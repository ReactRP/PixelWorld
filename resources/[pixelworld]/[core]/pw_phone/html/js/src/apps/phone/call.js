import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';

// TODO : Need To Verify Flow Works As It Should Once Back-End Communication Is Setup
var contacts = null;

var callPending = null;
var activeCallTimer = null;
var activeCallDigits = new Object();

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'receiveCall':
            console.log('receiving call');
            App.OpenApp(
                'phone-call',
                { number: event.data.number, receiver: true },
                false
            );
            break;
        case 'acceptCallSender':
            CallAnswered();
            break;
        case 'acceptCallReceiver':
            CallAnswered();
            break;
        case 'endCall':
            CallHungUp();
            break;
    }
});

$('#screen-content').on('click', '.call-action-mutesound', (e) => {
    $.post(Config.ROOT_ADDRESS + '/ToggleHold', JSON.stringify({}), (status) => {
        if (status) {
            $('.call-action-mutesound').html(`<i class="fas fa-volume-up"></i><span>Unmute</span>`);
        } else {
            $('.call-action-mutesound').html(`<i class="fas fa-volume-mute"></i><span>Mute</span>`);
        }
    });
});

$('#screen-content').on('click', '#end-call', (e) => {
    $.post(Config.ROOT_ADDRESS + '/EndCall', JSON.stringify());
});

$('#screen-content').on('click', '#answer-call', (e) => {
    $.post(Config.ROOT_ADDRESS + '/AcceptCall', JSON.stringify({}));
});

function CallAnswered() {
    clearInterval(callPending);
    $('.call-avatar')
        .addClass('call-connected')
        .removeClass('call-pending');

    $('.phone-header').removeClass('in-call');

    if (activeCallTimer == null) {
        activeCallDigits.seconds = 0;
        activeCallDigits.minutes = 0;
        activeCallDigits.hours = 0;

        activeCallTimer = setInterval(function() {
            if (activeCallDigits.seconds < 59) {
                activeCallDigits.seconds++;
            } else if (activeCallDigits.minutes < 60) {
                activeCallDigits.seconds = 0;
                activeCallDigits.minutes++;
            } else {
                activeCallDigits.seconds = 0;
                activeCallDigits.minutes = 0;
                activeCallDigits.hours++;
            }

            let sec = activeCallDigits.seconds;
            let min = activeCallDigits.minutes;

            if (sec < 10) {
                sec = '0' + sec;
            }
            if (min < 10) {
                min = '0' + min;
            }

            $('.call-number .call-timer').html(
                activeCallDigits.hours + ':' + min + ':' + sec
            );

            $('.phone-header .in-call').html(
                `<i class="fas fa-phone"></i> ${activeCallDigits.hours}:${min}:${sec}`
            );
        }, 1000);

        $('.phone-header .in-call').fadeOut();
    }
}

function CallHungUp() {
    $('.call-number .call-timer').html('ENDED');

    clearInterval(activeCallTimer);
    clearInterval(callPending);
    activeCallTimer = null;
    callPending = null;

    $('.call-avatar')
        .addClass('call-disconnected')
        .removeClass('call-connected')
        .removeClass('call-pending');

    $('.phone-header').attr('class', 'phone-header');
    $('.phone-header .in-call').fadeOut('fast', () => {
        $('.phone-header .in-call').html(`<i class="fas fa-phone"></i>`);
    });

    setTimeout(function() {
        $('.call-number .call-timer').html('Calling');
        $('.call-avatar').attr('class', 'call-avatar');

        if (App.GetCurrentApp() == 'phone-call') {
            App.GoBack();
            setTimeout(function() {
                $('#phone-call-container').attr('class', 'app-container');
            }, 500);
        }
    }, 2500);
}

function IsCallPending() {
    return callPending != null || activeCallTimer != null;
}

window.addEventListener('phone-call-open-app', (data) => {
    console.log('doing this shit?');
    console.log(JSON.stringify(data.detail));
    if (activeCallTimer != null || data.detail == null) {
        CallAnswered();
        return;
    }
    contacts = Data.GetData('contacts');

    if (!data.detail.receiver) {
        $('.call-button#answer-call').hide();
        $('#phone-call-container').data('data', data.detail);

        let contact = contacts.filter(c => c.number == data.detail.number)[0];

        if (contact != null) {
            $('#phone-call-container').addClass(
                'other-' + contact.name[0].toString().toLowerCase()
            );
            $('.call-number .call-number-text').html(contact.name);
            $('.call-number .call-subnumber').html(contact.number);
            $('.call-header .call-avatar').html(contact.name[0]);
        } else {
            $('.call-number .call-number-text').html(data.detail.number);
            $('.call-number .call-subnumber').html('');
            $('.call-header .call-avatar').html('#');
        }

        $('.call-avatar').addClass('call-pending');

        let dots = '';
        clearInterval(callPending);
        callPending = setInterval(function() {
            if (dots === '...') {
                dots = '';
            } else {
                dots = dots + '.';
            }

            $('.call-number .call-timer').html('Calling ' + dots);
        }, 500);
    } else {
        $('.call-button#answer-call').show();
        $('#phone-call-container').data('data', data.detail);

        let contact = contacts.filter(c => c.number == data.detail.number)[0];

        if (contact != null) {
            $('#phone-call-container').addClass(
                'other-' + contact.name[0].toString().toLowerCase()
            );
            $('.call-number .call-number-text').html(contact.name);
            $('.call-number .call-subnumber').html(contact.number);
            $('.call-header .call-avatar').html(contact.name[0]);
        } else {
            $('.call-number .call-number-text').html(data.detail.number);
            $('.call-number .call-subnumber').html('');
            $('.call-header .call-avatar').html('#');
        }

        $('.call-avatar').addClass('call-pending');

        let dots = '';
        clearInterval(callPending);
        callPending = setInterval(function() {
            if (dots === '...') {
                dots = '';
            } else {
                dots = dots + '.';
            }

            $('.call-number .call-timer').html('Incoming ' + dots);
        }, 500);
    }
});

window.addEventListener('phone-call-close-app', () => {
    if (activeCallTimer != null) {
        $('.phone-header').addClass('in-call');
        $('.phone-header .in-call').fadeIn();
        return;
    }

    /*if (callPending != null && is`C`allActive == null) {
        $.post(Config.ROOT_ADDRESS + '/CancelCall', JSON.stringify({
            
        }));
    } */

    contacts = null;

    clearInterval(callPending);
    callPending = null;

    $('#phone-call-container').attr('class', 'app-container');
    $('.call-avatar').attr('class', 'call-avatar');
    $('.call-number .call-timer').html('Calling');
    $('#phone-call-container').removeData('data');
    $('.call-number .call-number-text').html('');
    $('.call-number .call-subnumber').html('');

    $('.call-action-mutemic').html(
        `<i class="fas fa-microphone-slash"></i><span>Mute Mic</span>`
    );
    $('.call-action-mutesound').html(
        `<i class="fas fa-volume-mute"></i><span>Mute Sound</span>`
    );
});

export default { IsCallPending, CallAnswered, CallHungUp };