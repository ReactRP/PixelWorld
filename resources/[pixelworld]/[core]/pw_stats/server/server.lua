PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    PW.Print(data)
    local _char = exports['pw_core']:getCharacter(_src)
    local needsBoost = data.needs
    PW.Print(needsBoost)
    if needsBoost ~= nil and type(needsBoost) == "table" then
        if needsBoost.add ~= nil or needsBoost.remove ~= nil then
            TriggerClientEvent('pw_discord:client:overRide', _src, "Consuming "..data.label)
            for k, v in pairs(needsBoost) do
                if k ~= 'anim' and k ~= 'animLength' then
                    for t, q in pairs(v) do
                        print(k, t, q)
                        TriggerClientEvent('pw_needs:client:updateNeeds', _src, k, t, q)
                    end    
                end
            end
        end
        if needsBoost.anim ~= nil then
            TriggerClientEvent('pw_stats:client:doItemAnim', _src, needsBoost.anim, (needsBoost.animLength ~= nil and needsBoost.animLength or 20))
        end
        --Need to Add Item
        _char:Inventory():Remove().Slot(data.slot, 1, function(done)
            
        end)
    end
end)


needsBoost = {
    ['anim'] = "sandwich",
    ['animLength'] = 10,
    ['add'] = {
        ['hunger'] = 15.0,
    },
    ['remove'] = {
        ['thirst'] = 5.0,      
    }
}

print(json.encode(needsBoost))

--{"anim":"sandwich","remove":{"thirst":5.0},"add":{"hunger":15.0}}
