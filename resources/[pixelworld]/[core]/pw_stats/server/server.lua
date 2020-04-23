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
        if needsBoost.add ~= nil or needsBoost.remove ~= nil or needsBoost.drugs ~= nil then
            TriggerClientEvent('pw_discord:client:overRide', _src, "Consuming "..data.label)
            for k, v in pairs(needsBoost) do
                if k == 'add' or k == 'remove' then
                    for t, q in pairs(v) do
                        print(k, t, q)
                        TriggerClientEvent('pw_needs:client:updateNeeds', _src, k, t, q)
                    end    
                end
                if k == 'drugs' then
                    for t, q in pairs(v) do
                        TriggerClientEvent('pw_needs:client:updateDrugs', _src, t, q)
                    end
                end
            end
        end
        if needsBoost.anim ~= nil then
            TriggerClientEvent('pw_stats:client:doItemAnim', _src, needsBoost.anim, (needsBoost.animLength ~= nil and needsBoost.animLength or 20))
        end
        --Item Removal
        _char:Inventory():Remove().Slot(data.slot, 1, function(done)
            
        end)
    end
end)


needsBoost = {
    ['anim'] = "smokeweed",
    ['animLength'] = 10,
    ['remove'] = {
        ['stress'] = 20.0,      
    },
    ['drug'] = {
        ['weed'] = 2.0
    }
}

--print(json.encode(needsBoost))

--{"anim":"sandwich","remove":{"thirst":5.0},"add":{"hunger":15.0}}
--{"remove":{"stress":5.0},"animLength":10,"drug":{"weed":2.0},"anim":"smokeweed"}