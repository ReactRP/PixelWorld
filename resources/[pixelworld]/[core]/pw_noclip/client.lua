local playerLoaded, playerData = false, nil
noclipActive = false -- [[Wouldn't touch this.]]
noClipIndex = 1 -- [[Used to determine the index of the speeds table.]]
noclipEntity = nil

config = {
	controls = {
		-- [[Controls, list can be found here : https://docs.fivem.net/game-references/controls/]]
		openKey = 288, -- [[F2]]
		goUp = 85, -- [[Q]]
		goDown = 48, -- [[Z]]
		turnLeft = 34, -- [[A]]
		turnRight = 35, -- [[D]]
		goForward = 32,  -- [[W]]
		goBackward = 33, -- [[S]]
		changeSpeed = 21, -- [[L-Shift]]
	},

speeds = {
		-- [[If you wish to change the speeds or labels there are associated with then here is the place.]]
		{ label = "Very Slow", speed = 0},
		{ label = "Slow", speed = 0.5},
		{ label = "Normal", speed = 2},
		{ label = "Fast", speed = 4},
		{ label = "Very Fast", speed = 6},
		{ label = "Extremely Fast", speed = 10},
		{ label = "Extremely Fast v2.0", speed = 20},
		{ label = "Max Speed", speed = 25}
	},

offsets = {
		y = 0.5, -- [[How much distance you move forward and backward while the respective button is pressed]]
		z = 0.2, -- [[How much distance you move upward and downward while the respective button is pressed]]
		h = 3, -- [[How much you rotate. ]]
	},

	-- [[Background colour of the buttons. (It may be the standard black on first opening, just re-opening.)]]
	bgR = 0, -- [[Red]]
	bgG = 0, -- [[Green]]
	bgB = 0, -- [[Blue]]
	bgA = 80, -- [[Alpha]]
}

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            playerLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        playerLoaded = false
    end
end)

RegisterNetEvent("pw_core:noclip")
AddEventHandler("pw_core:noclip", function(t)
	noclipActive = not noclipActive
	msg = "Disabled"
	if noclipActive then
		msg = "Enabled"
	end
	
	if IsPedInAnyVehicle(PlayerPedId(), false) then
		noclipEntity = GetVehiclePedIsIn(PlayerPedId(), false)
	else
		noclipEntity = PlayerPedId()
	end

	SetEntityCollision(noclipEntity, not noclipActive, not noclipActive)
	FreezeEntityPosition(noclipEntity, noclipActive)
	SetEntityInvincible(noclipEntity, noclipActive)
	SetVehicleRadioEnabled(noclipEntity, not noclipActive) -- [[Stop radio from appearing when going upwards.]]

    exports.pw_notify:SendAlert('inform', 'NoClip has been: '..msg)
    buttons = setupScaleform("instructional_buttons")
    currentSpeed = config.speeds[noClipIndex].speed
    TriggerEvent('pw_noclip:startNoClipping')
end)

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)

    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, config.controls.goUp, true))
    ButtonMessage("Go Up")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, config.controls.goDown, true))
    ButtonMessage("Go Down")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(1, config.controls.turnRight, true))
    Button(GetControlInstructionalButton(1, config.controls.turnLeft, true))
    ButtonMessage("Turn Left/Right")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(1, config.controls.goBackward, true))
    Button(GetControlInstructionalButton(1, config.controls.goForward, true))
    ButtonMessage("Go Forwards/Backwards")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, config.controls.changeSpeed, true))
    ButtonMessage("Change Speed ("..config.speeds[noClipIndex].label..")")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(config.bgR)
    PushScaleformMovieFunctionParameterInt(config.bgG)
    PushScaleformMovieFunctionParameterInt(config.bgB)
    PushScaleformMovieFunctionParameterInt(config.bgA)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

RegisterNetEvent('pw_noclip:startNoClipping')
AddEventHandler('pw_noclip:startNoClipping', function()
    while noclipActive and playerLoaded do
        Citizen.Wait(1)
            DrawScaleformMovieFullscreen(buttons)

            local yoff = 0.0
            local zoff = 0.0

            if IsControlJustPressed(1, config.controls.changeSpeed) then
                if noClipIndex ~= 8 then
                    noClipIndex = noClipIndex+1
                    currentSpeed = config.speeds[noClipIndex].speed
                else
                    currentSpeed = config.speeds[1].speed
                    noClipIndex = 1
                end
                setupScaleform("instructional_buttons")
            end

            if IsControlPressed(0, config.controls.goForward) then
                yoff = config.offsets.y
            end
            
            if IsControlPressed(0, config.controls.goBackward) then
                yoff = -config.offsets.y
            end
            
            if IsControlPressed(0, config.controls.turnLeft) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity)+config.offsets.h)
            end
            
            if IsControlPressed(0, config.controls.turnRight) then
                SetEntityHeading(noclipEntity, GetEntityHeading(noclipEntity)-config.offsets.h)
            end
            
            if IsControlPressed(0, config.controls.goUp) then
                zoff = config.offsets.z
            end
            
            if IsControlPressed(0, config.controls.goDown) then
                zoff = -config.offsets.z
            end
            
            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
            local heading = GetEntityHeading(noclipEntity)
            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, heading)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, noclipActive, noclipActive, noclipActive)
    end
end)

