RegisterServerEvent("lvc_TogDfltSrnMuted_s")
AddEventHandler("lvc_TogDfltSrnMuted_s", function(toggle)
	local src = source
	TriggerClientEvent("lvc_TogDfltSrnMuted_c", -1, src, toggle)
end)

RegisterServerEvent("lvc_SetLxSirenState_s")
AddEventHandler("lvc_SetLxSirenState_s", function(newstate)
	local src = source
	TriggerClientEvent("lvc_SetLxSirenState_c", -1, src, newstate)
end)

RegisterServerEvent("lvc_TogPwrcallState_s")
AddEventHandler("lvc_TogPwrcallState_s", function(toggle)
	local src = source
	TriggerClientEvent("lvc_TogPwrcallState_c", -1, src, toggle)
end)

RegisterServerEvent("lvc_SetAirManuState_s")
AddEventHandler("lvc_SetAirManuState_s", function(newstate)
	local src = source
	TriggerClientEvent("lvc_SetAirManuState_c", -1, src, newstate)
end)

RegisterServerEvent("lvc_TogIndicState_s")
AddEventHandler("lvc_TogIndicState_s", function(newstate)
	local src = source
	TriggerClientEvent("lvc_TogIndicState_c", -1, src, newstate)
end)
