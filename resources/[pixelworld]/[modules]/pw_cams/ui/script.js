const CameraFeed = new Vue({
    el: "#feed",

    data: {
        camerasOpen: false,
    },

    methods: {
        OpenCameras() {
            this.camerasOpen = true;
        },

        CloseCameras() {
            this.camerasOpen = false;
        },
    }
});

const CameraApp = new Vue({
    el: "#Camera_Container",

    data: {
        camerasOpen: false,
        cameraBoxLabel: "Testing",
        cameraLabel: "Front Left Store Camera",
        cameraQ: "360p"
    },

    methods: {
        OpenCameras(boxLabel, label, q) {
            this.camerasOpen = true;
            this.cameraLabel = label;
            this.cameraBoxLabel = boxLabel;
            this.cameraQ = q;
        },

        CloseCameras() {
            this.camerasOpen = false;
        },

        UpdateCameraLabel(label) {
            this.cameraLabel = label;
        }
    }
});

document.onreadystatechange = () => {
    if (document.readyState === "complete") {
        window.addEventListener('message', function(event) {

            if (event.data.type == "enablecam") {
                CameraFeed.OpenCameras();
                CameraApp.OpenCameras(event.data.box, event.data.label, event.data.q);

            } else if (event.data.type == "disablecam") {

                CameraFeed.CloseCameras();
                CameraApp.CloseCameras();

            } else if (event.data.type == "updatecam") {

                CameraApp.UpdateCameraLabel(event.data.label);

            }

        });
    };
};