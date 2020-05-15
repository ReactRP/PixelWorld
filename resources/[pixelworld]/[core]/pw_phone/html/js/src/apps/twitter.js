import App from '../app';
import Config from '../util/config';
import Utils from '../util/utils';
import Data from '../util/data';
import Notif from '../util/notification';

var tweets = null;
var notif = null;

window.addEventListener('message', (event) => {
    switch (event.data.action) {
        case 'ReceiveNewTweet':
            refreshTweets()
            break;
    }
});

$('#screen-content').on('submit', '#new-tweet', function (event) {
    event.preventDefault();

    let data = $(event.currentTarget).serializeArray();

    let tweet = {
        author: 'PleaseWork',
        message: data[0].value,
        time: Date.now()
    };

    Data.AddData('tweets', tweet);

    let pattern = /\B@[a-z0-9_-]+/gi;
    let mentions = tweet.message.match(pattern);
    $.each(mentions, function (index2, mention) {
        tweet.message = tweet.message.replace(
            mention,
            `<span class="mention" data-mention="${mention.replace(
                '@',
                ''
            )}">${mention}</span>`
        );
    });

    pattern = /\B#[a-z0-9_-]+/gi;
    let hashtags = tweet.message.match(pattern);
    $.each(hashtags, function (index2, hashtag) {
        tweet.message = tweet.message.replace(
            hashtag,
            `<span class="hashtag" data-hashtag="${hashtag.replace(
                '#',
                ''
            )}">${hashtag}</span>`
        );
    });

    $.post(
        Config.ROOT_ADDRESS + '/NewTweet',
        JSON.stringify({
            message: data[0].value,
            time: tweet.time,
            mentions: mentions,
            hashtags: hashtags
        }),
        function (status) {
            if (!status) {
                Notif.Alert('Failed Sending Tweet');
            } else {
                tweet.author = status.author;

                AddTweet(tweet);

                let modal = M.Modal.getInstance($('#send-tweet-modal'));
                modal.close();
                $('#new-tweet-msg').val('');

                Notif.Alert('Tweet Sent');
            }
        }
    );
});

$('#screen-content').on('click', '.tweet .mention', function (event) {
    let user = $(event.currentTarget).data('mention');

    $('#new-tweet-msg').val('' + user + ' ');

    let modal = M.Modal.getInstance($('#send-tweet-modal'));
    modal.open();
});

$('#screen-content').on('click', '.twitter-body .author', function (event) {
    let user = $(event.currentTarget).html();

    $('#new-tweet-msg').val('' + user + ' ');

    let modal = M.Modal.getInstance($('#send-tweet-modal'));
    modal.open();
});

function AddTweet(tweet) {
    let myData = Data.GetData('myData');
    let pattern = /\B@[a-z0-9_-]+/gi;
    let data = tweet.message.match(pattern);
    $.each(data, function (index2, mention) {
        tweet.message = tweet.message.replace(
            mention,
            `<span class="mention" data-mention="${mention.replace(
                '@',
                ''
            )}">${mention}</span>`
        );
    });

    pattern = /\B#[a-z0-9_-]+/gi;
    data = tweet.message.match(pattern);
    $.each(data, function (index2, hashtag) {
        tweet.message = tweet.message.replace(
            hashtag,
            `<span class="hashtag" data-hashtag="${hashtag.replace(
                '#',
                ''
            )}">${hashtag}</span>`
        );
    });

    /// TODO : Figure out & implement image embeding
    /*pattern = /https?[^<"]+/g;
    data = tweet.message.match(pattern);
    $.each(data, (index2, hashtag) => {
        tweet.message = tweet.message.replace(hashtag, `<span class="hashtag" data-hashtag="${hashtag.replace('#', '')}">' + hashtag + '</span>`);
    }); */
    
    $('.twitter-body').prepend(`
        <div class="tweet ${ tweet.message.includes(myData.twitter) ? 'tweethighlight' : '' }">
            <div class="avatar other-${tweet.author[0]
            .toString()
            .toLowerCase()}">${tweet.author[0]}</div>
            <div class="author">${tweet.author}</div>
            <div class="body">${tweet.message}</div>
            <div class="time" data-tooltip="${moment(tweet.time).format(
                'MM/DD/YYYY'
            )} ${moment(tweet.time).format('hh:mmA')}">${moment(tweet.time).fromNowOrNow()}</div>
        </div>`);

    $('.twitter-body .tweet:first-child .time').tooltip({
        position: top
    });
    $('.twitter-body .tweet:first-child').data('data', tweet);
}

function refreshTweets() {
    tweets = Data.GetData('tweets');

    if (tweets == null) {
        tweets = new Array();
    }

    tweets.sort(Utils.DateSortOldest);

    $('.twitter-body').html('');
    $.each(tweets, function (index, tweet) {
        AddTweet(tweet)
    });

    $.post(
        Config.ROOT_ADDRESS + '/markRead',
        JSON.stringify({
            app: 'twitter',
        }));
}

window.addEventListener('twitter-open-app', (data) => {
    tweets = Data.GetData('tweets');

    if (tweets == null) {
        tweets = new Array();
    }

    tweets.sort(Utils.DateSortOldest);

    $('.twitter-body').html('');
    $.each(tweets, function (index, tweet) {
        AddTweet(tweet)
    });

    $.post(
        Config.ROOT_ADDRESS + '/markRead',
        JSON.stringify({
            app: 'twitter',
        }));
});

function ReceiveNewTweet(tweet) {
    if (notif != null) { clearTimeout(notif); }

    if (tweets == null) {
        tweets = Data.GetData('tweets');
    }

    Data.AddData('tweets', tweet);

    $('.twitter-alert-header')
        .find('span')
        .html(tweet.author);
    $('.twitter-alert-body').html(tweet.message);
    $('.twitter-alert').fadeIn();
    notif = setTimeout(function () {
        $('.twitter-alert').fadeOut('normal', function () {
            $('.twitter-alert-header')
                .find('span')
                .html('');

            $('.twitter-alert-body').html('');

            notif = null;
        });
    }, 3000);

    if (App.GetCurrentApp() === 'twitter') {
        AddTweet(tweet);
    }
}

export default { ReceiveNewTweet, refreshTweets };