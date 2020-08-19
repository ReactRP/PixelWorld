var Config = new Object();
Config.closeKeys = [113, 27];

window.addEventListener("message", function (event) {   
    if(event.data.action == "showShop") {
        $('#vehicleShop-Container').css({'display':'block'});
    } else if(event.data.action == "hide") {
        $('#vehicleShop-Container').css({'display':'none'});
    } else if(event.data.action == "loadVehicles") {
        populateVehicles(event.data.vehicles, event.data.playerData);
    }
}); 

function populateVehicles(data, pdata) {
    $('#modelBoxes').html('');
    $('#v-pills-tab').html('');
    $('#v-pills-tabContent').html('')
    $('#v-pills-tab').append('<a class="nav-link active m-1 w-100" id="v-pills-welcome-tab" data-toggle="pill" href="#v-pills-welcome" role="tab" aria-controls="v-pills-welcome" aria-selected="true">Select Category</a>');
    $('#v-pills-tabContent').append('<div class="tab-pane fade show active" id="v-pills-welcome" role="tabpanel" aria-labelledby="v-pills-welcome-tab">WELCOME</div>')
    $.each(data, function (index, category) {
        $('#v-pills-tab').append('<a class="nav-link m-1 w-100" id="v-pills-' + category.name + '-tab" data-toggle="pill" href="#v-pills-' + category.name + '" role="tab" aria-controls="v-pills-' + category.name + '" aria-selected="false">' + category.label + '</a>');
        $('#v-pills-tabContent').append('<div class="tab-pane fade" id="v-pills-' + category.name + '" role="tabpanel" aria-labelledby="v-pills-' + category.name + '-tab"><div class="container-fluid" id="container-' + category.name + '-vehicles">TEST</div></div>');
        $('#container-' + category.name + '-vehicles').html('');
        $.each(category.vehicles, function (index, vehicle) {
            if (vehicle.description !== undefined && vehicle.description !== null ) {
                var desc = '<p>'+ vehicle.description +'</p>';
            } else {
                var desc = '';
            }
            $('#container-' + category.name + '-vehicles').append('<div class="row m-1"><div class="col-3" id="' + vehicle.model + '-image"></div><div class="col-9" id="' + vehicle.model + '-info"></div></div>');
            $('#modelBoxes').append('<div class="modal fade mt-5" id="model-' + vehicle.model + '" tabindex="-1" role="dialog" aria-labelledby="exampleModalScrollableTitle" aria-hidden="true"><div class="modal-dialog modal-dialog-scrollable modal-lg" role="document"><div class="modal-content"><div class="modal-header"><h5 class="modal-title" id="exampleModalScrollableTitle">' + vehicle.name + '</h5><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div><div class="modal-body"> <div class="container-fluid"><div class="row"><div class="col-12 text-center" id="modelImage-' + vehicle.model + '"> </div></div><div class="row"><div class="col-12" id="vehicleDescription-' + vehicle.model + '"></div></div><div class="row"><div class="col-12"><p id="vehicleSpecs-' + vehicle.model + '"></p></div></div></div></div><div class="modal-footer"><button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button></div></div></div></div>');         
            
            $('#vehicleDescription-' + vehicle.model).html('<br>' + desc);

            if(vehicle.specifications !== undefined && vehicle.specifications !== null) {
                var spec = jQuery.parseJSON(vehicle.specifications);
                $.each(spec, function (indexspe, spe) {
                    $('#vehicleDescription-' + vehicle.model).append('<strong>' + indexspe + ':</strong> ' + spe + '<br>');
                });
            }
            var img = new Image();
            var url = 'https://donotdelete.chrisrogersuk.co.uk/images/vehicles/'+vehicle.model+'.png';
            img.onload = function(){
                $('#' + vehicle.model + '-image').append('<img src="https://donotdelete.chrisrogersuk.co.uk/images/vehicles/'+vehicle.model+'.png" class="img-fluid img-thumbnail">');
                $('#modelImage-' + vehicle.model).append('<img src="https://donotdelete.chrisrogersuk.co.uk/images/vehicles/'+vehicle.model+'.png" class="img-fluid img-thumbnail">');
            };
            img.onerror = function() {
                $('#' + vehicle.model + '-image').append('<img src="images/noimage.jpg" class="img-fluid img-thumbnail">');
                $('#modelImage-' + vehicle.model).append('<img src="images/noimage.jpg" class="img-fluid img-thumbnail">');
            }
            img.src = url
            $('#' + vehicle.model + '-info').append('<h5>' + vehicle.name + '</h5>'+desc)
            $('#container-' + category.name + '-vehicles').append('<div class="row m-1"><div class="col-3"></div><div class="col-4 text-success"><span id="vehiclePrice-' + vehicle.model + '"><h5>$' + vehicle.price + '</h5></span></div><div class="col-5 text-right"><button class="btn btn-info" data-action="testDrive" id="'+vehicle.model+'-testDrive">Test Drive</button> <button class="btn btn-warning" data-action="finance" id="'+vehicle.model+'-finance">Finance</button> <button class="btn btn-success" data-action="buyNow" id="'+vehicle.model+'-buynow">Buy Now</button> <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#model-' + vehicle.model + '">More Info</button></div></div>');
            if(vehicle.price <= pdata.cash) {
                $('#vehiclePrice-'+vehicle.model).addClass('text-success').removeClass('text-danger');
            } else {
                $('#vehiclePrice-'+vehicle.model).addClass('text-danger').removeClass('text-success');
            }
            
            $('#'+vehicle.model+'-testDrive').data('vehicleData', vehicle);
            $('#'+vehicle.model+'-finance').data('vehicleData', vehicle);
            $('#'+vehicle.model+'-buyNow').data('vehicleData', vehicle);
        });
    });    
}

function closeShop() {
    $.post("http://pw_vehicleshop/NUIFocusOff", JSON.stringify({}));
}

$( function() {
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeShop();
        }
    });

    $(document).on('click','[data-action=testDrive]',function(){
        var vehicleData = $(this).data('vehicleData');     
        $.post("http://pw_vehicleshop/testDriveVehicle", JSON.stringify({
            vehicle: vehicleData
        }));
        closeShop();
    });

    $(document).on('click','[data-action=buyNow]',function(){
        var vehicleData = $(this).data('vehicleData');
        $.post("http://pw_vehicleshop/purchaseVehicle", JSON.stringify({
            vehicle: vehicleData
        }));
        closeShop();
    });

    $(document).on('click','[data-action=finance]',function(){
        var vehicleData = $(this).data('vehicleData');
        $.post("http://pw_vehicleshop/financeVehicle", JSON.stringify({
            vehicle: vehicleData
        }));
        closeShop();
    });

});