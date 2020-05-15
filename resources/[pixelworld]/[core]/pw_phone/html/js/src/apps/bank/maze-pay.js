import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';
import Utils from '../../util/utils';
import Notif from '../../util/notification';

$('#screen-content').on('submit', '#send-maze-pay', (event) => {
    event.preventDefault();
    let data = $(event.currentTarget).serializeArray();

    $.post(Config.ROOT_ADDRESS + '/MazePay', JSON.stringify({
        destination: data[0].value,
        amount: data[1].value,
    }), (status) => {
        if (status) {
            Data.AddData('maze-pay', status);
            Notif.Alert('Money Has Been Transferred');
            App.GoBack();
        } else {
            Notif.Alert('Unable To Process Payment');
        }
    });
});

window.addEventListener('bank-mp-open-app', (data) => {
    $('#bank-app-page').animate({
        height: '100%'
    }, { duration: 1000 });
});

window.addEventListener('bank-mp-custom-close-app', (data) => {
    $('#bank-app-page').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('bank-mp-close-app', () => {

});

export default {}