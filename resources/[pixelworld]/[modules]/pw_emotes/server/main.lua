PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
-----------------------------------------------------------------------------------------------------
-- Shared Emotes Syncing  ---------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

RegisterServerEvent("pw_emotes:server:ServerEmoteRequest")
AddEventHandler("pw_emotes:server:ServerEmoteRequest", function(target, emotename, etype)
	TriggerClientEvent("pw_emotes:client:ClientEmoteRequestReceive", target, emotename, etype)
end)

RegisterServerEvent("pw_emotes:server:ServerValidEmote") 
AddEventHandler("pw_emotes:server:ServerValidEmote", function(target, requestedemote, otheremote)
	TriggerClientEvent("pw_emotes:client:SyncPlayEmote", source, otheremote, source)
	TriggerClientEvent("pw_emotes:client:SyncPlayEmoteSource", target, requestedemote)
end)

-----------------------------------------------------------------------------------------------------
-- Keybinding  --------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

PW.RegisterServerCallback('pw_emotes:server:getCharacterEmoteBinds', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _cid = _char.getCID()
	local bindData = MySQL.Sync.fetchScalar("SELECT `emoteBinds` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
	if bindData ~= nil then
		local bindDataFinal = json.decode(bindData)
		PW.Print(bindDataFinal)
		cb(bindDataFinal)
	else
		cb(nil)
	end
end)

PW.RegisterServerCallback('pw_emotes:server:updateCharacterEmoteBinds', function(source, cb, keybinds)
	local _src = source
	if keybinds ~= nil then
		local _char = exports['pw_core']:getCharacter(_src)
		local _cid = _char.getCID()
		PW.Print(keybinds)
		local newKeybinds = json.encode(keybinds)
		MySQL.Async.execute("UPDATE `characters` SET `emoteBinds` = @emoteBinds WHERE `cid` = @cid", {['@emoteBinds'] = newKeybinds, ['@cid'] = _cid}, function(updated)
			if updated > 0 then
				cb(true)
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end)

RegisterServerEvent('pw_emotes:server:updateKeyBinds')
AddEventHandler('pw_emotes:server:updateKeyBinds', function(data)
	local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _cid = _char.getCID()
	if data ~= nil then
		PW.Print(data)      
	end
end)

exports.pw_chat:AddChatCommand('emotebind', function(source, args, rawCommand)
	local _src = source
	if args[1] ~= nil and args[2] ~= nil then
		TriggerClientEvent('pw_emotes:client:updateBindedEmotes', _src, args[1], args[2])
	end
end, {
	help = "Update Emote Keybinds",
	params = {{ name = "Keybind ID", help = "1 - NUMPAD 4, 2 - NUMPAD 5, 3 - NUMPAD 6, 4 - NUMPAD 7, 5 - NUMPAD 8, 6 - NUMPAD 9"}, { name = "Emote", help = "A Valid Dance, Prop Emote or Regular Emote to Bind to The Key"} }
}, -1)

exports.pw_chat:AddChatCommand('e', function(source, args, rawCommand)
	local _src = source
	if args[1] ~= nil then
		TriggerClientEvent('pw_emotes:client:doAnEmote', _src, args[1])
	end
end, {
	help = "Do An Emote",
	params = {{ name = "Emote", help = "A Valid Regular Emote, Dance Emote or Prop Emote or \"C\" to Cancel"} }
}, -1)
