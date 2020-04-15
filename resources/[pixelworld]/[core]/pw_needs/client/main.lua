-- Starting Variables
PW, characterLoaded, playerData, GLOBAL_PED, GLOBAL_COORDS = nil, false, nil, nil, nil
local isOnWeed, isOnCoke, isOnCrack, isOnMeth = false, false, false, false

Citizen.CreateThread(function()
    while PW == nil do
	TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
    Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            Citizen.Wait(200)
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            characterLoaded = true
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            startNeedsTick()
            letsDoEffects()
            doDrugShit()
        else
            playerData = data
        end
    else
        characterLoaded = false
        playerData = nil
        AnimpostfxStop("DrugsMichaelAliensFightIn")
        AnimpostfxStop("DrugsMichaelAliensFight")
        AnimpostfxStop("DrugsMichaelAliensFightOut")
        AnimpostfxStop("DrugsTrevorClownsFight")
        AnimpostfxStop("DrugsTrevorClownsFightIn")
        AnimpostfxStop("DrugsTrevorClownsFightOut")
        SetPedIsDrunk(GLOBAL_PED, 0)
        SetCamEffect(0)
        ResetPedMovementClipset(GLOBAL_PED, 1)
        AnimpostfxStop("Rampage")
        exports.pw_notify:PersistentAlert('end', 'PW_HUNGER_MSG')
        exports.pw_notify:PersistentAlert('end', 'PW_THIRST_MSG')
        exports.pw_notify:PersistentAlert('end', 'PW_STRESS_MSG')
        isOnWeed, isOnCoke, isOnCrack, isOnMeth = false, false, false, false
        hungerMessage, thirstMessage, stressMessage, drunkenState = false, false, false, false
    end
end)

RegisterNetEvent('pw_needs:client:forceUpdate')
AddEventHandler('pw_needs:client:forceUpdate', function(values)
    playerData['needs']['hunger'] = values.hunger
    playerData['needs']['thirst'] = values.thirst
    playerData['needs']['stress'] = values.stress
    playerData['needs']['drugs'] = values.drugs
    playerData['needs']['drunk'] = values.drunk
    TriggerEvent('pw_hud:client:receiveStats', playerData['needs'])
    TriggerServerEvent('pw_hud:client:saveStats', playerData['needs'])
    if IsPedFatallyInjured(GLOBAL_PED) then
        TriggerEvent('pw_ems:getClosestRevive')
        TriggerEvent('pw_ems:getClosestHeal')
    end
end)

function startNeedsTick()
    Citizen.CreateThread(function()
        while characterLoaded do
            if not IsPedFatallyInjured(PlayerPedId()) then
                for k, v in pairs(playerData['needs']) do
                    if k == "stress" then
                        playerData['needs'][k] = (playerData['needs'][k] + Config.ReductionValues[k])
                    elseif k == "drugs" then
                        for x, y in pairs(v) do
                            playerData['needs'][k][x] = (playerData['needs'][k][x] - Config.ReductionValues[k][x])
                        end
                    else
                        playerData['needs'][k] = (playerData['needs'][k] - Config.ReductionValues[k])
                    end
                end

                if playerData['needs']['hunger'] > 100 then playerData['needs']['hunger'] = 100; end
                if playerData['needs']['thirst'] > 100 then playerData['needs']['thirst'] = 100; end
                if playerData['needs']['stress'] > 100 then playerData['needs']['stress'] = 100; end
                if playerData['needs']['drugs']['weed'] > 100 then playerData['needs']['drugs']['weed'] = 100; end
                if playerData['needs']['drugs']['coke'] > 100 then playerData['needs']['drugs']['coke'] = 100; end
                if playerData['needs']['drugs']['meth'] > 100 then playerData['needs']['drugs']['meth'] = 100; end
                if playerData['needs']['drugs']['crack'] > 100 then playerData['needs']['drugs']['crack'] = 100; end
                if playerData['needs']['drunk'] > 100 then playerData['needs']['drunk'] = 100; end
                if playerData['needs']['hunger'] < 0 then playerData['needs']['hunger'] = 0; end
                if playerData['needs']['thirst'] < 0 then playerData['needs']['thirst'] = 0; end
                if playerData['needs']['stress'] < 0 then playerData['needs']['stress'] = 0; end
                if playerData['needs']['drugs']['weed'] < 0 then playerData['needs']['drugs']['weed'] = 0; end
                if playerData['needs']['drugs']['coke'] < 0 then playerData['needs']['drugs']['coke'] = 0; end
                if playerData['needs']['drugs']['meth'] < 0 then playerData['needs']['drugs']['meth'] = 0; end
                if playerData['needs']['drugs']['crack'] < 0 then playerData['needs']['drugs']['crack'] = 0; end
                if playerData['needs']['drunk'] < 0 then playerData['needs']['drunk'] = 0; end

                TriggerEvent('pw_hud:client:receiveStats', playerData['needs'])
                TriggerServerEvent('pw_hud:client:saveStats', playerData['needs'])
            end

            Citizen.Wait(10000)
        end
    end)
end

function letsDoEffects()
    local hungerMessage = false
    local thirstMessage = false
    local stressMessage = false
    local drunkenState = false
    Citizen.CreateThread(function()
        while characterLoaded do
            if not IsPedFatallyInjured(GLOBAL_PED) then
                if playerData['needs']['hunger'] < 10 then
                    if playerData['needs']['hunger'] <= 0.05 then
                        SetEntityHealth(GLOBAL_PED, 99)
                        exports.pw_notify:PersistentAlert('end', 'PW_HUNGER_MSG')
                        hungerMessage = false
                    end
                    if playerData['needs']['hunger'] > 0.05 then
                        if not hungerMessage then
                            hungerMessage = true
                            Citizen.CreateThread(function()
                                exports.pw_notify:PersistentAlert('start', 'PW_HUNGER_MSG', 'info', 'You are starting to feel peckish, eat something soon!')
                            end)
                        end
                    end
                else
                    exports.pw_notify:PersistentAlert('end', 'PW_HUNGER_MSG')
                    hungerMessage = false
                end

                if playerData['needs']['thirst'] < 10 then
                    if playerData['needs']['thirst'] <= 0.05 then
                        SetEntityHealth(GLOBAL_PED, 99)
                        exports.pw_notify:PersistentAlert('end', 'PW_THIRST_MSG')
                        thirstMessage = false
                    end
                    if playerData['needs']['thirst'] > 0.05 then
                        if not thirstMessage then
                            thirstMessage = true
                            Citizen.CreateThread(function()
                                exports.pw_notify:PersistentAlert('start', 'PW_THIRST_MSG', 'info', 'You are starting to feel thirsty, drink something soon!')
                            end)
                        end
                    end
                else
                    exports.pw_notify:PersistentAlert('end', 'PW_THIRST_MSG')
                    thirstMessage = false
                end

                if playerData['needs']['stress'] > 90 then
                    if playerData['needs']['stress'] >= 99.50 then
                        exports['pw_notify']:SendAlert('error', 'You have just suffered a heart attack due to stress', 5000)
                        SetEntityHealth(GLOBAL_PED, 99)
                        if stressMessage then
                            AnimpostfxStop("Rampage")
                            stressMessage = false
                            exports.pw_notify:PersistentAlert('end', 'PW_STRESS_MSG')
                        end
                    end 
                    if playerData['needs']['stress'] < 99.50 then
                        if not stressMessage then
                            stressMessage = true
                            AnimpostfxPlay("Rampage", -1, 1)
                            Citizen.CreateThread(function()
                                exports.pw_notify:PersistentAlert('start', 'PW_STRESS_MSG', 'info', 'You are starting to feel the effects of stress, consider doing some excercise.')
                            end)
                        end
                    end
                else
                    if stressMessage then
                        exports.pw_notify:PersistentAlert('end', 'PW_STRESS_MSG')
                        stressMessage = false
                        AnimpostfxStop("Rampage")
                    end
                end

                if playerData['needs']['drunk'] > 5 then
                    if playerData['needs']['drunk'] >= 99.95 then
                        SetEntityHealth(GLOBAL_PED, 99)
                        if drunkenState then
                            SetPedIsDrunk(GLOBAL_PED, 0)
                            SetCamEffect(0)
                            ResetPedMovementClipset(GLOBAL_PED, 1)
                            drunkenState = false
                        end
                    end
                    if playerData['needs']['drunk'] < 99.95 then
                        if not drunkenState then
                            SetPedIsDrunk(GLOBAL_PED, true)
                            if not HasAnimSetLoaded("move_m@drunk@verydrunk") then
                                RequestAnimSet("move_m@drunk@verydrunk")
                                Citizen.Wait(10)
                            end
                            SetCamEffect(1)
                            SetPedMovementClipset(GLOBAL_PED, "move_m@drunk@verydrunk", 1)
                            drunkenState = true
                        end
                    end
                else
                    if drunkenState then
                        SetPedIsDrunk(GLOBAL_PED, 0)
                        SetCamEffect(0)
                        ResetPedMovementClipset(GLOBAL_PED, 1)
                        drunkenState = false
                    end
                end
            else
                hungerMessage = false
                thirstMessage = false
                stressMessage = false
                drunkenState = false
                SetPedIsDrunk(GLOBAL_PED, 0)
                SetCamEffect(0)
                ResetPedMovementClipset(GLOBAL_PED, 1)
                AnimpostfxStop("Rampage")
                exports.pw_notify:PersistentAlert('end', 'PW_HUNGER_MSG')
                exports.pw_notify:PersistentAlert('end', 'PW_THIRST_MSG')
                exports.pw_notify:PersistentAlert('end', 'PW_STRESS_MSG')
            end
            Citizen.Wait(500)
        end
    end)
end

function doCokeHealthDecrease()
    Citizen.CreateThread(function()
        while isOnCoke do   
            if IsPedRunning(GLOBAL_PED) then
                local currentHealth = GetEntityHealth(GLOBAL_PED)
                if (currentHealth - 100) > 10 then
                    SetEntityHealth(GLOBAL_PED, (currentHealth - 2))
                end
            end
            Citizen.Wait(500)
        end
    end)
end

function Drugs1()
    AnimpostfxPlay("DrugsMichaelAliensFightIn", 3.0, 0)
    Citizen.Wait(8000)
    AnimpostfxPlay("DrugsMichaelAliensFight", 3.0, 0)
    Citizen.Wait(8000)
    AnimpostfxPlay("DrugsMichaelAliensFightOut", 3.0, 0)
    AnimpostfxStop("DrugsMichaelAliensFightIn")
    AnimpostfxStop("DrugsMichaelAliensFight")
    AnimpostfxStop("DrugsMichaelAliensFightOut")
end

function Drugs2()
    AnimpostfxPlay("DrugsTrevorClownsFightIn", 3.0, 0)
    Citizen.Wait(8000)
    AnimpostfxPlay("DrugsTrevorClownsFight", 3.0, 0)
    Citizen.Wait(8000)
    AnimpostfxPlay("DrugsTrevorClownsFightOut", 3.0, 0)
    AnimpostfxStop("DrugsTrevorClownsFight")
    AnimpostfxStop("DrugsTrevorClownsFightIn")
    AnimpostfxStop("DrugsTrevorClownsFightOut")
end

RegisterNetEvent('pw_needs:client:usedJoint')
AddEventHandler('pw_needs:client:usedJoint', function(data)
    AddArmourToPed(GLOBAL_PED, 20)
    playerData['needs']['stress'] = (playerData['needs']['stress'] - 3.0)
    playerData['needs']['drugs']['weed'] = (playerData['needs']['drugs']['weed'] + 2.0)
    RequestAnimSet("move_m@hipster@a") 
    while not HasAnimSetLoaded("move_m@hipster@a") do
        Citizen.Wait(0)
    end  
    TaskStartScenarioInPlace(GLOBAL_PED, "WORLD_HUMAN_SMOKING_POT", 0, 0)
    Citizen.Wait(5000)
    ClearPedTasksImmediately(GLOBAL_PED)
end)

function doDrugShit()
    Citizen.CreateThread(function()
        while characterLoaded do
            if not IsPedFatallyInjured(GLOBAL_PED) then
                if playerData['needs']['drugs']['coke'] > 0.05 then
                    -- speed - health decrease
                    RestorePlayerStamina(PlayerId(), 1.0)
                    if not isOnCoke then
                        isOnCoke = true
                        doCokeHealthDecrease()
                        SetRunSprintMultiplierForPlayer(PlayerId(), 1.40)
                        Citizen.CreateThread(function()
                            while isOnCoke do
                                local random = math.random(2)
                                if random == 1 then
                                    Drugs1()
                                else
                                    Drugs2()
                                end
                                Citizen.Wait(30000)
                            end
                        end)
                    end
                else
                    isOnCoke = false
                    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                end

                if playerData['needs']['drugs']['crack'] > 0.05 then
                    -- swim speed + armour
                else

                end

                if playerData['needs']['drugs']['meth'] > 0.05 then
                    -- speed + armour
                else

                end
            end
            Citizen.Wait(500)
        end
    end)
end
