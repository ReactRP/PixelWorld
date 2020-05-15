PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

PW.RegisterServerCallback('pw_phone:server:setupData', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(sqlapps)
        if sqlapps[1] == nil then
            for i = 1, #Config.DefaultApps do
                MySQL.Sync.insert("INSERT INTO `phone_applications` (`charid`,`name`,`container`,`icon`,`color`,`unread`,`enabled`,`uninstallable`,`dumpable`,`customExit`) VALUES (@char, @name, @cont, @icon, @color, @unread, @enable, @uninst, @dump, @customExit)", {
                    ['@char'] = _char.getCID(),
                    ['@name'] = Config.DefaultApps[i].name,
                    ['@cont'] = Config.DefaultApps[i].container,
                    ['@icon'] = Config.DefaultApps[i].icon,
                    ['@color'] = Config.DefaultApps[i].color,
                    ['@unread'] = Config.DefaultApps[i].unread,
                    ['@enable'] = Config.DefaultApps[i].enabled,
                    ['@uninst'] = Config.DefaultApps[i].uninstallable,
                    ['@dump'] = Config.DefaultApps[i].dumpable,
                    ['@customExit'] = Config.DefaultApps[i].customExit
                })
            end
            applications = Config.DefaultApps
        else
            applications = sqlapps
        end
        local data = {
            { name = "myData", data = { id = _char.getCID(), name = _char.getFullName(), phone = _char:Phone().getNumber(), twitter = _char.getTwitter(), email = _char.getEmail(), src = _src }},
            { name = "apps", data = applications}
        }
        cb(data)
    end)
end)


PW.RegisterServerCallback('pw_phone:server:all:getAppData', function(source, cb, app)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `container` = @app AND `charid` = @cid", {['@cid'] = _char.getCID(), ['@app'] = app}, function(app2)
        if app2[1] ~= nil then
            cb(app2[1])
        else
            cb(nil)
        end
    end)
end)

PW.RegisterServerCallback('pw_phone:server:all:updateUnread', function(source, cb, app, unread)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    --MySQL.Async.execute("UPDATE `phone_applications` SET `unread` = @unread WHERE `container` = @app AND `charid` = @cid", {['@cid'] = _char.getCID(), ['@app'] = app, ['@unread'] = unread}, function(app2)
    --    if app2 > 0 then
    --        cb(true)
    --    else
    --        cb(false)
    --    end
    --end)
    cb(true)
end)

RegisterServerEvent('pw_phone:server:all:markRead')
AddEventHandler('pw_phone:server:all:markRead', function(app)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Sync.execute("UPDATE `phone_applications` SET `unread` = @unread WHERE `container` = @app AND `charid` = @cid", {['@cid'] = _char.getCID(), ['@app'] = app, ['@unread'] = 0})
    MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(apps)
        TriggerClientEvent('pw_phone:client:updateSettings', _src, "apps", apps)
    end)
end)