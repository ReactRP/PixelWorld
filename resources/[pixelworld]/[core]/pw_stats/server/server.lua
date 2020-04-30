PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    local _char = exports['pw_core']:getCharacter(_src)
    local needsBoost = data.needs
    if needsBoost ~= nil and type(needsBoost) == "table" then
        if needsBoost.add ~= nil or needsBoost.remove ~= nil or needsBoost.drugs ~= nil or needsBoost.speedBoost ~= nil then
            TriggerClientEvent('pw_discord:client:overRide', _src, "Consuming "..data.label)
            --Item Removal
            _char:Inventory():Remove().Slot(data.slot, 1, function(done)
                
            end)
            TriggerClientEvent('pw_stats:client:doNeedsBoostForItem', _src, data.label, needsBoost, data.health)
        end
    end
end)