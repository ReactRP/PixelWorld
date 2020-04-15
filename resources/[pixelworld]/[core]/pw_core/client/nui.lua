PWBase['NUI'] = {
    OpenFrontScreen = function()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "loadFrontScreen",
        })
    end,
    OpenRequestedScreen = function(req, value, value2)
        if req then
            SendNUIMessage({
                action = req,
                value = value,
                value2 = value2
            })
        end
    end,
    DoAlertScreen = function(alert, message, time)
        SendNUIMessage({
            action = "noticeMessage",
            type = alert,
            message = message,
            time = time
        })
    end,
    CloseAllScreens = function()
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "shutDownNUI",
        })
        SetTimecycleModifier('default')
    end,
}

RegisterNetEvent('pw_core:nui:openFS')
AddEventHandler('pw_core:nui:openFS', function(alert, msg, time)
    PWBase['NUI'].OpenFrontScreen()
end)

RegisterNetEvent('pw_core:nui:showNotice')
AddEventHandler('pw_core:nui:showNotice', function(alert, msg, time)
    PWBase['NUI'].DoAlertScreen(alert, msg, time)
end)

RegisterNetEvent('pw_core:nui:loadLogin')
AddEventHandler('pw_core:nui:loadLogin', function(steam, email, fs)
    if not fs then
        PWBase['NUI'].OpenFrontScreen()
    end
    Citizen.Wait(501)
    PWBase['NUI'].OpenRequestedScreen("loadLogin", steam, email)
end)

RegisterNetEvent('pw_core:nui:loadCharacters')
AddEventHandler('pw_core:nui:loadCharacters', function(chars)
    Citizen.Wait(501)
    PWBase['NUI'].OpenRequestedScreen("loadChars", chars)
end)

RegisterNetEvent('pw_core:nui:loadCharacterSpawns')
AddEventHandler('pw_core:nui:loadCharacterSpawns', function(spawns)
    Citizen.Wait(501)
    PWBase['NUI'].OpenRequestedScreen("spawns", spawns)
end)

RegisterNUICallback("verifyLogin", function(data, cb)
    if data then
        TriggerServerEvent('pw_core:server:verifyUserLogin', data)
    end
end)

RegisterNUICallback("loadCharacters", function(data, cb)
    TriggerServerEvent('pw_core:server:loadCharacters')
end)

RegisterNUICallback("spawnSelected", function(data, cb)
    if data then
        TriggerServerEvent('pw_core:server:spawnSelected', data)
    end
end)

RegisterNUICallback("createCharacter", function(data, cb)
    if data then
        TriggerServerEvent('pw_core:server:createCharacter', data)
    end
end)

RegisterNUICallback("deleteCharacter", function(data, cb)
    if data then
        TriggerServerEvent('pw_core:server:deleteCharacter', data)
    end
end)

RegisterNUICallback("selectCharacter", function(data, cb)
    if data then
        TriggerServerEvent('pw_core:server:selectCharacter', data)
    end
end)