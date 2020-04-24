local currentMonth = os.date("%B")
local currentDay = os.date("%d")
local blackout = false
local weatherTimer = ss_weather_timer * 60 -- 60 Seconds times whatever config minutes are.
local rainTimer = ss_rain_timeout * 60
local rainPossible = false

Citizen.CreateThread(function()
    local currentMonth = os.date("%B")
    local currentDay = os.date("%d")
    if(currentMonth == "December" and tonumber(currentDay) > 20 and tonumber(currentDay) < 30) then
        currentWeather = "XMAS"
    else
        currentWeather = ss_default_weather
    end
end)

RegisterServerEvent( "pw_serversync:changeWeather" )
AddEventHandler( "pw_serversync:changeWeather", function(startup)
    if startup then
        TriggerClientEvent( 'pw_serversync:changeWeather',source, currentWeather, blackout, startup )
    else
        TriggerClientEvent( 'pw_serversync:changeWeather',-1, currentWeather, blackout, startup )
	end
end)

Citizen.CreateThread(function()
	TraceMsg("initialized.")
    while true do
        weatherTimer = weatherTimer - 1
        if rainPossible == true then
            rainTimer = -1
        else
            rainTimer = rainTimer - 1
        end
        Citizen.Wait(1000) -- one second wait time
        if weatherTimer == 0 then
			if ss_enable_dynamic_weather then
                PushNextWeather()
            end
            weatherTimer = ss_weather_timer * 60
        end

        if rainTimer == 0 then
            rainPossible = true   
        end
    end
end)

function PushNextWeather()
    -- We need to find the current weather, selection a transistion weather, then push that to the clients via pw_serversync:changeWeather
    local reduced = false
    local reducedW = ""
	math.randomseed(GetGameTimer())
	local count = getTableLength(ss_weather_Transition)
    local tableKeys = getTableKeys(ss_weather_Transition)
    local currentOptions = ss_weather_Transition[currentWeather]
    if(currentMonth == "December" and tonumber(currentDay) >= 20 and tonumber(currentDay) <= 30) then
        currentWeather = "XMAS"
    else
        currentWeather = currentOptions[math.random(1,getTableLength(currentOptions))]
    end
    
    -- Reduce the chance of rainy weather being selected. (You get a free roll to try and get away)
    if ss_reduce_rain_chance == true then
        for i,wtype in ipairs(currentOptions) do
            if wtype == string.upper("THUNDER") or wtype == string.upper("CLEARING") then
                currentWeather = currentOptions[math.random(1,getTableLength(currentOptions))]
                reduced = true
                reducedW = wtype
            end
        end
    end

    if rainPossible == false then 
        while currentWeather == "THUNDER" or currentWeather == "CLEARING" do
            currentWeather = currentOptions[math.random(1,getTableLength(currentOptions))]
        end
    end

    if string.upper(currentWeather) == string.upper("THUNDER") or string.upper(currentWeather) == string.upper("CLEARING") then
        rainTimer = ss_rain_timeout * 60
        rainPossible = false
    end

    if ss_show_console_output then
        TraceMsg("New Weather: "..currentWeather.." (Tried to reduce: "..tostring(reduced).." from "..reducedW..") PossibleRain: ".. tostring(rainPossible) .. " | rainTimer: " .. tostring(rainTimer))
    end
	TriggerEvent("pw_serversync:changeWeather",false)
end

exports.pw_chat:AddAdminChatCommand('weather', function(source, args, rawCommand)
    local _src = source
    local validWeatherType = false
            if args[1] == nil then
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Invalid Syntax: Correct Syntax <span class='text-warning'>/weather [weatherType]</span>", length = 5000})
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = "Current Weather: "..currentWeather, length = 5000})
            else
                local tableKeys = getTableKeys(ss_weather_Transition)
			    for i,wtype in ipairs(tableKeys) do
                    if wtype == string.upper(args[1]) then
                        validWeatherType = true
                    end
                end
                if validWeatherType then
                    local name = exports['pw_core']:getCharacter(_src).getFullName()
                    currentWeather = string.upper(args[1])
                    weatherTimer = ss_weather_timer * 60
                    if args[2] == "1" then
                        TriggerEvent('pw_serversync:changeWeather',true)
                    else
                        TriggerEvent("pw_serversync:changeWeather",false)
                        TraceMsg(name.." has changed weather to "..currentWeather)
                    end
                    
                    PW.doAdminLog(_src, "Changed the Server Weather", {['weather'] = currentWeather, ['name'] = name}, true)
                else
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Error: Invalid weather type, valid weather types are in the chat suggestions", length = 5000})
                end
            end
end, {
    help = "Change the Server Weather",
    params = {{ name = "Weather Type", help = "EXTRASUNNY CLEAR SMOG FOGGY OVERCAST CLOUDS CLEARING\nRAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS"} }
}, -1)