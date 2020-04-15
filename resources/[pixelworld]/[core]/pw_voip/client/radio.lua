local Radio = {
    Open = false,
    On = false,
    Enabled = true,
    Dictionary = {
        "cellphone@",
        "cellphone@in_car@ds",
        "cellphone@str",    
        "random@arrests",  
    },
    Animation = {
        "cellphone_text_in",
        "cellphone_text_out",
        "cellphone_call_listen_a",
        "generic_radio_chatter",
    },
}

function SetRadioFrequency(channel)
    local newChannel = tonumber(channel)
    if newChannel == nil or newChannel > 999 or newChannel < 0 then
        newChannel = 0
    end
    if newChannel == 0 then
        Radio.On = false
        Radio:Remove()
    else
        local minFrequency = radioConfig.Frequency.List[1]
        if newChannel >= minFrequency and newChannel <= radioConfig.Frequency.List[#radioConfig.Frequency.List] and newChannel == math.floor(newChannel) then
            if not radioConfig.Frequency.Private[newChannel] or radioConfig.Frequency.Access[newChannel] then
                local idx = nil
    
                for i = 1, #radioConfig.Frequency.List do
                    if radioConfig.Frequency.List[i] == newChannel then
                        idx = i
                        break
                    end
                end

                if idx == nil then 
                    print('facked')
                end
    
                if idx ~= nil then
                    if Radio.Enabled then
                        Radio:Remove()
                    end

                    radioConfig.Frequency.CurrentIndex = idx
                    radioConfig.Frequency.Current = newChannel

                    Radio.On = true

                    SetMumbleProperty("radioEnabled", Radio.On)
                    Radio:Add(radioConfig.Frequency.Current)
                end
            else
                exports.pw_notify:SendAlert('error', 'Not Authorised For That Frequency', 2500)
            end
        else
            exports.pw_notify:SendAlert('error', 'Not Authorised For That Frequency', 2500)
        end
    end
end

function PowerOffRadio(silently)
    Radio.On = false
    Radio:Remove()
    if not silently then
        SendNUIMessage({ action = 'playSound', soundFile = "radio_off", soundVolume   = mumbleConfig.micClickVolume })
    end
end

-- Add player to radio channel
function Radio:Add(id)
    SendNUIMessage({ action = 'playSound', soundFile = "radio_on", soundVolume   = mumbleConfig.micClickVolume })
    SetRadioChannel(id)
end

-- Remove player from radio channel
function Radio:Remove()
    SetRadioChannel(0)
end

-- Generate list of available frequencies
function GenerateFrequencyList()
    radioConfig.Frequency.List = {}

    for i = radioConfig.Frequency.Min, radioConfig.Frequency.Max do
        if not radioConfig.Frequency.Private[i] or radioConfig.Frequency.Access[i] then
            radioConfig.Frequency.List[#radioConfig.Frequency.List + 1] = i
        end
    end
end

-- Check if radio is switched on
function IsRadioOn()
    return Radio.On
end

-- Check if radio is enabled or not
function IsRadioEnabled()
    return not Radio.Enabled
end

-- Check if radio can be used
function CanRadioBeUsed()
    return Radio.On and Radio.Enabled
end

-- Set if the radio is enabled or not
function SetRadioEnabled(value)
    if type(value) == "string" then
        value = value == "true"
    elseif type(value) == "number" then
        value = value == 1
    end
    
    Radio.Enabled = value and true or false
end

-- Add new frequency
function AddPrivateFrequency(value)
    local frequency = tonumber(value)

    if frequency ~= nil then
        if not radioConfig.Frequency.Private[frequency] then -- Only add new frequencies
            radioConfig.Frequency.Private[frequency] = true

            GenerateFrequencyList()
        end
    end
end

-- Remove private frequency
function RemovePrivateFrequency(value)
    local frequency = tonumber(value)

    if frequency ~= nil then
        if radioConfig.Frequency.Private[frequency] then -- Only remove existing frequencies
            radioConfig.Frequency.Private[frequency] = nil

            GenerateFrequencyList()
        end
    end
end

-- Give access to a frequency
function GivePlayerAccessToFrequency(value)
    local frequency = tonumber(value)

    if frequency ~= nil then
        if radioConfig.Frequency.Private[frequency] then -- Check if frequency exists
            if not radioConfig.Frequency.Access[frequency] then -- Only add new frequencies
                radioConfig.Frequency.Access[frequency] = true

                GenerateFrequencyList()
            end
        end
    end 
end

-- Remove access to a frequency
function RemovePlayerAccessToFrequency(value)
    local frequency = tonumber(value)

    if frequency ~= nil then
        if radioConfig.Frequency.Access[frequency] then -- Check if player has access to frequency
            radioConfig.Frequency.Access[frequency] = nil

            GenerateFrequencyList()
        end
    end 
end

-- Give access to multiple frequencies
function GivePlayerAccessToFrequencies(frequencies)
    local newFrequencies = {}
    
    for i = 1, #frequencies do
        local frequency = tonumber(frequencies[i])

        if frequency ~= nil then
            if radioConfig.Frequency.Private[frequency] then -- Check if frequency exists
                if not radioConfig.Frequency.Access[frequency] then -- Only add new frequencies
                    newFrequencies[#newFrequencies + 1] = frequency
                end
            end
        end
    end

    if #newFrequencies > 0 then
        for i = 1, #newFrequencies do
            radioConfig.Frequency.Access[newFrequencies[i]] = true
        end

        GenerateFrequencyList()
    end
end

-- Remove access to multiple frequencies
function RemovePlayerAccessToFrequencies(frequencies)
    local removedFrequencies = {}

    for i = 1, #frequencies do
        local frequency = tonumber(frequencies[i])

        if frequency ~= nil then
            if radioConfig.Frequency.Access[frequency] then -- Check if player has access to frequency
                removedFrequencies[#removedFrequencies + 1] = frequency
            end
        end
    end

    if #removedFrequencies > 0 then
        for i = 1, #removedFrequencies do
            radioConfig.Frequency.Access[removedFrequencies[i]] = nil
        end

        GenerateFrequencyList()
    end
end

-- Define exports
exports("IsRadioOpen", IsRadioOpen)
exports("IsRadioOn", IsRadioOn)
exports("IsRadioEnabled", IsRadioEnabled)
exports("CanRadioBeUsed", CanRadioBeUsed)
exports("TurnRadioOff", PowerOffRadio)
exports("SetRadioFrequency", SetRadioFrequency)
exports("AddPrivateFrequency", AddPrivateFrequency)
exports("RemovePrivateFrequency", RemovePrivateFrequency)
exports("GivePlayerAccessToFrequency", GivePlayerAccessToFrequency)
exports("RemovePlayerAccessToFrequency", RemovePlayerAccessToFrequency)
exports("GivePlayerAccessToFrequencies", GivePlayerAccessToFrequencies)
exports("RemovePlayerAccessToFrequencies", RemovePlayerAccessToFrequencies)

Citizen.CreateThread(function()
    GenerateFrequencyList()

    while true do
        Citizen.Wait(0)
        -- Init local vars
        local isDead = IsEntityDead(GLOBAL_PED)
        local minFrequency = radioConfig.Frequency.List[1]
        local broadcastType = 4
        local broadcastDictionary = Radio.Dictionary[broadcastType]
        local broadcastAnimation = Radio.Animation[broadcastType]
        local isBroadcasting = IsControlPressed(0, mumbleConfig.controls.radio.key) -- Gets the Radio Key from Main Config
        local isPlayingBroadcastAnim = IsEntityPlayingAnim(GLOBAL_PED, broadcastDictionary, broadcastAnimation, 3)

        -- Open radio settings
        if Radio.On and (not Radio.Enabled) then
            Radio:Remove()
            SetMumbleProperty("radioEnabled", false)
            Radio.On = false
        end
        
        -- Remove player from private frequency that they don't have access to
        if not radioConfig.Frequency.Access[radioConfig.Frequency.Current] and radioConfig.Frequency.Private[radioConfig.Frequency.Current] and Radio.On then
            Radio:Remove()
            radioConfig.Frequency.CurrentIndex = 1
            radioConfig.Frequency.Current = minFrequency
            Radio:Add(radioConfig.Frequency.Current)
        end

        if Radio.On and isBroadcasting and not isPlayingBroadcastAnim then
            RequestAnimDict(broadcastDictionary)

            while not HasAnimDictLoaded(broadcastDictionary) do
                Citizen.Wait(150)
            end

            TaskPlayAnim(GLOBAL_PED, broadcastDictionary, broadcastAnimation, 8.0, 0.0, -1, 49, 0, 0, 0, 0)                    
        elseif not isBroadcasting and isPlayingBroadcastAnim then
            StopAnimTask(GLOBAL_PED, broadcastDictionary, broadcastAnimation, -4.0)
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
            SetMumbleProperty("radioClickMaxChannel", radioConfig.Frequency.Max) -- Set radio clicks enabled for all radio frequencies
            SetMumbleProperty("radioEnabled", false) -- Disable radio control
			return
		end
	end
end)


RegisterNetEvent('pw_voip:autheriseRadio')
AddEventHandler('pw_voip:autheriseRadio', function(toggle, job)
    local radioStations
    local radioStationNumbers = {
        ['emergency'] = {1,2,3,4,5,6,7,8,9,10},
        ['mechanic'] = {10},
        ['tuner'] = {666}
    }

    if job.name == "police" or job.name == "ems" or job.name == "doctor" or job.name == "fire" then
        radioStations = "emergency"
    elseif job.name == "mechanic" then
        radioStations = "mechanic"
    elseif job.name == "tuner" then
        radioStations = "tuner"
    end

    if radioStations ~= nil and radioStationNumbers[radioStations] ~= nil then
        if toggle then
            exports['pw_voip']:GivePlayerAccessToFrequencies(radioStationNumbers[radioStations])
        else
            exports['pw_voip']:RemovePlayerAccessToFrequencies(radioStationNumbers[radioStations])
            exports['pw_voip']:TurnRadioOff(true)
        end
    end
end)