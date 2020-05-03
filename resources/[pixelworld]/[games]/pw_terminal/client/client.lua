RegisterNetEvent('pw_terminal:client:open')
AddEventHandler('pw_terminal:client:open', function()
    SetNuiFocus(true,true)
    guiEnabled = true
    SendNUIMessage({
        type = "enableui",
        enable = true
    })
end)

RegisterNetEvent('pw_terminal:client:close')
AddEventHandler('pw_terminal:client:close', function()
    SetNuiFocus(false,false)
    guiEnabled = false
    SendNUIMessage({
        type = "enableui"
    })
end)

RegisterNetEvent('pw_terminal:client:sendEmailResult')
AddEventHandler('pw_terminal:client:sendEmailResult', function(state, mail)
    SendNUIMessage({
        type = "emailResult",
        check = state,
        email = mail
    })
end)

RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false)
    guiEnabled = false
    ClearPedTasks(PlayerPedId())
    action = 'failed'
    cb('ok')
end)

RegisterNUICallback('checkMail', function(data, cb)
    TriggerServerEvent('pw_chopshop:server:checkMail', data)
    cb('ok')
end)

RegisterNUICallback('signup', function(data, cb)
    TriggerServerEvent('pw_chopshop:server:signEmail', data)
    cb('ok')
end)