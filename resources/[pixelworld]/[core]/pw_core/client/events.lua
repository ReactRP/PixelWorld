RegisterNetEvent('pw:characters:cashAdjustment')
AddEventHandler('pw:characters:cashAdjustment', function(amount)
    if playerLoaded and playerData then
        playerData.cash = tonumber(amount)
    end
end)

RegisterNetEvent('pw:characters:bankAdjustment')
AddEventHandler('pw:characters:bankAdjustment', function(amount)
    if playerLoaded and playerData then
        playerData.bank = tonumber(amount)
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerLoaded and playerData then
        playerData.job.duty = toggle
        TriggerEvent('pw_voip:autheriseRadio', toggle, playerData.job)
        TriggerServerEvent('pw_voip:autheriseRadio', toggle, playerData.job)
        if toggle then
            if playerData.job.name == "police" then
                if not DecorExistOn(GLOBAL_PED, "player_cop") then
                    DecorSetBool(GLOBAL_PED, "player_cop", true)
                end
            end
            if playerData.job.name == "ems" then
                if not DecorExistOn(GLOBAL_PED, "player_ems") then
                    DecorSetBool(GLOBAL_PED, "player_ems", true)
                end
            end
            exports['pw_notify']:SendAlert('info', 'You have gone on duty', 5000)
        else
            if playerData.job.name == "police" or playerData.job.name == "ems" then
                if not DecorExistOn(GLOBAL_PED, "player_cop") then
                    DecorRemove(GLOBAL_PED, "player_cop")
                end
                if DecorExistOn(GLOBAL_PED, "player_ems") then
                    DecorRemove(GLOBAL_PED, "player_ems")
                end
            end
            exports['pw_notify']:SendAlert('info', 'You have gone off duty', 5000)
        end
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerLoaded and playerData then
        playerData.job = data
    end
end)

RegisterNetEvent('pw_core:client:enterCityFirstTime')
AddEventHandler('pw_core:client:enterCityFirstTime', function()
    DoScreenFadeOut(1000)
    Citizen.Wait(1001)
    RenderScriptCams(false, false, 500, false, false)
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed, -1045.02, -2750.25, 21.37, 0.0, 0.0, 0.0, false)
    SetEntityHeading(playerPed, 330.07)
    Citizen.Wait(1000)
    DoScreenFadeIn(1001)
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)
    TriggerServerEvent('pw_core:server:freeUpCharCreatorLocations')
    TriggerServerEvent('pw_core:server:playerReady')
    TriggerEvent('pw_core:client:playerReady')
end)

RegisterNetEvent('pw_core:client:transitiontoCharCreation')
AddEventHandler('pw_core:client:transitiontoCharCreation', function(sex, spawnId)
    if spawnId ~= nil then
        PWBase['NUI'].CloseAllScreens()
        TriggerEvent('pw_character:client:setupCharCreation', sex, characterCreatorLocations[spawnId].coords)
    end
end)

RegisterNetEvent('pw:switchCharacter')
AddEventHandler('pw:switchCharacter', function()
    DoScreenFadeOut(1000)
    Citizen.Wait(1001)
    local playerPed = PlayerPedId()
    PWBase.StartUp.SetupLoadCamera()
    SetEntityCoords(playerPed, 19.22, 7633.61, 14.78, 0.0, 0.0, 0.0, false)
    TriggerServerEvent('pw:switchCharacter')
    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
end)