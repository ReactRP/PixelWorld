Calls = {}

function CreateCallRecord(sender, receiver, state)

end

AddEventHandler('playerDropped', function()
    local mPlayer = exports['pw_core']:getCharacter(source)
    if mPlayer ~= nil then
        if Calls[mPlayer:Phone().getNumber()] ~= nil then
            local tPlayer = exports['pw_core']:getByPhone(Calls[mPlayer:Phone().getNumber()].number)
            if tPlayer ~= nil then
                TriggerClientEvent('pw_phone:client:calls:EndCall', tPlayer.getSource())
            else
                Calls[Calls[mPlayer:Phone().getNumber()].number]= nil
            end
            Calls[mPlayer:Phone().getNumber()] = nil
        end
    end
end)

RegisterServerEvent('pw_core:server:playerReady')
AddEventHandler('pw_core:server:playerReady', function()
    local src = source
    local char = exports['pw_core']:getCharacter(src)

    Citizen.CreateThread(function()
        MySQL.Async.fetchAll('SELECT * FROM phone_calls WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0) LIMIT 50', { ['number'] = char:Phone().getNumber() }, function(history) 
            TriggerClientEvent('pw_phone:client:updateSettings', src, "history", history)
        end)
    end)
end)

PW.RegisterServerCallback('pw_phone:server:calls:CreateCall', function(source, cb, data)
    local char = exports['pw_core']:getCharacter(source)

    if char:Phone().getNumber() ~= data.number then
        local tPlayer = exports['pw_core']:getByPhone(data.number)
        if tPlayer ~= nil then
            if tPlayer.getSource() ~= nil then
                if Calls[data.number] ~= nil then
                    cb(-3)
                    TriggerClientEvent('pw:notification:SendAlert', tPlayer.getSource(), { type = 'inform', text = char.getFullName() .. ' Tried Calling You, Sending Busy Response'})
                else
                    MySQL.Async.insert('INSERT INTO phone_calls (sender, receiver, status, anon) VALUES(@sender, @receiver, @status, @anon)', {
                        ['sender'] = char:Phone().getNumber(),
                        ['receiver'] = data.number,
                        ['status'] = 0,
                        ['anon'] = data.nonStandard
                    }, function(status)
                        if status > 0 then
                            cb(1)
            
                            TriggerClientEvent('pw_phone:client:calls:CreateCall', source, char:Phone().getNumber())
                            if data.nonStandard then
                                TriggerClientEvent('pw_phone:client:calls:ReceiveCall', tPlayer.getSource(), 'Anonymous Caller')
                                TriggerClientEvent('pw:notification:PersistentAlert', tPlayer.getSource(), { id = Config.IncomingNotifId, action = 'start', type = 'inform', text = 'Recieve A Call From A Hidden Number', style = { ['background-color'] = '#ff8555', ['color'] = '#ffffff' } })
                            else
                                TriggerClientEvent('pw_phone:client:calls:ReceiveCall', tPlayer.getSource(), char:Phone().getNumber())
                                TriggerClientEvent('pw:notification:PersistentAlert', tPlayer.getSource(), { id = Config.IncomingNotifId, action = 'start', type = 'inform', text = char.getFullName() .. ' Is Calling You', style = { ['background-color'] = '#ff8555', ['color'] = '#ffffff' } })
                            end

                            MySQL.Async.fetchAll('SELECT * FROM phone_calls WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0) LIMIT 50', { ['number'] = char:Phone().getNumber() }, function(history) 
                                MySQL.Async.fetchAll('SELECT * FROM phone_calls WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0) LIMIT 50', { ['number'] = tPlayer:Phone().getNumber() }, function(history2) 
                                    TriggerClientEvent('pw_phone:client:updateSettings', char.getSource(), "history", history)
                                    TriggerClientEvent('pw_phone:client:updateSettings', tPlayer.getSource(), "history", history2)
                                end)
                            end)
                            
                            Calls[char:Phone().getNumber()] = {
                                number = data.number,
                                status = 0,
                                record = status
                            }
                            Calls[data.number] = {
                                number = char:Phone().getNumber(),
                                status = 0,
                                record = status
                            }
                        else
                            cb(-1)
                        end
                    end)
                end
            else
                cb(-4)
            end
        else
            cb(-4)
        end
    else
        cb(-2) 
    end
end)

PW.RegisterServerCallback('pw_phone:server:calls:DeleteCallRecord', function(source, cb, data)
    local char = exports['pw_core']:getCharacter(source)

    MySQL.Async.fetchAll('SELECT * FROM phone_calls WHERE id = @id', { ['id'] = data.id }, function(record)
        if record[1] ~= nil then
            if record[1].sender == char:Phone().getNumber() then
                MySQL.Async.execute('UPDATE phone_calls SET sender_deleted = 1 WHERE id = @id AND sender = @phone', { ['id'] = id, ['phone'] = char:Phone().getNumber() }, function(status)
                    if status > 0 then
                        cb(true)
                    else
                        cb(false)
                    end
                end)
            else
                MySQL.Async.execute('UPDATE phone_calls SET receiver_deleted = 1 WHERE id = @id AND receiver = @phone', { ['id'] = id, ['phone'] = char:Phone().getNumber() }, function(status)
                    if status > 0 then
                        cb(true)
                    else
                        cb(false)
                    end
                end)
            end
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('pw_phone:server:calls:ToggleHold')
AddEventHandler('pw_phone:server:calls:ToggleHold', function(call)
    local src = source
    local char = exports['pw_core']:getCharacter(src)
    local tPlayer = exports['pw_core']:getByPhone(Calls[call.number].number)
    TriggerClientEvent('pw_phone:client:calls:OtherToggleHold', tPlayer.getSource())
end)

RegisterServerEvent('pw_phone:server:calls:AcceptCall')
AddEventHandler('pw_phone:server:calls:AcceptCall', function()
    local src = source
    local char = exports['pw_core']:getCharacter(src)

    if Calls[char:Phone().getNumber()] ~= nil then
        local tPlayer = exports['pw_core']:getByPhone(Calls[char:Phone().getNumber()].number)
        if tPlayer ~= nil then
            if (Calls[char:Phone().getNumber()].number ~= nil) and (Calls[Calls[char:Phone().getNumber()].number].number ~= nil) then
                Calls[Calls[char:Phone().getNumber()].number].status = 1
                Calls[char:Phone().getNumber()].status = 1

                TriggerClientEvent('pw_phone:client:calls:AcceptCall', src, (tPlayer.getSource() + 100), false)
                TriggerClientEvent('pw_phone:client:calls:AcceptCall', tPlayer.getSource(), (tPlayer.getSource() + 100), true)
            else
                Calls[Calls[char:Phone().getNumber()].number] = nil
                Calls[char:Phone().getNumber()] = nil
                TriggerClientEvent('pw_phone:client:calls:EndCall', src)
                TriggerClientEvent('pw_phone:client:calls:EndCall', tPlayer.getSource())
            end
        else
            TriggerClientEvent('pw_phone:client:calls:EndCall', src)
        end
    end
end)

RegisterServerEvent('pw_phone:server:calls:EndCall')
AddEventHandler('pw_phone:server:calls:EndCall', function()
    local src = source
    
    local char = exports['pw_core']:getCharacter(src)

    if Calls[char:Phone().getNumber()] ~= nil then
        local tPlayer = exports['pw_core']:getByPhone(Calls[char:Phone().getNumber()].number)
        if tPlayer ~= nil then
            Calls[Calls[char:Phone().getNumber()].number] = nil
            Calls[char:Phone().getNumber()] = nil

            TriggerClientEvent('pw_phone:client:calls:EndCall', src)
            TriggerClientEvent('pw_phone:client:calls:EndCall', tPlayer.getSource())
        end
    end
end)