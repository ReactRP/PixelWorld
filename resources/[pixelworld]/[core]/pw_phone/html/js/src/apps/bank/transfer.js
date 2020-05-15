import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';
import Utils from '../../util/utils';
import Notif from '../../util/notification';

$('#screen-content').on('submit', '#send-quick-pay', (event) => {
    event.preventDefault();
    let data = $(event.currentTarget).serializeArray();

    $.post(Config.ROOT_ADDRESS + '/Transfer', JSON.stringify({
        from: data[0].value,
        account_number: data[1].value,
        sort_code: data[2].value,
        amount: data[3].value
    }), (status) => {
        if (status) {
            Notif.Alert('Transfer Submitted, Will Be Processed Within 1 Day (1 hour)');
            App.GoBack();
        } else {
            Notif.Alert('Unable To Process Transfer');
        }
    });
});

window.addEventListener('bank-transfer-open-app', (data) => {
    let accounts = Data.GetData('banking');
    let stuff = new Array();
    
    stuff.push({ label: 'Personal Accounts', data: accounts.filter(function(account) {
        return account.account_rank === 1;
    })});

    stuff.push({ label: 'Savings Accounts', data: accounts.filter(function(account) {
        return account.account_rank === 2;
    })});

    stuff.push({ label: 'Business Accounts', data: accounts.filter(function(account) {
        return account.account_rank === 3;
    })});

    $.each(stuff, (index, type) => {
        $('#bank-transfer-accounts').append(`<optgroup label="${type.label}"></optgroup>`);

        $.each(type.data, (index2, account) => {
            $('#bank-transfer-accounts').append(`<option value="${account.account_id}">${account.account_type} Account ${Utils.FormatCurrency(account.balance)}</option>`);
        });
    });

    $('#bank-transfer-accounts').formSelect();

    let history = Data.GetData('bank-transfers');
    history.sort(Utils.DateSortNewest);
    $.each(history, (index2, transfer) => {
        switch(transfer.status) {
            case 1:
                $('#bank-transfer-history table tbody').append(`
                    <tr class="transfer-pending" data-tooltip="Will transfer on ${moment(+transfer.process_date*1000).format('l')} at ${moment(+transfer.process_date*1000).format('h:mm a')}">
                        <td class="transfer-status pending"><small>Pending</small></td>
                        <td><small>${moment(+transfer.request_date*1000).format('l')}<br>${moment(+transfer.request_date*1000).format('h:mm a')}</small></td>
                        <td><small>${Utils.FormatCurrency(transfer.amount)}</small></td>
                        <td><small>${transfer.origin}<br>Account</small></td>
                        <td><small>${transfer.receiptName}</small></td>
                    </tr>
                `)
                break;
            case 2:
                $('#bank-transfer-history table tbody').append(`
                    <tr class="transfer-success" data-tooltip="Completed on ${moment(+transfer.process_date*1000).format('l')} at ${moment(+transfer.process_date*1000).format('h:mm a')}">
                        <td class="transfer-status completed"><small>Completed</small></td>
                        <td><small>${moment(+transfer.request_date*1000).format('l')}<br>${moment(+transfer.request_date*1000).format('h:mm a')}</small></td>
                        <td><small>${Utils.FormatCurrency(transfer.amount)}</small></td>
                        <td><small>${transfer.origin}<br>Account</small></td>
                        <td><small>${transfer.receiptName}</small></td>
                    </tr>
                `)
                break;
            case 3:
                $('#bank-transfer-history table tbody').append(`
                    <tr class="transfer-failed" data-tooltip="Failed on ${moment(+transfer.process_date*1000).format('l')} at ${moment(+transfer.process_date*1000).format('h:mm a')} / ${transfer.reason}">
                        <td class="transfer-status cancelled"><small>Failed</small></td>
                        <td><small>${moment(+transfer.request_date*1000).format('l')}<br>${moment(+transfer.request_date*1000).format('h:mm a')}</small></td>
                        <td><small>${Utils.FormatCurrency(transfer.amount)}</small></td>
                        <td><small>${transfer.origin}<br>Account</small></td>
                        <td><small>${transfer.receiptName}</small></td>
                    </tr>
                `)
                break;
        }

        let $entry = $('#bank-transfer-history table tbody tr:last-child');
        $entry.tooltip({
            enterDelay: 0,
            exitDelay: 0,
            inDuration: 0
        });
    });

    $('#bank-app-page').animate({
        height: '100%'
    }, { duration: 1000 });
});

window.addEventListener('bank-transfer-custom-close-app', (data) => {
    $('#bank-app-page').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('bank-transfer-close-app', () => {

});

export default {}