RegisterNUICallback('NewTweet', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:twitter:newTweet', cb, { message = data.message, mentions = data.mentions, hashtags = data.hashtags })
end)

--RegisterNUICallback('NewTweet', function(data, cb)
--    Callbacks:ServerCallback('mythic_phone:server:NewTweet', { message = data.message, mentions = data.mentions, hashtags = data.hashtags }, cb)
--end)

RegisterNetEvent('pw_phone:client:MentionedInTweet')
AddEventHandler('pw_phone:client:MentionedInTweet', function(author)
    local app = GetAppData('twitter')
    PW.Print(app)
    UpdateAppUnread('twitter', app.unread + 1)

    PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
    exports['pw_notify']:SendAlert('inform', author .. ' Mentioned You In A Tweet', 2500, { ['background-color'] = '#039be5'  })
end)
