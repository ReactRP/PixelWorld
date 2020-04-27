var type = "normal";
var firstTier = 1;
var firstUsed = 0;
var firstItems = new Array();
var secondTier = 1;
var secondUsed = 0;
var secondItems = new Array();
var playerCash = 0;

var dragging = false
var origDrag = null;
var draggingItem = null;
var givingItem = null;
var errorHighlightTimer = null;
var mousedown = false;
var docWidth = document.documentElement.clientWidth;
var docHeight = document.documentElement.clientHeight;
var offset = [76,81];
var cursorX = docWidth / 2;
var cursorY = docHeight / 2;
var thirdInventory = false;

var successAudio = document.createElement('audio');
successAudio.controls = false;
successAudio.volume = 0.25;
successAudio.src = './success.wav';

var failAudio = document.createElement('audio');
failAudio.controls = false;
failAudio.volume = 0.1;
failAudio.src = './fail.wav';

window.addEventListener("message", function (event) {
    switch(event.data.action) {
        case 'display':
            type = event.data.type
    
            if (type === "normal") {
                $('#inventoryTwo').parent().hide();
            } else if (type === "secondary") {
                $('#inventoryTwo').parent().fadeIn();
            }
    
            $(".ui").fadeIn();
            break;
        case 'hide':
            $(".ui").fadeOut();
            break;
        case 'updateCash':
            playerCash = event.data.cash;
            break;
        case 'closeSecondary':
            $('#inventoryTwo').parent().fadeOut('normal', function() {
                $('#inventoryTwo').html('');
            })
            break;
        case 'setItems':
            firstTier = event.data.invTier;
            inventorySetup(event.data.invOwner, event.data.itemList);

            if ($('#search').val() !== '') {
                SearchInventory($('#search').val());
            }

            break;
        case 'setSecondInventoryItems':
            secondTier = event.data.invTier;
            secondInventorySetup(event.data.invOwner, event.data.itemList);

            if ($('#search').val() !== '') {
                SearchInventory($('#search').val());
            }

            break;
        case 'setInfoText':
            $(".info-div").html(event.data.text);
            break;
        case 'nearPlayers':
            if (event.data.players.length > 0) {
                successAudio.play();
                $('.near-players-wrapper').find('.popup-body').html('');
                $.each(event.data.players, function(index, player) {
                    $('.near-players-list .popup-body').append(`<div class="player" data-id="${player.id}">${player.id} - ${player.name}</div>`);
                });
                $('.near-players-wrapper').fadeIn();
            } else {
                DisplayMoveError(origDrag, origDrag, 'Attempted To Give An Item To A Nearest Player, But No Players Are Around.');
            }
            EndDragging();
            break;
        case 'itemUsed':
            ItemUsed(event.data.alerts);
            break;
        case 'showActionBar':
            ActionBar(event.data.items, event.data.timer);

            if (event.data.index != null) {
                ActionBarUsed(event.data.index);
            }
            break;
    }
});

function formatCurrency(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function EndDragging() {
    $(origDrag).removeClass('orig-dragging');
    $("#use").removeClass("disabled");
    $("#drop").removeClass("disabled");
    $("#give").removeClass("disabled");
    $(draggingItem).remove();
    origDrag = null;
    draggingItem = null;
    dragging = false;
}

function closeInventory() {
    EndDragging();
    $.post("http://pw_inventory/NUIFocusOff", JSON.stringify({}));
    $('.near-players-wrapper').fadeOut();
    $('#search').val('');
    $('#count').val('0');
}

function inventorySetup(invOwner, items) {
    setupPlayerSlots();
    $('#player-inv-label').html(firstTier.label);
    $('#player-inv-id').html(`${firstTier.label.toLowerCase()} - ${invOwner.owner}`);
    invOwner.label = `${firstTier.label.toLowerCase()} - ${invOwner.owner}`;
    $('#inventoryOne').data('invOwner', invOwner);

    firstUsed = 0;
    $.each(items, function (index, item) {
        var slot = $('#inventoryOne').find('.slot').filter(function(){ return $(this).data('slot') === item.slot;});
        firstUsed++;
        var slotId = $(slot).data('slot');
        firstItems[slotId] = item;
        AddItemToSlot(slot, item);
    });

    $('#player-used').html(firstUsed);
    $("#inventoryOne > .slot:lt(5) .item").append('<div class="item-keybind"></div>');

    $('#inventoryOne .item-keybind').each(function(index ) {
        $(this).html(index + 1);
    })
}

function secondInventorySetup(invOwner, items) {
    setupSecondarySlots(invOwner);
    $('#other-inv-label').html(secondTier.label);
    invOwner.label = `${secondTier.label.toLowerCase()} - ${invOwner.owner}`;
    if(invOwner.req !== undefined && invOwner.req !== null) {
        $('#other-inv-id').html(`${invOwner.req}`);
    } else {
        $('#other-inv-id').html(`${secondTier.label.toLowerCase()} - ${invOwner.owner}`);
    }
    $('#inventoryTwo').data('invOwner', invOwner);
    secondUsed = 0;
    $.each(items, function (index, item) {
        if (invOwner.type == 18) {
            item.qty = item.max;
        }

        var slot = $('#inventoryTwo').find('.slot').filter(function(){ return $(this).data('slot') === item.slot;});
        secondUsed++;

        if ($(slot).find('.item .shop-cost').length > 0) {
            $(slot).find('.item .shop-cost').html(`$${formatCurrency(item.price)}`)
        }

        var slotId = $(slot).data('slot');
        secondItems[slotId] = item;
        AddItemToSlot(slot, item);
    });
    
    $('#other-used').html(secondUsed);
}

function setupPlayerSlots() {
    $('#inventoryOne').html("");
    $('#player-inv-id').html("");
    $('#inventoryOne').removeData('invOwner');
    $('#player-max').html(firstTier.slots);
    for(i = 1; i <= (firstTier.slots); i++) {
        $("#inventoryOne").append($('.slot-template').clone());
        $('#inventoryOne').find('.slot-template').data('slot', i);
        $('#inventoryOne').find('.slot-template').data('inventory', 'inventoryOne');
        $('#inventoryOne').find('.slot-template').removeClass('slot-template');
    };
}

function setupSecondarySlots(owner) {
    $('#inventoryTwo').html("");
    $('#other-inv-id').html("");
    $('#inventoryTwo').removeData('invOwner');
    $('#other-max').html(secondTier.slots);
    for(i = 1; i <= (secondTier.slots); i++) {
        $("#inventoryTwo").append($('.slot-template').clone());
        $('#inventoryTwo').find('.slot-template').data('slot', i);
        $('#inventoryTwo').find('.slot-template').data('inventory', 'inventoryTwo');

        switch(owner.type) {
            case 1:
                $('#inventoryTwo').find('.slot-template').addClass('player');
                break;
            case 2:
            case 3:
            case 6:
            case 7:
            case 17:
                $('#inventoryTwo').find('.slot-template').addClass('temporary');
                break;
            case 4:
            case 5:
            case 8:
            case 9:
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
                $('#inventoryTwo').find('.slot-template').addClass('storage');
                break;
            case 16:
                $('#inventoryTwo').find('.slot-template').addClass('evidence');
                break;
            case 18:
                $('#inventoryTwo').find('.slot-template').addClass('shop');
                $('#inventoryTwo').find('.slot-template').find('.item').append('<div class="shop-cost"></div>');
                break;
        }

        $('#inventoryTwo').find('.slot-template').removeClass('slot-template');
    };
}

document.addEventListener('mousemove', function(event) {
    event.preventDefault();
    cursorX = event.clientX,
    cursorY = event.clientY
    if (dragging) {
        if(draggingItem !== undefined && draggingItem !== null) {
            draggingItem.css('left', (cursorX - offset[0]) + 'px');
            draggingItem.css('top', (cursorY - offset[1]) + 'px');
        }
    }
}, true);

$(document).ready(function () {
    $('#inventoryTwo').parent().hide();

    $('#inventoryOne, #inventoryTwo').on('click', '.slot', function(e) {
        itemData = $(this).find('.item').data('item');
        if (itemData == null && !dragging) { return };

        if(dragging) {

            if($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner')) {    
                if ($(this).parent().data('invOwner').type == 18) {
                    DisplayMoveError(origDrag, $(this), 'Cannot Put Items In Inventory');
                    EndDragging();
                    return;
                }
                
                if($(this).find('.item').data('item') !== undefined) {
                    AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val()));
                } else {
                    AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                }
            } else {
                successAudio.play();
            }
            EndDragging();
        } else {
            if (itemData !== undefined) {
                // Store a reference because JS is retarded
                origDrag = $(this)
                AddItemToSlot(origDrag, itemData);
                $(origDrag).data('slot', $(this).find('.item').data('slot'));
                $(origDrag).data('invOwner', $(this).parent().data('invOwner'));
                $(origDrag).addClass('orig-dragging');

                // Clone this shit for dragging
                draggingItem = $(this).clone();
                AddItemToSlot(draggingItem, itemData);
                $(draggingItem).data('slot', $(this).find('.item').data('slot'));
                $(draggingItem).data('invOwner', $(this).parent().data('invOwner'));
                $(draggingItem).addClass('dragging');

                $(draggingItem).css('pointer-events', 'none');
                $(draggingItem).css('left', (cursorX - offset[0]) + 'px');
                $(draggingItem).css('top', (cursorY - offset[1]) + 'px');
                $('.ui').append(draggingItem);

                if (!itemData.usable) {
                    $("#use").addClass("disabled");
                }

                if (!itemData.canRemove || ($(this).parent().data('invOwner') == $('#inventoryTwo').data('invOwner'))) {
                    $("#drop").addClass("disabled");
                    $("#give").addClass("disabled");
                }
            }
            dragging = true;
        }

    });

    $('#close').click(function (event, ui) {
        closeInventory();
    });

    $('.toggle-log').click(function (event, ui) {
        if ($('.inv-log').is(':visible')) {
            $('.inv-log').fadeOut('normal');
        } else {
            $('.inv-log').fadeIn('normal');
        }
    });

    $('#use').click(function (event, ui) {
        if (!$(this).hasClass('disabled')) {
            if(dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                if (itemData.usable) {
                    InventoryLog(`Using ${itemData.label}`);
                    $.post("http://pw_inventory/UseItem", JSON.stringify({
                        owner: $(draggingItem).parent().data('invOwner'),
                        item: itemData
                    }), function(closeUi) {
                        if(closeUi) {
                            closeInventory();
                        }
                    });
                    successAudio.play();
                } else {
                    failAudio.play();
                }
                EndDragging();
            }
        } else {
            DisplayMoveError(origDrag, origDrag, 'Using Disabled');
            EndDragging();
        }
    });

    $("#use").mouseenter(function() {
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });

    $('#give').click(function (event, ui) {
        if (!$(this).hasClass('disabled')) {
            if(dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                let dropCount = parseInt($("#count").val());
    
                if (dropCount === 0 || dropCount > itemData.qty) {
                    dropCount = itemData.qty
                }
    
                if (itemData.canRemove) {
                    $.post("http://pw_inventory/GetSurroundingPlayers", JSON.stringify({}));
                    givingItem = itemData;
                } else {
                    failAudio.play();
                }
            }
        } else {
            DisplayMoveError(origDrag, origDrag, 'Giving Disabled');
            EndDragging();
        }
    });

    $("#give").mouseenter(function() {
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });

    $('#drop').click(function (event, ui) {
        if (!$(this).hasClass('disabled')) {
            if(dragging) {
                itemData = $(draggingItem).find('.item').data("item");
                let dropCount = parseInt($("#count").val());
    
                if (dropCount === 0 || dropCount > itemData.qty) {
                    dropCount = itemData.qty
                }
    
                if (itemData.canRemove) {
                    InventoryLog(`Dropping ${dropCount} ${itemData.label} On Ground`);
                    $.post("http://pw_inventory/DropItem", JSON.stringify({
                        item: itemData,
                        qty: dropCount
                    }));
                    successAudio.play();
                } else {
                    failAudio.play();
                }
                EndDragging();
            }
        } else {
            DisplayMoveError(origDrag, origDrag, 'Droping Disabled');
            EndDragging();
        }
    });

    $("#drop").mouseenter(function() {
        if(!$(this).hasClass('disabled')) {
            $(this).addClass('hover');
        }
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });

    $('#inventoryOne, #inventoryTwo').on('mouseenter', '.slot', function() {
        var itemData = $(this).find('.item').data('item');
        if(itemData !== undefined) {
            $('.tooltip-div').find('.tooltip-name').html(itemData.label);

            if(!itemData.unique) {
                if(itemData.stackable) {
                    $('.tooltip-div').find('.tooltip-uniqueness').html("Not Unique - Stack Max(" + itemData.max + ")");
                } else {
                    $('.tooltip-div').find('.tooltip-uniqueness').html("Not Unique - Not Stackable");
                }
            } else {
                $('.tooltip-div').find('.tooltip-uniqueness').html("Unique (" + itemData.max + ")");
            }

            $('.tooltip-div').find('.tooltip-meta').html('');
            if(itemData.metadata != null) {
                if(itemData.type === 1) {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Registered Owner</div> : <div class="meta-val">${itemData.metadata.owner}</div></div>`);
                } else if(itemData.itemId === 'license') {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Name</div> : <div class="meta-val">${itemData.metadata.name}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Issued On</div> : <div class="meta-val">${itemData.metadata.issuedDate}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Height</div> : <div class="meta-val">${itemData.metadata.height}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Date of Birth</div> : <div class="meta-val">${itemData.metadata.dob}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Phone Number</div> : <div class="meta-val">${itemData.metadata.phone}</div></div>`);
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Citizen ID</div> : <div class="meta-val">${itemData.metadata.id} - ${itemData.metadata.user}</div></div>`);

                    if(itemData.metadata.endorsements !== undefined) {
                        $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">Endorsement</div> : <div class="meta-val">${itemData.metadata.endorsements}</div></div>`);
                    }

                    if (itemData.description != null && itemData.description != '') {
                        $('.tooltip-div').find('.tooltip-meta').append(`<hr /><div class="meta-desc">${itemData.description}</div>`);
                    } 
                } else if(itemData.metadata.app !== undefined) {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-entry"><div class="meta-key">App Package</div> : <div class="meta-val">${itemData.metadata.app}</div></div>`);
                }
            } else {
                if (itemData.description != null && itemData.description != '') {
                    $('.tooltip-div').find('.tooltip-meta').append(`<div class="meta-desc">${itemData.description}</div>`);
                } else {
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-desc">This Item Has No Information</div>');
                }
            }

            $('.tooltip-div').show();
        }
    });

    $('#inventoryOne, #inventoryTwo').on('mouseleave', '.slot', function() {
        $('.tooltip-div').hide();
        $('.tooltip-div').find('.tooltip-name').html("");
        $('.tooltip-div').find('.tooltip-uniqueness').html("");
        $('.tooltip-div').find('.tooltip-meta').html("");
    });

    $("body").on("keyup", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeInventory();
        }

        if(key.which === 69) {
            if (type === "trunk") {
                closeInventory();
            }
        }
    });

    $('#count').on('keyup keydown blur', function(e) {
        switch(e.which) {
            case 107: // Numpad Equals
            case 109: // Numpad Minus
            case 110: // Numpad Decimal
            case 187: // =/+
            case 189: // -/_
            case 190: // ./>
                e.preventDefault();
                break;
        }
        if ($(this).val() == '') {
            $(this).val('0');
        } else {
            $(this).val(parseInt($(this).val()))
        }
    });

    $('.exit-popup').on('click', function() {
        givingItem = null;
        $('.near-players-wrapper').fadeOut('normal').promise().then(function() {
            $(this).find('.popup-body').html('');
        });
    });

    $('.popup-body').on('click', '.player', function() {
        if (givingItem != null) {
            let target = $(this).data('id');
            let count = parseInt($("#count").val())

            if (count === 0 || count > givingItem.qty) {
                count = givingItem.qty
            } 

            InventoryLog(`Giving ${count} ${givingItem.label} To Nearby Player With Server ID ${target}`);
            $.post("http://pw_inventory/GiveItem", JSON.stringify({
                target: target,
                item: givingItem,
                count: count
            }), function(status){
                if (status) {
                    $('.near-players-wrapper').fadeOut();

                    if (count == givingItem.qty) {
                        ResetSlotToEmpty(givingItem.slot);
                    }

                    givingItem = null;
                }
            });
        }
    });

    $('#search').on('keyup keydown blur', function(e) {
        SearchInventory($(this).val());
    });

    $('#search-reset').on('click', function() {
        SearchInventory('');
        $('#search').val('');
    });

    $('#count-reset').on('click', function() {
        $('#count').val('0');
    });
});
 
function SearchInventory(searchVal) {
    if (searchVal !== '') {
        $.each(
            $('#search')
                .parent()
                .parent()
                .parent()
                .find('#inventoryOne, #inventoryTwo')
                .children(),
            function(index, slot) {
                let item = $(slot).find('.item').data('item');

                if (item != null) {
                    if (
                        item.label.toUpperCase().includes(searchVal.toUpperCase()) ||
                        item.itemId.includes(searchVal.toUpperCase())
                    ) {
                        $(slot).removeClass('search-non-match');
                    } else {
                        $(slot).addClass('search-non-match');
                    }
                } else {
                    $(slot).addClass('search-non-match');
                }
            }
        );

    } else {
        $.each(
            $('#search')
                .parent()
                .parent()
                .parent()
                .find('#inventoryOne, #inventoryTwo')
                .children(),
            function(index, slot) {
                $(slot).removeClass('search-non-match');
            }
        );
    }
}

function AttemptDropInEmptySlot(origin, destination, moveQty) {
    let result = ErrorCheck(origin, destination, moveQty)
    if (result === -1) {
        $('.slot.error').removeClass('error');

        let item = origin.find('.item').data('item')

        if (item == null) { return; }

        if(moveQty > item.qty || moveQty === 0) { moveQty = item.qty; }

        if(moveQty === item.qty) {
            if (origin.parent().data('invOwner').type != 18) {
                ResetSlotToEmpty(origin);
            }
            
            item.slot = destination.data('slot');
            AddItemToSlot(destination, item);

            successAudio.play();

            InventoryLog(`Moving ${item.qty} ${item.label} From ${origin.data('invOwner').label} Slot ${origin.data('slot')} To ${destination.parent().data('invOwner').label} Slot ${item.slot}`)
            $.post("http://pw_inventory/MoveToEmpty", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.data('slot'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
            }));
        } else {
            let item2 = Object.create(item);
            item2.slot = destination.data('slot');
            item2.qty = moveQty;

            if (origin.parent().data('invOwner').type != 18) {
                item.qty = item.qty - moveQty
                AddItemToSlot(origin, item);
            }
            
            AddItemToSlot(destination, item2);
            successAudio.play();
            
            InventoryLog(`Moving ${moveQty} ${item.label} From ${origin.data('invOwner').label} Slot ${item.slot} To ${destination.parent().data('invOwner').label} Slot ${item.slot}`);
            $.post("http://pw_inventory/SplitStack", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.find('.item').data('item'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
                moveQty: moveQty,
            }));
        }
    } else {
        switch(result) {
            case 1:
                DisplayMoveError(origin, destination, "Destination Inventory Owner Was Undefined");
                break;
            case 8:
                DisplayMoveError(origin, destination, "You do not have enough cash to purchase this item");
                break;
        }
    }
}

function AttemptDropInOccupiedSlot(origin, destination, moveQty) {
    let originItem = origin.find('.item').data('item');
    let destinationItem = destination.find('.item').data('item');

    if (originItem == undefined || destinationItem == undefined) { return; }

    if(moveQty > originItem.qty || moveQty === 0) { 
        moveQty = originItem.qty;
    }

    let result = ErrorCheck(origin, destination, moveQty);

    if(result === -1) {
        $('.slot.error').removeClass('error');

        if (originItem.itemId === destinationItem.itemId && destinationItem.stackable) {
            if (moveQty != originItem.qty) {
                if (destinationItem.qty + moveQty <= destinationItem.max) {
                    destinationItem.qty += moveQty;

                    if (origin.parent().data('invOwner').type != 18) {
                        originItem.qty -= moveQty;
                        AddItemToSlot(origin, originItem);
                    }

                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();
                    InventoryLog(`Adding ${moveQty} ${originItem.label} In ${origin.data('invOwner').label} Slot ${originItem.slot} To ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/SplitStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                        moveQty: moveQty,
                    }));
                } else if (destinationItem.qty < destinationItem.max) {
                    let newOrigQty = destinationItem.max - destinationItem.qty;

                    if (origin.parent().data('invOwner').type != 18) {
                        originItem.qty -= newOrigQty;
                        AddItemToSlot(origin, originItem);
                    }
                    
                    destinationItem.qty = destinationItem.max;
                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();
    
                    InventoryLog(`Adding ${originItem.label} To Existing Stack In Inventory ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/TopoffStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                } else {
                    DisplayMoveError(origin, destination, "Stack At Max Items");
                }
            } else {
                if ((destinationItem.qty === destinationItem.max || originItem.qty === originItem.max)) {
                    if (origin.parent().data('invOwner').type == 18) {
                        DisplayMoveError(origin, destination, "Cannot Swap Items With Items In Shop");
                        return;
                    }

                    destinationItem.slot = origin.data('slot')
                    originItem.slot = destination.data('slot');
        
                    ResetSlotToEmpty(origin);
                    AddItemToSlot(origin, destinationItem);
                    ResetSlotToEmpty(destination);
                    AddItemToSlot(destination, originItem);
                    successAudio.play();
    
                    InventoryLog(`Swapping ${originItem.label} In ${destination.parent().data('invOwner').label} Slot ${originItem.slot} With ${destinationItem.label} In ${origin.data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/SwapItems", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                }
                else if(originItem.qty + destinationItem.qty <= destinationItem.max) {
                    if (origin.parent().data('invOwner').type != 18) {
                        ResetSlotToEmpty(origin);
                    }

                    destinationItem.qty += originItem.qty;
                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();

                    InventoryLog(`Merging Stack Of ${originItem.label} In ${origin.data('invOwner').label} Slot ${originItem.slot} To ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/CombineStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.data('slot'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                } else {
                    let newOrigQty = destinationItem.max - destinationItem.qty;

                    if (origin.parent().data('invOwner').type != 18) {
                        originItem.qty -= newOrigQty;
                        AddItemToSlot(origin, originItem);
                    }
                    
                    destinationItem.qty = destinationItem.max;
                    AddItemToSlot(destination, destinationItem);
    
                    successAudio.play();
    
                    InventoryLog(`Adding ${originItem.label} To Existing Stack In Inventorry ${destination.parent().data('invOwner').label} Slot ${destinationItem.slot}`);
                    $.post("http://pw_inventory/TopoffStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                    }));
                }
            }

        } else {
            if (origin.parent().data('invOwner').type == 18) {
                DisplayMoveError(origin, destination, "Cannot Swap Items With Items In Shop");
                return;
            }

            destinationItem.slot = origin.data('slot')
            originItem.slot = destination.data('slot');

            ResetSlotToEmpty(origin);
            AddItemToSlot(origin, destinationItem);
            ResetSlotToEmpty(destination);
            AddItemToSlot(destination, originItem);
            successAudio.play();
            
            InventoryLog(`Swapping ${originItem.label} In ${destination.parent().data('invOwner').label} Slot ${originItem.slot} With ${destinationItem.label} In ${origin.data('invOwner').label} Slot ${destinationItem.slot}`);
            $.post("http://pw_inventory/SwapItems", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.find('.item').data('item'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
            }));
        }
    } else {
        switch(result) {
            case 1:
                DisplayMoveError(origin, destination, "Destination Inventory Owner Was Undefined");
                break;
            case 2:
                DisplayMoveError(origin, destination, "Max Items In Stack");
                break;
            case 8:
                DisplayMoveError(origin, destination, "You do not have enough cash to purchase this.");
                break;
        }
    }
}

function DisplayMoveError(origin, destination, error) {
    failAudio.play();
    $('.error').removeClass('error');
    clearTimeout(errorHighlightTimer);

    origin.addClass('error');
    destination.addClass('error');
    errorHighlightTimer = setTimeout(function() {
        origin.removeClass('error');
        destination.removeClass('error');
    }, 1000);

    InventoryLog(error);
}

function ErrorCheck(origin, destination, moveQty) {
    var status = -1;

    var originOwner = origin.parent().data('invOwner');
    var destinationOwner = destination.parent().data('invOwner');

    if(destinationOwner === undefined) {
        return 1
    }

    var originItem = origin.find('.item').data('item');
    var destinationItem = destination.find('.item').data('item');

    if(originOwner.type === 18) {
        if(moveQty === 0) { 
            moveQty = 1
        }
        if(playerCash < (originItem.price * moveQty)) {
            return 8
        } else {
            var reduction = (originItem.price * moveQty);
            playerCash = (playerCash - reduction);
        }
    }

    return status
}

function ResetSlotToEmpty(slot) {
    slot.find('.item').addClass('empty-item');
    slot.find('.item').css('background-image', 'none');
    slot.find('.item-count').html(" ");
    slot.find('.item-name').html(" ");
    slot.find('.item').removeData("item");
    slot.find('.progress').css({"display":"none"});
    slot.find('.progress-bar').css({"width":"0%"});
    slot.find('.item-count').css({"top":"0"});
    slot.find('.item-keybind').css({"top":"0"});
}

function AddItemToSlot(slot, data) {
    slot.find('.empty-item').removeClass('empty-item');
    slot.find('.item').css('background-image', `url(\'img/item/${data.image}\')`); 
    slot.find('.item-count').html(data.qty);
    slot.find('.item-name').html(data.label);
    console.log(data.slot)

    if(data.slot > 5) {
        console.log(data.label + ' ' + data.slot);
        slot.find('.progress').css({"left":"0"}).css({"display":"flex"}).css({"width":"100%"});
        slot.find('.progress-bar').css({"width":"" + data.health + "%"});
    } else {
        console.log(data.label + ' ' + data.slot);
        slot.find('.progress').css({"left":"31px"}).css({"display":"flex"}).css({"width":"90px"});
        slot.find('.progress-bar').css({"width":"" + data.health + "%"});
    }

    
    slot.find('.item').data('item', data); 
}

var alertTimer = null;
var hiddenCheck = null;
function ItemUsed(alerts) {
    clearTimeout(alertTimer);
    clearInterval(hiddenCheck);

    $('#use-alert').hide('slide', { direction: 'left' }, 500, function() {
        $('#use-alert .slot').remove();
    });

    if (alerts != null) {
        hiddenCheck = setInterval(function() {
            if (!$('#use-alert').is(':visible') && $('#use-alert .slot').length <= 0) {
                $.each(alerts, function(index, data) {
                    if (data.item != null) {
                        $('#use-alert').append(`<div class="slot alert-${index}""><div class="item"><div class="item-count">${data.qty}</div><div class="item-name">${data.item.label}</div></div><div class="alert-text">${data.message}</div></div>`)
                        .ready(function() {
                            $(`.alert-${index}`).find('.item').css('background-image', `url(\'img/item/${data.item.image}\')`);
                            if (data.item.slot <= 5) {
                                $(`.alert-${index}`).find('.item').append(`<div class="item-keybind">${data.item.slot}</div>`)
                            }
                        });
                    }
                });
    
                clearInterval(hiddenCheck);
        
            
                $('#use-alert').show('slide', { direction: 'left' }, 500, function() {
                    alertTimer = setTimeout(function() {
                        $('#use-alert .slot').addClass('expired');
                        $('#use-alert').hide('slide', { direction: 'left' }, 500, function() {
                            $('#use-alert .slot.expired').remove();
                        });
                    }, 2500);
                });
            }
        }, 100)
    }
}

var actionBarTimer = null;
function ActionBar(items, timer) {
    if ($('#action-bar').is(':visible')) {
        clearTimeout(actionBarTimer);

        for (let i = 0; i < 5; i++) {
            $('#action-bar .slot').removeClass('expired');
            if (items[i] != null) {
                $(`.slot-${items[i].slot}`).find('.item-count').html(items[i].qty);
                $(`.slot-${items[i].slot}`).find('.item-name').html(items[i].label);
                $(`.slot-${items[i].slot}`).find('.item-keybind').html(items[i].slot);
                $(`.slot-${items[i].slot}`).find('.item').css('background-image', `url(\'img/item/${items[i].image}\')`);
            } else {
                $(`.slot-${i}`).find('.item-count').html('');
                $(`.slot-${i}`).find('.item-name').html('NONE');
                $(`.slot-${i}`).find('.item-keybind').html(i + 1);
                $(`.slot-${i}`).find('.item').css('background-image', 'none');
            }
        
            actionBarTimer = setTimeout(function() {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', { direction: 'down' }, 500, function() {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 5000 : timer);
        }
    } else {
        $('#action-bar').html('');
        for (let i = 0; i < 5; i++) {
            if (items[i] != null) {
                $('#action-bar').append(`<div class="slot slot-${items[i].slot}"><div class="item"><div class="item-count">${items[i].qty}</div><div class="item-name">${items[i].label}</div><div class="item-keybind">${items[i].slot}</div></div></div>`);
                $(`.slot-${items[i].slot}`).find('.item').css('background-image', `url(\'img/item/${items[i].image}\')`);
            } else {
                $('#action-bar').append(`<div class="slot slot-${i}" data-empty="true"><div class="item"><div class="item-count"></div><div class="item-name">NONE</div><div class="item-keybind">${i + 1}</div></div></div>`);
                $(`.slot-${i}`).find('.item').css('background-image', 'none');
            }
        }
        
        $('#action-bar').show('slide', { direction: 'down' }, 500, function() {
            actionBarTimer = setTimeout(function() {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', { direction: 'down' }, 500, function() {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 5000 : timer);
        });
    }
}

var usedActionTimer = null;
function ActionBarUsed(index) {
    clearTimeout(usedActionTimer);

    if ($('#action-bar .slot').is(':visible')) {
        if ($(`.slot-${index}`).data('empty') != null) {
            $(`.slot-${index}`).addClass('empty-used');
        } else {
            $(`.slot-${index}`).addClass('used');
        }
        usedActionTimer = setTimeout(function() {
            $(`.slot-${index}`).removeClass('used');
            $(`.slot-${index}`).removeClass('empty-used');
        }, 1000)
    }
}

function ClearLog() {
    $('.inv-log').html('');
}

function InventoryLog(log) {
    $('.inv-log').html(log + "<br>" + $('.inv-log').html());
}