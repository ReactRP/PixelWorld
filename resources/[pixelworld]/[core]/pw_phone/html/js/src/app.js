import Config from './util/config';
import Data from './util/data';
import Utils from './util/utils';
import Apps from './apps/apps';
import Notif from './util/notification';


// CSS Compilers
import '../../css/src/materialize.scss';
import '../../css/src/style.scss';

var phoneOpen = false

var appTrail = [
    {
        app: null,
        data: null,
        fade: null
    }
];

moment.fn.fromNowOrNow = function(a) {
    if (Math.abs(moment().diff(this)) < 60000) {
        return 'just now';
    }
    return this.fromNow(a);
};

function InitShit() {
    $('.modal').modal();
    $('.dropdown-trigger').dropdown({
        constrainWidth: false
    });
    $('.tabs').tabs();
    //$('select').formSelect();
    $('.char-count-input').characterCounter();
    $('.phone-number').mask('000-000-0000', { placeholder: '###-###-####' });
}

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'show':
            $('.wrapper').show('slide', { direction: 'down' }, 500);
            OpenApp('home', null, true);
            setTimeout(function(){
                phoneOpen = true;
            }, 501)
            break;
        case 'hide':
            ClosePhone();
            break;
        case 'SetServerID':
            $('.player-id span').html(event.data.id);
            break;
    }
});


function ClosePhone() {
    $.post(Config.ROOT_ADDRESS + '/ClosePhone', JSON.stringify({}));
    phoneOpen = false;
    $('.wrapper').hide('slide', { direction: 'down' }, 500, () => {  
        //$('#screen-content').trigger(`${appTrail[appTrail.length - 1].app}-close-app`);
        $('#toast-container').remove();
        $('.material-tooltip').remove();
        $('.app-container').hide();
        appTrail = [
            {
                app: null,
                data: null,
                fade: null
            }
        ];
    });
}

window.addEventListener('custom-close-finish', (data) => {
    if (data.detail.disableFade) {
        SetupApp(data.detail.app, data.detail.data, data.detail.pop, data.detail.disableFade, data.detail.customExit);
    } else {
        $('#screen-content').fadeOut('fast', () => {
            SetupApp(data.detail.app, data.detail.data, data.detail.pop, data.detail.disableFade, data.detail.customExit);
        });
    }
});

$('.mute').on('click', (e) => {
    let volume = Data.GetData('settings').volume;
    
    $.post(Config.ROOT_ADDRESS + '/ToggleMute', JSON.stringify({
        muted: volume === 0 ? false : true
    }), (status) => {
        if (status) {
            Data.UpdateData('settings', 'volume', volume === 0 ? 100 : 0);
            Utils.SetMute(volume !== 0);
        }
    });
});

$('.phone').on('click', '.close-button', (e) => {
    ClosePhone();
});

$('.phone').on('click', '.back-button', (event) => {
    if (!$(event.currentTarget).hasClass('disabled')) {
        $('.footer-button').addClass('disabled');
        GoBack();
    }
});

$('.phone').on('click', '.home-button', (event) => {
    if (!$(event.currentTarget).hasClass('disabled')) {
        $('.footer-button').addClass('disabled');
        GoHome();
    }
});

$(function() {
    let settings = Data.GetData('settings');

    Utils.UpdateWallpaper(`url(./imgs/back00${settings.wallpaper}.png)`);
    Utils.SetMute(settings.volume === 0);
    
    document.onkeyup = function(data) {
        if (phoneOpen) {
            if (data.which == 112 || data.which == 27) {
                ClosePhone();
            }
        }
    };
});

function RefreshApp() {
    $('.material-tooltip').remove();
    $('#screen-content').trigger(`${appTrail[appTrail.length - 1].app}-open-app`, [ appTrail[appTrail.length - 1].data ]);
}

function GoHome() {
    if (appTrail[appTrail.length - 1].app !== 'home') {
        OpenApp('home');
    }
}

function GoBack() {
    if (appTrail[appTrail.length - 1].app !== 'home') {
        if (appTrail.length > 1) {
            OpenApp(
                appTrail[appTrail.length - 2].app,
                appTrail[appTrail.length - 2].data,
                true,
                appTrail[appTrail.length - 1].fade,
                appTrail[appTrail.length - 2].close
            );
            console.log(appTrail[appTrail.length - 2].app)
            console.log(appTrail[appTrail.length - 2].data)
            console.log(appTrail[appTrail.length - 1].fade)
            console.log(appTrail[appTrail.length - 2].close)
        } else {
            GoHome();
        }
    }
}

function GetCurrentApp() {
    return appTrail[appTrail.length - 1].app;
}

function SetupApp(app, data, pop, disableFade, exit) {
    $.ajax({
        url: `./html/apps/${app}.html`,
        cache: false,
        dataType: "html",
        statusCode: {
            404: function() {
                appTrail.push({ app: app, data: null, fade: false, close: exit });
                Notif.Alert('App Doesn\'t Exist', 1000);
                GoHome();
                $('.footer-button').removeClass('disabled');
            }
        },
        success: function(response) {
            $('#screen-content').html(response);
            InitShit();
        
            window.dispatchEvent(new CustomEvent(`${appTrail[appTrail.length - 1].app}-close-app`));
            if (pop) {
                appTrail.pop();
                disableFade = null;
                appTrail.pop();
            }
        
            appTrail.push({
                app: app,
                data: data,
                fade: disableFade,
                close: exit
            });
        
            $('.material-tooltip').remove();
            window.dispatchEvent(new CustomEvent(`remove-closed-notif`, { detail: { app: app }}));
            window.dispatchEvent(new CustomEvent(`${app}-open-app`, { detail: data }));
            
            $('#screen-content').show();
            $('.footer-button').removeClass('disabled');
        }
    });
}

function OpenApp(app, data = null, pop = false, disableFade = false, customExit = false) {
    if ($('#screen-content .app-container').length <= 0 || disableFade) {
        if (appTrail[appTrail.length - 1].close) {
            console.log(`${appTrail[appTrail.length - 1].app}-custom-close-app`)
            window.dispatchEvent(new CustomEvent(`${appTrail[appTrail.length - 1].app}-custom-close-app`, { detail: { app: app, data: data, pop: pop, disableFade: disableFade, customExit: customExit } }));
        } else {
            SetupApp(app, data, pop, disableFade, customExit);
        }
        
    } else {
        if (appTrail[appTrail.length - 1].close) {
            console.log(`${appTrail[appTrail.length - 1].app}-custom-close-app`)
            window.dispatchEvent(new CustomEvent(`${appTrail[appTrail.length - 1].app}-custom-close-app`, { detail: { app: app, data: data, pop: pop, disableFade: disableFade, customExit: customExit } }));
        } else {
            $('#screen-content').fadeOut('fast', () => {
                SetupApp(app, data, pop, disableFade, customExit);
            });
        }
    }
}

export default { GoHome, GoBack, OpenApp, RefreshApp, GetCurrentApp };