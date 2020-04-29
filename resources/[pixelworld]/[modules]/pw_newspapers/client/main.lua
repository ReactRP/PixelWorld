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
        SendNUIMessage({ status = "closePaper" })
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw_newspaper:client:buyNewspaper')
AddEventHandler('pw_newspaper:client:buyNewspaper', function(currentlyJailed)
    if characterLoaded then
        for k, v in pairs(Config.NewsModels) do
            local hash = GetHashKey(v)
            local newpaperStand = IsObjectNearPoint(hash, GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, 1.8)
            if newpaperStand then 
                local obj = GetClosestObjectOfType(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, 2.0, hash, false, false, false)
                TriggerEvent("pw:progressbar:progress", {
                    name = "getting_newspaper",
                    duration = 1500,
                    label = "Getting Newspaper",
                    useWhileDead = false,
                    canCancel = false,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    },
                }, function(status)
                    if not status then
                        TriggerEvent('pw_emotes:client:doAnEmote', 'newspaper')
                        SetNuiFocus(true, true)
                        TriggerEvent('pw_voip:client:onlyAllowPTTOn')
                        SendNUIMessage({
                            status = "openPaper",
                            jailList = currentlyJailed,
                            amountJailed = #currentlyJailed,
                        })
                    end
                end)
            end
        end
    end
end)

RegisterNUICallback("loseFocus", function(data, cb)
    SetNuiFocus(false, false)
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    TriggerEvent('pw_emotes:client:cancelCurrentEmote')
end)
