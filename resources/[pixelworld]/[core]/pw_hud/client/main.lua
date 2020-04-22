PW = nil
local characterInfoSheetCooldown = false
GLOBAL_PED = nil
local directions = { [0] = 'North Bound', [45] = 'North West', [90] = 'West Bound', [135] = 'South West', [180] = 'South Bound', [225] = 'South East', [270] = 'East Bound', [315] = 'North East', [360] = 'North Bound', } 
local playerLoaded = false
local playerData = nil
local pauseOpen = false
local showVehicleHud = false
local currentHunger, currentThirst, currentDrugs, currentStress, currentDrunk = 100, 100, 0, 0, 0
local inVehicle = false
local onCruiseControl = false

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
	end
end)

RegisterNetEvent('pw_hud:client:receiveStats')
AddEventHandler('pw_hud:client:receiveStats', function(stats)
    if (stats ~= nil and type(stats) == "table") then
        local total = 0
        local xCount = 0
        for k, v in pairs(stats.drugs) do
            total = (total + v)
            xCount = (xCount + 100)
        end
        local percentageDrugs = (total / xCount * 100)

        currentHunger = stats.hunger
        currentThirst = stats.thirst
        currentDrugs = percentageDrugs
        currentStress = stats.stress
        currentDrunk = stats.drunk
    end
end)

RegisterNetEvent('pw_hud:client:toggleLogo')
AddEventHandler('pw_hud:client:toggleLogo', function(toggle)
    SendNUIMessage({
        action = "toggleLogo",
        toggle = toggle,
    })
end)

Citizen.CreateThread(function()
    while true do
        if playerLoaded then
            local temp = PlayerPedId()
            inVehicle = IsPedInAnyVehicle(GLOBAL_PED)
            if GLOBAL_PED ~= temp then
                GLOBAL_PED = temp
            end
        end
        Citizen.Wait(200)
    end
end)

function openCharacterInfoSheet()
    characterInfoSheetCooldown = true
    SendNUIMessage({
        action = "showCharacterSheet",
    })
end

function updateClock()
    local hour, minute
    if GetClockHours() < 10 then
        hour = '0'..GetClockHours()
    else
        hour = GetClockHours()
    end
    if GetClockMinutes() < 10 then
        minute = '0'..GetClockMinutes()
    else
        minute = GetClockMinutes()
    end
    local time = hour..':'..minute
    SendNUIMessage({
        action = "updateClock",
        time = time
    })
end

function updatePosition()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    local street, cross = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local streetName = GetStreetNameFromHashKey(street)
    local crossName
    if cross ~= nil then
        crossName =  ', '..GetStreetNameFromHashKey(cross)
    else
        crossName = ''
    end

    for k,v in pairs(directions)do
        direction = GetEntityHeading(playerPed)
        if(math.abs(direction - k) < 22.5)then
            direction = v
            break
        end
    end

    SendNUIMessage({
        action = "updateStreet",
        street = streetName..crossName,
        heading = direction
    })
end

function updateStats()
    local currentHealth = (GetEntityHealth(PlayerPedId()) - 100)

    SendNUIMessage({
        action = "updateStats",
        healthBar = currentHealth,
        hunger = currentHunger,
        thirst = currentThirst,
        drugs = currentDrugs,
        stress = currentStress,
        drunk = currentDrunk,
        armour = GetPedArmour(PlayerPedId())
    })
    
end


Citizen.CreateThread(function()
    while true do
        updateClock()
        updatePosition()
        updateStats()
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded and GLOBAL_PED ~= nil and GLOBAL_PED > 0 then
            if inVehicle then
                local vehicle = GetVehiclePedIsIn(GLOBAL_PED, false)
                local current = GetEntitySpeed(vehicle)
                local mph = (current * 2.236936)
                local speedPer = (mph / 245 * 100)
                local curRPM = GetVehicleCurrentRpm(vehicle)
                SendNUIMessage({
                    action = "updateVehicleSpeed",
                    percent = math.ceil(speedPer),
                    mph = math.ceil(mph),
                    rpm = math.ceil((curRPM * 100))
                })
            end
        end
    end
end)

exports('toggleHud', function(toggle)
    if toggle then
        SendNUIMessage({
            action = "enableHud",
        })
    else
        SendNUIMessage({
            action = "disableHud",
        })
    end
end)

exports('toggleMiniMap', function(toggle)
    DisplayRadar(toggle)
end)

Citizen.CreateThread(function()
    while true do
        if playerLoaded then
            if IsPauseMenuActive() then
                if not pauseOpen then
                    SendNUIMessage({
                        action = "disableHud",
                    })
                    pauseOpen = true
                end
            else
                if pauseOpen then
                    SendNUIMessage({
                        action = "enableHud",
                    })
                    pauseOpen = false
                end
            end
            if GLOBAL_PED ~= nil and GLOBAL_PED > 0 then
                if inVehicle then
                    if not showVehicleHud then
                        DisplayRadar(true)
                        SendNUIMessage({
                            action = "enableVehicleHud",
                        })
                        showVehicleHud = true
                    end
                else
                    if showVehicleHud then
                        DisplayRadar(false)
                        SendNUIMessage({
                            action = "disableVehicleHud",
                        })
                        showVehicleHud = false
                    end
                end
            end
        end
        Citizen.Wait(200)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            SendNUIMessage({
                action = "enableHud",
            })
            playerLoaded = true
        else
            playerData = data
            SendNUIMessage({
                action = "updateHudInformation",
                playerName = playerData.name,
                playerCash = playerData.cash,
                playerId = GetPlayerServerId(PlayerId()),
            })
        end
    else
        playerData = nil
        playerLoaded = false
        inVehicle = false
        DisplayRadar(false)
        showVehicleHud = false
    end
end)

RegisterNetEvent('pw:characters:cashAdjustment')
AddEventHandler('pw:characters:cashAdjustment', function(amount)
    if playerLoaded and playerData then
        playerData.cash = tonumber(amount)
        SendNUIMessage({
            action = "updateCash",
            playerCash = playerData.cash,
        })
    end
end)

RegisterNetEvent('pw_hud:client:updateRadioChannel')
AddEventHandler('pw_hud:client:updateRadioChannel', function(show, channel)
    SendNUIMessage({
        action = "updateRadioChannel",
        radioTrue = show,
        channel = channel
    })
end)

RegisterNetEvent('pw_hud:client:updateTalking')
AddEventHandler('pw_hud:client:updateTalking', function(html)
    SendNUIMessage({
        action = "updateCurrentlySpeaking",
        html = html,
    })
end)

RegisterNetEvent('pw_hud:client:updateVoiceLevel')
AddEventHandler('pw_hud:client:updateVoiceLevel', function(level)
    SendNUIMessage({
        action = "voiceLevel",
        level = level
    })
end)

RegisterNetEvent('pw:switchCharacter')
AddEventHandler('pw:switchCharacter', function()
    SendNUIMessage({
        action = "disableHud",
    })
end)

RegisterNUICallback("showCharacterSheetCooldownReset", function(data, cb)
    characterInfoSheetCooldown = false
end)


Citizen.CreateThread(function()
    while true do
        if not characterInfoSheetCooldown then
            if IsControlJustReleased(0, 37) then
                openCharacterInfoSheet()
            elseif inVehicle and IsControlJustReleased(0, Config.CruiseKey) and not onCruiseControl then
                StartCruise()
            end
        end
        Citizen.Wait(4)
    end
end)

function StartCruise()
    local playerPed = PlayerPedId()
    local pedVeh =	GetVehiclePedIsIn(playerPed, false)
    local vehClass = GetVehicleClass(pedVeh)
    local vehVel = GetVehicleWheelSpeed(pedVeh, 1)
    if inVehicle and vehClass ~= 16 and vehClass ~= 15 and vehClass ~= 14 and vehClass ~= 13 and vehClass ~= 8 and vehVel > 2.0 and vehVel < 40.0 then
        onCruiseControl = true
        SendNUIMessage({
            action = "updateCruiseControl",
            cruiseStatus = onCruiseControl,
        })
        exports.pw_notify:SendAlert('info', 'Cruise Control Enabled', 2500)
        local speed = vehVel * 2.237
        while onCruiseControl do
            Citizen.Wait(5)
            local vehVel2 = GetVehicleWheelSpeed(pedVeh, 1)
            if vehVel2 < 0.001 then
                vehVel2 = 0.01
            end
            local diff = vehVel + 0.2 - vehVel2
            local throttle = 0.2
            if diff > 1.0 then
                throttle = 1.0
            else
                throttle = diff
            end
            if not IsControlPressed(0, 76) and throttle > 0.01 then
                SetControlNormal(0, 71, throttle)
            end
            if throttle < 0.001 then
                throttle = 0.0
            end
            local curspeed = GetVehicleWheelSpeed(pedVeh, 1) * 2.237
            speed = vehVel * 2.237
            if IsControlJustPressed(0, 8) or (curspeed > 100.0) or (curspeed < 10.0) or (speed > 85.0) or (speed < 10.0) or not IsPedInAnyVehicle(playerPed, true) then
                onCruiseControl = false
                SendNUIMessage({
                    action = "updateCruiseControl",
                    cruiseStatus = onCruiseControl,
                })
                exports.pw_notify:SendAlert('info', 'Cruise Control Disabled', 2500)
            end
        end
    else
        onCruiseControl = false
    end
end