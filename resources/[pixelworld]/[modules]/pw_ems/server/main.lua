PW = nil

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)

MySQL.ready(function ()
    --exports.pw_banking:createBuisnessAccount('ems', 1)
end)

function getHospitals()
    return Config.Hospitals
end

exports('getHospitals', function()
    return getHospitals()
end)


RegisterServerEvent('pw_ems:putInVehicle')
AddEventHandler('pw_ems:putInVehicle', function(target)
    local _src = source
    local _ems = exports.pw_core:getCharacter(_src)

    if _ems:Job().getJob().name == "ems" then
        TriggerClientEvent('pw_ems:putPedInVehicle', target)
    end
end)

RegisterServerEvent('pw_ems:server:updateHealth')
AddEventHandler('pw_ems:server:updateHealth', function(health)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    _char:Health().updateHealth(health)
end)

RegisterServerEvent('pw_ems:server:getHealth')
AddEventHandler('pw_ems:server:getHealth', function()
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local health = _char:Health().getHealth()
    TriggerClientEvent('pw_ems:loadHealth', _src, health)
end)

RegisterServerEvent('pw_ems:toggleSignOn')
AddEventHandler('pw_ems:toggleSignOn', function()
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Job().toggleDuty()

    if _char:Job().getJob().name == 'ems' then
        if _char:Job().getJob().duty then
            TriggerEvent('pw_eblips:add', {src = _src, color = 1})
        else
            TriggerEvent('pw_eblips:remove', _src)
        end
    end
end)

RegisterServerEvent('pw_ems:lifter')
AddEventHandler('pw_ems:lifter', function(target)
    local src = source
    TriggerClientEvent('pw_ems:uplift', target, src)
end)

RegisterServerEvent('pw_ems:liftup')
AddEventHandler('pw_ems:liftup', function(target)
    TriggerClientEvent('pw_ems:getPickUpState', target)
end)

RegisterServerEvent('pw_ems:reviveFinal')
AddEventHandler('pw_ems:reviveFinal', function(id)
    local _target = id
    TriggerClientEvent('pw_ems:revive', _target)    
end)

RegisterServerEvent('pw_ems:reviveS')
AddEventHandler('pw_ems:reviveS', function(id)
    local _src = source
    local _target = id
    TriggerClientEvent('pw_ems:giveCPR', _src, _target)
    TriggerClientEvent('pw_ems:getRevived', _target)
end)

RegisterServerEvent('pw_ems:healFinal')
AddEventHandler('pw_ems:healFinal', function(id)
    local _target = id
    TriggerClientEvent('pw_ems:heal', _target)
end)

RegisterServerEvent('pw_ems:healS')
AddEventHandler('pw_ems:healS', function(id)
    local _src = source
    local _target = id
    TriggerClientEvent('pw_ems:giveHeal', _src, _target)
    TriggerClientEvent('pw_ems:getHealed', _target)
end)

RegisterServerEvent('pw_ems:server:liftMe')
AddEventHandler('pw_ems:server:liftMe', function(target)
    local _src = source
    TriggerClientEvent('pw_ems:client:liftMe', target, _src)
end)

RegisterServerEvent('pw_ems:server:detachMe')
AddEventHandler('pw_ems:server:detachMe', function(target)
    TriggerClientEvent('pw_ems:client:detachMe', target)
end)

RegisterServerEvent('pw_ems:server:dropMe')
AddEventHandler('pw_ems:server:dropMe', function(target, force)
    local _src = source
    TriggerClientEvent('pw_ems:client:dropMe', target, _src, force)
end)

exports.pw_chat:AddChatCommand('pickup', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_ems:client:getPickUp', _src)
end, {
    help = "Pickup a player",
    params = {
    }
}, -1, { "ems", "doctor"})

exports.pw_chat:AddChatCommand('revive', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_needs:client:forceUpdate', _src, exports['pw_core']:getConfig("NewCharacters").needs)
    TriggerClientEvent('pw_ems:getClosestRevive', _src, args[1])
end, {
    help = "Revive a player",
    params = {{
        name = "'close' or ServerID",
        help = "Closest player or the ID of the player to revive"
    }}
}, -1, { "ems", "doctor" })

exports.pw_chat:AddChatCommand('heal', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_ems:getClosestHeal', _src, args[1])
end, {
    help = "Heal a player",
    params = {{
        name = "'close' or ServerID",
        help = "Closest player or the ID of the player to heal"
    }}
}, -1, { "ems", "doctor" })

exports['pw_chat']:AddAdminChatCommand('arevive', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_needs:client:forceUpdate', _src, exports['pw_core']:getConfig("NewCharacters").needs)
    TriggerClientEvent('pw_ems:getClosestRevive', _src, args[1])
end, {
    help = "Revive a player",
    params = {{
        name = "ServerID",
        help = "ID of the player to revive"
    }}
}, -1)

exports['pw_chat']:AddAdminChatCommand('aheal', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_ems:getClosestHeal', _src, args[1])
end, {
    help = "Heal a player",
    params = {{
        name = "ServerID",
        help = "ID of the player to heal"
    }}
}, -1)