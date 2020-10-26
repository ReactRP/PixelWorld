RegisterNUICallback('ProcessInstall', function(data, cb)
    if data then
        if data.install then
            PW.TriggerServerCallback('pw_phone:server:store:installApplication', cb, data)
        elseif not data.install then
            PW.TriggerServerCallback('pw_phone:server:store:uninstallApplication', cb, data)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)
