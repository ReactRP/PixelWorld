PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

MySQL.ready(function ()
    MySQL.Async.fetchAll("SELECT * FROM `phone_simcards`", {}, function(cards)
        for k,v in pairs(cards) do
            simCards[v.number] = simCard(v.number)
        end
    end)
    MySQL.Sync.execute("DELETE FROM `phone_tweets`", {})
end)

PW.RegisterServerCallback('pw_phone:server:requestActiveNumber', function(source, cb)
    local _src = source
    local _cid = exports['pw_core']:getCharacter(_src).getCID()
    MySQL.Async.fetchAll("SELECT * FROM `phone_simcards` WHERE `cid` = @cid AND `active` = 1", {['@cid'] = _cid}, function(sa)
        if sa[1] ~= nil then
            cb(sa[1].number)
        else
            cb(nil)
        end
    end)
end)

PW.RegisterServerCallback('pw_phone:server:checkUnreadMessages', function(source, cb, number)
    local _src = source
    local _num = number
    local _unreadAmount = 0
end)

PW.RegisterServerCallback('pw_phone:server:openRadio', function(source, cb)
    local _src = source
    local _cid = exports['pw_core']:getCharacter(_src)
    _cid:Inventory().getItemCount('radio', function(radioCount)
        if radioCount ~= nil and radioCount > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_phone:server:openPhone', function(source, cb)
    local _src = source
    local _cid = exports['pw_core']:getCharacter(_src)
    
    _cid:Inventory().getItemCount('phone', function(phoneCount)
        MySQL.Async.fetchAll("SELECT * FROM `phone_simcards` WHERE `cid` = @cid AND `active` = 1", {['@cid'] = _cid.getCID()}, function(active)
            if active[1] ~= nil then
                if phoneCount ~= nil and phoneCount > 0 then
                    cb(true, active[1].number)
                else
                    cb(false, "nophone")
                end
            else
                if phoneCount ~= nil and phoneCount > 0 then
                    cb(false, "nosim")
                else
                    cb(false, "nophone")
                end
            end
        end)    
    end)
end)

RegisterServerEvent('pw_phone:server:sendEmail')
AddEventHandler('pw_phone:server:sendEmail', function(to, subject, message, meta, from)
    if to and subject and message then
        local time = os.date("%Y-%m-%d %H:%M:%S")
        if from == nil then
            from = "[[==ENCRYPTED==]]"
        end

        if meta == nil then
            meta = {}
        end

        MySQL.Async.insert("INSERT INTO `emails` (`email_to`, `email_from`, `email_date`,`email_read`,`email_deleted_receipt`, `email_deleted_sender`, `email_subject`,`email_content`,`email_meta`) VALUES (@to, @from, @date, 0, 0, 0, @subject, @content, @meta)", {
            ['@to'] = to,
            ['@from'] = from,
            ['@date'] = time,
            ['@subject'] = subject,
            ['@content'] = message,
            ['@meta'] = json.encode(meta)
        }, function(inserted)
            if inserted > 0 then
                MySQL.Async.fetchScalar("SELECT `cid` FROM `characters` WHERE `email` = @email", {['@email'] = to}, function(cid)
                    if cid ~= nil then
                        MySQL.Async.fetchAll("SELECT * FROM `phone_simcards` WHERE `cid` = @cid AND `active` = 1", {['@cid'] = cid}, function(active)
                            if active[1] then
                                local online = exports['pw_core']:checkOnline(cid)
                                if online ~= false then
                                    TriggerClientEvent('pw_phone:client:triggerNotification', online, "emailMessage", true)
                                end    
                            end
                        end)
                    end
                end)
            end
        end)
    end
end)

RegisterServerEvent('pw_phone:server:addMeta')
AddEventHandler('pw_phone:server:addMeta', function(number, pkey, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    if (simCards[tonumber(number)]) then
        simCards[tonumber(number)].addMeta(pkey, data)
    end
end) 

RegisterServerEvent('pw_phone:server:doPhoneActionFromCommand')
AddEventHandler('pw_phone:server:doPhoneActionFromCommand', function(action, number)
    local _src = source
    if action == "answer" then
        simCards[tonumber(number)].acceptCall(_src)
    elseif action == "reject" then
        simCards[tonumber(number)].rejectCall(_src)
    end
end)

exports['pw_chat']:AddChatCommand('answer', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_phone:client:doPhoneActionFromCommand', 'answer')
end, {
    help = "Answer a incomming phone call"
}, -1)

exports['pw_chat']:AddChatCommand('reject', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_phone:client:doPhoneActionFromCommand', 'reject')
end, {
    help = "Reject a incomming phone call"
}, -1)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == "radio" then
        TriggerClientEvent('pw_phone:client:usedRadioItem', _src, data)
    end
end)

RegisterServerEvent('pw_phone:server:setRadioChannel')
AddEventHandler('pw_phone:server:setRadioChannel', function(radioIdent, radioChannel)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    print(radioIdent)
    _char:Inventory():Update().MetaData(1, radioIdent, {['channel'] = radioChannel}, {['channel'] = radioChannel}, function(done)
    
    end)
end)

RegisterServerEvent('pw_core:itemRemoved')
AddEventHandler('pw_core:itemRemoved', function(_src, data)
    if data.item == "radio" then
        TriggerClientEvent('pw_phone:client:dropRadio', _src, data.id)
    end
end)

RegisterServerEvent('pw_phone:server:sendData')
AddEventHandler('pw_phone:server:sendData', function(data)
    local _src = source
    local mPlayer = exports['pw_core']:getCharacter(_src)
    local time = os.date("%Y-%m-%d %H:%M:%S")

    if data.request == "startCall" then
        simCards[tonumber(data.number)].attemptCallConnection(_src, tonumber(data.tonumber))
    end
    if data.request == "callRejected" then
        simCards[tonumber(data.number)].rejectCall(_src)
    end
    if data.request == "terminateCall" then
        simCards[tonumber(data.number)].terminateCall()
        simCards[tonumber(data.with)].terminateCall()
    end
    if data.request == "callAccepted" then
        simCards[tonumber(data.number)].acceptCall(_src)
    end
    if data.request == "deleteContact" then
        simCards[tonumber(data.number)].removeMeta("contacts", data.conid)
    end
    if data.request == "saveContact" then
        local createTable = { ['name'] = data.name, ['number'] = tonumber(data.saveNumber)}
        simCards[tonumber(data.number)].addMeta("contacts", createTable)
    end
    if data.request == "loadSim" then
        mPlayer:Inventory():Remove().Default(data.item.record_id, 1, function(done)
            if done then 
                simCards[tonumber(data.number)].updateStatus()
            end
        end)
    end
    if data.request == "removeSim" then
        mPlayer:Inventory():Add().Default(1, "simcard", 1, {['number'] = data.number}, {['number'] = data.number}, function(done)
            simCards[tonumber(data.number)].updateStatus()
        end, mPlayer.getCID())
    end
    if data.request == "sendTextMessage" then
        simCards[tonumber(data.number)].createNewMessage(tonumber(data.tonumber), data.message, true)
        -- Send New Message Notification
        local sendAlert = false
        local owner
        if simCards[tonumber(data.tonumber)].getStatus() then
            owner = simCards[tonumber(data.tonumber)].getOwner()
            sendAlert = true
        end

        if sendAlert then
            local online = exports['pw_core']:checkOnline(owner)
            if online ~= false then
                TriggerClientEvent('pw_phone:client:triggerNotification', online, "textMessages", true)
            end
        end
    end
    if data.request == "postAdvert" then
        MySQL.Sync.insert("INSERT INTO `phone_adverts` (`advert_title`,`advert_content`,`advert_poster`,`advert_posted`) VALUES (@title, @content, @poster, @posted)", {
            ['@title'] = data.title,
            ['@content'] = data.message,
            ['@poster'] = mPlayer.getCID(),
            ['@posted'] = time,
        })
    end
    if data.request == "sendEmail" then
        MySQL.Async.insert("INSERT INTO `emails` (`email_to`, `email_from`, `email_date`,`email_read`,`email_deleted_receipt`, `email_deleted_sender`, `email_subject`,`email_content`) VALUES (@to, @from, @date, 0, 0, 0, @subject, @content)", {
            ['@to'] = data.to,
            ['@from'] = mPlayer.getEmail(),
            ['@date'] = time,
            ['@subject'] = data.subject,
            ['@content'] = data.content
        }, function(inserted)
            if inserted > 0 then
                MySQL.Async.fetchScalar("SELECT `cid` FROM `characters` WHERE `email` = @email", {['@email'] = data.to}, function(cid)
                    if cid ~= nil then
                        MySQL.Async.fetchAll("SELECT * FROM `phone_simcards` WHERE `cid` = @cid AND `active` = 1", {['@cid'] = cid}, function(active)
                            if active[1] then
                                local online = exports['pw_core']:checkOnline(cid)
                                if online ~= false then
                                    TriggerClientEvent('pw_phone:client:triggerNotification', online, "emailMessage", true)
                                end    
                            end
                        end)
                    end
                end)
            end
        end)
    end
    if data.request == "deleteEmail" then
        if data.emailtype == "inbox" then
            MySQL.Sync.execute("UPDATE `emails` SET `email_deleted_receipt` = 1, `email_read` = 1 WHERE `email_id` = @id", {['@id'] = tonumber(data.emailid)})
        else
            MySQL.Sync.execute("UPDATE `emails` SET `email_deleted_sender` = 1 WHERE `email_id` = @id", {['@id'] = tonumber(data.emailid)})
        end
    end
    if data.request == "deleteAdvert" then
        MySQL.Sync.execute("DELETE FROM `phone_adverts` WHERE `advert_id` = @id", {['@id'] = data.advertid})
    end
    if data.request == "postNewTweet" then
        MySQL.Async.insert("INSERT INTO `phone_tweets` (`tweet_reply`,`tweet_by`,`tweet_content`,`tweet_date`) VALUES (0, @by, @content, @date)", {
            ['@by'] = mPlayer.getTwitter(),
            ['@content'] = data.tweet,
            ['@date'] = time
        }, function(insert)
            if insert > 0 then
                local onlineChars = exports['pw_core']:getOnlineCharacters()
                for k, v in pairs(onlineChars) do
                    if v.source ~= _src then
                        TriggerClientEvent('pw_phone:client:tweet', v.source, "newTweet", "new", mPlayer:Character().getTwitter(), data.tweet)
                    end
                end
            end
        end)
    end
    if data.request == "postTweetReply" then
        MySQL.Sync.execute("UPDATE `phone_tweets` SET `tweet_replys` = `tweet_replys` + 1 WHERE `tweet_id` = @twt", {['@twt'] = data.tweetid})
        MySQL.Async.insert("INSERT INTO `phone_tweets` (`tweet_reply`,`tweet_by`,`tweet_content`,`tweet_date`) VALUES (@twt, @by, @content, @date)", {
            ['@twt'] = data.tweetid,
            ['@by'] = mPlayer.getTwitter(),
            ['@content'] = data.tweet,
            ['@date'] = time
        }, function(insert)
            if insert > 0 then
                MySQL.Async.fetchScalar("SELECT `tweet_by` FROM `phone_tweets` WHERE `tweet_id` = @twt", {['@twt'] = data.tweetid}, function(by)
                    if by ~= nil then
                        if by ~= mPlayer.getTwitter() then
                            MySQL.Async.fetchScalar("SELECT `cid` FROM `characters` WHERE `twitter` = @twt", {['@twt'] = by}, function(cid)
                                if cid ~= nil then
                                    local online = exports['pw_core']:checkOnline(cid)
                                    if online ~= false then
                                        TriggerClientEvent('pw_phone:client:tweet', online, "newTweet", "reply", by, data.tweet)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end
        end)

    end
    if data.request == "propertySettings" then
        TriggerEvent('pw_realestate:server:propertySettings', _src, data.house)
    end
    if data.request == "processPropertySale" then
        local sendData = {}
        sendData['buyer'] = { ['source'] = data.playerSrc, ['cid'] = data.playerCID, ['uid'] = data.playerUID }
        sendData['agent'] = { ['source'] = _src, ['cid'] = mPlayer:Character().getCID(), ['uid'] = mPlayer:User().getUID() }
        sendData['property'] = { ['houseID'] = data.houseID, ['method'] = data.sellMethod }
        tprint(sendData)
        TriggerEvent('pw_realestate:server:processSale', _src, sendData)
    end
    if data.request == "togglePropertyLock" then
        exports['pw_properties']:toggleLock(data.house)
    end
    if data.request == "submitHeart" then
        MySQL.Sync.execute("UPDATE `phone_tweets` SET `tweet_hearts` = `tweet_hearts` + 1 WHERE `tweet_id` = @twt", {['@twt'] = data.tweetid})
    end
    if data.request == "deleteConvo" then
        simCards[tonumber(data.number)].deleteConversation(tonumber(data.convoid))
    end
    if data.request == "deleteMessage" then
        simCards[tonumber(data.number)].deleteMessage(tonumber(data.messageid))
    end
    if data.request == "sendTextMessageReply" then
        local sendOne
        if data.number == data.tonumber then
            sendOne = { ['conversation_id'] = data.convoid, ['message'] = data.message, ['datetime'] = time, ['read'] = false, ['to'] = tonumber(data.fromnumber), ['message_id'] = math.random(10000000,999999999) }
        elseif data.number == data.fromnumber then
            sendOne = { ['conversation_id'] = data.convoid, ['message'] = data.message, ['datetime'] = time, ['read'] = false, ['to'] = tonumber(data.tonumber), ['message_id'] = math.random(10000000,999999999) }
        end
        local sendAlert = false
        local owner
        if(simCards[tonumber(data.tonumber)]) and (simCards[tonumber(data.fromnumber)]) then
            if data.number == data.tonumber then
                -- From Number
                simCards[tonumber(data.fromnumber)].addMeta("messages", sendOne)
                owner = simCards[tonumber(data.fromnumber)].getOwner()
                if simCards[tonumber(data.fromnumber)].getStatus() then
                    sendAlert = true
                end
            else
                -- to number
                simCards[tonumber(data.tonumber)].addMeta("messages", sendOne)
                owner = simCards[tonumber(data.tonumber)].getOwner()
                if simCards[tonumber(data.tonumber)].getStatus() then
                    sendAlert = true
                end
            end
            simCards[tonumber(data.number)].addMeta("messages", sendOne)

            if sendAlert then
                local online = exports['pw_core']:checkOnline(owner)
                if online ~= false then
                    TriggerClientEvent('pw_phone:client:triggerNotification', online, "textMessages", true)
                end
            end
        end
    end

    if data.request == "startRace" then
        TriggerClientEvent('pw_races:client:startRace', _src, data)
    end

    if data.request == "joinRace" then
        TriggerClientEvent('pw_races:client:joinRace', _src)
    end

    if data.request == "changePole" then
        TriggerEvent('pw_races:server:changePole', _src, data)
    end
    
    if data.request == "cancelRace" then
        TriggerEvent('pw_races:server:activeRace', false)
    end
    
    if data.request == "fookingGo" then
        TriggerClientEvent('pw_races:client:forceStart', _src)
        TriggerClientEvent('pw_races:client:sendRaceReady', _src, data)
    end

    if data.request == "chooseTrackStart" then
        TriggerClientEvent('pw_races:client:chooseStart', _src, data)
    end

    if data.request == "clearRecords" then
        TriggerEvent('pw_races:server:clearRecord', data)
    end
    
    if data.request == "deleteTrack" then
        TriggerEvent('pw_races:server:deleteRace', data)
    end
end)

PW.RegisterServerCallback('pw_phone:server:retreiveMeta', function(source, cb, pkey, trigger, number, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    if pkey == "simcards" then
        MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @cid AND `type` = 'Simcard'", {['@cid'] = _char.getCID()}, function(sims)
            if sims[1] ~= nil then
                if trigger then
                    TriggerClientEvent('pw_phone:client:loadData', _src, pkey, sims)
                else
                    cb(sims)
                end
            else
                if trigger then
                    TriggerClientEvent('pw_phone:client:loadData', _src, pkey, {})
                else
                    cb({})
                end
            end
        end)
    elseif pkey == "twitterHome" then
        local _data = {}
        _data['profile'] = { ['name'] = _char.getTwitter() }
        _data['tweets'] = MySQL.Sync.fetchAll("SELECT * FROM `phone_tweets` WHERE `tweet_reply` = 0 ORDER BY `tweet_id` DESC", {})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "myProperties" then
        local _data = {}
        _data['mycid'] = _char.getCID()
        _data['properties'] = MySQL.Sync.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\"owner\":".._char:Character().getCID().."%' OR `metainformation` LIKE '%\"rentor\":".._char:Character().getCID().."%' ORDER BY `name` ASC", {})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "refreshTweets" then
        local _data = {}
        _data['profile'] = { ['name'] = _char.getTwitter() }
        _data['tweets'] = MySQL.Sync.fetchAll("SELECT * FROM `phone_tweets` WHERE `tweet_reply` = 0 ORDER BY `tweet_id` DESC", {})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "getNearbyPlayers" then
        local _data = {}
        _data['action'] = data.req
        _data['house'] = data.house
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "nearbyPropertys" then
        local _data = {}
        if data.ret == "forSale" then
            _data['query'] = MySQL.Sync.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\""..data.ret.."\":true%' AND `metainformation` LIKE '%\"owner\":0%' ORDER BY `name` ASC")
        else
            _data['query'] = MySQL.Sync.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\""..data.ret.."\":true%' AND `metainformation` LIKE '%\"owner\":0%' OR `metainformation` LIKE '%\""..data.ret.."\":true%' AND `metainformation` LIKE '%\"allowRealEstate\":true%' ORDER BY `name` ASC")
        end
        _data['result'] = {}
        _data['action'] = data.ret
        for k, v in pairs(_data['query']) do
            local coords = json.decode(v.location)
            v.storageLimit = exports['pw_inventory']:invLimit(tonumber(v.storageLimit))
            local distance = #(vector3(tonumber(data.coords.x), tonumber(data.coords.y), tonumber(data.coords.z)) - vector3(coords.x, coords.y, coords.z))
            if distance < 50.0 then
                table.insert(_data['result'], v)
            end
        end
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, data.ret, _data)
        else
            cb(_data)
        end
    elseif pkey == "requestTweet" then
        local mainTweet = MySQL.Sync.fetchAll("SELECT * FROM `phone_tweets` WHERE `tweet_id` = @tid ORDER BY `tweet_id` DESC", { ['@tid'] = data.tweetId})
        local _data = {}
        _data['profile'] = { ['name'] = _char.getTwitter() }
        _data['mainTweet'] = mainTweet[1]
        _data['tweets'] = MySQL.Sync.fetchAll("SELECT * FROM `phone_tweets` WHERE `tweet_reply` = @tid ORDER BY `tweet_id` DESC", { ['@tid'] = data.tweetId})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "refreshTweet" then
        local mainTweet = MySQL.Sync.fetchAll("SELECT * FROM `phone_tweets` WHERE `tweet_id` = @tid ORDER BY `tweet_id` DESC", { ['@tid'] = data.tweetId})
        local _data = {}
        _data['profile'] = { ['name'] = _char.getTwitter() }
        _data['mainTweet'] = mainTweet[1]
        _data['tweets'] = MySQL.Sync.fetchAll("SELECT * FROM `phone_tweets` WHERE `tweet_reply` = @tid ORDER BY `tweet_id` DESC", { ['@tid'] = data.tweetId})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "emailInbox" then
        MySQL.Async.fetchAll("SELECT * FROM `emails` WHERE `email_to` = @to AND `email_read` = 0", {['@to'] = _char.getEmail()}, function(total)
            if #total > 0 then
                TriggerClientEvent('pw_phone:client:triggerNotification', _src, "emailMessage", true)
            else
                TriggerClientEvent('pw_phone:client:triggerNotification', _src, "emailMessage", false)
            end
        end)
        local _data = MySQL.Sync.fetchAll("SELECT * FROM `emails` WHERE `email_to` = @email AND `email_deleted_receipt` = 0 ORDER BY `email_id` DESC", {['@email'] = _char.getEmail()})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "emailSent" then
        local _data = MySQL.Sync.fetchAll("SELECT * FROM `emails` WHERE `email_from` = @email AND `email_deleted_sender` = 0 ORDER BY `email_id` DESC", {['@email'] = _char.getEmail()})
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "viewEmail" then
        local _data = MySQL.Sync.fetchAll("SELECT * FROM `emails` WHERE `email_id` = @emailid", {['@emailid'] = tonumber(data.emailid) })
        if exports['pw_core']:getCharacter(_src).getEmail() == _data[1].email_to then
            MySQL.Sync.execute("UPDATE `emails` SET `email_read` = 1 WHERE `email_id` = @emailid", {['@emailid'] = tonumber(data.emailid) })
            _data[1].email_read = 1
        end
        local returnTable = { ['email'] = _data[1], ['data'] = data }
        MySQL.Async.fetchAll("SELECT * FROM `emails` WHERE `email_to` = @to AND `email_read` = 0", {['@to'] = _char.getEmail()}, function(total)
            if #total > 0 then
                TriggerClientEvent('pw_phone:client:triggerNotification', _src, "emailMessage", true)
            else
                TriggerClientEvent('pw_phone:client:triggerNotification', _src, "emailMessage", false)
            end
        end)
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, returnTable)
        else
            cb(returnTable)
        end
    elseif pkey == "advertisements" then
        local _data = MySQL.Sync.fetchAll("SELECT * FROM `phone_adverts` ORDER BY `advert_id` DESC", {})
            for k, v in pairs(_data) do
                if v.advert_poster == _char.getCID() then
                    v.owner = true
                else
                    v.owner = false
                end
            end
        if trigger then
            TriggerClientEvent('pw_phone:client:loadData', _src, pkey, _data)
        else
            cb(_data)
        end
    elseif pkey == "loadConvo" then
        if (simCards[tonumber(number)]) then
            local sendTable = {
                ['conversation_messages'] = simCards[tonumber(number)].retreiveConversation(tonumber(data.convoid)),
                ['conversation_details'] = simCards[tonumber(number)].ConvoDetails(tonumber(data.convoid))[1]
            }
            if trigger then
                TriggerClientEvent('pw_phone:client:loadData', _src, pkey, sendTable)
            else
                cb(sendTable)
            end

            if simCards[tonumber(number)].getUnreadMessages() == 0 then
                TriggerClientEvent('pw_phone:client:triggerNotification', _src, "textMessages", false)
            else
                TriggerClientEvent('pw_phone:client:triggerNotification', _src, "textMessages", true)
            end
        end 
    elseif pkey == "conversations" then
        if (simCards[tonumber(number)]) then
            if trigger then
                TriggerClientEvent('pw_phone:client:loadData', _src, pkey, simCards[tonumber(number)].getConversations())
            else
                cb(simCards[tonumber(number)].getConversations())
            end
        end
    elseif pkey == "createRace" or pkey == "manageTracks" then
        TriggerEvent('pw_races:server:getRacesForPhone', _src, pkey)
    elseif pkey == "activeRace" then
        TriggerEvent('pw_races:server:sendActive', _src, pkey)
    elseif pkey == "startNewFoodJob" or pkey == 'cancelOldFoodJob' then
        TriggerClientEvent('pw_fooddelivery:client:phoneFoodDelivery', _src, pkey)
    else
        if (simCards[tonumber(number)]) then
            if trigger then
                TriggerClientEvent('pw_phone:client:loadData', _src, pkey, simCards[tonumber(number)].getMeta(pkey))
            else
                cb(simCards[tonumber(number)].getMeta(pkey))
            end
        end
    end
end)

RegisterServerEvent('pw_phone:server:updateGPS')
AddEventHandler('pw_phone:server:updateGPS', function(number, x,y,z)
    local _src = source
    if (simCards[tonumber(number)]) then
        simCards[tonumber(number)].updateGPS(x,y,z)
    end
end)