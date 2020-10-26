import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';
import Utils from '../../util/utils';
import Notif from '../../util/notification';
import Unread from '../../util/unread';

import Transfer from './transfer';
import MazePay from './maze-pay';
import Transaction from './transaction'

var timeInt = null;

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'BankBalanceUpdate':
            
            break;
    }
});

$('#screen-content').on('click', '.account', (event) => {
    App.OpenApp('bank-transaction', $(event.currentTarget).data('account'), false, true, true);
});

$('#screen-content').on('keyup keydown blur', '#target-account', (event) => {
    switch(event.which) {
        case 69:
        case 107: // Numpad Equals
        case 109: // Numpad Minus
        case 110: // Numpad Decimal
        case 187: // =/+
        case 189: // -/_
        case 190: // ./>
            e.preventDefault();
            break;
        default:
            if ($(event.currentTarget).val() != '') {
                $(event.currentTarget).val(parseInt($(event.currentTarget).val()));
            }
            break;
    }
});

$('#screen-content').on('click', '.bank-quick-nav', (event) => {
    if (!$(event.currentTarget).hasClass('disabled')) {
        let type = $(event.currentTarget).data('type');

        if (type != 'back') {
            $(event.currentTarget).addClass('disabled');
            
            switch(type) {
                case 'atm':
                    Notif.Alert(`Marked Nearest ATM On Your GPS`);
                    $.post(Config.ROOT_ADDRESS + '/FindNearestAtm', JSON.stringify({}), (status) => {
                        if (status) {
                            Notif.Alert(`Marked Nearest ATM On Your GPS`);
                        } else {
                            Notif.Alert('Unable to locate a nearby ATM');
                        }
                    });
                    break;
                case 'bank':
                    Notif.Alert(`Marked Nearest Branch On Your GPS`);
                    $.post(Config.ROOT_ADDRESS + '/FindNearestBranch', JSON.stringify({}));
                    break;
            }
        }

        $('.quick-actions').animate({
            height: '0%'
        }, { duration: 500 }).promise().then(() => {
            $('.bank-quick-action').show();
            $('.bank-quick-nav').hide();

            $('.quick-actions').animate({
                height: '20%'
            }, { duration: 500 }).promise().then(() => {
                $('.bank-quick-nav.disabled').removeClass('disabled');
            });
        });

    }
});

$('#screen-content').on('click', '.bank-quick-action', (event) => {
    if (!$(event.currentTarget).hasClass('disabled')) {
        let app = $(event.currentTarget).data('nav');

        if (app != null) {
            $(event.currentTarget).addClass('disabled');
            App.OpenApp(app, null, false, true, true);
        } else {
            $('.quick-actions').animate({
                height: '0%'
            }, { duration: 500 }).promise().then(() => {
                $('.bank-quick-action').hide();
                $('.bank-quick-nav').show();

                $('.quick-actions').animate({
                    height: '20%'
                }, { duration: 500 }).promise().then(() => {
                    $(this).removeClass('disabled');
                });
            });
        }
    }
});

window.addEventListener('bank-open-app', () => {
    let myData = Data.GetData('myData');
    $('.message-name').html(myData.name);
    $('.message-text').html(`${moment().format('MMMM Do YYYY, h:mm:ss a')}`);

    timeInt = setInterval(function() {
        $('.message-text').html(`${moment().format('MMMM Do YYYY, h:mm:ss a')}`);
    }, 1000);


    /// TODO : Seriously find a better way to do this, fucking kill me please
    let accounts = Data.GetData('banking');
    $('.accounts').html('');

    $.each(accounts, (index, account) => {
        let sortCord = "" + account.sort_code + ""
        var newSortCode = sortCord.replace(/(\d{2})(\d{2})(\d{2})/, "$1-$2-$3");
        if (account.account_rank === 1) {
            $('.accounts').append(`<div class="account type-${account.account_rank}" data-tooltip="Personal Account (${account.account_number} / ${newSortCode}) - Balance: ${Utils.FormatCurrency(account.balance)}"><div class="account-label"><div class="bank-label-name">${account.account_type}</div><small>${account.account_number} / ${newSortCode}</small></div><div class="account-balance">${Utils.FormatCurrency(account.balance)}</div></div>`)
        } else if(account.account_rank === 2) {
            $('.accounts').append(`<div class="account type-${account.account_rank}" data-tooltip="Savings Account (${account.account_number} / ${newSortCode}) - Balance: ${Utils.FormatCurrency(account.balance)}"><div class="account-label"><div class="bank-label-name">${account.account_type}</div><small>${account.account_number} / ${newSortCode}</small></div><div class="account-balance">${Utils.FormatCurrency(account.balance)}</div></div>`)
        } else {
            $('.accounts').append(`<div class="account type-${account.account_rank}" data-tooltip="Business Account (${account.account_number} / ${newSortCode}) - Balance: ${Utils.FormatCurrency(account.balance)}"><div class="account-label"><div class="bank-label-name">${account.account_type}</div><small>${account.account_number} / ${newSortCode}</small></div><div class="account-balance">${Utils.FormatCurrency(account.balance)}</div></div>`)
        }
        $('.accounts .account:last-child').data('account', account);
    });

    $('.account').tooltip({
        enterDelay: 0,
        exitDelay: 0,
        inDuration: 0
    });

    $('.quick-actions').animate({
        height: '20%'
    }, { duration: 1000 }).promise().then(() => {
        $('.bank-quick-action').fadeIn('normal').css('display', 'inline-block');
    });
    Unread.ClearUnread();
});

window.addEventListener('bank-custom-close-app', (data) => {
    if (!$('#bank-container').hasClass('disabled')) {
        $('#bank-container').addClass('disabled');
        $('.bank-quick-action').fadeOut('normal').promise().then(() => {
            $('.quick-actions').animate({
                height: '100%'
            }, { duration: 1000 }).promise().then(() => {
                window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
            });
        });
    }
});

window.addEventListener('bank-close-app', () => {
    clearInterval(timeInt);
});

export default {}