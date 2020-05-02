PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
			GLOBAL_PED = PlayerPedId()
			GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
			characterLoaded = true
		else
			playerData = data
		end
	else
		playerData = nil
		characterLoaded = false
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if characterLoaded then
			GLOBAL_PED = GLOBAL_PED
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

RegisterNetEvent('pw:notification:SendAlert')
AddEventHandler('pw:notification:SendAlert', function(data)
	if characterLoaded then
		SendAlert(data.type, data.text, data.length, data.style)
	end
end)

RegisterNetEvent('pw:notification:SendUniqueAlert')
AddEventHandler('pw:notification:SendUniqueAlert', function(data)
	if characterLoaded then
		SendUniqueAlert(data.id, data.type, data.text, data.length, data.style)
	end
end)


RegisterNetEvent('pw:notification:PersistentAlert')
AddEventHandler('pw:notification:PersistentAlert', function(data)
	if characterLoaded then
		PersistentAlert(data.action, data.id, data.type, data.text, data.style)
	end
end)

function SendAlert(type, text, length, style)
	SendNUIMessage({
		type = type,
		text = text,
		length = length,
		style = style
	})
end

function SendUniqueAlert(id, type, text, length, style)
	SendNUIMessage({
		id = id,
		type = type,
		text = text,
		style = style
	})
end

function PersistentAlert(action, id, type, text, style)
	if action:upper() == 'START' then
		TriggerEvent('pw_base:addPersistentID', id)
		SendNUIMessage({
			persist = action,
			id = id,
			type = type,
			text = text,
			style = style
		})
	elseif action:upper() == 'END' then
		SendNUIMessage({
			persist = action,
			id = id
		})
	end
end