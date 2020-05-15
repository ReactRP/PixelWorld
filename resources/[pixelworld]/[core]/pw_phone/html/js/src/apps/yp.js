import App from '../app';
import Config from '../util/config';
import Utils from '../util/utils';
import Data from '../util/data';
import Notif from '../util/notification';
import Phone from './phone/phone';

var ads = null;

$('#screen-content').on('keyup', '#yp-search input', function (event) {
    event.preventDefault();

    let searchVal = $(event.currentTarget).val().toUpperCase();

    if (searchVal !== '') {
        $.each(
            $(event.currentTarget)
                .parent()
                .parent()
                .find('#yp-body')
                .find('.yp-post'),
            function (index, advert) {
                let data = $(advert).data('advert');

                if (
                    data.author.toUpperCase().includes(searchVal) ||
                    data.number.includes(searchVal) ||
                    data.title.toUpperCase().includes(searchVal) ||
                    data.message.toUpperCase().includes(searchVal)
                ) {
                    $(advert).fadeIn();
                } else {
                    $(advert).fadeOut();
                }
            }
        );
    } else {
        $.each(
            $(event.currentTarget)
                .parent()
                .parent()
                .find('#yp-body')
                .children(),
            function (index, advert) {
                $(advert).fadeIn();
            }
        );
    }
});

$('#screen-content').on('click', '#yp-body .yp-phone', function (event) {
    if ($(event.currentTarget).html() != Data.GetData('myData').phone) {
        App.OpenApp('phone', null, false);
        Phone.CreateCall($(event.currentTarget).html(), false, false);
    }
});

$('#screen-content').on('click', '#delete-ad', function (event) {
    $.post(Config.ROOT_ADDRESS + '/DeleteAd', JSON.stringify({}), () => {
        $('#yp-body').find('.yp-post-owned').fadeOut('normal', function () {
            $('#yp-body').find('.yp-post-owned').remove();
            Notif.Alert('Advertisement Deleted');
        });
        $('#delete-ad').fadeOut();
    });
});

$('#screen-content').on('submit', '#new-advert', function (event) {
    event.preventDefault();
    let data = $(event.currentTarget).serializeArray();

    let myData = Data.GetData('myData');
    let date = Date.now();
    let title = data[0].value;
    let message = data[1].value;

    $.post(Config.ROOT_ADDRESS + '/NewAd', JSON.stringify({
        date: date,
        title: title,
        message: message,
    }), function () {
        let modal = M.Modal.getInstance($('#create-advert-modal'));
        modal.close();
        $('#new-advert').trigger('reset');

        $(`#advert-${myData.src}`).addClass('yp-post-owned');
        $('#delete-ad').fadeIn();
        App.OpenApp('yp', null, false, false, false);
        Notif.Alert('Advertisement Posted');
    });
});

function AddAdvert(advert, store = true) {
    if ($(`#advert-${advert.id}`).length < 1) {
        $('#yp-body').prepend(`<div class="yp-post" id="advert-${advert.id}"><div class="yp-post-header"><span class="yp-author">${advert.author}</span><span class="yp-phone">${advert.number}</span></div><div class="yp-post-body"><div class="yp-post-title">${advert.title}</div><div class="yp-post-message">${advert.message}</div></div><div class="yp-post-timestamp">${moment(advert.date).fromNowOrNow()}</div></div>`);
        $('#yp-body .yp-post:first-child').data('advert', advert);
    } else {
        $(`#advert-${advert.id}`).find('.yp-post-title').html(advert.title);
        $(`#advert-${advert.id}`).find('.yp-post-message').html(advert.message);
        $(`#advert-${advert.id}`).find('.yp-post-timestamp').html(moment(advert.date).fromNowOrNow());
        $(`#advert-${advert.id}`).data('advert', advert);
        $(`#advert-${advert.id}`).parent().prepend($(`#advert-${advert.id}`));
    }
}

window.addEventListener('yp-open-app', () => {
    let phone = Data.GetData('myData').phone;
    ads = Data.GetData('adverts');

    ads.sort(Utils.DateSortOldest);

    $('#yp-body').html('');
    $.each(ads, function (index, advert) {
        AddAdvert(advert, false);
        if (advert.number == phone) {
            $('#yp-body .yp-post:first-child').addClass('yp-post-owned');
            $('#delete-ad').show();
        }
    });
});

export default { };