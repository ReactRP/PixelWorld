PW = nil
local activeBlips = {}

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

RegisterServerEvent('pw_eblips:unload')
AddEventHandler('pw_eblips:unload', function()
	local _src = source
	TriggerEvent('pw_eblips:remove', _src)
	for k, v in pairs(activeBlips) do
		TriggerClientEvent("pw_eblips:updateAll", k, activeBlips)
	end
end)

RegisterServerEvent("pw_eblips:add")
AddEventHandler("pw_eblips:add", function(person)
	activeBlips[person.src] = person
	for k, v in pairs(activeBlips) do
		TriggerClientEvent("pw_eblips:updateAll", k, activeBlips)
	end
	TriggerClientEvent("pw_eblips:toggle", person.src, true)
end)

RegisterServerEvent("pw_eblips:remove")
AddEventHandler("pw_eblips:remove", function(src)
	activeBlips[src] = nil
	for k, v in pairs(activeBlips) do
		TriggerClientEvent("pw_eblips:remove", tonumber(k), src)
	end
	TriggerClientEvent("pw_eblips:toggle", src, false)
end)

AddEventHandler("playerDropped", function()
    local _src = source
	if activeBlips[_src] then
		activeBlips[_src] = nil
		for k, v in pairs(activeBlips) do
			TriggerClientEvent("pw_eblips:updateAll", k, activeBlips)
		end
	end
end)