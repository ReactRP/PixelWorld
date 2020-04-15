window.addEventListener("message", function (event) {
    if(event.data.action == "enableHud") {
        $('#buttonsHud').fadeIn(1000);
        $('#streetHud').fadeIn(1000);
        $('#serverLogo').fadeIn(1000);
        $('#detailsHud').css({"display":"block"});
        $('#healthHud').css({"display":"block"});
    }
    if(event.data.action == "enableVehicleHud") {
        $('#vehicleHud').fadeIn(1000);
    }
    if(event.data.action == "disableVehicleHud") {
        $('#engineRPM').css({"width":"0%"}).addClass('bg-info');
        $('#mphProgress').css({"width":"0%"});
        $('#mphSpeed').html('0');
        $('#vehicleHud').fadeOut(1000);
    }
    if(event.data.action == "updateCash") {
        $('#playerCash').html(event.data.playerCash);
    }
    if(event.data.action == "updateVehicleSpeed") {
        if(event.data.rpm < 25) {
            $('#engineRPM').addClass('bg-info').removeClass('bg-success').removeClass('bg-warning').removeClass('bg-danger');
        } else if(event.data.rpm >= 25 && event.data.rpm < 60) {
            $('#engineRPM').removeClass('bg-info').addClass('bg-success').removeClass('bg-warning').removeClass('bg-danger');
        } else if(event.data.rpm >= 60 && event.data.rpm < 85) {
            $('#engineRPM').removeClass('bg-info').removeClass('bg-success').addClass('bg-warning').removeClass('bg-danger');
        } else {
            $('#engineRPM').removeClass('bg-info').removeClass('bg-success').removeClass('bg-warning').addClass('bg-danger');
        }
        if(event.data.mph < 70) { 
            $('#mphProgress').addClass('bg-success').removeClass('bg-danger');
        } else {
            $('#mphProgress').removeClass('bg-success').addClass('bg-danger');
        }
        $('#engineRPM').css({"width":""+ event.data.rpm +"%"});
        $('#mphProgress').css({"width":""+ event.data.percent +"%"});
        $('#mphSpeed').html(event.data.mph);
    }
    if(event.data.action == "updateStreet") {
        $('#currentStreet').html(event.data.street);
        $('#currentHeading').html(event.data.heading);
    }
    if(event.data.action == "updateClock") {
        $('#currentTime').html(event.data.time);
    }
    if(event.data.action == "voiceLevel") {
        $('#talkLevel').css({"width":""+ event.data.level+"%"});
    }
    if(event.data.action == "updateRadioChannel") {
        if(event.data.radioTrue === true) {
            $('#radioChannel').html(event.data.channel);
        } else {
            $('#radioChannel').html('Radio Off');
        }
    }
    if(event.data.action == "toggleLogo") {
        if(event.data.toggle === true) {
            $('#serverLogo').fadeIn(100);
        } else {
            $('#serverLogo').fadeOut(100);
        }
    }
    if(event.data.action == "updateStats") {
        $('#healthBar').css({"width":""+ event.data.healthBar+ "%"});
        $('#foodBar').css({"width":""+ event.data.hunger+ "%"});
        $('#thirstBar').css({"width":""+ event.data.thirst+ "%"});
        
        if(event.data.armour == 0) {
            $('#currentArmour').css({"display":"none"});
        } else {
            $('#armourBar').css({"width":""+ event.data.armour+ "%"});
            $('#currentArmour').css({"display":"flex"})
        }

        if(event.data.drugs == 0) {
            $('#currentDrugs').css({"display":"none"});
        } else {
            $('#drugsBar').css({"width":""+ event.data.drugs+ "%"});
            $('#currentDrugs').css({"display":"flex"});
        }

        if(event.data.drunk == 0) {
            $('#currentDrunk').css({"display":"none"});
        } else {
            $('#drunkBar').css({"width":""+ event.data.drunk+ "%"});
            $('#currentDrunk').css({"display":"flex"});
        }

        if(event.data.stress == 0) {
            $('#currentStress').css({"display":"none"});
        } else {
            $('#stressBar').css({"width":""+ event.data.stress+ "%"});
            $('#currentStress').css({"display":"flex"});
        }
    }
    if(event.data.action == "updateCurrentlySpeaking") {
        $('#voiceCommunication').html('')
        $('#voiceCommunication').html(event.data.html)
    }
    if(event.data.action == "disableHud") {
        $('#buttonsHud').fadeOut(50);
        $('#streetHud').fadeOut(50);
        $('#serverLogo').fadeOut(50);
        $('#detailsHud').css({"display":"none"});
        $('#healthHud').css({"display":"none"});
    }
    if(event.data.action == "updateHudInformation") {
        $('#playerName').html(event.data.playerName);
        $('#playerCash').html(event.data.playerCash);
        $('#playerId').html(event.data.playerId);
    } 
    if (event.data.action == "showCharacterSheet") {
        $("#detailsHud").animate({"right":"8px"}, "slow")
        $("#healthHud").animate({"right":"8px"}, "slow")
        setTimeout(function() {
            $("#detailsHud").animate({"right":"-250px"}, "slow")
            $("#healthHud").animate({"right":"-250px"}, "slow")
            setTimeout(function() {
            $.post("http://pw_hud/showCharacterSheetCooldownReset", JSON.stringify({}));
            }, 1000);
        }, 5000);
    } 
});