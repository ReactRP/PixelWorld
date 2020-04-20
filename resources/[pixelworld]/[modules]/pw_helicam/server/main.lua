RegisterServerEvent('pw_helicam:server:forwardspotlight')
AddEventHandler('pw_helicam:server:forwardspotlight', function(state)
	local serverID = source
	TriggerClientEvent('pw_helicam:client:forwardspotlight', -1, serverID, state)
end)

RegisterServerEvent('pw_helicam:trackingspotlight')
AddEventHandler('pw_helicam:trackingspotlight', function(target_netID, target_plate, targetposx, targetposy, targetposz)
	local serverID = source
	TriggerClientEvent('pw_helicam:client:HeliSpotlight2', -1, serverID, target_netID, target_plate, targetposx, targetposy, targetposz)
end)

RegisterServerEvent('pw_helicam:server:trackingspotlightToggle')
AddEventHandler('pw_helicam:server:trackingspotlightToggle', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:trackingSpotlightToggle', -1, serverID)
end)

RegisterServerEvent('pw_helicam:server:pauseTrackingSpotlight')
AddEventHandler('pw_helicam:server:pauseTrackingSpotlight', function(pause_Tspotlight)
	local serverID = source
	TriggerClientEvent('pw_helicam:client:pauseTrackingSpotlight', -1, serverID, pause_Tspotlight)
end)

RegisterServerEvent('pw_helicam:server:manualSpotlight')
AddEventHandler('pw_helicam:server:manualSpotlight', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:HeliSpotlight', -1, serverID)
end)

RegisterServerEvent('pw_helicam:server:manualSpotlightToggle')
AddEventHandler('pw_helicam:server:manualSpotlightToggle', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:HeliSpotlightToggle', -1, serverID)
end)

RegisterServerEvent('pw_helicam:server:lightUp')
AddEventHandler('pw_helicam:server:lightUp', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:lightUp', -1, serverID)
end)

RegisterServerEvent('pw_helicam:server:lightDown')
AddEventHandler('pw_helicam:server:lightDown', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:lightDown', -1, serverID)
end)

RegisterServerEvent('pw_helicam:server:radiusUp')
AddEventHandler('pw_helicam:server:radiusUp', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:radiusUp', -1, serverID)
end)

RegisterServerEvent('pw_helicam:server:radiusDown')
AddEventHandler('pw_helicam:server:radiusDown', function()
	local serverID = source
	TriggerClientEvent('pw_helicam:client:radiusDown', -1, serverID)
end)