RegisterNUICallback('SaveSettings', function(data, cb)
    Config.Settings = data
    TriggerServerEvent('pw_phone:server:settings:saveSettings', data)
    cb(true)
end)