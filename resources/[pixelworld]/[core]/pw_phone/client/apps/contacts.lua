RegisterNUICallback('CreateContact', function(data, cb)
    TriggerServerEvent('pw_phone:server:contacts:createContact', data)
    cb(true)
end)

RegisterNUICallback('EditContact', function(data, cb)
    TriggerServerEvent('pw_phone:server:contacts:editContact', data)
    cb(true)
end)

RegisterNUICallback('DeleteContact', function(data, cb)
    TriggerServerEvent('pw_phone:server:contacts:deleteContact', data)
    cb(true)
end)