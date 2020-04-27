PW = nil
characterLoaded, playerData = false, nil
local playerServerId = GetPlayerServerId(PlayerId())

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
			playerData = data
			GLOBAL_ISDEAD = false
			characterLoaded = true
			StartUIUpdates()
        else
            playerData = data
        end
    else
        characterLoaded = false
		playerData = nil
		PowerOffRadio(true)
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

RegisterNetEvent('pw:playerRevived')
AddEventHandler('pw:playerRevived', function()
	GLOBAL_ISDEAD = false
end)

RegisterNetEvent('pw:playerDied')
AddEventHandler('pw:playerDied', function()
    GLOBAL_ISDEAD = true
end)

-- Functions
function SetVoiceData(key, value)
	TriggerServerEvent("pw_voip:server:SetMumbleVoiceData", key, value)
end

-- Events
RegisterNetEvent("pw_voip:client:SetMumbleVoiceData")
AddEventHandler("pw_voip:client:SetMumbleVoiceData", function(voice, radio, call)
	voiceData = voice

	if radio then
		radioData = radio
	end

	if call then
		callData = call
	end
end)

RegisterNetEvent("pw_voip:client:RadioSound")
AddEventHandler("pw_voip:client:RadioSound", function(snd, channel)
	if channel <= mumbleConfig.radioClickMaxChannel then
		if mumbleConfig.micClicks then
			if (snd and mumbleConfig.micClickOn) or (not snd and mumbleConfig.micClickOff) then
				SendNUIMessage({ action = 'playSound', soundFile = (snd and "mic_click_on" or "mic_click_off"), soundVolume   = mumbleConfig.micClickVolume })
			end
		end
	end
end)

AddEventHandler("onClientResourceStart", function (resName)
	if GetCurrentResourceName() ~= resName then
		return
	end

	TriggerServerEvent("pw_voip:server:InitialiseMumble")
	DebugMsg("Initialising")
end)

-- Simulate PTT when radio is active
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerDataMumble = voiceData[playerServerId]
		local playerMode = 2
		local playerRadio = 0
		local playerRadioActive = false
		local playerCall = 0
		local playerCallSpeaker = false

		if playerDataMumble ~= nil then
			playerMode = playerDataMumble.mode or 2
			playerRadio = playerDataMumble.radio or 0
			playerRadioActive = playerDataMumble.radioActive or false
			playerCall = playerDataMumble.call or 0
			playerCallSpeaker = playerDataMumble.callSpeaker or false
		end

		if playerRadioActive then -- Force PTT enabled
			SetControlNormal(0, 249, 1.0)
			SetControlNormal(1, 249, 1.0)
			SetControlNormal(2, 249, 1.0)
		end

		if IsControlPressed(0, 21) and IsControlJustPressed(0, mumbleConfig.controls.proximity.key) then -- Shift+X
			print('switching?')
			if mumbleConfig.controls.speaker.key == mumbleConfig.controls.proximity.key and not ((mumbleConfig.controls.speaker.secondary == nil) and true or IsControlPressed(0, mumbleConfig.controls.speaker.secondary)) then
				local voiceMode = playerMode
			
				local newMode = voiceMode + 1
			
				if newMode > #mumbleConfig.voiceModes then
					voiceMode = 1
				else
					voiceMode = newMode
				end
			
				SetVoiceData("mode", voiceMode)
			end
		end

		if mumbleConfig.radioEnabled then
			if not mumbleConfig.controls.radio.pressed then
				if IsControlJustPressed(0, mumbleConfig.controls.radio.key) then
					if not GLOBAL_ISDEAD then
						if playerRadio > 0 then
							SetVoiceData("radioActive", true)
							playerDataMumble.radioActive = true
							mumbleConfig.controls.radio.pressed = true

							Citizen.CreateThread(function()
								while IsControlPressed(0, mumbleConfig.controls.radio.key) do
									Citizen.Wait(0)
								end

								SetVoiceData("radioActive", false)
								playerDataMumble.radioActive = false
								mumbleConfig.controls.radio.pressed = false
							end)
						end
					end
				end
			end
		else
			if playerRadioActive then
				SetVoiceData("radioActive", false)
				playerDataMumble.radioActive = false
			end
		end

		if mumbleConfig.radioSpeakerEnabled then
			if ((mumbleConfig.controls.speaker.secondary == nil) and true or IsControlPressed(0, mumbleConfig.controls.speaker.secondary)) then
				if IsControlJustPressed(0, mumbleConfig.controls.speaker.key) then
					if playerCall > 0 then
						SetVoiceData("callSpeaker", not playerCallSpeaker)
					end
				end
			end
		end
	end
end)

-- UI
function StartUIUpdates()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(600)
			if characterLoaded then
				local playerId = PlayerId()
				local playerDataMumble = voiceData[playerServerId]
				local playerTalking = NetworkIsPlayerTalking(playerId)
				local playerMode = 2
				local playerRadio = 0
				local playerRadioActive = false
				local playerCall = 0
				local playerCallSpeaker = false
				if playerDataMumble ~= nil then
					playerMode = playerDataMumble.mode or 2
					playerRadio = playerDataMumble.radio or 0
					playerRadioActive = playerDataMumble.radioActive or false
					playerCall = playerDataMumble.call or 0
					playerCallSpeaker = playerDataMumble.callSpeaker or false
				end
				local info = ""
				if (playerMode == 1) then -- Whispering
					TriggerEvent('pw_hud:client:updateVoiceLevel', 25)
				elseif (playerMode == 2) then -- Normal
					TriggerEvent('pw_hud:client:updateVoiceLevel', 50)
				elseif (playerMode == 3) then -- Shouting
					TriggerEvent('pw_hud:client:updateVoiceLevel', 100)
				end

				
				if playerRadio == 0 and playerCall == 0 then
					info = "<i class=\"fad fa-microphone fa-fw\"></i>"
				else
					if playerRadio ~= 0 then
						info = "<i class=\"fad fa-walkie-talkie fa-fw\"></i>"
					end
					if playerCall ~= 0 then
						if playerCallSpeaker then
							info = "<i class=\"fad fa-phone-plus fa-fw\"></i>"
						else
							info = "<i class=\"fad fa-phone fa-fw\"></i>"
						end
					end
				end

				if (playerTalking == 1 or playerRadioActive) then
					info = "<font class=".. (playerRadioActive and 'text-danger' or 'text-warning') .. ">" .. info .. "</font>"
				end

				TriggerEvent('pw_hud:client:updateTalking', info)
			else
				break
			end
		end
	end)
end

-- Main thread
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)

		local playerId = PlayerId()
		local playerPos = GetPedBoneCoords(GLOBAL_PED, headBone)
		local playerList = GetActivePlayers()
		local playerDataMumble = voiceData[playerServerId]
		local playerMode = 2
		local playerRadio = 0
		local playerCall = 0

		if playerDataMumble ~= nil then
			playerMode = playerDataMumble.mode or 2
			playerRadio = playerDataMumble.radio or 0
			playerCall = playerDataMumble.call or 0
		end

		local voiceList = {}
		local muteList = {}
		local callList = {}
		local radioList = {}

		-- Check if a player is close to the source voice mode distance, if close send voice

		for i = 1, #playerList do -- Proximity based voice (probably won't work for infinity?)
			local remotePlayerId = playerList[i]

			if playerId ~= remotePlayerId then
				local remotePlayerServerId = GetPlayerServerId(remotePlayerId)
				local remotePlayerPed = GetPlayerPed(remotePlayerId)
				local remotePlayerPos = GetPedBoneCoords(remotePlayerPed, headBone)
				local remotePlayerData = voiceData[remotePlayerServerId]

				local distance = #(playerPos - remotePlayerPos)
				local mode = 2
				local radio = 0
				local radioActive = false
				local call = 0
				local callSpeaker = false

				if remotePlayerData ~= nil then
					mode = remotePlayerData.mode or 2
					radio = remotePlayerData.radio or 0
					radioActive = remotePlayerData.radioActive or false
					call = remotePlayerData.call or 0
					callSpeaker = remotePlayerData.callSpeaker or false
				end

				local inRange = false

				if mumbleConfig.use3dAudio then
					inRange = distance < mumbleConfig.voiceModes[playerMode][1]
				else
					inRange = distance < mumbleConfig.voiceModes[mode][1]
				end
				-- Check if player is in range
				if inRange then
					local idx = #voiceList + 1
					voiceList[idx] = {
						id = remotePlayerServerId,
						player = remotePlayerId,
					}
					if not mumbleConfig.use3dAudio then
						local volume = 1.0 - (distance / mumbleConfig.voiceModes[mode][1])^0.5
						if volume < 0 then
							volume = 0.0
						end
						voiceList[idx].volume = volume
					end
					if distance < mumbleConfig.speakerRange then
						local volume = 1.0 - (distance / mumbleConfig.speakerRange)^0.5
						if mumbleConfig.callSpeakerEnabled then
							if call > 0 then -- Collect all players in the phone call
								if callSpeaker then
									local callParticipants = callData[call]
									if callParticipants ~= nil then
										for id, _ in pairs(callParticipants) do
											if id ~= remotePlayerServerId then
												callList[id] = volume
											end
										end
									end
								end
							end
						end
						
						if mumbleConfig.radioSpeakerEnabled then
							if radio > 0 then -- Collect all players in the radio channel
								local radioParticipants = radioData[radio]
								if radioParticipants then
									for id, _ in pairs(radioParticipants) do
										if id ~= remotePlayerServerId then
											radioList[id] = volume
										end
									end
								end
							end
						end
					end
				else
					muteList[#muteList + 1] = {
						id = remotePlayerServerId,
						player = remotePlayerId,
						volume = mumbleConfig.use3dAudio and -1.0 or 0.0,
						radio = radio,
						radioActive = radioActive,
						distance = distance,
						call = call,
					}					
				end
			end
		end

		if mumbleConfig.use3dAudio then
			MumbleClearVoiceTarget(0)
			for j = 1, #voiceList do
				MumbleSetVolumeOverride(voiceList[j].player, -1.0) -- Re-enable 3d audio
				MumbleAddVoiceTargetPlayer(2, voiceList[j].player) -- Broadcast voice to player if they are in my voice range
			end
			MumbleSetVoiceTarget(0)
		else
			for j = 1, #voiceList do
				MumbleSetVolumeOverride(voiceList[j].player, voiceList[j].volume)
			end
		end
		
		for j = 1, #muteList do
			if callList[muteList[j].id] ~= nil then
				if callList[muteList[j].id] > muteList[j].volume then
					muteList[j].volume = callList[muteList[j].id]
				end
			end
			if radioList[muteList[j].id] ~= nil then
				if radioList[muteList[j].id] > muteList[j].volume then
					muteList[j].volume = radioList[muteList[j].id]
				end
			end
			if muteList[j].radio > 0 and muteList[j].radio == playerRadio and muteList[j].radioActive then
				muteList[j].volume = 1.0
			end
			if muteList[j].call > 0 and muteList[j].call == playerCall then
				muteList[j].volume = 1.2
			end
			MumbleSetVolumeOverride(muteList[j].player, muteList[j].volume) -- Set player volume
		end
	end
end)

-- Exports and Additional Functions
function SetRadioChannel(channel)
	local channel = tonumber(channel)

	if channel ~= nil then
		if channel > 0 then
			TriggerEvent('pw_hud:client:updateRadioChannel', true, (mumbleConfig.radioChannelNames[channel] ~= nil and mumbleConfig.radioChannelNames[channel] or channel.."MHz"))
		else	
			TriggerEvent('pw_hud:client:updateRadioChannel', false)
		end
		SetVoiceData("radio", channel)
	end
end

function RemovePlayerFromRadio()
	SetRadioChannel(0)
	TriggerEvent('pw_hud:client:updateRadioChannel', false)
end

function SetCallChannel(channel)
	local channel = tonumber(channel)

	if channel ~= nil then
		SetVoiceData("call", channel)
	end
end

function RemovePlayerFromCall()
	SetCallChannel(0)
end

exports("SetRadioChannel", SetRadioChannel)
exports("addPlayerToRadio", SetRadioChannel)
exports("removePlayerFromRadio", RemovePlayerFromRadio)

exports("SetCallChannel", SetCallChannel)
exports("addPlayerToCall", SetCallChannel)
exports("removePlayerFromCall", RemovePlayerFromCall)

local disablingKeys = false


RegisterNetEvent('pw_voip:client:onlyAllowPTTOn')
AddEventHandler('pw_voip:client:onlyAllowPTTOn', function()
	SetNuiFocusKeepInput(true)
	disablingKeys = true
	while disablingKeys do
		Citizen.Wait(1)
        DisableAllControlActions(0)
        DisableControlAction(0, 2, true)  -- Disable Camera
        DisableControlAction(0, 1, true)  -- Disable Camera
		EnableControlAction(0, 249, true) -- Push to Talk
		EnableControlAction(0, 217, true) -- Change Voice Range
		EnableControlAction(0, 137, true) -- Push to Talk Radio
	end
end)

RegisterNetEvent('pw_voip:client:onlyAllowPTTOff')
AddEventHandler('pw_voip:client:onlyAllowPTTOff', function()
	SetNuiFocusKeepInput(false)
	disablingKeys = false
end)