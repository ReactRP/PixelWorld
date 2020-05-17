import App from '../../app';
import Config from '../../util/config';
import Utils from '../../util/utils';
import Data from '../../util/data';
import Notif from '../../util/notification';
import Call from './call';
import Contacts from '../contacts';

var myNumber = null;
var contacts = null;
var history = null;

var delHold = null;



$('#screen-content').on('click', '.phone-nav-button', (event) => {
    if (!$(event.currentTarget).hasClass('active-nav')) {
        let activeSection = $('.active-nav').data('nav');
        $('.active-nav').removeClass('active-nav');

        let section = $(event.currentTarget).data('nav');
        $(event.currentTarget).addClass('active-nav');
        $('[data-section=' + activeSection + ']').fadeOut('fast', () => {
            $('[data-section=' + section + ']').fadeIn();
        });
    }
});

$('#screen-content').on('click', '[data-section=keypad] .keypad-top .delete-num-btn', (e) => {
    let number = $('.keypad-top #number').val();
    if (number.length > 0) {
        let delNum = number.substring(0, number.length - 1);
        $('.keypad-top #number').val($('.keypad-top #number').masked(delNum));
    } else if ($('.keypad-top #type').val() != null) {
        $('.keypad-top #type').val('');
    }

    CheckIfContact($('.keypad-top #number').val());
    SetupCallType();
});

$('#screen-content').on('mousedown', '[data-section=keypad] .keypad-top .delete-num-btn', (e) => {
        let number = $('.keypad-top #number').val();
        delHold = setInterval(function() {
            if (number.length > 0) {
                let delNum = number.substring(0, number.length - 1);
                $('.keypad-top #number').val(
                    $('.keypad-top #number').masked(delNum)
                );
                number = $('.keypad-top #number').val();
                CheckIfContact($('.keypad-top #number').val());
                SetupCallType();
            }
        }, 250);

        return false;
    }
);

$('#screen-content').on('submit', '[data-section=keypad] #call-number', (event) => {
    event.preventDefault();
    let data = $(event.currentTarget).serializeArray();
    CreateCall(
        data[1].value,
        data[0].value === '#' || data[0].value === '*',
        false
    );
});

$(document).mouseup(function() {
    clearInterval(delHold);
    return false;
});

$('#screen-content').on('click', '[data-section=keypad] .keypad-key', (event) => {
    if (!$(event.currentTarget).hasClass('key-call')) {
        let key = $(event.currentTarget).data('value');
        let exist = $('.keypad-top #number').val();
        if (key === '#' || key === '*') {
            if ($('.keypad-top #type').val() === key) {
                $('.keypad-top #type').val('');
            } else {
                $('.keypad-top #type').val(key);
            }
        } else if (exist.length < 12) {
            exist = exist + key;
            $('.keypad-top #number').val(
                $('.keypad-top #number').masked(exist)
            );
        }
    }

    CheckIfContact($('.keypad-top #number').val());
    SetupCallType();
    $('.keypad-top #number')
        .get(0)
        .focus();
});

$('#screen-content').on('click', '[data-section=history] .call', (event) => {
    if (
        $(event.currentTarget)
            .find('.call-actions')
            .is(':visible')
    ) {
        $(event.currentTarget)
            .find('.call-actions')
            .slideUp();
    } else {
        $(event.currentTarget)
            .parent()
            .find('.call-actions')
            .slideUp();
        $(event.currentTarget)
            .find('.call-actions')
            .slideDown();
    }
});

$('#screen-content').on('click', '[data-section=history] .call-actions .call-action-call', (event) => {
        let data = $(event.currentTarget)
            .parent()
            .parent()
            .data('data');
        let number = data.sender;
        if (data.sender == myNumber) {
            number = data.receiver;
        }
        CreateCall(number, false, false);
    }
);

$('#screen-content').on('click', '[data-section=history] .call-actions .call-action-text', (event) => {
        let data = $(event.currentTarget)
            .parent()
            .parent()
            .data('data');
        let number = data.sender;

        if (data.sender == myNumber) {
            number = data.receiver;
        }

        App.OpenApp('message-convo', { number: number });
    }
);

$('#screen-content').on('click', '[data-section=history] .call-actions .call-action-delete', (event) => {
        let data = $(event.currentTarget)
            .parent()
            .parent()
            .data('data');
        $.post(
            Config.ROOT_ADDRESS + '/DeleteCallRecord',
            JSON.stringify({
                id: data.id
            }),
            function(status) {
                if (status) {
                    $(event.currentTarget)
                        .parent()
                        .parent()
                        .fadeOut('normal', () => {
                            Data.RemoveData('history', data.index);
                            App.RefreshApp();
                            Notif.Alert('Call Record Deleted');
                        });
                } else {
                    Notif.Alert('Error Deleting Call Record');
                }
            }
        );
    }
);

$('#screen-content').on('keyup', '[data-section=contacts] .contact-search input', (event) => {
    event.preventDefault();
    let searchVal = $(event.currentTarget).val();

    if (searchVal !== '') {
        $.each(
            $(event.currentTarget)
                .parent()
                .parent()
                .find('.contacts-list')
                .children(),
            function(index, contact) {
                let data = $(contact).data('data');

                if (
                    data.name.toUpperCase().includes(searchVal.toUpperCase()) ||
                    data.number.includes(searchVal.toUpperCase())
                ) {
                    $(contact).fadeIn();
                } else {
                    $(contact).fadeOut();
                }
            }
        );
    } else {
        $.each(
            $(event.currentTarget)
                .parent()
                .parent()
                .find('.contacts-list')
                .children(),
            function(index, contact) {
                $(contact).fadeIn();
            }
        );
    }
});

$('#screen-content').on('click', '[data-section=contacts] .phone-contact', (event) => {
    if (
        $(event.currentTarget)
            .find('.call-actions')
            .is(':visible')
    ) {
        $(event.currentTarget)
            .find('.call-actions')
            .slideUp();
    } else {
        $(event.currentTarget)
            .parent()
            .find('.call-actions')
            .slideUp();
        $(event.currentTarget)
            .find('.call-actions')
            .slideDown();
    }
});

$('#screen-content').on('click', '[data-section=contacts] .call-actions .call-action-call', (event) => {
        let data = $(event.currentTarget)
            .parent()
            .parent()
            .data('data');
        CreateCall(data.number, false, false);
    }
);

$('#screen-content').on('click', '[data-section=contacts] .call-actions .call-action-text', (event) => {
        let data = $(event.currentTarget)
            .parent()
            .parent()
            .data('data');
        App.OpenApp('message-convo', { number: data.number });
    }
);

$('#screen-content').on('click', '.call-action-mute', (e) => {});

function CheckIfContact(number) {
    let contact = contacts.filter(c => c.number == number)[0];
    if (contact != null) {
        $('.keypad-top .contact-display').html(contact.name);
        $('.keypad-top .contact-display').fadeIn();
    } else {
        $('.keypad-top .contact-display').fadeOut();
    }
}

function SetupCallType() {
    let number = $('.keypad-top #type').val();

    if (number[0] === '#') {
        $('.keypad-top .call-type').html('Calling Anonymously');
        if ($('.keypad-top .call-type').is(':hidden')) {
            $('.keypad-top .call-type').fadeIn();
        }
    } else if (number[0] == '*') {
        $('.keypad-top .call-type').html('Calling UNK');
        if ($('.keypad-top .call-type').is(':hidden')) {
            $('.keypad-top .call-type').fadeIn();
        }
    } else {
        if ($('.keypad-top .call-type').is(':visible')) {
            $('.keypad-top .call-type').fadeOut('fast', () => {
                $('.keypad-top .call-type').html('CALL TYPE');
            });
        }
    }
} 

function CreateCall(number, nonStandard, receiver) {
    $.post(
        Config.ROOT_ADDRESS + '/CreateCall',
        JSON.stringify({
            number: number,
            nonStandard: nonStandard
        }),
        function(status) {
            if (status > 0) {
                App.OpenApp('phone-call', {
                    number: number,
                    nonStandard: nonStandard,
                    receiver: receiver
                });
            } else if (status == -2) {
                Notif.Alert('You can\'t call yourself');
            } else if (status == -3) {
                Notif.Alert('Number is engaged');
            } else if (status == -4) {
                Notif.Alert('Number not currently active');
            } else {
                Notif.Alert('There was an error placing your call');
            }
        }
    );
}

window.addEventListener('phone-open-app', (data) => {
    myNumber = Data.GetData('myData').phone;
    contacts = Data.GetData('contacts');
    history = Data.GetData('history');

    SetupCallContacts();

    history.sort(Utils.DateSortOldest);

    $('[data-section=history').html('');
    $.each(history, (index, call) => {
        if (call.sender == myNumber) {
            let contact = contacts.filter(c => c.number == call.receiver)[0];

            if (call.status == 0) {
                if (contact != null) {
                    $('[data-section=history').prepend(
                        '<div class="call"><i class="fas fa-phone icon-outgoing-missed"></i><span>' +
                            contact.name +
                            '</span><div class="timestamp">' +
                            moment(call.date).calendar() +
                            '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                    );
                } else {
                    $('[data-section=history').prepend(
                        '<div class="call"><i class="fas fa-phone icon-outgoing-missed"></i><span>' +
                            call.receiver +
                            '</span><div class="timestamp">' +
                            moment(call.date).calendar() +
                            '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                    );
                }
            } else if (call.status == 1) {
                if (contact != null) {
                    $('[data-section=history').prepend(
                        '<div class="call"><i class="fas fa-phone icon-outgoing"></i><span>' +
                            contact.name +
                            '</span><div class="timestamp">' +
                            moment(call.date).calendar() +
                            '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                    );
                } else {
                    $('[data-section=history').prepend(
                        '<div class="call"><i class="fas fa-phone icon-outgoing"></i><span>' +
                            call.receiver +
                            '</span><div class="timestamp">' +
                            moment(call.date).calendar() +
                            '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                    );
                }
            }
        } else {
            if (call.anon == 0) {
                let contact = contacts.filter(c => c.number == call.sender)[0];
                if (call.status == 0) {
                    if (contact != null) {
                        $('[data-section=history').prepend(
                            '<div class="call"><i class="fas fa-phone-alt icon-incoming-missed"></i><span>' +
                                contact.name +
                                '</span><div class="timestamp">' +
                                moment(call.date).calendar() +
                                '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                        );
                    } else {
                        $('[data-section=history').prepend(
                            '<div class="call"><i class="fas fa-phone-alt icon-incoming-missed"></i><span>' +
                                call.sender +
                                '</span><div class="timestamp">' +
                                moment(call.date).calendar() +
                                '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                        );
                    }
                } else if (call.status == 1) {
                    if (contact != null) {
                        $('[data-section=history').prepend(
                            '<div class="call"><i class="fas fa-phone-alt icon-incoming"></i><span>' +
                                contact.name +
                                '</span><div class="timestamp">' +
                                moment(call.date).calendar() +
                                '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                        );
                    } else {
                        $('[data-section=history').prepend(
                            '<div class="call"><i class="fas fa-phone-alt icon-incoming"></i><span>' +
                                call.sender +
                                '</span><div class="timestamp">' +
                                moment(call.date).calendar() +
                                '</div><div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                        );
                    }
                }
            } else {
                if (call.status == 0) {
                    $('[data-section=history').prepend(
                        '<div class="call"><i class="fas fa-phone-alt icon-incoming"></i><span>Unknown Number</span><div class="timestamp">' +
                            moment(call.date).calendar() +
                            '</div><div class="call-actions"><i class="fas fa-phone-volume action-disabled"></i><i class="fas fa-sms action-disabled"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                    );
                } else {
                    $('[data-section=history').prepend(
                        '<div class="call"><i class="fas fa-phone-alt icon-incoming"></i><span>Unknown Number</span><div class="timestamp">' +
                            moment(call.date).calendar() +
                            '</div><div class="call-actions"><i class="fas fa-phone-volume action-disabled"></i><i class="fas fa-sms action-disabled"></i><i class="fas fa-trash-alt call-action-delete"></i></div></div>'
                    );
                }
            }
        }

        call.index = index;
        $('[data-section=history')
            .find('.call:first-child')
            .data('data', call);
    });
    setTimeout(function() {
        $('.keypad-top #number')
            .get(0)
            .focus();
    }, 1500);
});

function SetupCallContacts() {
    $('[data-section=contacts')
        .find('.contacts-list')
        .html('');

    contacts.sort(Contacts.SortContacts);

    $.each(contacts, (index, contact) => {
        $('[data-section=contacts')
            .find('.contacts-list')
            .append(
                '<div class="phone-contact"><div class="phone-avatar other-' +
                    contact.name[0].toString().toLowerCase() +
                    '">' +
                    contact.name[0] +
                    '</div>' +
                    contact.name +
                    '<div class="call-actions"><i class="fas fa-phone-volume call-action-call"></i><i class="fas fa-sms call-action-text"></i></div></div>'
            );
        $('[data-section=contacts')
            .find('.contacts-list')
            .find('.phone-contact:last-child')
            .data('data', contact);
    });
}

export default { CreateCall, Call };