var currentPosition

window.addEventListener("message", function (event) {   
    if (event.data.action == "showHouse") {
        $('#showHouse').css({"display":"flex"});
        currentPosition = event.data.position
        generateMessage(event.data.messages, event.data.player);
    } else if(event.data.action == "updateLock") {
        updateLocks(event.data.messages, event.data.player, event.data.toggle);
    }
    else if(event.data.action == "hideHouse") {
        if (currentPosition == event.data.position) {
            currentPosition = null
            $('#showHouse').css({"display":"none"});
            $("#messages").html('');
            $('#icon').html('<i class="fad fa-home-lg fa-3x"></i>')
        }
    }
});

function updateLocks(data, player, toggle) {
    var doorLock = "";
    if(toggle) {
        doorLock = "<small>Door Status: <span class='text-danger'><i class='fa-fw fad fa-key'></i></span></small>";
    } else {
        doorLock = "<small>Door Status: <span class='text-success'><i class='fa-fw fad fa-key'></i></span></small>";
    }
    if (data.bought && player.cid == data.rentor && !data.forSale) {
        $('#doorLockState').html(doorLock);
    } else if (data.bought && player.cid == data.rentor && data.forSale) {
        $('#doorLockState').html(doorLock);
    } else if (data.bought && data.propertyRented && player.cid == data.ownerCid) {
        $('#doorLockState').html(doorLock);
    } else if (data.bought && data.forSale && player.cid == data.ownerCid) { 
        $('#doorLockState').html(doorLock);
    } else if (data.bought && data.forRent && player.cid == data.ownerCid) {
        $('#doorLockState').html(doorLock);
    } else if (data.bought && player.cid == data.ownerCid) { 
        $('#doorLockState').html(doorLock);
    } else {
        $('#doorLockState').html('');
    }
}

function generateMessage(data, player) {
    $("#messages").html('');
    if(data.name !== undefined || data.name !== null) {
        $("#name").html('');
        $("#name").html('<small>' + data.name + '</small>'); 
    }
    var doorLock = "";

    if(data.doorStatus) {
        doorLock = "<small>Door Status: <span class='text-danger'><i class='fa-fw fad fa-key'></i></span></small>";
    } else {
        doorLock = "<small>Door Status: <span class='text-success'><i class='fa-fw fad fa-key'></i></span></small>";
    }
    $('#doorLockState').html('');

    if(currentPosition == "frontdoor") {
        if(!data.bought && data.forSale) {
            $("#messages").append('<i class="fad fa-money-bill-alt text-success fa-fw"></i> For Sale!<br><i class="fad fa-dollar-sign fa-fw"></i> Price: '+ data.price);
        } else if (!data.bought && data.forRent) {
            $("#messages").append('<i class="fad fa-badge-dollar text-success fa-fw"></i> Avaliable for Rent<br><i class="fad fa-dollar-sign fa-fw"></i> Cost: $'+ data.rentPrice+'/week');
        } else if (data.bought && player.cid == data.rentor && !data.forSale) {
            $('#doorLockState').html(doorLock);
            $("#messages").append('<i class="fad fa-badge-dollar text-success fa-fw"></i> Property Currently Rented<br><i class="fad fa-dollar-sign fa-fw"></i> Rented For: $'+ data.rentPrice+'/week');
        } else if (data.bought && player.cid == data.rentor && data.forSale) {
            $('#doorLockState').html(doorLock);
            $("#messages").append('<i class="fad fa-money-bill-alt text-success fa-fw"></i> For Sale!<br><i class="fad fa-dollar-sign fa-fw"></i> Price: '+ data.price);
            $("#messages").append('<br><i class="fad fa-badge-dollar text-success fa-fw"></i> Property Currently Rented<br><i class="fad fa-dollar-sign fa-fw"></i> Rented For: $'+ data.rentPrice+'/week');
        } else if (data.bought && data.propertyRented && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
            $("#messages").append('<i class="fad fad fa-check-circle text-success fa-fw"></i> Owned by You.');
            $("#messages").append('<br><i class="fad fa-badge-dollar text-success fa-fw"></i> Property Currently Rented<br><i class="fad fa-dollar-sign fa-fw"></i> Rented For: $'+ data.rentPrice+'/week');
        } else if (data.bought && data.forSale && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
            $("#messages").append('<i class="fad fad fa-check-circle text-success fa-fw"></i> Owned by You.');
            $("#messages").append('<br><i class="fad fa-money-bill-alt text-success fa-fw"></i> For Sale!<br><i class="fad fa-dollar-sign fa-fw"></i> Price: '+ data.price);
        } else if (data.bought && data.forSale && player.cid !== data.ownerCid) {
            $("#messages").append('<i class="fad fa-money-bill-alt text-success fa-fw"></i> For Sale!<br><i class="fad fa-dollar-sign fa-fw"></i> Price: '+ data.price);
        } else if (data.bought && data.forRent && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
            $("#messages").append('<i class="fad fad fa-check-circle text-success fa-fw"></i> Owned by You.');
            $("#messages").append('<br><i class="fad fa-badge-dollar text-success fa-fw"></i> Avaliable for Rent<br><i class="fad fa-dollar-sign fa-fw"></i> Cost: $'+ data.rentPrice+'/week');
        } else if (data.bought && data.forRent && player.cid !== data.ownerCid) {
            $("#messages").append('<i class="fad fa-badge-dollar text-success fa-fw"></i> Avaliable for Rent<br><i class="fad fa-dollar-sign fa-fw"></i> Cost: $'+ data.rentPrice+'/week');
        } else if (data.bought && player.cid !== data.ownerCid) {
            $("#messages").append('<i class="fad fa-times-circle text-danger fa-fw"></i> Not For Sale');
        } else if (data.bought && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
            $("#messages").append('<i class="fad fad fa-check-circle text-success fa-fw"></i> Owned by You.');
        }
    }

    if(currentPosition == "exit") {
        $('#icon').html('<i class="fad fa-door-open fa-3x"></i>');
        if (data.bought && player.cid == data.rentor && !data.forSale) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && player.cid == data.rentor && data.forSale) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && data.propertyRented && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && data.forSale && player.cid == data.ownerCid) { 
            $('#doorLockState').html(doorLock);
        } else if (data.bought && data.forRent && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && player.cid == data.ownerCid) { 
            $('#doorLockState').html(doorLock);
        } else {
            $('#doorLockState').html('');
        }
        $("#messages").append('Press [ <span class="text-danger">E</span> ] Or type "<span class="text-danger">/exit</span>" to leave.');
    }

    if(currentPosition == "backdoor") {
        $('#icon').html('<i class="fad fa-door-open fa-3x"></i>');
        $("#messages").append('Type [ <span class="text-danger">/enter</span> ] To Enter Rear Entrance');
        if (data.bought && player.cid == data.rentor && !data.forSale) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && player.cid == data.rentor && data.forSale) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && data.propertyRented && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && data.forSale && player.cid == data.ownerCid) { 
            $('#doorLockState').html(doorLock);
        } else if (data.bought && data.forRent && player.cid == data.ownerCid) {
            $('#doorLockState').html(doorLock);
        } else if (data.bought && player.cid == data.ownerCid) { 
            $('#doorLockState').html(doorLock);
        } else {
            $('#doorLockState').html('');
        }
    }

    if(currentPosition == "menu1") {
        $("#messages").append('Press [ <span class="text-danger">E</span> ] Or type "<span class="text-danger">/housemenu</span>" to access the owner menu.');
    }

    if(currentPosition == "menu2") {
        $("#messages").append('Press [ <span class="text-danger">E</span> ] Or type "<span class="text-danger">/housemenu</span>" to access the tenancy menu.');
    }

    if(currentPosition == "inventory") {
        $('#icon').html('<i class="fad fa-box-open fa-3x"></i>');
        $("#messages").append('Press [ <span class="text-danger">F2</span> ] to access your inventory.');
    }

    if(currentPosition == "weapons") {
        $('#icon').html('<i class="fad fa-box-open fa-3x"></i>');
        $("#messages").append('Press [ <span class="text-danger">F2</span> ] to access your weapons stash.');
    }

    if(currentPosition == "money") {
        $('#icon').html('<i class="fad fa-money-bill-wave fa-3x"></i>');
        $("#messages").append('Press [ <span class="text-danger">E</span> ] to access your cash stash.');
    }

    if(currentPosition == "garage") {
        $('#icon').html('<i class="fad fa-warehouse fa-3x"></i>');
        $("#messages").append('Press [ <span class="text-danger">E</span> ] to access your garage.');
    }

    if(currentPosition == "clothing") {
        $('#icon').html('<i class="fad fa-tshirt fa-3x"></i>');
        $("#messages").append('Press [ <span class="text-danger">E</span> ] to access your wardrobe.');
    }

}