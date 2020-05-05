PW = nil
characterLoaded, GLOBAL_PED, playerData = false, nil, nil

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
            GLOBAL_PED = PlayerPedId()
            StartMenuOpenChecks()
        else
            playerData = data
        end
    else
        TriggerEvent('pw_radialmenu:closeAllWheels', false)
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
    end
end)


local showMenu = false
local useMenu = 'mainMenu'

function StartMenuOpenChecks()
    Citizen.CreateThread(function()
        while characterLoaded do
            Citizen.Wait(5)
            if IsControlPressed(0, 348) then
                OpenMainMenu()
            end
        end
    end)
end


function OpenMainMenu()
    if IsPedFatallyInjured(GLOBAL_PED) then
        if playerData.job.duty then
            local deathWheel = playerData.job.name .. 'Dead'
            if menuConfigs[deathWheel] ~= nil then
                useMenu = deathWheel
            else
                useMenu = nil
            end
        else
            useMenu = nil
        end
    else
        menuConfigs[useMenu].data.wheels[1].labels[1] = string.upper(playerData.job.label)
        useMenu = 'mainMenu'
    end
    if useMenu ~= nil then
        showMenu = true
        SetCursorLocation(0.5, 0.5)
        SetNuiFocus(true, true)
        TriggerEvent('pw_voip:client:onlyAllowPTTOn')
        SendNUIMessage({
            type = 'init',
            data = menuConfigs[useMenu].data
        })
        PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
        while showMenu == true do Citizen.Wait(100) end
        Citizen.Wait(100)
        while IsControlPressed(0, 348) do Citizen.Wait(100) end
    end
end


RegisterNUICallback('closemenu', function(data, cb)
    showMenu = false
    TriggerEvent('pw_radialmenu:closeAllWheels', true)
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    cb('ok')
end)


RegisterNUICallback('sliceclicked', function(data, cb)
    showMenu = false
    TriggerEvent('pw_radialmenu:closeAllWheels', true)

    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
    PW.Print(data.trigger)
    if data.trigger[1] ~= nil then
        TriggerEvent(data.trigger[1], data.trigger[2])
    end

    cb('ok')
end)

RegisterNetEvent('pw_radialmenu:openJobWheel')
AddEventHandler('pw_radialmenu:openJobWheel', function()
    if characterLoaded and playerData ~= nil then
        if (menuConfigs[playerData.job.name] ~= nil) and playerData.job.duty then
            Citizen.Wait(200)

            SetNuiFocus(true, true)
            TriggerEvent('pw_voip:client:onlyAllowPTTOn')
            SendNUIMessage({
                type = 'init',
                data = menuConfigs[playerData.job.name].data
            })
            PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
        end
    end
end)

RegisterNetEvent('pw_radialmenu:closeAllWheels')
AddEventHandler('pw_radialmenu:closeAllWheels', function(focusOff)
    if focusOff then
        SetNuiFocus(false, false)
    end
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    SendNUIMessage({
        type = 'destroy'
    })
end)