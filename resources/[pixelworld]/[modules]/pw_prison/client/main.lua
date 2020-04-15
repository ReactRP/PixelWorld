-- Starting Variables
PW, characterLoaded, playerData = nil, false, nil
local showing = nil
local inCustody, timeRemaining, releaseEligable = false, 0, false
local currentJob, currentBlip, noJobs = nil, nil, 0
local doingJob = false
GLOBAL_PED, GLOBAL_COORDS = nil, nil

Citizen.CreateThread(function()
    while PW == nil do
	TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
    Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        if inCustody then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            Citizen.Wait(100)
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            characterLoaded = true
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            PW.TriggerServerCallback('pw_prison:server:checkCustodyState', function(inPrison, timeLeft)
                if inPrison then
                    local randomCell = math.random(0, #Config.EntryCell)
                    local cellInformation = Config.EntryCell[randomCell]
                    DoScreenFadeOut(1500)
                    Citizen.Wait(1501)
                    PW.Game.Teleport(cellInformation.x, cellInformation.y, cellInformation.z)
                    TriggerServerEvent('pw_prison:server:addPrisoner', timeLeft)
                    TriggerServerEvent('pw_sound:server:PlayWithinDistance', 5.0, 'cell', 1.0)
                    inCustody = inPrison
                    timeRemaining = timeLeft
                    if timeRemaining == 1 then
                        month = "month"
                    else
                        month = "months"
                    end
                    exports['pw_notify']:PersistentAlert('start', 'prisonTimer', 'info', 'You have '..timeRemaining..' '..month..' left on your sentence.')
                    Citizen.Wait(1500)
                    DoScreenFadeIn(1500)
                    Citizen.Wait(10000)
                    selectRandomJob()
                end
            end)
            runReleaseEligable()
        else
            playerData = data
        end
    else
        TriggerServerEvent('pw_prison:server:removeFromTimer')
        characterLoaded = false
        playerData = nil
    end
end)

function endWork()
    if currentBlip ~= nil then
        RemoveBlip(currentBlip)
        currentBlip = nil
        DisplayRadar(false)
        exports['pw_hud']:toggleMiniMap(false)
    end
    exports['pw_notify']:PersistentAlert('end', 'prisonJob')
    currentJob = nil
end

function DoJobWork(job)
    exports['pw_notify']:PersistentAlert('end', 'prisonJob')
    if noJobs ~= 7 and noJobs ~= 6 then
        local timeReduction = math.random(1,3)
        if timeReduction == 1 then
            month = "month"
        else
            month = "months"
        end
        exports['pw_notify']:SendAlert('info', "Your sentenced has been reduced by "..timeReduction.." "..month..".", 4000)
        TriggerServerEvent('pw_prison:server:completedWork', timeReduction)
    end

    currentJob = nil

    if currentBlip ~= nil then
        RemoveBlip(currentBlip)
        currentBlip = nil
        DisplayRadar(false)
        exports['pw_hud']:toggleMiniMap(false)
    end
    
    if (job.animation ~= nil) or (job.task ~= nil) then
        doingJob = true
        if job.animation == nil and job.task ~= nil then
            local cSCoords
            local propSpawn
            local netid
            local prop_net
            if job.prop ~= nil then
                cSCoords = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0.0, -5.0)
                propSpawn = CreateObject(GetHashKey(job.prop), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
                netid = ObjToNet(propSpawn)
            end
            TaskStartScenarioInPlace(GLOBAL_PED, job.task, 0, true)
            if job.prop ~= nil then
                AttachEntityToEntity(propSpawn,GLOBAL_PED,GetPedBoneIndex(GLOBAL_PED, 28422),-0.005,0.0,0.0,190.0,190.0,-50.0,1,1,0,1,0,1)
                prop_net = netid
                Citizen.Wait(job.duration)
                DetachEntity(NetToObj(prop_net), 1, 1)
                DeleteEntity(NetToObj(prop_net))
                prop_net = nil
            else
                Citizen.Wait(job.duration)
            end

            ClearPedTasks(GLOBAL_PED)
            doingJob = false
        elseif job.animation ~= nil and job.task == nil then
            local cSCoords
            local propSpawn
            local netid
            local prop_net
            if job.prop ~= nil then
                cSCoords = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0.0, -5.0)
                propSpawn = CreateObject(GetHashKey(job.prop), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
                netid = ObjToNet(propSpawn)
            end
            PW.Streaming.RequestAnimDict(job.animation, function()
                TaskPlayAnim(GLOBAL_PED, job.animation, job.dict, 8.0, -8.0, job.duration, 0, 0, false, false, false)
                if job.prop ~= nil then
                    AttachEntityToEntity(propSpawn, GLOBAL_PED, GetPedBoneIndex(GLOBAL_PED, 28422), -0.005, 0.0 ,0.0 ,360.0 ,360.0,0.0,1,1,0,1,0,1)
                    prop_net = netid
                    Citizen.Wait(job.duration)
                    DetachEntity(NetToObj(prop_net), 1, 1)
                    DeleteEntity(NetToObj(prop_net))
                    prop_net = nil
                else
                    Citizen.Wait(job.duration)
                end
                ClearPedTasks(GLOBAL_PED)
                doingJob = false
            end)
        end
    else
        doingJob = true
        local cSCoords
        local propSpawn
        local netid
        local prop_net
        if job.prop ~= nil then
            cSCoords = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0.0, -5.0)
            propSpawn = CreateObject(GetHashKey(job.prop), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
            netid = ObjToNet(propSpawn)
        end
        if job.prop ~= nil then
            AttachEntityToEntity(propSpawn,GLOBAL_PED,GetPedBoneIndex(GLOBAL_PED, 28422),-0.005,0.0,0.0,190.0,190.0,-50.0,1,1,0,1,0,1)
            prop_net = netid
            Citizen.Wait(job.duration)
            DetachEntity(NetToObj(prop_net), 1, 1)
            DeleteEntity(NetToObj(prop_net))
            prop_net = nil
        else
            Citizen.Wait(job.duration)
        end
        doingJob = false
    end

    if job.needs ~= nil then
        for k, v in pairs(job.needs) do
            for a, b in pairs(v) do
                TriggerEvent('pw_needs:client:updateNeeds', a, k, b)
            end
        end
    else
        TriggerEvent('pw_needs:client:updateNeeds', 'stress', 'add', 10000)
        TriggerEvent('pw_needs:client:updateNeeds', 'thirst', 'remove', 1000)
        TriggerEvent('pw_needs:client:updateNeeds', 'hunger', 'remove', 3000)
    end

    Citizen.Wait(10000)
    noJobs = (noJobs + 1)
    if not releaseEligable then
        if noJobs == 6 then
            doFood()
        elseif noJobs == 7 then
            doExcercise()
            noJobs = 0
        else
            selectRandomJob()
        end
    end
end

Citizen.CreateThread(function()
    while true do
        if doingJob then
            
            DisableControlAction(0, 32, true) -- W
            DisableControlAction(0, 34, true) -- A
            DisableControlAction(0, 31, true) -- S
            DisableControlAction(0, 30, true) -- D
            DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?
			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen
			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle
			DisableControlAction(2, 36, true) -- Disable going stealth
			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
        end
        Citizen.Wait(1)
    end
end)

function doFood()
    local randomFood = math.random(1, #Config.FoodPoints)
    local selectedJob = Config.FoodPoints[randomFood]
    currentJob = randomFood

    exports['pw_notify']:PersistentAlert('start', 'prisonJob', 'info', '<strong>Current Task:</strong><br>Eat & Drink')
    Citizen.CreateThread(function()
        currentBlip = AddBlipForCoord(selectedJob.x, selectedJob.y, selectedJob.z)
        SetBlipSprite(currentBlip, 402)
        SetBlipDisplay(currentBlip, 4)
        SetBlipScale  (currentBlip, 0.75)
        SetBlipColour (currentBlip, 78)
        SetBlipAsShortRange(currentBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("[~r~Prison~s~] Eat & Drink")
        EndTextCommandSetBlipName(currentBlip)
        exports['pw_hud']:toggleMiniMap(true)
        DisplayRadar(true)

        while currentJob == randomFood do
            local letSleep = true
            if GLOBAL_PED then
                local distance = #(GLOBAL_COORDS - vector3(selectedJob.x, selectedJob.y, selectedJob.z))
                if distance < 10.0 then
                    letSleep = false
                    DrawMarker(27, selectedJob.x, selectedJob.y, selectedJob.z-0.99, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 200, false, true, 2, true, nil, nil, false)
                    if distance < 1.0 then
                        if IsControlJustPressed(0, 38) then
                            DoJobWork(selectedJob)
                        end
                    end
                end
            end

            if letSleep then
                Citizen.Wait(200)
            else
                Citizen.Wait(1)
            end
        end
    end)
end

function doExcercise()
    local randomExcer = math.random(1, #Config.ExcercisePoints)
    local selectedJob = Config.ExcercisePoints[randomExcer]
    currentJob = randomExcer

    exports['pw_notify']:PersistentAlert('start', 'prisonJob', 'info', '<strong>Current Task:</strong><br>'..selectedJob.label)
    Citizen.CreateThread(function()
        currentBlip = AddBlipForCoord(selectedJob.x, selectedJob.y, selectedJob.z)
        SetBlipSprite(currentBlip, 402)
        SetBlipDisplay(currentBlip, 4)
        SetBlipScale  (currentBlip, 0.75)
        SetBlipColour (currentBlip, 78)
        SetBlipAsShortRange(currentBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("[~r~Prison~s~] "..selectedJob.label)
        EndTextCommandSetBlipName(currentBlip)
        exports['pw_hud']:toggleMiniMap(true)
        DisplayRadar(true)

        while currentJob == randomExcer do
            local letSleep = true
            if GLOBAL_PED then
                local distance = #(GLOBAL_COORDS - vector3(selectedJob.x, selectedJob.y, selectedJob.z))
                if distance < 10.0 then
                    letSleep = false
                    DrawMarker(27, selectedJob.x, selectedJob.y, selectedJob.z-0.99, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 200, false, true, 2, true, nil, nil, false)
                    if distance < 1.0 then
                        if IsControlJustPressed(0, 38) then
                            DoJobWork(selectedJob)
                        end
                    end
                end
            end

            if letSleep then
                Citizen.Wait(200)
            else
                Citizen.Wait(1)
            end
        end
    end)
end

function selectRandomJob()

    local randomJob = math.random(#Config.Jobs)
    local selectedJob = Config.Jobs[randomJob]
    currentJob = randomJob
    exports['pw_notify']:PersistentAlert('start', 'prisonJob', 'info', '<strong>Current Job:</strong><br>'..selectedJob.label)
    Citizen.CreateThread(function()
        currentBlip = AddBlipForCoord(selectedJob.x, selectedJob.y, selectedJob.z)
        SetBlipSprite(currentBlip, 402)
        SetBlipDisplay(currentBlip, 4)
        SetBlipScale  (currentBlip, 0.75)
        SetBlipColour (currentBlip, 78)
        SetBlipAsShortRange(currentBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("[~r~Prison~s~] "..selectedJob.label)
        EndTextCommandSetBlipName(currentBlip)
        exports['pw_hud']:toggleMiniMap(true)
        DisplayRadar(true)
        
        while currentJob == randomJob do
            local letSleep = true
            if GLOBAL_PED then
                local distance = #(GLOBAL_COORDS - vector3(selectedJob.x, selectedJob.y, selectedJob.z))
                if distance < 10.0 then
                    letSleep = false
                    DrawMarker(27, selectedJob.x, selectedJob.y, selectedJob.z-0.99, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 200, false, true, 2, true, nil, nil, false)
                    if distance < 1.0 then
                        if IsControlJustPressed(0, 38) then
                            DoJobWork(selectedJob)
                        end
                    end
                end
            end

            if letSleep then
                Citizen.Wait(200)
            else
                Citizen.Wait(1)
            end
        end
    end) 
end

Citizen.CreateThread(function()
    local checking = false
    while true do
        local letSleep = true
        if inCustody then
            if GLOBAL_PED then
                local distance = #(GLOBAL_COORDS - vector3(Config.EscapePoint.x, Config.EscapePoint.y, Config.EscapePoint.z))
                if distance < Config.EscapePoint.radius then
                    letSleep = false
                    if not checking then
                        checking = true
                        PW.TriggerServerCallback('pw_prison:server:checkBreakouts', function(allowed)
                            if allowed then
                                exports['pw_notify']:PersistentAlert('end', 'prisonEligable')
                                exports['pw_notify']:PersistentAlert('end', 'prisonTimer')
                                inCustody = false
                                timeRemaining = 0
                                releaseEligable = false
                                TriggerServerEvent('pw_prison:server:playerBrokeOut')
                            else
                                returnToCell()
                            end
                            checking = false
                        end)
                    end
                end
            end
        end
        if letSleep then
            Citizen.Wait(500)
        else
            Citizen.Wait(1)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if inCustody then
            if GLOBAL_PED then
                local checker = Config.ExitPoint.releaseCheck
                local distance = #(GLOBAL_COORDS - vector3(checker.x, checker.y, checker.z))
                if distance < 0.75 then 
                    letSleep = false
                    if releaseEligable then
                        exports['pw_doors']:toggleLockById(Config.ExitPoint.doorIdent, true)
                        exports['pw_notify']:PersistentAlert('end', 'prisonEligable')
                        exports['pw_notify']:PersistentAlert('end', 'prisonTimer')
                        inCustody = false
                        timeRemaining = 0
                        releaseEligable = false
                    else
                        returnToCell()
                    end
                end
            end
        end
        if letSleep then
            Citizen.Wait(500)
        else
            Citizen.Wait(1)
        end
    end
end)

function returnToCell()
    local randomCell = math.random(0, #Config.EntryCell)
    local cellInformation = Config.EntryCell[randomCell]
    DoScreenFadeOut(1500)
    Citizen.Wait(1501) 
    PW.Game.Teleport(cellInformation.x, cellInformation.y, cellInformation.z)
    Citizen.Wait(1500)
    DoScreenFadeIn(1500)
    TriggerServerEvent('pw_prison:server:increaseTime', Config.ExitPoint.penalty)
    if Config.ExitPoint.penalty == 1 then
        month = "month"
    else
        month = "months"
    end
    exports['pw_notify']:SendAlert('info', "Your sentenced has been increased by "..Config.ExitPoint.penalty.." "..month..". for attempting to leave early.", 4000)
end

RegisterNetEvent('pw_prison:client:sendToPrison')
AddEventHandler('pw_prison:client:sendToPrison', function(time)
    local _src = source
    local randomCell = math.random(0, #Config.EntryCell)
    local cellInformation = Config.EntryCell[randomCell] 
    DoScreenFadeOut(1500)
    Citizen.Wait(1501)
    PW.Game.Teleport(cellInformation.x, cellInformation.y, cellInformation.z)
    TriggerServerEvent('pw_prison:server:registerPrison', time)
    TriggerServerEvent('pw_prison:server:addPrisoner', time)
    TriggerServerEvent('pw_sound:server:PlayWithinDistance', 5.0, 'cell', 1.0)
    inCustody = true
    timeRemaining = time
    if timeRemaining == 1 then
        month = "month"
    else
        month = "months"
    end
    exports['pw_notify']:PersistentAlert('start', 'prisonTimer', 'info', 'You have '..timeRemaining..' '..month..' left on your sentence.')
    Citizen.Wait(1500)
    DoScreenFadeIn(1500)
    Citizen.Wait(10000)
    selectRandomJob()
end)

function doRelease()
    exports['pw_notify']:PersistentAlert('end', 'prisonEligable')
    exports['pw_doors']:toggleLockById(Config.ExitPoint.doorIdent, false)
end

function runReleaseEligable()
    local showingRelease
    Citizen.CreateThread(function()
        local releaseSection = Config.ExitPoint.releaseCoords
        while releaseEligable do
            local distance = #(GLOBAL_COORDS - vector3(releaseSection.x, releaseSection.y, releaseSection.z))
            if distance < 1.0 then
                if not showingRelease then
                    showingRelease = true
                    TriggerEvent('pw_drawtext:showNotification', {title = "Federal Prison", message = "Press [ <span class='text-success'>E</span> ] to leave.", icon = "fad fa-container-storage"})
                end
                if IsControlJustPressed(0, 38) then
                    doRelease()
                end
            else
                if showingRelease then
                    showingRelease = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end
            end
            Citizen.Wait(0)
        end
    end)
end

RegisterNetEvent('pw_prison:client:updatePrisonTime')
AddEventHandler('pw_prison:client:updatePrisonTime', function(time)
    if inCustody then
        if time <= 0 then
            if currentJob ~= nil then
                endWork()
            end
            exports['pw_notify']:PersistentAlert('end', 'prisonTimer')
            Wait(500)
            exports['pw_notify']:PersistentAlert('start', 'prisonEligable', 'info', 'You are now eligable for release.')
            releaseEligable = true
            timeRemaining = 0
            runReleaseEligable()
        else
            timeRemaining = time
            if timeRemaining == 1 then
                month = "month"
            else
                month = "months"
            end
            exports['pw_notify']:PersistentAlert('end', 'prisonTimer')
            Citizen.Wait(1000)
            exports['pw_notify']:PersistentAlert('start', 'prisonTimer', 'info', 'You have '..timeRemaining..' '..month..' left on your sentence.')
        end
    end
end)

Citizen.CreateThread(function()
    local prisonBlip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
    SetBlipSprite(prisonBlip, Config.BlipSprite)
    SetBlipDisplay(prisonBlip, 4)
    SetBlipScale  (prisonBlip, Config.BlipSize)
    SetBlipColour (prisonBlip, Config.BlipColor)
    SetBlipAsShortRange(prisonBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.BlipName)
    EndTextCommandSetBlipName(prisonBlip)
end)

Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if characterLoaded and playerData and GLOBAL_COORDS then
            local prisonDistance = #(GLOBAL_COORDS - vector3(Config.Location.x, Config.Location.y, Config.Location.z))
            if GLOBAL_PED and prisonDistance < 250.0 then
                letSleep = false
                ClearAreaOfPeds(Config.Location.x, Config.Location.y, Config.Location.z, 200.0, 1)
            end
        end
        
        if letSleep then
            Citizen.Wait(1000)
        else
            Citizen.Wait(500)
        end
    end
end)

