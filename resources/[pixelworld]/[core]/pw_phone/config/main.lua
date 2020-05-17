Config = {}

--[[
    These values are going to be all the allowed values for settings.
    Some of these may be dependant on other resources
]]--
Config.Ringtones = {
    { name = 'Ringtone 1', value = 1 },
    { name = 'Ringtone 2', value = 1 },
    { name = 'Ringtone 3', value = 1 },
}

Config.Settings = {
    volume = 100,
    wallpaper = 1, 
    ringtone = 1,
    text = 1,
    mynumber = "000-000-0000",
}

Config.DefaultApps = {
    {
        name = 'Contacts',
        container = 'contacts',
        icon = '<i class="fas fa-address-book"></i>',
        color = '#006064',
        unread = 0,
        enabled = true,
        uninstallable = false,
        installable = false,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "This application stores and manages your contacts to be able to call and text."
    },
    {
        name = 'Phone',
        container = 'phone',
        icon = '<i class="fas fa-phone"></i>',
        color = '#01579b',
        unread = 0,
        enabled = true,
        installable = false,
        uninstallable = false,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "This application enables your phone to make and receive telephone calls."
    },
    {
        name = 'Messages',
        container = 'message',
        icon = '<i class="fas fa-comment-alt"></i>',
        color = '#311b92',
        unread = 0,
        enabled = true,
        installable = false,
        uninstallable = false,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "This application enables your phone to send and receive text (SMS) messages."
    },
    {
        name = 'Settings',
        container = 'settings',
        icon = '<i class="fas fa-cogs"></i>',
        color = '#404040',
        unread = 0,
        enabled = true,
        installable = false,
        uninstallable = false,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "This application enables you to edit and update settings regarding your phone."
    },
    {
        name = 'App Store',
        container = 'store',
        icon = '<i class="fad fa-rocket"></i>',
        color = '#404040',
        unread = 0,
        enabled = true,
        installable = false,
        uninstallable = false,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "This application enables you to install and uninstall applications from the Application Store."
    },
    {
        name = 'Twitter',
        container = 'twitter',
        icon = '<i class="fab fa-twitter"></i>',
        color = '#039be5',
        unread = 0,
        enabled = false,
        installable = true,
        uninstallable = true,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "Twitter is one of the top Social Media Networking websites avaliable in our city."
    },
    {
        name = 'Bank', 
        container = 'bank',
        icon = '<i class="fas fa-university"></i>',
        color = '#d7252a',
        unread = 0,
        enabled = false,
        installable = true,
        uninstallable = true,
        dumpable = false,
        customExit = true,
        public = true,
        jobRequired = {},
        description= "This application is provided by PixelWorld Banking, to enable transactions performed on your phone."
    },
    {
        name = 'Fake Chrome',
        container = 'chrome',
        icon = '<i class="fad fa-planet-moon"></i>',
        color = '#490092',
        unread = 0,
        enabled = false,
        installable = true,
        uninstallable = true,
        dumpable = false,
        customExit = true,
        public = true,
        jobRequired = {},
        description= ""
    },
    {
        name = 'Yellow Pages',
        container = 'yp',
        icon = '<i class="fas fa-ad"></i>',
        color = '#f9a825',
        unread = 0,
        enabled = false,
        installable = true,
        uninstallable = true,
        dumpable = false,
        customExit = false,
        public = true,
        jobRequired = {},
        description= "Looking for advertisements? Sales? Services? the Yellow Pages is for you."
    },
    {
        name = 'MDT',
        container = 'police-mdt',
        icon = '<i class="fas fa-ad"></i>',
        color = '#f9a825',
        unread = 0,
        enabled = false,
        installable = true,
        uninstallable = true,
        dumpable = false,
        customExit = false,
        public = false,
        jobRequired = {4},
        description= ""
    },
}