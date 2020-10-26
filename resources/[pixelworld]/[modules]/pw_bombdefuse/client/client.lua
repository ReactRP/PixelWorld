local guiEnabled = false
local action = nil

RegisterNetEvent('adefuse:StartDefuse')
AddEventHandler('adefuse:StartDefuse', function(tL, bI, cb)    
            
	SetNuiFocus(true, true)
	guiEnabled = true
	SendNUIMessage({
		type = "enableui",
		timeLeft = tL + 1,
		bombId = bI,
		enable = true,
	})
	Citizen.CreateThread(function()
		while true do
			if action == 'success' then
				action = nil
				cb(true)
				break
			elseif action == 'failed' then
				action = nil
				exports.pw_notify:SendAlert('error', 'You failed the disarm', 5000)
				cb(false)
				break
			end
			Citizen.Wait(0)
		end
	end)

end)

RegisterNUICallback('escape', function(data, cb)    
	SetNuiFocus(false, false)	
	guiEnabled = false
	if data.bomb then
		local bId = data.bomb
		TriggerServerEvent('abomb:defusing', bId, false)
	end
	SendNUIMessage({
		type = "enableui",
		timeLeft = 0,
		enable = false,
	})
    cb('ok')
end)

RegisterNUICallback('process', function(data, cb)
    SetNuiFocus(false, false)
    guiEnabled = false
    if data.state then
        action = 'success'
    else
        action = 'failed'
    end
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        if guiEnabled then
            DisableControlAction(0, 142, guiEnabled)
            DisableControlAction(0, 106, guiEnabled)            
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('abomb:updateUi')
AddEventHandler('abomb:updateUi', function (timeL)
	if guiEnabled then
		SendNUIMessage({
			type = "updateTime",
			timeLeft = timeL,
		})
	end
end)

RegisterNetEvent('abomb:closeUi')
AddEventHandler('abomb:closeUi', function ()
	if guiEnabled then
		SendNUIMessage({
			type = "enableui",
			timeLeft = 0,
			enable = false,
		})
		SetNuiFocus(false, false)
		guiEnabled = false
	end
end)