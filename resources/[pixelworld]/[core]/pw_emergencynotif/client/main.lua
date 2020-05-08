PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            characterLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(500)
        if characterLoaded then
            local playerPed = PlayerPedId()
            if playerPed ~= GLOBAL_PED then
                GLOBAL_PED = playerPed
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw_emergencynotif:client:processNotification')
AddEventHandler('pw_emergencynotif:client:processNotification', function(code, codeText, message)
    if characterLoaded then
        SendNUIMessage({
            action = 'showNotification',
            content = { ['code'] = code, ['codeText'] = codeText, ['message'] = message}
        })
    end
end)

--[[
Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent('pw_notify:server:sendEmergencyAll', "10-13A", "Legion Square Carpark")
        end
        Citizen.Wait(0)
    end
end)]]