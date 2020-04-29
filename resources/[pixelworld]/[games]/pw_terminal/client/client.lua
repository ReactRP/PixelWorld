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

RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false)
    guiEnabled = false
    ClearPedTasks(PlayerPedId())
    action = 'failed'
    cb('ok')
end)