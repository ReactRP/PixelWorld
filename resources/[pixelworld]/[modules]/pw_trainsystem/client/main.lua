PW = nil
characterLoaded, playerData, GLOBAL_PED, GLOBAL_COORDS = false, nil, nil, nil

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
            characterLoaded = true
			GLOBAL_PED = PlayerPedId()
			GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
			createBlippers()
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
		deleteBlippers()
		showingtxt = false
		drawingMarker = false
    end
end)

local currentlyRunningMetro = false
local currentMetroStop = 1
local runningMetroStops = false
local inMetroTrain = false
local MetroTrain = nil
local MetroMoving = false
local justBordedMetro = false
local MetroTrainSpeed = 0.0
local MetroMaximumSpeedLimit = 0.0

local showingtxt, drawingMarker = false, false
local blips = {}

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
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)


function GetTrainInDirectionPlease()
    local coordTo = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 100.0, 0.0)
	local offset = 0
	local rayHandle
	local trainFoundInDirection
	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, GLOBAL_PED, 0)	
		_, _, _, _, trainFoundInDirection = GetRaycastResult(rayHandle)
		offset = offset - 1
		if trainFoundInDirection ~= 0 then 
			break 
		end
	end
	local trainDistance = Vdist2(GLOBAL_COORDS, GetEntityCoords(trainFoundInDirection))
	if trainDistance > 25 then 
		trainFoundInDirection = nil 
	end
    return trainFoundInDirection ~= nil and trainFoundInDirection or 0
end


function getClosestMetroSpawnID()
	prevClosest = 99999.9
	for i = 1, #Config.TrainStations.Metro do
		closestDist = #(vector3(Config.TrainStations.Metro[i].trainCoords.x, Config.TrainStations.Metro[i].trainCoords.y, Config.TrainStations.Metro[i].trainCoords.z) - GLOBAL_COORDS)
		if closestDist < prevClosest then 
			prevClosest = closestDist
			returninfo = i
		end		
	end
	return returninfo
end


function FuckingCloseMetroDoors(train, trainCarriage) -- For Some Reason the Train Doors Need to Be Closed Constantly Otherwise They Return to Open
	Citizen.CreateThread(function()
		while characterLoaded and inMetroTrain do
			SetVehicleDoorsShut(train, true)
			SetVehicleDoorsShut(trainCarriage, true)
			Citizen.Wait(10)
		end
	end)
end


function StartMetroRunningOnThisClientPlease()
	Citizen.CreateThread(function()
		SetTrainSpeed(MetroTrain, Config.Speeds['metro'])
		while currentlyRunningMetro do
			Citizen.Wait(100)
			if runningMetroStops and MetroTrain ~= nil then
				local closestStopDistance = #(vector3(Config.TrainStations.Metro[currentMetroStop].trainCoords.x, Config.TrainStations.Metro[currentMetroStop].trainCoords.y, Config.TrainStations.Metro[currentMetroStop].trainCoords.z) -  GetEntityCoords(MetroTrain))
				if closestStopDistance < 40.0 then
					SetTrainSpeed(MetroTrain, 10.0)
					MetroMaximumSpeedLimit = 0.0
					SetTrainCruiseSpeed(MetroTrain, 10.0)
					if closestStopDistance < 5.0 then
						SetTrainSpeed(MetroTrain, 0.0)
						SetTrainCruiseSpeed(MetroTrain, 0.0)
						UpdateMetroStopOnServerSidePlease(currentMetroStop)	
						local waitTime = Config.WaitTimes.eachStation.metro
						Citizen.Wait(waitTime) -- The Time It Waits at the Station
						currentMetroStop = currentMetroStop + 1
						if currentMetroStop > #Config.TrainStations.Metro then
							currentMetroStop = 1
						end
					end
				else
					SetTrainCruiseSpeed(MetroTrain, Config.Speeds['metro'])
					SetTrainSpeed(MetroTrain, Config.Speeds['metro'])
				end
			else
				runningMetroStops = false
				currentlyRunningMetro = false
			end
		end
	end)
end

function UpdateMetroStopOnServerSidePlease(currentMetroStop)
	local tempCurrentMetroStop = currentMetroStop + 1
	if tempCurrentMetroStop > #Config.TrainStations.Metro then
		tempCurrentMetroStop = 1
	end
	TriggerServerEvent('pw_trainsystem:server:updateCurrentMetroStop', tempCurrentMetroStop)
end

RegisterNetEvent('pw_trainsystem:client:passControllingTrains')
AddEventHandler('pw_trainsystem:client:passControllingTrains', function(MetroTrainNetID, MetroTrailerNetID, MetroStopID)
	MetroTrain = NetworkGetEntityFromNetworkId(MetroTrainNetID)
	if DoesEntityExist(MetroTrain) then
		local MetroTrainCoords = GetEntityCoords(MetroTrain)
		SetEntityAsMissionEntity(MetroTrain)
		currentMetroStop = MetroStopID
		print('[PW Train System Debug] Train Control Passed To This Client. Next Stop ID: ' .. currentMetroStop .. ' (' .. Config.TrainStations.Metro[currentMetroStop].name .. ') Train ID After Net: '.. MetroTrain)
		currentlyRunningMetro = true
		MetroMaximumSpeedLimit = Config.Speeds['metro']
		SetTrainSpeed(MetroTrain, Config.Speeds['metro'])
		runningMetroStops = true
		Citizen.Wait(5000)
		StartMetroRunningOnThisClientPlease()
	else
		TriggerEvent('pw_trainsystem:client:startTrainHostingInitital')
	end
end)

RegisterNetEvent('pw_trainsystem:client:startTrainHostingInitital')
AddEventHandler('pw_trainsystem:client:startTrainHostingInitital', function()
	DeleteAllTrains()
	local metroID = 1
	currentMetroStop = metroID
	currentlyRunningMetro = false
	MetroTrainSpeed = 0.0
	MetroMaximumSpeedLimit = 0.0

	RequestModel(`metrotrain`)
	while not HasModelLoaded(`metrotrain`) do
		RequestModel(`metrotrain`)
		Citizen.Wait(0)
	end

	MetroTrain = CreateMissionTrain(24, Config.TrainStations.Metro[metroID].trainCoords.x, Config.TrainStations.Metro[metroID].trainCoords.y, Config.TrainStations.Metro[metroID].trainCoords.z, true) -- these ones have pre-defined spawns since they are a pain to set up
	local MetroCarriage = GetTrainCarriage(MetroTrain, 1)
	
	SetTrainCruiseSpeed(MetroTrain, MetroTrainSpeed)
	local MetroTrainID = NetworkGetNetworkIdFromEntity(MetroTrain)
	local MetroCarriageID = NetworkGetNetworkIdFromEntity(MetroCarriage)
	SetEntityAsMissionEntity(MetroTrain)
	TriggerServerEvent('pw_trainsystem:server:saveNetIDsForTrains', MetroTrainID, MetroCarriageID, 2) -- 2 Because it starts at 1


	currentMetroStop = currentMetroStop + 1
	if currentMetroStop > #Config.TrainStations.Metro then
		currentMetroStop = 1
	end		

	local waitTime = Config.WaitTimes.initial.metro
	Citizen.Wait(waitTime)

	runningMetroStops = true
	currentlyRunningMetro = true
	StartMetroRunningOnThisClientPlease()
end)


function createBlippers()
    for k, v in pairs(Config.TrainStations) do
        for t,q in pairs(v) do
            local blipIndex = k..t
			if Config.Blips[k] ~= nil and q.platformCoords.blip then
				blips[blipIndex] = AddBlipForCoord(q.platformCoords.x, q.platformCoords.y, q.platformCoords.z)
				SetBlipSprite(blips[blipIndex], Config.Blips[k].blipSprite)
				SetBlipDisplay(blips[blipIndex], 4)
				SetBlipScale  (blips[blipIndex], Config.Blips[k].blipScale)
				SetBlipColour (blips[blipIndex], Config.Blips[k].blipColor)
				SetBlipAsShortRange(blips[blipIndex], true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(tostring(Config.Blips[k].blipName))
				EndTextCommandSetBlipName(blips[blipIndex])
            end
        end
    end
end

function deleteBlippers()
    for k, v in pairs(blips) do 
        RemoveBlip(v)
    end
end

RegisterNetEvent('pw_trainsystem:client:startTrackingMetro')
AddEventHandler('pw_trainsystem:client:startTrackingMetro', function(trainToTrack, alreadyOwner)
	if characterLoaded and trainToTrack ~= nil then
		local train = nil
		if alreadyOwner then
			train = MetroTrain
		else
			train = NetworkGetEntityFromNetworkId(trainToTrack)
		end
		if train ~= nil and DoesEntityExist(train) then
			local MetroTrackBlip = AddBlipForEntity(train)
			SetBlipSprite(MetroTrackBlip, 103)
			SetBlipDisplay(MetroTrackBlip, 4)
			SetBlipScale(MetroTrackBlip, 1.0)
			SetBlipColour(MetroTrackBlip, 81)
			SetBlipAsShortRange(MetroTrackBlip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString('Metro Train')
			EndTextCommandSetBlipName(MetroTrackBlip)
			TriggerEvent('pw_phone:client:loadData', "startTrackMetro", 'Started Tracking Metro Train. It Will Appear on Your GPS Temporarily')
			Citizen.Wait(100000)
			RemoveBlip(MetroTrackBlip)
			TriggerEvent('pw_phone:client:loadData', "startTrackMetro", 'You Are Not Currently Tracking a Metro Train')
		else
			exports.pw_notify:SendAlert('error', 'Error Tracking Train', 2500)
		end
	end
end)