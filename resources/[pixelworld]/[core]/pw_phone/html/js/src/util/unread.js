import App from '../app';
import Data from './data';
import Config from '../util/config';

function UpdateData(currApp, amount, cb) {
    $.post(Config.ROOT_ADDRESS + '/SetUnread', JSON.stringify({
        app: currApp,
        unread: amount
    }), cb);
}

function SetUnread(amount) {
    let apps = Data.GetData('apps');
    let myjob = Data.GetData('job');
    let currApp = App.GetCurrentApp();

    $.each(apps, (index, app) => {
        if (app.container === currApp) {
            UpdateData(currApp, amount, (status) => {
                app.unread = status;
                Data.UpdateData('apps', index, app);
            });

            return false;
        }
    });
}

function AddUnread() {
    let apps = Data.GetData('apps');
    let myjob = Data.GetData('job');
    let currApp = App.GetCurrentApp();

    $.each(apps, (index, app) => {
        if (app.container == currApp) {
            UpdateData(currApp, app.unread + 1, (status) => {
                app.unread = status;
                Data.UpdateData('apps', index, app);
            });

            return false;
        }
    });
}

function RemoveUnread() {
    let apps = Data.GetData('apps');
    let myjob = Data.GetData('job');
    let currApp = App.GetCurrentApp();

    $.each(apps, (index, app) => {
        if (app.container == currApp) {
            UpdateData(currApp, app.unread - 1, (status) => {
                app.unread = status;
                Data.UpdateData('apps', index, app);
            });

            return false;
        }
    });
}

function ClearUnread() {
    let apps = Data.GetData('apps');
    let myjob = Data.GetData('job');
    let currApp = App.GetCurrentApp();

    $.each(apps, (index, app) => {
        if (app.container == currApp) {
            UpdateData(currApp, 0, (status) => {
                app.unread = status;
                Data.UpdateData('apps', index, app);
            });

            return false;
        }
    });
}

export default { SetUnread, AddUnread, RemoveUnread, ClearUnread }