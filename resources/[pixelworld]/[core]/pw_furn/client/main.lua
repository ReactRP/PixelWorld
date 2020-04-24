RegisterCommand('nui', function(source, args, raw)
    TriggerEvent('pw_furn:client:closeNui')
end, false)

RegisterNetEvent('pw_furn:client:openNui')
AddEventHandler('pw_furn:client:openNui', function(resource, data, focus)
    SetNuiFocus(true, true)
    TriggerEvent('pw_voip:client:onlyAllowPTTOn')
    SendNUIMessage({
        status = "show",
        resource = resource,
        values = data,
        focused = focus
    })
end)

RegisterNetEvent('pw_furn:client:closeNui')
AddEventHandler('pw_furn:client:closeNui', function(resource)
    SendNUIMessage({
        status = "hide",
    })
    SetNuiFocus(false, false)
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    TriggerEvent('pw_furn:client:nuiClosed')
end)

RegisterNetEvent('pw_furn:client:fadeBack')
AddEventHandler('pw_furn:client:fadeBack', function(resource)
    SetNuiFocus(true, true)
    TriggerEvent('pw_voip:client:onlyAllowPTTOn')
    SendNUIMessage({
        status = "fadein",
    })
end)

RegisterNUICallback("closeMenu", function(data, cb)
    TriggerEvent('pw_furn:client:closeNui')
end)

RegisterNUICallback("setFocus", function(data, cb)
    SendNUIMessage({
        status = "fadeout",
    })
    SetNuiFocus(data.method, data.method);
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
end)