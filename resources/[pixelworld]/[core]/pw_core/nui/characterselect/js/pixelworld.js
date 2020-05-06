window.addEventListener("message", function (event) {   
    if(event.data.action == "loadFrontScreen") {
        $('#logoContainer').fadeIn(500);
        $('#mainContainer').fadeIn(500);
    }
    if(event.data.action == "loadLogin") {
        $('#steamIdent').html(event.data.value);
        if(event.data.value2 !== undefined || event.data.value2 !== null) {
            $('#emailAddress').val(event.data.value2);
        }
        $('#loginScreen').fadeIn(500);
    }
    if(event.data.action == "loadChars") {
        displayCharacters(event.data.value);
    }
    if(event.data.action == "spawns") {
        displaySpawns(event.data.value);
    }
    if(event.data.action == "noticeMessage") {
        $('#noticeMessage').addClass('alert-'+event.data.type);
        $('#noticeMessage').html(event.data.message);
        $('#noticeMessage').fadeIn(1000);
        setTimeout(function(){ 
            $('#noticeMessage').fadeIn(100);
            $('#noticeMessage').html('');
            $('#noticeMessage').removeClass('alert-'+event.data.type);
        }, event.data.time);
    }
    if(event.data.action == "shutDownNUI") {
        $('#noticeMessage').fadeOut(100);
        $('#loginScreen').fadeOut(500);
        $('#spawnScreen').fadeOut(500);
        $('#characterSelectionScreen').fadeOut(500);
        setTimeout(function(){
            $('#logoContainer').fadeOut(500);
            $('#mainContainer').fadeOut(500);
        }, 501);
    }
});

function displaySpawns(spawns) {
    $('#spawnSelections').html('');
    $.each(spawns, function (index, spawn) {
        $('#spawnSelections').append('<button class="btn btn-info m-2" data-act="selectSpawnPoint" data-spawnid="' + spawn.spawn_id + '">' + spawn.name + '</button>');
    });
    $('#spawnScreen').fadeIn(500);
}

function displayCharacters(chars) {
    for(i = 0; i < 10; i++) {
        $('[data-charid=' + (i+1) + ']').html('');
        $('[data-charbtn=' + (i+1) + ']').html('Slot '+ (i+1) +' Available');
        $('[data-charid=' + (i+1) + ']').html('<div class="card text-center mx-auto" style="max-width:800px; min-height:250px;"><div class="card-header">Slot ' + (i+1) + ' Avaliable</div><div class="card-body text-left"><div class="container-fluid"><div class="row"><div class="col-12 p-2 text-center"><i class="fad fa-user-plus fa-4x text-info"></i><br><button class="btn btn-success mt-3" data-act="createCharacter" style="min-width:400px;" data-slot="' + (i+1) + '">Create Character</button></div></div></div></div></div>');
    }

    $.each(chars, function (index, char) {
        if (char.cid !== 0) {
            if(char.sex == 1) {
                char.gender_human = "Male"
            } else {
                char.gender_human = "Female"
            }
            $('[data-charid=' + char.slot + ']').html('');
            $('[data-charbtn=' + char.slot + ']').html(char.firstname + ' ' + char.lastname);
            $('[data-charid=' + char.slot + ']').html('<div class="card text-center mx-auto" style="max-width:800px; min-height:250px; max-height:250px;"><div class="card-header">' + char.firstname + ' ' + char.lastname + '</div><div class="card-body text-left"><div class="container-fluid"><div class="row"><div class="col-12 pt-0 text-center" style="overflow-y:scroll;"><div class="container mt-0"><div class="row"><div class="col-6">Date of Birth<br><small>' + char.dateofbirth + '</small></div><div class="col-6">Sex<br><small>' + char.gender_human + '</small></div><div class="col-12 p-0">Biography<br><small>' + char.biography + '</small></div></div></div></div></div></div></div><div class="card-footer"><div class="row"><div class="col-6"><button class="btn btn-success btn-block btn-sm" data-act="selectCharacter"  data-character="' + char.cid + '" data-name="' + char.firstname + ' ' + char.lastname + '" data-slot="' + char.slot + '">Select Character</button></div><div class="col-6"><button class="btn btn-warning btn-block btn-sm" data-act="deleteCharacter"  data-character="' + char.cid + '" data-name="' + char.firstname + ' ' + char.lastname + '" data-slot="' + char.slot + '">Delete Character</button></div></div></div></div>');
        }
    });
    $('#characterSelectionScreen').fadeIn(500);
}

function doDisableButtons()
{
    $('button').addClass('disabled');
    setTimeout(function(){
        $('button').removeClass('disabled');
    }, 1500)
}

$( function() {
    $(document).on('click','[data-act=processLogin]',function(){
        if(!$(this).hasClass('disabled')) {
            doDisableButtons();
            var emailAddress = $('#emailAddress').val();
            var emailPassword = $('#emailPassword').val();
            $('#loginScreen').fadeOut(500);
            $('#emailAddress').val('');
            $('#emailPassword').val('');
            $.post('http://pw_core/verifyLogin', JSON.stringify({ 
                emailAddress: emailAddress,
                emailPassword: emailPassword
            }));
        }
    });

    
    $(document).on('click','[data-act=selectSpawnPoint]',function(){
        if(!$(this).hasClass('disabled')) {
            var spawnident = $(this).data('spawnid');
            if(spawnident !== undefined && spawnident !== null) {
                $('#spawnScreen').fadeOut(500);
                setTimeout(function(){ 
                    $.post('http://pw_core/spawnSelected', JSON.stringify({ 
                        spawn: spawnident,
                    }));
                }, 501);
            }
        }
    });


    $(document).on('click','[data-act=createCharacter]',function(){
        if(!$(this).hasClass('disabled')) {
            doDisableButtons();
            var slot = $(this).data('slot');
            $('#characterSelectionScreen').fadeOut(500);
            
            setTimeout(function(){ 
                $('#characterCreationScreen').fadeIn(500);
                $('[data-act=createNewCharacter]').data('slot', slot);
            }, 501);
        }
    });

    $(document).on('click','[data-act=characterSelect]',function(){
        if(!$(this).hasClass('disabled')) {
            doDisableButtons();
            $('#characterCreationScreen').fadeOut(500);
            $('#spawnScreen').fadeOut(500);
            setTimeout(function(){ 
                $('#firstName').val('');
                $('#lastName').val('');
                $('#gender').val('');
                $('#dateOfBirth').val('');
                $('#height').val('');
                $('#biography').val('');
                $.post('http://pw_core/loadCharacters', JSON.stringify({ }));
            }, 501);
        }
    });


    
    $(document).on('click','[data-act=selectCharacter]',function(){
        if(!$(this).hasClass('disabled')) {
            doDisableButtons();
            $('[data-act=deleteCharacter]').addClass('disabled');
            var cid = $(this).data('character');
            if(cid !== undefined && cid > 0) {
                $('#characterSelectionScreen').fadeOut(500);
                setTimeout(function(){ 
                    $.post('http://pw_core/selectCharacter', JSON.stringify({
                        cid: cid
                    }));
                }, 501);
            }
        }
    });
    
    $(document).on('click','[data-act=deleteCharacter]',function(){
        if(!$(this).hasClass('disabled')) {
            doDisableButtons();
            $('[data-act=selectCharacter]').addClass('disabled');
            var cid = $(this).data('character');
            $('#characterSelectionScreen').fadeOut(500);
            setTimeout(function(){ 
                $.post('http://pw_core/deleteCharacter', JSON.stringify({
                    cid: cid
                }));
            }, 501);
        }
    });

    $(document).on('click','[data-act=createNewCharacter]',function(){
        if(!$(this).hasClass('disabled')) {
            doDisableButtons();
            var error = false
            var firstName = $('#firstName').val();
            var lastName = $('#lastName').val();
            var gender = $('#gender').val();
            var dateOfBirth = $('#dateOfBirth').val();
            var height = $('#height').val();
            var biography = $('#biography').val();
            var slot = $(this).data('slot');
            
            if(firstName == undefined || firstName == null || firstName == "") {
                error = true;
                $('#firstName').addClass('is-invalid');
            } else {
                $('#firstName').removeClass('is-invalid');
            }

            if(lastName == undefined || lastName == null || lastName == "") {
                error = true;
                $('#lastName').addClass('is-invalid');
            } else {
                $('#lastName').removeClass('is-invalid');
            }

            if(gender == undefined || gender == null || gender == "") {
                error = true;
                $('#gender').addClass('is-invalid');
            } else {
                $('#gender').removeClass('is-invalid');
            }

            if(dateOfBirth == undefined || dateOfBirth == null || dateOfBirth == "") {
                error = true;
                $('#dateOfBirth').addClass('is-invalid');
            } else {
                $('#dateOfBirth').removeClass('is-invalid');
            }

            if(height == undefined || height == null || height == "") {
                error = true;
                $('#height').addClass('is-invalid');
            } else {
                $('#height').removeClass('is-invalid');
            }

            if(biography == undefined || biography == null || biography == "") {
                error = true;
                $('#biography').addClass('is-invalid');
            } else {
                $('#biography').removeClass('is-invalid');
            }

            if(error === false) {
                $('#characterCreationScreen').fadeOut(500);
                setTimeout(function(){ 
                    $('#firstName').val('');
                    $('#lastName').val('');
                    $('#gender').val('');
                    $('#dateOfBirth').val('');
                    $('#height').val('');
                    $('#biography').val('');
                    $.post('http://pw_core/createCharacter', JSON.stringify({
                        firstName: firstName,
                        lastName: lastName,
                        gender: gender,
                        dateOfBirth: dateOfBirth,
                        height: height,
                        biography: biography,
                        slot: slot,
                    }));
                }, 501);
            }
        }
        });

    
});