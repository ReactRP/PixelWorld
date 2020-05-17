window.addEventListener("message", function (event) {   
    if (event.data.action == "showPlant") {
        $('#showPlant').css({"display":"flex"});
        generateStatistics(event.data.info, event.data.canHarvest, event.data.messagePol);
    }
    else if(event.data.action == "hidePlant") {
        $('#showPlant').css({"display":"none"});
        $("#messageToUser").html('');
    }
}); 

function generateStatistics(info, canHarvest, policeMsg) {
    if(info.Growth !== undefined) {
        $("#growth").css({"width":"" + info.Growth + "%"}).attr("aria-valuenow", info.Growth);
        $("#growth").html('<small>Growth: '+Math.ceil(info.Growth)+'%</small>');
    }
    if(info.Water !== undefined) {
        $("#water").css({"width":"" + info.Water + "%"}).attr("aria-valuenow", info.Water);
        $("#water").html('<small>Water: '+Math.ceil(info.Water)+'%</small>');
    }
    if(info.Food !== undefined) {
        $("#feed").css({"width":"" + info.Food + "%"}).attr("aria-valuenow", info.Food);
        $("#feed").html('<small>Feed: '+Math.ceil(info.Food)+'%</small>');
    }
    if(info.Quality !== undefined) {
        $("#quality").css({"width":"" + info.Quality + "%"}).attr("aria-valuenow", info.Quality);
        $("#quality").html('<small>Quality: '+Math.ceil(info.Quality)+'%</small>');
    }
    if(info.Stage !== undefined) {
        $("#stage").html(info.Stage);
        
    }
    if(info.Gender !== undefined) {
        $("#sex").html(info.Gender);
        
    }
    
    var mathsSum = (info.Water + info.Food + info.Quality + info.Growth) / 4;

    if(mathsSum > 75) {
        $("#quality").addClass('bg-success').removeClass('bg-danger').removeClass('bg-info').removeClass('bg-warning');
        $("#looks").html('<i class="fad fa-shield-check"></i> Looks Good!').addClass('text-success').removeClass('text-warning').removeClass('text-info').removeClass('text-danger');
    } else if(mathsSum > 50) {
        $("#quality").removeClass('bg-success').removeClass('bg-danger').addClass('bg-info').removeClass('bg-warning');
        $("#looks").html('<i class="fad fa-shield-cross"></i> Seems Okay!').addClass('text-info').removeClass('text-success').removeClass('text-danger').removeClass('text-warning');
    } else if(mathsSum > 30) {
        $("#quality").removeClass('bg-success').removeClass('bg-danger').removeClass('bg-info').addClass('bg-warning');
        $("#looks").html('<i class="fad fa-shield-cross"></i> Needs Attention!').addClass('text-warning').removeClass('text-success').removeClass('text-info').removeClass('text-danger');
    } else {
        $("#quality").removeClass('bg-success').addClass('bg-danger').removeClass('bg-info').removeClass('bg-warning');
        $("#looks").html('<i class="fad fa-shield-cross"></i> Looks Bad!').addClass('text-danger').removeClass('text-success').removeClass('text-info').removeClass('text-warning');
    }

    if(!policeMsg) {
        if(canHarvest) {
            $("#messageToUser").html('Press [<span class="text-success"> E </span>] To Harvest');
            $("#looks").html('<i class="fad fa-shield-check"></i> Ready!').addClass('text-success');
        } else {
            $("#messageToUser").html('');
        }
    } else {
        $("#messageToUser").html('Press [<span class="text-success"> E </span>] To Destroy');
    }
}