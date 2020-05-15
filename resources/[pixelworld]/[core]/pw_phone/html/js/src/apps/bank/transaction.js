import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';
import Utils from '../../util/utils';


$("#screen-content").on('change', '#bank-transaction-accounts', (event) => {
    let id = $(event.currentTarget).val();
    let account = Data.GetData('banking').filter(function(item) {
        return item.account_id == id;
    })[0];
    App.OpenApp('bank-transaction', account, false, true, true);
    //App.OpenApp('bank-transaction', $(event.currentTarget).data('account'), false, true, true);
});

window.addEventListener('bank-transaction-open-app', (data) => {
    let account = data.detail;
    
    $.post(Config.ROOT_ADDRESS + '/GetBankTransactions', JSON.stringify({
        account_number: account.account_number,
        account_sortcode: account.sort_code,
        account_type: account.account_type
    }), (transactions) => {
        $('#bank-app-page').addClass(`type-${account.account_rank}`);

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
            $('#bank-transaction-accounts').append(`<optgroup label="${type.label}"></optgroup>`);
    
            $.each(type.data, (index2, act) => {
                $('#bank-transaction-accounts').append(`<option value="${act.account_id}">${act.account_type} Account ${Utils.FormatCurrency(act.balance)}</option>`);
                
                if (act.account_id == account.account_id) {
                    $('#bank-transaction-accounts option:last-child').attr('selected', 'selected');
                }
            });
        });
    
        $('#bank-transaction-accounts').formSelect();
    
        if (transactions != null && transactions.length > 0) {
            transactions.sort(Utils.DateSortNewest);
            $.each(transactions, (index, trans) => {
                if(trans.deposited != null) {
                    $('.transaction-body table').append(`<tr class="trans-deposit"><td>${moment(trans.date).format('l')}<br>${moment(trans.date).format('h:mm a')}</td><td class="trans-positive">+ ${Utils.FormatCurrency(trans.deposited)}</td><td>${trans.message}</td></tr>`)
                } else {
                    $('.transaction-body table').append(`<tr class="trans-withdraw"><td>${moment(trans.date).format('l')}<br>${moment(trans.date).format('h:mm a')}</td><td class="trans-negative">- ${Utils.FormatCurrency(trans.withdraw)}</td><td>${trans.message}</td></tr>`)
                }
            });
        } else {
            $('.transaction-body').html('<div class="no-transactions">No Recent Transactions</div>')
        }
    
        $('#bank-app-page').animate({
            height: '100%'
        }, { duration: 1000 }).promise().then(() => {
            $('.select-wrapper, .no-transactions').fadeIn('fast');
        });
    });
});

window.addEventListener('bank-transaction-custom-close-app', (data) => {
    $('.select-wrapper, .no-transactions').fadeOut('fast');
    $('#bank-app-page').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('bank-transaction-close-app', () => {
    
});

export default {}