PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_notify:server:sendEmergency')
AddEventHandler('pw_notify:server:sendEmergency', function(jobs, code, codeText, message)
    for k, v in pairs(jobs) do
        local players = exports['pw_core']:getDutyPlayers(v)
        for t, q in pairs(players) do
            TriggerClientEvent('pw_emergencynotif:client:processNotification', q.source, code, codeText, message)
        end
    end
end)