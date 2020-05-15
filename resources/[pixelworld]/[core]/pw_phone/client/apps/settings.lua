RegisterNUICallback('SaveSettings', function(data, cb)
    TriggerServerEvent('pw_phone:server:settings:saveSettings', data)
    cb(true)
end)