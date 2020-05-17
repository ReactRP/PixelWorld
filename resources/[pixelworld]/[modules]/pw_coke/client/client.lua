RegisterNetEvent('instance:onEnter')
RegisterNetEvent('instance:onLeave')
RegisterNetEvent('instance:onClose')
RegisterNetEvent('pw_coke:SyncPlant')
RegisterNetEvent('pw_coke:UseCokeSeed')
RegisterNetEvent('pw_coke:UseItem')
RegisterNetEvent('pw_coke:UseBag')
RegisterNetEvent('pw_coke:UseRollingPapers')

local showing = false
local MFD = MF_CokePlant

PW = nil
characterLoaded, playerData = false, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework)
            PW = framework
        end)
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
            Citizen.CreateThread(function(...) MFD:Awake(...); end)
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
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then playerData.job = data end
end)

function MFD:Start()
    self.Plants = {}
    self.timer = GetGameTimer()
    PW.TriggerServerCallback('pw_coke:GetLoginData', function(plants)
        self.Plants = plants or {}
        for k = 1, #self.Plants, 1 do
            local v = self.Plants[k]
            if v and not v.Instance then
                local hk = GetHashKey(self.Objects[v.Stage])
                PW.Streaming.RequestModel(hk)
                local zOffset = self:GetPlantZ(v)
                v.Object = CreateObject(hk, v.Position.x, v.Position.y,
                                        v.Position.z + zOffset, false, false,
                                        false)
                SetEntityAsMissionEntity(v.Object, true)
                FreezeEntityPosition(v.Object, true)
            end
        end
        self.iR = true
    end)
    while not self.iR do Citizen.Wait(1); end
    if self.dS and self.cS then
        Citizen.CreateThread(function(...) self:PerHalfSecThread(...); end)
        Citizen.CreateThread(function(...) self:PerSecThread(...); end)
        Citizen.CreateThread(function(...) self:FiveSecThread(...); end)
        Citizen.CreateThread(function(...) self:PerFrameThread(...); end)
    end
end

function MFD:GetLoginData() end

function MFD:PerSecThread()
    while true do
        Wait(1000)
        if characterLoaded then self:GrowthHandlerFast() end
    end
end

function MFD:FiveSecThread()
    local tick = 0
    while true do
        Wait(5000)
        if characterLoaded then
            tick = tick + 1
            self:GrowthHandlerSlow()
            if tick % 4 == 0 then self:SyncCheck(); end
        end
    end
end

function MFD:PerFrameThread()
    if not self then return; end
    while true do
        Citizen.Wait(1)
        if characterLoaded then
            self:InputHandler()
            self:DrawCurText()
        end
    end
end

function MFD:PerHalfSecThread()
    if not self then return; end
    while true do
        Citizen.Wait(500)
        if characterLoaded then self:TextHandler() end
    end
end

function MFD:InputHandler()
    if not self.Plants then return; end
    if not #self.Plants then return; end
    if self.CanHarvest or self.PolText then
        if Utils:GetKeyPressed("E") and (GetGameTimer() - self.timer) > 200 and
            not self.CurInteracting then
            Citizen.CreateThread(function()
                self.CurInteracting = true
                local plyPed = GLOBAL_PED
                TaskTurnPedToFaceEntity(plyPed, self.Plants[self.CurKey].Object,
                                        -1)
                Citizen.Wait(1000)
                local chooseLabel
                if self.CanHarvest then
                    chooseLabel = "Harvesting"
                else
                    chooseLabel = "Destroying"
                end
                exports['pw_progbar']:Progress(
                    {
                        name = "harvestingCoke",
                        duration = 20000,
                        label = chooseLabel,
                        useWhileDead = false,
                        canCancel = false,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        },
                        animation = {}
                    }, function(status)
                        if not status then
                            Wait(1000)
                            ClearPedTasksImmediately(plyPed)

                            local syncData = (self.CanHarvest or self.PolText)
                            self.timer = GetGameTimer()

                            local nearPlant
                            Citizen.CreateThread(
                                function()
                                    repeat
                                        nearPlant =
                                            FindNearest(chooseLabel, syncData,
                                                        0.65)
                                        SetEntityAsMissionEntity(nearPlant, true)
                                        FreezeEntityPosition(nearPlant, false)
                                        DeleteObject(nearPlant)
                                        Citizen.Wait(1)
                                    until nearPlant == 0
                                end)

                            self:Sync(self.Plants[self.CurKey], true)
                            self.Plants[self.CurKey] = false
                            self.CanHarvest = false
                            self.PolText = false
                            self:TextHandler()
                            self.CurInteracting = false
                            TriggerEvent('pw_coke:client:showing', false)
                            MFD:processNUI()
                        end
                    end)
            end)
        end
    end
end

function FindNearest(type, table, distance)
    local tempTable = {}
    local sendNear

    if type == "Searching" then
        tempTable = table
    elseif type == "Destroying" then
        tempTable = table.closest.Position
    else
        tempTable = table.Position
    end

    for _, v in pairs(MFD.Objects) do
        sendNear = GetClosestObjectOfType(tempTable.x, tempTable.y, tempTable.z,
                                          distance, GetHashKey(v), false, false,
                                          false)
        if sendNear > 0 then return sendNear end
    end

    for _, v in pairs(MFD.CheckForCollision) do
        sendNear = GetClosestObjectOfType(tempTable.x, tempTable.y, tempTable.z,
                                          distance, GetHashKey(v), false, false,
                                          false)
        if sendNear > 0 then return sendNear end
    end

    return sendNear
end

function MFD:processNUI(thisPlant)
    if thisPlant == nil then SendNUIMessage({action = "hidePlant"}) end
end

function MFD:DrawCurText()
    if not self.CurText then return; end
    local closest = self.CurText.closest

    local plyPos = GLOBAL_COORDS
    local dist = #(plyPos - vector3(closest.Position.x, closest.Position.y, closest.Position.z))
    if dist > self.InteractDist then
        self.CurText = false;
        self:TextHandler()
        return;
    end
    MFD:processNUI(closest)
    DrawMarker(27, closest.Position.x, closest.Position.y,
               closest.Position.z - 0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.55,
               0.55, 0.55, 0, 255, 0, 100, false, true, 2, true, nil, nil, false)
end

function MFD:TextHandler()
    if not self.Plants then
        self.CanHarvest = false;
        self.CurText = false;
        self.PolText = false;
        self.CurKey = false;
        return;
    end
    if not #self.Plants then
        self.CanHarvest = false;
        self.CurText = false;
        self.PolText = false;
        self.CurKey = false;
        return;
    end
    if showing then return; end
    local plyPos = GLOBAL_COORDS
    local closest, closestDist, closestKey
    for k = 1, #self.Plants, 1 do
        local v = self.Plants[k]
        if v then
            if (self.Instance and v.Instance and v.Instance == self.Instance) or
                (not self.Instance and not v.Instance) then
                local dist = #(plyPos - vector3(v.Position.x, v.Position.y, v.Position.z))
                if not closest or dist < closestDist then
                    closestDist = dist
                    closest = v
                    closestKey = k
                end
            end
        end
    end

    if not closest then
        self.CanHarvest = false;
        self.CurText = false;
        self.PolText = false;
        self.CurKey = false;
        return;
    end
    if closestDist > self.InteractDist then
        self.CanHarvest = false;
        self.CurText = false;
        self.PolText = false;
        self.CurKey = false;
        TriggerEvent('pw_coke:client:showing', false)
        MFD:processNUI()
        return;
    end

    local strA
    if closest.Gender == "Male" then
        strA = "[ Male ] "
    else
        strA = "[ Female ] "
    end

    local colGrowth = self:GetValColour(closest.Growth)
    strA = strA .. colGrowth .. math.ceil(closest.Growth) .. "~s~% Growth ] " -- 
    if closest.Growth >= 99.99 then
        local plyId = playerData.cid

        if (closest.Owner == plyId and playerData.job.name ~= self.PoliceJobLabel) or
            (closest.Owner == plyId and playerData.job.name ==
                self.PoliceJobLabel and not playerData.job.duty) then
            strA = strA .. "~s~[ ~y~Press ~s~[ ~g~E ~s~] ~y~to harvest ~s~] "
            self.CanHarvest = closest
        else
            self.CanHarvest = false
        end
    end
    local colQual = self:GetValColour(closest.Quality)
    strA = strA .. colQual .. "Quality~s~ ]"

    local colFert = self:GetValColour(closest.Food)
    local strB = colFert .. "Fertilizer~s~ ] "
    local colWater = self:GetValColour(closest.Water)
    strB = strB .. colWater .. "Water~s~ ]"

    self.CurText = {closest = closest, strA = strA, strB = strB}
    if (playerData.job.name == self.PoliceJobLabel and playerData.job.duty) then
        self.PolText = {
            closest = closest,
            strA = "~s~[ ~y~Press ~s~[ ~g~E ~s~] ~y~to destroy ~s~] "
        }
    end
    self.CurKey = closestKey
    TriggerEvent('pw_coke:client:showing', true)
    SendNUIMessage({
        action = "showPlant",
        info = closest,
        messagePol = self.PolText,
        canHarvest = self.CanHarvest
    })
end

function MFD:GetValColour(v)
    if not v then return "[ ~s~"; end
    if v >= 95.0 then
        return "[ ~p~"
    elseif v >= 80.0 then
        return "[ ~b~"
    elseif v >= 60.0 then
        return "[ ~g~"
    elseif v >= 40.0 then
        return "[ ~y~"
    elseif v >= 20.0 then
        return "[ ~o~"
    elseif v >= 0.0 then
        return "[ ~r~"
    else
        return "[ ~s~"
    end
end

function MFD:GetQualColour(v)
    if not v then return "~s~"; end
    if v >= 5.0 then
        return "~b~"
    elseif v >= 4.0 then
        return "~g~"
    elseif v >= 3.0 then
        return "~y~"
    elseif v >= 2.0 then
        return "~o~"
    elseif v >= 1.0 then
        return "~y~"
    elseif v >= 0.0 then
        return "~r~"
    else
        return "~s~"
    end
end

function MFD:GrowthHandlerSlow()
    if not self.Plants then return; end
    if not #self.Plants then return; end
    local plyId = playerData.cid
    for k = 1, #self.Plants, 1 do
        local v = self.Plants[k]
        if v and v.Owner and v.Owner == plyId then
            self:GrowPlantSlow(v, k)
        end
    end
end

function MFD:GrowPlantSlow(plant, key)
    if not self.Plants then return; end
    if not self.Plants[key] then return; end
    if self.Plants[key] ~= plant then return; end

    local divider = 95.0 / #self.Objects
    local targetStage = math.max(1, math.floor(plant.Growth / divider))

    if plant.Stage ~= math.min(targetStage, 7) then
        plant.Stage = targetStage
        SetEntityAsMissionEntity(plant.Object, false)
        FreezeEntityPosition(plant.Object, false)

        local hk = GetHashKey(self.Objects[plant.Stage]) -- Utils.GetHashKey(self.Objects[plant.Stage])
        -- local load    = Utils.LoadModel(hk,true) 
        PW.Streaming.RequestModel(hk)
        local zOffset = self:GetPlantZ(plant)
        DeleteObject(plant.Object)
        plant.Object = CreateObject(hk, plant.Position.x, plant.Position.y,
                                    plant.Position.z + zOffset, false, false,
                                    false)
        SetEntityAsMissionEntity(plant.Object, true)
        FreezeEntityPosition(plant.Object, true)

        self:Sync(plant, false)
    end
end

function MFD:GrowthHandlerFast()
    if not self.Plants then return; end
    if not #self.Plants then return; end
    local plyId = playerData.cid
    for k = 1, #self.Plants, 1 do
        local v = self.Plants[k]
        if v and v.Owner and v.Owner == plyId then
            self:GrowPlantFast(v, k)
        end
    end
end

function MFD:GrowPlantFast(plant, key)
    if not self.Plants then return; end
    if not self.Plants[key] then return; end
    if self.Plants[key] ~= plant then return; end

    plant.Food = math.max(0.0, plant.Food - self.FoodDrainSpeed)
    plant.Water = math.max(0.0, plant.Water - self.WaterDrainSpeed)

    if plant.Food > 80.0 and plant.Water > 80.0 then
        plant.Quality = math.min(100.0,
                                 plant.Quality + (self.QualityGainSpeed * 2))
        plant.Growth =
            math.min(100.0, plant.Growth + (self.GrowthGainSpeed * 2))
    elseif plant.Food > 50 and plant.Water > 50 then
        plant.Quality = math.min(100.0,
                                 plant.Quality + (self.QualityGainSpeed / 2))
        plant.Growth = math.min(100.0, plant.Growth + self.GrowthGainSpeed)
    elseif plant.Food > 0.5 and plant.Water > 0.5 then
        plant.Growth =
            math.min(100.0, plant.Growth + (self.GrowthGainSpeed / 2))
    end

    if (plant.Food + 20.0) < plant.Quality or (plant.Water + 20.0) <
        plant.Quality then
        plant.Quality = math.max(0.0, plant.Quality - self.QualityDrainSpeed)
    end
end

function MFD:SyncCheck()
    if not self.Plants then return; end
    local plyPed = GLOBAL_PED
    local plyPos = GLOBAL_COORDS
    local closestPos = GLOBAL_COORDS

    local plys = PW.Game.GetPlayers()
    local closestPly, closestDist
    for k = 1, #plys, 1 do
        local ped = GetPlayerPed(plys[k])
        if ped ~= plyPed then
            local dist = #(plyPos - GetEntityCoords(ped))
            if not closestPly or dist < closestPly then
                closestDist = dist
                closestPly = ped
            end
        end
    end

    -- if closestDist and closestDist < self.SyncDist then
    for k = 1, #self.Plants, 1 do
        local v = self.Plants[k]
        if v and v.Owner == playerData.cid then self:Sync(v) end
    end
    -- end
end

function MFD:EnterInstance(instance)
    self.Instance = instance.data.owner
    if not self.Plants then return; end
    if not #self.Plants then return; end
    for k = 1, #self.Plants, 1 do
        local v = self.Plants[k]
        if v and v.Instance then
            if v.Instance == self.Instance then
                MFD:SpawnInstance(v, k)
            end
        end
    end
end

function MFD:LeaveInstance(instance)
    if not self.Plants then return; end
    if not #self.Plants then return; end
    self.Instance = false
    for k = 1, #self.Plants, 1 do
        local v = self.Plants[k]
        if v and v.Instance then
            FreezeEntityPosition(self.Plants[k].Object, false)
            SetEntityAsMissionEntity(self.Plants[k].Object, false)
            DeleteObject(self.Plants[k].Object)
            if v.Owner ~= playerData.cid then self.Plants[k] = false end
        end
    end
end

function MFD:SpawnInstance(plant, k)
    if not self.Instance then return; end
    if plant.Instance ~= self.Instance then return; end
    self.Plants = self.Plants or {}
    if self.Plants[k] then
        local hk = GetHashKey(self.Objects[plant.Stage]) -- Utils.GetHashKey(self.Objects[plant.Stage])
        -- local load = Utils.LoadModel(hk,true) 
        PW.Streaming.RequestModel(hk)
        local zOffset = self:GetPlantZ(self.Plants[k])
        self.Plants[k].Object = CreateObject(hk, plant.Position.x,
                                             plant.Position.y,
                                             plant.Position.z + zOffset, false,
                                             false, false)
        FreezeEntityPosition(self.Plants[k].Object, true)
        SetEntityAsMissionEntity(self.Plants[k].Object, true)
    else
        self.Plants[k] = plant
        local hk = GetHashKey(self.Objects[plant.Stage]) -- Utils.GetHashKey(self.Objects[plant.Stage])
        -- local load = Utils.LoadModel(hk,true)  
        PW.Streaming.RequestModel(hk)
        local zOffset = self:GetPlantZ(self.Plants[k])
        self.Plants[k].Object = CreateObject(hk, plant.Position.x,
                                             plant.Position.y,
                                             plant.Position.z + zOffset, false,
                                             false, false)
        FreezeEntityPosition(self.Plants[k].Object, true)
        SetEntityAsMissionEntity(self.Plants[k].Object, true)
    end
end

function MFD:SpawnWorld(plant, k)
    if self.Instance or (not plant or plant.Instance) then return; end
    self.Plants = self.Plants or {}
    if self.Plants[k] then
        local hk = GetHashKey(self.Objects[plant.Stage]) -- Utils.GetHashKey(self.Objects[plant.Stage])
        -- local load = Utils.LoadModel(hk,true)  
        PW.Streaming.RequestModel(hk)
        local zOffset = self:GetPlantZ(self.Plants[k])
        self.Plants[k].Object = CreateObject(hk, plant.Position.x,
                                             plant.Position.y,
                                             plant.Position.z + zOffset, false,
                                             false, false)
        FreezeEntityPosition(self.Plants[k].Object, true)
        SetEntityAsMissionEntity(self.Plants[k].Object, true)
    else
        self.Plants[k] = plant
        local hk = GetHashKey(self.Objects[plant.Stage]) -- Utils.GetHashKey(self.Objects[plant.Stage])
        -- local load = Utils.LoadModel(hk,true)  
        PW.Streaming.RequestModel(hk)
        local zOffset = self:GetPlantZ(self.Plants[k])
        self.Plants[k].Object = CreateObject(hk, plant.Position.x,
                                             plant.Position.y,
                                             plant.Position.z + zOffset, false,
                                             false, false)
        FreezeEntityPosition(self.Plants[k].Object, true)
        SetEntityAsMissionEntity(self.Plants[k].Object, true)
    end
end

function MFD:SyncHandler(plant, delete)
    if not plant and not delete and not characterLoaded then return; end
    local plyPos = GLOBAL_COORDS

    if delete then
        if self.Plants then
            if #self.Plants then
                for k = 1, #self.Plants, 1 do
                    local v = self.Plants[k]
                    if v and v.Position then
                        if (math.floor(v.Position.x) ==
                            math.floor(plant.Position.x)) and
                            (math.floor(v.Position.y) ==
                                math.floor(plant.Position.y)) then
                            DeleteObject(self.Plants[k].Object)
                            self.Plants[k] = false
                            return
                        end
                    end
                end
            end
        end
    else
        local dist = #(plyPos - vector3(plant.Position.x, plant.Position.y, plant.Position.z))
        if dist < self.SyncDist then
            if self.Plants and #self.Plants and #self.Plants > 0 and
                characterLoaded then
                local didSpawn = false
                for k = 1, #self.Plants, 1 do
                    if self.Plants[k] then
                        local v = self.Plants[k]
                        if v then
                            if v.Position.x == plant.Position.x and v.Position.y ==
                                plant.Position.y then
                                if ((v.Instance and self.Instance and
                                    self.Instance == v.Instance) or
                                    (not self.Instance and not v.Instance)) and
                                    plant.Owner ~= playerData.cid then
                                    local zOffset = self:GetPlantZ(plant)
                                    FreezeEntityPosition(self.Plants[k].Object,
                                                         false)
                                    SetEntityAsMissionEntity(
                                        self.Plants[k].Object, false)
                                    DeleteObject(self.Plants[k].Object)
                                    local hk =
                                        GetHashKey(self.Objects[plant.Stage])
                                    PW.Streaming.RequestModel(hk)
                                    self.Plants[k] = plant
                                    self.Plants[k].Object =
                                        CreateObject(hk, plant.Position.x,
                                                     plant.Position.y,
                                                     plant.Position.z + zOffset,
                                                     false, false, false)
                                    FreezeEntityPosition(self.Plants[k].Object,
                                                         true)
                                    SetEntityAsMissionEntity(
                                        self.Plants[k].Object, true)
                                    didSpawn = true
                                else
                                    didSpawn = true
                                end
                            end
                        end
                    end
                end
                if not didSpawn then
                    if self.Instance then
                        self:SpawnInstance(plant, #self.Plants + 1)
                    else
                        self:SpawnWorld(plant, #self.Plants + 1)
                    end
                end
            else
                if self.Instance then
                    if plant.Owner == self.Instance then
                        self:SpawnInstance(plant, 1)
                    end
                else
                    self:SpawnWorld(plant, 1)
                end
            end
        end
    end
end

function MFD:Awake(...)
    while not PW do Citizen.Wait(1); end
    PW.TriggerServerCallback('pw_coke:GetStartData', function(retVal)
        self.dS = true;
        self.cS = retVal;
    end)
    while not self.dS do Citizen.Wait(1); end
    self:Start()
end

function MFD:GetPlantZ(plant)
    if plant.Stage <= 3 then
        return -1.0
    else
        return -1.0
    end
end

function MFD:UseItem(item, seedType, data)
    if seedType == "coke" then
        if not self.Plants then return; end
        if not #self.Plants then return; end
        local closest, closestDist
        for k = 1, #self.Plants, 1 do
            local v = self.Plants[k]
            if v then
                local dist = #(GLOBAL_COORDS - vector3(v.Position.x, v.Position.y, v.Position.z))
                if not closestDist or dist < closestDist then
                    closestDist = dist
                    closest = v
                end
            end
        end
        if not closest or not closestDist then return; end
        if closestDist < self.InteractDist then
            if item.Type == "Water" then
                closest.Water = closest.Water + (item.Quality * 100)
            elseif item.Type == "Food" then
                closest.Food = closest.Food + (item.Quality * 100)
            end
            closest.Quality = closest.Quality + item.Quality

            TriggerServerEvent('pw_coke:RemoveThisSpecificShit', data)
        end

        self:Sync(closest)
        self:TextHandler()
    end
end

function MFD:UseCokeSeed(seed, seedName)
    if not seed then return; end
    self.Plants = self.Plants or {}
    local ply = GLOBAL_PED
    local plyPos = GLOBAL_COORDS
    local k = math.max(1, #self.Plants + 1)
    local hk = GetHashKey(self.Objects[1]) -- Utils.GetHashKey(self.Objects[1])
    local dmin, dmax = GetModelDimensions(hk)
    local pos = GetOffsetFromEntityInWorldCoords(ply, 0, dmax.y * 5, 0)
    local npos = {x = pos.x, y = pos.y, z = plyPos.z}
    local nearPlant = FindNearest("Searching", npos, 0.75)
    if nearPlant > 0 then
        TriggerEvent('pw:notification:SendAlert', {
            type = "error",
            text = "There's already a plant growing nearby"
        })
    else
        if exports['pw_motels']:checkRadius() then
            exports.pw_notify:SendAlert('error',
                                        'You are not allowed to plant seeds near motels',
                                        5000)
        else
            local items = {}
            table.insert(items, {['name'] = 'plantpot', ['qty'] = 1})
            table.insert(items, {['name'] = seedName, ['qty'] = 1})
            TriggerServerEvent('pw_coke:RemoveThisShit', items)
            PW.Streaming.RequestModel(hk)
            local go = CreateObject(hk, npos.x, npos.y, npos.z - 1.0, false,
                                    false, false)
            local frozen = FreezeEntityPosition(go, true)
            local mission = SetEntityAsMissionEntity(go, true)
            self.Plants[k] = seed
            self.Plants[k]["Object"] = go
            self.Plants[k]["Position"] = npos
            self.Plants[k]["Instance"] = (self.Instance or false)
            self.Plants[k]["Owner"] = playerData.cid
            self:Sync(self.Plants[k])

            Utils.ReleaseModel(hk)
            self:TextHandler()
        end
    end
end

function MFD:Sync(plant, delete)
    TriggerServerEvent('pw_coke:SyncPlant', plant, delete)
end

function MFD:UseBag(canUse, msg)
    Citizen.CreateThread(function(...)
        local plyPed = GLOBAL_PED
        if canUse then
            TaskStartScenarioInPlace(plyPed, "PROP_HUMAN_PARKING_METER", 0, true)
            Wait(5000)
            ClearPedTasksImmediately(plyPed)
            exports['pw_notify']:SendAlert('inform', msg)
        else
            exports['pw_notify']:SendAlert('error', msg)
        end
    end)
end

RegisterNetEvent('pw_coke:HandleThisShit')
AddEventHandler('pw_coke:HandleThisShit', function(data)
    if exports.pw_coke:getWeedShowing() then
        TriggerEvent('pw_weed:Use' .. data.item, data)
    elseif exports.pw_weed:getCokeShowing() then
        TriggerEvent('pw_coke:Use' .. data.item, data)
    else
        TriggerServerEvent('pw_coke:GiveThisShit', data)
    end
end)

AddEventHandler('instance:onEnter', function(instance)
    while not MFD.iR do Citizen.Wait(1); end
    MFD:EnterInstance(instance);
end)
AddEventHandler('instance:onLeave', function(instance)
    if MFD.iR then
        MFD:LeaveInstance(instance);
    else
        MFD.Instance = false;
    end
end)
AddEventHandler('pw_coke:UseCokeSeed', function(seed, seedName)
    if MFD.iR then MFD:UseCokeSeed(seed, seedName); end
end)
AddEventHandler('pw_coke:UseItem', function(item, seedType, data)
    if MFD.iR then MFD:UseItem(item, seedType, data); end
end)
AddEventHandler('pw_coke:SyncPlant', function(plant, del)
    if MFD.iR then MFD:SyncHandler(plant, del); end
end)
AddEventHandler('pw_coke:UseBag',
                function(canUse, msg) MFD:UseBag(canUse, msg); end)

RegisterNetEvent('pw_weed:client:showing')
AddEventHandler('pw_weed:client:showing', function(status) showing = status end)

exports('getWeedShowing', function() return showing end)
