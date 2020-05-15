PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

PW.RegisterServerCallback('pw_phone:server:setupJob', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    cb(_char:Job().getJob())
end)

RegisterServerEvent('pw:updateJobSS')
AddEventHandler('pw:updateJobSS', function(plyid)
    local _char = exports['pw_core']:getCharacter(plyid)
    TriggerClientEvent('pw_phone:client:updateSettings', plyid, "job", _char:Job().getJob())
end)

RegisterServerEvent('pw:toggleCallsignSS')
AddEventHandler('pw:toggleCallsignSS', function(plyid)
    local _char = exports['pw_core']:getCharacter(plyid)
    TriggerClientEvent('pw_phone:client:updateSettings', plyid, "job", _char:Job().getJob())
end)

RegisterServerEvent('pw:toggleDutySS')
AddEventHandler('pw:toggleDutySS', function(plyid)
    local _char = exports['pw_core']:getCharacter(plyid)
    TriggerClientEvent('pw_phone:client:updateSettings', plyid, "job", _char:Job().getJob())
end)

PW.RegisterServerCallback('pw_phone:server:setupData', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(sqlapps)
        local applications = {}
        if sqlapps[1] == nil then
            for i = 1, #Config.DefaultApps do
                MySQL.Sync.insert("INSERT INTO `phone_applications` (`charid`,`name`,`container`,`icon`,`color`,`unread`,`enabled`,`uninstallable`,`dumpable`,`customExit`,`public`,`jobRequired`) VALUES (@char, @name, @cont, @icon, @color, @unread, @enable, @uninst, @dump, @customExit, @public, @jobs)", {
                    ['@char'] = _char.getCID(),
                    ['@name'] = Config.DefaultApps[i].name,
                    ['@cont'] = Config.DefaultApps[i].container,
                    ['@icon'] = Config.DefaultApps[i].icon,
                    ['@color'] = Config.DefaultApps[i].color,
                    ['@unread'] = Config.DefaultApps[i].unread,
                    ['@enable'] = Config.DefaultApps[i].enabled,
                    ['@uninst'] = Config.DefaultApps[i].uninstallable,
                    ['@dump'] = Config.DefaultApps[i].dumpable,
                    ['@customExit'] = Config.DefaultApps[i].customExit,
                    ['@public'] = Config.DefaultApps[i].public,
                    ['@jobs'] = json.encode(Config.DefaultApps[i].jobRequired)
                })
            end
            applications = Config.DefaultApps
        else
            for i = 1, #Config.DefaultApps do
                local checker = MySQL.Sync.fetchScalar("SELECT `name` FROM `phone_applications` WHERE `charid` = @cid AND `container` = @con", {['@con'] = Config.DefaultApps[i].container, ['@cid'] = _char.getCID()})
                if checker == nil then
                    MySQL.Sync.insert("INSERT INTO `phone_applications` (`charid`,`name`,`container`,`icon`,`color`,`unread`,`enabled`,`uninstallable`,`dumpable`,`customExit`,`public`,`jobRequired`) VALUES (@char, @name, @cont, @icon, @color, @unread, @enable, @uninst, @dump, @customExit, @public, @jobs)", {
                        ['@char'] = _char.getCID(),
                        ['@name'] = Config.DefaultApps[i].name,
                        ['@cont'] = Config.DefaultApps[i].container,
                        ['@icon'] = Config.DefaultApps[i].icon,
                        ['@color'] = Config.DefaultApps[i].color,
                        ['@unread'] = Config.DefaultApps[i].unread,
                        ['@enable'] = Config.DefaultApps[i].enabled,
                        ['@uninst'] = Config.DefaultApps[i].uninstallable,
                        ['@dump'] = Config.DefaultApps[i].dumpable,
                        ['@customExit'] = Config.DefaultApps[i].customExit,
                        ['@public'] = Config.DefaultApps[i].public,
                        ['@jobs'] = json.encode(Config.DefaultApps[i].jobRequired)
                    })
                    
                    table.insert(sqlapps, {charid = _char.getCID(), name = Config.DefaultApps[i].name, container = Config.DefaultApps[i].container, icon = Config.DefaultApps[i].icon, color = Config.DefaultApps[i].color, unread = Config.DefaultApps[i].unread, enabled = Config.DefaultApps[i].enabled, uninstallable = Config.DefaultApps[i].uninstallable, dumpable = Config.DefaultApps[i].dumpable, customExit = Config.DefaultApps[i].customExit, public = Config.DefaultApps[i].public, jobRequired = json.encode(Config.DefaultApps[i].jobRequired)})
                end
            end
            
            for k, v in pairs(sqlapps) do
                table.insert(applications, {charid = v.charid, name = v.name, container = v.container, icon = v.icon, color = v.color, unread = v.unread, enabled = v.enabled, uninstallable = v.uninstallable, dumpable = v.dumpable, customExit = v.customExit, public = v.public, jobRequired = json.decode(v.jobRequired)})
            end
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
            local application = {charid = app2[1].charid, name = app2[1].name, container = app2[1].container, icon = app2[1].icon, color = app2[1].color, unread = app2[1].unread, enabled = app2[1].enabled, uninstallable = app2[1].uninstallable, dumpable = app2[1].dumpable, customExit = app2[1].customExit, public = app2[1].public, jobRequired = json.decode(app2[1].jobRequired)}
            cb(application)
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
        local applications = {}
        for k, v in pairs(apps) do
            table.insert(applications, {charid = v.charid, name = v.name, container = v.container, icon = v.icon, color = v.color, unread = v.unread, enabled = v.enabled, uninstallable = v.uninstallable, dumpable = v.dumpable, customExit = v.customExit, public = v.public, jobRequired = json.decode(v.jobRequired)})
        end
        TriggerClientEvent('pw_phone:client:updateSettings', _src, "apps", applications)
    end)
end)