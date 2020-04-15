PW = nil
characterLoaded, playerData = false, nil
local active, activeBlips = false, {}

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
			GLOBAL_PED = PlayerPedId()
			characterLoaded = true
        else
            playerData = data
        end
	else
		if active then
			RemoveAnyExistingEmergencyBlips()
			TriggerServerEvent('pw_eblips:unload')
		end
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded and playerData then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

RegisterNetEvent("pw_eblips:toggle")
AddEventHandler("pw_eblips:toggle", function(on)
	active = on
	if not active then
		RemoveAnyExistingEmergencyBlips()
	end
end)

RegisterNetEvent("pw_eblips:updateAll")
AddEventHandler("pw_eblips:updateAll", function(personnel)
	activeBlips = personnel
end)

RegisterNetEvent("pw_eblips:update")
AddEventHandler("pw_eblips:update", function(person)
	activeBlips[person.src] = person
end)

RegisterNetEvent("pw_eblips:remove")
AddEventHandler("pw_eblips:remove", function(src)
	RemoveAnyExistingEmergencyBlipsById(src)
end)

function RemoveAnyExistingEmergencyBlips()
	for src, info in pairs(activeBlips) do
		local blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(src)))
		if blip ~= 0 then
			RemoveBlip(blip)
			activeBlips[src] = nil
		end
	end
end

function RemoveAnyExistingEmergencyBlipsById(id)
	local blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(id)))
	if blip ~= 0 then
		RemoveBlip(blip)
		activeBlips[id] = nil
	end
end

Citizen.CreateThread(function()
	while true do
		if characterLoaded and active then
			for src, info in pairs(activeBlips) do
				local player = GetPlayerFromServerId(src)
				local ped = GetPlayerPed(player)
				if GLOBAL_PED ~= ped then
					if GetBlipFromEntity(ped) == 0 then
						local blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						SetBlipColour(blip, info.color)
						SetBlipAsShortRange(blip, true)
                        SetBlipScale(blip, 0.8)
						SetBlipDisplay(blip, 4)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        SetBlipHiddenOnLegend(blip, true)
					end
				end
			end
		end
		Wait(1000)
	end
end)