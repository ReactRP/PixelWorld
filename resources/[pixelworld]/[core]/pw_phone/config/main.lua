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
        uninstallable = 0,
        dumpable = 0,
        customExit = 0
    },
    {
        name = 'Phone',
        container = 'phone',
        icon = '<i class="fas fa-phone"></i>',
        color = '#01579b',
        unread = 0,
        enabled = true,
        uninstallable = 0,
        dumpable = 0,
        customExit = 0
    },
    {
        name = 'Messages',
        container = 'message',
        icon = '<i class="fas fa-comment-alt"></i>',
        color = '#311b92',
        unread = 0,
        enabled = true,
        uninstallable = 0,
        dumpable = 0,
        customExit = 0
    },
    {
        name = 'Settings',
        container = 'settings',
        icon = '<i class="fas fa-cogs"></i>',
        color = '#404040',
        unread = 0,
        enabled = true,
        uninstallable = 0,
        dumpable = 0,
        customExit = 0
    },
    {
        name = 'App Store',
        container = 'store',
        icon = '<i class="fad fa-rocket"></i>',
        color = '#404040',
        unread = 0,
        enabled = true,
        uninstallable = 0,
        dumpable = 0,
        customExit = 0
    },
    {
        name = 'Bank',
        container = 'bank',
        icon = '<i class="fas fa-university"></i>',
        color = '#d7252a',
        unread = 0,
        enabled = true,
        uninstallable = true,
        dumpable = 0,
        customExit = 0
    },
    {
        name = 'Fake Chrome',
        container = 'chrome',
        icon = '<i class="fad fa-planet-moon"></i>',
        color = '#490092',
        unread = 0,
        enabled = false,
        uninstallable = true,
        dumpable = 0,
        customExit = 1
    },
    {
        name = 'Yellow Pages',
        container = 'yp',
        icon = '<i class="fas fa-ad"></i>',
        color = '#f9a825',
        unread = 0,
        enabled = false,
        uninstallable = true,
        dumpable = 0,
        customExit = 0
    },
}