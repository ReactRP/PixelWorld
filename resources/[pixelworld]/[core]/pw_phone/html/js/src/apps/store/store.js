import App from '../../app';
import Data from '../../util/data';
import Config from '../../util/config';
import Notif from '../../util/notification';

var Appperanos = null;
var Job = null;
var modifyApp = null;
var actionDoing = null;
var timeout = null;

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'Logout':
            window.dispatchEvent(new CustomEvent('reset-closed-notifs'));
            break;
        
    }
});

$('.phone-screen').on('click', '[data-action=installApplication]', function(event) {
    let app = $(this).data('application');
    $.post(Config.ROOT_ADDRESS + '/ProcessInstall', JSON.stringify({
        app: app.container,
        install: true
    }), (status) => {
        if (status) {
            modifyApp = app;
            actionDoing = "installing";
            App.OpenApp('store-setupapp', null, false, false, true);
        } else {
            Notif.Alert('Failed to Install Application: '+ app.name, 1500);
        }
    });
});

$('.phone-screen').on('click', '[data-action=returnToStore]', function(event) {
    App.OpenApp('store', null, true, false, true);
});

$('.phone-screen').on('click', '[data-action=uninstallApplication]', function(event) {
    let app = $(this).data('application');
    $.post(Config.ROOT_ADDRESS + '/ProcessInstall', JSON.stringify({
        app: app.container,
        install: false
    }), (status) => {
        if (status) {
            modifyApp = app;
            actionDoing = "uninstalling";
            App.OpenApp('store-setupapp', {application: app, action: 'uninstall'}, false, false, false);
        } else {
            Notif.Alert('Failed to Uninstall Application: '+ app.name, 1500);
        }
    });
});

function SetupApp(initialLoad) {
    Appperanos = Data.GetData('apps');
    Job = Data.GetData('job')
    $('#store').html('');
    $('#installed').html('');
    $('#jobApps').html('');
    var installFound = false
    var uninstallFound = false
    var privateFound = false
    
    $.each(Appperanos, (index, app) => {
        if(app.public && app.installable && !app.enabled) {
            installFound = true;
            $('#store').append(`<div class="appStoreContainer"><div class="appStoreIcon"><div class="app-button" data-tooltip="${app.name}"><div class="app-icon" id="home-app" style="background-color: ${app.color};"> ${app.icon}</div></div></div><div class="appStoreInfo"><strong>${app.name}</strong><br><small>${app.description}</small></div><div class="appStoreInstaller"><div class="appStoreInnerButton"><button class="waves-effect waves-light btn install doAction" data-action="installApplication" id="install-${app.container}"><i class="fad fa-download"></i></button></div></div></div>`)
            let $app = $('#install-' + app.container);
            $app.data('application', app);
        }
        
        if(app.enabled && app.installable && app.uninstallable) {
            uninstallFound = true;
            $('#installed').append(`<div class="appStoreContainer"><div class="appStoreIcon"><div class="app-button" data-tooltip="${app.name}"><div class="app-icon" id="home-app" style="background-color: ${app.color};"> ${app.icon}</div></div></div><div class="appStoreInfo"><strong>${app.name}</strong><br><small>${app.description}</small></div><div class="appStoreInstaller"><div class="appStoreInnerButton"><button class="waves-effect waves-light btn delete doAction" data-action="uninstallApplication" id="uninstall-${app.container}"><i class="fad fa-trash-alt"></i></button></div></div></div>`);
            let $app = $('#uninstall-' + app.container);
            $app.data('application', app);
        }
        
        if(!app.public && !app.enabled) {
            if(typeof app.jobRequired == "string") {
                app.jobRequired = JSON.parse(app.jobRequired);
            }
            $.each(app.jobRequired, (index, job) => {
                if(job == Job.job_id) {
                    privateFound = true;
                    $('#jobApps').append(`<div class="appStoreContainer"><div class="appStoreIcon"><div class="app-button" data-tooltip="${app.name}"><div class="app-icon" id="home-app" style="background-color: ${app.color};"> ${app.icon}</div></div></div><div class="appStoreInfo"><strong>${app.name}</strong><br><small>${app.description}</small></div><div class="appStoreInstaller"><div class="appStoreInnerButton"><button class="waves-effect waves-light btn install doAction" data-action="installApplication" id="install-${app.container}"><i class="fad fa-download"></i></button></div></div></div>`);
                    let $app = $('#install-' + app.container);
                    $app.data('application', app);
                }
            });
        }
    });

    if(!installFound) {
        $('#store').append(`<div class="noAppsFounds">No Applications to Install</div>`);
    }
    
    if(!uninstallFound) {
        $('#installed').append(`<div class="noAppsFounds">No Applications Installed</div>`);
    }
    
    if(!privateFound) {
        $('#jobApps').append(`<div class="noAppsFounds">No Applications to Install</div>`);
    }
    
    $('#storeContainer').animate({
        height: '100%'
    }, { duration: 1000 });
}

function doInstallScreen() { 
    var localinstall = null
    $('#applicationNameStore').html(modifyApp.name);
    if(actionDoing == "installing") {
        $('#storeAction').html('Installing');
        $('#actionTypeStore').html('Installation');
        localinstall = "Installed";
    } else {
        $('#storeAction').html('Uninstalling');
        $('#actionTypeStore').html('Uninstallation');
        localinstall = "Uninstalled";
    }

    $('#installedapp').css({"background-color":"" + modifyApp.color + ""}).html(modifyApp.icon);

    $('#storeContainer2').animate({
        height: '100%'
    }, { duration: 1000 });
    setTimeout(function() {
        setTimeout(function() {
            Notif.Alert(modifyApp.name + ' has been successfully ' + localinstall, 1500);
            $('#preloader-wrapper').css({"display":"none"});
            actionDoing = null;
            modifyApp = null;
            localinstall = null;
            App.OpenApp('store', null, true, false, true);
        }, 5000)
    }, 1001)
}

window.addEventListener('store-setupapp-close-app', () => {
    $('#preloader-wrapper').css({"display":"block"});
});

window.addEventListener('store-close-app', () => {
    
});

window.addEventListener('store-setupapp-open-app', () => {
    $('#actionCompleteStire').css({"display":"none"});
    doInstallScreen();
});

window.addEventListener('store-setupapp-custom-close-app', (data) => {
    $('#storeContainer2').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('store-custom-close-app', (data) => {
    $('#storeContainer').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('store-open-app', () => {
    SetupApp(true);
});

export default {}