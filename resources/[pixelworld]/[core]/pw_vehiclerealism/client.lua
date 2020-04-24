PW = nil
-- Vehicles to enable/disable air control
local vehRoadDensity = 0.65
local vehParkedDensity = 0.8
local playerLoaded = false

local vehicleClassDisableControl = {
    [0] = true,     --compacts
    [1] = true,     --sedans
    [2] = true,     --SUV's
    [3] = true,     --coupes
    [4] = true,     --muscle
    [5] = true,     --sport classic
    [6] = true,     --sport
    [7] = true,     --super
    [8] = false,    --motorcycle
    [9] = true,     --offroad
    [10] = true,    --industrial
    [11] = true,    --utility
    [12] = true,    --vans
    [13] = false,   --bicycles
    [14] = false,   --boats
    [15] = false,   --helicopter
    [16] = false,   --plane
    [17] = true,    --service
    [18] = true,    --emergency
    [19] = false    --military
}

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
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        playerLoaded = false
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
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

-- Main thread
Citizen.CreateThread(function()
    while true do
        -- Loop forever and update every frame
        Citizen.Wait(1)

        if playerLoaded then 
            local vehicle = GetVehiclePedIsIn(GLOBAL_PED, false)
            local vehicleClass = GetVehicleClass(vehicle)

            SetVehicleDensityMultiplierThisFrame(vehRoadDensity)
            SetParkedVehicleDensityMultiplierThisFrame(vehParkedDensity)
            
            -- Disable control if player is in the driver seat and vehicle class matches array
            if ((GetPedInVehicleSeat(vehicle, -1) == GLOBAL_PED) and vehicleClassDisableControl[vehicleClass]) then
                -- Check if vehicle is in the air and disable L/R and UP/DN controls
                if IsEntityInAir(vehicle) then
                    DisableControlAction(2, 59)
                    DisableControlAction(2, 60)
                end
            end
            if IsPedInAnyVehicle(GLOBAL_PED) then
                SmoothDriving()
            end
        end
    end
end)

local pedInSameVehicleLast, vehicle, lastVehicle, vehicleClass, fBrakeForce, isBrakingForward, isBrakingReverse = false, nil, nil, nil, 1.0, false, false

function IsPedDrivingCar()
    if IsPedInAnyVehicle(GLOBAL_PED, false) then
        vehicle = GetVehiclePedIsIn(GLOBAL_PED, false)
		-- Check if ped is in driver seat
		if GetPedInVehicleSeat(vehicle, -1) == GLOBAL_PED then
			local class = GetVehicleClass(vehicle)
			if class ~= 15 and class ~= 16 and class ~= 21 and class ~= 13 and class ~= 14 then -- don't want planes, helicopters, bicycles and trains
				return true
			end
		end
	end
	return false
end

function fscale(inputValue, originalMin, originalMax, newBegin, newEnd, curve)
    local OriginalRange, NewRange, zeroRefCurVal, normalizedCurVal, rangedValue, invFlag = 0.0, 0.0, 0.0, 0.0, 0.0, 0

    if (curve > 10.0) then curve = 10.0 end
    
    if (curve < -10.0) then curve = -10.0 end
    
	curve = (curve * -.1)
	curve = 10.0 ^ curve
	if (inputValue < originalMin) then
		inputValue = originalMin
    end
    
	if inputValue > originalMax then
	    inputValue = originalMax
    end
    
	OriginalRange = originalMax - originalMin
	if (newEnd > newBegin) then
		NewRange = newEnd - newBegin
	else
	    NewRange = newBegin - newEnd
	    invFlag = 1
	end
	zeroRefCurVal = inputValue - originalMin
    normalizedCurVal  =  zeroRefCurVal / OriginalRange
    
	if (originalMin > originalMax ) then
	    return 0
    end
    
	if (invFlag == 0) then
		rangedValue =  ((normalizedCurVal ^ curve) * NewRange) + newBegin
	else
		rangedValue =  newBegin - ((normalizedCurVal ^ curve) * NewRange)
	end
	return rangedValue
end

function SmoothDriving()
	if pedInSameVehicleLast then
		local torqueFactor = 1.0
		local accelerator = GetControlValue(2, 71)
		local brake = GetControlValue(2, 72)
		local speedVector = GetEntitySpeedVector(vehicle, true)['y']
		local brk = fBrakeForce
		if speedVector >= 1.0 then
			-- Going forward
			if accelerator > 127 then
				-- Forward and accelerating
				local acc = fscale(accelerator, 127.0, 254.0, 0.1, 1.0, 10.0-(15.0))
				torqueFactor = torqueFactor * acc
			end
			if brake > 127 then
				-- Forward and braking
				isBrakingForward = true
				brk = fscale(brake, 127.0, 254.0, 0.01, fBrakeForce, 10.0-(10.0))
			end
		elseif speedVector <= -1.0 then
			-- Going reverse
			if brake > 127 then
				-- Reversing and accelerating (using the brake)
				local rev = fscale(brake, 127.0, 254.0, 0.1, 1.0, 10.0-(15.0))
				torqueFactor = torqueFactor * rev
			end
			if accelerator > 127 then
				-- Reversing and braking (Using the accelerator)
				isBrakingReverse = true
				brk = fscale(accelerator, 127.0, 254.0, 0.01, fBrakeForce, 10.0-(10.0))
			end
		else
			-- Stopped or almost stopped or sliding sideways
			local entitySpeed = GetEntitySpeed(vehicle)
			if entitySpeed < 1 then
				-- Not sliding sideways
				if isBrakingForward then
					--Stopped or going slightly forward while braking
					DisableControlAction(2, 72, true) -- Disable Brake until user lets go of brake
					SetVehicleForwardSpeed(vehicle, speedVector*0.98)
					SetVehicleBrakeLights(vehicle,true)
				end
				if isBrakingReverse then
					--Stopped or going slightly in reverse while braking
					DisableControlAction(2, 71, true) -- Disable reverse Brake until user lets go of reverse brake (Accelerator)
					SetVehicleForwardSpeed(vehicle, speedVector*0.98)
					SetVehicleBrakeLights(vehicle, true)
				end
				if isBrakingForward and GetDisabledControlNormal(2, 72) == 0 then
					-- We let go of the brake
					isBrakingForward = false
				end
				if isBrakingReverse and GetDisabledControlNormal(2, 71) == 0 then
					-- We let go of the reverse brake (Accelerator)
					isBrakingReverse = false
				end
			end
		end
		if brk > fBrakeForce - 0.02 then brk = fBrakeForce end -- Make sure we can brake max.
		SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce', brk)  -- Set new Brake Force multiplier
		SetVehicleEngineTorqueMultiplier(vehicle, torqueFactor)
	end
end


Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1500)
        if playerLoaded then
            if IsPedDrivingCar() then
                vehicle = GetVehiclePedIsIn(GLOBAL_PED, false)
                if vehicle ~= lastVehicle then
                    pedInSameVehicleLast = false
                end

                if not pedInSameVehicleLast then
                    fBrakeForce = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce')
                    pedInSameVehicleLast = true
                end

                lastVehicle = vehicle
            else
                if pedInSameVehicleLast then
                    lastVehicle = GetVehiclePedIsIn(GLOBAL_PED, true)
                    SetVehicleHandlingFloat(lastVehicle, 'CHandlingData', 'fBrakeForce', fBrakeForce)  -- Restore Brake Force multiplier
                end
                pedInSameVehicleLast = false
            end
        end
	end
end)