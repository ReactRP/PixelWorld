window.addEventListener("message", function (event) {
    switch(event.data.action) {
        case 'showUsableBar':
            UsableBar(event.data.items);
            break;
        case 'hideUsableBar':
            $('#usable-bar').fadeOut(500);
            setTimeout(function() {
                $('#usable-bar').html('');
            }, 502)
            break;
    }
});


function UsableBar(items) {
    if(items !== undefined && items !== null) {
        total = items.length
        $('#usable-bar').html('');
        for (let i = 0; i < total; i++) {
            $('#usable-bar').append(`<div class="slot slot-usable-${i}" data-empty="true"><div class="item"><div class="item-action" style="display:none;"></div><div class="item-name">NONE</div></div></div>`);
            $(`.slot-usable-${i}`).find('.item').css('background-image', 'none');
        }

        $.each(items, function (index, item) {
            console.log(`url(\'img/${item.type}/${item.image}\')`);
            $(`.slot-usable-${index}`).find('.item-name').html(item.label);
            $(`.slot-usable-${index}`).find('.item').css('background-image', `url(\'img/${item.type}/${item.image}\')`);
            if(item.action !== undefined && item.action !== null) {
                $(`.slot-usable-${index}`).find('.item-action').html(item.action).css({"display":"block"});
            }
        })

        $('#usable-bar').fadeIn(500);
    }
}