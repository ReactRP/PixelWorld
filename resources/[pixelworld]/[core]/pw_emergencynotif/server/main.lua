PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_notify:server:sendEmergencySpecificJobs')
AddEventHandler('pw_notify:server:sendEmergencySpecificJobs', function(jobs, code, message)
    if jobs and type(jobs) == "table" and code and message then
        MySQL.Async.fetchAll("SELECT * FROM `alert_codes` WHERE `code_id` = @code", {['@code'] = code}, function(alert)
            if alert[1] ~= nil then
                if alert[1].sendAlert then
                    for k, v in pairs(jobs) do
                        local players = exports['pw_core']:getDutyPlayers(v)
                        for t, q in pairs(players) do
                            TriggerClientEvent('pw_emergencynotif:client:processNotification', q.source, alert[1].code_id, alert[1].code_title, message)
                        end
                    end
                end
            end
        end)
    else
        print(' ^1[ERROR] - You have not specified the correct syntax to submit an emergency alert - L23 SERVER.LUA')
    end
end)

RegisterServerEvent('pw_notify:server:sendEmergencyAll')
AddEventHandler('pw_notify:server:sendEmergencyAll', function(code, message)
    if code and message then
        MySQL.Async.fetchAll("SELECT * FROM `alert_codes` WHERE `code_id` = @code", {['@code'] = code}, function(alert)
            if alert[1] ~= nil then
                if alert[1].sendAlert then
                    if alert[1].jobs ~= nil then
                        local jobs = json.decode(alert[1].jobs)
                        if type(jobs) == "table" then
                            for k, v in pairs(jobs) do
                                local players = exports['pw_core']:getDutyPlayers(v)
                                for t, q in pairs(players) do
                                    TriggerClientEvent('pw_emergencynotif:client:processNotification', q.source, alert[1].code_id, alert[1].code_title, message)
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        print(' ^1[ERROR] - You have not specified the correct syntax to submit an emergency alert - L48 SERVER.LUA')
    end
end)