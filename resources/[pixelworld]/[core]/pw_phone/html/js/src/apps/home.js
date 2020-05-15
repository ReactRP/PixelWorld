import App from '../app';
import Data from '../util/data';
import Config from '../util/config';

var apps = null;

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'Logout':
            window.dispatchEvent(new CustomEvent('reset-closed-notifs'));
            break;
        case 'updateUnread':
            UpdateUnread(event.data.app, event.data.unread);
            break;
        case 'EditAppState':
            $.each(Data.GetData('apps'), (index, app) => {
                if (app.container === event.data.app) {
                    Data.UpdateObjectData('apps', 'container', event.data.app, 'enabled', event.data.state);
                    return false;
                }
            });

            if (App.GetCurrentApp() === 'home') {
                SetupApp()
            }

            //ToggleApp(event.data.app, true);
            break;
        case 'DisableApp':
            $.each(Data.GetData('apps'), (index, app) => {
                if (app.container === event.data.app) {
                    Data.UpdateObjectData('apps', 'container', event.data.app, 'enabled', false);
                    return false;
                }
            });

            if (App.GetCurrentApp() === 'home') {
                SetupApp()
            }
            //ToggleApp(event.data.app, false);
            break;
        case 'SyncUnread':
            $.each(Data.GetData('apps'), (index, app) => {
                if (event.data.unread[app.container] !== null) {
                    Data.UpdateObjectData('apps', 'container', app.container, 'unread', event.data.unread[app.container]);
                }
            });
            break;
        case 'AddClosedAlert':
            AddClosedAlert(event.data.app);
            break;
    }
});

$('.phone-screen').on('click', '#home-container .app-button', function(event) {
    let app = $(event.currentTarget).data('app');
    App.OpenApp(app.container, null, false, false, app.customExit);
});

function UpdateUnread(name, unread) {
    if (apps == null) {
        apps = Data.GetData('apps');
    }

    if (App.GetCurrentApp() === name && unread > 0) {
        return;
    }

    $.each(apps, (index, app) => {
        if (app.container == name) {
            $.post(Config.ROOT_ADDRESS + '/SetUnread', JSON.stringify({
                app: name,
                unread: unread
            }), (status) => {
                if (status != null) {
                    app.unread = unread;
                    Data.StoreData('apps', apps);
                    if (App.GetCurrentApp() === 'home') {
                        SetupApp();
                    }
                }
            });
            return false;
        }
    });
}

window.addEventListener('remove-closed-notif', (data) => {
    $(`#${data.detail.app}-unread-notif`).fadeOut('normal').promise().then(() => {
        $(this).remove();
    });
});

window.addEventListener('reset-closed-notifs', () => {
    $('.unread-alert').find('.app-button').fadeOut('normal').promise().then(() => {
        $(this).remove();
    });
});

function AddClosedAlert(notif) {
    apps = Data.GetData('apps');

    $.each(apps, (index, app) => {
        if (app.container === notif) {
            $('.unread-alert').append(
                `<div class="app-button" id="${app.container}-unread-notif"><div class="app-icon" id="${app.container}-app" style="background-color: ${app.color}"> ${app.icon}</div></div>`
            );
        }
    });
}

function SetupApp() {
    apps = Data.GetData('apps');
    $.each(apps, (index, app) => {
        if (app.enabled) {
            if (app.unread > 0) {
                $('.inner-app').append(
                    `<div class="app-button" data-tooltip="${app.name}"><div class="app-icon" id="${app.container}-app" style="background-color: ${app.color}"> ${app.icon}<div class="badge pulse">${app.unread}</div></div></div>`
                );
            } else {
                $('.inner-app').append(
                    `<div class="app-button" data-tooltip="${app.name}"><div class="app-icon" id="${app.container}-app" style="background-color: ${app.color}"> ${app.icon}</div></div>`
                );
            }
            let $app = $('#home-container .app-button:last-child');

            $app.tooltip({
                enterDelay: 0,
                exitDelay: 0,
                inDuration: 0
            });

            $app.data('app', app);
        }
    });
}

window.addEventListener('home-open-app', () => {
    SetupApp();
});

export default { UpdateUnread };