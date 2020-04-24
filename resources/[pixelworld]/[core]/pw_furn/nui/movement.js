var incrementBy = 0.01; // What the buttons will increment by, not the form objects
var incrementByH = 1.00;
var currentResourceRequest = null;
var curPos = null;
var moving = null;
var defaultPos = new Object();

window.addEventListener("message", function (event) {
    if(event.data.status == "show") {
        if(event.data.values.x !== null) {
            currentResourceRequest = event.data.resource
            if(defaultPos == null) {
                //defaultPos = event.data.values;
            }
            $('#mainView').animate({ opacity: 1.0 }, 0);
            $('#mainView').fadeIn(800);
            curPos = event.data.values;
            $('#xint').val((Math.round((event.data.values.x * 100)) / 100).toFixed(2));
            $('#yint').val((Math.round((event.data.values.y * 100)) / 100).toFixed(2));
            $('#zint').val((Math.round((event.data.values.z * 100)) / 100).toFixed(2));
            $('#hint').val((Math.round((event.data.values.h * 100)) / 100).toFixed(2));
            $('#xinthide').val(event.data.values.x);
            $('#yinthide').val(event.data.values.y);
            $('#zinthide').val(event.data.values.z);
            $('#hinthide').val(event.data.values.h);
            defaultPos.x = parseFloat($('#xinthide').val());
            defaultPos.y = parseFloat($('#yinthide').val());
            defaultPos.z = parseFloat($('#zinthide').val());
            defaultPos.h = parseFloat($('#hinthide').val());
            console.log('Default Pos X: ' + defaultPos.x)
        };
        if(event.data.focused === false) {
            fadeMenu()
        }
    }
    if(event.data.status == "hide") {
        $('#mainView').fadeOut(800);
        currentResourceRequest = null;
        curPos = null;
        defaultPos = new Object();;
    }
    if(event.data.status == "fadeout") {
        $('#mainView').animate({ opacity: 0.5 }, 100)
        
    }
    if(event.data.status == "fadein") {
        $('#mainView').animate({ opacity: 1.0 }, 100);
    }
    
});

function closeMenu(save) {
    $('#mainView').fadeOut(800);
    if(moving !== null) {
        clearInterval(moving);
    };
    if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
        $.post('http://' + currentResourceRequest + (save === true ? '/furnitureSave' : '/furnitureCancel'), JSON.stringify({}));
    }
    $.post('http://pw_furn/closeMenu', JSON.stringify({}));
}

function fadeMenu() {
    if(moving !== null) {
        clearInterval(moving);
    };
    $.post('http://pw_furn/setFocus', JSON.stringify({
        method: false
    }));
}

$(function() { 
    $("body").on("keydown", function (key) {
        if (key.which == 27) {
            closeMenu(false);
        }
        if(key.which == 77) {
            fadeMenu();
            
        }
    });

    $("input[type='number']").bind("input", function() {
        var id = $(this).attr('id');
        var currentValue = null;
        var post = null;
        switch(id) {
            case "xint":
                currentValue = +$('#xint').val();
                curPos.x = currentValue;
                post = "X";
                break;
            case "yint":
                currentValue = +$('#yint').val();
                curPos.y = currentValue;
                post = "Y";
                break;
            case "zint":
                currentValue = +$('#zint').val();
                curPos.z = currentValue;
                post = "Z";
                break;
            case "hint":
                currentValue = +$('#hint').val();
                if (currentValue < 0) {
                    currentValue = (currentValue + 360.0);
                    $('#hint').val(currentValue);
                } else if (currentValue > 360) {
                    currentValue = (currentValue - 360.0);
                    $('#hint').val(currentValue);
                }
                curPos.h = currentValue;
                post = "H";
                break;
        }

        if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
            $.post('http://' + currentResourceRequest + '/furniture' + post + 'Update', JSON.stringify({
                newvalue: currentValue,
                prevPos: curPos
            }));
        };
    });

    $(document).on('click','[data-act=reset]',function(){
        console.log('reset')
        $('#xint').val((Math.round((parseFloat($('#xinthide').val()) * 100)) / 100).toFixed(2));
        $('#yint').val((Math.round((parseFloat($('#yinthide').val()) * 100)) / 100).toFixed(2));
        $('#zint').val((Math.round((parseFloat($('#zinthide').val()) * 100)) / 100).toFixed(2));
        $('#hint').val((Math.round((parseFloat($('#hinthide').val()) * 100)) / 100).toFixed(2));
        console.log('Restoring Default Position: ' + defaultPos.x);
        if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
            $.post('http://' + currentResourceRequest + '/furnitureReset', JSON.stringify({
                defaultP: defaultPos,
            }));
        };
        curPos.x = parseFloat(defaultPos.x);
        curPos.y = parseFloat(defaultPos.y);
        curPos.z = parseFloat(defaultPos.z);
        curPos.h = parseFloat(defaultPos.h);
    });

    $(document).on('click','[data-act=save]',function(){
        closeMenu(true);
    });

    $(document).on('click','[data-act=cancel]',function(){
        closeMenu(false);
    });

    $(document).on('mousedown','[data-act=xleft]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#xint').val();
            var newValue = (currentValue - incrementBy);
            $('#xint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.x = parseFloat(curPos.x - incrementBy);
            
            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureXUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }
        }, 25);
    });

    $(document).on('mousedown','[data-act=xright]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#xint').val();
            var newValue = (currentValue + incrementBy);
            $('#xint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.x = parseFloat(curPos.x + incrementBy);
            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureXUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }
        }, 25);
    });

    $(document).on('mousedown','[data-act=ydown]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#yint').val();
            var newValue = (currentValue - incrementBy);
            $('#yint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.y = parseFloat(curPos.y - incrementBy);

            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureYUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }}, 25);
    });

    $(document).on('mousedown','[data-act=yup]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#yint').val();
            var newValue = (currentValue + incrementBy);
            $('#yint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.y = parseFloat(curPos.y + incrementBy);

            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureYUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }}, 25);
    });

    $(document).on('mousedown','[data-act=zdown]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#zint').val();
            var newValue = (currentValue - incrementBy);
            console.log(currentValue + ' ' + newValue)
            $('#zint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.z = parseFloat(curPos.z - incrementBy);
            
            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureZUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }}, 25);
    });

    $(document).on('mousedown','[data-act=zup]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#zint').val();
            var newValue = (currentValue + incrementBy);
            $('#zint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.z = parseFloat(curPos.z + incrementBy);

            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureZUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }}, 25);
    });

    $(document).on('mousedown','[data-act=hright]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#hint').val();
            var newValue = (currentValue - incrementByH);
            if (newValue < 0) {
                newValue = (360.0 + newValue);
            }
            $('#hint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.h = parseFloat(curPos.h - incrementByH);
            if (curPos.h < 0) {
                curPos.h = (360.0 + curPos.h);
            }
            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureHUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }}, 25);
    });

    $(document).on('mousedown','[data-act=hleft]',function(){
        moving = setInterval(function() {
            var currentValue = +$('#hint').val();
            var newValue = (currentValue + incrementByH);
            if (newValue > 360) {
                newValue = (newValue - 360);
            }
            $('#hint').val((Math.round((newValue * 100)) / 100).toFixed(2));
            curPos.h = parseFloat(curPos.h + incrementByH);
            if (curPos.h > 360) {
                curPos.h = (curPos.h - 360);
            }
            if(currentResourceRequest !== undefined && currentResourceRequest !== null) {
                $.post('http://' + currentResourceRequest + '/furnitureHUpdate', JSON.stringify({
                    oldvalue: currentValue,
                    newvalue: newValue,
                    prevPos: curPos
                }));
            }}, 25);
    });

    $(document).on('mouseup mouseleave','[data-act=yup], [data-act=ydown], [data-act=xleft], [data-act=xright], [data-act=zup], [data-act=zdown], [data-act=hright], [data-act=hleft]',function(){
        clearInterval(moving);
    });
});