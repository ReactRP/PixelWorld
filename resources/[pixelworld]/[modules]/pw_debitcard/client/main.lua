PW = nil
playerLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
            playerLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        playerLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)


RegisterNUICallback("NUIFocusOff", function(data, cb)
    SetNuiFocus(false, false)
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    SendNUIMessage({
        status = "closePin"
    })
end)

RegisterNUICallback("pinSuccess", function(data, cb)
    if data ~= nil then
        TriggerServerEvent('pw_debitcard:server:autherisePayment', data)
    end
end)

RegisterNetEvent('pw_debitcard:openPinTerminal')
AddEventHandler('pw_debitcard:openPinTerminal', function(trigger, ttype, amount, data)
    PW.TriggerServerCallback('pw_debitcard:server:requestCards', function(cards)
        if cards ~= nil and cards[1] ~= nil then
            SetNuiFocus(true, true)
            TriggerEvent('pw_voip:client:onlyAllowPTTOn')
            SendNUIMessage({
                status = "populateCards",
                cards = cards,
                reqamount = amount,
                trigger = trigger,
                type = ttype,
                data = data,
                statement = statementText
            })
        else
            exports['pw_notify']:SendAlert('error', 'You do not have a debit card to pay with, please visit a branch to order a card. or ensure one is on your person.', 5000)
        end
    end)
end)

