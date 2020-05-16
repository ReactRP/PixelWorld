var ROOT_ADDRESS = 'http://pw_phone';

var entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '`': '&#x60;',
    '=': '&#x3D;'
};

var Apps = [
    {
        name: 'Contacts',
        container: 'contacts',
        icon: '<i class="fas fa-address-book"></i>',
        color: '#006064',
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'Phone',
        container: 'phone',
        icon: '<i class="fas fa-phone"></i>',
        color: '#01579b',
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'Messages',
        container: 'message',
        icon: '<i class="fas fa-comment-alt"></i>',
        color: '#311b92',
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'Bank',
        container: 'bank',
        icon: '<i class="fas fa-university"></i>',
        color: '#d7252a',
        unread: 0,
        enabled: true,
        customExit: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: true
    },
    {
        name: 'Twitter',
        container: 'twitter',
        icon: '<i class="fab fa-twitter"></i>',
        color: '#039be5',
        unread: 1,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'Yellow Pages',
        container: 'yp',
        icon: '<i class="fas fa-ad"></i>',
        color: '#f9a825',
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'Settings',
        container: 'settings',
        icon: '<i class="fas fa-cogs"></i>',
        color: '#404040',
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'App Store',
        container: 'store',
        icon: '<i class="fas fa-cogs"></i>',
        color: '#404040',
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: false
    },
    {
        name: 'Fake Chrome',
        container: 'chrome',
        icon: '<i class="fas fa-cogs"></i>',
        color: '#404040', 
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: Array(),
        customExit: 1
    },
    {
        name: 'MDT',
        container: 'mdt',
        icon: '<i class="fas fa-cogs"></i>',
        color: '#404040', 
        unread: 0,
        enabled: true,
        dumpable: 0,
        public: true,
        jobRequired: [4],
        customExit: true
    },
];


export default { ROOT_ADDRESS, entityMap, Apps };