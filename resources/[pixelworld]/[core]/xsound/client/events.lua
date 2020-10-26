RegisterNUICallback("data_status", function(data)
    if data.type == "finished" then
        TriggerServerEvent('xsound:server:stop', data.id, true)
    end
end)

RegisterNUICallback("updateTitle", function(data)
    TriggerServerEvent('xsound:server:updateTitle', data.id, data.title)
end)

RegisterNUICallback("sendTitle", function(data)
    TriggerServerEvent('pw_properties:server:addSong', data)
end)