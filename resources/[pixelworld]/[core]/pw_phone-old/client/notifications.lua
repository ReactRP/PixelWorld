phoneNumber = nil

function notificationNui(sub, show)
    SendNUIMessage({
        status = "notifications",
        sub = sub,
        show = show
    })
end

RegisterNetEvent('pw_phone:client:triggerNotification')
AddEventHandler('pw_phone:client:triggerNotification', function(alert, status, by, tweet)
    print(alert, status, by, tweet)
    notificationNui(alert, status)
    if not phoneSilent and status then
        TriggerServerEvent('pw_sound:server:PlayWithinDistance', 2.0, 'notification1', 0.4)
    end
end)

RegisterNetEvent('pw_phone:client:tweet')
AddEventHandler('pw_phone:client:tweet', function(alert, status, by, tweet)
    if status == "reply" then
        status = "replied"
    else
        status = "tweeted"
    end
    SendNUIMessage({
        status = "newTweet",
        stat = status,
        by = by,
        tweet = tweet
    })
    if not phoneSilent then
        TriggerServerEvent('pw_sound:server:PlayWithinDistance', 2.0, 'tweet', 0.4)
    end
end)