RegisterNUICallback('NewTweet', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:twitter:newTweet', cb, { message = data.message, mentions = data.mentions, hashtags = data.hashtags })
end)

RegisterNetEvent('pw_phone:client:MentionedInTweet')
AddEventHandler('pw_phone:client:MentionedInTweet', function(author)
    local app = GetAppData('twitter')
    TriggerServerEvent('pw_sound:server:PlayWithinDistance', 5.0, 'tweet', 0.05 * (Config.Settings.volume / 100))
    exports['pw_notify']:SendAlert('inform', author .. ' Mentioned You In A Tweet', 2500, { ['background-color'] = '#039be5'  })
    UpdateAppUnread('twitter', app.unread + 1)
end)

RegisterNetEvent('pw_phone:client:twitter:registerTweet')
AddEventHandler('pw_phone:client:twitter:registerTweet', function(src)
    if GetPlayerServerId(PlayerId()) ~= src then
        SendNUIMessage({
            action = 'ReceiveNewTweet',
        })
    end
end)
