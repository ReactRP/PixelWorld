PW = nil
characterLoaded, playerData = false, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            characterLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
    end
end)

RegisterNetEvent('pw_stats:client:doItemAnim')
AddEventHandler('pw_stats:client:doItemAnim', function(anim, length)
    if characterLoaded and anim ~= nil and length ~= nil then
        TriggerEvent('pw_emotes:client:doAnEmote', anim)
        local wait = length * 1000
        Citizen.Wait(wait)
        TriggerEvent('pw_emotes:client:cancelCurrentEmote')
    end
end)

RegisterNetEvent('pw_stats:client:doQuickSpeedBoost')
AddEventHandler('pw_stats:client:doQuickSpeedBoost', function(energy, length)
    if characterLoaded and length ~= nil and energy ~= nil then
        exports.pw_notify:SendAlert('info', 'You Feel the Energy Running Through Your Blood')
        local player = PlayerId()
        local speedMult = tonumber("1.".. energy)
        SetRunSprintMultiplierForPlayer(player, speedMult)
        local waitTime = length * 1000
        Citizen.Wait(waitTime)
        SetRunSprintMultiplierForPlayer(player, 1.00)
    end
end)
