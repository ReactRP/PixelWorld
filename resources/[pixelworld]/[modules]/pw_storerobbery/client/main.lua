PW = nil
characterLoaded, playerData = false, nil
local Stores = {}
local GLOBAL_COORDS, GLOBAL_PED = nil, nil
local nearStore, nearRegister, nearSafe, nearNpc = false, false, false, false

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
            PW.TriggerServerCallback('pw_storerobbery:server:getStores', function(stores)
                Stores = stores
                playerData = data
            end)
        end
    else
        DeleteSafes()
        characterLoaded = false
        playerData = nil
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = GLOBAL_PED
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

RegisterNetEvent('pw_storerobbery:client:resetStore')
AddEventHandler('pw_storerobbery:client:resetStore', function(id, store)
    Stores[id] = store
end)

RegisterNetEvent('pw_storerobbery:client:updateStore')
AddEventHandler('pw_storerobbery:client:updateStore', function(store, var, state)
    Stores[store][var] = state
end)

RegisterNetEvent('pw_storerobbery:client:updateNpc')
AddEventHandler('pw_storerobbery:client:updateNpc', function(store, ped)
    Stores[store].npcObj = ped
end)

RegisterNetEvent('pw_storerobbery:client:updateRegister')
AddEventHandler('pw_storerobbery:client:updateRegister', function(store, register, var, state)
    Stores[store].robbery.registers[register][var] = state
    if nearStore == store and nearRegister == register then
        nearRegister = false
        TriggerServerEvent('pw_items:server:showUsable', false)
    end
end)

RegisterNetEvent('pw_storerobbery:client:updateSafe')
AddEventHandler('pw_storerobbery:client:updateSafe', function(store, var, state)
    Stores[store].robbery.safe[var] = state
    if nearStore == store and nearSafe then
        nearSafe = false
        TriggerEvent('pw_drawtext:hideNotification')
    end
end)

RegisterNetEvent('pw_storerobbery:client:resetSafe')
AddEventHandler('pw_storerobbery:client:resetSafe', function(store, safe)
    Stores[store].robbery.safe = safe
end)

RegisterNetEvent('pw_storerobbery:client:usedLockpick')
AddEventHandler('pw_storerobbery:client:usedLockpick', function(data)
    if nearStore and Stores[nearStore].clerkCooldown and nearRegister then
        if not Stores[nearStore].robbery.registers[nearRegister].cooldown and not Stores[nearStore].robbery.registers[nearRegister].robbing then
            local curStore, curRegister = nearStore, nearRegister
            TriggerServerEvent('pw_storerobbery:server:updateRegister', curStore, curRegister, 'robbing', true)
            TriggerEvent('pw_clicker:client:startGame', 6, function(success)
                if success then
                    TriggerServerEvent('pw_storerobbery:server:awardRegisters', curStore, curRegister)
                else
                    TriggerServerEvent('pw_storerobbery:server:updateRegister', curStore, curRegister, 'robbing', false)
                    TriggerServerEvent('pw_storerobbery:server:updateRegister', curStore, curRegister, 'cooldown', true)
                    TriggerServerEvent('pw_storerobbery:server:removeItem', data)
                end
            end)
        end
    end
end)

function SafeCrack(store)
    TriggerServerEvent('pw_storerobbery:server:updateSafe', store, 'robbing', true)
    TriggerEvent('pw_lockpick2:client:startGame', Stores[store].robbery.safe.code, function(success)
        if success then
            TriggerServerEvent('pw_storerobbery:server:awardSafe', store)
        else
            TriggerServerEvent('pw_storerobbery:server:updateSafe', store, 'robbing', false)
            TriggerServerEvent('pw_storerobbery:server:updateSafe', store, 'cooldown', true)
        end
    end)
end

function SpawnNpc(store)
    local npcObj = GetHashKey(Config.Peds[math.random(1,#Config.Peds)])
    while not HasModelLoaded(npcObj) do
        RequestModel(npcObj)
        Wait(10)
    end

    if Stores[store].npcObj ~= nil and DoesEntityExist(NetToPed(Stores[store].npcObj)) then
        DeleteEntity(NetToPed(Stores[store].npcObj))
        TriggerServerEvent('pw_storerobbery:server:updateNpc', store, nil)
    end

    local pedObj = CreatePed(2, npcObj, Stores[store].robbery.npc.x, Stores[store].robbery.npc.y, Stores[store].robbery.npc.z, Stores[store].robbery.npc.h, true, true)
    SetEntityAsMissionEntity(pedObj, true, true)
    SetBlockingOfNonTemporaryEvents(pedObj, true)
    SetPedFleeAttributes(pedObj, 0, 0)
    TriggerServerEvent('pw_storerobbery:server:updateNpc', store, PedToNet(pedObj))
    TriggerServerEvent('pw_storerobbery:server:updateStore', store, 'spawningNpc', false)
end

function SpawnSafe(store)
    local safeObj = Stores[store].robbery.safe.hash --"p_v_43_safe_s"
    while not HasModelLoaded(safeObj) do
        RequestModel(safeObj)
        Wait(10)
    end

    if Stores[store].robbery.safe.obj ~= nil and DoesEntityExist(Stores[store].robbery.safe.obj) then
        DeleteEntity(Stores[store].robbery.safe.obj)
        Stores[store].robbery.safe.obj = nil
    end

    Stores[store].robbery.safe.obj = CreateObjectNoOffset(safeObj, Stores[store].robbery.safe.x, Stores[store].robbery.safe.y, Stores[store].robbery.safe.z, 0, 1, 1)
    SetEntityAsMissionEntity(Stores[store].robbery.safe.obj, true, true)
    FreezeEntityPosition(Stores[store].robbery.safe.obj, true)
    SetEntityHeading(Stores[store].robbery.safe.obj, Stores[store].robbery.safe.h)
end

function DeleteSafes()
    for k,v in pairs(Stores) do
        if v.robbery ~= nil then
            if v.robbery.safe.obj ~= nil and DoesEntityExist(v.robbery.safe.obj) then
                DeleteEntity(v.robbery.safe.obj)
                Stores[k].robbery.safe.obj = nil
            end
        end
    end
end

function DeleteSafe(store)
    if Stores[store].robbery.safe.obj ~= nil and DoesEntityExist(Stores[store].robbery.safe.obj) then
        DeleteEntity(Stores[store].robbery.safe.obj)
        Stores[store].robbery.safe.obj = nil
    end
end

function CheckAiming(store)
    local storePed = NetToPed(Stores[store].npcObj)
    timeout = 1000
    while not DoesEntityExist(storePed) do
        if timeout <= 0 then
            return
        else
            timeout = timeout - 100
            storePed = NetToPed(Stores[store].npcObj)
            Wait(100)
        end
    end

    if not IsPedFatallyInjured(storePed) then
        local aiming = false
        Citizen.CreateThread(function()
            while nearNpc == store do
                if IsPlayerFreeAimingAtEntity(PlayerId(), storePed) then
                    if IsPedArmed(GLOBAL_PED, 7) and IsPedArmed(GLOBAL_PED, 5) then
                        if not aiming and not Stores[store].robbing and not Stores[store].clerkCooldown then
                            TriggerServerEvent('pw_storerobbery:server:startRobbery', store)
                            aiming = true
                            TaskHandsUp(storePed, -1, GLOBAL_PED, -1, true)
                            Wait(1500)
                            Citizen.CreateThread(function()
                                while aiming and Stores[store].clerkMoney > 0 do
                                    if Stores[store].paymentsLeft > 0 then
                                        TriggerServerEvent('pw_storerobbery:server:payClerk', store)
                                    end
                                    Citizen.Wait(Config.ClerkMoneyDelay * 1000)
                                end
                            end)
                        end
                    elseif aiming then
                        NpcFlee(storePed, store)
                        aiming = false
                    end
                elseif aiming then
                    Citizen.Wait(2000)
                    if not IsPlayerFreeAimingAtEntity(PlayerId(), storePed) then
                        NpcFlee(storePed, store)
                        aiming = false
                    end
                end
                Citizen.Wait(50)
            end
        end)
    end
end

function NpcFlee(ped, store)
    TaskSmartFleePed(ped, GLOBAL_PED, 100.0, -1, true, true)
    ClearPedTasks(ped)
    Citizen.SetTimeout(20000, function()
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end)
end

function WaitingKey()
    Citizen.CreateThread(function()
        while nearSafe do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                SafeCrack(nearStore)
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and GLOBAL_COORDS then
            for k,v in pairs(Stores) do
                if v.robbery ~= nil then
                    local dist = #(GLOBAL_COORDS - vector3(v.shop_coords.x, v.shop_coords.y, v.shop_coords.z))
                    if dist <= 30.0  then
                        if not nearStore then
                            nearStore = k
                            if v.robbery.safe.obj == nil and not v.hasSafe then
                                SpawnSafe(k)
                            end
                            if not v.npcSpawned and not v.spawningNpc then
                                TriggerServerEvent('pw_storerobbery:server:updateStore', k, 'spawningNpc', true)
                                SpawnNpc(k)
                            end
                        end
                    elseif dist > 30.0 and v.robbery.safe.obj ~= nil then
                        DeleteSafe(k)
                        if nearStore == k then
                            nearStore = false
                        end
                    elseif dist > 30.0 and nearStore == k then
                        nearStore = false
                    end

                    if dist < 3.0 then
                        if not nearNpc or nearNpc ~= k then
                            nearNpc = k
                            if not v.clerkCooldown then
                                CheckAiming(k)
                            end
                        end
                    elseif nearNpc == k then
                        nearNpc = false
                    end

                    if v.clerkCooldown and nearStore == k then
                        for i = 1, #v.robbery.registers do
                            local regDist = #(GLOBAL_COORDS - vector3(v.robbery.registers[i].x, v.robbery.registers[i].y, v.robbery.registers[i].z))
                            if regDist <= 1.0 then
                                if not nearRegister and not v.robbery.registers[i].robbing and not v.robbery.registers[i].cooldown then
                                    nearRegister = i
                                    TriggerServerEvent('pw_items:server:showUsable', true, {"lockpick"})
                                elseif nearRegister == i and (v.robbery.registers[i].robbing or v.robbery.registers[i].cooldown) then
                                    nearRegister = false
                                    TriggerServerEvent('pw_items:server:showUsable', false)
                                end
                            elseif regDist > 1.0 and nearRegister == i then
                                nearRegister = false
                                TriggerServerEvent('pw_items:server:showUsable', false)
                            end
                        end
                    end

                    if v.clerkCooldown and not v.robbery.safe.cooldown and not v.robbery.safe.robbing then
                        local safeDist = #(GLOBAL_COORDS - vector3(v.robbery.safe.x, v.robbery.safe.y, v.robbery.safe.z))
                        if safeDist < 2.0 then
                            if not nearSafe then
                                nearSafe = true
                                TriggerEvent('pw_drawtext:showNotification', { title = "Store Safe", message = "<b><span style='font-size:18px'>[ <span class='text-danger'>E</span> ] <span class='text-primary'>Insert Combination</span></span></b>", icon = "fad fa-dollar-sign" })
                                WaitingKey()
                            elseif nearSafe and (v.robbery.safe.cooldown or v.robbery.safe.robbing) then
                                nearSafe = false
                                TriggerEvent('pw_drawtext:hideNotification')
                            end
                        elseif nearSafe then
                            nearSafe = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                    end
                end
            end
        end
    end
end)

---- DEV PURPOSES ONLY
--[[ function safe()
    local playerPed = PlayerPedId()

    local thermalObj = -1251197000-- GetHashKey("p_v_43_safe_s") -- 
    while not HasModelLoaded(thermalObj) do
        RequestModel(thermalObj)
        Wait(10)
    end

    local objCoords = { ['x'] = -163.33, ['y'] = -241.02, ['z'] = 43.94, ['h'] = 203.74 }
    local x, y, z, h = objCoords.x, objCoords.y, objCoords.z, objCoords.h
    local thermal = CreateObjectNoOffset(thermalObj, x, y, z, 1, 1, 1)
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsControlJustPressed(0, 38) then
            safe()
        end
    end
end) ]]