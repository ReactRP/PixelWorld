AddEventHandler('chatMessage', function(source, n, message)
    local char = exports.pw_core:getCharacter(source)
    if char ~= nil then
        if(starts_with(message, '/'))then
            local command_args = stringsplit(message, " ")

            command_args[1] = string.gsub(command_args[1], '/', "")

            local commandName = command_args[1]

            if commands[commandName] ~= nil then
                if commands[commandName].job ~= nil then
                    for k, v in pairs(commands[commandName].job) do
                        if char:getJob().name == v.name then
                            local command = commands[commandName]
                        end
                    end
                else
                    local command = commands[commandName]
                end

                if(command)then
                    local Source = source
                    CancelEvent()
                    table.remove(command_args, 1)
                    if (not (command.arguments <= (#command_args - 1)) and command.arguments > -1) then
                        TriggerEvent('pw:chat:server:Server', source, "Invalid Number Of Arguments")
                    end
                else
                    TriggerEvent('pw:chat:server:Server', source, "Invalid Command Handler")
                end
            else
                TriggerEvent('pw:chat:server:Server', source, "Invalid Command")
            end
        else
            local cData = exports.pw_core:getCharacter(source)
            local name = cData.getFullName()

            fal = name
            TriggerClientEvent('chat:addMessage', -1, {
                template = '<div class="chat-message"><div class="chat-message-header">[OOC] {0}:</div><div class="chat-message-body">{1}</div></div>',
                args = { fal, message }
            })
        end
    end
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:Server')
AddEventHandler('pw:chat:server:Server', function(source, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message server"><div class="chat-message-header">[SERVER]</div><div class="chat-message-body">{0}</div></div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:ServerToAll')
AddEventHandler('pw:chat:server:ServerToAll', function(message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message server"><div class="chat-message-header">[SERVER]</div><div class="chat-message-body">{0}</div></div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:System')
AddEventHandler('pw:chat:server:System', function(source, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message system"><div class="chat-message-header">[SYSTEM]</div><div class="chat-message-body">{0}</div></div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:SystemToAll')
AddEventHandler('pw:chat:server:SystemToAll', function(message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message system"><div class="chat-message-header">[SYSTEM]</div><div class="chat-message-body">{0}</div></div>',
        args = { message }
    })
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:Advert')
AddEventHandler('pw:chat:server:Advert', function(name, phone, message)
    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message advert"><div class="chat-message-header"><i class="fas fa-ad"></i> Advertisement: {0} | {1}</div><div class="chat-message-body">{2}</div></div>',
        args = { name, phone, message }
    })
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:311Alert')
AddEventHandler('pw:chat:server:311Alert', function(name, location, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message nonemergency"><div class="chat-message-header">[311] | {0}: Your message has been sent to the non-emergency number.</div></div>',
        args = { name }
    })
    local players = exports['pw_core']:GetActivePlayers()
    for k, v in pairs(players) do
        local cData = exports.pw_core:getCharacter(k)
        if (cData:getJob().name == 'police' or cData:getJob().name == 'ems') and cData:getJob().duty then
            TriggerClientEvent('chat:addMessage', k, {
                template = '<div class="chat-message nonemergency"><div class="chat-message-header">[311] | Caller : {0} | Location : {1}</div><div class="chat-message-body">{2}</div></div>',
                args = { name, location, message }
            })
        end
    end
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:911Alert')
AddEventHandler('pw:chat:server:911Alert', function(name, location, message)
    TriggerClientEvent('chat:addMessage', source, {
        template = '<div class="chat-message emergency"><div class="chat-message-header">[911] | {0}: Your message has been sent to the emergency services.</div></div>',
        args = { name }
    })
    local players = exports['pw_core']:GetActivePlayers()
    for k, v in pairs(players) do
        local cData = exports.pw_core:getCharacter(k)
        if cData:getJob().name == 'police' and cData:getJob().duty then
            TriggerClientEvent('chat:addMessage', k, {
                template = '<div class="chat-message emergency"><div class="chat-message-header">[911] | Caller : {0} | Location : {1}</div><div class="chat-message-body">{2}</div></div>',
                args = { name, location, message }
            })
        end
    end
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:policeDispatch')
AddEventHandler('pw:chat:server:policeDispatch', function(code, locale, message, coords, gender)
    if gender ~= nil then
        if type(gender) == 'table' then
            gender = (gender.victim and "Male" or "Female") .. " v " .. (gender.attacker and "Male" or "Female")
        else
            gender = (gender and "Male" or "Female")
        end
    else
        gender = "Unknown"
    end
    local players = exports['pw_core']:GetActivePlayers()
    for k, v in pairs(players) do
        local cData = exports.pw_core:getCharacter(k)
        if cData:getJob().name == 'police' and cData:getJob().duty then
            TriggerClientEvent('chat:addMessage', k, {
                template = '<div class="chat-message emergency"><div class="chat-message-header">[911 Dispatch] | {0} - {1} | Location : {2}</div><div class="chat-message-body">{3}</div></div>',
                args = { code, gender, locale, message }
            })
            TriggerClientEvent('pw_police:displayCrimeBlip', k, code, coords)
        end
    end
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:emsDispatch')
AddEventHandler('pw:chat:server:emsDispatch', function(name, location, message)
    local players = exports['pw_core']:GetActivePlayers()
    for k, v in pairs(players) do
        local cData = exports.pw_core:getCharacter(k)
        if cData:getJob().name == 'ems' and cData:getJob().duty then
            TriggerClientEvent('chat:addMessage', k, {
                template = '<div class="chat-message emergency"><div class="chat-message-header">[911 Dispatch] | Caller : {0} | Location : {1}</div><div class="chat-message-body">{2}</div></div>',
                args = { name, location, message }
            })
        end
    end
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:EmergencyDispatch')
AddEventHandler('pw:chat:server:EmergencyDispatch', function(name, location, message)
    local players = exports['pw_core']:GetActivePlayers()
    for k, v in pairs(players) do
        local cData = exports.pw_core:getCharacter(k)
        if (cData:getJob().name == 'police' or cData:getJob().name == 'ems') and cData:getJob().duty then
            TriggerClientEvent('chat:addMessage', k, {
                template = '<div class="chat-message nonemergency"><div class="chat-message-header">[311 Dispatch] | Caller : {0} | Location : {1}</div><div class="chat-message-body">{2}</div></div>',
                args = { name, location, message }
            })
        end
    end
    CancelEvent()
end)

RegisterServerEvent('pw:chat:server:SendMeToNear')
AddEventHandler('pw:chat:server:SendMeToNear', function(source, message)
    local src = source
    TriggerClientEvent('pw:chat:client:ReceiveMe', -1, src, message)
end)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
    end
	return t
end