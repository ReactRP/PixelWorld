RegisterServerEvent("pw_voip:server:InitialiseMumble")
AddEventHandler("pw_voip:server:InitialiseMumble", function()
    DebugMsg("Initialised player: " .. source)

    if not voiceData[source] then
        voiceData[source] = {
            mode = 2,
            radio = 0,
            radioActive = false,
            call = 0,
            callSpeaker = false,
        }
    end

    TriggerClientEvent("pw_voip:client:SetMumbleVoiceData", -1, voiceData, radioData, callData)
end)

RegisterServerEvent("pw_voip:server:SetMumbleVoiceData")
AddEventHandler("pw_voip:server:SetMumbleVoiceData", function(key, value)
    if not voiceData[source] then
        voiceData[source] = {
            mode = 2,
            radio = 0,
            radioActive = false,
            call = 0,
            callSpeaker = false,
        }
    end

    local radio = voiceData[source]["radio"]
    local call = voiceData[source]["call"]
    local radioActive = voiceData[source]["radioActive"]

    local radioChanged = false
    local callChanged = false

    if key == "radio" and radio ~= value then -- Check if channel has changed
        if radio > 0 then -- Check if player was in a radio channel
            if radioData[radio] then  -- Remove player from radio channel
                if radioData[radio][source] then
                    DebugMsg("Player " .. source .. " was removed from radio channel " .. radio)
                    radioData[radio][source] = nil
                end
            end
        end

        if value > 0 then
            if not radioData[value] then -- Create channel if it does not exist
                DebugMsg("Player " .. source .. " is creating channel: " .. value)
                radioData[value] = {}
            end
            
            DebugMsg("Player " .. source .. " was added to channel: " .. value)
            radioData[value][source] = true -- Add player to channel
        end

        radioChanged = true
    elseif key == "call" and call ~= value then
        if call > 0 then -- Check if player was in a call channel
            if callData[call] then  -- Remove player from call channel
                if callData[call][source] then
                    DebugMsg("Player " .. source .. " was removed from call channel " .. call)
                    callData[call][source] = nil
                end
            end
        end

        if value > 0 then
            if not callData[value] then -- Create call if it does not exist
                DebugMsg("Player " .. source .. " is creating call: " .. value)
                callData[value] = {}
            end
            
            DebugMsg("Player " .. source .. " was added to call: " .. value)
            callData[value][source] = true -- Add player to call
        end

        callChanged = true
    elseif key == "radioActive" and radioActive ~= value then
        DebugMsg("Player " .. source .. " radio talking state was changed from: " .. tostring(radioActive):upper() .. " to: " .. tostring(value):upper())
        if radio > 0 then
            local channel = radioData[radio]

            if channel ~= nil then
                for id, _ in pairs(channel) do
                    DebugMsg("Sending sound to player" .. id)
                    TriggerClientEvent("pw_voip:client:RadioSound", id, value, radio)
                end
            end
        end
    end

    voiceData[source][key] = value

    DebugMsg("Player " .. source .. " changed " .. key .. " to: " .. tostring(value))

    TriggerClientEvent("pw_voip:client:SetMumbleVoiceData", -1, voiceData, radioChanged and radioData or false, callChanged and callData or false)
end)

exports.pw_chat:AddAdminChatCommand('radiochannels', function(source, args, rawCommand)
    if source > 0 then
        for id, players in pairs(radioData) do
            for player, _ in pairs(players) do
                local _user = exports['pw_base']:Source(player)
                local rpname = _user:Character().getName()
                print("Radio Channels: " .. id .. "-> id: " .. player .. ", RP NAME: " .. rpname .. "NAME: " .. GetPlayerName(player) .. "\n")
            end
        end
    end
    
end, {
    help = 'Check Radio Channels in Use'
}, -1)

exports.pw_chat:AddAdminChatCommand('callchannels', function(source, args, rawCommand)
    if source > 0 then
        for id, players in pairs(callData) do
            for player, _ in pairs(players) do
                local _user = exports['pw_base']:Source(player)
                local rpname = _user:Character().getName()
                print("Call Channel IDs: " .. id .. "-> id: " .. player .. ", RP NAME: " .. rpname .. "NAME: " .. GetPlayerName(player) .. "\n")
            end
        end
    end
    
end, {
    help = 'Check Call Channels in Use'
}, -1)

AddEventHandler("playerDropped", function()
    if voiceData[source] then
        local radioChanged = false
        local callChanged = false

        if voiceData[source].radio > 0 then
            if radioData[voiceData[source].radio] ~= nil then
                radioData[voiceData[source].radio][source] = nil
                radioChanged = true
            end
        end

        if voiceData[source].call > 0 then
            if callData[voiceData[source].call] ~= nil then
                callData[voiceData[source].call][source] = nil
                callChanged = true
            end
        end

        voiceData[source] = nil
        
        TriggerClientEvent("pw_voip:client:SetMumbleVoiceData", -1, voiceData, radioChanged and radioData or false, callChanged and callData or false)
    end
end)