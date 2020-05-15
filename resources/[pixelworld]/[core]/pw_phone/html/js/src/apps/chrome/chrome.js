import App from '../../app';
import Config from '../../util/config';
import Data from '../../util/data';
import Utils from '../../util/utils';
import Notif from '../../util/notification';
import Unread from '../../util/unread';

let pixelworldWebsites = { // The Allowed Websites in the WebSystem
    "drnick.xyz":{
        actualUrl:"https://drnick.xyz",
        friendlyName:"Dr Nick",
        secure:false
    },
    "lsweb.com":{
        actualUrl:"http://localhost/pwwebsys/sites/lsweb.net/",
        friendlyName:"LS Web",
        secure:true
    }
}

var addressBarInput = document.getElementById('fakeChromeAddressBar');

$(function() {
    $(document).on('keyup', addressBarInput ,function(e){
        if (e.which === 13) {
            loadWebSite(this.value)
        }
    });
});

var website = document.getElementById('shittyFuckingFrame');
var currentTabName = document.getElementById('currentTabName');

function loadWebSite(link) {
    let requestedLinkWithoutHttps = link.replace("http://", "");
    requestedLinkWithoutHttps = requestedLinkWithoutHttps.replace("http://", "");
    let requestedLink = requestedLinkWithoutHttps.replace("www.", "");
    if (pixelworldWebsites[requestedLink]) {

        let name = requestedLink;
        let realUrl = pixelworldWebsites[requestedLink].actualUrl
        let isSecure = pixelworldWebsites[requestedLink].secure

        currentTabName = currentTabName.innerHTML = pixelworldWebsites[requestedLink].friendlyName
        website.src = realUrl
        secSearch = document.getElementById('secSearch');
        console.log(secSearch.innerHTML)
        if (isSecure) {
            addressBarInput.value = 'https://www.'+name
            secSearch.style.color = 'darkgreen'
            secSearch.innerHTML = '<i class="fas fa-lock"></i>'
        } else {
            addressBarInput.value = 'http://www.'+name
            secSearch.style.color = 'red'
            secSearch.innerHTML = '<i class="fas fa-unlock"></i>'
        }
    } else {
        addressBarInput.style.color = 'red'
        setTimeout(function(){ // Fuck off Again
            addressBarInput.style.color = 'black'
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
});

window.addEventListener('chrome-custom-close-app', (data) => {
    $('#webBrowser').animate({
        height: '0%'
    }, { duration: 1000 }).promise().then(() => {
        window.dispatchEvent(new CustomEvent('custom-close-finish', { detail: data.detail }));
    });
});

window.addEventListener('chrome-close-app', () => {
    
});

export default { loadWebSite }