PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_altrevive:server:updateLocation')
AddEventHandler('pw_altrevive:server:updateLocation', function(location, var, state)
    Config.Locations[location][var] = state
    TriggerClientEvent('pw_altrevive:client:updateLocation', -1, location, var, state)
end)

RegisterServerEvent('pw_altrevive:server:updateNpc')
AddEventHandler('pw_altrevive:server:updateNpc', function(location, ped)
    Config.Locations[location].npcObj = ped
    TriggerClientEvent('pw_altrevive:client:updateNpc', -1, location, ped)
    if ped ~= nil then
        Config.Locations[location].npcSpawned = true
        TriggerClientEvent('pw_altrevive:client:updateLocation', -1, location, 'npcSpawned', true)
        TriggerClientEvent('pw_altrevive:client:updateLocation', -1, location, 'spawningNpc', false)
    else
        Config.Locations[location].npcSpawned = false
        TriggerClientEvent('pw_altrevive:client:updateLocation', -1, location, 'npcSpawned', false)
    end
end)

AddEventHandler('playerDropped', function()
    local _src = source
    for i = 1, #Config.Locations do
        if Config.Locations[i].inUse and Config.Locations[i].inUseBy == _src then
            Config.Locations[i].inUse = false
            Config.Locations[i].inUseBy = nil
            TriggerClientEvent('pw_altrevive:client:updateLocation', -1, i, 'inUse', false)
        end
    end
end)

RegisterServerEvent('pw_altrevive:server:requestRevive')
AddEventHandler('pw_altrevive:server:requestRevive', function(location)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local cashBalance = _char:Cash().getBalance()
    if cashBalance >= Config.Cost then
        if not Config.Locations[location].inUse then
            Config.Locations[location].inUse = true
            Config.Locations[location].inUseBy = _src
            TriggerClientEvent('pw_altrevive:client:updateLocation', -1, location, 'inUse', true)
            TriggerClientEvent('pw_altrevive:client:startrevive', _src, location)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Someone Is Already Being Treated Here.', length = 2500 })
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Not Enough Cash For a Revive.', length = 2500 })
    end
end)

RegisterServerEvent('pw_altrevive:server:completeRevive')
AddEventHandler('pw_altrevive:server:completeRevive', function(location, success)
    local _src = source
    if Config.Locations[location].inUseBy == _src then
        local _char = exports['pw_core']:getCharacter(_src)
        Config.Locations[location].inUseBy = nil
        Config.Locations[location].inUse = false
        if success then
            TriggerClientEvent('pw_ems:revive', _src)
            _char:Cash().removeCash(Config.Cost)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'info', text = 'Paid $'.. Config.Cost .. ' To Recieve Treatment.', length = 2500 })
        end
    end
end)

