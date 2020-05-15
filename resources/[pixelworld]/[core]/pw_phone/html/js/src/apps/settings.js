import App from '../app';
import Config from '../util/config';
import Data from '../util/data';
import Notif from '../util/notification';
import Utils from '../util/utils';

window.addEventListener('settings-open-app', () => {
    $('#phone-settings').on('submit', (event) => {
        event.preventDefault();
        let data = $(event.currentTarget).serializeArray();
    
        let settings ={
            volume: parseInt(data[0].value),
            wallpaper: parseInt(data[1].value),
            ringtone: parseInt(data[2].value),
            text: parseInt(data[3].value),
            mynumber: $('#settings-mynumber').html()
        }
    
        $.post(Config.ROOT_ADDRESS + '/SaveSettings', JSON.stringify(settings), (status) => {
            if (status) {
                Data.StoreData('settings', settings);
                Utils.UpdateWallpaper(`url(./imgs/back00${settings.wallpaper}.png)`);
                Utils.SetMute(settings.volume === 0);
                Notif.Alert('Settings Saved');
            } else {
                Notif.Alert('Unable To Save Settings');
            }
        });
    });
});

window.addEventListener('settings-open-app', (data) => {
    let settings = Data.GetData('settings');
    $('#settings-volume').val(settings.volume);
    $('#settings-wallpaper').val(settings.wallpaper);
    $('#settings-ringtone').val(settings.ringtone);
    $('#settings-text').val(settings.text);
    $('#settings-mynumber').html(settings.mynumber);

    $('#settings-volume').formSelect();
    $('#settings-wallpaper').formSelect();
    $('#settings-ringtone').formSelect();
    $('#settings-text').formSelect();
});

window.addEventListener('settings-close-app', () => {
    $('#phone-settings').off('submit');
});

export default {}