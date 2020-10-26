import App from '../../app'; 
import Config from '../../util/config';
import Data from '../../util/data';
import Notif from '../../util/notification';
import Messages from './messages';

var myNumber = null;
var contacts = null;
var messages = null;
var myJob = null;

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'receiveText':
            ReceiveText(
                event.data.data.sender,
                event.data.data.text
            )
            break;
    }
});

$('#screen-content').on('click', '.convo-top-bar .convo-action-addcontact', (e) => {
    let data = $('#message-convo-container').data('data');
    $('#convo-add-contact-number').val(data.number);
});

$('#screen-content').on('submit', '#convo-add-contact', (event) => {
    event.preventDefault();

    let data = $(event.currentTarget).serializeArray();

    let name = data[0].value;
    let number = data[1].value;

    $.post(
        Config.ROOT_ADDRESS + '/CreateContact',
        JSON.stringify({
            name: Utils.escapeHtml(name),
            number: number
        }),
        function(status) {
            if (status) {
                if (contacts == null) {
                    contacts = new Array();
                }

                Data.AddData('contacts', {
                    name: Utils.escapeHtml(name),
                    number: number,
                    index: contacts.length
                });

                let modal = M.Modal.getInstance($('#convo-add-contact-modal'));
                modal.close();

                $('#convo-add-contact-name').val('');
                $('#convo-add-contact-number').val('555-555-5555');

                Notif.Alert('Contact Added');
                App.RefreshApp();
            } else {
                Notif.Alert('Error Adding Contact');
            }
        }
    );
});

$('#screen-content').on('submit', '#convo-new-text', (event) => {
    event.preventDefault();
    let convoData = $('#message-convo-container').data('data');
    let data = $(event.currentTarget).serializeArray();

    let text = [
        {
            value: convoData.number
        },
        {
            value: data[0].value
        }
    ];

    Messages.SendNewText(text, (sent) => {
        if (sent) {
            $('.convo-texts-list').append(
                '<div class="text me-sender"><span>' +
                    data[0].value +
                    '</span><p>' +
                    moment(Date.now()).fromNowOrNow() +
                    '</p></div>'
            );

            Notif.Alert('Message Sent');

            $('#convo-input').val('');

            if ($('.convo-texts-list .text:last-child').offset() != null) {
                $('.convo-texts-list').animate(
                    {
                        scrollTop:
                            $('.convo-texts-list')[0].scrollHeight -
                            $('.convo-texts-list')[0].clientHeight
                    },
                    200
                );
            }
        }
    });
});

$('#screen-content').on('click', '#convo-delete-all', (e) => {
    e.preventDefault();
    let convoData = $('#message-convo-container').data('data');

    $.post(
        Config.ROOT_ADDRESS + '/DeleteConversation',
        JSON.stringify({
            number: convoData.number
        }),
        function(status) {
            if (status) {
                let cleanedMsgs = messages.filter(
                    m =>
                        m.sender != convoData.number &&
                        m.receiver != convoData.number
                );
                Data.StoreData('messages', cleanedMsgs);
                Notif.Alert('Conversation Deleted');
                App.GoBack();
            } else {
                Notif.Alert('Error Deleting Conversation');
            }
        }
    );
});

function ReceiveText(sender, text) {
    let viewingConvo = $('#message-convo-container').data('data');

    if (viewingConvo != null) {
        let contact = contacts.filter(c => c.number == viewingConvo.number)[0];
        if (viewingConvo.number == text.sender) {
            if (contact != null) {
                $('.convo-texts-list').append(
                    '<div class="text other-sender"><span class=" other-' +
                        contact.name[0] +
                        '">' +
                        text.message +
                        '</span><p>' +
                        moment(Date.now()).fromNowOrNow() +
                        '</p></div>'
                );
            } else {
                $('.convo-texts-list').append(
                    '<div class="text other-sender"><span>' +
                        text.message +
                        '</span><p>' +
                        moment(Date.now()).fromNowOrNow() +
                        '</p></div>'
                );
            }

            if ($('.convo-texts-list .text:last-child').offset() != null) {
                $('.convo-texts-list').animate(
                    {
                        scrollTop:
                            $('.convo-texts-list')[0].scrollHeight -
                            $('.convo-texts-list')[0].clientHeight
                    },
                    200
                );
            }
        }
    }

    if (messages == null) {
        messages = Data.GetData('messages');
    }

    if (myNumber == null) {
        myNumber = Data.GetData('myData').phone;
    }

    Data.AddData('messages', {
        sender: text.sender,
        receiver: myNumber,
        message: text.message,
        sent_time: text.sent_time,
        sender_read: 0,
        receiver_read: 0
    });
}

window.addEventListener('message-convo-open-app', (data) => {
    myNumber = Data.GetData('myData').phone;
    contacts = Data.GetData('contacts');
    messages = Data.GetData('messages');
    myJob = Data.GetData('job');

    $('#message-convo-container').data('data', data.detail);
    let texts = messages.filter(
        c =>
            (c.sender == data.detail.number && c.receiver == myNumber) ||
            (c.sender == myNumber && c.receiver == data.detail.number)
    );
    let contact = contacts.filter(c => c.number == data.detail.number)[0];

    if (contact != null) {
        $('.convo-action-addcontact').hide();
        $('.convo-top-number').html(contact.name);
        $('.convo-top-bar').attr(
            'class',
            'convo-top-bar other-' + contact.name[0]
        );
    } else {
        $('.convo-action-addcontact').show();
        $('.convo-top-number').html(data.detail.number);
    }

    $('.convo-texts-list').html('');
    $.each(texts, (index, text) => {
        let d = new Date(text.sent_time);
        if (text.sender == myNumber) {
            if(text.sender_read == 0) {
                $.post(Config.ROOT_ADDRESS + '/MarkTextRead',
                    JSON.stringify({
                        message_id: text.id,
                        number: myNumber,
                        othernumber: data.detail.number,
                        type: "sender"
                    }));
            }
            $('.convo-texts-list').append(
                '<div class="text me-sender"><span>' +
                    text.message +
                    '</span><p>' +
                    moment(d).fromNowOrNow() +
                    '</p></div>'
            );

            // Just incase losers wanna send themselves a text
            if (text.receiver == myNumber) {
                if (contact != null) {
                    $('.convo-texts-list').append(
                        '<div class="text other-sender"><span class=" other-' +
                            contact.name[0] +
                            '">' +
                            text.message +
                            '</span><p>' +
                            moment(d).fromNowOrNow() +
                            '</p></div>'
                    );
                } else {
                    $('.convo-texts-list').append(
                        '<div class="text other-sender"><span>' +
                            text.message +
                            '</span><p>' +
                            moment(d).fromNowOrNow() +
                            '</p></div>'
                    );
                }
            }
        } else {
            if(text.receiver_read == 0) {
                $.post(Config.ROOT_ADDRESS + '/MarkTextRead',
                    JSON.stringify({
                        message_id: text.id,
                        number: myNumber,
                        othernumber: data.detail.number,
                        type: "receiver"
                    }));
            }
            if (contact != null) {
                $('.convo-texts-list').append(
                    '<div class="text other-sender"><span class=" other-' +
                        contact.name[0] +
                        '">' +
                        text.message +
                        '</span><p>' +
                        moment(d).fromNowOrNow() +
                        '</p></div>'
                );
            } else {
                $('.convo-texts-list').append(
                    '<div class="text other-sender"><span>' +
                        text.message +
                        '</span><p>' +
                        moment(d).fromNowOrNow() +
                        '</p></div>'
                );
            }
        }
    });

    $.post(Config.ROOT_ADDRESS + '/ProcessMarkedRead', JSON.stringify({}));

    if ($('.convo-texts-list .text:last-child').offset() != null) {
        $('.convo-texts-list').animate(
            {
                scrollTop: $('.convo-texts-list .text:last-child').offset().top
            },
            25
        );
    }
});

window.addEventListener('message-convo-close-app', (data) => {
    myNumber = null;
    contacts = null;
    messages = null;
    $('#message-convo-container').removeData('data');
    $('.convo-texts-list').html('');
    $('.convo-top-bar').attr('class', 'convo-top-bar');
});

export default { ReceiveText };