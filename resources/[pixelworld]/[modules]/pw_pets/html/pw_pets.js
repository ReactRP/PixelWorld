window.addEventListener("message", function (event) {   
    if (event.data.action == "showPet") {
        $('#showPet').css({"display":"flex"});
        generateStats(event.data.info);
    }
    else if(event.data.action == "hidePet") {
        $('#showPet').css({"display":"none"});
    }
}); 

function generateStats(info) {
    if(info.health !== undefined) {
        $("#health").css({"width":"" + info.health + "%"}).attr("aria-valuenow", info.health);
        $("#health").html('<small>Health: '+Math.ceil(info.health)+'%</small>');
    }
    if(info.needs.thirst !== undefined) {
        $("#water").css({"width":"" + info.needs.thirst + "%"}).attr("aria-valuenow", info.needs.thirst);
        $("#water").html('<small>Water: '+Math.ceil(info.needs.thirst)+'%</small>');
    }
    if(info.needs.hunger !== undefined) {
        $("#food").css({"width":"" + info.needs.hunger + "%"}).attr("aria-valuenow", info.needs.hunger);
        $("#food").html('<small>Hunger: '+Math.ceil(info.needs.hunger)+'%</small>');
    }
    if(info.needs.excercise !== undefined) {
        $("#excercise").css({"width":"" + info.needs.excercise + "%"}).attr("aria-valuenow", info.needs.excercise);
        $("#excercise").html('<small>Excercise: '+Math.ceil(info.needs.excercise)+'%</small>');
    }
}