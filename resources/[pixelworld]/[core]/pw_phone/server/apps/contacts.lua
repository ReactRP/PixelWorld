RegisterServerEvent('pw_phone:server:contacts:createContact')
AddEventHandler('pw_phone:server:contacts:createContact', function(data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    if _char then
        MySQL.Sync.insert("INSERT INTO `phone_contacts` (`charid`,`number`,`name`) VALUES (@cid, @num, @name)", {['@cid'] = _char.getCID(), ['@num'] = data.number, ['@name'] = data.name})
    end
end)

RegisterServerEvent('pw_phone:server:contacts:editContact')
AddEventHandler('pw_phone:server:contacts:editContact', function(data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)

    if _char then
        MySQL.Sync.execute("UPDATE `phone_contacts` SET `name` = @name, `number` = @number WHERE `name` = @name2 AND `number` = @number2 AND `charid` = @cid", {
            ['@name'] = data.name,
            ['@number'] = data.number,
            ['@name2'] = data.originName,
            ['@number2'] = data.originNumber,
            ['@cid'] = _char.getCID()
        })
    end
end)

PW.RegisterServerCallback('pw_phone:server:retreiveContacts', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    if _char then
        MySQL.Async.fetchAll("SELECT * FROM `phone_contacts` WHERE `charid` = @cid", {['@cid'] = _char.getCID()}, function(contacts)
            if contacts[1] ~= nil then
                cb({name = "contacts", data = contacts})
            else
                cb({name = "contacts", data = {}}) 
            end
        end)
    end
end)

RegisterServerEvent('pw_phone:server:contacts:deleteContact')
AddEventHandler('pw_phone:server:contacts:deleteContact', function(data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    if _char then
        MySQL.Sync.execute("DELETE FROM `phone_contacts` WHERE `number` = @number AND `name` = @name AND `charid` = @cid", {['@name'] = data.name, ['@number'] = data.number, ['@cid'] = _char.getCID()})
    end
end)