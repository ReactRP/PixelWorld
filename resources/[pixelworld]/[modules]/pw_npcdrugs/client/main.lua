PW = nil
characterLoaded, playerData = false, nil
local selling, waitingKey, nearStore, processingSale = false, false, false, false
local Sellers, last, soldTo, methNpc = {}, {}, {}, {}
local methVeh, methTarget, methBlip, methQty

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
        if nearStore then NpcMethClerk('despawn'); end
        if methNpc.ped then DeleteEntity(methNpc.ped); end
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

RegisterNetEvent('pw_npcdrugs:client:updateSellers')
AddEventHandler('pw_npcdrugs:client:updateSellers', function(s)
    Sellers = s
end)

function CheckIfSellersNear()
    if #Sellers > 0 then
        local myId = GetPlayerServerId(PlayerId())
        for k,v in pairs(Sellers) do
            if myId ~= k then
                local dist = #(v.coords - GLOBAL_COORDS)
                if dist < 50.0 then
                    return true
                end
            end
        end
    end

    return false
end

RegisterNetEvent('pw_npcdrugs:client:sell')
AddEventHandler('pw_npcdrugs:client:sell', function(drug)
    if selling == 'meth' then exports.pw_notify:SendAlert('error', 'You are currently doing a meth run', 5000); return; end

    if not selling or (selling and selling ~= drug and last.drug ~= nil and last.drug ~= drug) then
        local owned = PW.Game.CheckInventory(Config.ItemName[drug])
        if owned > 0 then
            if not CheckIfSellersNear() then
                selling = drug
            else
                exports.pw_notify:SendAlert('error', 'This area is too crowded', 4500)
                return
            end
        end
    else
        selling = false
    end
    TriggerServerEvent('pw_npcdrugs:server:updateState', selling, (selling and { ['drug'] = drug, ['coords'] = GLOBAL_COORDS } or nil) )

    if selling then 
        last.drug = drug
    else
        last = {}
    end

    exports.pw_notify:SendAlert('inform', (selling and 'Corner Selling ' .. string.gsub(drug, "^%l", string.upper) or 'Stopped Corner Selling'), 4500)
end)

function ClearPed(ped)
    Wait(math.random(500, 2000))
    ClearPedTasks(ped)
    TriggerEvent('pw_items:showUsableKeys', false)
    waitingKey = false
    selling = 'cooldown'
    Citizen.SetTimeout(Config.FindCooldown * 1000, function()
        if selling == 'cooldown' then
            selling = last.drug
            last = { ['drug'] = selling }
        end
    end)
end

function CheckIfNear(ped)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(GLOBAL_COORDS - pedCoords)
    if dist < 4.0 then
        return true
    else
        ClearPed(ped)
        return false
    end
end

function WaitKeys(ped)
    Citizen.CreateThread(function()
        while waitingKey == ped do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then -- E
                if CheckIfNear(ped) then
                    waitingKey = false
                    -- TODO: give/receive anims
                    TriggerServerEvent('pw_npcdrugs:server:processDrugSell', last)
                    ClearPed(ped)
                end
            end

            if IsControlJustPressed(0, 47) then -- G
                if CheckIfNear(ped) then
                    ClearPed(ped)
                end
            end
        end
    end)
end

function DrawPed(ped)
    Citizen.CreateThread(function()
        while (selling == 'pedNear' and last.ped == ped) do
            Citizen.Wait(1)
            local pedCoords = GetEntityCoords(ped)
            DrawMarker(20, pedCoords.x, pedCoords.y, pedCoords.z + 1.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.25, 0.25, 0.25, 0, 255, 0, 200, false, true, 2, false, nil, nil, false)
        end
    end)
end

function CheckPed(ped)
    if ped == nil or (methNpc.ped and DoesEntityExist(methNpc.ped) and methNpc.ped == ped) or ped == GLOBAL_PED or ped == nearStore or not DoesEntityExist(ped) or IsPedAPlayer(ped) or IsPedFatallyInjured(ped) or IsPedFleeing(ped) or IsPedRunning(ped) or IsPedSprinting(ped) or IsPedInCover(ped) or IsPedGoingIntoCover(ped) or IsPedGettingUp(ped) or IsPedInMeleeCombat(ped) or IsPedShooting(ped) or IsPedDucking(ped) or IsPedBeingJacked(ped) or IsPedSwimming(ped) or IsPedSittingInAnyVehicle(ped) or IsPedGettingIntoAVehicle(ped) or IsPedJumpingOutOfVehicle(ped) or IsPedOnAnyBike(ped) or IsPedInAnyBoat(ped) or IsPedInFlyingVehicle(ped) then
        return false
    end

    local pedTypes = {6, 20, 21, 27, 28, 29}
    local pedType = GetPedType(ped)
    for i = 1, #pedTypes do
        if pedType == pedTypes[i] then
            return false
        end
    end

    return true
end

function GetRandomPed(peds)
    local usePeds = {}
    for k,v in pairs(peds) do
        if CheckPed(v) then
            table.insert(usePeds, v)
        end
    end

    local found = false
    if #usePeds > 0 then
        for k,v in pairs(usePeds) do
            local chance = math.random(100)
            if chance <= Config.NPCChance then
                found = v
                break
            end
        end
    end

    return found
end

function DelieverNote(ped)
    TaskTurnPedToFaceEntity(ped, GLOBAL_PED, -1)
    local maxBags = PW.Game.CheckInventory(Config.ItemName[last.drug])
    local randomBags = math.random(1, (maxBags >= Config.MaxQty[last.drug] and Config.MaxQty[last.drug] or maxBags))
    local randomPrice = math.random(Config.Prices[last.drug].min, Config.Prices[last.drug].max)
    last.amount = randomBags
    last.price = randomPrice
    -- TODO: give note anim
    TriggerEvent('pw_notes:client:createNote', '$'..(last.price * last.amount)..' for '..last.amount..' bags of '..string.gsub(last.drug, "^%l", string.upper))
    TaskStandStill(ped, Config.NPCWait * 1000)
    if not waitingKey then
        TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Accept"},{['key'] = "g", ['label'] = "Refuse"}})
        waitingKey = ped
        WaitKeys(ped)
    end
    Citizen.SetTimeout(Config.NPCWait * 1000, function()
        if waitingKey == ped then
            ClearPed(ped)
        end
    end)
end

function BringPed(ped)
    last.ped = ped
    DrawPed(ped)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    TaskGoToEntity(ped, GLOBAL_PED, 10000, 2.0, 100, 1073741824, 0)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1)
            if characterLoaded and GLOBAL_COORDS then
                local dist = #(GLOBAL_COORDS - GetEntityCoords(ped))
                if dist <= 2.15 then
                    DelieverNote(ped)
                    break
                end
            end
        end
    end)
end

function SetSold(ped)
    table.insert(soldTo, ped)
    Citizen.SetTimeout(Config.NPCCooldown * 1000, function()
        for k,v in pairs(soldTo) do
            if v == ped then
                soldTo[k] = nil
                break
            end
        end
    end)
end

function FindPeds()
    local peds = PW.Game.GetClosestPedsInArea(GLOBAL_COORDS, 15.0, soldTo)
    if #peds > 0 then
        local chosen = GetRandomPed(peds)
        if chosen then
            SetSold(chosen)
            selling = 'pedNear'
            BringPed(chosen)
        else
            selling = 'cooldown'
            Citizen.SetTimeout(Config.FindCooldown * 1000, function()
                selling = last.drug
            end)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and GLOBAL_COORDS then
            if selling and selling ~= 'pedNear' and selling ~= 'cooldown' and selling ~= 'meth' then
                FindPeds()
            end
        end
    end
end)

---- METH RUNS ----

function NpcMethClerk(stuff)
    if stuff == 'spawn' then
        local npcObj = GetHashKey(Config.MethRun.clerk[math.random(1,#Config.MethRun.clerk)])
        while not HasModelLoaded(npcObj) do
            RequestModel(npcObj)
            Wait(10)
        end

        nearStore = CreatePed(2, npcObj, Config.MethRun.location.x, Config.MethRun.location.y, Config.MethRun.location.z, Config.MethRun.location.h, false, true)
        SetEntityAsMissionEntity(nearStore, true, true)
        SetBlockingOfNonTemporaryEvents(nearStore, true)
        SetPedFleeAttributes(nearStore, 0, 0)
        SetEntityInvincible(nearStore, true)
    else
        if nearStore and DoesEntityExist(nearStore) then
            DeleteEntity(nearStore)
            nearStore = false
        end
    end
end

function CreateMethBlip(target)
    local blip = AddBlipForCoord(Config.MethRun.dropoffs[target].x, Config.MethRun.dropoffs[target].y, Config.MethRun.dropoffs[target].z)
    SetBlipSprite(blip, Config.MethRun.blips.type)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.MethRun.blips.scale)
    SetBlipColour(blip, Config.MethRun.blips.color)
    SetBlipAsShortRange(blip, true)
    SetBlipHiddenOnLegend(blip, true)
    return blip
end

function SpawnNpc(target)
    local npcObj = GetHashKey(Config.MethRun.targets[math.random(1,#Config.MethRun.targets)])
    while not HasModelLoaded(npcObj) do
        RequestModel(npcObj)
        Wait(10)
    end
    methNpc.target = target
    methNpc.ped = CreatePed(2, npcObj, Config.MethRun.dropoffs[target].x, Config.MethRun.dropoffs[target].y, Config.MethRun.dropoffs[target].z, Config.MethRun.dropoffs[target].h, true, true)
    SetEntityAsMissionEntity(methNpc.ped, true, true)
    SetBlockingOfNonTemporaryEvents(methNpc.ped, true)
    SetPedFleeAttributes(methNpc.ped, 0, 0)
end

function GTFO(ped)
    ClearPedTasks(ped)
    TaskWanderStandard(ped, 10.0, 10)
    Citizen.SetTimeout(30000, function()
        if DoesEntityExist(ped) then DeleteEntity(ped); end
    end)
end

function FindNewTarget()
    local chosen
    local count = #Config.MethRun.dropoffs
    repeat
        if count > 0 then
            local random = math.random(#Config.MethRun.dropoffs)
            if not Config.MethRun.dropoffs[random].done then
                chosen = random
            else
                count = count - 1
            end
        else
            chosen = false
        end
    until chosen ~= nil
    return chosen
end

function GoToNext()
    if methNpc.ped then GTFO(methNpc.ped); end
    if methQty > 0 then
        local target = FindNewTarget()
        if target then
            Config.MethRun.dropoffs[target].done = true
            methTarget = target
            if methBlip and DoesBlipExist(methBlip) then RemoveBlip(methBlip); methBlip = nil; end
            methBlip = CreateMethBlip(target)
            local shown = false
            Citizen.CreateThread(function()
                while (selling == 'meth' and methTarget == target) do
                    local dist = #(GLOBAL_COORDS - vector3(Config.MethRun.dropoffs[target].x, Config.MethRun.dropoffs[target].y, Config.MethRun.dropoffs[target].z))
                    if dist < 75.0 then
                        if not methNpc.ped or (methNpc.ped and methNpc.target ~= target) then
                            SpawnNpc(target)
                            if not shown then
                                exports.pw_notify:SendAlert('inform', 'You are near a drop-off location', 4500)
                                shown = true
                                Citizen.SetTimeout(10000, function()
                                    shown = false
                                end)
                            end
                        end

                        if dist < 2.5 then
                            if not waitingMethKey or waitingMethKey ~= 'dropoff' or (waitingMethKey == 'dropoff' and methNpc.target ~= target) then
                                TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Deliever"}})
                                waitingMethKey = 'dropoff'
                                WaitMethKey(waitingMethKey, target)
                            end
                        elseif waitingMethKey == 'dropoff' then
                            TriggerEvent('pw_items:showUsableKeys', false)
                            waitingMethKey = false
                        end
                    elseif methNpc and methNpc.ped and DoesEntityExist(methNpc.ped) and methNpc.target and methTarget == methNpc.target then
                        DeleteEntity(methNpc.ped)
                        methNpc.ped = nil
                    end
                    Citizen.Wait(100)
                end
            end)
        else
            exports.pw_notify:SendAlert('error', 'There are no more dropoffs available', 5000)
            StopRun()
        end
    else
        exports.pw_notify:SendAlert('error', 'You delievered all the meth for this run.', 5000)
        StopRun()
    end
end

function StartMethRun()
    selling = 'meth'
    TriggerEvent('pw_items:showUsableKeys', false)
    waitingMethKey = false
    methQty = Config.MethRun.qty
    GoToNext()
end

function StopRun()
    if methBlip and DoesBlipExist(methBlip) then RemoveBlip(methBlip); methBlip = nil; end
    selling = false
    waitingMethKey = false
    methTarget, methQty = nil, nil
    if methNpc.ped and DoesEntityExist(methNpc.ped) then GTFO(methNpc.ped); end
    methNpc = {}
    TriggerServerEvent('pw_npcdrugs:server:startMethCooldown')
end

function StartMissionTimeout()
    TriggerServerEvent('pw_npcdrugs:server:updateMethRun', true)
    Citizen.SetTimeout(Config.MethRun.maxDuration * 60 * 1000, function() 
        if selling == 'meth' then
            StopRun()
            exports.pw_notify:SendAlert('error', 'Your meth run timed out', 5000)
        end
    end)
end

RegisterNetEvent('pw_npcdrugs:client:startMethRun')
AddEventHandler('pw_npcdrugs:client:startMethRun', function(veh)
    PW.TriggerServerCallback('pw_npcdrugs:server:checkCashForRun', function(canDo)
        if canDo then
            local canSpawn = false
            for k,v in pairs(Config.MethRun.spawns) do
                local cV = GetClosestVehicle(v.x, v.y, v.z, 6.0, 0, 71)
                if cV == nil or cV == 0 then
                    canSpawn = k
                    break
                end
            end

            if canSpawn then
                StartMissionTimeout()
                ResetDropoffs()
                PW.Game.SpawnOwnedVehicle(veh, Config.MethRun.spawns[canSpawn], Config.MethRun.spawns[canSpawn].h, function(vehicle)
                    methVeh = vehicle
                    local vehProps = PW.Game.GetVehicleProperties(methVeh)
                    --[[ PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                        TriggerServerEvent('pw_keys:issueKey', 'Vehicle', vin, false, false, false)
                    end, vehProps, methVeh) ]]
                    TriggerServerEvent('pw_npcdrugs:server:loadVehTrunkWithMeth', vehProps.plate)
                    StartMethRun()
                    exports.pw_notify:SendAlert('inform', 'Your car is ready. We\'ve loaded the trunk with meth', 5000)
                end)
            else
                exports.pw_notify:SendAlert('error', 'The parking lot is blocked with vehicles. Clear the path.', 4500)
            end
        else
            exports.pw_notify:SendAlert('error', 'Not enough money', 4000)
        end
    end, Config.MethRun.price)
end)

RegisterNetEvent('pw_npcdrugs:client:stopRun')
AddEventHandler('pw_npcdrugs:client:stopRun', function()
    StopRun()
    exports.pw_notify:SendAlert('inform', 'You gave up on the run', 5000)
end)

function OpenClerkMenu()
    local menu = {}
    
    if selling == 'meth' then
        table.insert(menu, { ['label'] = 'Stop Run', ['action'] = 'pw_npcdrugs:client:stopRun', ['triggertype'] = 'client', ['color'] = 'danger' })
    else
        for k,v in pairs(Config.MethRun.cars) do
            table.insert(menu, { ['label'] = PW.Vehicles.GetName(v) .. ' ($' .. Config.MethRun.price .. ')', ['action'] = 'pw_npcdrugs:client:startMethRun', ['value'] = v, ['triggertype'] = 'client', ['color'] = 'primary' })
        end
    end
    
    TriggerEvent('pw_interact:generateMenu', menu, 'Choose your ride')
end

RegisterNetEvent('pw_npcdrugs:client:resetDropoffs')
AddEventHandler('pw_npcdrugs:client:resetDropoffs', function()
    ResetDropoffs()
end)

function ResetDropoffs()
    for k,v in pairs(Config.MethRun.dropoffs) do
        Config.MethRun.dropoffs[k]['done'] = false
    end
end

RegisterNetEvent('pw_npcdrugs:client:saleConfirmed')
AddEventHandler('pw_npcdrugs:client:saleConfirmed', function(awarded, sold)
    exports.pw_notify:SendAlert('inform', 'Drop-off confirmed ($'..awarded..' for '..sold..' bags)', 5000)
    methQty = methQty - sold
    GoToNext()
    processingSale = false
end)

function WaitMethKey(key, target)
    Citizen.CreateThread(function()
        while waitingMethKey == key do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then -- E
                if key == 'clerk' then
                    PW.TriggerServerCallback('pw_npcdrugs:server:checkMethCooldown', function(onCd)
                        if not onCd or selling == 'meth' then
                            OpenClerkMenu()
                        else
                            exports.pw_notify:SendAlert('error', 'There\'s no more meth for you, crackhead', 4000)
                        end
                    end)
                elseif key == 'dropoff' then
                    if not processingSale then
                        local curAmount = PW.Game.CheckInventory(Config.ItemName['meth'])
                        if curAmount > 0 then
                            processingSale = true
                            TriggerEvent('pw_items:showUsableKeys', false)
                            waitingMethKey = false
                            -- TODO: give/receive anims
                            TriggerServerEvent('pw_npcdrugs:server:processMethSale', methQty, curAmount)
                        else
                            exports.pw_notify:SendAlert('error', 'You do not have any meth with you', 5000)
                        end
                    end
                end
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and GLOBAL_COORDS then
            local dist = #(GLOBAL_COORDS - vector3(Config.MethRun.location.x, Config.MethRun.location.y, Config.MethRun.location.z))
            if dist < 50.0 then
                if not nearStore then
                    NpcMethClerk('spawn')
                end

                if dist < 2.0 then
                    if not waitingMethKey and (not selling or selling == 'meth') then
                        TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Talk"}})
                        waitingMethKey = 'clerk'
                        WaitMethKey(waitingMethKey)
                    end
                elseif waitingMethKey == 'clerk' then
                    TriggerEvent('pw_items:showUsableKeys', false)
                    waitingMethKey = false
                end
            elseif nearStore then
                NpcMethClerk('despawn')
            end
        end
    end
end)