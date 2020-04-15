RegisterNUICallback("NUIFocusOff", function(data, cb)
    if bankOpen then
        bankOpen = false
        SetNuiFocus(false, false)
        --TriggerEvent('pw_voip:client:onlyAllowPTTOff')
        SendNUIMessage({
            action = "closeBankingTerminal"
        })
        
        TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    end
end)

RegisterNUICallback("requestOpenSavings", function(data, cb)
    if bankOpen then
        TriggerServerEvent('pw_banking:server:requestOpenSavings')
    end
end)

RegisterNUICallback("quickTransfer", function(data, cb)
    if data and bankOpen then
        TriggerServerEvent('pw_banking:server:quickTransfer', data)
    end
end)

RegisterNUICallback("completeExternalTransfer", function(data, cb)
    if data and bankOpen then
        TriggerServerEvent('pw_banking:server:completeExternalTransfer', data)
    end
end)

RegisterNUICallback("completeInternalTransfer", function(data, cb)
    if data and bankOpen then
        TriggerServerEvent('pw_banking:server:completeInternalTransfer', data)
    end
end)

RegisterNetEvent('pw_banking:client:externalTransferMessage')
AddEventHandler('pw_banking:client:externalTransferMessage', function(error, message)
    SendNUIMessage({
        action = "externalTransferMessage",
        error = error,
        message = message
    })
end)

RegisterNUICallback("createDebitCard", function(data, cb)
    if bankOpen and data then
        TriggerServerEvent('pw_banking:server:createDebitCard', data)
    end
end)