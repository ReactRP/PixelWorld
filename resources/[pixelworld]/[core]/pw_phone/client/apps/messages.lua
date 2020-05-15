RegisterNUICallback('SendText', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:messages:SendText', cb, data)
end)

RegisterNetEvent('pw_phone:client:messages:receiveText')
AddEventHandler('pw_phone:client:messages:receiveText', function(from, text)
    -- Do play distance sound shizzle
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