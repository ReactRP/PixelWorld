var Config = new Object();
Config.closeKeys = [27];
var pin = null

function listen() {
    window.addEventListener('resize', () => this.onResize());
  }
  
function onResize() {
    if(window.innerWidth % 2 === 0) {
      this.dom.lock.style.marginLeft = '0px';
    } else {
      this.dom.lock.style.marginLeft = '1px';
    }
  }
  
function onChange() {
    this.sounds.select.play();
    this.code = getCode();
    this.dom.code.textContent = this.code;
    if(this.code === pin) {
      this.verified = true;
      this.dom.lock.classList.add('verified');
      this.dom.status.textContent = 'UNLOCKED';
      this.sounds.success.play();
      $.post('http://pw_lockpick2/gameOver', JSON.stringify({ result: true }));
    } else {
      this.dom.lock.classList.remove('verified');
      this.dom.status.textContent = 'LOCKED';
      if(this.verified) {
        this.sounds.fail.play();
      }
      this.verified = false;
    }
  }
  
function getCode() {
    let code = '';
    for(let i = 0, len = this.dom.rows.length; i < len; i++) {
      let cell = this.dom.rows[i].querySelector('.is-selected .text');
      let num = cell.textContent;
      code += num;
    }
    return code;
  }

function setupDom() {
    this.dom = {};
    this.dom.lock = document.querySelector('.lock');
    this.dom.rows = document.querySelectorAll('.row');
    this.dom.code = document.querySelector('.code');
    this.dom.status = document.querySelector('.status');
  }

function setupAudio() {
    this.sounds = {};
    
    this.sounds.select = new Howl({
      src: [
        'https://jackrugile.com/sounds/misc/lock-button-1.mp3',
        'https://jackrugile.com/sounds/misc/lock-button-1.ogg'
      ],
      volume: 0.5,
      rate: 1.4
    });
    
    this.sounds.prev = new Howl({
      src: [
        'https://jackrugile.com/sounds/misc/lock-button-4.mp3',
        'https://jackrugile.com/sounds/misc/lock-button-4.ogg'
      ],
      volume: 0.5,
      rate: 1
    });
    
    this.sounds.next = new Howl({
      src: [
        'https://jackrugile.com/sounds/misc/lock-button-4.mp3',
        'https://jackrugile.com/sounds/misc/lock-button-4.ogg'
      ],
      volume: 0.5,
      rate: 1.2
    });
    
    this.sounds.hover = new Howl({
      src: [
        'https://jackrugile.com/sounds/misc/lock-button-1.mp3',
        'https://jackrugile.com/sounds/misc/lock-button-1.ogg'
      ],
      volume: 0.2,
      rate: 3
    });
    
    this.sounds.success = new Howl({
      src: [
        'https://jackrugile.com/sounds/misc/lock-online-1.mp3',
        'https://jackrugile.com/sounds/misc/lock-online-1.ogg'
      ],
      volume: 0.5,
      rate: 1
    });
    
    this.sounds.fail = new Howl({
      src: [
        'https://jackrugile.com/sounds/misc/lock-fail-1.mp3',
        'https://jackrugile.com/sounds/misc/lock-fail-1.ogg'
      ],
      volume: 0.6,
      rate: 1
    });
  }

function setupFlickity() {
    for(let i = 0, len = this.dom.rows.length; i < len; i++) {
      let row = this.dom.rows[i];
      let flkty = new Flickity( row, {
        selectedAttraction: 0.25,
        friction: 0.9,
        cellAlign: 'center',
        pageDots: false,
        wrapAround: true
      });
      flkty.lastIndex = 0;

      flkty.on('select', () => {
        if(flkty.selectedIndex !== flkty.lastIndex) {
          onChange();
        }
        flkty.lastIndex = flkty.selectedIndex;
      });
      
      row.addEventListener('mouseenter', () => {
        this.sounds.hover.play();			   
      });
    }
    
    this.dom.prevNextBtns = this.dom.lock.querySelectorAll('.flickity-prev-next-button');
    for(let i = 0, len = this.dom.prevNextBtns.length; i < len; i++) {
      let btn = this.dom.prevNextBtns[i];
      btn.addEventListener('click', () => {
        if(btn.classList.contains('previous')) {
          this.sounds.prev.play();
        } else {
          this.sounds.next.play();
        }
      });
    }
  }
  
  window.addEventListener('message', function(event) {
    if (event.data.type == "startGame") {
        pin = event.data.code;
        setupDom();
        setupFlickity();  
        setupAudio();
        onResize();
        listen();
        this.dom.code.textContent = '0000'
        this.verified = false;
        this.dom.lock.classList.remove('verified');
        this.dom.status.textContent = 'LOCKED';
        $('#lockContainer').fadeIn(500);
    } else if(event.data.type == "endGame") {
        $('#lockContainer').fadeOut(500);
    }
});

function closeGame()
{
    $.post('http://pw_lockpick2/gameOver', JSON.stringify({ result: false }));
}

$(function() {
    $("body").on("keydown", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeGame()
        }
    });

});