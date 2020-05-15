RegisterServerEvent('pw_phone:server:settings:saveSettings')
AddEventHandler('pw_phone:server:settings:saveSettings', function(data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    PW.Print(data)
    data.mynumber = _char:Phone().getNumber()
    MySQL.Async.fetchAll("SELECT * FROM `phone_settings` WHERE `charid` = @cid", {['@cid'] = _char:getCID()}, function(settngs)
        local query
        if settngs[1] ~= nil then
            query = "UPDATE `phone_settings` SET `data` = @data WHERE `charid` = @cid"
        else
            query = "INSERT INTO `phone_settings` (`charid`, `data`) VALUE (@cid, @data)"
        end
        MySQL.Sync.execute(query, {['@cid'] = _char.getCID(), ['@data'] = json.encode(data)})

        PW.Print(data)
        TriggerClientEvent('pw_phone:client:updateSettings', _src, "settings", data)
    end)
end)

PW.RegisterServerCallback('pw_phone:server:retreiveSettings', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local settings
    MySQL.Async.fetchAll("SELECT * FROM `phone_settings` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(res)
        if res[1] ~= nil then
            settings = {
                charid = _char.getCID(),
                settings = json.decode(res[1].data)
            }
        else
            settings = {
                charid = _char.getCID(),
                settings = Config.Settings,
            }
        end
        settings.settings['mynumber'] = _char:Phone().getNumber()
        PW.Print(settings.settings)
        cb(settings.settings)
    end)
end)