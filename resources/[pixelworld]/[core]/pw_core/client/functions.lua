PW = {}
playerData, playerLoaded = nil, false
GLOBAL_PED, OLD_PED = nil, nil
PW.CurrentRequestId          = 0
PW.ServerCallbacks           = {}
PW.TimeoutCallbacks          = {}
PW.Streaming = {}
PW.Game = {}
PW.Math = {}
PW.Vehicles = {}
PW.Base = {}
local cameraFunc = nil
PWBase = {}
flyCam = nil

Citizen.CreateThread(function()
	while true do
		if playerLoaded then
			GLOBAL_PED = PlayerPedId()
		end
		Citizen.Wait(500)
	end
end)

Citizen.CreateThread(function()
	while true do
		if playerLoaded and playerData then
			if (GLOBAL_PED ~= nil and GLOBAL_PED ~= OLD_PED) then
				if OLD_PED ~= nil and DecorExistOn(OLD_PED, "player_admin") then
					DecorRemove(OLD_PED, "player_admin")
				end
				if OLD_PED ~= nil and playerData.job.name == "police" and (playerData.job.duty or not playerData.job.duty) and DecorExistOn(OLD_PED, "player_cop") then
					DecorRemove(OLD_PED, "player_cop")
				end
				if OLD_PED ~= nil and playerData.job.name == "ems" and (playerData.job.duty or not playerData.job.duty) and DecorExistOn(OLD_PED, "player_cop") then
					DecorRemove(OLD_PED, "player_ems")
				end

				if not DecorExistOn(GLOBAL_PED, "player_admin") then
					DecorSetBool(GLOBAL_PED, "player_admin", playerData.developer)
				end
				-- If there police & ON duty set a Police Decor on there ped
				if playerData.job.name == "police" and (playerData.job.duty) and not DecorExistOn(GLOBAL_PED, "player_cop") then
					DecorSetBool(GLOBAL_PED, "player_cop", true)
				end
				-- If there ems & ON duty set a Police Decor on there ped
				if playerData.job.name == "ems" and (playerData.job.duty) and not DecorExistOn(GLOBAL_PED, "player_cop") then
					DecorSetBool(GLOBAL_PED, "player_ems", true)
				end
				-- If there police & OFF duty remove the Police Decor on there ped
				if playerData.job.name == "police" and (not playerData.job.duty) and DecorExistOn(GLOBAL_PED, "player_cop") then
					DecorRemove(GLOBAL_PED, "player_cop")
				end
				-- If there ems & OFF duty remove the EMS Decor on there ped
				if playerData.job.name == "ems" and (not playerData.job.duty) and DecorExistOn(GLOBAL_PED, "player_cop") then
					DecorRemove(GLOBAL_PED, "player_ems")
				end

				-- Set the Old Ped ID to Current incase they did change ped...
				OLD_PED = GLOBAL_PED
			end
		end
		Citizen.Wait(60000)
	end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            playerLoaded = true
			TriggerServerEvent('pw:characterLoaded')
			DecorSetBool(PlayerPedId(), "player_admin", playerData.developer)
        else
			playerData = data
			NetworkSetFriendlyFireOption(true)
            SetCanAttackFriendly(PlayerPedId(), true, true)
        end
    else
        playerData = nil
		playerLoaded = false
		TriggerServerEvent('pw:characterUnLoaded')
    end
end)

PW.ExecuteServerCallback = function(name, cb, ...)
	PW.ServerCallbacks[PW.CurrentRequestId] = cb
	TriggerServerEvent('pw:serverCallback', name, PW.CurrentRequestId, ...)
	if PW.CurrentRequestId < 65535 then
		PW.CurrentRequestId = PW.CurrentRequestId + 1
	else
		PW.CurrentRequestId = 0
	end
end

PW.TriggerServerCallback = function(name, cb, ...)
	PW.ServerCallbacks[PW.CurrentRequestId] = cb
	TriggerServerEvent('pw:serverCallback', name, PW.CurrentRequestId, ...)
	if PW.CurrentRequestId < 65535 then
		PW.CurrentRequestId = PW.CurrentRequestId + 1
	else
		PW.CurrentRequestId = 0
	end
end

PW.Print = function(t, s)
    if t then
        if type(t) ~= 'table' then 
            print(" [debug] ["..type(t).."] ", t)
            return
        else
            for k, v in pairs(t) do
                local kfmt = '["' .. tostring(k) ..'"]'
                if type(k) ~= 'string' then
                    kfmt = '[' .. k .. ']'
                end
                local vfmt = '"'.. tostring(v) ..'"'
                if type(v) == 'table' then
                    PW.Print(v, (s or '')..kfmt)
                else
                    if type(v) ~= 'string' then
                        vfmt = tostring(v)
                    end
					print(" [debug] ["..type(t).."]", (s or '')..kfmt, '=', vfmt)
                end
            end
        end
    else
        print("Error Printing Request - The Passed through variable seems to be nil")
    end
end

PW.GetPlayerData = function(pedId, cb)
	if IsEntityAPed(pedId) and IsPedAPlayer(pedId) then
		local plySrc = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pedId))
		PW.TriggerServerCallback('pw_core:server:getPlayerData', function(data)
			cb(data)
		end, plySrc)
	end
end

PW.GetPlayerDataSrc = function(src, cb)
	if src then
		PW.TriggerServerCallback('pw_core:server:getPlayerData', function(data)
			cb(data)
		end, src)
	end
end

PW.KeysTable = function(req)
	local Keys = {
		['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169,
		['F9'] = 56, ['F10'] = 57, ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165,
		['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177, ['TAB'] = 37,
		['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39,
		[']'] = 40, ['ENTER'] = 18, ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74,
		['K'] = 311, ['L'] = 182, ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29,
		['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81, ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22,
		['RIGHTCTRL'] = 70, ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178, ['LEFT'] = 174,
		['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173, ['NENTER'] = 201, ['N4'] = 108, ['N5'] = 60, ['N6'] = 107,
		['N+'] = 96, ['N-'] = 97, ['N7'] = 117, ['N8'] = 61, ['N9'] = 118
		}

	if req ~= nil and Keys[tostring(req)] then
		return Keys[tostring(req)]
	elseif req == nil then
		return Keys
	else
		print('Incorrect Usage of Function please use PW.KeysTable("F3") to request a number or PW.KeysTable() to request a table of all keys')
	end
end

PW.Capitalize = function(str)
    return string.gsub(str, "^%l", string.upper)
end

RegisterNetEvent('pw:serverCallback')
AddEventHandler('pw:serverCallback', function(requestId, ...)
	PW.ServerCallbacks[requestId](...)
	PW.ServerCallbacks[requestId] = nil
end)

PW.Game.Teleport = function(x, y, z)
	myPed = GetPlayerPed(-1)
    Citizen.Wait(200)
    SetEntityCoords(myPed, tonumber(x), tonumber(y), tonumber(z), false, false, false, false)
end

RegisterNetEvent('pw:teleport')
AddEventHandler('pw:teleport', function(coords)
    local success = false
	Citizen.CreateThread(function()
		if coords.x ~= false then
			local xPos = tonumber(x)
			local yPos = tonumber(y)
			local zPos = tonumber(z)
			PW.Game.Teleport(coords.x,coords.y,coords.z)
		else
			local entity = PlayerPedId()
			
			if IsPedInAnyVehicle(entity, false) then
				entity = GetVehiclePedIsUsing(entity)
			end

			local blipFound = false
			local blipIterator = GetBlipInfoIdIterator()
			local blip = GetFirstBlipInfoId(8)

			while DoesBlipExist(blip) do
				if GetBlipInfoIdType(blip) == 4 then
					cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
                    blipFound = true
                    success = true
					break
				end
				blip = GetNextBlipInfoId(blipIterator)
			end

			if blipFound then
				local groundFound = false
				local yaw = GetEntityHeading(entity)
				
				for i = 0, 1000, 1 do
					SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
					SetEntityRotation(entity, 0, 0, 0, 0 ,0)
					SetEntityHeading(entity, yaw)
					SetGameplayCamRelativeHeading(0)
					Citizen.Wait(0)
					--groundFound = true
					if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
						cz = ToFloat(i)
						groundFound = true
						break
					end
				end
				if not groundFound then
					cz = -300.0
				end
				success = true
			else
				exports['pw_notify']:SendAlert('error', 'No Coordinates Specified and no WayPoint located.')
			end

			if success then
				SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
				SetGameplayCamRelativeHeading(0)
				if IsPedSittingInAnyVehicle(PlayerPedId()) then
					if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
						SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
					end
				end
				blipFound = false
                exports['pw_notify']:SendAlert('success', 'Moved successfully')
                TriggerEvent('pw:playerTeleported')
                TriggerServerEvent('pw:playerTeleported')
			end
		
		end
	end)
end)

RegisterNetEvent('pw_core:changeLivery')
AddEventHandler('pw_core:changeLivery', function(livery)
	local playerPed = GetPlayerPed(-1)
	local Veh = GetVehiclePedIsIn(playerPed)
	if Veh ~= nil and Veh ~= 0 then
		SetVehicleLivery(Veh, livery)
		exports.pw_notify:SendAlert("inform", "Vehicle Livery Changed")
	else
		exports.pw_notify:SendAlert("error", "You are not in a vehicle.")
	end
end)

function PW.Streaming.RequestModel(modelHash, cb)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function PW.Streaming.RequestStreamedTextureDict(textureDict, cb)
	if not HasStreamedTextureDictLoaded(textureDict) then
		RequestStreamedTextureDict(textureDict)

		while not HasStreamedTextureDictLoaded(textureDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function PW.Streaming.RequestNamedPtfxAsset(assetName, cb)
	if not HasNamedPtfxAssetLoaded(assetName) then
		RequestNamedPtfxAsset(assetName)

		while not HasNamedPtfxAssetLoaded(assetName) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function PW.Streaming.RequestAnimSet(animSet, cb)
	if not HasAnimSetLoaded(animSet) then
		RequestAnimSet(animSet)

		while not HasAnimSetLoaded(animSet) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function PW.Streaming.RequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

PW.Base.GetAvaliableJobs = function()
	local processed = false
	local jobs = {}
	PW.TriggerServerCallback('pw_base:functions:getAvaliableJobs', function(jobscb)
		jobs = jobscb
		processed = true
	end)
	repeat Wait(0) until processed == true
	return jobs
end

PW.Base.GetAvaliableGrades = function(job, cb)
	local grades = {}
	local processed = false
	PW.TriggerServerCallback('pw_base:functions:getAvailiableGrades', function(gradescb)
		grades = gradescb
		processed = true
	end, job)
	repeat Wait(0) until processed == true
	if cb then
		cb(grades)
	else
		return grades
	end
end

PW.Base.GetAvaliableGangs = function()
    local processed = false
    local gangs = {}
    PW.TriggerServerCallback('pw_gangs:server:getGangs', function(gangscb)
        gangs = gangscb
        processed = true
    end)
    repeat Wait(0) until processed == true
    return gangs
end

function PW.Streaming.RequestWeaponAsset(weaponHash, cb)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash)

		while not HasWeaponAssetLoaded(weaponHash) do
			Citizen.Wait(1)
		end
	end

	if cb ~= nil then
		cb()
	end
end

function PW.Vehicles.GetName(model)
	local hashVehicle = (type(model) ~= "number" and GetHashKey(model) or model)
    local displayVehicle = string.gsub(GetDisplayNameFromVehicleModel(hashVehicle), "%s", "_")
	local vehicleName = GetLabelText(displayVehicle)
	if vehicleName == "NULL" or vehicleName == "CARNOTFOUND" then
        vehicleName = GetDisplayNameFromVehicleModel(hashVehicle)
		if vehicleName == "NULL" or vehicleName == "CARNOTFOUND" then
            vehicleName = hashVehicle
		end
	end
	return vehicleName
end

function PW.Vehicles.GetVehId(plate)
	if plate then
		local vId = nil
		PW.TriggerServerCallback('pw_vehiclemanagement:server:getVID', function(id)
			vId = id or false
		end, plate)
		while vId == nil do Citizen.Wait(0) end
		return vId
	else
		return false
	end
end

PW.SetTimeout = function(msec, cb)
	table.insert(PW.TimeoutCallbacks, {
		time = GetGameTimer() + msec,
		cb   = cb
	})
	return #PW.TimeoutCallbacks
end

PW.ClearTimeout = function(i)
	PW.TimeoutCallbacks[i] = nil
end

PW.Math.Round = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

PW.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

PW.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

PW.Game.GetPlayers = function()
	local players = {}

	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)

		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end
	
	return players
end

PW.Game.GetClosestPlayer = function(coords)
	local players         = PW.Game.GetPlayers()
	local closestDistance = -1
	local closestPlayer   = -1
	local coords          = coords
	local usePlayerPed    = false
	local playerPed       = PlayerPedId()
	local playerId        = PlayerId()
	if coords == nil then
		usePlayerPed = true
		coords       = GetEntityCoords(playerPed)
	end

	for i=1, #players, 1 do
		local target = GetPlayerPed(players[i])

		if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
			local targetCoords = GetEntityCoords(target)
			local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

			if closestDistance == -1 or closestDistance > distance then
				closestPlayer   = players[i]
				closestDistance = distance
			end
		end
	end

	return closestPlayer, closestDistance
end

PW.Game.GetPlayersInArea = function(coords, area)
	local players       = PW.Game.GetPlayers()
	local playersInArea = {}

	for i=1, #players, 1 do
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end

PW.Game.GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

PW.Game.GetClosestVehicle = function(coords)
	local vehicles        = PW.Game.GetVehicles()
	local closestDistance = -1
	local closestVehicle  = -1
	local coords          = coords

	if coords == nil then
		local playerPed = PlayerPedId()
		coords          = GetEntityCoords(playerPed)
	end

	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

		if closestDistance == -1 or closestDistance > distance then
			closestVehicle  = vehicles[i]
			closestDistance = distance
			vehInfo = PW.Game.GetVehicleProperties(vehicles[i])
		end
	end

	return closestVehicle, closestDistance, vehInfo
end

PW.Game.GetVehiclesInArea = function(coords, area)
	local vehicles       = PW.Game.GetVehicles()
	local vehiclesInArea = {}

	for i=1, #vehicles, 1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance      = GetDistanceBetweenCoords(vehicleCoords, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(vehiclesInArea, vehicles[i])
		end
	end

	return vehiclesInArea
end

PW.Game.GetVehicleInDirection = function()
	local playerPed    = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local inDirection  = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
	local rayHandle    = StartShapeTestRay(playerCoords, inDirection, 10, playerPed, 0)
	local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	if hit == 1 and GetEntityType(entityHit) == 2 then
		return entityHit
	end

	return nil
end

PW.Game.GetPeds = function(ignoreList)
	local ignoreList = ignoreList or {}
	local peds       = {}

	for ped in EnumeratePeds() do
		local found = false

		for j=1, #ignoreList, 1 do
			if ignoreList[j] == ped then
				found = true
			end
		end

		if not found then
			table.insert(peds, ped)
		end
	end

	return peds
end

PW.Game.ToggleRadar = function(toggle)
	DisplayRadar(toggle)
end

PW.Game.GetClosestPed = function(coords, ignoreList)
	local ignoreList      = ignoreList or {}
	local peds            = PW.Game.GetPeds(ignoreList)
	local closestDistance = -1
	local closestPed      = -1

	for i=1, #peds, 1 do
		local pedCoords = GetEntityCoords(peds[i])
		local distance  = GetDistanceBetweenCoords(pedCoords, coords.x, coords.y, coords.z, true)

		if closestDistance == -1 or closestDistance > distance then
			closestPed      = peds[i]
			closestDistance = distance
		end
	end

	return closestPed, closestDistance
end

PW.Game.GetClosestPedsInArea = function(coords, radius, ignoreList)
	local ignoreList      	= ignoreList or {}
	local peds            	= PW.Game.GetPeds(ignoreList)
	local distanceChecking 	= radius or 20.0
	local closestPeds     	= {}

	for i=1, #peds, 1 do
		local pedCoords = GetEntityCoords(peds[i])
		local distance  = GetDistanceBetweenCoords(pedCoords, coords.x, coords.y, coords.z, true)

		if distance <= radius then
			table.insert(closestPeds, peds[i])
		end
	end

	return closestPeds
end

PW.Game.GetVehicleProperties = function(vehicle)
	local paintType1, whoCaresColor1, whoCaresPearlescentColor1 = GetVehicleModColor_1(vehicle)
	local paintType2, whoCaresColor2, whoCaresPearlescentColor2 = GetVehicleModColor_2(vehicle)
	local color1 = {}
	local color2 = {}
	color1[1], color1[2], color1[3] = GetVehicleCustomPrimaryColour(vehicle)
	color2[1], color2[2], color2[3] = GetVehicleCustomSecondaryColour(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	local extras = {}
	
	for id=0, 12 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
			extras[tostring(id)] = state
		end
	end

	return {
		model             = GetEntityModel(vehicle),
		plate             = PW.Math.Trim(GetVehicleNumberPlateText(vehicle)),
		plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

		doorLock 		  = GetVehicleDoorLockStatus(vehicle),

		bodyHealth        = PW.Math.Round(GetVehicleBodyHealth(vehicle), 1),
		engineHealth      = PW.Math.Round(GetVehicleEngineHealth(vehicle), 1),
		tankHealth        = PW.Math.Round(GetVehiclePetrolTankHealth(vehicle), 1),

		fuelLevel         = PW.Math.Round(GetVehicleFuelLevel(vehicle), 1),
		dirtLevel         = PW.Math.Round(GetVehicleDirtLevel(vehicle), 1),
		color1            = color1,
		color2            = color2,
		paintType		  = {paintType1, paintType2},		  

		pearlescentColor  = pearlescentColor,
		wheelColor        = wheelColor,

		wheels            = GetVehicleWheelType(vehicle),
		windowTint        = GetVehicleWindowTint(vehicle),

		neonEnabled       = {
			IsVehicleNeonLightEnabled(vehicle, 0),
			IsVehicleNeonLightEnabled(vehicle, 1),
			IsVehicleNeonLightEnabled(vehicle, 2),
			IsVehicleNeonLightEnabled(vehicle, 3)
		},

		extras            = extras,

		neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
		tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

		modSpoilers       = GetVehicleMod(vehicle, 0),
		modFrontBumper    = GetVehicleMod(vehicle, 1),
		modRearBumper     = GetVehicleMod(vehicle, 2),
		modSideSkirt      = GetVehicleMod(vehicle, 3),
		modExhaust        = GetVehicleMod(vehicle, 4),
		modFrame          = GetVehicleMod(vehicle, 5),
		modGrille         = GetVehicleMod(vehicle, 6),
		modHood           = GetVehicleMod(vehicle, 7),
		modFender         = GetVehicleMod(vehicle, 8),
		modRightFender    = GetVehicleMod(vehicle, 9),
		modRoof           = GetVehicleMod(vehicle, 10),

		modEngine         = GetVehicleMod(vehicle, 11),
		modBrakes         = GetVehicleMod(vehicle, 12),
		modTransmission   = GetVehicleMod(vehicle, 13),
		modHorns          = GetVehicleMod(vehicle, 14),
		modSuspension     = GetVehicleMod(vehicle, 15),
		modArmor          = GetVehicleMod(vehicle, 16),

		modTurbo          = IsToggleModOn(vehicle, 18),
		modSmokeEnabled   = IsToggleModOn(vehicle, 20),
		modXenon          = IsToggleModOn(vehicle, 22),
		modXenonColor	  = GetVehicleXenonLightsColour(vehicle) or -1,

		modFrontWheels    = GetVehicleMod(vehicle, 23),
		modBackWheels     = GetVehicleMod(vehicle, 24),

		modPlateHolder    = GetVehicleMod(vehicle, 25),
		modVanityPlate    = GetVehicleMod(vehicle, 26),
		modTrimA          = GetVehicleMod(vehicle, 27),
		modOrnaments      = GetVehicleMod(vehicle, 28),
		modDashboard      = GetVehicleMod(vehicle, 29),
		modDial           = GetVehicleMod(vehicle, 30),
		modDoorSpeaker    = GetVehicleMod(vehicle, 31),
		modSeats          = GetVehicleMod(vehicle, 32),
		modSteeringWheel  = GetVehicleMod(vehicle, 33),
		modShifterLeavers = GetVehicleMod(vehicle, 34),
		modAPlate         = GetVehicleMod(vehicle, 35),
		modSpeakers       = GetVehicleMod(vehicle, 36),
		modTrunk          = GetVehicleMod(vehicle, 37),
		modHydrolic       = GetVehicleMod(vehicle, 38),
		modEngineBlock    = GetVehicleMod(vehicle, 39),
		modAirFilter      = GetVehicleMod(vehicle, 40),
		modStruts         = GetVehicleMod(vehicle, 41),
		modArchCover      = GetVehicleMod(vehicle, 42),
		modAerials        = GetVehicleMod(vehicle, 43),
		modTrimB          = GetVehicleMod(vehicle, 44),
		modTank           = GetVehicleMod(vehicle, 45),
		modWindows        = GetVehicleMod(vehicle, 46),
		modLivery         = GetVehicleLivery(vehicle)
	}
end

local nbrDisplaying = 1

RegisterNetEvent('pw_core:startMeText')
AddEventHandler('pw_core:startMeText', function(args)
	local text = ''
	for i = 1, #args do
		text = text..' '..args[i]
	end
	TriggerServerEvent('pw_core:startMeText', text)
end)

RegisterNetEvent('pw_core:broadcastMeText')
AddEventHandler('pw_core:broadcastMeText', function(text, source)
	local offset = 1 + (nbrDisplaying*0.14)
	Display(GetPlayerFromServerId(source), text, offset)
end)

function Display(mePlayer, text, offset)
	local displaying = true
	local displayTime = 7000

    Citizen.CreateThread(function()
        Wait(displayTime)
        displaying = false
	end)
	
    Citizen.CreateThread(function()
        nbrDisplaying = nbrDisplaying + 1
        while displaying do
            Wait(0)
            local coordsMe = GetEntityCoords(GetPlayerPed(mePlayer), false)
            local coords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist2(coordsMe, coords)
            if dist < 2500 then
                if HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(mePlayer), 17 ) then
                    PW.Game.DrawText3D(coordsMe['x'], coordsMe['y'], coordsMe['z'], text)
                end
            end
        end
        nbrDisplaying = nbrDisplaying - 1
    end)
end

PW.Game.DrawText3D = function(x, y, z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local scale = 0.45
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0150, 0.030 + factor , 0.030, 66, 66, 66, 150)
    end
end

PW.Game.MissionText = function(text, time)
	ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(time, 1)
end

PW.Game.SetVehicleProperties = function(vehicle, props)
	SetVehicleModKit(vehicle, 0)

	if props.plate ~= nil then SetVehicleNumberPlateText(vehicle, props.plate) end
	if props.plateIndex ~= nil then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
	if props.bodyHealth ~= nil then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
	if props.engineHealth ~= nil then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)	end
	if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
	if props.fuelLevel ~= nil then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
	if props.dirtLevel ~= nil then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
	if props.paintType ~= nil then
		SetVehicleModColor_1(vehicle, props.paintType[1], 0, 0)
		SetVehicleModColor_2(vehicle, props.paintType[2], 0, 0)
	end
	if props.color1 ~= nil then
		ClearVehicleCustomPrimaryColour(vehicle)
		SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
	end
	if props.color2 ~= nil then
		ClearVehicleCustomSecondaryColour(vehicle)
		SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
	end
	if props.pearlescentColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
	end
	if props.wheelColor ~= nil then
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
	end
	if props.wheels ~= nil then SetVehicleWheelType(vehicle, props.wheels) end
	if props.windowTint ~= nil then SetVehicleWindowTint(vehicle, props.windowTint) end
	if props.neonEnabled ~= nil then
		for i = 0, 3 do
			SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i+1])
		end
	end
	if props.extras ~= nil then
		for id,enabled in pairs(props.extras) do
			SetVehicleExtra(vehicle, tonumber(id), (enabled and 0 or 1))
		end
	end
	if props.neonColor ~= nil then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
	if props.modSmokeEnabled ~= nil then ToggleVehicleMod(vehicle, 20, true) end
	if props.tyreSmokeColor ~= nil then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
	if props.modSpoilers ~= nil then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
	if props.modFrontBumper ~= nil then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
	if props.modRearBumper ~= nil then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
	if props.modSideSkirt ~= nil then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
	if props.modExhaust ~= nil then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
	if props.modFrame ~= nil then SetVehicleMod(vehicle, 5, props.modFrame, false) end
	if props.modGrille ~= nil then SetVehicleMod(vehicle, 6, props.modGrille, false) end
	if props.modHood ~= nil then SetVehicleMod(vehicle, 7, props.modHood, false) end
	if props.modFender ~= nil then SetVehicleMod(vehicle, 8, props.modFender, false) end
	if props.modRightFender ~= nil then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
	if props.modRoof ~= nil then SetVehicleMod(vehicle, 10, props.modRoof, false) end
	if props.modEngine ~= nil then SetVehicleMod(vehicle, 11, props.modEngine, false) end
	if props.modBrakes ~= nil then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
	if props.modTransmission ~= nil then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
	if props.modHorns ~= nil then SetVehicleMod(vehicle, 14, props.modHorns, false) end
	if props.modSuspension ~= nil then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
	if props.modArmor ~= nil then SetVehicleMod(vehicle, 16, props.modArmor, false) end
	if props.modTurbo ~= nil then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
	if props.modXenon ~= nil then ToggleVehicleMod(vehicle,  22, props.modXenon) end
	if props.modXenonColor ~= nil then SetVehicleXenonLightsColour(vehicle, props.modXenonColor) end
	if props.modFrontWheels ~= nil then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
	if props.modBackWheels ~= nil then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
	if props.modPlateHolder ~= nil then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
	if props.modVanityPlate ~= nil then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
	if props.modTrimA ~= nil then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
	if props.modOrnaments ~= nil then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
	if props.modDashboard ~= nil then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
	if props.modDial ~= nil then SetVehicleMod(vehicle, 30, props.modDial, false) end
	if props.modDoorSpeaker ~= nil then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
	if props.modSeats ~= nil then SetVehicleMod(vehicle, 32, props.modSeats, false) end
	if props.modSteeringWheel ~= nil then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
	if props.modShifterLeavers ~= nil then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
	if props.modAPlate ~= nil then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
	if props.modSpeakers ~= nil then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
	if props.modTrunk ~= nil then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
	if props.modHydrolic ~= nil then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
	if props.modEngineBlock ~= nil then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
	if props.modAirFilter ~= nil then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
	if props.modStruts ~= nil then SetVehicleMod(vehicle, 41, props.modStruts, false) end
	if props.modArchCover ~= nil then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
	if props.modAerials ~= nil then SetVehicleMod(vehicle, 43, props.modAerials, false) end
	if props.modTrimB ~= nil then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
	if props.modTank ~= nil then SetVehicleMod(vehicle, 45, props.modTank, false) end
	if props.modWindows ~= nil then SetVehicleMod(vehicle, 46, props.modWindows, false) end
	if props.modLivery ~= nil then
		SetVehicleMod(vehicle, 48, props.modLivery, false)
		SetVehicleLivery(vehicle, props.modLivery)
	end
end

PW.Game.SpawnOwnedVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		PW.Streaming.RequestModel(model)

		if coords == nil then
			local playerPed = PlayerPedId()
			coords = GetEntityCoords(playerPed) -- get the position of the local player ped
			heading = GetEntityHeading(playerPed)
		end

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
		local id      = NetworkGetNetworkIdFromEntity(vehicle)

		SetNetworkIdCanMigrate(id, true)
		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetVehicleAutoRepairDisabled(vehicle, true)
		SetModelAsNoLongerNeeded(model)
		

		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')
		DecorSetBool(vehicle, "player_owned_veh", true)                
		if cb then
			cb(vehicle)
		end
	end)
end

PW.Game.SpawnLocalVehicle = function(modelName, coords, heading, cb)
	local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

	Citizen.CreateThread(function()
		PW.Streaming.RequestModel(model)

		local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false)

		SetEntityAsMissionEntity(vehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(vehicle, true)
		SetVehicleNeedsToBeHotwired(vehicle, false)
		SetModelAsNoLongerNeeded(model)
		SetVehicleAutoRepairDisabled(vehicle, true)
		RequestCollisionAtCoord(coords.x, coords.y, coords.z)

		while not HasCollisionLoadedAroundEntity(vehicle) do
			RequestCollisionAtCoord(coords.x, coords.y, coords.z)
			Citizen.Wait(0)
		end

		SetVehRadioStation(vehicle, 'OFF')
		DecorSetBool(vehicle, "player_owned_veh", false)                
		if cb then
			cb(vehicle)
		end
	end)
end

PW.Game.SpawnVehicle = function(vehicle, pos, entervehicle, networked)
	local vehicleName = vehicle or 'adder'
    
        if vehicleName == nil then 
            return 
        end
    
        -- check if the vehicle actually exists
        
        if not IsModelInCdimage(vehicleName) or not IsModelAVehicle(vehicleName) then
            return
        end
        
    
        -- load the model
        RequestModel(vehicleName)
    
        -- wait for the model to load
        while not HasModelLoaded(vehicleName) do
            Wait(500) -- often you'll also see Citizen.Wait
        end
    
        -- get the player's position
		local playerPed = PlayerPedId() -- get the local player ped
		if pos == nil then
			pos = GetEntityCoords(playerPed) -- get the position of the local player ped
		end

		if pos == nil then
			pos.h = GetEntityHeading(playerPed)
		else
			if pos.h == nil then
				pos.h = GetEntityHeading(playerPed)
			end
		end
    
		if networked == nil then
			networked = true
		end

		-- create the vehicle
		local vehicle = CreateVehicle(vehicleName, pos.x, pos.y, pos.z, pos.h, networked, false)

		-- set the player ped into the vehicle's driver seat
		if entervehicle then
			SetPedIntoVehicle(playerPed, vehicle, -1)
		end
    
		-- give the vehicle back to the game (this'll make the game decide when to despawn the vehicle)
		SetVehicleAutoRepairDisabled(vehicle, true)
        SetEntityAsNoLongerNeeded(vehicle)
    
        -- release the model
		SetModelAsNoLongerNeeded(vehicleName)
		DecorSetBool(vehicle, "player_owned_veh", false)                
		return vehicle
end

PW.Game.GetNearbyPlayers = function(dist)
	local coords = GetEntityCoords(PlayerPedId(), true)
	local nearPlayers = {}
	for _, player in ipairs(GetActivePlayers()) do
		if Config.GetOthersOnly and player ~= PlayerId() then
			local ped = GetPlayerPed(player) 
            local targetCoords = GetEntityCoords(ped)
			local distance = #(vector3(targetCoords.x, targetCoords.y, targetCoords.z) - coords)
			if distance <= dist then
                table.insert(nearPlayers, {
                    id = GetPlayerServerId(player)
                })
            end
		else
			local ped = GetPlayerPed(player) 
            local targetCoords = GetEntityCoords(ped)
			local distance = #(vector3(targetCoords.x, targetCoords.y, targetCoords.z) - coords)
			if distance <= dist then
                table.insert(nearPlayers, {
                    id = GetPlayerServerId(player)
                })
            end
		end
	end

	local players

	if #nearPlayers > 0 then
		PW.TriggerServerCallback('pw:base:server:getPlayerNamesNearby', function(returnedPlayers)
			players = returnedPlayers
		end, nearPlayers)
		repeat Wait(0) until players ~= nil
	end

	return players
end

PW.Game.SpawnObjectNoOffset = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	Citizen.CreateThread(function()
		PW.Streaming.RequestModel(model)
		local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, true, false, true)
		if cb ~= nil then
			cb(obj)
		end
	end)
end

PW.Game.SpawnLocalObjectNoOffset = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	Citizen.CreateThread(function()
		PW.Streaming.RequestModel(model)
		local obj = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, false, false, true)
		if cb ~= nil then
			cb(obj)
		end
	end)
end

PW.Game.CreateCameraView = function(camCoords, lookAtCoords, fieldOfView)
	Citizen.CreateThread(function()
		DoScreenFadeOut(1000)
		Citizen.Wait(1001)
		cameraFunc = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camCoords.x, camCoords.y, camCoords.z, 0.00, 0.00, 0.00, fieldOfView, false, 0)
		PointCamAtCoord(cameraFunc, lookAtCoords.x, lookAtCoords.y, lookAtCoords.z)
		SetCamActive(cameraFunc, true)
		RenderScriptCams(true, true, 0, true, true)
		Citizen.Wait(500)
		DoScreenFadeIn(500)
	end)
end

PW.Game.CancelCameraView = function()
	if cameraFunc then
		DoScreenFadeOut(1000)
		Citizen.Wait(1001)
		SetCamActive(cameraFunc, false)
		DestroyCam(cameraFunc, false)
		RenderScriptCams(false, false, 0, true, true)
		Citizen.Wait(500)
		DoScreenFadeIn(500)
	end
end

PW.Game.SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	Citizen.CreateThread(function()
		PW.Streaming.RequestModel(model)
		local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, true)
		if cb ~= nil then
			cb(obj)
		end
	end)
end

PW.Game.DeleteObject = function(object)
	SetEntityAsMissionEntity(object, false, true)
	DeleteObject(object)
end

PW.Game.GetObjects = function()
	local objects = {}

	for object in EnumerateObjects() do
		table.insert(objects, object)
	end

	return objects
end

PW.Game.GetClosestObject = function(filter, coords)
	local objects = PW.Game.GetObjects()
	local closestDistance, closestObject = -1, -1
	local filter, coords = filter, coords

	if type(filter) == 'string' then
		if filter ~= '' then
			filter = {filter}
		end
	end

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for i=1, #objects, 1 do
		local foundObject = false

		if filter == nil or (type(filter) == 'table' and #filter == 0) then
			foundObject = true
		else
			local objectModel = GetEntityModel(objects[i])

			for j=1, #filter, 1 do
				if objectModel == GetHashKey(filter[j]) then
					foundObject = true
					break
				end
			end
		end

		if foundObject then
			local objectCoords = GetEntityCoords(objects[i])
			local distance = #(objectCoords - coords)

			if closestDistance == -1 or closestDistance > distance then
				closestObject = objects[i]
				closestDistance = distance
			end
		end
	end

	return closestObject, closestDistance
end

PW.Game.CheckInventory = function(item)
	local count = 0
	local processed = false
	PW.TriggerServerCallback('pw_core:server:getItemCount', function(cou)
		count = cou
		processed = true
	end, item)
	repeat Wait(0) until processed == true
	return count	
end

function GetColor(idx)
	local function _U(color)
		colors = {
				['black'] = 'black',
				['graphite'] = 'graphite',
				['black_metallic'] = 'black Metallic',
				['caststeel'] = 'cast Steel',
				['black_anth'] = 'black Anthracite',
				['matteblack'] = 'matte Black',
				['darknight'] = 'dark Night',
				['deepblack'] = 'deep Black',
				['oil'] = 'oil',
				['carbon'] = 'carbon',
				-- White
				['white'] = 'white',
				['vanilla'] = 'vanilla',
				['creme'] = 'creme',
				['polarwhite'] = 'polar White',
				['beige'] = 'beige',
				['mattewhite'] = 'matte White',
				['snow'] = 'snow',
				['cotton'] = 'cotton',
				['alabaster'] = 'alabaster',
				['purewhite'] = 'pure White',
				-- Grey
				['grey'] = 'grey',
				['silver'] = 'silver',
				['metallicgrey'] = 'metallic Grey',
				['laminatedsteel'] = 'laminated Steel',
				['darkgray'] = 'dark Grey',
				['rockygray'] = 'rocky Grey',
				['graynight'] = 'gray Night',
				['aluminum'] = 'aluminum',
				['graymat'] = 'matte Grey',
				['lightgrey'] = 'light Grey',
				['asphaltgray'] = 'asphalt Grey',
				['grayconcrete'] = 'concrete Grey',
				['darksilver'] = 'dark Silver',
				['magnesite'] = 'magnesite',
				['nickel'] = 'nickel',
				['zinc'] = 'zinc',
				['dolomite'] = 'dolomite',
				['bluesilver'] = 'blue Silver',
				['titanium'] = 'titanium',
				['steelblue'] = 'steel Blue',
				['champagne'] = 'champagne',
				['grayhunter'] = 'grey Hunter',
				-- Red
				['red'] = 'red',
				['torino_red'] = 'torino Red',
				['poppy'] = 'poppy',
				['copper_red'] = 'copper Red',
				['cardinal'] = 'cardinal Red',
				['brick'] = 'brick Red',
				['garnet'] = 'Garnet',
				['cabernet'] = 'cabernet Red',
				['candy'] = 'candy Red',
				['matte_red'] = 'matte Red',
				['dark_red'] = 'dark Red',
				['red_pulp'] = 'red Pulp',
				['bril_red'] = 'brilliant Red',
				['pale_red'] = 'pale Red',
				['wine_red'] = 'wine Red',
				['volcano'] = 'Volcano',
				-- Pink
				['pink'] = 'pink',
				['electricpink'] = 'electric Pink',
				['brightpink'] = 'bright Pink',
				['salmon'] = 'salmon',
				['sugarplum'] = 'sugar Plum',
				-- Blue
				['blue'] = 'blue',
				['topaz'] = 'topaz',
				['light_blue'] = 'light Blue',
				['galaxy_blue'] = 'galaxy Blue',
				['dark_blue'] = 'dark Blue',
				['azure'] = 'azure',
				['navy_blue'] = 'navy Blue',
				['lapis'] = 'lapis Lazuli',
				['blue_diamond'] = 'blue Diamond',
				['surfer'] = 'surfer',
				['pastel_blue'] = 'pastel Blue',
				['celeste_blue'] = 'celeste Blue',
				['rally_blue'] = 'rally Blue',
				['blue_paradise'] = 'blue Paradise',
				['blue_night'] = 'blue Night',
				['cyan_blue'] = 'cyan Blue',
				['cobalt'] = 'cobalt',
				['electric_blue'] = 'electric Blue',
				['horizon_blue'] = 'horizon Blue',
				['metallic_blue'] = 'metallic Blue',
				['aquamarine'] = 'aquamarine',
				['blue_agathe'] = 'blue Agathe',
				['zirconium'] = 'zirconium',
				['spinel'] = 'spinel',
				['tourmaline'] = 'tourmaline',
				['paradise'] = 'paradise',
				['bubble_gum'] = 'bubble Gum',
				['midnight_blue'] = 'midnight Blue',
				['forbidden_blue'] = 'forbidden Blue',
				['glacier_blue'] = 'glacier Blue',
				-- Yellow
				['yellow'] = 'yellow',
				['wheat'] = 'wheat',
				['raceyellow'] = 'race Yellow',
				['paleyellow'] = 'pale Yellow',
				['lightyellow'] = 'light Yellow',
				-- Green
				['green'] = 'green',
				['met_dark_green'] = 'metallic Dark Green',
				['rally_green'] = 'Rally Green',
				['pine_green'] = 'pine Green',
				['olive_green'] = 'olive Green',
				['light_green'] = 'Light Green',
				['lime_green'] = 'lime green',
				['forest_green'] = 'forest Green',
				['lawn_green'] = 'lawn Green',
				['imperial_green'] = 'imperial Green',
				['green_bottle'] = 'breen Bottle',
				['citrus_green'] = 'citrus Green',
				['green_anis'] = 'green Anis',
				['khaki'] = 'Khaki',
				['army_green'] = 'army Green',
				['dark_green'] = 'dark Green',
				['hunter_green'] = 'hunter Green',
				['matte_foilage_green'] = 'matte Foilage Green',
				-- Orange
				['orange'] = 'orange',
				['tangerine'] = 'Tangerine',
				['matteorange'] = 'Matte Orange',
				['lightorange'] = 'Light Orange',
				['peach'] = 'Peach',
				['pumpkin'] = 'Pumpkin',
				['orangelambo'] = 'Orange Lambo',
				-- Brown
				['brown'] = 'brown',
				['copper'] = 'Copper',
				['lightbrown'] = 'Light Brown',
				['darkbrown'] = 'Dark Brown',
				['bronze'] = 'Bronze',
				['brownmetallic'] = 'Brown Metallic',
				['espresso'] = 'Espresso',
				['chocolate'] = 'Chocolate',
				['terracotta'] = 'Terracotta',
				['marble'] = 'Marble',
				['sand'] = 'Sand',
				['sepia'] = 'Sepia',
				['bison'] = 'Bison',
				['palm'] = 'Palm',
				['caramel'] = 'Caramel',
				['rust'] = 'Rust',
				['chestnut'] = 'Chestnut',
				['hazelnut'] = 'Hazelnut',
				['shell'] = 'Shell',
				['mahogany'] = 'Mahogany',
				['cauldron'] = 'Cauldron',
				['blond'] = 'Blond',
				['gravel'] = 'Gravel',
				['darkearth'] = 'Dark Earth',
				['desert'] = 'Desert',
				-- Purple
				['purple'] = 'purple',
				['indigo'] = 'Indigo',
				['deeppurple'] = 'Deep Purple',
				['darkviolet'] = 'Dark Violet',
				['amethyst'] = 'Amethyst',
				['mysticalviolet'] = 'Mystic Violet',
				['purplemetallic'] = 'Purple Metallic',
				['matteviolet'] = 'Matte Violet',
				['mattedeeppurple'] = 'Matte Deep Purple',
				-- Chrome
				['chrome'] = 'chrome',
				['brushedchrome'] = 'brushed Chrome',
				['blackchrome'] = 'black Chrome',
				['brushedaluminum'] = 'brushed Aluminum',
				-- Metal
				['gold'] = 'gold',
				['puregold'] = 'pure Gold',
				['brushedgold'] = 'brushed Gold',
				['lightgold'] = 'light Gold',
		}

		local function firstToUpper(str)
			return (str:gsub("^%l", string.upper))
		end

		if colors[color] then
			return firstToUpper(colors[color])
		end
	end

	local colors = {
			{ index = 0, label = _U('black')},
			{ index = 1, label = _U('graphite')},
			{ index = 2, label = _U('black_metallic')},
			{ index = 3, label = _U('caststeel')},
			{ index = 11, label = _U('black_anth')},
			{ index = 12, label = _U('matteblack')},
			{ index = 15, label = _U('darknight')},
			{ index = 16, label = _U('deepblack')},
			{ index = 21, label = _U('oil')},
			{ index = 147, label = _U('carbon')},
			{ index = 106, label = _U('vanilla')},
			{ index = 107, label = _U('creme')},
			{ index = 111, label = _U('white')},
			{ index = 112, label = _U('polarwhite')},
			{ index = 113, label = _U('beige')},
			{ index = 121, label = _U('mattewhite')},
			{ index = 122, label = _U('snow')},
			{ index = 131, label = _U('cotton')},
			{ index = 132, label = _U('alabaster')},
			{ index = 134, label = _U('purewhite')},
			{ index = 4, label = _U('silver')},
			{ index = 5, label = _U('metallicgrey')},
			{ index = 6, label = _U('laminatedsteel')},
			{ index = 7, label = _U('darkgray')},
			{ index = 8, label = _U('rockygray')},
			{ index = 9, label = _U('graynight')},
			{ index = 10, label = _U('aluminum')},
			{ index = 13, label = _U('graymat')},
			{ index = 14, label = _U('lightgrey')},
			{ index = 17, label = _U('asphaltgray')},
			{ index = 18, label = _U('grayconcrete')},
			{ index = 19, label = _U('darksilver')},
			{ index = 20, label = _U('magnesite')},
			{ index = 22, label = _U('nickel')},
			{ index = 23, label = _U('zinc')},
			{ index = 24, label = _U('dolomite')},
			{ index = 25, label = _U('bluesilver')},
			{ index = 26, label = _U('titanium')},
			{ index = 66, label = _U('steelblue')},
			{ index = 93, label = _U('champagne')},
			{ index = 144, label = _U('grayhunter')},
			{ index = 156, label = _U('grey')},
			{ index = 27, label = _U('red')},
			{ index = 28, label = _U('torino_red')},
			{ index = 29, label = _U('poppy')},
			{ index = 30, label = _U('copper_red')},
			{ index = 31, label = _U('cardinal')},
			{ index = 32, label = _U('brick')},
			{ index = 33, label = _U('garnet')},
			{ index = 34, label = _U('cabernet')},
			{ index = 35, label = _U('candy')},
			{ index = 39, label = _U('matte_red')},
			{ index = 40, label = _U('dark_red')},
			{ index = 43, label = _U('red_pulp')},
			{ index = 44, label = _U('bril_red')},
			{ index = 46, label = _U('pale_red')},
			{ index = 143, label = _U('wine_red')},
			{ index = 150, label = _U('volcano')},
			{ index = 135, label = _U('electricpink')},
			{ index = 136, label = _U('salmon')},
			{ index = 137, label = _U('sugarplum')},
			{ index = 54, label = _U('topaz')},
			{ index = 60, label = _U('light_blue')},
			{ index = 61, label = _U('galaxy_blue')},
			{ index = 62, label = _U('dark_blue')},
			{ index = 63, label = _U('azure')},
			{ index = 64, label = _U('navy_blue')},
			{ index = 65, label = _U('lapis')},
			{ index = 67, label = _U('blue_diamond')},
			{ index = 68, label = _U('surfer')},
			{ index = 69, label = _U('pastel_blue')},
			{ index = 70, label = _U('celeste_blue')},
			{ index = 73, label = _U('rally_blue')},
			{ index = 74, label = _U('blue_paradise')},
			{ index = 75, label = _U('blue_night')},
			{ index = 77, label = _U('cyan_blue')},
			{ index = 78, label = _U('cobalt')},
			{ index = 79, label = _U('electric_blue')},
			{ index = 80, label = _U('horizon_blue')},
			{ index = 82, label = _U('metallic_blue')},
			{ index = 83, label = _U('aquamarine')},
			{ index = 84, label = _U('blue_agathe')},
			{ index = 85, label = _U('zirconium')},
			{ index = 86, label = _U('spinel')},
			{ index = 87, label = _U('tourmaline')},
			{ index = 127, label = _U('paradise')},
			{ index = 140, label = _U('bubble_gum')},
			{ index = 141, label = _U('midnight_blue')},
			{ index = 146, label = _U('forbidden_blue')},
			{ index = 157, label = _U('glacier_blue')},
			{ index = 42, label = _U('yellow')},
			{ index = 88, label = _U('wheat')},
			{ index = 89, label = _U('raceyellow')},
			{ index = 91, label = _U('paleyellow')},
			{ index = 126, label = _U('lightyellow')},
			{ index = 49, label = _U('met_dark_green')},
			{ index = 50, label = _U('rally_green')},
			{ index = 51, label = _U('pine_green')},
			{ index = 52, label = _U('olive_green')},
			{ index = 53, label = _U('light_green')},
			{ index = 55, label = _U('lime_green')},
			{ index = 56, label = _U('forest_green')},
			{ index = 57, label = _U('lawn_green')},
			{ index = 58, label = _U('imperial_green')},
			{ index = 59, label = _U('green_bottle')},
			{ index = 92, label = _U('citrus_green')},
			{ index = 125, label = _U('green_anis')},
			{ index = 128, label = _U('khaki')},
			{ index = 133, label = _U('army_green')},
			{ index = 151, label = _U('dark_green')},
			{ index = 152, label = _U('hunter_green')},
			{ index = 155, label = _U('matte_foilage_green')},
			{ index = 36, label = _U('tangerine')},
			{ index = 38, label = _U('orange')},
			{ index = 41, label = _U('matteorange')},
			{ index = 123, label = _U('lightorange')},
			{ index = 124, label = _U('peach')},
			{ index = 130, label = _U('pumpkin')},
			{ index = 138, label = _U('orangelambo')},
			{ index = 45, label = _U('copper')},
			{ index = 47, label = _U('lightbrown')},
			{ index = 48, label = _U('darkbrown')},
			{ index = 90, label = _U('bronze')},
			{ index = 94, label = _U('brownmetallic')},
			{ index = 95, label = _U('expresso')},
			{ index = 96, label = _U('chocolate')},
			{ index = 97, label = _U('terracotta')},
			{ index = 98, label = _U('marble')},
			{ index = 99, label = _U('sand')},
			{ index = 100, label = _U('sepia')},
			{ index = 101, label = _U('bison')},
			{ index = 102, label = _U('palm')},
			{ index = 103, label = _U('caramel')},
			{ index = 104, label = _U('rust')},
			{ index = 105, label = _U('chestnut')},
			{ index = 108, label = _U('brown')},
			{ index = 109, label = _U('hazelnut')},
			{ index = 110, label = _U('shell')},
			{ index = 114, label = _U('mahogany')},
			{ index = 115, label = _U('cauldron')},
			{ index = 116, label = _U('blond')},
			{ index = 129, label = _U('gravel')},
			{ index = 153, label = _U('darkearth')},
			{ index = 154, label = _U('desert')},
			{ index = 71, label = _U('indigo')},
			{ index = 72, label = _U('deeppurple')},
			{ index = 76, label = _U('darkviolet')},
			{ index = 81, label = _U('amethyst')},
			{ index = 142, label = _U('mysticalviolet')},
			{ index = 145, label = _U('purplemetallic')},
			{ index = 148, label = _U('matteviolet')},
			{ index = 149, label = _U('mattedeeppurple')},
			{ index = 117, label = _U('brushedchrome')},
			{ index = 118, label = _U('blackchrome')},
			{ index = 119, label = _U('brushedaluminum')},
			{ index = 120, label = _U('chrome')},
			{ index = 37, label = _U('gold')},
			{ index = 158, label = _U('puregold')},
			{ index = 159, label = _U('brushedgold')},
			{ index = 160, label = _U('lightgold')}
		}

	for k, v in pairs(colors) do
		if v.index == idx then
			return v.label
		end
	end

	return nil
end


AddEventHandler('pw:loadFramework', function(cb)
	cb(PW)
end)

function loadFramework()
	return PW
end

exports('loadFramework', function()
    return loadFramework()
end)

exports('getVehicleColor', function(idx)
	return GetColor(idx)
end)