PW.RegisterServerCallback('pw_phone:server:messages:SendText', function(source, cb, data)
    if data then
        local _src = source
        local _char = exports['pw_core']:getCharacter(_src) 
        if _char then
            if data.receiver and data.message then
                local myNumber = _char:Phone().getNumber()
                MySQL.Async.fetchScalar("SELECT `cid` FROM `characters` WHERE `phone_id` = @phone", {['@phone'] = data.receiver}, function(exist)
                    if exist ~= nil then
                        MySQL.Async.insert("INSERT INTO `phone_texts` (`sender`,`receiver`,`message`) VALUES (@sender, @receiver, @message)", {['@sender'] = myNumber, ['@receiver'] = data.receiver, ['@message'] = data.message}, function(inserted)
                            if inserted > 0 then
                                MySQL.Async.fetchAll("SELECT * FROM `phone_texts` WHERE `id` = @id", {['@id'] = inserted}, function(textData)
                                    if textData[1] ~= nil then
                                        local sendTable = {
                                            ['receiver'] = textData[1].receiver,
                                            ['message'] = textData[1].message,
                                            ['sentime'] = textData[1].send_time
                                        }

                                        MySQL.Sync.execute("UPDATE `phone_applications` SET `unread` = `unread` + 1 WHERE `container` = 'message' AND `charid` = @cid", {['@cid'] = exist})
                                        local tSrc = exports['pw_core']:checkOnline(exist)
                                        if tSrc ~= false then
                                            local tChar =  exports['pw_core']:getCharacter(tSrc)
                                            if tChar then
                                                MySQL.Async.fetchScalar("SELECT `name` FROM `phone_contacts` WHERE `number` = @number AND `charid` = @cid", {['@number'] = myNumber, ['@cid'] = tChar.getCID() }, function(fuckersname)
                                                    if fuckersname ~= nil then
                                                        TriggerClientEvent('pw_phone:client:messages:receiveText', tSrc, fuckersname, textData[1])
                                                    else
                                                        TriggerClientEvent('pw_phone:client:messages:receiveText', tSrc, myNumber, textData[1])
                                                    end
                                                    MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = tChar.getCID()}, function(apps)
                                                        TriggerClientEvent('pw_phone:client:updateSettings', tSrc, "apps", apps)
                                                    end)
                                                    refreshTexts(tSrc)
                                                end)
                                            end
                                        end
                                        refreshTexts(_src)
                                        cb(sendTable)
                                    else
                                        cb(false)
                                    end
                                end)
                            else
                                cb(false)
                            end
                        end)
                    else
                        cb(false)
                    end                
                end)
            else
                cb(false)
            end
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

RegisterServerEvent('pw_phone:server:phone:processReadMessages')
AddEventHandler('pw_phone:server:phone:processReadMessages', function(toProcess)
    local src = source
    local _char = exports['pw_core']:getCharacter(src)
    local totalToRemove = 0
    if toProcess['sender'] then
        for i = 1, #toProcess['sender'] do
            MySQL.Sync.execute("UPDATE `phone_texts` SET `sender_read` = 1 WHERE `id` = @id", {['@id'] = toProcess['sender'][i].message_id})
            totalToRemove = totalToRemove + 1
        end
    end
    
    if toProcess['receiver'] then
        for i = 1, #toProcess['receiver'] do
            MySQL.Sync.execute("UPDATE `phone_texts` SET `receiver_read` = 1 WHERE `id` = @id", {['@id'] = toProcess['receiver'][i].message_id})
            totalToRemove = totalToRemove + 1
        end   
    end

    if totalToRemove > 0 then
        print('Removed', totalToRemove)
        MySQL.Sync.execute("UPDATE `phone_applications` SET `unread` = `unread` - @unread WHERE `charid` = @cid AND `container` = 'message'", {['@cid'] = _char.getCID(), ['@unread'] = totalToRemove})
    end

    MySQL.Async.fetchAll("SELECT * FROM `phone_applications` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(apps)
        local applications = {}
        for k, v in pairs(apps) do
            table.insert(applications, {charid = v.charid, name = v.name, container = v.container, icon = v.icon, color = v.color, unread = v.unread, enabled = v.enabled, installable = v.installable, uninstallable = v.uninstallable, dumpable = v.dumpable, customExit = v.customExit, public = v.public, jobRequired = json.decode(v.jobRequired), description = v.description})
        end
        TriggerClientEvent('pw_phone:client:updateSettings', src, "apps", applications)
    end)
end)

function refreshTexts(src)
    local _src = src
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.fetchAll("SELECT * FROM phone_texts WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0)", {['@number'] = _char:Phone().getNumber()}, function(messages)
        TriggerClientEvent('pw_phone:client:updateSettings', _src, "messages", messages)
    end)
end

PW.RegisterServerCallback('pw_phone:server:messages:receiveInitialMessages', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.fetchAll("SELECT * FROM phone_texts WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0)", {['@number'] = _char:Phone().getNumber()}, function(messages)
        cb(messages)
    end)
end)

PW.RegisterServerCallback('pw_phone:server:messages:DeleteConversation', function(source, cb, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)

    MySQL.Async.execute('UPDATE `phone_texts` SET `sender_deleted` = 1 WHERE `sender` = @me AND `receiver` = @other', { ['@me'] = _char:Phone().getNumber(), ['@other'] = data.number }, function(status1)
        MySQL.Async.execute('UPDATE `phone_texts` SET `receiver_deleted` = 1 WHERE `receiver` = @me AND `sender` = @other', { ['@me'] = _char:Phone().getNumber(), ['@other'] = data.number }, function(status2)
            cb(status1 ~= nil and status2 ~= nil)
        end)
    end)
end)