PW = nil
characterLoaded, playerData, showing = false, nil, false
Screens, Door, System, currentTablet = {}, {}, {}, {}
local hacksNeeded = 7
local tryCooldown = 5  --minutes
local winCooldown = 10 --minutes

local curMonitor = 0
local sucHacks = 0
local doorStatus = true
local onCool = false

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
		Citizen.Wait(1)
	end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
	if not unload then
		if ready then
			PW.TriggerServerCallback('pw_usb:server:getSettings', function(screens, door, system)
				Screens = screens
				Door = door
				System = system
				GLOBAL_PED = PlayerPedId()
				GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
				characterLoaded = true
			end)
		else
			playerData = data
		end
	else
		if GetPlayerServerId(PlayerId()) == System.inUse then
			TriggerServerEvent('pw_usb:server:updateSystem', 'inUse', false)
		end
		playerData = nil
		characterLoaded = false
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if characterLoaded then
			GLOBAL_PED = PlayerPedId()
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(200)
		if characterLoaded then
			GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
		end
	end
end)

RegisterNetEvent('pw_usb:start')
AddEventHandler('pw_usb:start', function(data)
	local pedCoords		= GLOBAL_COORDS
	local pedServerId 	= GetPlayerServerId(PlayerId())
	
	if not System.disabled and (not System.inUse or System.inUse == pedServerId) then
		local screen = Screens[System.currentActive]
		local dist = #(pedCoords - vector3(screen.x, screen.y, screen.z))
		if dist < 1.0 then
			if not System.inUse then
				TriggerServerEvent('pw_usb:server:updateSystem', 'inUse', pedServerId)
			end

			local difficulty = #Screens
			if System.currentActive > 1 and System.currentActive < 4 then
				difficulty = 6
			elseif System.currentActive < 6 then
				difficulty = 5
			else
				difficulty = 4
			end

			local time = (#Screens - System.currentActive) * 3 + 10

			currentTablet = data
			TriggerEvent('mhacking:show')
			TriggerEvent('mhacking:start', difficulty, time, function(success, timeRemaining)
				if success then
					hackSuccess(currentTablet)
				else
					hackFail(currentTablet)
				end
				hacking = false
			end)
			hacking = true
		end
	end
end)

RegisterNetEvent('pw_usb:client:updateSystem')
AddEventHandler('pw_usb:client:updateSystem', function(key, value)
	System[key] = value
	if key == 'disabled' and value == true and hacking then
		exports.pw_notify:SendAlert('error', 'Time\'s up. The system is now disabled.')
		hackFail()
	end
end)

RegisterNetEvent('pw_usb:client:updateDoor')
AddEventHandler('pw_usb:client:updateDoor', function(state)
	Door.open = state
	if showing then showing = false; end
end)

function hackSuccess()
	TriggerEvent("mhacking:hide")
	Citizen.Wait(1500)
	if System.currentActive == 1 then
		TriggerServerEvent('pw_usb:server:updateDoor', 'open')
		TriggerServerEvent('pw_usb:server:startTimer')
	else
		if System.currentActive == #Screens then
			TriggerServerEvent('pw_usb:remove', currentTablet, false)
			TriggerServerEvent('pw_usb:award', currentTablet)
			exports.pw_notify:SendAlert('inform', 'You have 30 seconds to leave the room', 10000)
			currentTablet = {}
		end
	end
	TriggerServerEvent('pw_usb:server:updateSystem', 'currentActive', System.currentActive + 1)
end

function hackFail()
	TriggerEvent("mhacking:hide")
	Citizen.Wait(1500)
	TriggerServerEvent('pw_usb:remove', currentTablet, true)
	exports.pw_notify:SendAlert('inform', 'You have 30 seconds to leave the room', 30000)
	currentTablet = {}
end

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(1)
		if characterLoaded then
			if (not System.inUse or System.inUse == GetPlayerServerId(PlayerId())) and System.currentActive > 1 then
				local dist = #(GLOBAL_COORDS - vector3(Screens[System.currentActive].x, Screens[System.currentActive].y, Screens[System.currentActive].z))
				if dist < 20.0 then
					DrawMarker(25, Screens[System.currentActive].x, Screens[System.currentActive].y, Screens[System.currentActive].z -0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, (System.disabled and 255 or 0), 0, (System.disabled and 0 or 255), 100, false, true, 2, true, nil, nil, false)
				end
			end
		end
	end
end)

Citizen.CreateThread(function ()    
	while true do
		Citizen.Wait(100)
		if characterLoaded then
			local distance = #(GLOBAL_COORDS - vector3(Door.coords.x, Door.coords.y, Door.coords.z))
			if distance < 20.0 then
				if Door.obj == nil or Door.obj == 0 or not DoesEntityExist(Door.obj) then
					Door.obj = GetClosestObjectOfType(Door.coords.x, Door.coords.y, Door.coords.z, 3.0, Door.hash)
				end

				if not Door.open and not Door.rotating and math.abs(GetEntityHeading(Door.obj) - Door.ch) > 2.0 then
					SetEntityHeading(Door.obj, Door.ch)
				end
				FreezeEntityPosition(Door.obj, not Door.open)

				if distance < 2.0 then
					if not showing then
						showing = true
						TriggerEvent('pw_drawtext:showNotification', { title = "Door", message = "<span style='font-size:22px'>" .. (Door.open and "<b><span class='text-success'>OPEN</span></b>" or "<b><span class='text-danger'>LOCKED</span></b>") .. "</span>", icon = (Door.open and "fad fa-door-open" or "fad fa-door-closed") })
					end
				elseif showing then
					showing = false
					TriggerEvent('pw_drawtext:hideNotification')
				end
			end
		end
	end
end)