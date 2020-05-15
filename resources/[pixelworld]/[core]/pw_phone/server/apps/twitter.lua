PW.RegisterServerCallback('pw_phone:server:twitterr:retreiveTweets', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local settings
    MySQL.Async.fetchAll("SELECT * FROM `phone_tweets`", {}, function(res)
        if res[1] ~= nil then
            cb(res)
        else
            cb({})
        end
    end)
end)

PW.RegisterServerCallback('pw_phone:server:twitter:newTweet', function(source, cb, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local author = _char.getTwitter()
    local users = exports['pw_core']:getEveryone("chars")
    
    if _char and data then
        data.author = _char.getTwitter()
        MySQL.Async.execute("INSERT INTO `phone_tweets` (`author_id`, `author`, `message`) VALUES (@cid, @auth, @mes)", {
            ['@cid'] = _char.getCID(),
            ['@auth'] = author,
            ['@mes'] = data.message
        }, function(updated)
            if updated > 0 then
                cb(data)
                MySQL.Async.fetchAll("SELECT * FROM `phone_tweets`", {}, function(tweets)
                    if tweets[1] ~= nil then
                        TriggerClientEvent('pw_phone:client:updateSettings', -1, "tweets", tweets)
                        TriggerClientEvent('pw_phone:client:twitter:registerTweet', -1, _src)
                        if data.mentions ~= nil then
                            for k, v in pairs(data.mentions) do
                                for k2, v2 in pairs(users) do
                                    if (v2.getTwitter()) == v then
                                        TriggerClientEvent('pw_phone:client:MentionedInTweet', v2.getSource(), author, _src)
                                        MySQL.Sync.execute("UPDATE `phone_applications` SET `unread` = `unread` + 1 WHERE `container` = 'twitter' AND `charid` = @cid", {['@cid'] = v2.getCID()})
                                        MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = v2.getCID()}, function(apps)
                                            TriggerClientEvent('pw_phone:client:updateSettings', v2.getSource(), "apps", apps)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end)