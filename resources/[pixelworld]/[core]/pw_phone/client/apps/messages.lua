local PW = nil

local markForDeletion = {
    ['sender'] = {},
    ['receiver'] = {}
}

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
            markForDeletion = {
                ['sender'] = {},
                ['receiver'] = {}
            }
        end
    else
        markForDeletion = {
            ['sender'] = {},
            ['receiver'] = {}
        }
    end
end)

RegisterNUICallback('SendText', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:messages:SendText', cb, data)
end)

RegisterNUICallback('DeleteConversation', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:messages:DeleteConversation', cb, data)
end)

RegisterNetEvent('pw_phone:client:messages:receiveText')
AddEventHandler('pw_phone:client:messages:receiveText', function(from, text)
    TriggerServerEvent('pw_sound:server:PlayWithinDistance', 5.0, 'notification1', 0.05 * (Config.Settings.volume / 100))
    exports['pw_notify']:SendAlert('inform', 'You Received A Text From ' .. from)
    
    SendNUIMessage({
        action = 'receiveText',
        data = {
            sender = from,
            text = text
        }
    })
end)

RegisterNUICallback('MarkTextRead', function(data, cb)
    if data then
        table.insert(markForDeletion[data.type], { ['message_id'] = tonumber(data.message_id), ['phone'] = data.number, ['other'] = data.othernumber })
    end
end)

RegisterNUICallback('ProcessMarkedRead', function(data, cb)
    TriggerServerEvent('pw_phone:server:phone:processReadMessages', markForDeletion)
    markForDeletion = {
        ['sender'] = {},
        ['receiver'] = {}
    }
end)
