$(function() {
    window.addEventListener('message', function(event) {
        // Initialize menu
        if (event.data.type == 'init') {
            // Get number of wheels and create array to hold them
            numWheels = event.data.data.wheels.length;
            wheels = new Array(numWheels);

            // Get wheel style settings
            wheelStyle = event.data.data.style;

            // Set wheel size
            var wheelSize = wheelStyle.sizePx;
            document.getElementById("wheelDiv").style.width = wheelSize+"px";
            document.getElementById("wheelDiv").style.height = wheelSize+"px";

            // Set top margin to center wheel
            var marginTopSize = ($(window).height() - wheelSize) / 2;
            document.getElementById("container").style.marginTop = marginTopSize+"px";

            // Create and initialize all wheels
            for (var i = 0; i < numWheels; i++) {
                // Create new wheelnav and add to array of wheels
                if (i == 0) {
                    wheels[i] = new wheelnav('wheelDiv', null);
                }
                else {
                    wheels[i] = new wheelnav('wheelDiv', wheels[0].raphael);
                }

                // Get wheel data from JSON and customize wheel
                wheelData = event.data.data.wheels[i];
                wheels[i].navAngle = wheelData.navAngle;
                wheels[i].clickModeRotate = false;
                wheels[i].slicePathFunction = slicePath().DonutSlice;
                wheels[i].slicePathCustom = slicePath().DonutSliceCustomization();
                wheels[i].slicePathCustom.minRadiusPercent = wheelData.minRadiusPercent;
                wheels[i].slicePathCustom.maxRadiusPercent = wheelData.maxRadiusPercent;
                wheels[i].sliceInitPathCustom = wheels[i].slicePathCustom;
                wheels[i].sliceHoverPathCustom = wheels[i].slicePathCustom;
                wheels[i].sliceSelectedPathCustom = wheels[i].slicePathCustom;
                wheels[i].slicePathAttr = wheelStyle.slices.default;
                wheels[i].sliceHoverAttr = wheelStyle.slices.hover;
                wheels[i].sliceSelectedAttr = wheelStyle.slices.selected;
                wheels[i].titleWidth = wheelStyle.icons.width;
                wheels[i].titleHeight = wheelStyle.icons.height;
                wheels[i].titleAttr = wheelStyle.titles.default;
                wheels[i].titleHoverAttr = wheelStyle.titles.hover;
                wheels[i].titleSelectedAttr = wheelStyle.titles.selected;
                wheels[i].createWheel(wheelData.labels);
                
                // Clear selected items and add mouse functions
                for (var j = 0; j < wheels[i].navItems.length; j++) {
                    // Clear selected
                    wheels[i].navItems[j].selected = false;

                    // Add events for both navSlice and navTitle
                    const execTrigger = wheelData.eventTrigger[j]
                    wheels[i].navItems[j].navSlice.mousedown(function () {
                        $.post('http://pw_radialmenu/sliceclicked', JSON.stringify({trigger: execTrigger}));
                    });
                    wheels[i].navItems[j].navTitle.mousedown(function () {
                        $.post('http://pw_radialmenu/sliceclicked', JSON.stringify({trigger: execTrigger}));
                    });
                }

                // Refresh menu
                wheels[i].refreshWheel();
            }
        }
        // Destroy menu
        else if (event.data.type == 'destroy') {
            // Remove all wheels when they exist
            if ((typeof wheels !== 'undefined') && (typeof numWheels !== 'undefined')) {
                for (var i = 0; i < numWheels; i++) {
                    wheels[i].removeWheel();
                }
                delete wheels;
                delete numWheels;
            }
        }
    });
});

$(document).on("auxclick", '', function(e) {
    // Close menu when key is released
    if (e.which === 2) { // Middle Click
        $.post('http://pw_radialmenu/closemenu', JSON.stringify({}));
    }
});