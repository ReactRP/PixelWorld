import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';
import Utils from '../../util/utils';
import Notif from '../../util/notification';
import Unread from '../../util/unread';

var webSiteNameRefresh = null;
var lastLoadedFrameSource = "lsweb.com";

let pixelworldWebsites = [
    { url:"drnick.xyz", actualUrl:"https://drnick.xyz/", friendlyName:"Dr Nick", secure:false},
    { url:"lsweb.com", actualUrl:"http://localhost/pwwebsys/sites/lsweb.net/", friendlyName:"LS Web", secure:true},
    { url:"weazelnews.com", actualUrl:"http://localhost/weazelnews.com", friendlyName:"Weazel News", secure:true},
]

$('#screen-content').on('keyup keydown blur', '#fakeChromeAddressBar', (event) => {
    if (event.which === 13) {
        loadWebSite($(event.currentTarget).val())
    }
});

$('#screen-content').on('click', '#chromeWebHome', (event) => {
    loadWebSite("lsweb.com");
});

function loadWebSite(link) {
    let requestedLinkWithoutHttps = link.replace("https://", "");
    let requestedLinkWithoutHttp = requestedLinkWithoutHttps.replace("http://", "");
    let requestedLink = requestedLinkWithoutHttp.replace("www.", "")

    let foundWeb = pixelworldWebsites.findIndex( find=> find['url'] === requestedLink);
    let cunt = foundWeb
    if(cunt !== -1) {
        let realUrl = pixelworldWebsites[cunt].actualUrl;
        let fakeUrl = pixelworldWebsites[cunt].url;
        let siteName = pixelworldWebsites[cunt].friendlyName;
        let secureSite = pixelworldWebsites[foundWeb].secure;

        lastLoadedFrameSource = realUrl.replace("https://", "");

        $("#currentTab").html('<p><strong>'+siteName+'</strong></p>');
        $("#shittyFuckingChromeIFrame").attr("src", realUrl);
        if (secureSite) {
            $("#fakeChromeAddressBar").val('https://www.'+fakeUrl);
            $("#secSearch").css({"color":"darkgreen"});
        } else {
            $("#fakeChromeAddressBar").val('http://www.'+fakeUrl);
            $("#secSearch").css({"color":"red"});
        }

    } else { // Link is Invalid
        $("#fakeChromeAddressBar").css({"color":"red"});
        setTimeout(function(){ // Fuck off Again
            $("#fakeChromeAddressBar").css({"color":"black"});
        }, 2000);
    }
}


window.addEventListener('message', (event) => {
    // messages from the nui interfaces thats needed 
});

window.addEventListener('chrome-open-app', () => {
    $('#webBrowser').animate({
        height: '100%'
    }, { duration: 1000 });
    loadWebSite("lsweb.com");

    webSiteNameRefresh = setInterval(function() {
        let iFrameURL = $("#shittyFuckingChromeIFrame").contents()["0"].location.href
        if (iFrameURL) {
            let currentLoadedFrameSource = iFrameURL.replace("https://", "");

            if (currentLoadedFrameSource !== lastLoadedFrameSource) {
    
                let foundWeb = pixelworldWebsites.findIndex( find=> find['actualUrl'] === 'https://'+currentLoadedFrameSource);
                if(foundWeb !== -1) {
                    let siteName = pixelworldWebsites[foundWeb].friendlyName;
                    let fakeUrl = pixelworldWebsites[foundWeb].url;
                    let secureSite = pixelworldWebsites[foundWeb].secure;
                    $("#currentTab").html('<p><strong>'+siteName+'</strong></p>');
                    if (secureSite) {
                        $("#fakeChromeAddressBar").val('https://www.'+fakeUrl);
                        $("#secSearch").css({"color":"darkgreen"});
                    } else {
                        $("#fakeChromeAddressBar").val('http://www.'+fakeUrl);
                        $("#secSearch").css({"color":"red"});
                    }
                    lastLoadedFrameSource = currentLoadedFrameSource;
                } 
            }
        }
    }, 3000);
});

window.addEventListener('chrome-custom-close-app', (data) => {
    $('#webBrowser').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('chrome-close-app', () => {
    clearInterval(webSiteNameRefresh);
});

export default { loadWebSite }