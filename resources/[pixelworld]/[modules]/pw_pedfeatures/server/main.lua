PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_pedfeatures:server:getFeatures', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.fetchScalar('SELECT `features` FROM `characters` WHERE `cid` = @cid', { ['@cid'] = _char.getCID() }, function(settings)
        if settings ~= nil then
            cb(json.decode(settings))
        else
            settings = { ['mood'] = 'default', ['walk'] = 'default' }
            MySQL.Async.execute('UPDATE `characters` SET `features` = @features WHERE `cid` = @cid', { ['@features'] = json.encode(settings), ['@cid'] = _char.getCID() }, function() end)
            cb(settings)
        end
    end)
end)

RegisterServerEvent('pw_pedfeatures:server:saveFeatures')
AddEventHandler('pw_pedfeatures:server:saveFeatures', function(features)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.execute('UPDATE `characters` SET `features` = @features WHERE `cid` = @cid', { ['@features'] = json.encode(features), ['@cid'] = _char.getCID() }, function()
        
    end)
end)

exports.pw_chat:AddChatCommand('walk', function(source, args, rawCommand)
    TriggerClientEvent('pw_pedfeatures:client:walkMenu', source)
end, {
    help = 'Open player walking style menu',
    params = {}
}, -1)

exports.pw_chat:AddChatCommand('mood', function(source, args, rawCommand)
    TriggerClientEvent('pw_pedfeatures:client:moodMenu', source)
end, {
    help = 'Open player mood menu',
    params = {}
}, -1)