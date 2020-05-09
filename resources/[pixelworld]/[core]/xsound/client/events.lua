RegisterNUICallback("data_status", function(data)
    if data.type == "finished" then
        PW.Print(data)
        TriggerServerEvent('xsound:server:stop', data.id, true)
    end
end)

RegisterNUICallback("updateTitle", function(data)
    TriggerServerEvent('xsound:server:updateTitle', data.id, data.title)
end)