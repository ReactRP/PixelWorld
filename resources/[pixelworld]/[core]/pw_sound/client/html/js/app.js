var AudioPlayers = new Array();

// Listen for NUI Messages.
window.addEventListener('message', function(event) {
    switch (event.data.action) {
        case 'playSound':
            if (AudioPlayers[event.data.source] != null) {
                AudioPlayers[event.data.source].volume(event.data.volume);
                //AudioPlayers[event.data.source].stop();
                return;
            }


            AudioPlayers[event.data.source] = new Howl({
                src: ["./sounds/" + event.data.file + ".ogg"],
                onend: function() {
                    delete AudioPlayers[event.data.source];
                    $.post('http://mythic_sounds/SoundEnd', JSON.stringify({
                        source: event.data.source
                    }))
                }
            });

            AudioPlayers[event.data.source].volume(event.data.volume);
            AudioPlayers[event.data.source].play();
            break;
        case 'loopSound':
            if (AudioPlayers[event.data.source] != null) {
                AudioPlayers[event.data.source].volume(event.data.volume);
                //AudioPlayers[event.data.source].stop();
                return;
            }

            AudioPlayers[event.data.source] = new Howl({
                src: ["./sounds/" + event.data.file + ".ogg"],
                loop: true,
                onend: function() {
                    delete AudioPlayers[event.data.source];
                    $.post('http://mythic_sounds/SoundEnd', JSON.stringify({
                        source: event.data.source
                    }))
                }
            });

            AudioPlayers[event.data.source].volume(event.data.volume);
            AudioPlayers[event.data.source].play();
            break;
        case 'stopSound':
            if (AudioPlayers[event.data.source] != null) {
                AudioPlayers[event.data.source].stop();
                AudioPlayers[event.data.source] = null;
            }
            break;
        case 'updateVol':
            AudioPlayers[event.data.source].volume(event.data.volume);
            break;
    }
});