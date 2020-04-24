var Config = new Object();
Config.closeKeys = [27];
var PaperOpen = false

$(document).on('auxclick', 'a', function(e) {
    if (e.which === 2) { //middle Click
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();
        return false;
    }
    return true;
});

window.addEventListener("message", function (event) {
    if(event.data.status == "openPaper") {
        $('#jailTitle').html('');
        $('#jailList').html('');
        if (event.data.amountJailed > 0) {
            $('#jailTitle').append('<strong>' + event.data.amountJailed + ' CURRENTLY JAILED</strong>');
            $.each(event.data.jailList, function (index, player) {
                $('#jailList').append('<div class="col-12 text-center"><strong>' + player.name + '</strong> was sent to Bolingbroke for <strong>' + player.time + ' months</strong> behind bars.</div>');
            });
        } else {
            $('#jailTitle').append('<strong>0 JAILED AT BOLINGBROKE</strong>');
            $('#jailList').append('<div class="col-12 text-center">There is no one currently jailed at Bolingroke - the police must be slacking!</div>');
            $('#jailList').append('<div class="col-12 text-center">Get the latest edition of the newspaper to stay up to date with who is currently in prison.</div>');
        }
        PaperOpen = true
        $('#newsPaperDiv').fadeIn(500);
    }
    if(event.data.status == "closePaper") {
        closePaper()
    }
});

function closePaper() {
    if (PaperOpen === true) {
        $('#newsPaperDiv').fadeOut(500);
        PaperOpen = false
        $.post('http://pw_newspapers/loseFocus', JSON.stringify({}));
    }
}

$(function() { 
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closePaper();
        }
    });
    $(document).on('click','[data-act=closePaper]',function(){
        closePaper()
    });
});