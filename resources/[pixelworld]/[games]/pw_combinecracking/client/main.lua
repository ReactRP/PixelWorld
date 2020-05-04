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

RegisterNetEvent("safecracking:start")
AddEventHandler("safecracking:start", function()
	TriggerEvent("safecracking:loop",10,"safe:success")
end)

local cracking, pinfall, openString, closedString, sendResponse = false, false, "lock_open", "lock_closed", {}

RegisterNetEvent("pw_combinecracking:startGame")
AddEventHandler("pw_combinecracking:startGame", function(difficulty, func)
	startLoadSafeTexture()
    startLoadSafeAudio()
    if difficulty > 11 then difficulty = 10 end
    if difficulty < 1 then difficulty = 1 end
	local difficultySetting = {}
	for z = 1, difficulty do
		difficultySetting[z] = 1
    end
    sendResponse = func
	local factor = difficulty
    local lockRot = 0.0
    local lockInf = 1
	local safeLock = 0
	local randomCrackTarget = math.ceil(math.random(1, 99))
    local curLock = 1
    local crackingPos = GLOBAL_COORDS
    cracking = true
    pinfall = false

    exports.pw_notify:PersistentAlert('start', 'combine_safe_cracking_intruc', 'inform', 'Attempting to Crack Combination Safe<br>Use the <span style="color:#ffff00">Arrow Keys</span> to Rotate<br>Use the <span style="color:#ffff00">E Key</span> to Confirm')
	while cracking do
		DisableControlAction(38, 0, true) -- E
		DisableControlAction(44, 0, true) -- Q (Cover)
        DisableControlAction(174, 0, true) -- Left Arrow
        DisableControlAction(175, 0, true) -- Right Arrow

		if IsDisabledControlPressed(1, 174) then -- Turn it LEFT
			if lockInf > 1 then
				lockRot = lockRot + 1.8
				PlaySoundFrontend(0, "TUMBLER_TURN", "SAFE_CRACK_SOUNDSET", true)
				lockInf = 0
				doSafeCrackingAnim(1)
			end
		end

		if IsDisabledControlPressed(1, 175) then -- Turn it RIGHT
			if lockInf > 1 then
				lockRot = lockRot - 1.8
                PlaySoundFrontend(0, "TUMBLER_TURN", "SAFE_CRACK_SOUNDSET", true)
				lockInf = 0
				doSafeCrackingAnim(1)
			end
		end

		lockInf = lockInf + 0.2
        Citizen.Wait(1)
        
		if lockRot < 0.0 then lockRot = 360.0 end
        if lockRot > 360.0 then lockRot = 0.0 end
        
		safeLock = math.floor(100-(lockRot / 3.6))

		if #(crackingPos - GLOBAL_COORDS) > 1 or curLock > difficulty then
			cracking = false
        end
        
		if IsDisabledControlPressed(1, 38) and safeLock ~= randomCrackTarget then
			Citizen.Wait(1000)
        end
        
		if safeLock == randomCrackTarget then
			if not pinfall then
				PlaySoundFrontend(0, "TUMBLER_PIN_FALL", "SAFE_CRACK_SOUNDSET", true)
				pinfall = true
			end
			if IsDisabledControlPressed(1, 38) then
				pinfall = false
				PlaySoundFrontend(0, "TUMBLER_RESET", "SAFE_CRACK_SOUNDSET", true)
				factor = factor / 2
				lockRot = 0.0
				safeLock = 0
				randomCrackTarget = math.ceil(math.random(1, 99))
				doSafeCrackingAnim(3)
				difficultySetting[curLock] = 0
				curLock = curLock + 1
			end
		else
			pinfall = false
		end

		DrawSprite("MPSafeCracking", "Dial_BG", 0.65, 0.5, 0.18, 0.32, 0, 255, 255, 211, 255 )
        DrawSprite("MPSafeCracking", "Dial", 0.65, 0.5, 0.09, 0.16, lockRot, 255, 255, 211, 255 )
		addition = 0.45
		xaddition = 0.58
		for x = 1, difficulty do
			if difficultySetting[x] ~= 1 then
				DrawSprite("MPSafeCracking", openString, xaddition, addition, 0.012, 0.024, 0, 255, 255, 211, 255)
			else
				DrawSprite("MPSafeCracking", closedString, xaddition, addition, 0.012, 0.024, 0, 255, 255, 211, 255)
			end
			addition = addition + 0.05
			if x == 10 or x == 20 or x == 30 then
				addition = 0.25
				xaddition = xaddition + 0.05
			end
		end
    end
    
	if curLock > difficulty then
        sendResponse(true)
    else
        sendResponse(false)
    end
    exports.pw_notify:PersistentAlert('end', 'combine_safe_cracking_intruc')
	ClearPedSecondaryTask(GLOBAL_PED)
end)

local anims = {
    [1] = "dial_turn_anti_fast_1",
    [2] = "idle_base",
    [3] = "dial_turn_succeed_4"
}

function doSafeCrackingAnim(animType)
    if characterLoaded and not IsPedFatallyInjured(GLOBAL_PED) then 
        while not HasAnimDictLoaded("mini@safe_cracking") do
            RequestAnimDict("mini@safe_cracking")
            Citizen.Wait(5)
        end

        if animType == 1 then
            if not IsEntityPlayingAnim(GLOBAL_PED, "mini@safe_cracking", "dial_turn_anti_fast_1", 3) then
                TaskPlayAnim(GLOBAL_PED, "mini@safe_cracking", "dial_turn_anti_fast_1", 8.0, -8, -1, 49, 0, 0, 0, 0)
            end	
        end
        if animType == 2 or animType == 3 then
            TaskPlayAnim(GLOBAL_PED, "mini@safe_cracking", anims[animType], 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
        end
    end
end

function startLoadSafeTexture()
	RequestStreamedTextureDict("MPSafeCracking", false)
	while not HasStreamedTextureDictLoaded("MPSafeCracking") do
		Citizen.Wait(0)
	end
end

function startLoadSafeAudio()
	RequestAmbientAudioBank("SAFE_CRACK", false)
end
