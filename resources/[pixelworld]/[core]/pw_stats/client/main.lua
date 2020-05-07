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

RegisterNetEvent('pw_stats:client:doNeedsBoostForItem')
AddEventHandler('pw_stats:client:doNeedsBoostForItem', function(itemLabel, needsBoost, itemHealth)
    if characterLoaded then
        local progTime = 10
        local progText = 'Using ' .. itemLabel
        if needsBoost.wait.time ~= nil then
            progTime = needsBoost.wait.time
            if needsBoost.wait.text ~= nil then
                progText = needsBoost.wait.text
            end
        end
        if needsBoost.anim ~= nil then
            TriggerEvent('pw_stats:client:doItemAnim', needsBoost.anim, (needsBoost.animLength ~= nil and needsBoost.animLength or 20))
        end        
        if progTime > 0 then
            TriggerEvent('pw:progressbar:progress',
            {
                name = 'stats_use_item_prog',
                duration = (progTime * 1000),
                label = progText,
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                },
            },
            function(status)
                if not status then
                    UpdateNeedsBoost(needsBoost, itemHealth)
                end
            end)
        else
            UpdateNeedsBoost(needsBoost, itemHealth)
        end
    end
end)

function UpdateNeedsBoost(needsBoost, itemHealth)
    for k, v in pairs(needsBoost) do
        if k == 'add' or k == 'remove' then
            for t, q in pairs(v) do
                print(k, t, q)
                if itemHealth < 10 and t == 'hunger' then
                    exports.pw_notify:SendAlert('error', 'You Ate Old Food and Feel Your Stomach Hurting.', 4000)
                    TriggerEvent('pw_needs:client:updateNeeds', 'remove', 'hunger', 10)
                    doMouldyFoodHealthDecrease()
                elseif itemHealth < 10 and t == 'thirst' then
                    exports.pw_notify:SendAlert('error', 'You Drank Something Old and Feel Your Stomach Hurting.', 4000)
                    TriggerEvent('pw_needs:client:updateNeeds', 'remove', 'thirst', 10)
                    doMouldyFoodHealthDecrease()
                else
                    TriggerEvent('pw_needs:client:updateNeeds', k, t, q)
                end
            end    
        end
        if k == 'drugs' then
            for t, q in pairs(v) do
                TriggerEvent('pw_needs:client:updateDrugs', t, q)
            end
        end
    end
    if needsBoost.speedBoost ~= nil and needsBoost.speedBoost.len ~= nil and needsBoost.speedBoost.energy ~= nil then
        TriggerEvent('pw_stats:client:doQuickSpeedBoost', needsBoost.speedBoost.energy, needsBoost.speedBoost.len)
    end
end

function doMouldyFoodHealthDecrease()
    local playerPed = PlayerPedId()
    local currentHealth = GetEntityHealth(playerPed)
    SetEntityHealth(playerPed, (currentHealth - 10))
end

