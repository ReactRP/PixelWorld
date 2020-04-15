var Config = new Object();
Config.closeKeys = [112];
var to = null;
var from = null;
var ringer = true;
var number = null;
var simcardActive = false;
var blockNormalOpen = false
var phoneOpen = false;
var radioOpen = false;
var callWith = null;
var currentRadioChannel = null;
var currentlyInRadio = false;
var radioClicks = false;
var playerJob = null;
var jobDuty = false;
var currentCoords = null
var preventPhoneOpen = false
var onFoodDelivery = false

window.addEventListener("message", function (event) {
    if(event.data.status == "playerCoords") {
        currentCoords = event.data.coords;
    }
    if(event.data.status == "setJob") {
        playerJob = event.data.job;
        jobDuty = event.data.duty;
        toggleJobIcons();
    }
    if(event.data.status == "raceActive") {
        toggleActiveRaceBtn(event.data.raceState)
    }
    if(event.data.status == "toggleContestants") {
        toggleContestants(event.data.state)
    }
    if(event.data.sub == "manageTracks") {
        manageRaces(event.data.data)
    }
    if(event.data.status == "openPhone") {
        if(preventPhoneOpen == false) {
            if(blockNormalOpen === false) {
                phoneOpen = true;
                if (callWith === null) {
                    if(event.data.simcard === false) {    
                        simcardActive = false
                        $('#mainMenu').fadeOut(1);
                        $('#noSimcard').fadeIn(1);
                    }
                    else {
                        simcardActive = true
                        number = event.data.activenumber;
                        $('#noSimcard').fadeOut(1);
                        $('#mainMenu').fadeIn(1);
                    }
                }
                $("#phoneDiv").animate({"bottom":"10px"}, "slow");
            }
        }
    }
    if(event.data.status == "closePhone") {
        if(preventPhoneOpen == false) {
            if(phoneOpen === true) {
                closePhone("fast");
            }
        }
    }
    if(event.data.status == "closeRadio") {
        if(radioOpen === true) {
            //closeRadio("fast");
        }
    }
    if(event.data.status == "updateClock") {
        $('#currentTime').html(event.data.time);
    }
    if(event.data.status == "updateVoice") {
        $('#voiceInfo').css({"display":"inline-block"});
        $('#voiceInfo').html(event.data.mes)
    }
    if(event.data.status == "updateLevel") {
        $('#voiceLevel').css({"width":"" + event.data.level + "%"});
    }
    if(event.data.status == "updateVoice2") {
        if(event.data.show == true) {
            $('#voiceInfo2').css({"display":"inline-block"});
            $('#voiceInfo2').html('<p class="mb-1">' + event.data.mes + '</p>');
        }
        else {
            $('#voiceInfo2').css({"display":"none"});
        }
    }
    if(event.data.status == "hideHud") {
        $('#mainContainer').css({"display":"none"});
    }
    if(event.data.status == "showHud") {
        $('#mainContainer').css({"display":"block"});
    }

    if(event.data.status == "receiving") {
        if(event.data.terminate === false) {
            number = parseInt(event.data.mynumber);
            phoneOpen = true;
            receivingCall(event.data.incomming, event.data.name, event.data.failed, event.data.reason)
        } else {
            closePhone();
        }
    }

    if(event.data.status == "phoneGame") {
        if(event.data.action == "start") {
            preventPhoneOpen = true;
            $('#mainMenu').fadeOut(1);
            $('#noSimcard').fadeOut(1);
            $("#phoneDiv").animate({"bottom":"10px"}, "slow");
            $('#gameDiv').fadeIn(300);
            setTimeout(function() {
                playGame(event.data.tries, event.data.failures, event.data.duration, event.data.letters);
                polyfillKey();
            }, 2000);
        } else if(event.data.action == "end") {
            closeGame();
        }
    }

    if(event.data.status == "callEnded") {
        callEnded();
    }

    if(event.data.status == "makingCall") {
        if(event.data.terminate === false) {
            connectingCall(event.data.incomming, event.data.name, event.data.failed, event.data.reason)
        } else {
            $('#dialingCall').fadeOut(500);
            setTimeout(function() {
                connectingCall(event.data.incomming, event.data.name, event.data.failed, event.data.reason)
            }, 501)

        }
    }

    if(event.data.status == "callConnected") {
        callWith = parseInt(event.data.with);
        callConnectedWith(event.data.name)
    }

    if(event.data.status == "phonePopulation") {
        if(event.data.sub == "updatePole") {
            loadContestants(event.data.data)
        }
        if(event.data.sub == "activeRace") {
            loadActiveRaceDiv(event.data.data.active, event.data.data.contestants, event.data.data.org);
        }
        if(event.data.sub == "createRace") {
            loadRaces(event.data.data)
        }
        if(event.data.sub == "startNewFoodJob") {
            loadFoodDelivery(event.data.data)
        }
        if(event.data.sub == "contacts") {
            loadContacts(event.data.data)
        }
        if(event.data.sub == "conversations") {
            loadConversations(event.data.data);
        }
        if(event.data.sub == "loadConvo") {
            loadConversation(event.data.data);
        }
        if(event.data.sub == "simcards") {
            loadSimCards(event.data.data);
        }
        if(event.data.sub == "advertisements") {
            loadAdvertisements(event.data.data);
        }
        if(event.data.sub == "emailInbox") {
            loadEmailInbox(event.data.data)
        }
        if(event.data.sub == "emailSent") {
            loadEmailSent(event.data.data)
        }
        if(event.data.sub == "viewEmail") {
            loadViewEmail(event.data.data);
        }
        if(event.data.sub == "twitterHome") {
            loadTwitterApplication(event.data);
        }
        if(event.data.sub == "refreshTweets") {
            refreshTweets(event.data)
        }
        if(event.data.sub == "requestTweet") {
            loadSpecificTweet(event.data);
        }
        if(event.data.sub == "refreshTweet") {
            loadSpecificTweet(event.data);
        }
        if(event.data.sub == "myProperties") {
            populateProperties(event.data.data)
        }
        if(event.data.sub == "forSale") {
            populatePropertysRetail(event.data.data)
        }
        if(event.data.sub == "forRent") {
            populatePropertysRetail(event.data.data)
        }
        if(event.data.sub == "getNearbyPlayers") {
            populatePropertyNearbyPlayers(event.data.data)
        }
    }
    if(event.data.status == "notifications") {
        if(event.data.sub == "textMessages") {
            if(event.data.show === true) { 
                $('#newMessageIcon').css({"display":"inline-block"});
            }
            if(event.data.show === false) { 
                $('#newMessageIcon').css({"display":"none"});
            }
        }
        if(event.data.sub == "emailMessage") {
            if(event.data.show === true) { 
                $('#newEmailIcon').css({"display":"inline-block"});
            }
            if(event.data.show === false) { 
                $('#newEmailIcon').css({"display":"none"});
            }
        }
    }
    if(event.data.status == "newTweet") {
        $('#twtNotificationAuthor').html('');
        $('#twtNotificationAction').html('');
        $('#twtNotificationTweet').html('');
        $('#twtNotificationAuthor').html(event.data.by);
        $('#twtNotificationAction').html(event.data.stat);
        $('#twtNotificationTweet').html(event.data.tweet);
        $('#twitterNotification').fadeIn(1500);
        setTimeout(function() {
            $('#twitterNotification').fadeOut(1500);
        }, 5000);
    }
    if(event.data.status == "openRadio") {
        if(currentRadioChannel !== null && parseInt(currentRadioChannel) > 0 && parseInt(currentRadioChannel) < 1000) {
            $('#radioChannel').val(currentRadioChannel);
        }
        $("#radioDiv").animate({"bottom":"0px"}, "slow");
    }
});

function toggleAlertRetail(show, k, message) {
    if(show == true) {
        $('#retHouseInformationAlert-' + k).html(message);
        $('#retHouseInformationAlert-' + k).css({"display":"block"});
    } else {
        $('#retHouseInformationAlert-' + k).css({"display":"none"});
        $('#retHouseInformationAlert-' + k).html('');
    }
}

function closeGame() {
    preventPhoneOpen = false;
    $('#gameDiv').fadeOut(300);
    $("#phoneDiv").animate({"bottom":"-600px"}, "slow");
    $.post('http://pw_phone/loseFocus', JSON.stringify({ }));
}

function polyfillKey() {
    if (!('KeyboardEvent' in window) ||
          'key' in KeyboardEvent.prototype) {
      return false;
    }
    
    var keys = {};
    var letter = '';
    for (var i = 65; i < 91; ++i) {
      letter = String.fromCharCode(i);
      keys[i] = letter.toUpperCase();
    }
    for (var i = 97; i < 123; ++i) {
      letter = String.fromCharCode(i);
      keys[i] = letter.toLowerCase();
    }
    var proto = {
      get: function (x) {
        var key = keys[this.which || this.keyCode];
        return key;
      }
    };
    Object.defineProperty(KeyboardEvent.prototype, 'key', proto);
  }


  function playGame(tries, failures, duration, letters) {
    var LETTERS = ['w','a','s','d','i','j','k','l'];
    var animations = {'w':[],'a':[],'s':[],'d':[],'i':[],'j':[],'k':[],'l':[]};
    var gameOn = true;
    if(letters !== undefined && letters !== null) {
        var timeOffset = letters
    } else {
        var timeOffset = 2000; //interval between letters starting, will be faster over time
    }
    if(duration !== undefined && duration !== null) {
        var DURATION = duration
    } else {
        var DURATION = 5000; //interval between letters starting, will be faster over time
    }
    if(failures !== undefined && failures !== null) {
        var maxFailures = failures
    } else {
        var maxFailures = 10; //interval between letters starting, will be faster over time
    }
    if(tries !== undefined && tries !== null) {
        var maxTries = tries
    } else {
        var maxTries = 50; //interval between letters starting, will be faster over time
    }

    var main1 = document.getElementById('letterRow1');
    var main2 = document.getElementById('letterRow2');
    var main3 = document.getElementById('letterRow3');
    var score = 0
    var rate = 1.2;
    var RATE_INTERVAL = .07; //playbackRate will increase by .05 for each letter... so after 20 letters, the rate of falling will be 2x what it was at the start
    var misses = 0;
    var counter = 0;
  
    //Create a letter element and setup its falling animation, add the animation to the active animation array, and setup an onfinish handler that will represent a miss. 
    function create1() {
      var idx = Math.floor(Math.random() * LETTERS.length);
      var x = (Math.random() * 85) + 'vw';
      var container = document.createElement('div');
      var letter = document.createElement('span');
      var letterText = document.createElement('b');
      letterText.textContent = LETTERS[idx];
      letter.appendChild(letterText);
      container.appendChild(letter);
      main1.appendChild(container);
      var randomer = Math.floor(Math.random() * Math.floor(100));
      container.setAttribute("id", "letterText-" + LETTERS[idx] + '-' + randomer);
      var animation = container.animate([
        {transform: 'translate3d(0px,-20px,0)'},
        {transform: 'translate3d(0px,449px,0)'}
      ], {
        duration: DURATION,
        easing: 'linear',
        fill: 'both'
      });
      
      animations[LETTERS[idx]].splice(0, 0, {animation: animation, element: container, letterdiv: "letterText-" + LETTERS[idx] + '-' + randomer});
      rate = rate + RATE_INTERVAL;
      animation.playbackRate = rate;
      
      //If an animation finishes, we will consider that as a miss, so we will remove it from the active animations array and increment our miss count
      animation.onfinish = function(e) {
        var target = container;
        var char = target.textContent;
                                        
        animations[char].pop();
        target.classList.add('missed');
        handleMisses();
      }
    }

    function create2() {
        var idx = Math.floor(Math.random() * LETTERS.length);
        var x = (Math.random() * 85) + 'vw';
        var container = document.createElement('div');
        var letter = document.createElement('span');
        var letterText = document.createElement('b');
        letterText.textContent = LETTERS[idx];
        letter.appendChild(letterText);
        container.appendChild(letter);
        main2.appendChild(container);
        var randomer = Math.floor(Math.random() * Math.floor(100));
        container.setAttribute("id", "letterText-" + LETTERS[idx] + '-' + randomer);
        var animation = container.animate([
          {transform: 'translate3d(0px,-20px,0)'},
          {transform: 'translate3d(0px,449px,0)'}
        ], {
          duration: DURATION,
          easing: 'linear',
          fill: 'both'
        });
        
        animations[LETTERS[idx]].splice(0, 0, {animation: animation, element: container, letterdiv: "letterText-" + LETTERS[idx] + '-' + randomer});
        rate = rate + RATE_INTERVAL;
        animation.playbackRate = rate;
        
        //If an animation finishes, we will consider that as a miss, so we will remove it from the active animations array and increment our miss count
        animation.onfinish = function(e) {
          var target = container;
          var char = target.textContent;
                                          
          animations[char].pop();
          target.classList.add('missed');
          handleMisses();
        }
      }
      function create3() {
        var idx = Math.floor(Math.random() * LETTERS.length);
        var x = (Math.random() * 85) + 'vw';
        var container = document.createElement('div');
        var letter = document.createElement('span');
        var letterText = document.createElement('b');
        letterText.textContent = LETTERS[idx];
        letter.appendChild(letterText);
        container.appendChild(letter);
        main3.appendChild(container);
        var randomer = Math.floor(Math.random() * Math.floor(100));
        container.setAttribute("id", "letterText-" + LETTERS[idx] + '-' + randomer);
        var animation = container.animate([
          {transform: 'translate3d(0px,-20px,0)'},
          {transform: 'translate3d(0px,449px,0)'}
        ], {
          duration: DURATION,
          easing: 'linear',
          fill: 'both'
        });
        
        animations[LETTERS[idx]].splice(0, 0, {animation: animation, element: container, letterdiv: "letterText-" + LETTERS[idx] + '-' + randomer});
        rate = rate + RATE_INTERVAL;
        animation.playbackRate = rate;
        
        //If an animation finishes, we will consider that as a miss, so we will remove it from the active animations array and increment our miss count
        animation.onfinish = function(e) {
          var target = container;
          var char = target.textContent;
                                          
          animations[char].pop();
          target.classList.add('missed');
          handleMisses();
        }
      }
    
    //When a miss is registered, check if we have reached the max number of misses
    function handleMisses() {
      misses++;
        if(misses > 10) {
            gameOver();
        }
    }
    
    //End game and show screen
    function gameOver() {
      clearInterval(cleanupInterval);
      if(misses < maxFailures) {
        if(gameOn === true) {  
            $('#gameDiv').fadeOut(500)
            setTimeout(function() {
                $('#successMessageYes').html('Success!');
                $('#successMessage').fadeIn(500);
                setTimeout(function() {
                    $('#successMessage').fadeOut(500);
                    setTimeout(function() {
                        $('#successMessageYes').html('');
                        $.post('http://pw_phone/gameResult', JSON.stringify({ result: true }));
                    }, 501)
                }, 1000)
            }, 501)
        }
      } else {
        if(gameOn === true) {
            $('#gameDiv').fadeOut(500)
            setTimeout(function() {
                $('#failedMessageYes').html('You failed.');
                $('#failedMessage').fadeIn(500);
                setTimeout(function() {
                    $('#failedMessage').fadeOut(500);
                    setTimeout(function() {
                        $('#failedMessageYes').html('');
                        $.post('http://pw_phone/gameResult', JSON.stringify({ result: false }));
                    }, 501)
                }, 1000)
            }, 501)
        }
      }
      gameOn = false;
    }
  
    //Periodically remove missed elements, and lower the interval between falling elements
    var cleanupInterval = setInterval(function() {
      timeOffset = timeOffset * 4 / 5;
      cleanup();
    }, 20000);
    function cleanup() {
      [].slice.call(main1.querySelectorAll('.missed')).forEach(function(missed) {
        main1.removeChild(missed);
      });
      [].slice.call(main2.querySelectorAll('.missed')).forEach(function(missed) {
        main2.removeChild(missed);
      });
      [].slice.call(main3.querySelectorAll('.missed')).forEach(function(missed) {
        main3.removeChild(missed);
      });
    }
    
    //Firefox 48 supports document.getAnimations as per latest spec, Chrome 52 and polyfill use older spec
    function getAllAnimations() {
      if (document.getAnimations) {
        return document.getAnimations();
      } else if (document.timeline && document.timeline.getAnimations) {
        return document.timeline.getAnimations();
      }
      return [];
    }
    
    //On key press, see if it matches an active animating (falling) letter. If so, pop it from active array, pause it (to keep it from triggering "finish" logic), and add an animation on inner element with random 3d rotations that look like the letter is being kicked away to the distance. Also update score.
    function onPress(e) {
      var char = e.key;
      if (char.length === 1) {
        char = char.toLowerCase();
        if (animations[char] && animations[char].length) {
          counter++;
          var popped = animations[char].pop();
          popped.animation.pause();
          var target = popped.element.querySelector('b');
          var pos =  $('#'+popped.letterdiv).position();
          var degs = [(Math.random() * 1000)-500,(Math.random() * 1000)-500,(Math.random() * 2000)-1000];
          target.animate([
            {transform: 'scale(1) rotateX(0deg) rotateY(0deg) rotateZ(0deg)',opacity:1},
            {transform: 'scale(0) rotateX('+degs[0]+'deg) rotateY('+degs[1]+'deg) rotateZ('+degs[2]+'deg)', opacity: 0}
          ], {
            duration: Math.random() * 500 + 850,
            easing: 'ease-out',
            fill: 'both'
          });
            if(counter >= maxTries) {
                gameOver();
            } else {
                var audioPlayer = null;
                if (audioPlayer != null) {
                    audioPlayer.pause();
                }
                if((Math.floor(pos.top)) > 360 && (Math.floor(pos.top)) < 415) {
                    audioPlayer = new Howl({src: ["./sound/success.ogg"]});
                    audioPlayer.volume(1.0);
                    audioPlayer.play();
                    $('#'+popped.letterdiv).addClass('text-success'); 
                    score++;
                } else {
                    audioPlayer = new Howl({src: ["./sound/error.ogg"]});
                    audioPlayer.volume(1.0);
                    audioPlayer.play();
                    $('#'+popped.letterdiv).addClass('text-danger');
                    handleMisses();
                }
            }
        }
      }
    }
    
    document.body.addEventListener('keypress', onPress);
  
    //start the letters falling... create the element+animation, and setup timeout for next letter to start
    function setupNextLetter1() {
      if (gameOn) {
        create1();
        setTimeout(function() {
          setupNextLetter2();
        }, timeOffset);
      }
    }
    function setupNextLetter2() {
        if (gameOn) {
          create2();
          setTimeout(function() {
            setupNextLetter3();
          }, timeOffset);
        }
      }
      function setupNextLetter3() {
        if (gameOn) {
          create3();
          setTimeout(function() {
            setupNextLetter1();
          }, timeOffset);
        }
      }
    setupNextLetter1();
  }

function populatePropertyNearbyPlayers(data) {
    $('#retailPropertysDiv').fadeOut(500);
    setTimeout(function() {
        $('#retMyPropertiesContent').html('');
        if(data.action == "forSale") {
            $('#retailPropeName').html('Properties for Sale<br>Player to Sell To')
        } else {
            $('#retailPropeName').html('Properties for Rent<br>Player to Lease To')
        }
        var players = data.players;
        if(players.length > 0) {
            $('#retMyPropertiesContent').append('<div class="alert alert-primary p-1 mb-1 text-center"><small><strong>' + players.length + '</strong> players located nearby.</small></div>');
            $.each(players, function (index, player) {
                if(data.action == "forSale") {
                    $('#retMyPropertiesContent').append('<div class="alert alert-info p-1 mb-1"><div class="container-fluid mt-1"><div class="row"><div class="col-2 my-auto mt-1"><i class="fad fa-user fa-2x"></i></div><div class="col-10 text-center my-auto" data-house="' + data.house + '" data-cid="' + player.cid + '" data-source="' + player.id + '" data-uid="' + player.uid + '" data-method="sell" data-act="processPropertySale"><small><strong>' + player.name + '</strong></small></div></div></div></div></div>');
                } else {
                    $('#retMyPropertiesContent').append('<div class="alert alert-info p-1 mb-1"><div class="container-fluid mt-1"><div class="row"><div class="col-2 my-auto mt-1"><i class="fad fa-user fa-2x"></i></div><div class="col-10 text-center my-auto" data-house="' + data.house + '" data-cid="' + player.cid + '" data-source="' + player.id + '" data-uid="' + player.uid + '" data-method="rent" data-act="processPropertySale"><small><strong>' + player.name + '</strong></small></div></div></div></div></div>');
                }
            });
            $('#retMyPropertiesContent').append('<div class="alert alert-primary p-1 mb-1 text-center"><small><strong>' + players.length + '</strong> players located nearby.</small></div>');
        } else {
            $('#retMyPropertiesContent').append('<div class="alert alert-info text-center"><small>No Players Nearby</small></div>');
        }
        $('[data-toggle="tooltip"]').tooltip()
        setTimeout(function() {
            from = "retailPropertysDiv";
            to = "mainMenu";
            $('#retailPropertysDiv').fadeIn(500);
        }, 501)
    }, 501);
}

function populatePropertysRetail(data) {
    $('#mainMenu').fadeOut(500);
    $('#retMyPropertiesContent').html('');
    var properties = data.result;
    if(data.action == "forSale") { 
        $('#retailPropeName').html('Properties for Sale')
    } else {
        $('#retailPropeName').html('Properties for Rent')
    }

    if(properties.length > 0) {
        $('#retMyPropertiesContent').append('<div class="alert alert-primary p-1 mb-1 text-center"><small><strong>' + properties.length + '</strong> properties located nearby.</small></div>');
        $.each(properties, function (index, property) {
            var meta = jQuery.parseJSON(property.metainformation)
            var coords = jQuery.parseJSON(property.location)
            if(meta.lockStatus == true) {
                lock = '<span id="lockStatus-'+ property.property_id + '"><i  data-toggle="tooltip" data-placement="top" title="Unlock Property" class="fad fa-key fa-2x text-danger" data-act="retailUnlock" data-house="' + property.property_id + '"></i></span>';
            } else {
                lock = '<span id="lockStatus-'+ property.property_id + '"><i  data-toggle="tooltip" data-placement="top" title="Lock Property" class="fad fa-key fa-2x text-success" data-act="retailLock" data-house="' + property.property_id + '"></i></span>';
            }

            $('#retMyPropertiesContent').append('<div class="alert alert-info p-1 mb-1"><div class="container-fluid mt-1"><div class="row" data-toggle="collapse" data-target="#retProperty-' + property.property_id + '"><div class="col-2 my-auto mt-1"><i class="fad fa-home-alt fa-2x"></i></div><div class="col-10 text-center my-auto"><small><strong>' + property.name + '</strong></small></div></div><div class="row collapse" id="retProperty-' + property.property_id + '"><div class="col-12 p-2"><div class="container-fluid" id="retHouseInformation-' + property.property_id + '"></div></div></div></div></div>');
            if(data.action == "forSale") { 
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Sale Price:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.costs.purchase + '</small></small></div></div>')
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Garage Space:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + property.garageLimit + ' Vehicles</small></small></div></div>')
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Storage Limit:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + property.storageLimit.slots + ' Item Slots</small></small></div></div>')
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-3 text-center p-2" data-toggle="tooltip" data-placement="top" title="Set Waypoint Marker"><i class="fad fa-map-marker-alt fa-2x" data-x="' + coords.x + '" data-y="' + coords.y + '" data-z="' + coords.z + '" data-act="propertyGPS"></i></div><div class="col-3 text-center p-2">' + lock + '</div><div class="col-3 text-center p-2" data-toggle="tooltip" data-placement="top" title="Sell Property"><i class="fad fa-usd-circle fa-2x text-success" data-act="sellProperty" data-house="' + property.property_id + '"></i></div><div class="col-3 text-center p-2"><i class="fad fa-cog fa-2x text-info" data-act="propertySettings" data-house="' + property.property_id + '" data-toggle="tooltip" data-placement="top" title="Manage Property"></i></div></div>');
            } else {
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Rental Price:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.costs.rental + ' per week</small></small></div></div>')
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Security Deposit:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + Math.floor(meta.costs.rental * 2) + '</small></small></div></div>')
                if(meta.luxuryAvailable.money == true) {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Money Stash:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$5000 Limit</small></small></div></div>')    
                } else {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-12 p-0"><small><small><strong>No Money Stash Avaliable</strong></small></small></div></div>')    
                }
                if(meta.luxuryAvailable.weapon == true) {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Weapon Stash:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>20 Slots</small></small></div></div>')    
                } else {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-12 p-0"><small><small><strong>No Weapon Stash Avaliable</strong></small></small></div></div>')    
                }
                if(meta.luxuryAvailable.inventory == true) {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Inventory Storage:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + property.storageLimit.slots + ' Item Slots</small></small></div></div>')    
                } else {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-12 p-0"><small><small><strong>No Inventory Storage Avaliable</strong></small></small></div></div>')    
                }
                if(meta.luxuryEnabled.garage == true) {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Garage Space:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + property.garageLimit + ' Vehicles</small></small></div></div>')
                } else {
                    $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-12 p-0"><small><small><strong>No Garage Avaliable</strong></small></small></div></div>')    
                }
                $('#retHouseInformation-' + property.property_id).append('<div class="row"><div class="col-4 text-center p-2" data-toggle="tooltip" data-placement="top" title="Set Waypoint Marker"><i class="fad fa-map-marker-alt fa-2x" data-x="' + coords.x + '" data-y="' + coords.y + '" data-z="' + coords.z + '" data-act="propertyGPS"></i></div><div class="col-4 text-center p-2">' + lock + '</div><div class="col-4 text-center p-2" data-toggle="tooltip" data-placement="top" title="Rent Property"><i class="fad fa-usd-circle fa-2x text-success" data-act="rentProperty" data-house="' + property.property_id + '"></i></div></div>');
            }
        })
        $('#retMyPropertiesContent').append('<div class="alert alert-primary p-1 mb-1 text-center"><small><strong>' + properties.length + '</strong> properties located nearby.</small></div>');
    } else {
        $('#retMyPropertiesContent').append('<div class="alert alert-info text-center"><small>No Nearby Propertys found on market</small></div>');
    }

    $('[data-toggle="tooltip"]').tooltip()
    setTimeout(function() {
        from = "retailPropertysDiv";
        to = "mainMenu";
        $('#retailPropertysDiv').fadeIn(500);
    }, 501)
}

function toggleJobIcons(raceActive) {
    if(playerJob == "police" && jobDuty == true) {
        $('#policeJobBtns').css({"display":"flex"})
    } else {
        $('#policeJobBtns').css({"display":"none"})
    }
    if(playerJob == "ems" && jobDuty == true) {

    } else {

    }
    if(playerJob == "realestate" && jobDuty == true) {
        $('#retailJobBtns').css({"display":"flex"})
    } else {
        $('#retailJobBtns').css({"display":"none"})
    }
    if(playerJob == "fooddelivery" && jobDuty == true) {
        $('#foodJobBtns').css({"display":"flex"})
    } else {
        $('#foodJobBtns').css({"display":"none"})
    }
    if(playerJob == "tuners") {
        $('#raceBtn').css({"display":"block"})
    } else {
        $('#raceBtn').css({"display":"none"})
    }
}

function toggleActiveRaceBtn(state) {
    if(state == true) {
        $('#activeRaceBtn').css({"display":"block"})
    } else {
        $('#activeRaceBtn').css({"display":"none"})
    }
}

function toggleContestants(state) {
    if(state == true) {
        $('#checkContestants').css({"display":"block"})
    } else {
        $('#checkContestants').css({"display":"none"})
    }
}

function populateProperties(data) {
    $('#mainMenu').fadeOut(500);
    var properties = data.properties

    $('#myPropertiesContent').html('');

    if(properties.length > 0) {
        $.each(properties, function (index, property) {
            $('#myPropertiesContent').append('<div class="alert alert-info p-1 mb-1"><div class="container-fluid mt-1"><div class="row" data-toggle="collapse" data-target="#property-' + property.property_id + '"><div class="col-2 my-auto mt-1"><i class="fad fa-home-alt fa-2x"></i></div><div class="col-10 text-center my-auto"><small><strong>' + property.name + '</strong></small></div></div><div class="row collapse" id="property-' + property.property_id + '"><div class="col-12 p-2"><div class="container-fluid" id="houseInformation-' + property.property_id + '"></div></div></div></div></div>');
            var meta = jQuery.parseJSON(property.metainformation)
            var coords = jQuery.parseJSON(property.location)
            if (meta.CIDS.rentor == data.mycid) {
                if(meta.luxuryEnabled.alarm == true && meta.options.alarm == true) {
                    if(meta.brokenInto == true) {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-12 text-center"><div class="alert alert-danger"><i class="fad fa-bells fa-3x alertFlick"></i><br>Alarm Triggered</div></div></div>');
                    }
                }
                $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Status:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Rented</small></small></div></div>');
                $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Rental Cost:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.costs.rental + ' per week</small></small></div></div>');
                if(parseInt(meta.rents.arrears) > 0) {
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Current Arrears:</strong></small></small></div><div class="col-6 p-0 text-danger"><small><small>$' + meta.rents.arrears + '</small></small></div></div>');
                } else {
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Current Arrears:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Good Standing</small></small></div></div>');
                }
                if(parseInt(meta.rents.missed) > 0) {
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Weeks in Arrears:</strong></small></small></div><div class="col-6 p-0 text-danger"><small><small>' + meta.rents.missed + ' Weeks</small></small></div></div>');
                } else {
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Weeks in Arrears:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Good Standing</small></small></div></div>');
                }
                if(meta.rents.evicting == true) {
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Eviction Pending</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + meta.rents.evictingLeft + ' Hours Left</small></small></div></div>');
                }
            } else if(meta.CIDS.owner == data.mycid) {
                if(meta.CIDS.rentor > 0) {
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Status:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Leased</small></small></div></div>');
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Rental Cost:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.costs.rental + ' per week</small></small></div></div>');
                    if(parseInt(meta.rents.arrears) > 0) {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Current Arrears:</strong></small></small></div><div class="col-6 p-0 text-danger"><small><small>$' + meta.rents.arrears + '</small></small></div></div>');
                    } else {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Current Arrears:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Good Standing</small></small></div></div>');
                    }
                    if(parseInt(meta.rents.missed) > 0) {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Weeks in Arrears:</strong></small></small></div><div class="col-6 p-0 text-danger"><small><small>' + meta.rents.missed + ' Weeks</small></small></div></div>');
                    } else {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Weeks in Arrears:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Good Standing</small></small></div></div>');
                    }
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Pending Collection:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.rents.pot + '</small></small></div></div>');
                    if(meta.rents.evicting == true) {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Eviction Order</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + meta.rents.evictingLeft + ' Hours Left</small></small></div></div>');
                    }
                } else {
                    if(meta.luxuryEnabled.alarm == true && meta.options.alarm == true) {
                        if(meta.brokenInto == true) {
                            $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-12 text-center"><div class="alert alert-danger"><i class="fad fa-bells fa-3x alertFlick"></i><br>Alarm Triggered</div></div></div>');
                        }
                    }
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Status:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Owned</small></small></div></div>');
                    $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Purchase Cost:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>' + meta.costs.purchase + '</small></small></div></div>');
                    if(meta.houseStatus.forSale == true) {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>ForSale State:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Property For Sale</small></small></div></div>');    
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Advertised For:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.costs.purchase + '</small></small></div></div>');    
                    }
                    if(meta.houseStatus.forRent == true) {
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Rental State:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>Property For Rent</small></small></div></div>');    
                        $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-6 p-0"><small><small><strong>Advertised For:</strong></small></small></div><div class="col-6 p-0 text-success"><small><small>$' + meta.costs.rental + ' per week</small></small></div></div>');    
                    }
                }
            }
            $('#houseInformation-' + property.property_id).append('<div class="row"><div class="col-4 text-center p-2"><i class="fad fa-map-marker-alt fa-2x" data-x="' + coords.x + '" data-y="' + coords.y + '" data-z="' + coords.z + '" data-act="propertyGPS"></i></div><div class="col-4 text-center p-2"></div><div class="col-4 text-center p-2"></div></div>');
        });
    } else {
        $('#myPropertiesContent').append('<div class="alert alert-info text-center"><small>No Propertys Found</small></div>');
    }

    setTimeout(function() {
        from = "myPropertiesDiv";
        to = "mainMenu";
        $('#myPropertiesDiv').fadeIn(500);
    }, 501)
}

function closeRadio() {
    $("#radioDiv").animate({"bottom":"-600px"}, "slow");
}

function loadSpecificTweet(data) {
    var mainTweet = data.data.mainTweet
    var tweetReply = data.data.tweets
    var profile = event.data.profile

    $('#twitterContent').html('');
    $('#twitterContent').append('<div class="row"><div class="col-12"><input type="text" class="form-control form-control-sm text-center" tabindex="-1" placeholder="Reply to Tweet" id="replyTweetText" name="replyTweetText" data-tweet="' + mainTweet.tweet_id + '"><button class="btn btn-warning btn-sm mt-1" data-act="twitterHome" style="width:49%;">Return</button> <button style="width:49%;" class="btn btn-info btn-sm mt-1" data-act="postReplyTweet">Post Reply</button></div></div><div class="row mt-2"><div class="col-12 p-1"><div class="container-fluid bg-white rounded noscrollbar p-1" style="height: 600px; max-height:345px; overflow-y:scroll;" id="tweetHomepageTweets"></div></div></div>');
    $('#tweetHomepageTweets').append('<div class="alert alert-primary mb-1 p-0"><div class="container-fluid"><div class="row"><div class="col-12 p-1"><small><strong>' + mainTweet.tweet_by + '</strong> tweeted:</small></div></div><div class="row"><div class="col-12"><small>' + mainTweet.tweet_content + '</small></div></div><div class="row mt-1"><div class="col-6 text-center">' + mainTweet.tweet_replys + ' <i class="fad fa-reply-all fa-fw"></i></div><div class="col-6 text-center" data-act="loveTweet" data-from="theTweet" data-tweet="' + mainTweet.tweet_id + '"><i class="fad fa-heart fa-fw"></i> ' + mainTweet.tweet_hearts + '</div></div></div></div>');
    $('#tweetHomepageTweets').append('<div class="alert alert-info mb-1 p-0" id="tweetReplysBox"></div>');
    $('#tweetReplysBox').html('');
    if(tweetReply.length > 0) {
        $.each(tweetReply, function (index, tweet) {
            $('#tweetReplysBox').append('<div class="container-fluid"><div class="row"><div class="col-12 p-1"><small><strong>' + tweet.tweet_by + '</strong> replied:</small></div></div><div class="row"><div class="col-12"><small>' + tweet.tweet_content + '</small></div></div></div>');
        });
    } else {
        $('#tweetReplysBox').append('<div class="text-center"><small>No Replys Found</small></div>');
    }
}

function loadTwitterApplication(data){
    var tweets = data.data.tweets;
    var profile = data.data.profile
    
    $('#twitterContent').html('');
    $('#twitterContent').append('<div class="row"><div class="col-12"><input type="text" class="form-control form-control-sm text-center" tabindex="-1" placeholder="Lets Tweet about..." id="newTweetText" name="newTweetText"><button class="btn btn-info btn-sm btn-block mt-1" data-act="postNewTweet">Post Tweet</button></div></div><div class="row mt-2"><div class="col-12 p-1"><div class="container-fluid bg-white rounded noscrollbar p-1" style="height: 600px; max-height:345px; overflow-y:scroll;" id="tweetHomepageTweets"></div></div></div>');
    $('#tweetHomepageTweets').html('');
    if(tweets.length > 0) {
        $.each(tweets, function (index, tweet) {
            $('#tweetHomepageTweets').append('<div class="alert alert-primary mb-1 p-0"><div class="container-fluid"><div class="row"><div class="col-12 p-1" data-act="viewTweet" data-tweet="' + tweet.tweet_id + '"><span><small><strong>' + tweet.tweet_by + '</strong> tweeted:</small></span></div></div><div class="row"><div class="col-12" data-act="viewTweet" data-tweet="' + tweet.tweet_id + '"><small><span>' + tweet.tweet_content + '</span></small></div></div><div class="row mt-1"><div class="col-6 text-center" data-act="viewTweet" data-tweet="' + tweet.tweet_id + '">' + tweet.tweet_replys + ' <i class="fad fa-reply-all fa-fw"></i></div><div class="col-6 text-center" data-act="loveTweet" data-from="homepage" data-tweet="' + tweet.tweet_id + '"><i class="fad fa-heart fa-fw"></i> ' + tweet.tweet_hearts + '</div></div></div></div>');
        });
    } else {
        $('#tweetHomepageTweets').append('<div class="alert alert-primary mb-1 p-1 text-center">No Tweets Found</div>');
    }

    from = "twitterHomePage";
    to = "mainMenu";
    $('#twitterHomePage').fadeIn(500)
}

function refreshTweets(data) {
    var tweets = data.data.tweets;
    var profile = data.data.profile
    $('#twitterContent').html('');
    $('#twitterContent').append('<div class="row"><div class="col-12"><input type="text" class="form-control form-control-sm text-center" tabindex="-1" placeholder="Lets Tweet about..." id="newTweetText" name="newTweetText"><button class="btn btn-info btn-sm btn-block mt-1" data-act="postNewTweet">Post Tweet</button></div></div><div class="row mt-2"><div class="col-12 p-1"><div class="container-fluid bg-white rounded noscrollbar p-1" style="height: 600px; max-height:345px; overflow-y:scroll;" id="tweetHomepageTweets"></div></div></div>');
    
    if(tweets.length > 0) {
        $.each(tweets, function (index, tweet) {
            $('#tweetHomepageTweets').append('<div class="alert alert-primary mb-1 p-0" data-act="viewTweet"><div class="container-fluid"><div class="row"><div class="col-12 p-1" data-act="viewTweet" data-tweet="' + tweet.tweet_id + '"><span><small><strong>' + tweet.tweet_by + '</strong> tweeted:</small></span></div></div><div class="row"><div class="col-12" data-act="viewTweet" data-tweet="' + tweet.tweet_id + '"><small><span>' + tweet.tweet_content + '</span></small></div></div><div class="row mt-1"><div class="col-6 text-center" data-act="viewTweet" data-tweet="' + tweet.tweet_id + '">' + tweet.tweet_replys + ' <i class="fad fa-reply-all fa-fw"></i></div><div class="col-6 text-center" data-act="loveTweet" data-from="homepage" data-tweet="' + tweet.tweet_id + '"><i class="fad fa-heart fa-fw"></i> ' + tweet.tweet_hearts + '</div></div></div></div>');
        });
    } else {
        $('#tweetHomepageTweets').append('<div class="alert alert-primary mb-1 p-1 text-center">No Tweets Found</div>');
    }

    from = "twitterHomePage";
    to = "mainMenu";
}

function callConnectedWith(name) {
    $.post('http://pw_phone/loseFocus', JSON.stringify({ }));
    $('#'+from).fadeOut(500)
    $('#callConnected').html('');
    $('#callConnected').append('<div class="row"><div class="col-12 pt-3 text-center"><i class="fad fa-phone-volume text-success fa-9x"></i><div class="alert alert-info mt-4 text-center"><small>Connected With</small><br><div class="text-center h5" id="callWithName">' + name + '</div></div></div></div><div class="row"><div class="col-12 pt-3 text-center"><i class="fad fa-times-circle fa-3x text-danger" data-act="terminateCall"></i></div></div>')

    setTimeout(function() {
        from = 'callConnected';
        to = 'mainMenu';
        $('#callConnected').fadeIn(500);
    }, 501);
}

function callEnded() {
    $('#callConnected').fadeOut(500);
    from = null;
    to = null;
    callWith = null;
    setTimeout(function() {
        $('#callEnded').fadeIn(500);
        setTimeout(function() {
            closePhone('fast');
            $('#callEnded').fadeOut(500);
        }, 501);
    }, 501);
}

function receivingCall(incomming, name, failed, reason) {
    $('#mainMenu').fadeOut(1);
    blockNormalOpen = true;
    $('#receivingCall').html('');
    $('#receivingCall').append('<div class="row"><div class="col-12 pt-3 text-center"><i id="callBlinker" class="fad fa-phone-volume fa-9x text-success"></i><div class="alert alert-info mt-4 text-center"><small>Incoming Call</small><br><span class="h5 mb-1">' + name + '</span></div></div></div><div class="row"><div class="col-12 pt-3 text-center"><i class="fad fa-times-circle fa-3x text-danger mr-4" data-act="rejectCall"></i> <i class="ml-4 fad fa-check-circle fa-3x text-success" data-act="acceptCall"></i></div></div>')
    $('#receivingCall').fadeIn(1)
    $("#phoneDiv").animate({"bottom":"10px"}, "slow");
    from = 'receivingCall';
    to = 'mainMenu';
}

function connectingCall(incomming, name, failed, reason) {
    $('#dialingCall').html('');
    $('#connectingCall').fadeOut(500);

    if(failed === true) {
        $('#dialingCall').append('<div class="row"><div class="col-12 pt-3 text-center"><i class="fad fa-times-circle fa-9x text-danger"></i><div class="alert alert-info mt-4 text-center"><small>Call has Failed</small><br><span class="h5 mb-1">' + name + '</span><br>' + reason + '</div></div></div><div class="row"><div class="col-12 pt-3 text-center"></div></div>')
    } else {
        from = 'connectingCall';
        $('#dialingCall').append('<div class="row"><div class="col-12 pt-3 text-center"><i id="callBlinker2" class="fad fa-phone-volume fa-9x text-success"></i><div class="alert alert-info mt-4 text-center"><small>Calling</small><br><span class="h5 mb-1">' + name + '</span></div></div></div><div class="row"><div class="col-12 pt-3 text-center"><i class="fad fa-times-circle fa-3x text-danger" data-act="cancelCall></i></div></div>')
    }

    setTimeout(function() {
        $('#dialingCall').fadeIn(500);
        from = 'dialingCall';
        if(failed === true) {
            setTimeout(function() {
                $('#dialingCall').fadeOut(500);
                setTimeout(function() {
                    $('#mainMenu').fadeIn(500);
                    $('#dialingCall').html('');
                    to = null;
                    from = null;
                }, 501);
            }, 2000);
        }
    }, 501)
}

function loadViewEmail(email) {
    $('#emailViewList').html('');
    $('#emailViewList').append('<div class="row justify-content-center mt-2"><div class="col-2"><small>To:</small></div><div class="col-10 text-right"><small>' + email.email.email_to + '</small></div></div><div class="row justify-content-center mt-2"><div class="col-2"><small>From:</small></div><div class="col-10 text-right"><small>' + email.email.email_from + '</small></div></div><div class="row justify-content-center mt-1"><div class="col-2"><small>Subject:</small></div><div class="col-10 text-right"><small>' + email.email.email_subject +'</small></div></div><div class="row justify-content-center mt-1"><div class="col-2"><small>Date:</small></div><div class="col-10 text-right"><small>' + email.email.email_date + '</small></div></div>');
    if(email.email.email_meta !== undefined && email.email.email_meta !== null) {
        $('#emailViewList').append('<div class="row"><div class="col-12"><strong><small>Attachments</small></strong></div></div><div class="row justify-content-center">');
        var emailAttachments = jQuery.parseJSON(email.email.email_meta);
        if(emailAttachments.waypoint !== undefined && emailAttachments.waypoint !== null) {
            $('#emailViewList').append('<div class="col text-center"><i class="fad fa-map-marked fa-2x" data-x="' + emailAttachments.waypoint.x + '" data-y="' + emailAttachments.waypoint.y + '" data-z="' + emailAttachments.waypoint.z + '" data-act="setEmailWaypoint"></i></div>');
        }
        if(emailAttachments.property !== undefined && emailAttachments.property !== null) {
            $('#emailViewList').append('<div class="col text-center"><i class="fad fa-house-leave fa-2x" data-x="' + emailAttachments.property.x + '" data-y="' + emailAttachments.property.y + '" data-z="' + emailAttachments.property.z + '" data-act="setEmailWaypoint"></i></div>');
        }
        if(emailAttachments.vehicle !== undefined && emailAttachments.vehicle !== null) {
            $('#emailViewList').append('<div class="col text-center"><i class="fad fa-car fa-2x" data-x="' + emailAttachments.vehicle.x + '" data-y="' + emailAttachments.vehicle.y + '" data-z="' + emailAttachments.vehicle.z + '" data-act="setEmailWaypoint"></i></div>');
        }
        if(emailAttachments.gps !== undefined && emailAttachments.gps !== null) {
            $('#emailViewList').append('<div class="col text-center"><i class="fad fa-location fa-2x" data-x="' + emailAttachments.gps.x + '" data-y="' + emailAttachments.gps.y + '" data-z="' + emailAttachments.gps.z + '" data-act="setEmailWaypoint"></i></div>');
        }
        $('#emailViewList').append('</div>');
    }
    $('#emailViewList').append('<div class="row justify-content-center mt-2"><div class="col-12"><div class="alert alert-info"><small>' + email.email.email_content + '</small></div></div></div></div>');

    if(email.data.emailtype == "inbox") {
        $('#emailReplyBtn').data('emailTo', email.email.email_from).data('to', 'emailInboxDiv');
        $('#emailBackButton').data('goto', 'emailInboxDiv').data('from','viewEmailDiv')
        from = "viewEmailDiv";
        to = "emailInboxDiv"
    } else {
        $('#emailReplyBtn').data('emailTo', email.email.email_to).data('to', 'emailSentDiv');
        $('#emailBackButton').data('goto', 'emailSentDiv').data('from','viewEmailDiv')
        from = "viewEmailDiv";
        to = "emailSentDiv"
    }
    $('#viewEmailDiv').fadeIn(500);
}

function loadEmailInbox(emails) {
    $('#emailInboxContent').html('');

    if(emails.length > 0) {
        $.each(emails, function (index, email) {
            if(email.email_read == 0) {
                icon = '<i class="fad fa-envelope fa-fw text-warning"></i>';
            } else {
                icon = '<i class="fad fa-envelope-open fa-fw"></i>';
            }
            $('#emailInboxContent').append('<div class="container-fluid alert alert-info p-1 m-1"><div class="row"><div class="col-2 text-center my-auto" data-act="viewEmail" data-email="' + email.email_id + '" data-emailtype="inbox">' + icon + '</div><div class="col-7" data-act="viewEmail" data-email="' + email.email_id + '" data-emailtype="inbox"><small>' + email.email_subject + '</small><br><small><small>' + email.email_from + '</small></small></div><div class="col-3 text-center my-auto" data-act="deleteEmail" data-email="' + email.email_id + '" data-emailtype="inbox"><i class="fad fa-trash-alt text-danger fa-fw"></i></div></div></div>');
        });
    } else {
        $('#emailInboxContent').append('<div class="alert alert-info text-center p-1 mt-2"><small>No emails avaliable in your inbox.</small></div>');
    }

    from = "emailInboxDiv";
    to = "mainMenu"
    $('#emailInboxDiv').fadeIn(500);
}

function loadEmailSent(emails) {
    $('#emailSentContent').html('');

    if(emails.length > 0) {
        $.each(emails, function (index, email) {
            icon = '<i class="fad fa-envelope-open fa-fw"></i>';
            $('#emailSentContent').append('<div class="container-fluid alert alert-info p-1 m-1"><div class="row"><div class="col-2 text-center my-auto" data-act="viewEmail" data-email="' + email.email_id + '" data-emailtype="sent">' + icon + '</div><div class="col-7" data-act="viewEmail" data-email="' + email.email_id + '" data-emailtype="sent"><small>' + email.email_subject + '</small><br><small><small>' + email.email_to + '</small></small></div><div class="col-3 text-center my-auto" data-act="deleteEmail" data-email="' + email.email_id + '" data-emailtype="sent"><i class="fad fa-trash-alt text-danger fa-fw"></i></div></div></div>');
        });
    } else {
        $('#emailSentContent').append('<div class="alert alert-info text-center p-1 mt-2"><small>No emails avaliable in your sent box.</small></div>');
    }

    from = "emailSentDiv";
    to = "emailInboxDiv"
    $('#emailSentDiv').fadeIn(500);
}

function manageRaces(races) {
    $('#manageRacesList').html('');

    if(races.length > 0) {
        $.each(races, function (index, race) {
            $('#manageRacesList').append('<div class="btn-group w-100 m-1" role="group" aria-label="Race Info"><button class="btn btn-primary btn-block" tabindex="-1">' + race.name + '</button><button class="btn btn-info" id="raceInfo-'+ index + '" data-toggle="collapse" data-target="#raceInfoBox-' + race.id + '" aria-expanded="false" aria-controls="raceInfoBox-' + race.id + '" tabindex="-1"><i class="fas fa-stopwatch fa-fw"></i></button><button class="btn btn-danger" id="race-'+ index + '" data-act="deleteTrack" data-track="' + race.id + '" tabindex="-1"><i class="fas fa-trash-alt fa-fw"></i></button></div>');
            var appendToThis = '<div class="container-fluid pb-0"><div class="collapse row" id="raceInfoBox-' + race.id + '"><div class="alert alert-info w-100 m-1">'
            if (race.records.length > 0) {
                $.each(race.records, function (rIndex, record) {
                    appendToThis = appendToThis + '<small data-placement="top" data-atoggle="tooltip" title="' + record.name + '">#' + (rIndex + 1) + ': <strong>' + record.display + '</strong> ' + (record.topSpeed.car !== 'onfoot' ? ' (Max: <strong>' + record.topSpeed.speed + ' mph</strong>)' : '') + '</small><br>';
                });
                appendToThis = appendToThis + '<div class="text-center mt-2"><button class="btn btn-danger btn-sm" id="race-'+ index + '" data-act="clearRecords" data-track="' + race.id + '" tabindex="-1"><i class="fas fa-trash-alt fa-fw"></i> Clear Records</button></div>';
            } else {
                appendToThis = appendToThis + '<small>No data available yet</small>';
            };
            appendToThis = appendToThis + '</div></div></div>'
            $('#manageRacesList').append(appendToThis);
            race.tblIndex = index + 1
            $('#race-' + index).data('raceInfo', race);
        });        
        $('[data-atoggle="tooltip"]').tooltip();
    } else {
        $('#manageRacesList').append('<div class="container-fluid pb-0"><div class="alert alert-danger text-center p-1 mt-2"><small>There aren\'t any available race tracks at the moment.</small></div></div>');
    };

    from = "manageRacesDiv";
    to = "mainMenu";
    $('#manageRacesDiv').fadeIn(500);
}

function loadRaces(races) {
    $('#racesList').html('');

    if(races.length > 0) {
        $.each(races, function (index, race) {
            $('#racesList').append('<div class="btn-group w-100 m-1" role="group" aria-label="Race Info"><button class="btn btn-primary btn-block" tabindex="-1">' + race.name + '</button><button class="btn btn-info" id="raceInfo-'+ index + '" data-toggle="collapse" data-target="#raceInfoBox-' + race.id + '" aria-expanded="false" aria-controls="raceInfoBox-' + race.id + '" tabindex="-1"><i class="fas fa-info fa-fw"></i></button><button class="btn btn-success" id="race-'+ index + '" data-act="pickedRace" tabindex="-1"><i class="fas fa-angle-double-right fa-fw"></i></button></div>');
            $('#racesList').append('<div class="container-fluid pb-0"><div class="collapse row" id="raceInfoBox-' + race.id + '"><div class="alert alert-info w-100 m-1"><small>Race Type: <strong>' + race.typeLabel + '</strong></small><br><small>Max Contestants: <strong>' + race.max + '</strong></small><br><small># of Laps: <strong>' + ((race.typeLabel === 'Circuit' || race.typeLabel === 'Running') ? 'Custom' : '1') + '</strong></small><br><small># of Checkpoints: <strong>' + race.checkpoints.length + '</strong></small></div></div></div>');
            race.tblIndex = index + 1
            $('#race-' + index).data('raceInfo', race);
        });
    } else {
        $('#racesList').append('<div class="container-fluid pb-0"><div class="alert alert-danger text-center p-1 mt-2"><small>There aren\'t any available race tracks at the moment.</small></div></div>');
    };

    from = "newRacesDiv";
    to = "mainMenu";
    $('#newRacesDiv').fadeIn(500);
}

function loadActiveRaceDiv(active, contestants, org) {
    $('#activeRace').html('');
    $('#activeRaceName').html(active.info.name);

    $('#activeRace').append('<div class="alert alert-info w-100 m-1"><small>Race Type: <strong>' + active.info.typeLabel + '</strong></small><br><small>Contestants: <strong>' + contestants.length + '</strong>/<strong>' + active.settings.contestants + '</strong></small><br><small># of Laps: <strong>' + active.settings.laps + '</strong></small><br><small># of Checkpoints: <strong>' + active.info.checkpoints.length + '</strong></small></div>');
    $('#activeRace').append('<div class="row justify-content-center w-100 mx-auto"><div class="col-12 p-2 text-center"><button class="btn btn-success" id="joinRace" data-act="joinRace" tabindex="-1"><i class="fas fa-plus fa-fw"></i> <strong>Join Race</strong></button> <button ' + ((org !== true) ? 'style="display:none;"' : '') + 'class="btn btn-warning" id="checkContestants" data-act="checkContestants" tabindex="-1"><i class="fas fa-users-cog fa-fw"></i></button></div></div>');
    $('#checkContestants').data('contestantsTable', contestants);

    from = "activeRaceDiv";
    to = "mainMenu";
    $('#activeRaceDiv').fadeIn(500);
}

function loadContestants(contestants) {
    $('#contestantsRow').html('');

    var nContestants = contestants.length;
    $('#activeRaceContestants').html('Contestants: <strong>' + nContestants + '</strong>');

    $.each(contestants, function(index, contestant) {
        var curPosition = index + 1;
        var name = contestant.name;
        var dropdownItems = '<div class="dropdown-menu" aria-labelledby="btnGroupDrop1">';
        $.each(contestants, function(cIndex, cContestant) {
            dropdownItems = dropdownItems + '<a class="dropdown-item' + ((curPosition == (cIndex + 1)) ? ' disabled' : '') + '" data-act="changePosition" data-contestant="' + index + '" data-curposition="' + curPosition + '" data-toposition="' + (cIndex + 1) + '" href="#">#' + (cIndex + 1) + '</a>'
        });
        dropdownItems = dropdownItems + '</div>'
        $('#contestantsRow').append('<div class="btn-group mx-auto w-100 mb-1" role="group" aria-label="Contestants"><div class="btn-group" role="group"><button id="btnGroupDrop1" type="button" class="btn btn-info dropdown-toggle btn-sm" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" data-tooltip="tooltip" data-placement="top" title="Set Pole Position">' + curPosition + '</button>' + dropdownItems + '</div><button type="button" class="btn btn-primary btn-sm text-truncate w-50" data-toggle="tooltip" data-placement="top" title="' + name + '">' + name + '</button><button type="button" class="btn btn-' + (curPosition == 1 ? 'secondary disabled' : 'success') + ' btn-sm" data-toggle="tooltip" data-placement="top" title="Move Up" data-act="changePosition" data-contestant="' + index + '" data-curposition="' + curPosition + '" data-toposition="' + (curPosition - 1) + '"><i class="fas fa-arrow-alt-up fa-fw"></i></button><button type="button" class="btn btn-' + (curPosition == nContestants ? 'secondary disabled' : 'danger') + ' btn-sm" data-toggle="tooltip" data-placement="top" title="Move Down" data-act="changePosition" data-contestant="' + index + '" data-curposition="' + curPosition + '" data-toposition="' + (curPosition + 1) + '"><i class="fas fa-arrow-alt-down fa-fw"></i></button></div>');
    });
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-tooltip="tooltip"]').tooltip();

    $('#contestantsRow').append('<div class="row justify-content-center w-100 mx-auto"><div class="col-12 p-2 text-center"><button type="button" class="btn btn-danger" data-act="cancelRace"><i class="fas fa-ban fa-fw"></i> Cancel</button> <button type="button" class="btn btn-success" data-act="startRace"><i class="fas fa-cars fa-fw"></i> Start</button></div></div>');

    from = "raceContestantsDiv";
    to = "mainMenu";
    $('#raceContestantsDiv').fadeIn(500);
}

function createTrack(step, data) {

    $('#raceTypes').change(function() {
        changeContestants();
    });

    $('#newTrackLaps').on('input', function() {
        $('#newTrackLaps-value').html(this.value);
    });

    from = "createTrackDiv";
    to = "mainMenu";
    $('#createTrackDiv').fadeIn(500);
}

function changeContestants() {
    switch ($('#raceTypes').val()) {
        case '1':
            $('#newTrackLaps').attr('min', 2);
            $('#newTrackLaps').attr('max', 8);
            break;
        case '2':
            $('#newTrackLaps').attr('min', 2);
            $('#newTrackLaps').attr('max', 8);
            break;
        case '3':
            $('#newTrackLaps').attr('min', 2);
            $('#newTrackLaps').attr('max', 2);
            break;
        case '4':
            $('#newTrackLaps').attr('min', 2);
            $('#newTrackLaps').attr('max', 32);
            break;
    }
    $('#newTrackLaps').val('2');
    $('#newTrackLaps-value').html('2');
}

function loadStartRaceSettings(race) {
    $('#raceSettings').html('');
    $('#raceSettingsRaceName').html(race.name + " - " + race.typeLabel);

    if(race.raceType === 1 || race.raceType === 4) {
        $('#raceSettings').append('<div class="alert alert-info w-100"><label for="laps"><small># of Laps: <strong><span id="laps-value" class="text-info">' + 2 + '</span></strong></small></label><input type="range" name="rangeLaps" step="1" id="laps" min="2" max="5" value="2" class="form-control"></div>');
        $('#laps').on('input', function() {
            $('#laps-value').html(this.value);
        });
    } else {
        $('#raceSettings').append('<div class="alert alert-info w-100"><small># of Laps: <strong><span id="laps-value" class="text-info">1</span></strong></small></div>');
    };
    
    if(race.raceType !== 3) {
        if(race.max === 2) {
            $('#raceSettings').append('<div class="alert alert-info w-100 mt-n2"><small># of Contestants: <strong><span id="contestants-value" class="text-info">2</span></strong></small></div>');
        } else {
            $('#raceSettings').append('<div class="alert alert-info w-100 mt-n2"><label for="contestants"><small># of Contestants: <strong><span id="contestants-value" class="text-info">' + 2 + '</span></strong></small></label><input type="range" name="rangeContestants" step="1" id="contestants" min="2" max="' + race.max + '" value="2" class="form-control"></div>');
            $('#contestants').on('input', function() {
                $('#contestants-value').html(this.value);
            });
        };
    } else {
        $('#raceSettings').append('<div class="alert alert-info w-100 mt-n2"><small># of Contestants: <strong><span id="contestants-value" class="text-info">2</span></strong></small></div>');
    };

    $('#raceSettings').append('<div class="alert alert-info w-100 mt-n2"><label for="delay"><small>Starting delay: <strong><span id="delay-value" class="text-info">' + 10 + ' seconds</span></strong></small></label><input type="range" name="rangeDelay" step="10" id="delay" min="10" max="' + 300 + '" value="10" class="form-control"></div>');
    $('#delay').on('input', function() {
        $('#delay-value').html(this.value + " seconds");
    });
    
    $('#raceSettings').append('<button class="btn btn-success btn-block" id="raceCreate" data-act="raceSet" tabindex="-1"><i class="fas fa-plus fa-fw"></i> <strong>Create Race</strong></button>');
    $('#raceCreate').data('raceInfo', race)

    from = "raceSettingsDiv";
    to = "mainMenu";
    $('#raceSettingsDiv').fadeIn(500);
};

function loadFoodDelivery(delivery) {
    if (delivery.isOnActiveDelivery === true && onFoodDelivery === false) {
        onFoodDelivery = true
        $('[data-act=startNewFoodJob]').replaceWith('<button class="btn btn-block btn-danger" data-act="cancelOldFoodJob" tabindex="-1">Cancel Current</button>');
        $('[data-act=cancelOldFoodJob]').fadeIn(500);
    } else if (delivery.isOnActiveDelivery === false && onFoodDelivery === true) {
        onFoodDelivery = false
        $('#currentFoodDeliveryInfo').fadeOut(500);
        setTimeout(function() {
            $('[data-act=cancelOldFoodJob]').replaceWith('<button class="btn btn-block btn-success" data-act="startNewFoodJob" tabindex="-1">Start Delivery</button>');
            $('#currentFoodDeliveryInfo').replaceWith('<div id="currentFoodDeliveryInfo" class="alert alert-info m-1 pb-1"><div class="w-100 text-center"><strong>You Have No Current Delivery</small></div><br><div class="w-100 text-center"><small>Start a Delivery for it to appear here.</small></div><br></div>');
            $('[data-act=startNewFoodJob]').fadeIn(500);
            $('#currentFoodDeliveryInfo').fadeIn(500);
        }, 501)
    }
    if (delivery.isOnActiveDelivery) {
        $('#currentFoodDeliveryInfo').fadeOut(500);
        setTimeout(function() {
            $('#currentFoodDeliveryInfo').replaceWith('<div id="currentFoodDeliveryInfo" class="alert alert-info m-1 pb-1"><div class="w-100 text-center"><strong>Currently On a Delivery</small></div><br><div class="w-100 text-center"><small>There is ' + delivery.foodName + delivery.currentFoodInstructions + delivery.currentAwaitingLocation +'</small></div><br></div>');
            $('#currentFoodDeliveryInfo').fadeIn(500);
        }, 501)
    }
}

function loadAdvertisements(ads) {
    $('#advertisementLists').html('');

    if(ads.length > 0) {
        $('#advertisementLists').append('<div class="mt-1 mb-1 text-center"><small><strong>Current Advertisements</strong></small></div>');
    $.each(ads, function (index, ad) {
        if(ad.owner === true) {
            deleteIcon = ' <i class="fad fa-trash-alt text-danger fa-fw" data-act="deleteMyAdvert" data-adid="' + ad.advert_id + '"></i>';
        } else {
            deleteIcon = '';
        }
        $('#advertisementLists').append('<div class="alert alert-warning m-1 pb-1"><small><strong>' + ad.advert_title + '</strong></small><br><small><small>' + ad.advert_content + '</small></small><br><div class="text-right"><small>' + ad.advert_posted + '' + deleteIcon + '</small></div></div>');
    });
    } else {
        $('#advertisementLists').append('<div class="alert alert-info text-center p-1 mt-2"><small>No Adverts have been posted.</small></div>');
    }

    from = "advertisementsDiv";
    to = "mainMenu"
    $('#advertisementsDiv').fadeIn(500);
}

function loadConversation(con) {
    $('#convoList').html('');
    if(con.conversation_messages.length > 0) {
        con.conversation_messages.reverse();
        $('#sendTextReponse').data('convoid', con.conversation_details.convo_id);
        $('#sendTextReponse').data('to', con.conversation_details.to);
        $('#sendTextReponse').data('from', con.conversation_details.from);
        $('#convoReply').fadeIn(500);
        $('#convoList').append('<div class="row mb-2"><div class="col-12 text-center"><small><b>Conversation History</b></small></div></div>');
        $.each(con.conversation_messages, function (index, convo) {
            if(convo.to == number) {
                if(convo.to == con.conversation_details.to) {
                    if(con.conversation_details.fromName !== undefined && con.conversation_details.fromName !== null) {
                        name = con.conversation_details.fromName
                    } else {
                        name = con.conversation_details.from
                    }
                } else {
                    if(con.conversation_details.toName !== undefined && con.conversation_details.toName !== null) {
                        name = con.conversation_details.toName
                    } else {
                        name = con.conversation_details.to
                    }
                }
                $('#convoList').append('<div class="alert alert-dark mr-auto p-1" style="max-width:80%;"><small><small><strong>' + name + '</strong></small></small><br><small>' + convo.message + '</small><br><div class="text-right"><small><small>' + convo.datetime + ' <i class="fad fa-trash-alt text-danger" data-act="deleteMessage" data-messageid="' + convo.message_id + '" data-convoid="' + con.conversation_details.convo_id + '"></i></small></small></div></div>');
            } else if(convo.to !== number) {
                $('#convoList').append('<div class="alert alert-info ml-auto p-1" style="max-width:80%;"><small><small><strong>Me</strong></small></small><br><small>' + convo.message + '</small><br><div class="text-right"><small><small>' + convo.datetime + ' <i class="fad fa-trash-alt text-danger" data-act="deleteMessage" data-messageid="' + convo.message_id + '" data-convoid="' + con.conversation_details.convo_id + '"></i></small></small></div></div>');
            }
        });
    } else {
        $('#convoReply').css({"display":"none"});
        $('#convoList').append('<div class="alert alert-info text-center p-1"><small>No Messages Stored</small></div>');
    }

    $('#conversationDiv').fadeIn(500);
    from = "conversationDiv";
    to = "textMessagesDiv"
}

function loadConversations(convos) {
    $('#conversationsList').html('');

    if(convos.length > 0) {
        convos.reverse();
        $.each(convos, function (index, convo) {
            if(convo.to == number) {
                if(convo.fromName !== undefined && convo.fromName !== null) {
                    name = convo.fromName
                } else {
                    name = convo.from
                }
            } else {
                if(convo.toName !== undefined && convo.toName !== null) {
                    name = convo.toName
                } else {
                    name = convo.to
                }
            }
            if(convo.unread !== undefined && convo.unread === true) { 
                text_color = ' text-warning';
            } else {
                text_color = '';
            }
            $('#conversationsList').append('<div class="container-fluid alert alert-info p-1 mb-1"><div class="row"><div class="col-2 text-center" data-act="loadConversation" data-convoid="' + convo.convo_id + '"><i class="fad fa-comment-lines fa-fw ' + text_color + '"></i></div><div class="col-7 my-auto" data-act="loadConversation" data-convoid="' + convo.convo_id + '"><small>' + name + '</small></div><div class="col-3 text-center" data-act="deleteConversation" data-convoid="' + convo.convo_id + '"><i class="fad fa-trash-alt text-danger fa-fw"></i></div></div></div>')
        });
    } else {
        $('#conversationsList').append('<div class="alert alert-info text-center p-1"><small>No Conversations Stored</small></div>');
    }
    
    from = "textMessagesDiv";
    to = "mainMenu"
    $('#textMessagesDiv').fadeIn(500);
}

function loadContacts(contacts) {
    $('#contactsDiv').fadeIn(500)
    $('#contactsList').html('');
    if(contacts.length > 0) {
        $.each(contacts, function (index, contact) {
            $('#contactsList').append('<div class="container-fluid alert alert-dark mb-1"><div class="row"><div class="col-12" data-toggle="collapse" data-target="#contact-' + index + '">' + contact.name + '</div></div><div class="row collapse" id="contact-' + index + '"><div class="col-12 mb-2"><small><strong>Number:</strong> #' + contact.number + '</small></div><div class="col-4 text-center p-2"><i class="fad fa-phone fa-2x fa-fw text-success" data-act="callPhone" data-number="' + contact.number + '"></i></div><div class="col-4 text-center p-2"><i class="fad fa-envelope-open-text fa-2x fa-fw text-warning" data-act="sendText" data-number="' + contact.number + '"></i></div><div class="col-4 text-center p-2"><i class="fad fa-trash-alt fa-2x fa-fw text-danger" data-act="deleteContact" data-contactid="' + (index + 1) + '"></i></div></div></div>');
        });
    } else {
        $('#contactsList').append('<div class="alert alert-info text-center p-1"><small>No Contacts Saved</small></div>');
    }


    from = "contactsDiv";
    to = "mainMenu"
}

function loadSimCards(cards) {
    $('#simcardData').html('');
    $('#avaliableSimCards').fadeIn(500);
    if(cards.length > 0) { 
        $.each(cards, function (index, sim) {
            var number = jQuery.parseJSON(sim.metaprivate)
            $('#simcardData').append('<div class="container-fluid alert alert-info p-1 mb-1"><div class="row"><div class="col-2 my-auto text-center"><i class="fad fa-sim-card fa-2x"></i></div><div class="col-7 my-auto text-center">' + number.number + '</div><div class="col-3 my-auto text-center"><button class="btn btn-sm btn-success btn-block" id="simcard-' + sim.record_id + '" data-act="loadSim" data-number="' + number.number + '"><i class="fad fa-arrow-square-right fa-fw"></i></button></div></div></div>');
            $('#simcard-' + sim.record_id).data('item', sim)
        });
    } else {
        $('#simcardData').append('<div class="alert alert-info text-center p-1 mt-5"><small>No SimCards found in inventory.</small></div><p class="text-center"><small>In order to use your phone, a sim card is required to connect to the Celluar network, please purchase a simcard, or put one in your personal inventory, once you have done that you will be able to insert it into your mobile device.</small></p>');
    }
    from = "avaliableSimCards";
    to = "noSimcard";
}

function closePhone(speed) {
    $.post('http://pw_phone/closePhone', JSON.stringify({ }));
    $('[data-toggle="tooltip"]').tooltip('hide');
    if(speed == undefined) {
        speed = "slow"
    }
    phoneOpen = false;
    blockNormalOpen = false;
    $("#phoneDiv").animate({"bottom":"-600px"}, speed);
    if(callWith === null) {
        setTimeout(function() {
            if(from !== undefined && from !== null) {
                if(simcardActive === false) {
                    $('#' + from).fadeOut(1);
                    $('#noSimcard').fadeIn(1);
                } else {
                    $('#' + from).fadeOut(1);
                    $('#mainMenu').fadeIn(1);
                }
            }
            from = null;
            to = null;
        }, 2000)
    }
}

function showInfo(msg) 
{
    if(msg == "ringer") {
        if(ringer === true) {
            $('#infoMessage').html('<small>Turn Ringer Off</small>');
        } else {
            $('#infoMessage').html('<small>Turn Ringer On</small>');
        }
    } else {
    $('#infoMessage').html('<small>' + msg + '</small>');
    }
    $('#mainMenuNotification').css({"display":"block"});
}

function hideInfo()
{
    $('#mainMenuNotification').css({"display":"none"});
    $('#infoMessage').html('');
}

function processessSignal()
{
    if(simcardActive === true) {
        $('#netName').html('PixelNet');
        $('#signal1').html('<i class="fad fa-signal-alt-slash m-1 fa-fw"></i>');
        $('#signal5').css({"display":"none"});
        $('#signal4').css({"display":"none"});
        $('#signal3').css({"display":"none"});
        $('#signal2').css({"display":"none"});
        $('#signal1').css({"display":"inline-block"});
        setTimeout(function() {
            $('#signal5').css({"display":"none"});
            $('#signal4').css({"display":"none"});
            $('#signal3').css({"display":"none"});
            $('#signal2').css({"display":"none"});
            $('#signal1').css({"display":"none"});
            $('#signal4').css({"display":"inline-block"});
            setTimeout(function() {
                $('#signal5').css({"display":"none"});
                $('#signal4').css({"display":"none"});
                $('#signal3').css({"display":"none"});
                $('#signal2').css({"display":"none"});
                $('#signal1').css({"display":"none"});
                $('#signal2').css({"display":"inline-block"});
                setTimeout(function() {
                    $('#signal5').css({"display":"none"});
                    $('#signal4').css({"display":"none"});
                    $('#signal3').css({"display":"none"});
                    $('#signal2').css({"display":"none"});
                    $('#signal1').css({"display":"none"});
                    $('#signal3').css({"display":"inline-block"});
                    setTimeout(function() {
                        $('#signal5').css({"display":"none"});
                        $('#signal4').css({"display":"none"});
                        $('#signal3').css({"display":"none"});
                        $('#signal2').css({"display":"none"});
                        $('#signal1').css({"display":"none"});
                        $('#signal5').css({"display":"inline-block"});
                        setTimeout(function() {
                            $('#signal5').css({"display":"none"});
                            $('#signal4').css({"display":"none"});
                            $('#signal3').css({"display":"none"});
                            $('#signal2').css({"display":"none"});
                            $('#signal1').css({"display":"none"});
                            $('#signal1').css({"display":"inline-block"});
                            processessSignal();
                        }, 6500)
                    }, 5500)
                }, 4500)
            }, 3500)
        }, 2500)
    } else {
        $('#netName').html('<small>No Network</small>');
        $('#signal1').html('<i class="fad fa-sim-card m-1 fa-fw text-danger"></i> <i class="fad fa-signal-alt-slash m-1 fa-fw"></i>');
        setTimeout(function() {
            processessSignal();
        }, 1000)
    }
}

$(function() { 
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            if(preventPhoneOpen === false) {
                closePhone();
                closeRadio();
            }
        }
        if(key.which == 27) {
            if(preventPhoneOpen === true) {
                closeGame();
            }
        }
    });

    $(document).on('click','[data-act=dialNumpad]',function(){
        var currentNumber = $('#dialNumber').val();
        var requestedNumber = $(this).data('number');

        if(requestedNumber == "CALL") {

        } else if(requestedNumber == "CANCEL") {
            $('#dialNumber').val('');
        } else {
            $.post('http://pw_phone/sendSound', JSON.stringify({ sound: "dialPad", number: requestedNumber }));
            $('#dialNumber').val(currentNumber + requestedNumber);
        }
    });

    $(document).on('click','#removeSimBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            from = null;
            to = null;
            $('#noSimcard').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "removeSim", number: number }));
            number = null;
            simcardActive = false;
        }, 501)
    });
    
    $(document).on('click','[data-act=loadSim]',function(){
        var loadNum = $(this).data('number');
        var item = $(this).data('item');
        number = loadNum;
        simcardActive = true;
        $('#avaliableSimCards').fadeOut(500);
        from = null;
        to = null;
        setTimeout(function() {
            $('#mainMenu').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "loadSim", number: loadNum, item: item }));
        }, 501)
    });
    
    $(document).on('click','[data-act=insertSimCard]',function(){
        $('#noSimcard').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "simcards" }));
        }, 501)
    });

    $(document).on('click','#contactListBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "contacts", number: number }));
        }, 501) 
    });

    $(document).on('click','[data-act=deleteContact]',function(){
        $('#contactsDiv').fadeOut(500);
        var contactId = $(this).data('contactid');
        setTimeout(function() {
            $('#deletedMessageYes').html('Contact has been deleted.');
            $('#deletedMessage').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "deleteContact", number: number, conid: contactId }));
            setTimeout(function() {
                $('#deletedMessage').fadeOut(500);
                setTimeout(function() {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "contacts", number: number }));
                    $('#deletedMessageYes').html('');
                }, 501)
            }, 2300)
        }, 501)
    });

    $(document).on('click','[data-act=saveContact]',function(){
        var name = $('#newContactName').val();
        var number2 = $('#newContactNumber').val();
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "saveContact", number: number, name: name, saveNumber: number2 }));
        $('#newContactDiv').fadeOut(500);
        setTimeout(function() {
            $('#newContactName').val('');
            $('#newContactNumber').val('');
            from = null;
            to = null;
            $('#successMessageYes').html('Contact has been saved.');
            $('#successMessage').fadeIn(500);
            setTimeout(function() {
                $('#successMessage').fadeOut(500);
                setTimeout(function() {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "contacts", number: number }));
                }, 501)
            }, 2200)
        }, 501)
    });

    $(document).on('click','#postNewAdvert',function(){
        $('#advertMessage').removeClass('is-invalid');
        $('#advertTitle').removeClass('is-invalid');
        $('#advertisementsDiv').fadeOut(500);
        $('#advertTitle').val('');
        $('#advertMessage').val('');
        setTimeout(function() {
            from = "newAdvertisementPost";
            to = "advertisementsDiv"
            $('#newAdvertisementPost').fadeIn(500);
        }, 501)
    });

    $(document).on('click','[data-act=newContact]',function(){
        $('#contactsDiv').fadeOut(500);
        setTimeout(function() {
            from = "newContactDiv";
            to = "contactsDiv"
            $('#newContactDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','#raceBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            from = "racesDiv";
            to = "mainMenu"
            $('#racesDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','#activeRaceBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "activeRace" }));
        }, 501)
    });

    $(document).on('click','[data-act=newRaceEvent]',function(){
        $('#racesDiv').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "createRace" }));
        }, 501)
    });

    $(document).on('click','[data-act=newRaceTrack]',function(){
        $('#racesDiv').fadeOut(500);
        setTimeout(function() {
            createTrack(1);
        }, 501)
    });
    
    $(document).on('click','[data-act=manageTracks]',function(){
        $('#racesDiv').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "manageTracks" }));
        }, 501)
    });
    
    $(document).on('click','[data-act=clearRecords]',function(){
        $('#manageRacesDiv').fadeOut(500);
        var trackId = $(this).data('track');
        $('[data-atoggle="tooltip"]').tooltip('dispose');
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "clearRecords", tId: trackId }));
        setTimeout(function() {    
            from = "racesDiv";
            to = "mainMenu"
            $('#racesDiv').fadeIn(500);
        }, 501)
    });
    
    $(document).on('click','[data-act=deleteTrack]',function(){
        $('#manageRacesDiv').fadeOut(500);
        var trackId = $(this).data('track');
        $('[data-atoggle="tooltip"]').tooltip('dispose');
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "deleteTrack", tId: trackId }));
        setTimeout(function() {    
            from = "racesDiv";
            to = "mainMenu"
            $('#racesDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','[data-act=pickedRace]',function(){
        $('#newRacesDiv').fadeOut(500);
        var raceInfo = $(this).data('raceInfo');
        setTimeout(function() {
            loadStartRaceSettings(raceInfo);
        }, 501)
    });

    $(document).on('click','[data-act=nextStepTrack]',function(){
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "chooseTrackStart", raceName: $('#raceName').val(), raceType: $('#raceTypes').val(), maxContestants: $('#newTrackLaps').val() }));
            closePhone();
        }, 501)
    });

    $(document).on('click','[data-act=raceSet]',function(){
        var raceInfo = $(this).data('raceInfo');
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "startRace", raceId: raceInfo.tblIndex, laps: $('#laps-value').html(), contestants: $('#contestants-value').html(), delay: $('#delay-value').html().replace(' seconds','') }));
            closePhone();
        }, 501)
    });

    $(document).on('click','[data-act=changePosition]',function(){
        if(!$(this).hasClass('disabled')) {
            var contestantId = $(this).data('contestant');
            var curPosition = $(this).data('curposition');
            var toPosition = $(this).data('toposition');

            $('[data-toggle="tooltip"]').tooltip('dispose');
            $('[data-tooltip="tooltip"]').tooltip('dispose');
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "changePole", cId: contestantId, curPos: curPosition, newPos: toPosition }));

        }
    });

    $(document).on('click','[data-act=cancelRace]',function(){
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "cancelRace" }));
            closePhone();
        }, 501)
    });

    $(document).on('click','[data-act=startRace]',function(){
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "fookingGo" }));
            closePhone();
        }, 501)
    });

    $(document).on('click','[data-act=joinRace]',function(){
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "joinRace" }));
            closePhone();
        }, 501)
    });

    $(document).on('click','[data-act=checkContestants]',function(){
        var contestants = $(this).data('contestantsTable');
        $('#activeRaceDiv').fadeOut(500)
        setTimeout(function() {
            loadContestants(contestants);
        }, 501)
    });

    $(document).on('click','#foodDeliveryAppBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            from = "foodDeliveryDiv";
            to = "mainMenu"
            $('#foodDeliveryDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','[data-act=startNewFoodJob]',function(){
        $('[data-act=startNewFoodJob]').fadeOut(500);
        $.post('http://pw_phone/requestData', JSON.stringify({ request: "startNewFoodJob" }));
    });

    $(document).on('click','[data-act=cancelOldFoodJob]',function(){
        $('[data-act=cancelOldFoodJob]').fadeOut(500);
        $.post('http://pw_phone/requestData', JSON.stringify({ request: "cancelOldFoodJob" }));
    });

    $(document).on('click','#silentMode',function(){
        $.post('http://pw_phone/silentMode', JSON.stringify({}));
    });

    $(document).on('click','#phoneCallsBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            from = "phoneCallsDiv";
            to = "mainMenu"
            $('#phoneCallsDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','#advertisementBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "advertisements" }));
        }, 501)
    });

    $(document).on('click','[data-act=callPhone]',function(){
        var dialNumber = $(this).data('number');
        if(dialNumber !== undefined && dialNumber !== null && parseInt(dialNumber) > 0) {
            from = 'contactsDiv';
            $('#contactsDiv').fadeOut(500);
        } else {
            from = 'phoneCallsDiv';
            $('#phoneCallsDiv').fadeOut(500);
            dialNumber = $('#dialNumber').val();
        }

        if(parseInt(dialNumber) > 0) {
            setTimeout(function() {
                $('#connectingCall').fadeIn(500)
                from = 'connectingCall';
                setTimeout(function() {
                    $.post('http://pw_phone/sendData', JSON.stringify({ request: "startCall", number: number, tonumber: dialNumber }));
                }, 501)
            }, 501);
        } else {
            $('#'+from).fadeIn(500)
        }
    });
    
    $(document).on('click','[data-act=postAdvert]',function(){
        var advertTitle = $('#advertTitle').val();
        var advertMessage = $('#advertMessage').val();
        if(advertMessage !== undefined && advertMessage !== null && advertMessage !== "" && advertTitle !== undefined && advertTitle !== null && advertTitle !== "") {
            $('#advertMessage').removeClass('is-invalid');
            $('#advertTitle').removeClass('is-invalid');
            $('#newAdvertisementPost').fadeOut(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "postAdvert", title: advertTitle, message: advertMessage }));
            setTimeout(function() {
                $('#advertTitle').val('');
                $('#advertMessage').val('');
                $('#successMessageYes').html('Your advertisement has been posted.');
                $('#successMessage').fadeIn(500);
                from = null;
                to = null
                setTimeout(function() {
                    $('#successMessage').fadeOut(500);
                    setTimeout(function() {
                        $('#successMessageYes').html('');
                        $.post('http://pw_phone/requestData', JSON.stringify({ request: "advertisements" }));
                    }, 500)
                }, 2300)                
            }, 501)
        } else {
            if(advertMessage == undefined || advertMessage == null || advertMessage == "") {
                $('#advertMessage').addClass('is-invalid');
            } else {
                $('#advertMessage').removeClass('is-invalid');
            }
            if(advertTitle == undefined || advertTitle == null || advertTitle == "") {
                $('#advertTitle').addClass('is-invalid');
            } else {
                $('#advertTitle').removeClass('is-invalid');
            }
        }
    });
    
    $(document).on('click','#sendTextReponse',function(){
        var convoid = $(this).data('convoid');
        var toNum = $(this).data('to');
        var fromNum = $(this).data('from');
        var message = $('#messageReponse').val();
        if(message !== undefined && message !== null && message !== "") {
            $('#messageReponse').removeClass('is-invalid');
            $('#conversationDiv').fadeOut(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "sendTextMessageReply", number: number, tonumber: toNum, fromnumber: fromNum, message: message, convoid: convoid }));
            setTimeout(function() {
                $('#messageReponse').val('');
                $.post('http://pw_phone/requestData', JSON.stringify({ request: "loadConvo", number: number, convoid: convoid }));
            }, 501)
        } else {
            $('#messageReponse').addClass('is-invalid');
        }
    });

    $(document).on('click','#textMessagesBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "conversations", number: number }));
        }, 501)
    });

    $(document).on('click','[data-act=newMessage]',function(){
        $('#textMessagesDiv').fadeOut(500);
        $('#newMessageNumberError').fadeOut(1);
        $('#newMessageMessageError').fadeOut(1);
        $('#newMessageNumberError').html('');
        $('#newMessageMessageError').html('');
        $('#newMessageNumberTo').val('');
        $('#newMessageNumberContent').val('');
        $('#newMessageNumberTo').removeClass('is-invalid');
        $('#newMessageNumberContent').removeClass('is-invalid');
        setTimeout(function() {
            from = "newMessageDiv";
            to = "textMessagesDiv"
            $('#newMessageDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','[data-act=sendText]',function(){
        var toNumber = $(this).data('number');
        $('#contactsDiv').fadeOut(500);
        $('#newMessageNumberTo').val(toNumber);
        $('#newMessageNumberContent').val('');
        setTimeout(function() {
            from = "newMessageDiv";
            to = "contactsDiv"
            $('#newMessageDiv').fadeIn(500);
        }, 501)
    });

    $(document).on('click','[data-act=loadConversation]',function(){
        $('#' + from).fadeOut(500);
        var convoid = $(this).data('convoid')
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "loadConvo", number: number, convoid: convoid }));
        }, 501)
    });

    $(document).on('click','#emailBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailInbox" }));
        }, 501)
    });

    $(document).on('click','#twitterBtn',function(){
        $('#mainMenu').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "twitterHome" }));
        }, 501)
    });

    $(document).on('click','[data-act=postNewTweet]',function(){
        var tweetText = $('#newTweetText').val();
        if(tweetText !== undefined && tweetText !== null && tweetText !== "") {
            $('#newTweetText').removeClass('is-invalid');
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "postNewTweet", tweet: tweetText }));
            setTimeout(function() {
                $.post('http://pw_phone/requestData', JSON.stringify({ request: "refreshTweets" }));
            }, 501)
        } else {
            $('#newTweetText').addClass('is-invalid');
        }
    });

    $(document).on('click','[data-act=twitterHome]',function(){
        $.post('http://pw_phone/requestData', JSON.stringify({ request: "refreshTweets" }));
    });

    $(document).on('click','[data-act=postReplyTweet]',function(){
        var tweetText = $('#replyTweetText').val();
        var tweetId = $('#replyTweetText').data('tweet');
        if(tweetText !== undefined && tweetText !== null && tweetText !== "") {
            if(tweetId !== undefined && tweetId !== null) {
                $('#replyTweetText').removeClass('is-invalid');
                $.post('http://pw_phone/sendData', JSON.stringify({ request: "postTweetReply", tweet: tweetText, tweetid: tweetId }));
                setTimeout(function() {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "refreshTweet", tweetId: tweetId }));
                }, 501)
            }
        } else {
            $('#replyTweetText').addClass('is-invalid');
        }
    });

    $(document).on('click','[data-act=viewTweet]',function(){
        var tweetId = $(this).data('tweet')
        if(tweetId !== undefined && tweetId !== null) {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "requestTweet", tweetId: tweetId }));
        }
    });

    $(document).on('click','[data-act=loveTweet]',function(){
        var tweetId = $(this).data('tweet')
        var tfrm = $(this).data('from');
        if(tweetId !== undefined && tweetId !== null) {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "submitHeart", tweetid: tweetId }));
            setTimeout(function() {
                if(tfrm == "homepage") {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "refreshTweets" }));
                } else {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "refreshTweet", tweetId: tweetId }));
                }
            }, 501)
        }
    });
    
    $(document).on('click','[data-act=sentEmailsBox]',function(){
        $('#emailInboxDiv').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailSent" }));
        }, 501)
    });

    $(document).on('click','[data-act=gotoInboxEmail]',function(){
        $('#emailSentDiv').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailInbox" }));
        }, 501)
    });

    $(document).on('click','[data-act=deleteMessage]',function(){
        var messageid = $(this).data('messageid');
        var convoid = $(this).data('convoid');
        $('#conversationDiv').fadeOut(500);
        setTimeout(function() {
            $('#deletedMessageYes').html('Message has been deleted.');
            $('#deletedMessage').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "deleteMessage", number: number, messageid: messageid }));
            setTimeout(function() {
                $('#deletedMessage').fadeOut(500);
                setTimeout(function() {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "loadConvo", number: number, convoid: convoid }));
                    $('#deletedMessageYes').html('');
                }, 501)
            }, 2300)
        }, 501)
    });

    $(document).on('click','[data-act=deleteEmail]',function(){
        var emailid = $(this).data('email');
        var emailType = $(this).data('emailtype');
        if(emailType == "inbox") {
            $('#emailInboxDiv').fadeOut(500);
        } else {
            $('#emailSentDiv').fadeOut(500);
        }
        setTimeout(function() {
            $('#deletedMessageYes').html('Email has been deleted.');
            $('#deletedMessage').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "deleteEmail", emailid: emailid, emailtype: emailType }));
            setTimeout(function() {
                $('#deletedMessage').fadeOut(500);
                setTimeout(function() {
                    if(emailType == "inbox") {
                        $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailInbox" }));
                    } else {
                        $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailSent" }));
                    }
                }, 501)
            }, 2300)
        }, 501)
    });

    $(document).on('click','[data-act=viewEmail]',function(){
        var emailid = $(this).data('email');
        var emailType = $(this).data('emailtype');
        if(emailType == "inbox") {
            $('#emailInboxDiv').fadeOut(500);
        } else {
            $('#emailSentDiv').fadeOut(500);
        }
        setTimeout(function() {
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "viewEmail", emailid: emailid, emailtype: emailType }));
        }, 501)
    });


    $(document).on('click','[data-act=sendNewEmailBtn]',function(){
        var toEmail = $('#newEmailTo').val();
        var toSubject = $('#newEmailSubject').val();
        var toContent = $('#newEmailContent').val();
        if(toEmail !== undefined && toEmail !== null && toEmail !== "" && toSubject !== undefined && toSubject !== null && toSubject !== "" && toContent !== undefined && toContent !== null && toContent !== "") {
            $('#newEmailTo').removeClass('is-invalid');
            $('#newEmailSubject').removeClass('is-invalid');
            $('#newEmanewEmailContentilSubject').removeClass('is-invalid');
            $('#createEmailDiv').fadeOut(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "sendEmail", to: toEmail, subject: toSubject, content: toContent }));
            setTimeout(function() {
                $('#newEmailTo').val('');
                $('#newEmailSubject').val('');
                $('#newEmailContent').val('');
                $('#successMessageYes').html('Your Email has been sent successfully.');
                $('#successMessage').fadeIn(500);
                from = null;
                to = null
                setTimeout(function() {
                    $('#successMessage').fadeOut(500);
                    setTimeout(function() {
                        $('#successMessageYes').html('');
                        $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailSent" }));
                    }, 501)
                }, 2300)                
            }, 501)
        } else {
            if(toEmail == undefined || toEmail == null || toEmail == "") {
                $('#newEmailTo').addClass('is-invalid');
            } else {
                $('#newEmailTo').removeClass('is-invalid');
            }
            if(toSubject == undefined || toSubject == null || toSubject == "") {
                $('#newEmailSubject').addClass('is-invalid');
            } else {
                $('#newEmailSubject').removeClass('is-invalid');
            }
            if(toContent == undefined || toContent == null || toContent == "") {
                $('#newEmailContent').addClass('is-invalid');
            } else {
                $('#newEmailContent').removeClass('is-invalid');
            }
        }
    });

    

    $(document).on('click','[data-act=newEmailMessage]',function(){
        $('#' + from).fadeOut(500);
        $('#newEmailTo').val('');
        $('#newEmailSubject').val('');
        $('#newEmailContent').val('');
        var toEmail = $(this).data('emailTo');
        if(toEmail !== undefined && toEmail !==null && toEmail !== "") {
            $('#newEmailTo').val(toEmail);
        }
        setTimeout(function() {
            from = "createEmailDiv";
            var toReturn = $(this).data('to');
            if (toReturn !== undefined && toReturn !== null) {
                to = toReturn;
            } else {
                to = "emailInboxDiv";
            }
            $('#createEmailDiv').fadeIn(500)
        }, 501)
    });

    $(document).on('click','[data-act=deleteMyAdvert]',function(){
        var advertid = $(this).data('adid');
        $('#advertisementsDiv').fadeOut(500);
        setTimeout(function() {
            $('#deletedMessageYes').html('Your Advert has been deleted.');
            $('#deletedMessage').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "deleteAdvert", advertid: advertid }));
            setTimeout(function() {
                $('#deletedMessage').fadeOut(500);
                setTimeout(function() {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "advertisements"}));
                    $('#deletedMessageYes').html('');
                }, 501)
            }, 2300)
        }, 501)
    });


    $(document).on('click','[data-act=deleteConversation]',function(){
        var convoid = $(this).data('convoid');
        $('#textMessagesDiv').fadeOut(500);
        setTimeout(function() {
            $('#deletedMessageYes').html('Conversation has been deleted.');
            $('#deletedMessage').fadeIn(500);
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "deleteConvo", number: number, convoid: convoid }));
            setTimeout(function() {
                $('#deletedMessage').fadeOut(500);
                setTimeout(function() {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "conversations", number: number }));
                    $('#deletedMessageYes').html('');
                }, 501)
            }, 2300)
        }, 501)
    });

    $(document).on('click','#propertySalesBtn',function(){
        if(currentCoords !== null) {
            $('[data-toggle="tooltip"]').tooltip('hide');
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "nearbyPropertys", ret: "forSale", coords: currentCoords }));
        }
    });

    $(document).on('click','#propertyRentalsBtn',function(){
        if(currentCoords !== null) {
            $('[data-toggle="tooltip"]').tooltip('hide');
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "nearbyPropertys", ret: "forRent", coords: currentCoords }));
        }
    });

    $(document).on('click','[data-act=sellProperty]',function(){
        if(currentCoords !== null) {
            $('[data-toggle="tooltip"]').tooltip('hide');
            var house = $(this).data('house')
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "getNearbyPlayers", req: "forSale", coords: currentCoords, house: parseInt(house) }));
        }
    });

    $(document).on('click','[data-act=rentProperty]',function(){
        if(currentCoords !== null) {
            $('[data-toggle="tooltip"]').tooltip('hide');
            var house = $(this).data('house')
            $.post('http://pw_phone/requestData', JSON.stringify({ request: "getNearbyPlayers", req: "forRent", coords: currentCoords, house: parseInt(house) }));
        }
    });

    $(document).on('click','#propertiesBtn',function(){
        $.post('http://pw_phone/requestData', JSON.stringify({ request: "myProperties"}));
    });

    $(document).on('click','[data-act=acceptCall]',function(){
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "callAccepted", number: number }));
    });

    $(document).on('click','[data-act=rejectCall]',function(){
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "callRejected", number: number }));
    });

    $(document).on('click','[data-act=cancelCall]',function(){
        console.log('call cancelled');
    });

    $(document).on('click','[data-act=terminateCall]',function(){
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "terminateCall", number: number, with: callWith }));
    });

    $(document).on('click','[data-act=processPropertySale]',function(){
        $('[data-toggle="tooltip"]').tooltip('hide');
        var playerSrc = $(this).data('source');
        var playerCID = $(this).data('cid');
        var playerUID = $(this).data('uid');
        var houseID = $(this).data('house');
        var method = $(this).data('method');
        $('#retailPropertysDiv').fadeOut(500);
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "processPropertySale", playerSrc: parseInt(playerSrc), playerCID: parseInt(playerCID), playerUID: parseInt(playerUID), houseID: parseInt(houseID), sellMethod: method }));
            from = null;
            to = null;
            setTimeout(function() {
            $('#retMyPropertiesContent').html('');
            $('#mainMenu').fadeIn(500);
            }, 200);
        }, 501)
    });

    $(document).on('click','[data-act=propertySettings]',function(){
        $('[data-toggle="tooltip"]').tooltip('hide');
        var house = $(this).data('house');
        closePhone();
        setTimeout(function() {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "propertySettings", house: house }));
        }, 1000)
        $('[data-toggle="tooltip"]').tooltip();
    });

    $(document).on('click','[data-act=retailLock]',function(){
        $('[data-toggle="tooltip"]').tooltip('hide');
        var house = $(this).data('house');
        $('#lockStatus-'+ house).html('<i data-toggle="tooltip" data-placement="top" title="Unlock Property" class="fad fa-key fa-2x text-danger" data-act="retailUnlock" data-house="' + house + '"></i>')
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "togglePropertyLock", house: house }));
        $('[data-toggle="tooltip"]').tooltip();
    });

    $(document).on('click','[data-act=retailUnlock]',function(){
        $('[data-toggle="tooltip"]').tooltip('hide');
        var house = $(this).data('house');
        $('#lockStatus-'+ house).html('<i data-toggle="tooltip" data-placement="top" title="Lock Property" class="fad fa-key fa-2x text-success" data-act="retailLock" data-house="' + house + '"></i>')
        $.post('http://pw_phone/sendData', JSON.stringify({ request: "togglePropertyLock", house: house }));
        $('[data-toggle="tooltip"]').tooltip();
    });

    $(document).on('click','[data-act=propertyGPS], [data-act=setEmailWaypoint]',function(){
        var x = $(this).data('x')
        var y = $(this).data('y')
        $.post('http://pw_phone/setWaypoint', JSON.stringify({ x: x, y: y }));
    });

    $(document).on('click','[data-act=sendNewMessage]',function(){
        var toNumber = $('#newMessageNumberTo').val();
        var toMessage = $('#newMessageNumberContent').val();

        if(toNumber !== undefined && toNumber !== null && toNumber !== "" && parseInt(toNumber) !== number && toMessage !== undefined && toMessage !== null && toMessage !== "") {
            $.post('http://pw_phone/sendData', JSON.stringify({ request: "sendTextMessage", number: number, tonumber: toNumber, message: toMessage }));

            $('#newMessageDiv').fadeOut(500);
            setTimeout(function() {
                $('#successMessageYes').html('Your message has been sent.');
                $('#successMessage').fadeIn(500);
                from = null;
                to = null
                setTimeout(function() {
                    $('#successMessage').fadeOut(500);
                    setTimeout(function() {
                        $('#successMessageYes').html('');
                        $('#newMessageNumberTo').val('');
                        $('#newMessageNumberContent').val('');
                        $.post('http://pw_phone/requestData', JSON.stringify({ request: "conversations", number: number }));
                    }, 501)
                }, 2300)
            }, 501)
        } else {
            if(toNumber == undefined || toNumber == null || toNumber == "" || parseInt(toNumber) == number) {
                $('#newMessageNumberTo').addClass('is-invalid');
                if(parseInt(toNumber) == number) {
                    $('#newMessageNumberError').html('Can not send to yourself.');
                } else {
                    $('#newMessageNumberError').html('Invalid Number');
                }
                $('#newMessageNumberError').fadeIn(500);
            } else {
                $('#newMessageNumberError').fadeOut(500);
                $('#newMessageNumberTo').removeClass('is-invalid');
            }
            if(toMessage == undefined || toMessage == null || toMessage == "") {
                $('#newMessageNumberContent').addClass('is-invalid');
                $('#newMessageMessageError').html('Invalid Message');
                $('#newMessageMessageError').fadeIn(500);
            } else {
                $('#newMessageNumberContent').removeClass('is-invalid');
                $('#newMessageMessageError').fadeOut(500);
            }
        }
    });

    $(document).on('click','#backButton',function(){
        if(to !== undefined && to !== null && from !== undefined && from !== null) {
            $('#' + from).fadeOut(500);
            setTimeout(function() {
                if(to == "contactsDiv") {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "contacts", number: number }));
                } else if(to =="textMessagesDiv") {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "conversations", number: number }));
                } else if(to =="emailInboxDiv") {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailInbox" }));
                } else if(to =="emailSentDiv") {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "emailSent" }));
                } else if(to =="advertisementsDiv") {
                    $.post('http://pw_phone/requestData', JSON.stringify({ request: "advertisements" }));
                } else {
                    $('#' + to).fadeIn(500);
                }
            }, 501)
        }
    });

    $(document).on('click','#mainMenuBtn',function(){
        if(from !== undefined && from !== null) {
            $('#' + from).fadeOut(500);
            setTimeout(function() {
                if(simcardActive === false) {
                    $('#noSimcard').fadeIn(500);
                } else {
                    $('#mainMenu').fadeIn(500);
                }
            }, 501)
        }
    });

    $(document).on('click','[data-act=setRadioChannel]' ,function(){
        var requestedChannel = $('#radioChannel').val();
        if(requestedChannel !== undefined && requestedChannel !== null && requestedChannel !== "" && parseInt(requestedChannel) > 0 && parseInt(requestedChannel) < 1000) {
            if(currentRadioChannel !== undefined && currentRadioChannel !== null) {
                $.post('http://pw_phone/setRadioChannel', JSON.stringify({ toggle: false, channel: parseInt(currentRadioChannel) }));
            }
            $('#radioChannel').removeClass('is-invalid');
            currentRadioChannel = requestedChannel;
            currentlyInRadio = true;
            $.post('http://pw_phone/setRadioChannel', JSON.stringify({ toggle: true, channel: parseInt(requestedChannel) }));
        } else {    
            $('#radioChannel').addClass('is-invalid');
        }
    });

    $(document).on('click','[data-act=toggleRadioOnOff]' ,function(){
        if(currentlyInRadio === true) {
            $.post('http://pw_phone/setRadioChannel', JSON.stringify({ toggle: false, channel: parseInt(currentRadioChannel) }));
            currentlyInRadio = false;
        } else if(currentlyInRadio === false) {
            $.post('http://pw_phone/setRadioChannel', JSON.stringify({ toggle: true, channel: parseInt(currentRadioChannel) }));
            currentlyInRadio = true;
        }
    });

    $(document).on('click','[data-act=clearRadioChannel]' ,function(){
            $.post('http://pw_phone/setRadioChannel', JSON.stringify({ toggle: false, channel: parseInt(currentRadioChannel) }));
            currentlyInRadio = false;
            currentRadioChannel = null;
            $('#radioChannel').val('');
    });

    $(document).on('click','[data-act=toggleRadioClicks]' ,function(){
        if(radioClicks === false) {
            $.post('http://pw_phone/toggleRadioClicks', JSON.stringify({ toggle: true }));
            radioClicks = true;
        } else {
            $.post('http://pw_phone/toggleRadioClicks', JSON.stringify({ toggle: false }));
            radioClicks = false;
        }
        console.log(radioClicks)
    });
    
});

processessSignal();