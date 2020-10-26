var soundList = [];
var playingRightNow = [];
var interval = null;

function load(stuff) {
	if(Object.keys(stuff).length > 0) {
		$.each(stuff, function (index, song) {
			var sd = new SoundPlayer();
			sd.setSoundUrl(song.url);
			sd.setVolume(song.volume);
			sd.setDynamic((song.dynamic || true));
			sd.setLocation(song.position.x, song.position.y, song.position.z);
			sd.setLoop(song.loop);
			if (song.playing) {
				sd.create((song.seconds || 0));
				sd.play((song.seconds || 0));
			}
			soundList[song.id] = sd;
		});
	}
	for (i = 0; i < musicList.length; i++) {
		var sound = new SoundPlayer();
		var name = musicList[i][1];
		var distance = musicList[i][2];

		sound.setSoundUrl(musicList[i][0]);
		//sound.setDynamic (musicList[i][1]);

		sound.setDistance(distance);

		soundList[name] = sound;
	}
	interval = setInterval(myMethod, 100);
}

function startPlaylist(list) {
	
}

var playerPos = [0, 0, 0];
$(function () {
	window.addEventListener('message', function (event) {
		var item = event.data;
		if (item.status === "position") {
			playerPos = [item.x, item.y, item.z];
		}

		if (item.status === "volume") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.setVolume(item.volume);
				sound.setMaxVolume(item.volume);
			}
		}

		if (item.status === "max_volume") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.setMaxVolume(item.volume);
			}
		}

		if (item.status === "url") {
			var sound = soundList[item.name];

			if (sound == null) {
				var sd = new SoundPlayer();
				sd.setSoundUrl(item.url);
				sd.setVolume(item.volume);
				sd.setDynamic(item.dynamic);
				sd.setLocation(item.x, item.y, item.z);
				sd.setLoop(item.loop);
				sd.setTitle(item.title);
				sd.create();
				sd.play();
				soundList[item.name] = sd;
			} else {
				sound.setLocation(item.x, item.y, item.z);
				sound.setSoundUrl(item.url);
				sound.setLoop(item.loop)
				sound.setTitle(item.title);
				sound.delete();
				sound.create();
				sound.play();
			}
		}

		if (item.status === "distance") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.setDistance(item.distance);
			}
		}

		if (item.status === "play") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.delete();
				sound.create();
				sound.setVolume(item.volume);
				sound.setDynamic(item.dynamic);
				sound.setLocation(item.x, item.y, item.z);
				sound.play();
			}
		}

		if (item.status === "soundPosition") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.setLocation(item.x, item.y, item.z);
			}
		}

		if (item.status === "resume") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.resume();
			}
		}

		if (item.status === "pause") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.pause();
			}
		}

		if (item.status === "delete") {
			var sound = soundList[item.name];
			if (sound != null) {
				sound.destroyYoutubeApi();
				sound.delete();
			}
		}

		if (item.status === "unload") {
			clearInterval(interval)
			for (var ss in soundList) {
				var sound = soundList[ss];
				if (sound != null) {
					sound.destroyYoutubeApi();
					sound.delete();
				}
			}
			soundList = []
		}

		if (item.status === "load") {
			load(item.sinfo);
		}

		if (item.status === "fetchTitle") {
			getVideoTitle(item.link, item.data)
		}

		if(item.status === "playList") {
			startPlaylist(list)
		}
	})
});

function Between(loc1, loc2) {
	var deltaX = loc1[0] - loc2[0];
	var deltaY = loc1[1] - loc2[1];
	var deltaZ = loc1[2] - loc2[2];

	var distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
	return distance;
}

function myMethod() {
	for (var ss in soundList) {
		var sound = soundList[ss];
		if (sound.isDynamic()) {
			var distance = Between(playerPos, sound.getLocation());
			var distance_max = sound.getDistance();
			if (distance < distance_max) {
				sound.updateVolume(distance, distance_max);
				continue;
			}
			if(!sound.isMuted()) sound.mute();
		}
	}
}
























