PW = nil
Spots, Safes = {}, {}
onCooldown, lockdownStarted = false, false

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        Spots = Config.Spots
        Safes = Config.Safes
        local pickedSafe = math.random(1,#Safes)
        for i = 1, #Safes do
            Safes[i].safe.robbed = false
            Safes[i].safe.obj = 0
            if i == pickedSafe then
                Safes[i].safe.active = true
                Safes[i].safe.robbing = false
                Safes[i].safe.disabled = false
            else
                Safes[i].safe.active = false
            end
            Safes[i].frame.inPlace = true
            Safes[i].frame.obj = 0
        end
        CheckCops()
    end
end)

RegisterServerEvent('pw_vangelico:server:updateSafe')
AddEventHandler('pw_vangelico:server:updateSafe', function(safe, spot, var, state)
    Safes[safe][spot][var] = state
    TriggerClientEvent('pw_vangelico:client:updateSafe', -1, safe, spot, var, state)
end)

RegisterServerEvent('pw_vangelico:server:removeFrame')
AddEventHandler('pw_vangelico:server:removeFrame', function(safe)
    Safes[safe].frame.inPlace = false
    TriggerClientEvent('pw_vangelico:client:updateSafe', -1, safe, 'frame', 'inPlace', false)
    TriggerClientEvent('pw_vangelico:client:removeFrame', -1, safe)
end)

RegisterServerEvent('pw_vangelico:server:awardSafe')
AddEventHandler('pw_vangelico:server:awardSafe', function(safe)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    local amount = math.random(Config.SafeAward.min, Config.SafeAward.max)
    _char:Inventory():Add().Default(1, 'valuegood', amount, {}, {}, function(done) end)

    TriggerEvent('pw_vangelico:server:updateSafe', safe, 'safe', 'robbed', true)
end)

RegisterServerEvent('pw_vangelico:server:awardItems')
AddEventHandler('pw_vangelico:server:awardItems', function(spot)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    local itemName, itemIndex, itemAmount

    if Spots[spot].type ~= nil then
        itemIndex = 4 -- necklace
        itemAmount = 1
    else
        itemIndex = math.random(1,#Config.Award)
        itemAmount = math.random(Config.Award[itemIndex].min,Config.Award[itemIndex].max)
    end
    _char:Inventory():Add().Default(1, Config.Award[itemIndex].item, itemAmount, {}, {}, function(done) end)
end)

RegisterServerEvent('pw_vangelico:server:updateLockdown')
AddEventHandler('pw_vangelico:server:updateLockdown', function(state)
    lockdownStarted = state
    TriggerClientEvent('pw_vangelico:client:updateLockdown', -1, state)
    if state then
        PW.SetTimeout(Config.TimeToLockdown * 60 * 1000, function()
            lockdownStarted = false
            TriggerClientEvent('pw_vangelico:client:updateLockdown', -1, false)
            onCooldown = true
            TriggerClientEvent('pw_vangelico:client:updateCooldown', -1, true)
            PW.SetTimeout(Config.Cooldown * 60 * 1000, function()
                onCooldown = false
                TriggerClientEvent('pw_vangelico:client:updateCooldown', -1, false)
                ResetEverything()
            end)
        end)
    end
end)

RegisterServerEvent('pw_vangelico:server:updateSpot')
AddEventHandler('pw_vangelico:server:updateSpot', function(spot, var, state)
    Spots[spot][var] = state
    TriggerClientEvent('pw_vangelico:client:updateSpot', -1, spot, var, state)
end)

RegisterServerEvent('pw_vangelico:server:playParticles')
AddEventHandler('pw_vangelico:server:playParticles', function(spot)
    local _src = source
    TriggerClientEvent('pw_vangelico:client:playParticles', -1, spot, _src)
end)

PW.RegisterServerCallback('pw_vangelico:server:getSpots', function(source, cb)
    cb(Spots, Safes, onCooldown, lockdownStarted)
end)

function ResetEverything()
    Spots = Config.Spots
    Safes = Config.Safes
    local pickedSafe = math.random(1,#Safes)
    for i = 1, #Safes do
        Safes[i].safe.robbed = false
        Safes[i].safe.obj = 0
        if i == pickedSafe then
            Safes[i].safe.active = true
            Safes[i].safe.robbing = false
            Safes[i].safe.disabled = false
        else
            Safes[i].safe.active = false
        end
        Safes[i].frame.inPlace = true
        Safes[i].frame.obj = 0
    end
    onCooldown = false
    lockdownStarted = false
    TriggerClientEvent('pw_vangelico:client:resetEverything', -1, Spots, Safes, onCooldown, lockdownStarted)
end

function CheckCops()
    PW.SetTimeout(10000, function()
        TriggerClientEvent('pw_vangelico:client:updateCops', -1, #PW.CheckOnlineDuty('police'))
        CheckCops()
    end)
end