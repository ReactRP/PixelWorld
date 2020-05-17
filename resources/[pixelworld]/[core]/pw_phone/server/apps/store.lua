PW.RegisterServerCallback('pw_phone:server:store:installApplication', function(source, cb, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)

    MySQL.Async.execute("UPDATE `phone_applications` SET `enabled` = 1 WHERE `container` = @con AND `charid` = @cid", {['@cid'] = _char.getCID(), ['@con'] = data.app}, function(done)
        if done > 0 then
            MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(apps)
                local applications = {}
                for k, v in pairs(apps) do
                    table.insert(applications, {charid = v.charid, name = v.name, container = v.container, icon = v.icon, color = v.color, unread = v.unread, enabled = v.enabled, installable = v.installable, uninstallable = v.uninstallable, dumpable = v.dumpable, customExit = v.customExit, public = v.public, jobRequired = json.decode(v.jobRequired), description = v.description})
                end
                TriggerClientEvent('pw_phone:client:updateSettings', _src, "apps", applications)
                cb(true)
            end)
        else
            cb(false)
        end    
    end)

end)

PW.RegisterServerCallback('pw_phone:server:store:uninstallApplication', function(source, cb, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    
    MySQL.Async.execute("UPDATE `phone_applications` SET `enabled` = 0 WHERE `container` = @con AND `charid` = @cid", {['@cid'] = _char.getCID(), ['@con'] = data.app}, function(done)
        if done > 0 then
            MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(apps)
                local applications = {}
                for k, v in pairs(apps) do
                    table.insert(applications, {charid = v.charid, name = v.name, container = v.container, icon = v.icon, color = v.color, unread = v.unread, enabled = v.enabled, installable = v.installable, uninstallable = v.uninstallable, dumpable = v.dumpable, customExit = v.customExit, public = v.public, jobRequired = json.decode(v.jobRequired), description = v.description})
                end
                TriggerClientEvent('pw_phone:client:updateSettings', _src, "apps", applications)
                cb(true)
            end)
        else
            cb(false)
        end
    end)

end)