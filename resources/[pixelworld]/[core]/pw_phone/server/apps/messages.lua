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