PW = nil
characterLoaded, playerData = false, nil
local GLOBAL_PED, GLOBAL_COORDS, GLOBAL_VEH, GLOBAL_FOOT
local creatingRace, activeRace, signedUp, forceStart = false, {}, false, false
local nextCheckpoint = 0
Races, raceBlips, creatorBlips, curRace = {}, {}, {}, {}

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
            PW.TriggerServerCallback('pw_races:server:getRaces', function(races, active)
                Races = races
                activeRace = active
                playerData = data
                GLOBAL_PED = PlayerPedId()
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                characterLoaded = true
            end)
        else
            if signedUp then
                TriggerServerEvent('pw_races:server:signedUpOff')
            end
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
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and GLOBAL_PED and signedUp then
            GLOBAL_VEH = IsPedInAnyVehicle(GLOBAL_PED)
            GLOBAL_FOOT = IsPedOnFoot(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw_races:client:updateRaces')
AddEventHandler('pw_races:client:updateRaces', function(races)
    Races = races
end)

RegisterNetEvent('pw_races:client:activeRace')
AddEventHandler('pw_races:client:activeRace', function(race)
    activeRace = race
    if race.id == nil then
        if signedUp then signedUp = false; end
        TriggerEvent('pw_phone:client:activeContestants', false)
    end
end)

RegisterNetEvent('pw_races:client:joinedRace')
AddEventHandler('pw_races:client:joinedRace', function(state)
    signedUp = state
end)

RegisterNetEvent('pw_races:client:joinRace')
AddEventHandler('pw_races:client:joinRace', function()
    if not signedUp then
        if Races[activeRace.id].raceType ~= 4 then
            if IsPedInAnyVehicle(GLOBAL_PED) then
                local pedVeh = GetVehiclePedIsIn(GLOBAL_PED)
                local vehicleProps = PW.Game.GetVehicleProperties(pedVeh)
                local dist = #(GLOBAL_COORDS - vector3(Races[activeRace.id].start.x, Races[activeRace.id].start.y, Races[activeRace.id].start.z))
                if dist < Config.DistanceToSign then
                    TriggerServerEvent('pw_races:server:signUp', vehicleProps.plate, vehicleProps.model)
                end
            else
                exports.pw_notify:SendAlert('error', 'Can\'t join this race without a vehicle. Get inside one first.', 5000)
            end
        else
            if IsPedOnFoot(GLOBAL_PED) then
                local dist = #(GLOBAL_COORDS - vector3(Races[activeRace.id].start.x, Races[activeRace.id].start.y, Races[activeRace.id].start.z))
                if dist < 30.0 then
                    TriggerServerEvent('pw_races:server:signUp')
                end
            else
                exports.pw_notify:SendAlert('error', 'This is a running course. You can\'t use any vehicle', 5000)
            end
        end
    else
        exports.pw_notify:SendAlert('error', 'You already are signed up for a race', 5000)
    end
end)

RegisterNetEvent('pw_races:client:startRace')
AddEventHandler('pw_races:client:startRace', function(data)
    local raceId = tonumber(data.raceId)
    local laps = tonumber(data.laps)
    local contestants = tonumber(data.contestants)
    local delay = tonumber(data.delay) > 10 and tonumber(data.delay) or 10
    
    TriggerEvent('pw_phone:client:activeContestants', true)
    TriggerServerEvent('pw_races:server:activeRace', raceId, laps, contestants)
    exports.pw_notify:SendAlert('inform', 'Race created. Signup closing in '..delay..'s', 5000)

    Citizen.CreateThread(function()
        local tempDelay = delay        
        
        while tempDelay > 0 and not forceStart and activeRace.id ~= nil do
            Citizen.Wait(1000)
            tempDelay = tempDelay - 1
            if tempDelay <= 10 and tempDelay > 0 then
                exports.pw_notify:SendAlert('inform', tempDelay..'s', 600)
                if tempDelay == 10 then
                    exports.pw_notify:PersistentAlert('start', 'raceCountdown', 'inform', 'Race signup closing in:', {})
                end
            end
        end
        forceStart = false

        exports.pw_notify:PersistentAlert('end', 'raceCountdown')
    end)
end)

RegisterNetEvent('pw_races:client:forceStart')
AddEventHandler('pw_races:client:forceStart', function()
    forceStart = true
end)

RegisterNetEvent('pw_races:client:setPositions')
AddEventHandler('pw_races:client:setPositions', function(race, pos, plate, model)
    if signedUp then
        if Races[activeRace.id].raceType ~= 4 then
            if IsPedInAnyVehicle(GLOBAL_PED) then
                local veh = GetVehiclePedIsIn(GLOBAL_PED)
                local vehicleProps = PW.Game.GetVehicleProperties(veh)
                if vehicleProps.plate == plate and vehicleProps.model == model then
                    SetEntityCoords(veh, Races[activeRace.id].positions[pos].x, Races[activeRace.id].positions[pos].y, Races[activeRace.id].positions[pos].z)
                    SetEntityHeading(veh, Races[activeRace.id].positions[pos].h)
                    Wait(100)
                    FreezeEntityPosition(veh, true)
                else
                    exports.pw_notify:SendAlert('error', 'You were disqualified from this race.<br>Registered vehicle didn\'t match with the current one.', 7500)
                    TriggerServerEvent('pw_races:server:disqualify')
                end
            else
                exports.pw_notify:SendAlert('error', 'You were disqualified from this race.<br>You weren\'t inside a vehicle.', 7500)
                TriggerServerEvent('pw_races:server:disqualify')
            end
        else
            if IsPedOnFoot(GLOBAL_PED) then
                SetEntityCoords(GLOBAL_PED, Races[activeRace.id].positions[pos].x, Races[activeRace.id].positions[pos].y, Races[activeRace.id].positions[pos].z - 0.987)
                SetEntityHeading(GLOBAL_PED, Races[activeRace.id].positions[pos].h)
                Wait(100)
                FreezeEntityPosition(GLOBAL_PED, true)
            else
                exports.pw_notify:SendAlert('error', 'You were disqualified from this race.<br>You were inside a vehicle at race starting time.', 7500)
                TriggerServerEvent('pw_races:server:disqualify')
            end
        end
    end
end)

RegisterNetEvent('pw_races:client:countdown')
AddEventHandler('pw_races:client:countdown', function(time, laps)
    if signedUp then
        if time > 5 then
            exports.pw_notify:SendAlert('error', time, 600)
        elseif time > 0 then
            exports.pw_notify:SendAlert('inform', time, 600, { ['background-color'] = '#ffff00', ['color'] = '#000000' })
        end

        if time == 5 then
            curRace = Races[activeRace.id]
            curRace.laps = laps
            curRace.activeRace = activeRace.id
            LoadRaceInfo(activeRace.id)
            if curRace.raceType == 4 and GLOBAL_FOOT then
                DisplayRadar(true)
                exports['pw_hud']:toggleMiniMap(true)
            end
        end
    end
end)

function SetRoute(type, pos)
    ClearAllBlipRoutes()
    if type == 'checkpoints' then
        DNFCheck(pos)
        SetBlipColour(raceBlips.checkpoints[pos], Config.Blips.checkpoints.active)
        SetBlipRoute(raceBlips.checkpoints[pos], true)
        SetBlipRouteColour(raceBlips.checkpoints[pos], 5)
        if curRace.raceType == 1 and curRace.lap <= curRace.laps then
            local prevPos = ((pos == 1 or pos == 'start') and #curRace.checkpoints or pos - 1)
            SetBlipColour(raceBlips.checkpoints[prevPos], Config.Blips.checkpoints.color)
        end
    else
        DNFCheck(type)
        if curRace.raceType == 1 and curRace.lap <= curRace.laps then
            SetBlipColour(raceBlips.checkpoints[#curRace.checkpoints], Config.Blips.checkpoints.color)
        end
        SetBlipRoute(raceBlips[type], true)
        SetBlipRouteColour(raceBlips[type], 5)
    end
end

function FormatMilis(ms)
    local seconds = ms / 1000
    local roundedSecs = math.floor(seconds)

    local remainingMilis = seconds - roundedSecs
    remainingMilis = tostring(remainingMilis)
    remainingMilis = string.sub(remainingMilis, 3, 5)

    local mins = math.floor(roundedSecs / 60)
    local finalSeconds
    if mins > 0 then
        roundedSecs = roundedSecs - mins * 60
    end

    if tonumber(mins) < 10 then mins = '0'..mins; end
    if tonumber(roundedSecs) < 10 then roundedSecs = '0'..roundedSecs; end
    if tonumber(remainingMilis) < 100 then
        if tonumber(remainingMilis) < 10 then
            remainingMilis = remainingMilis .. '00'
        else
            remainingMilis = remainingMilis .. '0'
        end
    end

    return mins, roundedSecs, remainingMilis
end

function PrintTime(type)
    local timeMilis = GetGameTimer() - curRace.timer

    local mins, secs, ms = FormatMilis(timeMilis)

    if type == 'total' then
        return timeMilis, mins, secs, ms
    else
        return mins, secs, ms
    end
end

function DrawAdvancedText(text, x, y, sc)
    local scale = sc or 0.6
    SetTextFont(6)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    N_0x4e096588b13ffeca(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function DNFCheck(next)
    Citizen.SetTimeout(Config.DisqualifyTime * 60 * 1000, function()
        if curRace.nextCheckpoint == next and racing then
            racing = false
            RemoveBlips()
            TriggerServerEvent('pw_races:server:finished', 'DNF')
            exports.pw_notify:SendAlert('error', 'Your race was ended. It took you more than 5 minutes to reach the next checkpoint.', 5000)
        end
    end)
end

RegisterNetEvent('pw_races:client:fookingGO')
AddEventHandler('pw_races:client:fookingGO', function()
    if signedUp then
        if curRace.raceType ~= 4 then
            local veh = GetVehiclePedIsIn(GLOBAL_PED)
            FreezeEntityPosition(veh, false)
        else
            FreezeEntityPosition(GLOBAL_PED, false)
        end
        curRace.timer = GetGameTimer()
        curRace.lap = 1
        exports.pw_notify:SendAlert('success', 'GO!', 3000)
        if curRace.raceType ~= 1 and curRace.laps == 1 then
            RemoveBlip(raceBlips.start)
            raceBlips.start = nil
        end
        curRace.nextCheckpoint = 1
        SetRoute('checkpoints', curRace.nextCheckpoint)
        racing = true
        local prevBest = 0
        local prevFormat, color

        Citizen.CreateThread(function()
            while racing and characterLoaded do
                Citizen.Wait(1)
                local mins, secs, ms = PrintTime()
                if curRace.bestLap ~= nil and prevBest ~= curRace.bestLap then
                    prevBest = curRace.bestLap
                    local dm, ds, dms = FormatMilis(GetLapTime(curRace.bestLap))
                    prevFormat = dm .. ":" .. ds .. "." .. dms
                    color = "~g~"
                    Citizen.SetTimeout(3000, function()
                        color = "~s~"
                    end)
                end
                local msg = "~g~" .. curRace.name .. "~s~ - " .. Config.RaceTypes[curRace.raceType].type
                msg = msg .. "~n~" .. (curRace.laps > 1 and 'Lap ~y~' .. curRace.lap .. '~s~/~b~' .. curRace.laps .. '~s~ | ' or '~s~') .. mins .. ':' .. secs .. "." .. ms
                msg = msg .. ((curRace.raceType == 1 and curRace.bestLap) and "~n~ Best Lap: " .. color .. prevFormat or "")
                DrawAdvancedText(msg, 0.0210, 0.68)
            end
        end)

        Citizen.CreateThread(function()
            local topSpeed = 0
            while racing and characterLoaded do
                Citizen.Wait(100)
                local curSpeed
                if GLOBAL_VEH and not GLOBAL_FOOT then
                    curSpeed = GetEntitySpeed(GetVehiclePedIsIn(GLOBAL_PED)) * 2.236936
                else
                    curSpeed = GetEntitySpeed(GLOBAL_PED) * 2.236936
                end
                if curSpeed > topSpeed then topSpeed = curSpeed; end
                if (curRace.raceType ~= 4 and GLOBAL_VEH and not GLOBAL_FOOT) or (curRace.raceType == 4 and GLOBAL_FOOT and not GLOBAL_VEH) then
                    if curRace.nextCheckpoint ~= 'finish' and curRace.nextCheckpoint ~= 'start' then
                        local dist = #(GLOBAL_COORDS - vector3(curRace.checkpoints[curRace.nextCheckpoint].x, curRace.checkpoints[curRace.nextCheckpoint].y, curRace.checkpoints[curRace.nextCheckpoint].z))
                        if dist < curRace.checkpoints[curRace.nextCheckpoint].size then
                            if (curRace.raceType == 1 and curRace.lap == curRace.laps) or curRace.raceType ~= 1 then
                                RemoveBlip(raceBlips.checkpoints[curRace.nextCheckpoint])
                                raceBlips.checkpoints[curRace.nextCheckpoint] = nil
                            end
                            curRace.nextCheckpoint = curRace.nextCheckpoint + 1
                            if (curRace.raceType ~= 1 and curRace.nextCheckpoint > #curRace.checkpoints) or (curRace.raceType == 1 and curRace.lap == curRace.laps and curRace.nextCheckpoint > #curRace.checkpoints) then
                                curRace.nextCheckpoint = 'finish'
                                SetRoute('finish')                            
                            else
                                if curRace.raceType == 1 and curRace.lap < curRace.laps and curRace.nextCheckpoint > #curRace.checkpoints then
                                    curRace.nextCheckpoint = 'start'
                                    SetRoute('start', curRace.nextCheckpoint)
                                else
                                    SetRoute('checkpoints', curRace.nextCheckpoint)
                                end
                            end
                        end
                    else
                        if curRace.nextCheckpoint == 'start' then
                            local startDist = #(GLOBAL_COORDS - vector3(curRace.start.x, curRace.start.y, curRace.start.z))
                            if startDist < 10.0 then
                                curRace.nextCheckpoint = 1
                                SetRoute('checkpoints', curRace.nextCheckpoint)
                                local totalms, mins, secs, ms = PrintTime('total')
                                if curRace.lapTimes == nil then curRace.lapTimes = {}; end
                                curRace.lapTimes[curRace.lap] = {totalms, mins, secs, ms}
                                curRace.bestLap = GetBestLap()
                                curRace.lap = curRace.lap + 1
                                if curRace.lap == curRace.laps then
                                    RemoveBlip(raceBlips.start)
                                    raceBlips.start = nil
                                    CreateBlip(curRace.activeRace, 'finish')
                                end
                            end
                        else
                            local finishDist = #(GLOBAL_COORDS - vector3(curRace.finish.x, curRace.finish.y, curRace.finish.z))
                            if finishDist < 10.0 then
                                local totalms, mins, secs, ms = PrintTime('total')
                                local tmpTopSpeed = (topSpeed - math.abs(topSpeed)) > 0.5 and math.ceil(topSpeed) or math.floor(topSpeed)
                                local sendTime = { ['total'] = totalms, ['display'] = mins .. ":" .. secs .. "." .. ms, ['topSpeed'] = { ['speed'] = tmpTopSpeed, ['car'] = (GLOBAL_VEH and PW.Vehicles.GetName(GetVehiclePedIsIn(GLOBAL_PED)) or 'onfoot') }}
                                if curRace.raceType == 1 then
                                    curRace.lapTimes[curRace.lap] = {totalms, mins, secs, ms}
                                    curRace.bestLap = GetBestLap()
                                    local bestLapTime = GetLapTime(curRace.bestLap)
                                    local lapM, lapS, lapMS = FormatMilis(bestLapTime)
                                    sendTime['best'] = {}
                                    sendTime['best'] = { ['total'] = bestLapTime, ['display'] = lapM .. ":" .. lapS .. "." .. lapMS }
                                end
                                racing = false
                                RemoveBlip(raceBlips.finish)
                                raceBlips.finish = nil
                                raceBlips = {}
                                TriggerServerEvent('pw_races:server:finished', sendTime)
                                if curRace.raceType == 1 and curRace.laps > 1 then
                                    for i = #curRace.lapTimes, 1, -1 do
                                        local displayM, displayS, displayMS = FormatMilis(GetLapTime(i))
                                        local totalM, totalS, totalMS = FormatMilis(curRace.lapTimes[i][1])
                                        exports.pw_notify:SendAlert('inform', 'Lap #'.. i .. ' | Lap Time: <b><span style="color: ' .. (i == curRace.bestLap and '#ff0000' or '#ffff00') .. '">' .. displayM .. ':' .. displayS .. '.' .. displayMS .. '</span></b> | Total Time: <b>' .. totalM .. ':' .. totalS .. '.' .. totalMS .. '</b>', 15000)
                                    end
                                end
                                exports.pw_notify:SendAlert('inform', 'You finished the race in <b><span style="color: #ffff00">' .. mins .. ':' .. secs .. '.' .. ms .. '</span></b><br>Top Speed: <b><span style="color: #ffff00">' .. tmpTopSpeed .. ' mph</span></b>', 15000)
                                if curRace.raceType == 4 and GLOBAL_FOOT then
                                    DisplayRadar(false)
                                    exports['pw_hud']:toggleMiniMap(false)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if activeRace.id ~= nil then
            local dist = #(GLOBAL_COORDS - vector3(Races[activeRace.id].start.x, Races[activeRace.id].start.y, Races[activeRace.id].start.z))
            if dist < Config.DistanceToSign then
                if not nearRace then
                    nearRace = activeRace.id
                    TriggerEvent('pw_phone:client:activeRace', true)
                end
            elseif nearRace == activeRace.id then
                nearRace = false
                TriggerEvent('pw_phone:client:activeRace', false)
            end
        elseif nearRace then
            nearRace = false
            TriggerEvent('pw_phone:client:activeRace', false)
        end
    end
end)

function RemoveBlips()
    if raceBlips.start then RemoveBlip(raceBlips.start); end
    if raceBlips.finish then RemoveBlip(raceBlips.finish); end
    if raceBlips.checkpoints ~= nil and #raceBlips.checkpoints > 0 then
        for k,v in pairs(raceBlips.checkpoints) do
            RemoveBlip(v)
        end
    end
    raceBlips = {}
end

function GetLapTime(lap)
    return curRace.lapTimes[lap][1] - (lap == 1 and 0 or curRace.lapTimes[lap - 1][1])
end

function GetBestLap()
    local best, lap
    for i = #curRace.lapTimes, 1, -1 do
        if best == nil or (curRace.lapTimes[i][1] - (i == 1 and 0 or curRace.lapTimes[i-1][1])) < best then
            best = GetLapTime(i)
            lap = i
        end
    end
    return lap
end

function LoadRaceInfo(race)
    CreateBlip(race, 'start')
    CreateBlip(race, 'checkpoints')
    CreateBlip(race, 'finish')
end

function CreatorBlip(type, x, y, z)
    local blip = AddBlipForCoord(x, y, z)

    if type == 'start' or type == 'finish' then
        SetBlipSprite(blip, Config.Blips[type].sprite)
        SetBlipScale(blip, Config.Blips[type].scale)
        SetBlipColour(blip, Config.Blips[type].color)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
        SetBlipHiddenOnLegend(blip, true)
    
        creatorBlips[type] = blip
    elseif type == 'checkpoints' then
        local index = #creatorBlips.checkpoints + 1
        
        SetBlipSprite(blip, Config.Blips[type].sprite)
        SetBlipScale(blip, Config.Blips[type].scale)
        SetBlipColour(blip, Config.Blips[type].color)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
        SetBlipHiddenOnLegend(blip, true)
        ShowNumberOnBlip(blip, tonumber(index))
        
        creatorBlips.checkpoints[index] = blip
    end
end

function CreateBlip(race, type, creator)
    local blip
    if type == 'start' or type == 'finish' then
        if ((curRace.laps == 1 or curRace.lap == curRace.laps) and type == 'finish') or type == 'start' then
            blip = AddBlipForCoord(Races[race][type].x, Races[race][type].y, Races[race][type].z)

            SetBlipSprite(blip, Config.Blips[type].sprite)
            SetBlipScale(blip, Config.Blips[type].scale)
            SetBlipColour(blip, Config.Blips[type].color)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            SetBlipHiddenOnLegend(blip, true)
        
            raceBlips[type] = blip
        end
    elseif type == 'checkpoints' then
        raceBlips.checkpoints = {}
        
        for k,v in pairs(Races[race].checkpoints) do
            blip = AddBlipForCoord(v.x, v.y, v.z)

            SetBlipSprite(blip, Config.Blips[type].sprite)
            SetBlipScale(blip, Config.Blips[type].scale)
            SetBlipColour(blip, Config.Blips[type].color)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            SetBlipHiddenOnLegend(blip, true)
            ShowNumberOnBlip(blip, tonumber(k))
        
            raceBlips.checkpoints[k] = blip
        end
    end
end

RegisterNetEvent('pw_races:client:sendRaceReady')
AddEventHandler('pw_races:client:sendRaceReady', function()
    TriggerServerEvent('pw_races:server:raceReady')
end)

function FinishSet(raceInfo)
    TriggerServerEvent('pw_races:server:saveNewRace', raceInfo)
    if creatorBlips['start'] ~= nil then
        RemoveBlip(creatorBlips['start'])
        for k,v in pairs(creatorBlips['checkpoints']) do
            RemoveBlip(v)
        end
    end
    creatorBlips = {}
end

function CheckpointsSet(raceInfo)
    creatingRace = 'finish'
    if raceInfo.type == 1 then -- if circuit then start = end
        raceInfo.finishPosition = raceInfo.startPosition
        FinishSet(raceInfo)
    else
        exports.pw_notify:PersistentAlert('start', 'finish', 'inform', 'Press <b><span style="color:#ffff00">SHIFT+X</span></b> to set the finish line', {})
        Citizen.CreateThread(function()
            while creatingRace == 'finish' and characterLoaded do
                Citizen.Wait(1)
                if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
                    raceInfo.finishPosition = { ['x'] = GLOBAL_COORDS.x, ['y'] = GLOBAL_COORDS.y, ['z'] = GLOBAL_COORDS.z }
                    exports.pw_notify:PersistentAlert('end', 'finish')
                    FinishSet(raceInfo)
                end
                
                if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then
                    exports.pw_notify:PersistentAlert('end', 'finish')
                    creatingRace = false
                end
            end
        end)
    end
end

function PositionsSet(raceInfo)
    if raceInfo.type ~= 4 then
        local veh = GetVehiclePedIsIn(GLOBAL_PED)
    end
    local showingNotif = false
    local curCheckpoint = 1
    
    raceInfo.checkpoints = {}
    
    exports.pw_notify:PersistentAlert('start', 'endCP', 'inform', 'Press <b><span style="color:#ffff00">SHIFT+SPACE</span></b> when you\'ve added all checkpoints', {})
    
    creatingRace = 'checkpoints'
    local markerSize = 5.0
    Citizen.CreateThread(function()
        while creatingRace == 'checkpoints' and characterLoaded do
            Citizen.Wait(1)
            if not showingNotif then
                showingNotif = true
                exports.pw_notify:PersistentAlert('start', 'chooseCP'..curCheckpoint, 'inform', 'Press <b><span style="color:#ffff00">SHIFT+X</span></b> to set checkpoint #'..curCheckpoint..'<br>Press <b><span style="color:#ffff00">UP</span></b> or <b><span style="color:#ffff00">DOWN</span></b> to change the radius', {})
            end

            local useCoords = GetEntityCoords((raceInfo.type ~= 4 and veh or GLOBAL_PED))
            DrawMarker(25, useCoords.x, useCoords.y, useCoords.z - (raceInfo.type ~= 4 and 0.05 or 0.987), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerSize, markerSize, 1.0, 255, 255, 255, 200, false, true, 2, false, nil, nil, false)

            if IsControlPressed(0, 172) then
                markerSize = markerSize + 0.15
            end

            if IsControlPressed(0, 173) then
                markerSize = markerSize - 0.15
            end

            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
                raceInfo.checkpoints[curCheckpoint] = { ['x'] = GLOBAL_COORDS.x, ['y'] = GLOBAL_COORDS.y, ['z'] = GLOBAL_COORDS.z, ['size'] = markerSize }
                CreatorBlip('checkpoints', raceInfo.checkpoints[curCheckpoint].x, raceInfo.checkpoints[curCheckpoint].y, raceInfo.checkpoints[curCheckpoint].z)
                exports.pw_notify:PersistentAlert('end', 'chooseCP'..curCheckpoint)
                curCheckpoint = curCheckpoint + 1
                showingNotif = false
            end

            if IsControlJustPressed(0, 22) and IsControlPressed(0, 21) then
                if curCheckpoint > 3 then
                    exports.pw_notify:PersistentAlert('end', 'chooseCP'..curCheckpoint)
                    exports.pw_notify:PersistentAlert('end', 'endCP')
                    CheckpointsSet(raceInfo)
                else
                    exports.pw_notify:SendAlert('error', 'You need 3 or more checkpoints', 4000)
                end
            end

            if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then
                exports.pw_notify:PersistentAlert('end', 'chooseCP'..curCheckpoint)
                exports.pw_notify:PersistentAlert('end', 'endCP')
                creatingRace = false
            end
        end
    end)
end

function SetStartPos(raceInfo)
    raceInfo.startPosition = { ['x'] = GLOBAL_COORDS.x, ['y'] = GLOBAL_COORDS.y, ['z'] = GLOBAL_COORDS.z }
    CreatorBlip('start', raceInfo.startPosition.x, raceInfo.startPosition.y, raceInfo.startPosition.z)
    creatorBlips.checkpoints = {}
    raceInfo.positions = {}

    creatingRace = 'positions'
    local curPosition = 1
    local showingNotif = false

    Citizen.CreateThread(function()
        while creatingRace == 'positions' and characterLoaded do
            Citizen.Wait(1)
            if not showingNotif then
                showingNotif = true
                exports.pw_notify:PersistentAlert('start', 'choosePos'..curPosition, 'inform', 'Press <b><span style="color:#ffff00">SHIFT+X</span></b> to set the pole position #'..curPosition .. ' (' .. (raceInfo.max - curPosition) .. ' left)', {})
            end

            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
                raceInfo.positions[curPosition] = { ['x'] = GLOBAL_COORDS.x, ['y'] = GLOBAL_COORDS.y, ['z'] = GLOBAL_COORDS.z, ['h'] = GetEntityHeading(GLOBAL_PED) }
                exports.pw_notify:PersistentAlert('end', 'choosePos'..curPosition)
                if curPosition >= raceInfo.max then
                    PositionsSet(raceInfo)
                else
                    curPosition = curPosition + 1
                    showingNotif = false
                end
            end

            if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then
                exports.pw_notify:PersistentAlert('end', 'choosePos'..curPosition)
                creatingRace = false
            end
        end
    end)
end

RegisterNetEvent('pw_races:client:chooseStart')
AddEventHandler('pw_races:client:chooseStart', function(data)
    if creatorBlips['start'] ~= nil then
        RemoveBlip(creatorBlips['start'])
        for k,v in pairs(creatorBlips['checkpoints']) do
            RemoveBlip(v)
        end
    end
    creatorBlips = {}

    local raceInfo = {}
    raceInfo.name = data.raceName
    raceInfo.type = tonumber(data.raceType)
    raceInfo.max = tonumber(data.maxContestants)

    creatingRace = 'start'

    exports.pw_notify:PersistentAlert('start', 'chooseStart', 'inform', 'Press <b><span style="color:#ffff00">SHIFT+X</span></b> to set the starting line', {})
    
    Citizen.CreateThread(function()
        while creatingRace == 'start' and characterLoaded do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
                exports.pw_notify:PersistentAlert('end', 'chooseStart')
                SetStartPos(raceInfo)
            end

            if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then
                exports.pw_notify:PersistentAlert('end', 'chooseStart')
                creatingRace = false
            end
        end
    end)
end)