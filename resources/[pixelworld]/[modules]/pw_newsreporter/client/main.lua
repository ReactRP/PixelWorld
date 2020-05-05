PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
local showingtxt, drawingMarker, blips = false, false, {} 

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
			if playerData.job.name == "newsreporter" then
				createBlips()
			end  
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

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
	if playerData ~= nil then
		playerData.job = data
		if playerData.job.name == "newsreporter" then
			createBlips()
		else
			destroyBlips()
		end
	end
end) 

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
	if playerData then
		playerData.job.duty = toggle
	end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        if characterLoaded and playerData then   
            for k,v in pairs(Config.Points) do   
                if v.public or (not v.public and playerData.job.name == 'newsreporter' and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                    local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z)) 
                    if dist < 15.0 then
                        if not drawingMarker then
                            drawingMarker = k
                            DrawShit(v.coords.x, v.coords.y, v.coords.z, drawingMarker)
                        end

                        if dist < 1.0 then
                            if not showingtxt then
                                showingtxt = k
                                DrawText(k, showingtxt)
                            end
                        elseif showingtxt == k then
                            showingtxt = false
							TriggerEvent('pw_drawtext:hideNotification')
                        end  
                    elseif drawingMarker == k then
                        drawingMarker = false   
                    end          
                elseif showingtxt == k then
                    showingtxt = false
					TriggerEvent('pw_drawtext:hideNotification')
                end      
            end   
        end    
    end
end) 


function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(type, var, heading, rockID)
    local title, message, icon, key
    if type == 'duty' then
        title = "News Reporter Duty"
        message = "<span style='font-size:25px'>Go <b><span class='text-"..(playerData.job.duty and "danger'>Off" or "success'>On").."</span></b> Duty</span>"
		icon = "fal fa-newspaper"  
	elseif type == 'garage' then
        title = "News Garage"
        message = "<span style='font-size:20px'><b>Access News Garage</span></b></span>"
		icon = "fad fa-garage"
	end	      
    if title ~= nil and message ~= nil and icon ~= nil then
		TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showingtxt == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'duty' then
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
					TriggerServerEvent('pw_newsreporter:server:toggleDuty')
				elseif type == 'garage' then
					if IsPedInAnyVehicle(GLOBAL_PED) then
                        ParkVehicle() 
                    else    
                        OpenGarage()   
                    end 	
                end     
            end
        end
    end)
end

-- Vehicle Spawner/Despawner --
function OpenGarage()
    local menu = {}
        table.insert(menu, { ['label'] = PW.Vehicles.GetName(Config.Points.garage.vehicle), ['action'] = 'pw_newsreporter:client:spawnVeh', ['value'] = { ['model'] = Config.Points.garage.vehicle }, ['triggertype'] = 'client', ['color'] = 'primary' })
	TriggerEvent('pw_interact:generateMenu', menu, "News Vehicle Garage")
end

RegisterNetEvent('pw_newsreporter:client:spawnVeh')
AddEventHandler('pw_newsreporter:client:spawnVeh', function(data)
    local coords = Config.Points.garage.vehicleSpawn
    local cV = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    if cV == 0 or cV == nil then
		PW.Game.SpawnOwnedVehicle(data.model, coords, coords.h, function(spawnedVeh)
			SetVehicleLivery(spawnedVeh, 2)
			--TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
			exports.pw_notify:SendAlert('success', 'Spawned Vehicle', 2500)
        end)
	else
		exports.pw_notify:SendAlert('error', 'There\'s a vehicle blocking the vehicle exit', 2500)
    end
end)

function ParkVehicle()
    if GetHashKey(Config.Points.garage.vehicle) == GetEntityModel(GetVehiclePedIsIn(GLOBAL_PED)) then
        local pedVeh = GetVehiclePedIsIn(GLOBAL_PED)
        --local vin = PW.Vehicles.GetVinNumber(PW.Game.GetVehicleProperties(pedVeh).plate)
        SetEntityAsMissionEntity(pedVeh, true, true)
        DeleteEntity(pedVeh)
    else
        exports.pw_notify:SendAlert('error', 'Cannot Return Vehicle', 2500)
    end 
end 




function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.Points) do
            if v.blip then
                blips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
                SetBlipSprite(blips[k], v.blip_info.type)
                SetBlipDisplay(blips[k], 4)
                SetBlipScale  (blips[k], v.blip_info.scale)
                SetBlipColour (blips[k], v.blip_info.color)
                SetBlipAsShortRange(blips[k], true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.blip_info.name)
                EndTextCommandSetBlipName(blips[k])
            end    
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end

local holdingCam, usingCam, holdingMic, usingMic, holdingBmic, usingBmic, newscamera, movcamera = false, false, false, false, false, false, false, false
local camModel, camanimDict, camanimName, micModel, micanimDict, micanimName, bmicModel, bmicanimDict, bmicanimName = "prop_v_cam_01", "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", "p_ing_microphonel_01", "missheistdocksprep1hold_cellphone", "hold_cellphone", "prop_v_bmike_01", "missfra1", "mcs2_crew_idle_m_boom"
local bmic_net, mic_net, cam_net = nil, nil, nil

local UI = { 
	x =  0.000 ,
	y = -0.001 ,
}

-- Camera
RegisterNetEvent("pw_newsreporter:client:ToggleCam")
AddEventHandler("pw_newsreporter:client:ToggleCam", function()
	if characterLoaded then
		if not holdingCam then
			TriggerEvent('pw:notification:SendAlert', {type = "inform", text = 'Press <b><span style="color: #ffff00">E</span></b> to Enter News Camera or <b><span style="color: #ffff00">M</span></b> to Enter Movie Camera. Do the Command Again to Stop Using the Camera.', length = 9000})
			RequestModel(GetHashKey(camModel))
			while not HasModelLoaded(GetHashKey(camModel)) do
				Citizen.Wait(100)
			end
			
			local plyCoords = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0.0, -5.0)
			local camspawned = CreateObject(GetHashKey(camModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
			Citizen.Wait(1000)
			local netid = ObjToNet(camspawned)
			SetNetworkIdExistsOnAllMachines(netid, true)
			NetworkSetNetworkIdDynamic(netid, true)
			SetNetworkIdCanMigrate(netid, false)
			AttachEntityToEntity(camspawned, GLOBAL_PED, GetPedBoneIndex(GLOBAL_PED, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
			TaskPlayAnim(GLOBAL_PED, 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
			TaskPlayAnim(GLOBAL_PED, camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			cam_net = netid
			holdingCam = true
			StartCamThread()
		else
			ClearPedSecondaryTask(GLOBAL_PED)
			DetachEntity(NetToObj(cam_net), 1, 1)
			DeleteEntity(NetToObj(cam_net))
			cam_net = nil
			holdingCam = false
			usingCam = false
			if newscamera then
				newscamera = false
			elseif movcamera then
				movcamera = false
			end		
		end
	end	
end)


function StartCamThread()

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(20)
            if holdingCam then
                while not HasAnimDictLoaded(camanimDict) do
                    RequestAnimDict(camanimDict)
                    Citizen.Wait(100)
                end

                if not IsEntityPlayingAnim(PlayerPedId(), camanimDict, camanimName, 3) then
                    TaskPlayAnim(GetPlayerPed(PlayerId()), 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
                    TaskPlayAnim(GetPlayerPed(PlayerId()), camanimDict, camanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
                end
                    
				SetCurrentPedWeapon(GLOBAL_PED, GetHashKey("WEAPON_UNARMED"), true)

				if holdingCam and IsControlJustReleased(1, 38) and not movcamera then
					newsCam()
				end

				if holdingCam and IsControlJustReleased(1, 244) and not newscamera then
					MovieCam()
				end
				
				if IsPedInAnyVehicle(GLOBAL_PED, false) then
					ClearPedSecondaryTask(GLOBAL_PED)
					DetachEntity(NetToObj(cam_net), 1, 1)
					DeleteEntity(NetToObj(cam_net))
					cam_net = nil
					holdingCam = false
					usingCam = false
					if newscamera then
						newscamera = false
						exports.pw_hud:toggleHud(true)
					elseif movcamera then
						movcamera = false
						exports.pw_hud:toggleHud(true)
					end		
				end	

            else 
                break
            end    
        end
	end)
	
end    

-- Cam Functions

local fov_max, fov_min, zoomspeed, speed_lr, speed_ud, camera = 70.0, 5.0, 10.0, 8.0, 8.0, false
local fov = (fov_max+fov_min)*0.5

function MovieCam()

	movcamera = true
	SetTimecycleModifier("default")
	SetTimecycleModifierStrength(0.3)
	
	local scaleform = RequestScaleformMovie("security_camera")
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(10)
	end

	local cam1 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

	AttachCamToEntity(cam1, GLOBAL_PED, 0.0,0.6,0.75, true)
	SetCamRot(cam1, 2.0,1.0,GetEntityHeading(GLOBAL_PED))
	SetCamFov(cam1, fov)
	RenderScriptCams(true, false, 0, 1, 0)
	PushScaleformMovieFunction(scaleform, "security_camera")
	PopScaleformMovieFunctionVoid()

	while movcamera do
		if IsControlJustPressed(0, 177) or IsControlJustReleased(1, 244) or IsPedInAnyVehicle(GLOBAL_PED, false) then
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
			movcamera = false
			exports.pw_hud:toggleHud(true)
		end
		exports.pw_hud:toggleHud(false)
		SetEntityRotation(GLOBAL_PED, 0, 0, new_z,2, true)

		local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
		CheckInputRotation(cam1, zoomvalue)

		HandleZoom(cam1)
		
		local camHeading = GetGameplayCamRelativeHeading()
		local camPitch = GetGameplayCamRelativePitch()
		if camPitch < -70.0 then
			camPitch = -70.0
		elseif camPitch > 42.0 then
			camPitch = 42.0
		end
		camPitch = (camPitch + 70.0) / 112.0
		if camHeading < -180.0 then
			camHeading = -180.0
		elseif camHeading > 180.0 then
			camHeading = 180.0
		end
		camHeading = (camHeading + 180.0) / 360.0
		Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Pitch", camPitch)
		Citizen.InvokeNative(0xD5BB4025AE449A4E, GetPlayerPed(-1), "Heading", camHeading * -1.0 + 1.0)
		Citizen.Wait(1)
	end
	exports.pw_hud:toggleHud(true)
	movcamera = false
	ClearTimecycleModifier()
	fov = (fov_max+fov_min)*0.5
	RenderScriptCams(false, false, 0, 1, 0)
	SetScaleformMovieAsNoLongerNeeded(scaleform)
	DestroyCam(cam1, false)
	SetNightvision(false)
	SetSeethrough(false)
end


function newsCam()

	newscamera = true
	SetTimecycleModifier("default")
	SetTimecycleModifierStrength(0.3)
	local scaleform = RequestScaleformMovie("security_camera")
	local scaleform2 = RequestScaleformMovie("breaking_news")

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(10)
	end
	while not HasScaleformMovieLoaded(scaleform2) do
		Citizen.Wait(10)
	end

	local GLOBAL_PED = GetPlayerPed(-1)
	local cam2 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

	AttachCamToEntity(cam2, GLOBAL_PED, 0.0,0.6,0.75, true)
	SetCamRot(cam2, 2.0,1.0,GetEntityHeading(GLOBAL_PED))
	SetCamFov(cam2, fov)
	RenderScriptCams(true, false, 0, 1, 0)
	PushScaleformMovieFunction(scaleform2, "breaking_news")
	PopScaleformMovieFunctionVoid()
	exports.pw_hud:toggleHud(false)
	while newscamera do
		if IsControlJustPressed(1, 177) or IsControlJustReleased(1, 38) or IsPedInAnyVehicle(GLOBAL_PED, false) then
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
			newscamera = false
			exports.pw_hud:toggleHud(true)
		end
		SetEntityRotation(GLOBAL_PED, 0, 0, new_z,2, true)
			
		local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
		CheckInputRotation(cam2, zoomvalue)

		HandleZoom(cam2)
		DrawScaleformMovie(scaleform2, 0.5, 0.63, 1.0, 1.0, 255, 255, 255, 255)

		local camHeading = GetGameplayCamRelativeHeading()
		local camPitch = GetGameplayCamRelativePitch()
		if camPitch < -70.0 then
			camPitch = -70.0
		elseif camPitch > 42.0 then
			camPitch = 42.0
		end
		camPitch = (camPitch + 70.0) / 112.0
		
		if camHeading < -180.0 then
			camHeading = -180.0
		elseif camHeading > 180.0 then
			camHeading = 180.0
		end
		camHeading = (camHeading + 180.0) / 360.0
		Citizen.InvokeNative(0xD5BB4025AE449A4E, GLOBAL_PED, "Pitch", camPitch)
		Citizen.InvokeNative(0xD5BB4025AE449A4E, GLOBAL_PED, "Heading", camHeading * -1.0 + 1.0)
		Citizen.Wait(1)
	end
	exports.pw_hud:toggleHud(true)
	newscamera = false
	ClearTimecycleModifier()
	fov = (fov_max+fov_min)*0.5
	RenderScriptCams(false, false, 0, 1, 0)
	SetScaleformMovieAsNoLongerNeeded(scaleform)
	DestroyCam(cam2, false)
	SetNightvision(false)
	SetSeethrough(false)
end


function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	local GLOBAL_PED = GetPlayerPed(-1)
	if not (IsPedSittingInAnyVehicle(GLOBAL_PED)) then

		if IsControlJustPressed(0,241) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsControlJustPressed(0,17) then
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max)
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	end
end

---


-- Normal Mic
RegisterNetEvent("pw_newsreporter:client:ToggleMic")
AddEventHandler("pw_newsreporter:client:ToggleMic", function()
	if characterLoaded then
		if not holdingMic then
			RequestModel(GetHashKey(micModel))
			while not HasModelLoaded(GetHashKey(micModel)) do
				Citizen.Wait(100)
			end
			
			while not HasAnimDictLoaded(micanimDict) do
				RequestAnimDict(micanimDict)
				Citizen.Wait(100)
			end

			local plyCoords = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0.0, -5.0)
			local micspawned = CreateObject(GetHashKey(micModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
			Citizen.Wait(1000)
			local netid = ObjToNet(micspawned)
			SetNetworkIdExistsOnAllMachines(netid, true)
			NetworkSetNetworkIdDynamic(netid, true)
			SetNetworkIdCanMigrate(netid, false)
			AttachEntityToEntity(micspawned, GLOBAL_PED, GetPedBoneIndex(GLOBAL_PED, 60309), 0.055, 0.05, 0.0, 240.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
			TaskPlayAnim(GLOBAL_PED, 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
			TaskPlayAnim(GLOBAL_PED, micanimDict, micanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			mic_net = netid
			holdingMic = true
		else
			ClearPedSecondaryTask(GLOBAL_PED)
			DetachEntity(NetToObj(mic_net), 1, 1)
			DeleteEntity(NetToObj(mic_net))
			mic_net = nil
			holdingMic = false
			usingMic = false
		end
	end	
end)


-- Boom Mic
RegisterNetEvent("pw_newsreporter:client:ToggleBMic")
AddEventHandler("pw_newsreporter:client:ToggleBMic", function()
	if characterLoaded then
		if not holdingBmic then
			RequestModel(GetHashKey(bmicModel))
			while not HasModelLoaded(GetHashKey(bmicModel)) do
				Citizen.Wait(100)
			end
			
			local plyCoords = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0.0, -5.0)
			local bmicspawned = CreateObject(GetHashKey(bmicModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, false)
			Citizen.Wait(1000)
			local netid = ObjToNet(bmicspawned)
			SetNetworkIdExistsOnAllMachines(netid, true)
			NetworkSetNetworkIdDynamic(netid, true)
			SetNetworkIdCanMigrate(netid, false)
			AttachEntityToEntity(bmicspawned, GLOBAL_PED, GetPedBoneIndex(GLOBAL_PED, 28422), -0.08, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
			TaskPlayAnim(GLOBAL_PED, 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
			TaskPlayAnim(GLOBAL_PED, bmicanimDict, bmicanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			bmic_net = netid
			holdingBmic = true
			HoldingBoom()
		else
			ClearPedSecondaryTask(GLOBAL_PED)
			DetachEntity(NetToObj(bmic_net), 1, 1)
			DeleteEntity(NetToObj(bmic_net))
			bmic_net = nil
			holdingBmic = false
			usingBmic = false
		end
	end	
end)

function HoldingBoom()

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(100)
			if holdingBmic then
				while not HasAnimDictLoaded(bmicanimDict) do
					RequestAnimDict(bmicanimDict)
					Citizen.Wait(100)
				end

				if not IsEntityPlayingAnim(GLOBAL_PED, bmicanimDict, bmicanimName, 3) then
					TaskPlayAnim(GLOBAL_PED, 1.0, -1, -1, 50, 0, 0, 0, 0) -- 50 = 32 + 16 + 2
					TaskPlayAnim(GLOBAL_PED, bmicanimDict, bmicanimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
				end
				
				SetCurrentPedWeapon(GLOBAL_PED, GetHashKey("WEAPON_UNARMED"), true)
				
				if IsPedInAnyVehicle(GLOBAL_PED, false) or holdingMic then
					ClearPedSecondaryTask(GLOBAL_PED)
					DetachEntity(NetToObj(bmic_net), 1, 1)
					DeleteEntity(NetToObj(bmic_net))
					bmic_net = nil
					holdingBmic = false
					usingBmic = false
				end
			else
				break
			end	
		end
	end)
end	
