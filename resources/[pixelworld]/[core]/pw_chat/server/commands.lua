--[[ Add Command Functions & Events ]]--
function AddChatCommand(command, callback, suggestion, arguments, job)
    commands[command] = {}
	commands[command].cmd = callback
    commands[command].arguments = arguments or -1
    commands[command].job = job

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end
    RegisterCommand(command, function(source, args, rawCommand)
        local cData = exports.pw_core:getCharacter(source)
        if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1)then
            if commands[command].job ~= nil then
                for k2, val in pairs(commands[command].job) do
                    if tostring(val) == cData:Job().getJob().name and cData:Job().getJob().duty then
                        callback(source, args, rawCommand)
                        break
                    end
                end
            else
                callback(source, args, rawCommand)
            end
        else
            TriggerEvent('pw:chat:server:Server', source, "Invalid Number Of Arguments")
        end
    end, false)
end

RegisterServerEvent('pw:chat:server:AddChatCommand')
AddEventHandler('pw:chat:server:AddChatCommand', function(command, callback, suggestion, arguments, job)
    AddChatCommand(command, callback, suggestion, arguments, job)
end)

exports('AddChatCommand', function(command, callback, suggestion, arguments, job)
    AddChatCommand(command, callback, suggestion, arguments, job)
end)

function AddAdminChatCommand(command, callback, suggestion, arguments)
	commands[command] = {}
	commands[command].cmd = callback
    commands[command].arguments = arguments or -1
    commands[command].admin = true

	if suggestion then
		if not suggestion.params or not type(suggestion.params) == "table" then suggestion.params = {} end
		if not suggestion.help or not type(suggestion.help) == "string" then suggestion.help = "" end

		commandSuggestions[command] = suggestion
	end

    RegisterCommand(command, function(source, args, rawCommand)
        local mPlayer = exports.pw_core:getUser(source)
        if((#args <= commands[command].arguments and #args == commands[command].arguments) or commands[command].arguments == -1) then
            if (mPlayer.getDeveloperState() and mPlayer.getLoginState()) or (mPlayer.privAccess() and mPlayer.getLoginState()) or (mPlayer.getOwnerState() and mPlayer.getLoginState()) then 
                callback(source, args, rawCommand)
            end
        else
            TriggerEvent('pw:chat:server:Server', source, "Invalid Number Of Arguments")
        end
    end, false)
end

RegisterServerEvent('pw:chat:server:AddAdminChatCommand')
AddEventHandler('pw:chat:server:AddAdminChatCommand', function(command, callback, suggestion, arguments)
    AddAdminChatCommand(command, callback, suggestion, arguments)
end)

exports('AddAdminChatCommand', function(command, callback, suggestion, arguments, job)
    AddAdminChatCommand(command, callback, suggestion, arguments, job)
end)

--[[ COMMANDS ALL USERS ]]--

AddChatCommand('ad', function(source, args, rawCommand)
    local mPlayer = exports.pw_core:getCharacter(source)
    local fal = mPlayer:getFullName()
    local msg = rawCommand:sub(4)
    TriggerEvent('pw:chat:server:Advert', fal, '#0000', msg)
end, {
    help = "Post An Ad For A Service You're Offering",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To Ad Channel"
        }
    }
}, -1)

AddChatCommand('refreshchat', function(source, args, rawCommand)
    TriggerEvent('pw_chat:refreshChat', source)
end, {
    help = "Refresh tne Chat",
}, -1)

AddChatCommand('311', function(source, args, rawCommand)
    local mPlayer = exports.pw_core:getCharacter(source)
    local name = mPlayer.getFullName()
    fal = name
    local msg = rawCommand:sub(5)
  TriggerClientEvent('pw_chat:client:Do311Alert', source, fal, msg)
end, {
    help = "Non-Emergency Line",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To 311 Channel"
        }
    }
}, -1)

AddChatCommand('911', function(source, args, rawCommand)
    local mPlayer = exports.pw_core:getCharacter(source)
    local name = mPlayer.getFullName()
    fal = name
    local msg = rawCommand:sub(5)
   TriggerClientEvent('pw_chat:client:Do911Alert', source, fal, msg)
end, {
    help = "Emergency Line",
    params = {{
            name = "Message",
            help = "The Message You Want To Send To 911 Channel"
        }
    }
}, -1)

--[[ ADMIN-RESTRICTED COMMANDS ]]--

AddChatCommand('clear', function(source, args, rawCommand)
    TriggerClientEvent('pw:chat:client:ClearChat', source)
end, {
    help = "Clear The Chat"
})

AddAdminChatCommand('clear', function(source, args, rawCommand)
    TriggerClientEvent('pw:chat:client:ClearChat', source)
end, {
    help = "Clear the Chat",
}, -1)

AddAdminChatCommand('system', function(source, args, rawCommand)
    TriggerEvent('pw:chat:server:System', source, rawCommand:sub(8))
end, {
    help = "Send a System Message to all players.",
    params = {{
            name = "Message",
            help = "The message that you wish to send to all players."
        }
    }
}, -1)