var Config = new Object();
Config.closeKeys = [27];
var noteId = null;

window.addEventListener('message', function(event) {
    if (event.data.type == "openNotePadBlank") {
        $('#noteContainer').html('')
        $('#noteContainer').append('<textarea class="form-control" id="noteContentBox" name="noteContentBox"></textarea><div class="text-right" style="position:absolute; bottom:3px; right: 3px;"><button class="btn btn-sm btn-danger" data-act="closeNotepad">Close Notepad</button> <button class="btn btn-sm btn-success" data-act="saveNote">Save Note</button></div>')
        $('#noteContentBox').removeClass('is-invalid');
        $('#noteContainer').css({"display":"block"});
    } else if(event.data.type == "openNotePadContent") {
        noteId = event.data.id;
        $('#noteContainer').html('')
        $('#noteContainer').append('<textarea class="form-control" id="noteContentBox" name="noteContentBox">' + event.data.message + '</textarea><div class="text-right" style="position:absolute; bottom:3px; right: 3px;"><button class="btn btn-sm btn-danger" data-act="closeNotepad">Close Notepad</button> <button class="btn btn-sm btn-success" data-act="saveNote">Save Note</button></div>')
        $('#noteContentBox').removeClass('is-invalid');
        $('#noteContainer').css({"display":"block"});        
    }
});

function closeNotes() {
    $('#noteContainer').css({"display":"none"});
    $.post('http://pw_notes/closeNUI', JSON.stringify({ }));
    setTimeout(function(){
        $('#noteContentBox').val('');
            setTimeout(function(){
                $('#noteContainer').html('');
                noteId = null;
            }, 200);
    }, 500);
}

$(function() {
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeNotes()
        }
    });

    $(document).on('click','[data-act=closeNotepad]',function(){
        closeNotes();
    });

    $(document).on('click','[data-act=saveNote]',function(){
        var message = $('#noteContentBox').val()
        if(message !== undefined && message !== null && message !== "") {
            $('#noteContentBox').removeClass('is-invalid');
            $.post('http://pw_notes/saveNote', JSON.stringify({ message: message, noteid: noteId }));
            closeNotes()
        } else {
            $('#noteContentBox').addClass('is-invalid');
        }
    });

});