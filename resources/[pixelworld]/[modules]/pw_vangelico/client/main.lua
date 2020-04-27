PW = nil
characterLoaded, playerData = false, nil
GLOBAL_COORDS, GLOBAL_PED = nil, nil
local onlineCops = 0
local onCooldown, lockdownStarted, nearStore, nearSafe, safeNotif, spawning, spawnedSafes = false, false, false, false, false, false, false
Spots, Safes = {}, {}

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
            PW.TriggerServerCallback('pw_vangelico:server:getSpots', function(spots, safes, onCd, lockdown)
                Spots = spots
                Safes = safes
                onCooldown = onCd
                lockdownStarted = lockdown
                GLOBAL_PED = PlayerPedId()
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                characterLoaded = true
            end)
        else
            playerData = data
        end
    else
        DeleteSafes()
        playerData = nil
        characterLoaded = false
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if characterLoaded and playerData then
        playerData.job = data
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
    end
end)

RegisterNetEvent('pw_vangelico:client:updateSafe')
AddEventHandler('pw_vangelico:client:updateSafe', function(safe, spot, var, state)
    Safes[safe][spot][var] = state
end)

RegisterNetEvent('pw_vangelico:client:resetEverything')
AddEventHandler('pw_vangelico:client:resetEverything', function(newSpots, newSafes, onCd, lockdown)
    Spots = newSpots
    for i = 1, #Spots do
        Spots[i].robbed = false
    end
    DeleteSafes()
    Safes = newSafes
    onCooldown = onCd
    lockdownStarted = lockdown
    nearSafe, safeNotif, spawning, spawnedSafes = false, false, false, false
    if nearStore then
        spawnedSafes = true
        spawning = true
        DrawSafes()
        while spawning do Wait(0); end
    end
end)

RegisterNetEvent('pw_vangelico:client:updateCops')
AddEventHandler('pw_vangelico:client:updateCops', function(cops)
    onlineCops = cops
end)

RegisterNetEvent('pw_vangelico:client:updateCooldown')
AddEventHandler('pw_vangelico:client:updateCooldown', function(state)
    onCooldown = state
end)

RegisterNetEvent('pw_vangelico:client:updateLockdown')
AddEventHandler('pw_vangelico:client:updateLockdown', function(state)
    lockdownStarted = state
end)

RegisterNetEvent('pw_vangelico:client:updateSpot')
AddEventHandler('pw_vangelico:client:updateSpot', function(spot, var, state)
    Spots[spot][var] = state
end)

RegisterNetEvent('pw_vangelico:client:playParticles')
AddEventHandler('pw_vangelico:client:playParticles', function(spot, src)
    if nearStore then
        loadParticle()
        StartParticleFxLoopedAtCoord('scr_jewel_cab_smash', Spots[spot].coords, 0.0, 0.0, 0.0, 1.2, false, false, false, false)
        Citizen.CreateThread(function()
            Citizen.Wait(300)
            PlaySoundFromCoord(-1, "Glass_Smash", Spots[spot].coords, "", 0, 0, 0)
            CreateModelSwap(Spots[spot].coords, 0.2, GetHashKey("des_jewel_" .. Spots[spot].caseProp .. "_start"), GetHashKey("des_jewel_" .. Spots[spot].caseProp .. "_end"), false)
        end)
        if src == GetPlayerServerId(PlayerId()) then
            loadAnimation(spot, true)
            Citizen.Wait(1500)
            ClearPedTasks(GLOBAL_PED)
            TriggerServerEvent('pw_vangelico:server:updateSpot', spot, 'robbed', true)
            TriggerServerEvent('pw_vangelico:server:updateSpot', spot, 'robbing', false)
            TriggerServerEvent('pw_vangelico:server:awardItems', spot)
        end
    end
end)

function BreakGlass(spot, weaponType)
    TriggerServerEvent('pw_vangelico:server:updateSpot', spot, 'robbing', true)
    math.randomseed(GetGameTimer())
    local canCrack = (Config.WeaponsAllowed[weaponType] > 0 and (Config.WeaponsAllowed[weaponType] > 1 or math.random(1,100) <= Config.BreakChance))
    TaskPedSlideToCoordHdgRate(GLOBAL_PED, Spots[spot].coords, Spots[spot].heading, -1, -1)
    SetEntityHeading(GLOBAL_PED, Spots[spot].heading)
    Citizen.Wait(2000)
    if canCrack then
        TriggerServerEvent('pw_vangelico:server:playParticles', spot)
    else
        loadAnimation()
        ClearPedTasks(GLOBAL_PED)
        exports.pw_notify:SendAlert('error', 'You only cracked the glass', 4000)
        TriggerServerEvent('pw_vangelico:server:updateSpot', spot, 'robbing', false)
    end
end

function loadParticle()

	if not HasNamedPtfxAssetLoaded('scr_jewelheist') then
        RequestNamedPtfxAsset('scr_jewelheist')
        Citizen.Wait(5)
    end

    SetPtfxAssetNextCall('scr_jewelheist')
end

function loadAnimation(spot, yes)
	loadAnimDict('missheist_jewel') 
    TaskPlayAnim(GLOBAL_PED, 'missheist_jewel', 'smash_case', 8.0, 1.0, -1, 2, 0, 0, 0, 0)
	Citizen.Wait((yes and 1700 or 700))
end

function loadAnimDict(dict)  
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function DrawText(spot)
    local title, message, icon
    local icons = { 'gem', 'ring', 'watch' }

    title = 'Vangelico Jewelry'
    message = "<b><span style='font-size:22px'>[ <span class='text-primary'>E</span> ] to rob"
    icon = 'fad fa-' .. (icons[math.random(#icons)])

    TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })

    Citizen.CreateThread(function()
        while showing == spot do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if IsPedArmed(GLOBAL_PED, 5) then
                    local _, weapon = GetCurrentPedWeapon(GLOBAL_PED, 1)
                    local weaponInfo = exports.pw_weapons:retreiveWeaponByHash(weapon)
                    if weaponInfo.label ~= "Unknown" then
                        local weaponType = weaponInfo.type
                        if not lockdownStarted and not onCooldown then
                            TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-90', 'Vangelico Jewelry')
                            Citizen.SetTimeout(2000, function()
                                TriggerServerEvent('pw_sound:server:PlayWithinDistance', 15.0, 'alarm', 0.8)
                            end)
                            TriggerServerEvent('pw_vangelico:server:updateLockdown', true)
                        end
                        BreakGlass(spot, weaponType)
                    end
                end
            end
        end
    end)
end

function HideDraw()
    showing = false
    TriggerEvent('pw_drawtext:hideNotification')
end

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
        Citizen.Wait(100)
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and GLOBAL_COORDS then
            if not onCooldown and lockdownStarted and nearStore then
                for k,v in pairs(Safes) do
                    if not v.safe.robbed and not v.frame.removing and not v.safe.robbing then
                        local dist = #(GLOBAL_COORDS - v.frame.coords)
                        if dist < 1.0 then
                            if not nearSafe then
                                nearSafe = k
                                SafeDetected(k, nearSafe)
                            end
                        elseif nearSafe == k then
                            nearSafe = false
                        end
                    elseif nearSafe == k then
                        nearSafe = false
                    end
                end
            elseif nearSafe then
                nearSafe = false
            end
        end
    end
end)

function LoadCases(type)
    for i = 1, 20 do
        if type == 'unload' then
            RemoveModelSwap(Spots[i].coords, 1.0, GetHashKey("des_jewel_" .. Spots[i].caseProp .. "_start"), GetHashKey("des_jewel_" .. Spots[i].caseProp .. "_end"), false)
        elseif type == 'load' then
            if Spots[i].robbed then
                CreateModelSwap(Spots[i].coords, 1.0, GetHashKey("des_jewel_" .. Spots[i].caseProp .. "_start"), GetHashKey("des_jewel_" .. Spots[i].caseProp .. "_end"), false)
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and GLOBAL_COORDS then
            if not onCooldown then
                local dist = #(GLOBAL_COORDS - Spots[1].coords)
                if dist <= 20.0 then
                    nearStore = true
                    if not spawnedSafes then
                        if not spawning then
                            spawnedSafes = true
                            spawning = true
                            DrawSafes()
                            while spawning do Wait(0); end
                            LoadCases('load')
                        end
                    end
                    if playerData.job.name ~= 'police' and onlineCops >= Config.NeededPolice then
                        for k,v in pairs(Spots) do
                            dist = #(GLOBAL_COORDS - v.coords)
                            if dist < 0.8 then
                                if not v.robbed then
                                    if not showing and not v.robbing then
                                        showing = k
                                        DrawText(k)
                                    elseif showing == k and v.robbing then
                                        HideDraw()
                                    end
                                elseif v.robbed and showing == k then
                                    HideDraw()
                                end
                            elseif showing == k then
                                HideDraw()
                            end
                        end
                    end
                else
                    nearStore = false
                    LoadCases('unload')
                    if Safes[1].frame.obj ~= 0 then
                        DeleteSafes()
                        spawnedSafes = false
                    end
                end
            elseif showing then
                HideDraw()
            end
        end
    end
end)

function SafeDetected(safe, var)
    if not safeNotif then
        if Safes[safe].frame.inPlace then
            safeNotif = true
            exports.pw_notify:SendAlert('inform', 'You notice a crooked '..((safe == 1 or safe == 3) and "mirror" or "frame"), 4000)
            Citizen.SetTimeout(10000, function()
                safeNotif = false
            end)
        end
    end

    Citizen.CreateThread(function()
        while nearSafe == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if not onCooldown and lockdownStarted then
                    if Safes[safe].frame.inPlace and not Safes[safe].frame.removing then
                        TriggerEvent('pw:progressbar:progress',
                            {
                                name = 'removing_frame',
                                duration = 5000,
                                label = 'Removing frame',
                                useWhileDead = false,
                                canCancel = true,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = false,
                                    disableMouse = true,
                                    disableCombat = true,
                                },
                                animation = {

                                },
                            },
                            function(status)
                                if not status then
                                    Citizen.Wait(800)
                                    TriggerServerEvent('pw_vangelico:server:removeFrame', safe)
                                    TriggerServerEvent('pw_vangelico:server:updateSafe', safe, 'frame', 'removing', false)
                                else
                                    TriggerServerEvent('pw_vangelico:server:updateSafe', safe, 'frame', 'removing', false)
                                end
                            end)
                    elseif not Safes[safe].safe.disabled and not Safes[safe].safe.robbed and Safes[safe].safe.active and not Safes[safe].safe.robbing then
                        TriggerServerEvent('pw_vangelico:server:updateSafe', safe, 'safe', 'robbing', true)
                        TriggerEvent('pw_clicker:client:startGame', 6, function(success)
                            -- safe cracking mini game
                            if success then
                                TriggerServerEvent('pw_vangelico:server:awardSafe', safe)
                                TriggerServerEvent('pw_vangelico:server:updateSafe', safe, 'safe', 'robbing', false)
                            else
                                TriggerServerEvent('pw_vangelico:server:updateSafe', safe, 'safe', 'disabled', true)
                                TriggerServerEvent('pw_vangelico:server:updateSafe', safe, 'safe', 'robbing', false)
                                exports.pw_notify:SendAlert('error', 'The safe went on lockdown', 5000)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

RegisterNetEvent('pw_vangelico:client:removeFrame')
AddEventHandler('pw_vangelico:client:removeFrame', function(safe)
    if nearStore then
        if DoesEntityExist(Safes[safe].frame.obj) then
            SetEntityAsMissionEntity(Safes[safe].frame.obj, true, true)
            DeleteEntity(Safes[safe].frame.obj)
            Safes[safe].frame.obj = 0
        end
        nearSafe = false
        DrawSafes()
    end
end)

function DeleteSafes()
    for i = 1, #Safes do
        if DoesEntityExist(Safes[i].safe.obj) then
            SetEntityAsMissionEntity(Safes[i].safe.obj, true, true)
            DeleteEntity(Safes[i].safe.obj)
        end

        if Safes[i].frame.inPlace then
            if DoesEntityExist(Safes[i].frame.obj) then
                SetEntityAsMissionEntity(Safes[i].frame.obj, true, true)
                DeleteEntity(Safes[i].frame.obj)
            end
        end
    end
end

function DrawSafes()
    spawning = true

    local safeModel = -1251197000
    
    while not HasModelLoaded(safeModel) do
        RequestModel(safeModel)
        Wait(1)
    end

    for i = 1, #Safes do
        if Safes[i].frame.inPlace then
            if Safes[i].frame.obj ~= 0 and DoesEntityExist(Safes[i].frame.obj) then
                SetEntityAsMissionEntity(Safes[i].frame.obj, true, true)
                DeleteEntity(Safes[i].frame.obj)
                Safes[i].frame.obj = 0
            end
            local frameModel = GetHashKey(Safes[i].frame.model)

            while not HasModelLoaded(frameModel)do
                RequestModel(frameModel)
                Wait(1)
            end

            local frameObj = CreateObjectNoOffset(Safes[i].frame.model, Safes[i].frame.coords, false, false, true)
            FreezeEntityPosition(frameObj, true)
            SetEntityHeading(frameObj, Safes[i].frame.heading)
            Safes[i].frame.obj = frameObj
        else
            if Safes[i].safe.obj ~= 0 and DoesEntityExist(Safes[i].safe.obj) then
                SetEntityAsMissionEntity(Safes[i].safe.obj, true, true)
                DeleteEntity(Safes[i].safe.obj)
                Safes[i].safe.obj = 0
            end
            if Safes[i].safe.active then
                local safeObj = CreateObjectNoOffset(-1251197000, Safes[i].safe.coords, false, false, true)
                FreezeEntityPosition(safeObj, true)
                SetEntityHeading(safeObj, Safes[i].safe.heading)
                Safes[i].safe.obj = safeObj
            end
        end
    end
    spawning = false
end

function safe()
    local playerPed = GLOBAL_PED

    -- v_ret_mirror
    -- v_ilev_trev_pictureframe
    -- -1251197000 - safe
    local thermalObj = GetHashKey("v_ilev_trev_pictureframe")-- 
    while not HasModelLoaded(thermalObj) do
        RequestModel(thermalObj)
        Wait(10)
    end
    
    local objCoords = { ['x'] = -621.2, ['y'] = -235.5, ['z'] = 38.06, ['h'] = 164.65 }
    local x, y, z, h = objCoords.x, objCoords.y, objCoords.z, objCoords.h
    local thermal = CreateObjectNoOffset(thermalObj, x, y, z, 1, 1, 0)
    FreezeEntityPosition(thermal, true)
    local moving = true

    Citizen.CreateThread(function()
        while moving do
            Citizen.Wait(1)
            SetEntityCoords(thermal, x, y, z, 0.0, 0.0, 0.0, false)
            SetEntityHeading(thermal, h)
        end
    end)

    Citizen.CreateThread(function()
        while moving do
            Citizen.Wait(1)
            if IsControlPressed(0, 108) then --num4 X -
                x = x - 0.01
            end
            
            if IsControlPressed(0, 109) then --num6 X +
                x = x + 0.01
            end

            if IsControlPressed(0, 111) then --num8 Y +
                y = y + 0.01
            end

            if IsControlPressed(0, 112) then --num5 Y -
                y = y - 0.01
            end

            if IsControlPressed(0, 96) then --num- H -
                h = h - 1.0
                if h < 0 then h = h + 360; end
            end

            if IsControlPressed(0, 97) then --num+ H +
                h = h + 1.0
                if h > 359.99 then h = h - 360; end
            end

            if IsControlPressed(0, 117) then --num7 Z -
                z = z - 0.01
            end
            
            if IsControlPressed(0, 118) then --num9 Z +
                z = z + 0.01
            end

            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then --save
                print(x,y,z,h)
                moving = false
                DeleteObject(thermal)
            end
        end
    end)
end



local running = false
function safeFrame()
    running = true
    local frameObj = GetHashKey("v_ret_mirror")
    local safeObj = -1251197000

    RequestModel(frameObj)
    RequestModel(safeObj)

    while not HasModelLoaded(frameObj) or not HasModelLoaded(safeObj) do
        Wait(1)
    end

    local safeCoords = vector3(-616.69000000001, -233.14, 38.52)
    local frameCoords = vector3(-617.06, -233.13, 37.8)
    
    local frameObject = CreateObjectNoOffset(frameObj, frameCoords, 1, 1, 0)
    FreezeEntityPosition(frameObject, true)
    SetEntityHeading(frameObject, 270.97)

    Citizen.Wait(2000)
    DeleteObject(frameObject)

    local safeObject = CreateObjectNoOffset(safeObj, safeCoords, 1, 1, 0)
    FreezeEntityPosition(safeObject, true)
    SetEntityHeading(safeObject, 271.0)

    Citizen.Wait(2000)
    DeleteObject(safeObject)

    running = false
end

--[[ Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsControlJustPressed(0, 38) then
            safe()
            if not running then
                safeFrame()
            end
        end
    end
end) ]]