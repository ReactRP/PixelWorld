PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

RegisterServerEvent('pw_notes:server:createNote')
AddEventHandler('pw_notes:server:createNote', function(message)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    MySQL.Async.insert("INSERT INTO `notes` (`message`) VALUES (@message)", {['@message'] = message}, function(noteid)
        if noteid > 0 then
            _char:Inventory():Add().Default(1, "note", 1, {['note'] = noteid }, {}, function(done)
            end, _char.getCID())
        end
    end)
end)

RegisterServerEvent('pw_notes:server:updateNote')
AddEventHandler('pw_notes:server:updateNote', function(noteid, message)
    MySQL.Async.execute("UPDATE `notes` SET `message` = @message WHERE `note_id` = @id", {['@message'] = message, ['@id'] = noteid}, function()
    end)
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == "note" then
        MySQL.Async.fetchScalar("SELECT `message` FROM `notes` WHERE `note_id` = @id", {['@id'] = data.metapublic.note}, function(message)
            TriggerClientEvent('pw_notes:client:openNote', _src, data.metapublic.note, message)
        end)
    end
end)

exports['pw_chat']:AddChatCommand('note', function(source, args, rawCommand)
    local _src = source
    if _src > 0 then
        TriggerClientEvent('pw_notes:client:newNote', _src)
    end
end, {
    help = "Create a New Note"
}, -1)