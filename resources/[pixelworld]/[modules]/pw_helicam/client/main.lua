PW = nil
playerLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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

            DecorRegister("SpotvectorX", 3) -- For direction of manual spotlight
			DecorRegister("SpotvectorY", 3)
			DecorRegister("SpotvectorZ", 3)
            DecorRegister("Target", 3) -- Backup method of target ID
            StartHeliChecks()
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
        playerInHeliThread = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

local fov_max = 80.0
local fov_min = 5.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 3.0 -- camera zoom speed
local speed_lr = 4.0 -- speed by which the camera pans left-right 
local speed_ud = 4.0 -- speed by which the camera pans up-down
local brightness = 1.0 -- default spotlight brightness
local spotradius = 4.0 -- default manual spotlight radius
local target_vehicle = nil
local manual_spotlight = false
local tracking spotlight = false
local helicam = false
local fov = (fov_max+fov_min)*0.5
local vision_state = 0 -- 0 is normal, 1 is nightmode, 2 is thermal vision
local playerInHeliThread = false

function StartHeliChecks()
    Citizen.CreateThread(function()
        while characterLoaded do
            Citizen.Wait(1500)
            if IsPlayerInAllowedHeli() then
                if not playerInHeliThread then
                    playerInHeliThread = true
                    StartInHeliThread()
                end
            else
                if playerInHeliThread then
                    playerInHeliThread = false
                end
            end
        end
    end)
end

function StartInHeliThread()
    Citizen.CreateThread(function()
        while playerInHeliThread do
            Citizen.Wait(5)
            local heli = GetVehiclePedIsIn(GLOBAL_PED)
            
            if IsHeliHighEnough(heli) then
                if IsControlJustPressed(0, Config.Controls.ToggleHeliCam) then -- Toggle Helicam
                    helicam = true
                end
                
                if IsControlJustPressed(0, Config.Controls.ToggleRappel) then -- Initiate rappel
                    if GetPedInVehicleSeat(heli, 1) == GLOBAL_PED or GetPedInVehicleSeat(heli, 2) == GLOBAL_PED then
                        exports.pw_notify:SendAlert('info', 'Attempting to Rappel')
                        TaskRappelFromHeli(GLOBAL_PED, 1)
                    else
                        exports.pw_notify:SendAlert('error', 'Unable to Rappel From This Seat', 2500)
                    end
                end
            end
            
            if IsControlJustPressed(0, Config.Controls.ToggleSpotLight) and GetPedInVehicleSeat(heli, -1) == GLOBAL_PED and not helicam then -- Toggle forward and tracking spotlight states
                if target_vehicle then
                    if tracking_spotlight then
                        if not pause_Tspotlight then
                            pause_Tspotlight = true
                            TriggerServerEvent("pw_helicam:server:pauseTrackingSpotlight", pause_Tspotlight)
                        else
                            pause_Tspotlight = false
                            TriggerServerEvent("pw_helicam:server:pauseTrackingSpotlight", pause_Tspotlight)
                        end
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    else
                        if Fspotlight_state then
                            Fspotlight_state = false	
                            TriggerServerEvent("pw_helicam:server:forwardspotlight", Fspotlight_state)
                        end
                        local target_netID = VehToNet(target_vehicle)
                        local target_plate = GetVehicleNumberPlateText(target_vehicle)
                        local targetposx, targetposy, targetposz = table.unpack(GetEntityCoords(target_vehicle))
                        pause_Tspotlight = false
                        tracking_spotlight = true
                        TriggerServerEvent("pw_helicam:server:trackingspotlight", target_netID, target_plate, targetposx, targetposy, targetposz)
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                    end				
                else
                    if tracking_spotlight then
                        pause_Tspotlight = false
                        tracking_spotlight = false
                        TriggerServerEvent("pw_helicam:server:trackingspotlightToggle")
                    end
                    Fspotlight_state = not Fspotlight_state
                    TriggerServerEvent("pw_helicam:server:forwardspotlight", Fspotlight_state)
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                end
            end

            if target_vehicle and GetPedInVehicleSeat(heli, -1) == GLOBAL_PED then
                local coords1 = GetEntityCoords(heli)
                local coords2 = GetEntityCoords(target_vehicle)
                local target_distance = GetDistanceBetweenCoords(coords1.x, coords1.y, coords1.z, coords2.x, coords2.y, coords2.z, false)
                if IsControlJustPressed(0, Config.Controls.ToggleLockOn) or target_distance > Config.TargetLockMaxDist then
                    DecorRemove(target_vehicle, "Target")
                    if tracking_spotlight then
                        TriggerServerEvent("pw_helicam:server:trackingspotlightToggle")
                    end
                    tracking_spotlight = false
                    pause_Tspotlight = false
                    target_vehicle = nil					
                    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                end
            end
            
            if helicam then
                SetTimecycleModifier("heliGunCam")
                SetTimecycleModifierStrength(0.3)
                local scaleform = RequestScaleformMovie("HELI_CAM")
                while not HasScaleformMovieLoaded(scaleform) do
                    Citizen.Wait(0)
                end
                local heli = GetVehiclePedIsIn(GLOBAL_PED)
                local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
                AttachCamToEntity(cam, heli, 0.0,0.0,-1.5, true)
                SetCamRot(cam, 0.0,0.0,GetEntityHeading(heli))
                SetCamFov(cam, fov)
                RenderScriptCams(true, false, 0, 1, 0)
                PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
                PushScaleformMovieFunctionParameterInt(0) -- 0 for nothing, 1 for LSPD logo
                PopScaleformMovieFunctionVoid()
                local locked_on_vehicle = nil
                while helicam and not IsEntityDead(GLOBAL_PED) and (GetVehiclePedIsIn(GLOBAL_PED) == heli) and IsHeliHighEnough(heli) do
                    if IsControlJustPressed(0, Config.Controls.ToggleHeliCam) then -- Toggle Helicam
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                        if manual_spotlight and target_vehicle then -- If exiting helicam while manual spotlight is locked on a target, transition to non-helicam auto tracking spotlight
                            TriggerServerEvent("pw_helicam:server:manualSpotlightToggle")
                            local target_netID = VehToNet(target_vehicle)
                            local target_plate = GetVehicleNumberPlateText(target_vehicle)
                            local targetposx, targetposy, targetposz = table.unpack(GetEntityCoords(target_vehicle))
                            pause_Tspotlight = false
                            tracking_spotlight = true
                            TriggerServerEvent("pw_helicam:server:trackingspotlight", target_netID, target_plate, targetposx, targetposy, targetposz)
                            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                        end
                        manual_spotlight = false
                        helicam = false
                    end

                    if IsControlJustPressed(0, Config.Controls.ToggleVision) then
                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                        ChangeVision()
                    end

                    if IsControlJustPressed(0, Config.Controls.ToggleSpotLight) then -- Spotlight_toggles within helicam
                        if tracking_spotlight then -- If tracking spotlight active, pause it & toggle manual spotlight
                            pause_Tspotlight = true
                            TriggerServerEvent("pw_helicam:server:pauseTrackingSpotlight", pause_Tspotlight)
                            manual_spotlight = not manual_spotlight
                            if manual_spotlight then
                                local rotation = GetCamRot(cam, 2)
                                local forward_vector = RotAnglesToVec(rotation)
                                local SpotvectorX, SpotvectorY, SpotvectorZ = table.unpack(forward_vector)
                                DecorSetInt(GLOBAL_PED, "SpotvectorX", SpotvectorX)
                                DecorSetInt(GLOBAL_PED, "SpotvectorY", SpotvectorY)
                                DecorSetInt(GLOBAL_PED, "SpotvectorZ", SpotvectorZ)
                                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                TriggerServerEvent("pw_helicam:server:manualSpotlight")
                            else
                                TriggerServerEvent("pw_helicam:server:manualSpotlightToggle")
                            end
                        elseif Fspotlight_state then -- If forward spotlight active, disable it & toggle manual spotlight
                            Fspotlight_state = false
                            TriggerServerEvent("pw_helicam:server:forwardspotlight", Fspotlight_state)
                            manual_spotlight = not manual_spotlight
                            if manual_spotlight then
                                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                TriggerServerEvent("pw_helicam:server:manualSpotlight")
                            else
                                TriggerServerEvent("pw_helicam:server:manualSpotlightToggle")
                            end
                        else -- If no other spotlight mode active, toggle manual spotlight
                            manual_spotlight = not manual_spotlight
                            if manual_spotlight then
                                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                TriggerServerEvent("pw_helicam:server:manualSpotlight")
                            else
                                TriggerServerEvent("pw_helicam:server:manualSpotlightToggle")
                            end
                        end
                    end

                    if IsControlJustPressed(0, Config.Controls.LightUp) then
                        TriggerServerEvent("pw_helicam:server:lightUp")
                    end

                    if IsControlJustPressed(0, Config.Controls.LightDown) then
                        TriggerServerEvent("pw_helicam:server:lightDown")
                    end

                    if IsControlJustPressed(0, Config.Controls.RadiusUp) then
                        TriggerServerEvent("pw_helicam:server:radiusUp")
                    end

                    if IsControlJustPressed(0, Config.Controls.RadiusDown) then
                        TriggerServerEvent("pw_helicam:server:radiusDown")
                    end

                    if locked_on_vehicle then
                        if DoesEntityExist(locked_on_vehicle) then
                            PointCamAtEntity(cam, locked_on_vehicle, 0.0, 0.0, 0.0, true)
                            RenderVehicleInfo(locked_on_vehicle)
                            local coords1 = GetEntityCoords(heli)
                            local coords2 = GetEntityCoords(locked_on_vehicle)
                            local target_distance = GetDistanceBetweenCoords(coords1.x, coords1.y, coords1.z, coords2.x, coords2.y, coords2.z, false)
                            if IsControlJustPressed(0, Config.Controls.ToggleLockOn) or target_distance > Config.TargetLockMaxDist then
                                --Citizen.Trace("Heli: locked_on_vehicle unlocked or lost")
                                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                DecorRemove(target_vehicle, "Target")
                                if tracking_spotlight then
                                    TriggerServerEvent("pw_helicam:server:trackingspotlightToggle")
                                    tracking_spotlight = false
                                end
                                target_vehicle = nil
                                locked_on_vehicle = nil
                                local rot = GetCamRot(cam, 2)
                                local fov = GetCamFov(cam)
                                local old cam = cam
                                DestroyCam(old_cam, false)
                                cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
                                AttachCamToEntity(cam, heli, 0.0,0.0,-1.5, true)
                                SetCamRot(cam, rot, 2)
                                SetCamFov(cam, fov)
                                RenderScriptCams(true, false, 0, 1, 0)
                            end
                        else
                            locked_on_vehicle = nil
                            target_vehicle = nil
                        end
                    else
                        local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
                        CheckInputRotation(cam, zoomvalue)
                        local vehicle_detected = GetVehicleInView(cam)
                        if DoesEntityExist(vehicle_detected) then
                            RenderVehicleInfo(vehicle_detected)
                            if IsControlJustPressed(0, Config.Controls.ToggleLockOn) then
                                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                locked_on_vehicle = vehicle_detected
                
                                if target_vehicle then 
                                    DecorRemove(target_vehicle, "Target")
                                end
                                
                                target_vehicle = vehicle_detected
                                NetworkRequestControlOfEntity(target_vehicle)
                                local target_netID = VehToNet(target_vehicle) 
                                SetNetworkIdCanMigrate(target_netID, true)
                                NetworkRegisterEntityAsNetworked(VehToNet(target_vehicle))
                                SetNetworkIdExistsOnAllMachines(target_vehicle, true) 
                                SetEntityAsMissionEntity(target_vehicle, true, true) 
                                target_plate = GetVehicleNumberPlateText(target_vehicle)
                                DecorSetInt(locked_on_vehicle, "Target", 2)

                                if tracking_spotlight then
                                    TriggerServerEvent("pw_helicam:server:trackingspotlightToggle")
                                    target_vehicle = locked_on_vehicle
                                    
                                    if not pause_Tspotlight then
                                        local target_netID = VehToNet(target_vehicle)
                                        local target_plate = GetVehicleNumberPlateText(target_vehicle)
                                        local targetposx, targetposy, targetposz = table.unpack(GetEntityCoords(target_vehicle))
                                        pause_Tspotlight = false
                                        tracking_spotlight = true
                                        TriggerServerEvent("heli:tracking.spotlight", target_netID, target_plate, targetposx, targetposy, targetposz)
                                        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
                                    else
                                        tracking_spotlight = false
                                        pause_Tspotlight = false
                                    end
                                end
                            end
                        end
                    end

                    HandleZoom(cam)
                    PushScaleformMovieFunction(scaleform, "SET_ALT_FOV_HEADING")
                    PushScaleformMovieFunctionParameterFloat(GetEntityCoords(heli).z)
                    PushScaleformMovieFunctionParameterFloat(zoomvalue)
                    PushScaleformMovieFunctionParameterFloat(GetCamRot(cam, 2).z)
                    PopScaleformMovieFunctionVoid()
                    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
                    Citizen.Wait(0)

                    if manual_spotlight then
                        local rotation = GetCamRot(cam, 2)
                        local forward_vector = RotAnglesToVec(rotation)
                        local SpotvectorX, SpotvectorY, SpotvectorZ = table.unpack(forward_vector)
                        local camcoords = GetCamCoord(cam)

                        DecorSetInt(GLOBAL_PED, "SpotvectorX", SpotvectorX)
                        DecorSetInt(GLOBAL_PED, "SpotvectorY", SpotvectorY)
                        DecorSetInt(GLOBAL_PED, "SpotvectorZ", SpotvectorZ)
                        DrawSpotLight(camcoords, forward_vector, 255, 255, 255, 800.0, 10.0, brightness, spotradius, 1.0, 1.0)
                    else
                        TriggerServerEvent("pw_helicam:server:manualSpotlightToggle")
                    end

                end
                if manual_spotlight then
                    manual_spotlight = false
                    TriggerServerEvent("pw_helicam:server:manualSpotlightToggle")
                end
                helicam = false
                ClearTimecycleModifier()
                fov = (fov_max+fov_min)*0.5 
                RenderScriptCams(false, false, 0, 1, 0)
                SetScaleformMovieAsNoLongerNeeded(scaleform)
                DestroyCam(cam, false)
                SetNightvision(false)
                SetSeethrough(false)
            end

            if IsPlayerInAllowedHeli() and target_vehicle and not helicam then
                RenderVehicleInfo(target_vehicle)
            end
        end
    end)
end

RegisterNetEvent('pw_helicam:client:forwardspotlight')
AddEventHandler('pw_helicam:client:forwardspotlight', function(serverID, state)
	local heli = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(serverID)), false)
	SetVehicleSearchlight(heli, state, false)
end)

RegisterNetEvent('pw_helicam:client:HeliSpotlight2')
AddEventHandler('pw_helicam:client:HeliSpotlight2', function(serverID, target_netID, target_plate, targetposx, targetposy, targetposz)
	if GetVehicleNumberPlateText(NetToVeh(target_netID)) == target_plate then
		Tspotlight_target = NetToVeh(target_netID)
	elseif GetVehicleNumberPlateText(DoesVehicleExistWithDecorator("Target")) == target_plate then
		Tspotlight_target = DoesVehicleExistWithDecorator("Target")
	elseif GetVehicleNumberPlateText(GetClosestVehicle(targetposx, targetposy, targetposz, 25.0, 0, 70)) == target_plate then
		Tspotlight_target = GetClosestVehicle(targetposx, targetposy, targetposz, 25.0, 0, 70)
	else 
		vehicle_match = FindVehicleByPlate(target_plate)
		if vehicle_match then
			Tspotlight_target = vehicle_match
		else 
			Tspotlight_target = nil
		end
	end

	local heli = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(serverID)), false)
	local heliPed = GetPlayerPed(GetPlayerFromServerId(serverID))
	Tspotlight_toggle = true
	Tspotlight_pause = false
	tracking_spotlight = true
	while not IsEntityDead(heliPed) and (GetVehiclePedIsIn(heliPed) == heli) and Tspotlight_target and Tspotlight_toggle do
		Citizen.Wait(1)
		local helicoords = GetEntityCoords(heli)
		local targetcoords = GetEntityCoords(Tspotlight_target)
		local spotVector = targetcoords - helicoords
		local target_distance = Vdist(targetcoords, helicoords)
		if Tspotlight_target and Tspotlight_toggle and not Tspotlight_pause then 
			DrawSpotLight(helicoords['x'], helicoords['y'], helicoords['z'], spotVector['x'], spotVector['y'], spotVector['z'], 255, 255, 255, (target_distance+20), 10.0, brightness, 4.0, 1.0, 0.0)
		end
		if Tspotlight_target and Tspotlight_toggle and target_distance > Config.TargetLockMaxDist then
			DecorRemove(Tspotlight_target, "Target")			
			target_vehicle = nil
			tracking_spotlight = false
			TriggerServerEvent("pw_helicam:server:trackingspotlightToggle")
			Tspotlight_target = nil
			break
		end
	end
	Tspotlight_toggle = false
	Tspotlight_pause = false
	Tspotlight_target = nil
	tracking_spotlight = false
end)

RegisterNetEvent('pw_helicam:client:trackingSpotlightToggle')
AddEventHandler('pw_helicam:client:trackingSpotlightToggle', function(serverID)
	Tspotlight_toggle = false
	tracking_spotlight = false
end)

RegisterNetEvent('pw_helicam:client:pauseTrackingSpotlight')
AddEventHandler('pw_helicam:client:pauseTrackingSpotlight', function(serverID, pause_Tspotlight)
	if pause_Tspotlight then
		Tspotlight_pause = true
	else
		Tspotlight_pause = false
	end
end)

RegisterNetEvent('pw_helicam:client:HeliSpotlight')
AddEventHandler('pw_helicam:client:HeliSpotlight', function(serverID)
	if GetPlayerServerId(PlayerId()) ~= serverID then -- Skip event for the source, since heli pilot already sees a more responsive manual spotlight
		local heli = GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(serverID)), false)
		local heliPed = GetPlayerPed(GetPlayerFromServerId(serverID))
		Mspotlight_toggle = true
		while not IsEntityDead(heliPed) and (GetVehiclePedIsIn(heliPed) == heli) and Mspotlight_toggle do
			Citizen.Wait(0) 
			local helicoords = GetEntityCoords(heli)
			spotoffset = helicoords + vector3(0.0, 0.0, -1.5)
			SpotvectorX = DecorGetInt(heliPed, "SpotvectorX")
			SpotvectorY = DecorGetInt(heliPed, "SpotvectorY")
			SpotvectorZ = DecorGetInt(heliPed, "SpotvectorZ")
			if SpotvectorX then
				DrawSpotLight(spotoffset['x'], spotoffset['y'], spotoffset['z'], SpotvectorX, SpotvectorY, SpotvectorZ, 255, 255, 255, 800.0, 10.0, brightness, spotradius, 1.0, 1.0)
			end
		end
		Mspotlight_toggle = false
		DecorSetInt(heliPed, "SpotvectorX", nil)
		DecorSetInt(heliPed, "SpotvectorY", nil)
		DecorSetInt(heliPed, "SpotvectorZ", nil)
	end
end)

RegisterNetEvent('pw_helicam:client:HeliSpotlightToggle')
AddEventHandler('pw_helicam:client:HeliSpotlightToggle', function(serverID)
	Mspotlight_toggle = false
end)

RegisterNetEvent('pw_helicam:client:lightUp')
AddEventHandler('pw_helicam:client:lightUp', function(serverID)
	if brightness < 10 then
		brightness = brightness + 1.0
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
	end
end)

RegisterNetEvent('pw_helicam:client:lightDown')
AddEventHandler('pw_helicam:client:lightDown', function(serverID)
	if brightness > 1.0 then
		brightness = brightness - 1.0
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
	end
end)

RegisterNetEvent('pw_helicam:client:radiusUp')
AddEventHandler('pw_helicam:client:radiusUp', function(serverID)
	if spotradius < 10.0 then
		spotradius = spotradius + 1.0
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
	end
end)

RegisterNetEvent('pw_helicam:client:radiusDown')
AddEventHandler('pw_helicam:client:radiusDown', function(serverID)
	if spotradius > 4.0 then
		spotradius = spotradius - 1.0
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
	end
end)

function IsPlayerInAllowedHeli()
    local vehicle = GetVehiclePedIsIn(GLOBAL_PED)
    for i=1, #Config.AllowedHelis do
        if IsVehicleModel(vehicle, Config.AllowedHelis[i]) then
            return true
        end
    end
    return false
end

function IsHeliHighEnough(heli)
	return GetEntityHeightAboveGround(heli) > 1.5
end

function ChangeVision()
	if vision_state == 0 then
		SetNightvision(true)
		vision_state = 1
	elseif vision_state == 1 then
		SetNightvision(false)
		SetSeethrough(true)
		vision_state = 2
	else
		SetSeethrough(false)
		vision_state = 0
	end
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5) -- Clamping at top (cant see top of heli) and at bottom (doesn't glitch out in -90deg)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	if IsControlJustPressed(0,241) then -- Scrollup
		fov = math.max(fov - zoomspeed, fov_min)
	end
	if IsControlJustPressed(0,242) then
		fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown		
	end
	local current_fov = GetCamFov(cam)
	if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
		fov = current_fov
	end
	SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
end

function GetVehicleInView(cam)
	local coords = GetCamCoord(cam)
	local forward_vector = RotAnglesToVec(GetCamRot(cam, 2))
	--DrawLine(coords, coords+(forward_vector*100.0), 255,0,0,255) -- debug line to show LOS of cam
	local rayhandle = CastRayPointToPoint(coords, coords+(forward_vector*200.0), 10, GetVehiclePedIsIn(GLOBAL_PED), 0)
	local _, _, _, _, entityHit = GetRaycastResult(rayhandle)
	if entityHit>0 and IsEntityAVehicle(entityHit) then
		return entityHit
	else
		return nil
	end
end

function RenderVehicleInfo(vehicle)
	if DoesEntityExist(vehicle) then
		local model = GetEntityModel(vehicle)
		local vehname = GetLabelText(GetDisplayNameFromVehicleModel(model))
		local licenseplate = GetVehicleNumberPlateText(vehicle)
		vehspeed = GetEntitySpeed(vehicle)*2.236936
		SetTextFont(0)
		SetTextProportional(1)
		SetTextScale(0.0, 0.49)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(0, 0, 0, 0, 255)
		SetTextEdge(1, 0, 0, 0, 255)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		AddTextComponentString("Speed: " .. math.ceil(vehspeed) .. " MPH\nModel: " .. vehname .. "\nPlate: " .. licenseplate)
		DrawText(0.45, 0.9)
	end
end

function RotAnglesToVec(rot)
	local z = math.rad(rot.z)
	local x = math.rad(rot.x)
	local num = math.abs(math.cos(x))
	return vector3(-math.sin(z)*num, math.cos(z)*num, math.sin(x))
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
        disposeFunc(iter)
        return
        end
        
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
        
        local next = true
        repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
        until not next
        
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function FindVehicleByPlate(plate)
	for vehicle in EnumerateVehicles() do
		if GetVehicleNumberPlateText(vehicle) == plate then
			return vehicle
		end
	end
end