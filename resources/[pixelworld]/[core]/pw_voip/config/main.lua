voiceData = {}
radioData = {}
callData = {}
mumbleConfig = {
    debug = false, -- enable debug msgs
    voiceModes = {
        {2.5, "Whisper"}, -- Whisper speech distance in gta distance units
        {8, "Normal"}, -- Normal speech distance in gta distance units
        {20, "Shouting"}, -- Shout speech distance in gta distance units
    },
    speakerRange = 8.5, -- Speaker distance in gta distance units (how close you need to be to another player to hear other players on the radio or phone)
    callSpeakerEnabled = true, -- Allow players to hear all talking participants of a phone call if standing next to someone that is on the phone
    radioSpeakerEnabled = true, -- Allow players to hear all talking participants in a radio if standing next to someone that has a radio
    radioEnabled = true, -- Enable or disable using the radio
    micClicks = true, -- Are clicks enabled or not
    micClickOn = true, -- Is click sound on active
    micClickOff = true, -- Is click sound off active
    micClickVolume = 0.1, -- How loud a mic click is
    radioClickMaxChannel = 100, -- Set the max amount of radio channels that will have local radio clicks enabled
    controls = { -- Change default key binds
        proximity = { key = 73, }, -- Switch proximity mode (Z)
        radio = { pressed = false, key = 137, }, -- Use radio (CAPS)
        speaker = { key = 20, secondary = 21, } -- LEFT SHIFT + Z (phone speaker toggle)
    },
    radioChannelNames = { -- Add named radio channels (Defaults to [channel number] MHz)
        [1] = "PD",
        [2] = "SWAT",
        [3] = "EMS",
        [4] = "DOCTOR",
        [5] = "FIRE",
        [6] = "PRISON",
        [10] = "MECH",
        [666] = "RACE",
    },
    callChannelNames = {},
    use3dAudio = false, -- make sure setr voice_use3dAudio true and setr voice_useSendingRangeOnly true is in your server.cfg
}

radioConfig = {
    Frequency = {
        Private = { -- List of private frequencies
            [1] = true, -- Make 1 a private frequency
            [2] = true, 
            [3] = true, 
            [4] = true, 
            [5] = true, 
            [6] = true, 
            [7] = true, 
            [8] = true, 
            [9] = true, 
            [10] = true,
            [666] = true,
        },
        Current = 1, -- Don't touch
        CurrentIndex = 1, -- Don't touch
        Min = 1, -- Minimum frequency
        Max = 999, -- Max number of frequencies
        List = {}, -- Frequency list, Don't touch
        Access = {}, -- List of freqencies a player has access to
    },
    AllowRadioWhenClosed = true -- Always true
}

function DebugMsg(msg)
    if mumbleConfig.debug then
        print("[" .. resourceName .. "] ".. msg)
    end
end

-- Update config properties from another script
function SetMumbleProperty(key, value)
	if mumbleConfig[key] ~= nil and mumbleConfig[key] ~= "controls" and mumbleConfig[key] ~= "radioChannelNames" then
		mumbleConfig[key] = value
	end
end

function AddRadioChannelName(channel, name)
    local channel = tonumber(channel)
    if channel ~= nil and name ~= nil and name ~= "" then
        mumbleConfig.radioChannelNames[channel] = tostring(name)
    end
end

function AddCallChannelName(channel, name)
    local channel = tonumber(channel)
    if channel ~= nil and name ~= nil and name ~= "" then
        mumbleConfig.callChannelNames[channel] = tostring(name)
    end
end

-- Make exports available on first tick
exports("SetMumbleProperty", SetMumbleProperty)
exports("AddRadioChannelName", AddRadioChannelName)
exports("AddCallChannelName", AddCallChannelName)