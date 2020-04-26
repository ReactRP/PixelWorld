local Houses, spawnedFurniture, displayedFurniture = {}, {}, 0
local inCam, isMoving, movingHouse, isInside, canToggle, toggleMod, pickedFurniture, pickedObj = false, nil, false, false, false, false, false
local showing, inventoryOpened, inCamera, furnMenu, isGangBoss, isGangAuthed = false, false, false, false, false, false
local blips, storeBlips = {}, {}
local ped = 0
local shoppingCart = { ['items'] = {} }
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
PW = nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerLoaded = true
            isGangAuthed = exports.pw_gangs:checkBoss(0)
            isGangBoss = (isGangAuthed and exports.pw_gangs:checkBoss(4) or false)
            CreateStoreBlips()
        else
            PW.TriggerServerCallback('pw_properties:server:sendHousesToRE', function(housesTbl)
                Houses = housesTbl
                playerData = data
                CreateBlips()
            end)
            while playerData == nil do Wait(10); end
        end
    else
        playerLoaded = false
        playerData = nil
        HideNuis()
        if isInside then
            DeleteFurniture(isInside)
            if toggleMod then ManageEditMod(); end
            if pickedObj then StopMoving(nil, pickedObj); end
            if furnMenu then TriggerEvent('pw_furn:client:closeNui'); end
            pickedFurniture = false
        end
        StopMoving()
        TriggerEvent('pw_properties:client:deleteDisplayed')
        DeleteBlips()
        DeleteStoreBlips()
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
    end    
end)

RegisterNetEvent('pw:setGang')
AddEventHandler('pw:setGang', function(data)
    if characterLoaded and playerData then
        playerData.gang = data
        isGangAuthed = exports.pw_gangs:checkBoss(0)
        isGangBoss = (isGangAuthed and exports.pw_gangs:checkBoss(4) or false)
        RefreshBlips()
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        if spawnedFurniture ~= nil and #spawnedFurniture > 0 then
            for k,v in pairs(spawnedFurniture) do
                for j,b in pairs(spawnedFurniture[k]) do
                    FreezeEntityPosition(b.obj, false)
                    SetEntityAsMissionEntity(b.obj, true, true)    
                    DeleteEntity(b.obj)
                    spawnedFurniture[k][j] = nil
                end
            end
        end
    end
end)

RegisterNetEvent('pw:playerDied')
AddEventHandler('pw:playerDied', function()
    if isInside then
        if toggleMod then ManageEditMod(); end
        if pickedObj then StopMoving(nil, pickedObj); end
        if furnMenu then TriggerEvent('pw_furn:client:closeNui'); end
        pickedFurniture = false
    end
end)

RegisterNetEvent('pw_properties:client:updateCams')
AddEventHandler('pw_properties:client:updateCams', function(house, cams)
    Houses[house].camSettings = cams
    if playerData.cid == Houses[house].ownerCid then OpenOptionsMenu(house); end
end)

RegisterNetEvent('pw_properties:client:setSellPrice')
AddEventHandler('pw_properties:client:setSellPrice', function(house, price)
    Houses[house].price = price
    if showing == house..'-entrance' then
        showing = false
        sendNUI("hide", "frontdoor")
    end
end)

RegisterNetEvent('pw_properties:leftHQ')
AddEventHandler('pw_properties:leftHQ', function(prop)
    if isInside == prop then
        if toggleMod then ManageEditMod(); end
        if pickedObj then StopMoving(nil, pickedObj); end
        if furnMenu then TriggerEvent('pw_furn:client:closeNui'); end
        DeleteFurniture(prop)
        isInside = false
        canToggle = false
        pickedFurniture, pickedObj = false, nil
    end
end)

RegisterNetEvent('pw_properties:spawnedInHome')
AddEventHandler('pw_properties:spawnedInHome', function(house, toggle)
    if not isInside then
        isInside = house
        canToggle = true
        if toggle then
            canToggle = (toggle == Houses[house].gang_id)
        end
        if canToggle then exports.pw_notify:SendAlert('inform', 'Press <b><span style="color:#FFFF00">F</span></b> to toggle furniture edit mode', 5000); end
        while #Houses == 0 do Wait(10); end
        SpawnFurniture(isInside)
    end
end)

RegisterNetEvent('pw_properties:client:loadHouses')
AddEventHandler('pw_properties:client:loadHouses', function(housesTable)
    Houses = housesTable
end)

RegisterNetEvent('pw_properties:client:ownerMenuCheck')
AddEventHandler('pw_properties:client:ownerMenuCheck', function()
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    local distMenu
    for k,v in pairs(Houses) do
        local isAuthed = exports.pw_gangs:checkBoss(v.gang_id)
        if isAuthed or playerData.cid == v.ownerCid or playerData.cid == v.rentor then
            distMenu = #(pedCoords - vector3(v.ownerMenu.x, v.ownerMenu.y, v.ownerMenu.z))
            if distMenu < 3.0 then
                if isAuthed or playerData.cid == v.ownerCid then
                    OpenHouseMenu(k)
                else
                    OpenTenantMenu(k)
                end
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:giveKey')
AddEventHandler('pw_properties:client:giveKey', function()
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    for k,v in pairs(Houses) do
        local distEntrance = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
        if distEntrance < 2.0 then
            if PW ~= nil then
                local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
                if closestPlayer ~= -1 and closestDistance <= 3.0 and closestDistance >= 0.01 then
                GetPlayerServerId(closestPlayer)
                    TriggerServerEvent('pw_keys:giveKey', 'Property', k, 1)
                else
                    exports.pw_notify:SendAlert('error', 'You are not near anyone to give the key to.')
                end
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:enterCheck')
AddEventHandler('pw_properties:client:enterCheck', function(type, house)
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS

    if house ~= nil then
        if type == "exit" and CheckMoving() then
            if not Houses[house].doorStatus or Houses[house].brokenInto == 'police' then
                TPHouse(house, "exit")
                if toggleMod then ManageEditMod(); end
            else
                exports.pw_notify:SendAlert('error', 'Door locked')
            end
        elseif type == "enter" and not isMoving then

            if not Houses[house].doorStatus then
                TPHouse(house, "enter")
            else
                exports.pw_notify:SendAlert('error', 'Door locked')
            end
        end
    else
        for k,v in pairs(Houses) do
            if type == "enter" and CheckMoving() then
                local distEntrance = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
                if distEntrance < 3.0 then
                    if not v.doorStatus then
                        TPHouse(k, "enter")
                    else
                        exports.pw_notify:SendAlert('error', 'Door locked')
                    end
                    break
                end
            elseif CheckMoving() then
                local distExit = #(pedCoords - vector3(v.exit.x, v.exit.y, v.exit.z))
                if distExit < 3.0 then
                    if not v.doorStatus or Houses[house].brokenInto == 'police' then
                        TPHouse(k, "exit")
                        if toggleMod then ManageEditMod(); end
                    else
                        exports.pw_notify:SendAlert('error', 'Door locked')
                    end
                    break
                end
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:frontDoorRent')
AddEventHandler('pw_properties:client:frontDoorRent', function()
    if CheckMoving() then
        local pedCoords = GLOBAL_COORDS
        for k,v in pairs(Houses) do
            local distExit = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
            if distExit < 3.0 then
                if v.propertyRented and playerData.cid == v.ownerCid then
                    OpenHouseMenu(k, true)
                else
                    exports.pw_notify:SendAlert('error', (not v.propertyRented and 'This house isn\'t rented' or 'This house doesn\'t belong to you'))
                end
                break
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:rearenterCheck')
AddEventHandler('pw_properties:client:rearenterCheck', function(type, house)
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    if house ~= nil then
        if type == "exit" and CheckMoving() then
            if not Houses[house].doorStatus or Houses[house].brokenInto == 'police' then
                TPHouseR(house, "exit")
                if toggleMod then ManageEditMod(); end
            else
                exports.pw_notify:SendAlert('error', 'Door locked')
            end
        elseif type == "enter" and CheckMoving() then
            if not Houses[house].doorStatus then
                TPHouseR(house, "enter")
            else
                exports.pw_notify:SendAlert('error', 'Door locked')
            end
        end
    else
        for k,v in pairs(Houses) do
            if type == "enter" and CheckMoving() then
                local distEntrance = #(pedCoords - vector3(v.exitEntrance.x, v.exitEntrance.y, v.exitEntrance.z))
                if distEntrance < 3.0 then
                    if not v.doorStatus then
                        TPHouseR(k, "enter")
                    else
                        exports.pw_notify:SendAlert('error', 'Door locked')
                    end
                    break
                end
            elseif CheckMoving() then
                local distExit = #(pedCoords - vector3(v.exitInside.x, v.exitInside.y, v.exitInside.z))
                if distExit < 3.0 then
                    if not v.doorStatus or Houses[house].brokenInto == 'police' then
                        TPHouseR(k, "exit")
                        if toggleMod then ManageEditMod(); end
                    else
                        exports.pw_notify:SendAlert('error', 'Door locked')
                    end
                    break
                end
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:changeLock')
AddEventHandler('pw_properties:client:changeLock', function(house, status)
    Houses[house].doorStatus = status
end)

RegisterNetEvent('pw_properties:client:updateOptions')
AddEventHandler('pw_properties:client:updateOptions', function(house, option, value, src, lockpick)
    Houses[house][option] = value
    if not lockpick and GetPlayerFromServerId(src) == PlayerId() then OpenOptionsMenu(house); end
end)

RegisterNetEvent('pw_properties:client:updateBroken')
AddEventHandler('pw_properties:client:updateBroken', function(house, state)
    Houses[house].brokenInto = state
end)

RegisterNetEvent('pw_properties:client:lockCheck')
AddEventHandler('pw_properties:client:lockCheck', function(lockpicking, house, side, owner)
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    if lockpicking and house and side then
        if not Houses[house].brokenInto then
            TriggerServerEvent('pw_properties:server:toggleBroken', house, 'theft')
            Citizen.CreateThread(function()
                Citizen.Wait(Config.HouseBroken * 1000)
                TriggerServerEvent('pw_properties:server:toggleBroken', house, false)
            end)
            TriggerServerEvent('pw_properties:server:toggleAutoLock', { ['house'] = house, ['state'] = false }, true)
            TriggerServerEvent('pw_properties:server:lockHouse', house, false)
            Wait(20)
            SendNUIMessage({
                action = "updateLock",
                messages = Houses[house],
                player = playerData,
                toggle = false
            })        
            TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houselock', 0.05, {x = Houses[house][side].x, y = Houses[house][side].y, z = Houses[house][side].z})
            exports.pw_notify:SendAlert('inform', 'Lock picked')
            if side == 'entrance' then
                TPHouse(house, 'enter')
            else
                TPHouseR(house, 'enter')
            end
            Citizen.CreateThread(function()
                Citizen.Wait(Config.AlarmTrigger * 1000)
                if Houses[house].alarm then
                    if owner then
                        TriggerServerEvent('pw_properties:server:alertOwner', owner, house)
                    end
                    --TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'housealarm', 0.05, {x = Houses[house][side].x, y = Houses[house][side].y, z = Houses[house][side].z})
                    TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31A', Houses[house].name, playerData.sex )
                end
            end)
        else
            exports.pw_notify:SendAlert('error', 'This house was broken into too recently.', 5000)
        end
    else
        for k,v in pairs(Houses) do
            local distEntrance = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
            if distEntrance < 3.0 then
                PW.TriggerServerCallback('pw_keys:checkKeyHolder', function(allowed)
                    if allowed then
                        local status = not v.doorStatus
                        TriggerServerEvent('pw_properties:server:lockHouse', k, status)
                        Wait(20)
                        SendNUIMessage({
                            action = "updateLock",
                            messages = v,
                            player = playerData,
                            toggle = status
                        })
                        local hStatus = "unlocked"
                        if not v.doorStatus then
                            hStatus = "locked"
                        end
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houselock', 0.05, {x = v.entrance.x, y = v.entrance.y, z = v.entrance.z})
                        exports.pw_notify:SendAlert('inform', 'Door '..hStatus)
                    else
                        exports.pw_notify:SendAlert('error', 'You do not have a key for this house')
                    end
                end, 'Property', k) 
                break
            else
                local distExit = #(pedCoords - vector3(v.exit.x, v.exit.y, v.exit.z))
                if distExit < 3.0 then
                    PW.TriggerServerCallback('pw_keys:checkKeyHolder', function(allowed)
                        if allowed then
                            local status = not v.doorStatus
                            TriggerServerEvent('pw_properties:server:lockHouse', k, status)
                            Wait(20)
                            SendNUIMessage({
                                action = "updateLock",
                                messages = v,
                                player = playerData,
                                toggle = status
                            })
                            local hStatus = "unlocked"
                            if not v.doorStatus then
                                hStatus = "locked"
                            end
                            TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houselock', 0.05, {x = v.exit.x, y = v.exit.y, z = v.exit.z})
                            exports.pw_notify:SendAlert('inform', 'Door '..hStatus)
                        else
                            exports.pw_notify:SendAlert('error', 'You do not have a key for this house')
                        end
                    end, 'Property', k)  
                    break
                end
            end
        end
    end
end)

-- LOCKPICKING STUFF
RegisterNetEvent('pw_properties:usedScrewdriver')
AddEventHandler('pw_properties:usedScrewdriver', function()
    local targetHouse = exports.pw_properties:checkIfNearHouse()
    if type(targetHouse) == 'table' then -- use tables as exports return results because it was tripping out with multiple return variables
        if targetHouse.house > 0 then
            if playerData.cid ~= Houses[targetHouse.house].ownerCid and playerData.cid ~= Houses[targetHouse.house].rentor and (Houses[targetHouse.house].bought or Houses[targetHouse.house].propertyRented) then
                PW.TriggerServerCallback('pw_properties:server:checkOnlineProperty', function(owner)
                    if owner then
                        TriggerServerEvent('pw_properties:server:setPetAlert', owner, targetHouse.house, Houses[targetHouse.house].entrance)
                        TriggerEvent('pw_lockpick:client:startGame', function(success)
                            if success then
                                TriggerEvent('pw_properties:client:lockCheck', true, targetHouse.house, targetHouse.side, owner)
                            end
                        end)
                    end
                end, targetHouse.house)
            end
        else
            -- check for motels
        end
    end
end)
--

function sendNUI(action, position, data, player)
    if action == "show" then
        TriggerEvent('pw_hud:client:toggleLogo', false)
        SendNUIMessage({
            action = "showHouse",
            messages = data,
            player = player,
            position = position
        })
    else
        TriggerEvent('pw_hud:client:toggleLogo', true)
        SendNUIMessage({
            action = "hideHouse",
            position = position
        })
    end
end

RegisterNetEvent('pw_properties:client:rearlockCheck')
AddEventHandler('pw_properties:client:rearlockCheck', function()
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    for k,v in pairs(Houses) do
        local distEntrance = #(pedCoords - vector3(v.exitEntrance.x, v.exitEntrance.y, v.exitEntrance.z))
        if distEntrance < 3.0 then
            PW.TriggerServerCallback('pw_keys:checkKeyHolder', function(allowed)
                if allowed then
                    local status = not v.doorStatus
                    TriggerServerEvent('pw_properties:server:lockHouse', k, status)
                    -- LOCK DOOR NUI UPDATE
                    SendNUIMessage({
                        action = "updateLock",
                        messages = v,
                        player = playerData,
                        toggle = status
                    })
                    local hStatus = "unlocked"
                    if not v.doorStatus then
                        hStatus = "locked"
                    end
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houselock', 0.05, {x = v.exitEntrance.x, y = v.exitEntrance.y, z = v.exitEntrance.z})
                    exports.pw_notify:SendAlert('inform', 'Door '..hStatus)
                else
                    exports.pw_notify:SendAlert('error', 'You do not have a key for this house')
                end
            end, 'Property', k)
            break
        else
            local distExit = #(pedCoords - vector3(v.exitInside.x, v.exitInside.y, v.exitInside.z))
            if distExit < 3.0 then
                PW.TriggerServerCallback('pw_keys:checkKeyHolder', function(allowed)
                    if allowed then
                        local status = not v.doorStatus
                        TriggerServerEvent('pw_properties:server:lockHouse', k, status)
                        SendNUIMessage({
                            action = "updateLock",
                            messages = v,
                            player = playerData,
                            toggle = status
                        })
                        local hStatus = "unlocked"
                        if not v.doorStatus then
                            hStatus = "locked"
                        end
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houselock', 0.05, {x = v.exitInside.x, y = v.exitInside.y, z = v.exitInside.z})
                        exports.pw_notify:SendAlert('inform', 'Door '..hStatus)
                    else
                        exports.pw_notify:SendAlert('error', 'You do not have a key for this house')
                    end
                end, 'Property', k)
                break
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:knockDoor')
AddEventHandler('pw_properties:client:knockDoor', function(door)
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS

    if door == "front" then
        for k,v in pairs(Houses) do
            local distEntrance = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
            if distEntrance < 3.0 then
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houseknock', 0.15, {x = v.entrance.x, y = v.entrance.y, z = v.entrance.z})
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houseknock', 0.15, {x = v.exit.x, y = v.exit.y, z = v.exit.z})
                break
            end
        end
    else
        for k,v in pairs(Houses) do
            local distEntrance = #(pedCoords - vector3(v.exitEntrance.x, v.exitEntrance.y, v.exitEntrance.z))
            if distEntrance < 3.0 then
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houseknock', 0.15, {x = v.exitEntrance.x, y = v.exitEntrance.y, z = v.exitEntrance.z})
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'houseknock', 0.15, {x = v.exitInside.x, y = v.exitInside.y, z = v.exitInside.z})
                break
            end
        end
    end
end)


RegisterNetEvent('pw_properties:client:updateStatus')
AddEventHandler('pw_properties:client:updateStatus', function(house, status)
    if status == "owned" then
        Houses[house].bought = not Houses[house].bought
    elseif status == "rented" then
        Houses[house].propertyRented = not Houses[house].propertyRented
    elseif status == "forSale" then
        Houses[house].forSale = not Houses[house].forSale
    elseif status == "forRent" then
        Houses[house].forRent = not Houses[house].forRent
        if playerData.cid == Houses[house].ownerCid then OpenRentMenu(house); end
    end
end)

RegisterNetEvent('pw_properties:client:updateStashesRent')
AddEventHandler('pw_properties:client:updateStashesRent', function(house, stashType)
    if stashType == "weapon" then
        Houses[house].hasWeaponsRent = not Houses[house].hasWeaponsRent
    elseif stashType == "inventory" then
        Houses[house].hasItemsRent = not Houses[house].hasItemsRent
    elseif stashType == "money" then
        Houses[house].hasMoneyRent = not Houses[house].hasMoneyRent
    end
    if playerData.cid == Houses[house].ownerCid or exports.pw_gangs:checkBoss(Houses[data.house].gang_id) then OpenOptionsMenu(house); end
end)

RegisterNetEvent('pw_properties:client:updateStashes')
AddEventHandler('pw_properties:client:updateStashes', function(house, stashType)
    if stashType == "weapon" then
        Houses[house].hasWeapons = true
    elseif stashType == "inventory" then
        Houses[house].hasItems = true
    elseif stashType == "money" then
        Houses[house].hasMoney = true
    else
        if stashType == "alarm" then
            Houses[house].hasAlarm = true
        elseif stashType == "cams" then
            Houses[house].hasCams = true
        end
        if playerData.cid == Houses[house].ownerCid then OpenOptionsMenu(house); end
    end
end)

RegisterNetEvent('pw_properties:client:updateOwnerRentor')
AddEventHandler('pw_properties:client:updateOwnerRentor', function(house, type, cid)
    Houses[house][type] = cid
    RefreshBlips()
end)

RegisterNetEvent('pw_properties:client:setRentPrice')
AddEventHandler('pw_properties:client:setRentPrice', function(house, price)
    Houses[house].rentPrice = price
    Citizen.Wait(100)
    if playerData.cid == Houses[house].ownerCid then OpenRentMenu(house); end
end)

RegisterNetEvent('pw_properties:client:openRentMenu')
AddEventHandler('pw_properties:client:openRentMenu', function(house)
    if playerData.cid == Houses[house.house].ownerCid then OpenRentMenu(house.house); end
end)

RegisterNetEvent('pw_properties:client:openOptions')
AddEventHandler('pw_properties:client:openOptions', function(house)
    if playerData.cid == Houses[house.house].ownerCid or exports.pw_gangs:checkBoss(Houses[data.house].gang_id) then OpenOptionsMenu(house.house); end
end)

RegisterNetEvent('pw_properties:client:rentPriceForm')
AddEventHandler('pw_properties:client:rentPriceForm', function(data)
    if playerData.cid == Houses[data.house].ownerCid then OpenRentPriceMenu(data.house); end 
end)

RegisterNetEvent('pw_properties:client:openFurnitureMenu')
AddEventHandler('pw_properties:client:openFurnitureMenu', function(data)
    if playerData.cid == Houses[data.house].ownerCid or exports.pw_gangs:checkBoss(Houses[data.house].gang_id) then OpenFurnitureMenu(data.house, data.outside); end
end)

RegisterNetEvent('pw_properties:client:changeLuxuryPos')
AddEventHandler('pw_properties:client:changeLuxuryPos', function(data)
    if not isMoving and movingHouse == nil then
        isMoving = data.type
        movingHouse = data.house
        StartMoving(movingHouse)
    end
end)

RegisterNetEvent('pw_properties:client:askForFurnitureOnHold')
AddEventHandler('pw_properties:client:askForFurnitureOnHold', function(house, meta)
    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = 'You have <b><span class="text-success">'..#meta..'</span></b> pieces of furniture stored' })
    table.insert(form, { ['type'] = 'hr' })
    local str = ""
    for k,v in pairs(meta) do
        if v.name ~= nil then
            str = str .. v.name .. "<br>"
        end
    end
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b><span class="text-primary">'..str..'</span></b>' })
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = 'Would you like to send them over to the new place?' })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'data', ['data'] = {house = house, meta = meta} })

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:importFurniture', 'server', form, 'Stored furniture')
end)

RegisterNetEvent('pw_properties:client:updateMarkerPos')
AddEventHandler('pw_properties:client:updateMarkerPos', function(house, type, coords)
    Houses[house][type] = coords
end)

AddEventHandler('pw_inventory:closeInventory', function()
    if inventoryOpened then inventoryOpened = false; end
end)

RegisterNetEvent('pw_properties:client:rentTerminated')
AddEventHandler('pw_properties:client:rentTerminated', function(house)
    if inventoryOpened then
        TriggerEvent('pw_inventory:closeInventory')
        inventoryOpened = false
    end
    TriggerEvent('pw_interact:closeMenu')
    if isInside == house then
        TPHouse(house, 'exit')
        if toggleMod then ManageEditMod(); end
    end
    Wait(200)
    HideNuis()
end)

RegisterNetEvent('pw_properties:client:openTerminateRent')
AddEventHandler('pw_properties:client:openTerminateRent', function(data)
    OpenTerminateRent(data.house)
end)

RegisterNetEvent('pw_properties:client:sendFinalContract')
AddEventHandler('pw_properties:client:sendFinalContract', function(house, rent, terms)
    local newTerms = terms .. "<br><b>Make sure you read all the terms before signing</b>"

    local form = {  
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Rent terms</b>"},
        { ['type'] = "checkbox", ['label'] = newTerms, ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "houseId", ['value'] = house },
        { ['type'] = "hidden", ['name'] = "rentPrice", ['value'] = rent }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:finalContractAgreed', 'server', form, "Rent Contract | "..Houses[house].name)
end)

RegisterNetEvent('pw_properties:client:ownerReviewRent')
AddEventHandler('pw_properties:client:ownerReviewRent', function(data)
    local house = Houses[data.house]
    local rentPrice = house.rentPrice
    local terms = "<br>Security Deposit: <b><span class='text-primary'>$"..tostring(math.floor(rentPrice * 2)).."</span></b><br>Daily Cost: <b><span class='text-primary'>$"..rentPrice.."</span></b><br>Garage: "..(house.hasGarage and "<b><span style='color: #00FF00'>Yes</span></b>" or "<b><span style='color: #FF0000'>No</span></b>").."<br>Wardrobe: <b><span style='color: #00FF00'>Yes</span></b><br>Item Stash: "..(house.hasItemsRent and "<b><span style='color: #00FF00'>Yes</span></b>" or "<b><span style='color: #FF0000'>No</span></b>").."<br>Money Stash: "..(house.hasMoneyRent and "<b><span style='color: #00FF00'>Yes</span></b>" or "<b><span style='color: #FF0000'>No</span></b>").."<br>Weapon Stash: "..(house.hasWeaponsRent and "<b><span style='color: #00FF00'>Yes</span></b>" or "<b><span style='color: #FF0000'>No</span></b>")

    local form = {  
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Rent terms</b>"},
        { ['type'] = "checkbox", ['label'] = terms, ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "houseId", ['value'] = data.house },
        { ['type'] = "hidden", ['name'] = "target", ['value'] = data.target },
        { ['type'] = "hidden", ['name'] = "terms", ['value'] = terms },
        { ['type'] = "hidden", ['name'] = "rentPrice", ['value'] = rentPrice }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:sendRentContract', 'server', form, "Review Rent Contract | "..house.name)
end)

RegisterNetEvent('pw_properties:client:ownerTerminate')
AddEventHandler('pw_properties:client:ownerTerminate', function(data)
    local house = Houses[data.house]
    if house.evicting then exports.pw_notify:SendAlert('error', 'There\'s already an evict order going on (Time left: '..house.evictingLeft..'h)'); return; end

    local form = {  
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b><span class='text-danger'>Terminate Tenancy</span></b><br>Tenant: <span class='text-primary'>"..data.rentorName.."</span>"},
        { ['type'] = "checkbox", ['label'] = "I understand that this decision is irreversible and the tenant will receive a notice to evict this house in a timespan of 72h.", ['name'] = "terminateReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "houseId", ['value'] = data.house },
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:sendTerminateRent', 'server', form, "Terminate Tenancy | "..house.name)
end)

RegisterNetEvent('pw_properties:client:updateRent')
AddEventHandler('pw_properties:client:updateRent', function(house, value)
    Houses[house] = value
end)

RegisterNetEvent("pw_properties:client:openOptionsMenu")
AddEventHandler("pw_properties:client:openOptionsMenu", function(data)
    OpenOptionsMenu(data.house)
end)

RegisterNetEvent('pw_properties:openMoneyStash')
AddEventHandler('pw_properties:openMoneyStash', function(houseid)
    PW.TriggerServerCallback('pw_properties:retreiveStashedMoney', function(data)
        local subMenu = {
            { ['label'] = "Withdraw", ['value'] = "withdraw" }, 
            { ['label'] = "Deposit", ['value'] = "deposit" }
        }
        local form = {  
            { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Limits</b>"},
            { ['type'] = "writting", ['align'] = 'left', ['value'] = "<b>Maximum Storage:</b> <span class='text-info'>$"..data.limit.."</span><br><b>Currently Stored:</b> <span class='text-info'>$"..data.currentCash.."</span>"},
            { ['type'] = "number", ['label'] = "Amount", ['name'] = "amount"},
            { ['type'] = "dropdown", ['label'] = "Action", ['options'] = subMenu, ['name'] = "action" },
            { ['type'] = "hidden", ['name'] = "houseId", ['value'] = houseid },
        }
        TriggerEvent('pw_interact:generateForm', 'pw_properties:server:processStashMoney', 'server', form, "Money Stash | "..data.name)
    end, houseid)
end)

RegisterNetEvent('pw_properties:client:checkPayments')
AddEventHandler('pw_properties:client:checkPayments', function(data)
    DisplayPayments(data.house)
end)

RegisterNetEvent('pw_properties:client:openTenantPayment')
AddEventHandler('pw_properties:client:openTenantPayment', function(data)
    TenantPayment(data.house)
end)

RegisterNetEvent('pw_properties:client:processPayment')
AddEventHandler('pw_properties:client:processPayment', function(result)
    if result.method == nil then return; end
    local method = result.method.value
    local houseId = tonumber(result.houseId.value)
    local house = Houses[houseId]
    local form = {}
    local amountToPay = 0
    PW.TriggerServerCallback('pw_properties:server:getBothNames', function(ownerName, rentorName)
        if ownerName ~= nil and rentorName ~= nil then
            if method == "payMonths" then
                amountToPay = house.amountRentsMissed * house.rentPrice
                if amountToPay > 0 then
                    form = {  
                        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b><span class='text-success'>Rent Payment</span></b><br>Tenant: <span class='text-primary'>"..rentorName.."</span> | Landlord: <span class='text-primary'>"..ownerName.."</span>"},
                        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Rents Missing: <b><span class='text-danger'>"..house.amountRentsMissed.."</span></b> (Total Arrears: <b><span class='text-secondary'>$"..house.arrears.."</span></b>)"},
                        { ['type'] = "checkbox", ['label'] = "By ticking this box, you agree to pay the remaining <b><span class='text-primary'>"..house.amountRentsMissed.."</span></b> months for a total of <b><span class='text-success'>$"..amountToPay.."</b>", ['name'] = "checkPay", ['value'] = "yes" },
                        { ['type'] = "hidden", ['name'] = "houseId", ['data'] = {house = houseId, method = method, amount = amountToPay} },
                    }

                    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:processPayment', 'server', form, "Pay Missing Months | "..house.name)
                else
                    exports.pw_notify:SendAlert('error', 'No rents left to pay for now')
                end
            else
                if house.arrears > 0 then
                    form = {  
                        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b><span class='text-success'>Rent Payment</span></b><br>Tenant: <span class='text-primary'>"..rentorName.."</span> | Landlord: <span class='text-primary'>"..ownerName.."</span>"},
                        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Total Arrears: <b><span class='text-danger'>$"..house.arrears.."</span></b>"},
                        { ['type'] = "number", ['label'] = "Pay towards the Arrears (Max: <b><span class='text-success'>$"..house.arrears.."</span></b>)", ['name'] = "checkPay" },
                        { ['type'] = "hidden", ['name'] = "houseId", ['data'] = {house = houseId, method = method} },
                    }

                    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:processPayment', 'server', form, "Pay Towards Arrears | "..house.name)
                else
                    exports.pw_notify:SendAlert('error', 'No arrears left to pay for now')
                end
            end
        end
    end, houseId)
end)

function BreakInside(house, door)
    exports['pw_progbar']:Progress({
        name = "breakIn",
        duration = 5700,
        label = "Breaking in",
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = 'veh@std@bobcat@ds@enter_exit', --'melee@knife@streamed_core',
            anim = 'd_force_entry', --'kick_far_a',
            flags = 0,
        }
    }, function(status)
        if not status then
            TriggerServerEvent('pw_properties:server:toggleBroken', house, 'police')
            Citizen.CreateThread(function()
                Citizen.Wait(Config.HouseBrokenByPolice * 1000)
                TriggerServerEvent('pw_properties:server:toggleBroken', house, false)
            end)
            if door == "front" then
                TPHouse(house, "enter")
            else
                TPHouseR(house, "enter")
            end
            exports.pw_notify:SendAlert('inform', 'Broken into property')
        end
    end)
end

RegisterNetEvent('pw_properties:client:policeForceEntry')
AddEventHandler('pw_properties:client:policeForceEntry', function(warrantId, propertyId)
    local ped = GLOBAL_PED
    local coords = GLOBAL_COORDS
    local found = false
    for k,v in pairs(Houses) do
        for i = 1, #propertyId do
            if propertyId[i] == k then
                local dist = #(coords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
                if dist < 2.0 then
                    BreakInside(k, "front")
                    found = true
                    break
                end

                dist = #(coords - vector3(v.exitEntrance.x, v.exitEntrance.y, v.exitEntrance.z))
                if dist < 2.0 then
                    BreakInside(k, "back")
                    found = true
                    break
                end
            end
        end
    end
    if not found then exports.pw_notify:SendAlert('error', 'This warrant is not valid for this property'); end
end)

RegisterNetEvent('pw_properties:client:deleteFurnitureForEveryone')
AddEventHandler('pw_properties:client:deleteFurnitureForEveryone', function(house, fid)
    if isInside == house then
        FreezeEntityPosition(spawnedFurniture[house][fid].obj, false)
        SetEntityAsMissionEntity(spawnedFurniture[house][fid].obj, true, true)  
        local gtfo = false
        local waited = 0  

        while not gtfo do
            if waited >= 1000 then
                gtfo = true
            else
                waited = waited + 10
                
                if DoesEntityExist(spawnedFurniture[house][fid].obj) then
                    DeleteEntity(spawnedFurniture[house][fid].obj)
                    gtfo = true
                else
                    gtfo = true
                end
            end
            Wait(10)
        end
        
        spawnedFurniture[house][fid] = {}
    end
end)

RegisterNetEvent('pw_properties:client:storeFurniture')
AddEventHandler('pw_properties:client:storeFurniture', function(data)
    TriggerServerEvent('pw_properties:server:deleteFurnitureForEveryone', data.house, data.fid)
    TriggerServerEvent('pw_properties:server:updateFurniturePlaced', data.house, data.fid, false)
    exports.pw_notify:SendAlert('inform', 'Object sent to the storage room', 4000)
end)

RegisterNetEvent('pw_properties:client:changeFurnitureLabelMenu')
AddEventHandler('pw_properties:client:changeFurnitureLabelMenu', function(data)
    ChangeFurnitureName(data.house, data.fid)
end)

RegisterNetEvent('pw_properties:client:openPlacedFurniture')
AddEventHandler('pw_properties:client:openPlacedFurniture', function(house)
    if Houses[house].furniture ~= nil and #Houses[house].furniture > 0 then
        local menu = {}
        for k,v in pairs(Houses[house].furniture) do
            if v.delivered and v.placed and v.buyer == playerData.cid then
                local sub = {}
                table.insert(sub, { ['label'] = 'Change Label', ['action'] = 'pw_properties:client:changeFurnitureLabelMenu', ['value'] = {house = house, fid = k}, ['triggertype'] = 'client', ['color'] = ''})
                table.insert(sub, { ['label'] = '<b><span class="text-danger">Store</span></b>', ['action'] = 'pw_properties:client:storeFurniture', ['value'] = {house = house, fid = k}, ['triggertype'] = 'client', ['color'] = '' })
                table.insert(menu, { ['label'] = v.name, ['color'] = 'primary', ['subMenu'] = sub })
            end
        end
        if #menu > 0 then
            TriggerEvent('pw_interact:generateMenu', menu, "Furniture | "..Houses[house].name)
        else
            exports.pw_notify:SendAlert('error', 'You do not have any furniture placed', 4000)
        end
    else
        exports.pw_notify:SendAlert('error', 'You do not have any furniture placed', 4000)
    end
end)

RegisterNetEvent('pw_properties:client:openFurnitureManagement')
AddEventHandler('pw_properties:client:openFurnitureManagement', function(k)
    local menu = {}
    table.insert(menu, { ['label'] = "Placed Furniture", ['action'] = "pw_properties:client:openPlacedFurniture", ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Storage Room", ['action'] = "pw_properties:client:openStorageRoom", ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Furniture | "..Houses[k].name)
end)

RegisterNetEvent('pw_properties:client:camQualityUpgrade')
AddEventHandler('pw_properties:client:camQualityUpgrade', function(data)
    local menu = {}
    for k,v in pairs(Config.CamsQuality) do
        if k > Houses[data.house].camSettings.quality then
            table.insert(menu, { ['label'] = v.label .. ' ($' .. v.price .. ')', ['action'] = 'pw_properties:server:upgradeCamQuality', ['value'] = {house = data.house, quality = k}, ['triggertype'] = 'server', ['color'] = 'primary' })
        end
    end

    table.sort(menu, function(a,b) return a.value.quality < b.value.quality end)

    TriggerEvent('pw_interact:generateMenu', menu, 'Camera Quality Upgrade')
end)

function OpenOptionsMenu(k)
    local menu = {}
    table.insert(menu, { ['label'] = "Furniture Management", ['action'] = "pw_properties:client:openFurnitureManagement", ['value'] = k, ['triggertype'] = 'client', ['color'] = 'info' })
    
    if not Houses[k].hasCams then
        table.insert(menu, { ['label'] = "Buy Security Cameras ($"..Houses[k].camsCost..")", ['action'] = "pw_properties:server:buyCams", ['value'] = {house = k, state = not Houses[k].cams}, ['triggertype'] = "server", ['color'] = "primary" })
    else
        local sub = {}
        table.insert(sub, { ['label'] = (Houses[k].cams and "<b><span class='text-danger'>Disable</span></b>" or "<b><span class='text-success'>Enable</span></b>"), ['action'] = 'pw_properties:server:toggleCams', ['value'] = {house = k, state = not Houses[k].cams}, ['triggertype'] = 'server', ['color'] = (Houses[k].cams and 'success' or 'danger') })
        table.insert(sub, { ['label'] = 'Quality: <b>' .. Config.CamsQuality[Houses[k].camSettings.quality].label .. '</b>', ['color'] = 'primary' })
        table.insert(sub, { ['label'] = 'Nightvision: ' .. (Houses[k].camSettings.nightvision and '<b>Available</b>' or '<b>Not available</b>'), ['color'] = 'primary' })
        if Houses[k].camSettings.quality < #Config.CamsQuality then
            table.insert(sub, { ['label'] = '<b><span class="text-primary">Upgrade Quality</span></b>', ['action'] = 'pw_properties:client:camQualityUpgrade', ['value'] = {house = k}, ['triggertype'] = 'client', ['color'] = 'primary' })
        end
        if not Houses[k].camSettings.nightvision then
            table.insert(sub, { ['label'] = '<b><span class="text-primary">Buy Nightvision</span> (<span class="text-success">$' .. Config.NightvisionPrice .. '</span>)</b>', ['action'] = 'pw_properties:server:purchaseNightvision', ['value'] = {house = k}, ['triggertype'] = 'server', ['color'] = 'primary' })
        end
        table.insert(menu, { ['label'] = (Houses[k].cams and "Security Cameras: Enabled" or "Security Cameras: Disabled"), ['action'] = (not Houses[k].hasCams and "pw_properties:server:buyCams" or "pw_properties:server:toggleCams"), ['value'] = {house = k, state = not Houses[k].cams}, ['triggertype'] = "server", ['color'] = (not Houses[k].hasCams and "primary" or Houses[k].cams and "success" or "danger"), ['subMenu'] = sub })
    end

    if Houses[k].gang_id == 0 then
        table.insert(menu, { ['label'] = (not Houses[k].hasAlarm and "Buy Alarm System ($"..Houses[k].alarmCost..")" or Houses[k].alarm and "Alarm System: Enabled" or "Alarm System: Disabled"), ['action'] = (not Houses[k].hasAlarm and "pw_properties:server:buyAlarm" or "pw_properties:server:toggleAlarm"), ['value'] = {house = k, state = not Houses[k].alarm}, ['triggertype'] = "server", ['color'] = (not Houses[k].hasAlarm and "primary" or Houses[k].alarm and "success" or "danger") })
        table.insert(menu, { ['label'] = "Auto-Lock Doors: "..(Houses[k].autoLock and "Enabled" or "Disabled"), ['action'] = "pw_properties:server:toggleAutoLock", ['value'] = {house = k, state = not Houses[k].autoLock}, ['triggertype'] = "server", ['color'] = (Houses[k].autoLock and "success" or "danger") })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "House Options | "..Houses[k].name)
end

function TenantPayment(k)
    local house = Houses[k]

    PW.TriggerServerCallback('pw_properties:server:getBothNames', function(ownerName, rentorName)
        if ownerName ~= nil and rentorName ~= nil then
            local subOptions = {}
            table.insert(subOptions, { ['value'] = "payMonths", ['label'] = "Pay Missing Months"} )
            table.insert(subOptions, { ['value'] = "payArrears", ['label'] = "Pay Towards Arrears"} )
            
            local form = {  
                { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b><span class='text-success'>Rent Payment</span></b><br>Tenant: <span class='text-primary'>"..rentorName.."</span> | Landlord: <span class='text-primary'>"..ownerName.."</span>"},
                { ['type'] = "writting", ['align'] = 'left', ['value'] = "Total Rents: <b><span class='text-primary'>"..house.totalRents.."</span></b><br>Rents Paid: <b><span class='text-success'>"..house.amountRentsPaid.."</span></b><br>Rents Missing: <b><span class='text-danger'>"..house.amountRentsMissed.."</span></b> (Total Arrears: <b><span class='text-secondary'>$"..house.arrears.."</span></b>)"},
                { ['type'] = "hidden", ['name'] = "houseId", ['value'] = k },
            }

            if house.amountRentsMissed == 0 then
                for k,v in pairs(subOptions) do
                    if v.value == "payMonths" then
                        table.remove(subOptions, k)
                        break
                    end
                end
            end

            if house.arrears <= 0 then
                for k,v in pairs(subOptions) do
                    if v.value == "payArrears" then
                        table.remove(subOptions, k)
                        break
                    end
                end
            end

            if #subOptions > 0 then table.insert(form, { ['type'] = "dropdown", ['label'] = "Choose Method", ['name'] = "method", ['options'] = subOptions }); end

            TriggerEvent('pw_interact:generateForm', 'pw_properties:client:processPayment', 'client', form, "Rent Payment | "..house.name)
        end
    end, k)
end

function DisplayPayments(k)
    local house = Houses[k]

    PW.TriggerServerCallback('pw_properties:server:getRentor', function(rentorName)
        if rentorName ~= nil then
            local form = {  
                { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b><span class='text-success'>Payment Collection</span></b><br>Tenant: <span class='text-primary'>"..rentorName.."</span>"},
                { ['type'] = "writting", ['align'] = 'left', ['value'] = "Total Rents: <b><span class='text-primary'>"..house.totalRents.."</span></b><br>Rents Paid: <b><span class='text-success'>"..house.amountRentsPaid.."</span></b><br>Rents Missing: <b><span class='text-danger'>"..house.amountRentsMissed.."</span></b> (Total Arrears: <b><span class='text-secondary'>$"..house.arrears.."</span></b>)"},
                { ['type'] = "number", ['label'] = "Collect Payments (Pot: <b><span class='text-success'>$"..house.pot.."</span></b>)", ['name'] = "potAmount" },
                { ['type'] = "hidden", ['name'] = "houseId", ['value'] = k },
            }

            TriggerEvent('pw_interact:generateForm', 'pw_properties:server:processCollection', 'server', form, "Payment Collection | "..house.name)
        end

    end, k)
end

function StartMoving(house)
    isInside = house
    -- Ctrl + X - Set
    -- Ctrl + C - Cancel
    if showing then
        showing = false
        sendNUI("hide", "menu1")
    end
    local luxuryLabel
    if isMoving == "items" then 
        luxuryLabel = "Item Stash"
    elseif isMoving == "money" then 
        luxuryLabel = "Money Stash"
    elseif isMoving == "weapons" then 
        luxuryLabel = "Weapon Stash"
    elseif isMoving == "garage" then 
        luxuryLabel = "Garage"
    elseif isMoving == "clothing" then 
        luxuryLabel = "Wardrobe"
    elseif isMoving == "exitEntrance" then 
        luxuryLabel = "Back Entrance"
    elseif isMoving == "exitInside" then 
        luxuryLabel = "Back Exit"
    end

    if luxuryLabel ~= nil then exports['pw_notify']:PersistentAlert('start', 'curMoving', 'inform', 'Currently moving: '..luxuryLabel); end
    exports['pw_notify']:PersistentAlert('start', 'movingSet', 'inform', 'Press <b><span style="color:#ffff00">SHIFT+X</span></b> to set the current position')
    exports['pw_notify']:PersistentAlert('start', 'movingCancel', 'inform', 'Press <b><span style="color:#ffff00">SHIFT+C</span></b> to cancel the operation')
    Citizen.CreateThread(function()
        while isMoving and playerLoaded and not inCam do
            Citizen.Wait(1)
            -- SHIFT + X 73
            if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then
                local ped = GLOBAL_PED
                local pedCoords = GLOBAL_COORDS
                local dist, notFound = nil, false
                if (isMoving == "garage" or isMoving == "exitEntrance") and not isInside then
                    --dist = GetDistanceBetweenCoords(pedCoords.x, pedCoords.y, pedCoords.z, Houses[movingHouse].entrance.x, Houses[movingHouse].entrance.y, Houses[movingHouse].entrance.z, true)
                    if isMoving == "exitEntrance" then
                        if Houses[movingHouse].exitEntrance.x ~= nil and Houses[movingHouse].exitEntrance.x ~= 0.0 then
                            dist = #(pedCoords - vector3(Houses[movingHouse].exitEntrance.x, Houses[movingHouse].exitEntrance.y, Houses[movingHouse].exitEntrance.z))
                        else
                            notFound = true
                            dist = #(pedCoords - vector3(Houses[movingHouse].entrance.x, Houses[movingHouse].entrance.y, Houses[movingHouse].entrance.z))
                        end
                    else
                        if Houses[movingHouse].gang_id == 0 then
                            dist = #(pedCoords - vector3(Houses[movingHouse].entrance.x, Houses[movingHouse].entrance.y, Houses[movingHouse].entrance.z))
                        else
                            dist = exports.pw_gangs:checkPoly('outpoly', pedCoords, Houses[movingHouse].gang_id)
                        end
                    end
                    if (Houses[movingHouse].gang_id > 0 and dist) or (Houses[movingHouse].gang_id == 0 and (notFound and dist < Houses[movingHouse].radiusOutside + 10.0) or dist < Houses[movingHouse].radiusOutside) then
                        local h = GetEntityHeading(ped)-- save
                        TriggerServerEvent('pw_properties:server:saveMarkerPos', isMoving, movingHouse, pedCoords, h)
                        exports['pw_notify']:SendAlert('success', 'Moved successfully')
                        StopMoving()
                        notFound = false
                    else
                        -- show far away
                        exports['pw_notify']:SendAlert('error', 'Too far from the main entrance')
                    end
                elseif isMoving ~= "garage" and isMoving ~= "exitEntrance" and isInside then
                    if Houses[movingHouse].gang_id == 0 then
                        dist = #(pedCoords - vector3(Houses[movingHouse].charSpawn.x, Houses[movingHouse].charSpawn.y, Houses[movingHouse].charSpawn.z))
                    else
                        dist = exports.pw_gangs:checkPoly('poly', pedCoords, Houses[movingHouse].gang_id)
                    end
                    if (Houses[movingHouse].gang_id == 0 and dist < Houses[movingHouse].radiusInside) or dist then
                        local h = GetEntityHeading(ped)-- save
                        TriggerServerEvent('pw_properties:server:saveMarkerPos', isMoving, movingHouse, pedCoords, h)
                        exports['pw_notify']:SendAlert('success', 'Moved successfully')
                        StopMoving()
                    else
                        -- show far away
                        exports['pw_notify']:SendAlert('error', 'Too far from the main exit')
                    end
                else
                    if (isMoving == "garage" or isMoving == "exitEntrance") and isInside then
                        exports['pw_notify']:SendAlert('error', 'You need to be outside')
                    elseif isMoving ~= "garage" and isMoving ~= "exitEntrance" and not isInside then
                        exports['pw_notify']:SendAlert('error', 'You need to be inside')
                    else
                        exports['pw_notify']:SendAlert('error', 'Too far from the main '.. (isInside and "exit" or "entrance"))
                    end
                end
            end

            if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then
                if isMoving then
                    StopMoving(1)
                end
            end
        end
    end)
end

function HideNuis()
    if showing then
        showing = false
        local hideThis = { "frontdoor", "backdoor", "menu1", "menu2", "garage", "inventory", "money", "clothing", "weapons" }
        for i = 1, #hideThis do
            sendNUI("hide", hideThis[i])
        end
    end
end

function StopMoving(load, delete)
    exports.pw_notify:PersistentAlert('end', 'movingSet'); exports.pw_notify:PersistentAlert('end', 'movingCancel'); exports.pw_notify:PersistentAlert('end', 'curMoving'); 
    if isMoving == 'new' then exports.pw_notify:PersistentAlert('end', 'newFurn'); end
    isMoving = false
    movingHouse = nil
    if load then exports['pw_notify']:SendAlert('error', 'Placement canceled'); end
    if delete then
        FreezeEntityPosition(delete, false)
        SetEntityAsMissionEntity(delete, true, true)
        DeleteEntity(delete)
    end
end

function OpenTerminateRent(k)
    local form = {  { ['type'] = "checkbox", ['label'] = "I understand that this decision is irreversible and will lose access to any belongings I leave inside this house.<br> I will then leave my keys inside and will see myself the exit.", ['name'] = "checkTerminate", ['value'] = 'check'},
                    { ['type'] = "hidden", ['name'] = "houseId", ['value'] = k }
                }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:terminateRent', 'server', form, "Terminate Tenancy | "..Houses[k].name)
end

function OpenTenantMenu(k)
    local menu = {}
    table.insert(menu, { ['label'] = "House Options", ['action'] = "pw_properties:client:openOptionsMenu", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "primary" })
    table.insert(menu, { ['label'] = "Payments", ['action'] = "pw_properties:client:openTenantPayment", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "warning"})
    table.insert(menu, { ['label'] = "Terminate Tenancy", ['action'] = "pw_properties:client:openTerminateRent", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "danger"})

    TriggerEvent('pw_interact:generateMenu', menu, "Tenancy Options | "..Houses[k].name)
end

function OpenRentPriceMenu(k)
    local form = {  
        { ['type'] = "number", ['label'] = "Current: <b><span class='text-primary'>$"..Houses[k].rentPrice.."</span></b><br>Min: <b><span class='text-success'>$1</span></b><br>Max: <b><span class='text-success'>$"..(Houses[k].price / 100).."</span>", ['name'] = "rentPrice" },
        { ['type'] = "hidden", ['name'] = "houseId", ['value'] = k }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:setRentPrice', 'server', form, "Rent Price | "..Houses[k].name)
end

RegisterNetEvent('pw_properties:client:toggleRentRealEstate')
AddEventHandler('pw_properties:client:toggleRentRealEstate', function(house, state)
    Houses[house].allowRealEstate = state
    if playerData.cid == Houses[house].ownerCid then OpenRentMenu(house); end
end)

function OpenRentMenu(k)
    local itemSub = {}
    table.insert(itemSub, { ['label'] = (not Houses[k].hasItemsRent and "Enable" or "Disable"), ['action'] = "pw_properties:server:toggleLuxaryRent", ['value'] = {house = k, type = 'inventory'}, ['triggertype'] = "server", ['color'] = "success" })

    local moneySub = {}
    table.insert(moneySub, { ['label'] = (not Houses[k].hasMoneyRent and "Enable" or "Disable"), ['action'] = "pw_properties:server:toggleLuxaryRent", ['value'] = {house = k, type = 'money'}, ['triggertype'] = "server", ['color'] = "success" })

    local weaponSub = {}
    table.insert(weaponSub, { ['label'] = (not Houses[k].hasWeaponsRent and "Enable" or "Disable"), ['action'] = "pw_properties:server:toggleLuxaryRent", ['value'] = {house = k, type = 'weapon'}, ['triggertype'] = "server", ['color'] = "success" })

    local menu = {}

    table.insert(menu, { ['label'] = (Houses[k].evicting and "Evicting Order - "..Houses[k].evictingLeft.."h left" or not Houses[k].propertyRented and "Not Rented" or "Rented"), ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = (Houses[k].evicting and "warning" or "primary")})
    if Houses[k].propertyRented then
        local rentorName
        PW.TriggerServerCallback('pw_properties:server:getRentor', function(data)
            if data then
                rentorName = data
            else
                rentorName = "No Tenant"
            end
        end, k)
        
        while rentorName == nil do
            Wait(10)
        end

        local tenantSub = {}
        table.insert(tenantSub, { ['label'] = "Terminate Contract", ['action'] = "pw_properties:client:ownerTerminate", ['value'] = {house = k, rentorName = rentorName}, ['triggertype'] = "client", ['color'] = "primary" })
        table.insert(menu, { ['label'] = "Tenant: ".. rentorName, ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "primary", ['subMenu'] = tenantSub })

    else
        table.insert(menu, { ['label'] = "Looking for Tenant: ".. (Houses[k].forRent and "Yes" or "No"), ['action'] = "pw_properties:server:changeRentStatus", ['value'] = {house = k, type = "forRent"}, ['triggertype'] = "server", ['color'] = (Houses[k].forRent and "success" or "danger")})
        
        if Houses[k].forRent then
            local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
            local nearbyPlayersSub = {}
            if closestPlayer ~= -1 and closestDistance <= 2.0 and closestPlayer > 0 then
                local pName
                PW.TriggerServerCallback('pw_properties:server:getNearbyName', function(name)
                    pName = name
                end, GetPlayerServerId(closestPlayer))

                while pName == nil do
                    Wait(10)
                end
                
                if pName then
                    table.insert(nearbyPlayersSub, { ['label'] = pName, ['action'] = "pw_properties:client:ownerReviewRent", ['value'] = {house = k, target = GetPlayerServerId(closestPlayer)}, ['triggertype'] = "client", ['color'] = "warning" })
                else
                    table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = "action", ['triggertype'] = "trigger", ['color'] = "warning"})
                end
            else
                table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = "action", ['triggertype'] = "trigger", ['color'] = "warning" })
            end

            table.insert(menu, { ['label'] = "Add Tenant", ['action'] = "action", ['triggertype'] = "trigger", ['color'] = "warning", ['subMenu'] = nearbyPlayersSub })
        end
    end

    if Houses[k].forRent and not Houses[k].propertyRented then
        table.insert(menu, { ['label'] = "Advertise with Real Estate: " .. (Houses[k].allowRealEstate and "Yes" or "No"), ['action'] = 'pw_properties:server:toggleRentRealEstate', ['value'] = { house = k, state = not Houses[k].allowRealEstate }, ['triggertype'] = 'server', ['color'] = (Houses[k].allowRealEstate and 'success' or 'danger') })

        local rentPriceSub = {}
        table.insert(rentPriceSub, { ['label'] = "Change Rent Price", ['action'] = "pw_properties:client:rentPriceForm", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "primary"})
        table.insert(menu, { ['label'] = "Rent Price: $".. Houses[k].rentPrice, ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "primary", ['subMenu'] = rentPriceSub})
    end

    if Houses[k].hasItems then
        table.insert(menu, { ['label'] = "Item Stash: ".. (Houses[k].hasItemsRent and "Enabled" or "Disabled"), ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = (Houses[k].hasItemsRent and "success" or "danger"), ['subMenu'] = itemSub })
    end

    if Houses[k].hasMoney then
        table.insert(menu, { ['label'] = "Money Stash: ".. (Houses[k].hasMoneyRent and "Enabled" or "Disabled"), ['action'] = "testAction2", ['triggertype'] = "triggerType", ['color'] = (Houses[k].hasMoneyRent and "success" or "danger"), ['subMenu'] = moneySub })
    end

    if Houses[k].hasWeapons then
        table.insert(menu, { ['label'] = "Weapon Stash: ".. (Houses[k].hasWeaponsRent and "Enabled" or "Disabled"), ['action'] = "testAction3", ['triggertype'] = "triggerType", ['color'] = (Houses[k].hasWeaponsRent and "success" or "danger"), ['subMenu'] = weaponSub })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Renting Options | "..Houses[k].name)
end

function OpenInventoryMenu(k, rtype)
    inventoryOpened = true
    if rtype == "items" or rtype == "weapons" then 
        TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 2.0, 'stashopen', 0.05, {x = Houses[k][rtype].x, y = Houses[k][rtype].y, z = Houses[k][rtype].z})
    end
    if rtype == "money" then TriggerEvent('pw_properties:openMoneyStash', k); end
    if rtype == "clothing" then TriggerEvent('pw_character:client:openOutfitManagement'); end
end

function DeleteFurniture(house)
    if house then
        if spawnedFurniture[house] ~= nil and #spawnedFurniture[house] > 0 then
            for k,v in pairs(spawnedFurniture[house]) do
                FreezeEntityPosition(v.obj, false)
                SetEntityAsMissionEntity(v.obj, true, true)
                DeleteEntity(v.obj)
                spawnedFurniture[house][k] = nil
            end            
        end
    end
end

function SpawnFurniture(house)
    if spawnedFurniture[house] ~= nil and #spawnedFurniture[house] > 0 then
        DeleteFurniture(house)
    end
    if Houses[house].furniture ~= nil and #Houses[house].furniture > 0 then
        if type(spawnedFurniture[house]) ~= "table" then
            spawnedFurniture[house] = {}
        end
        for k,v in pairs(Houses[house].furniture) do
            if v.placed then
                PW.Game.SpawnLocalObjectNoOffset(v.prop, v.position, function(obj)
                    SetEntityHeading(obj, v.position.h)
                    FreezeEntityPosition(obj, true)

                    spawnedFurniture[house][k] = { ['obj'] = obj }
                end)
            end
        end
    end
end

RegisterNetEvent('pw_properties:client:addedFurniture')
AddEventHandler('pw_properties:client:addedFurniture', function(house, furniture, check)
    Houses[house].furniture = furniture
    if check then
        if isInside == house then SpawnFurniture(house); end
    end
end)

RegisterNetEvent('pw_properties:client:deleteDisplayed')
AddEventHandler('pw_properties:client:deleteDisplayed', function()
    if displayedFurniture ~= 0 then
        if DoesEntityExist(displayedFurniture) then
            FreezeEntityPosition(displayedFurniture, false)
            SetEntityAsMissionEntity(displayedFurniture, true, true)
            DeleteEntity(displayedFurniture)
            displayedFurniture = 0
        end
    end
end)

function GetCameraSettingsForCat(cat)
    if Config.Furniture[cat].camera then
        return Config.StoreCameras[Config.Furniture[cat].camera]
    else
        return Config.StoreCameras['default']
    end
end

RegisterNetEvent('pw_properties:client:camOff')
AddEventHandler('pw_properties:client:camOff', function()
    inCamera = false
    PW.Game.CancelCameraView()
end)

RegisterNetEvent('pw_properties:client:loadFurniture')
AddEventHandler('pw_properties:client:loadFurniture', function(data)
    TriggerEvent('pw_properties:client:deleteDisplayed')
    local cam = GetCameraSettingsForCat(data.cat)
    PW.Game.SpawnLocalObjectNoOffset(data.prop, cam.spawnObj, function(obj)
        displayedFurniture = obj
        SetEntityHeading(displayedFurniture, cam.spawnObj.h + data.h)
        PlaceObjectOnGroundProperly(displayedFurniture)
        FreezeEntityPosition(displayedFurniture, true)
        TriggerEvent('pw_interact:enableSlider')
    end)
end)

function GetFurnitureCategory(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs (Config.Furniture[k].props) do
            if b.prop == prop then
                return k
            end
        end
    end
    return "Piece of Furniture"
end

function GetFurnitureLabel(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs (Config.Furniture[k].props) do
            if b.prop == prop then
                return b.label
            end
        end
    end
    return "Piece of Furniture"
end

function GetPropPrice(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs (Config.Furniture[k].props) do
            if b.prop == prop then
                return b.price
            end
        end
    end
    return "Piece of Furniture"
end

RegisterNetEvent('pw_properties:client:pickDeliveryMethod')
AddEventHandler('pw_properties:client:pickDeliveryMethod', function(dataa)
    local methods = {}
    
    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Purchase of <span class="text-info">'..CountBasketItems()..' items</span></b>' })
    table.insert(form, { ['type'] = 'hr'})
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Cost</b>: <b><span class="text-success">$'..SumBasket()..'</span></b>' })
    table.insert(form, { ['type'] = 'hr'})
    local str, count = "", 0
    for k,v in pairs(Config.DeliveryMethods) do
        if count == 0 then str = "<b>Delivery Methods</b><br>"; end
        count = count + 1
        table.insert(methods, {['value'] = k, ['label'] = k})
        str = str .. '<b><span class="text-primary">'..k..'</span></b>  - Delivery in <b>'..v.delay..'</b> minutes (<b><span class="text-success">+ $'..v.fee..'</b></span>)<br>'
    end
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = str })
    table.insert(form, { ['type'] = "dropdown", ['label'] = 'Pick a Delivery Method', ['name'] = "delivery", ['options'] = methods })
    table.insert(form, { ['type'] = 'hidden', ['name'] = "cart", ['data'] = shoppingCart.items, ['value'] = dataa.paymentMethod })
    table.insert(form, { ['type'] = 'hidden', ['name'] = "house", ['value'] = dataa.house })

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:payForFurniture', 'server', form, "Pick a Delivery Method")
end)

RegisterNetEvent('pw_properties:client:pickMethod')
AddEventHandler('pw_properties:client:pickMethod', function(data)
    local menu = {}
    table.insert(menu, { ['label'] = "Cash", ['action'] = 'pw_properties:client:pickDeliveryMethod', ['value'] = {paymentMethod = 'cash', house = data}, ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Debit Card", ['action'] = 'pw_properties:client:pickDeliveryMethod', ['value'] = {paymentMethod = 'debit', house = data}, ['triggertype'] = 'client', ['color'] = 'primary' })
    TriggerEvent('pw_interact:generateMenu', menu, "Pick a Payment Method")
end)

RegisterNetEvent('pw_properties:client:pickHouse')
AddEventHandler('pw_properties:client:pickHouse', function(data)
    PW.TriggerServerCallback('pw_properties:server:getOwnedProperties', function(props, gang)
        local ownedHouses = props    
        local menu = {}
        if ownedHouses and #ownedHouses > 0 then
            for k,v in pairs(ownedHouses) do
                table.insert(menu, { ['label'] = v.name, ['action'] = 'pw_properties:client:pickMethod', ['value'] = v.property_id, ['triggertype'] = 'client', ['color'] = 'primary' })
            end
        end
        if gang then 
            table.insert(menu, { ['label'] = gang.name .. ' HQ', ['action'] = 'pw_properties:client:pickMethod', ['value'] = gang.property, ['triggertype'] = 'client', ['color'] = 'primary' })
        end
        if #menu > 0 then
            TriggerEvent('pw_interact:generateMenu', menu, "Pick a Delivery Location")
        else
            exports.pw_notify:SendAlert('error', 'You don\'t own any properties', 5000)
        end
    end)        
end)

function CheckItemInBasket(item)
    if shoppingCart.items and #shoppingCart.items > 0 then
        for i = 1, #shoppingCart.items do
            if shoppingCart.items[i].prop == item then
                return i
            end
        end
    end

    return false
end

RegisterNetEvent('pw_properties:client:addItemToBasket')
AddEventHandler('pw_properties:client:addItemToBasket', function(data)
    local qty = data.qty.value and tonumber(data.qty.value) or 1
    if qty > 0 then
        local exists = CheckItemInBasket(data.piece.data.prop)
        if not exists then
            table.insert(shoppingCart.items, { ['prop'] = data.piece.data.prop, ['qty'] = qty })
        elseif exists > 0 then
            shoppingCart.items[exists].qty = shoppingCart.items[exists].qty + qty
        end
        exports.pw_notify:SendAlert('success', (qty > 0 and 'Items' or 'Item')..' added', 4000)
        TriggerEvent('pw_properties:client:orderFurniture', data.piece.data.store, true)
    else
        exports.pw_notify:SendAlert('error', 'Invalid quantity', 3500)
        TriggerEvent('pw_properties:client:addToBasket', data.piece.data)
    end
end)

RegisterNetEvent('pw_properties:client:addToBasket')
AddEventHandler('pw_properties:client:addToBasket', function(data)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Selected Product<br><b>"..data.cat.."</b> > <b><span class='text-primary'>"..data.label.."</span></b>"},
        { ['type'] = 'hr'},
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Price Per Piece<br><b><span class='text-success'>$"..data.price.."</span></b>"},
        { ['type'] = 'hr'},
        { ['type'] = 'number', ['label'] = 'Desired Quantity', ['name'] = 'qty'},
        { ['type'] = 'hidden', ['name'] = 'piece', ['data'] = data }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:client:addItemToBasket', 'client', form, 'Add '..data.label..' to your cart')
end)

RegisterNetEvent('pw_properties:client:displayCatalogCategory')
AddEventHandler('pw_properties:client:displayCatalogCategory', function(data)
    inCamera = true
    
    local cam = GetCameraSettingsForCat(data.cat)
    PW.Game.CreateCameraView(cam.cameraPos, cam.spawnObj, cam.fov)
    
    local slider = {}
    for k,v in pairs(Config.Furniture[data.cat].props) do
        table.insert(slider, { ['label'] = v.label.."<br>($"..v.price..")", ['data'] = { ['h'] = (v.h or 0.0), ['prop'] = v.prop, ['price'] = v.price, ['label'] = v.label, ['store'] = data.store, ['cat'] = data.cat, ['trigger'] = "pw_properties:client:loadFurniture", ['triggerType'] = "client"} })
    end
    table.sort(slider, function(a,b) return a.data.price < b.data.price end)
    Wait(1500)
    TriggerEvent('pw_interact:generateSlider', slider, 'pw_properties:client:addToBasket', 'client', data.cat, "", {vehicle = true}, { { ['trigger'] = "pw_properties:client:deleteDisplayed", ['method'] = "client" }, { ['trigger'] = "pw_properties:client:camOff", ['method'] = "client" }, { ['trigger'] = "pw_properties:client:orderFurniture", ['method'] = "client" } } )
    
end)

RegisterNetEvent('pw_properties:client:orderFurniture')
AddEventHandler('pw_properties:client:orderFurniture', function(store, cancel)
    if store == nil then
        Wait(1500)
        store = 1
    end

    inDisplayCatalogs = store
    if cancel then inCamera = false; PW.Game.CancelCameraView(); end
    local menu = {}
    for k,v in pairs(Config.Furniture) do
        table.insert(menu, { ['label'] = k, ['action'] = 'pw_properties:client:displayCatalogCategory', ['value'] = {cat = k, store = store}, ['triggertype'] = 'client', ['color'] = 'primary' })
    end
    table.sort(menu, function(a,b) return a.label < b.label end)
    
    TriggerEvent('pw_interact:generateMenu', menu, "Furniture Catalog", { { ['trigger'] = 'pw_properties:client:openFurnitureStore', ['method'] = 'client' } })
end)

function CountBasketItems()
    local sum = 0
    if shoppingCart and #shoppingCart.items > 0 then
        for i = 1, #shoppingCart.items do
            sum = sum + shoppingCart.items[i]['qty']
        end
    end

    return sum
end

function SumBasket()
    local sum = 0
    if shoppingCart and #shoppingCart.items > 0 then
        for i = 1, #shoppingCart.items do
            sum = sum + (shoppingCart.items[i]['qty'] * GetPropPrice(shoppingCart.items[i]['prop']))
        end
    end

    return sum
end

RegisterNetEvent('pw_properties:client:updateItemQty')
AddEventHandler('pw_properties:client:updateItemQty', function(data)
    local qty = tonumber(data.qty.value)
    if qty > 0 then
        local sItem = shoppingCart.items[tonumber(data.piece.value)]
        local exists = CheckItemInBasket(sItem.prop)
        if not exists then
            table.insert(shoppingCart.items, { ['prop'] = sItem.prop, ['qty'] = qty })
        elseif exists > 0 then
            shoppingCart.items[exists].qty = qty
        end
        exports.pw_notify:SendAlert('success', (qty > 0 and 'Items' or 'Item')..' added', 4000)
        TriggerEvent('pw_properties:client:viewCart')
    else
        exports.pw_notify:SendAlert('error', 'Invalid quantity', 3500)
        TriggerEvent('pw_properties:client:viewCart')
    end
end)

RegisterNetEvent('pw_properties:client:changeItemQty')
AddEventHandler('pw_properties:client:changeItemQty', function(item)
    local sItem = shoppingCart.items[item]
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Selected Product<br><b>"..GetFurnitureCategory(sItem.prop).."</b> > <b><span class='text-primary'>"..GetFurnitureLabel(sItem.prop).."</span></b>"},
        { ['type'] = 'hr'},
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Current Quantity<br><b><span class='text-success'>"..sItem.qty.."</span></b>"},
        { ['type'] = 'hr'},
        { ['type'] = 'number', ['label'] = 'Desired Quantity', ['name'] = 'qty'},
        { ['type'] = 'hidden', ['name'] = 'piece', ['value'] = item }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:client:updateItemQty', 'client', form, 'Update item')
end)

RegisterNetEvent('pw_properties:client:confirmRemoveItem')
AddEventHandler('pw_properties:client:confirmRemoveItem', function(data)
    table.remove(shoppingCart.items, tonumber(data.item.value))
    exports.pw_notify:SendAlert('error', 'Item removed from your Shopping Cart', 4000)
    TriggerEvent('pw_properties:client:viewCart')
end)

RegisterNetEvent('pw_properties:client:removeItem')
AddEventHandler('pw_properties:client:removeItem', function(item)
    local sItem = shoppingCart.items[item]
    local form = {
        { ['type'] = 'writting' , ['align'] = 'center', ['value'] = "You are about to <b><span class='text-danger'>remove</span></b><br>"..sItem.qty.."x "..GetFurnitureLabel(sItem.prop).."<br>from your Shopping Cart"},
        { ['type'] = 'hr' },
        { ['type'] = 'writting' , ['align'] = 'center', ['value'] = "Do you wish to remove this item?" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No'},
        { ['type'] = 'hidden', ['name'] = 'item', ['value'] = item }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:client:confirmRemoveItem', 'client', form, 'Update item')
end)

RegisterNetEvent('pw_properties:client:viewCart')
AddEventHandler('pw_properties:client:viewCart', function()
    local items = CountBasketItems()
    if items > 0 then
        local menu = {}
        for i = 1, #shoppingCart.items do
            local sub = {}
            table.insert(sub, { ['label'] = "Change Quantity", ['action'] = 'pw_properties:client:changeItemQty', ['value'] = i, ['triggertype'] = 'client' })
            table.insert(sub, { ['label'] = "<b><span class='text-danger'>Remove</span></b>", ['action'] = 'pw_properties:client:removeItem', ['value'] = i, ['triggertype'] = 'client' })
            table.insert(menu, { ['label'] = "(x"..shoppingCart.items[i].qty..") "..GetFurnitureLabel(shoppingCart.items[i].prop).." - $"..(GetPropPrice(shoppingCart.items[i].prop) * shoppingCart.items[i].qty), ['color'] = 'primary', ['subMenu'] = sub })
        end
        table.insert(menu, { ['label'] = "Total: $"..SumBasket(), ['color'] = 'success' })
        TriggerEvent('pw_interact:generateMenu', menu, "Shopping Cart ("..items.." items)")
    else
        exports.pw_notify:SendAlert('error', 'Your Shopping Cart is empty', 4000)
    end
end)

RegisterNetEvent('pw_properties:client:confirmEmptyCart')
AddEventHandler('pw_properties:client:confirmEmptyCart', function(data)
    shoppingCart = { ['items'] = {} }
    TriggerEvent('pw_properties:client:openFurnitureStore', tonumber(data.store.value))
    exports.pw_notify:SendAlert('inform', 'Your Shopping Cart is now empty', 4000)
end)

RegisterNetEvent('pw_properties:client:clearCart')
AddEventHandler('pw_properties:client:clearCart', function()
    shoppingCart = { ['items'] = {} }
end)

RegisterNetEvent('pw_properties:client:emptyCart')
AddEventHandler('pw_properties:client:emptyCart', function(store)
    local form = {
        { ['type'] = 'writting' , ['align'] = 'center', ['value'] = "You are about to <b><span class='text-danger'>empty</span></b> your cart<br>with <b><span class='text-danger'>"..CountBasketItems().."</span></b> items"},
        { ['type'] = 'hr' },
        { ['type'] = 'writting' , ['align'] = 'center', ['value'] = "Do you wish to continue?" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No'},
        { ['type'] = 'hidden', ['name'] = 'store', ['value'] = store }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:client:confirmEmptyCart', 'client', form, 'Empty Cart')
end)

RegisterNetEvent('pw_properties:client:checkoutCart')
AddEventHandler('pw_properties:client:checkoutCart', function(store)
    local form = {
        { ['type'] = 'writting' , ['align'] = 'center', ['value'] = "You are about to <b><span class='text-success'>complete</span></b> your order<br>with <b><span class='text-danger'>"..CountBasketItems().."</span></b> items<br>for a total of <b><span class='text-success'>$"..SumBasket()..'</span></b>'},
        { ['type'] = 'hr' },
        { ['type'] = 'writting' , ['align'] = 'center', ['value'] = "Do you wish to continue?" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No'},
        { ['type'] = 'hidden', ['name'] = 'store', ['value'] = store }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:client:pickHouse', 'client', form, 'Checkout')
end)

RegisterNetEvent('pw_properties:client:openFurnitureStore')
AddEventHandler('pw_properties:client:openFurnitureStore', function(store)
    if store == nil then store = 1; end
    inDisplayCatalogs = false
    PW.TriggerServerCallback('pw_properties:server:getOwnedProperties', function(props, gang)
        local ownedHouses = props

        if (ownedHouses and #ownedHouses > 0) or gang.gang then
            local menu = {}
            table.insert(menu, { ['label'] = "Order Furniture", ['action'] = "pw_properties:client:orderFurniture", ['value'] = store, ['triggertype'] = "client", ['color'] = "primary" })

            local sub = {}
            table.insert(sub, { ['label'] = "Items: <b><span class='text-primary'>"..CountBasketItems().."</span></b>" })
            table.insert(sub, { ['label'] = "Total: <b><span class='text-success'>$"..SumBasket().."</span></b>" })
            table.insert(sub, { ['label'] = "<b><span class='text-info'>View</span></b>", ['action'] = "pw_properties:client:viewCart", ['value'] = store, ['triggertype'] = "client", ['color'] = "warning" })
            table.insert(sub, { ['label'] = "<b><span class='text-success'>Checkout</span></b>", ['action'] = "pw_properties:client:checkoutCart", ['value'] = store, ['triggertype'] = "client", ['color'] = "warning" })
            table.insert(sub, { ['label'] = "<b><span class='text-danger'>Empty Cart</span></b>", ['action'] = "pw_properties:client:emptyCart", ['value'] = store, ['triggertype'] = "client", ['color'] = "warning" })

            table.insert(menu, { ['label'] = "Shopping Cart", ['action'] = "pw_properties:client:orderFurniture", ['value'] = store, ['triggertype'] = "client", ['color'] = "info", ['subMenu'] = sub })
            TriggerEvent('pw_interact:generateMenu', menu, "Furniture Catalog")
        else
            exports.pw_notify:SendAlert('error', 'You do not own any property', 4000)
        end
    end)
end)

function ChangeFurnitureName(house, fid)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = 'Changing the label of<br><b><span class="text-primary">'..Houses[house].furniture[fid].name..'</span></b>' },
        { ['type'] = 'text', ['label'] = 'New label: <i>(4-15 characters or empty for default)</i>', ['name'] = 'newName' },
        { ['type'] = 'hidden', ['name'] = 'info', ['data'] = {house = house, fid = fid} },
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:changeFurnitureLabel', 'server', form, "Change Furniture Label")
end

RegisterNetEvent('pw_properties:client:changeFurnitureLabel')
AddEventHandler('pw_properties:client:changeFurnitureLabel', function(house, fid)
    ChangeFurnitureName(house, fid)
end)

RegisterNetEvent('pw_properties:client:placeFurniture')
AddEventHandler('pw_properties:client:placeFurniture', function(data)
    if not toggleMod then
        pickedFurniture = data.fid
        PlaceNewFurniture(pickedFurniture)
    else
        exports.pw_notify:SendAlert('error', 'Can\'t place new furniture while in furniture edit mode', 5000)
    end
end)

RegisterNetEvent('pw_properties:client:disposeFurniture')
AddEventHandler('pw_properties:client:disposeFurniture', function(data)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>This action is irreversible</b><br>Are you sure you want to throw this away?' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No'},
        { ['type'] = 'hidden', ['name'] = 'info', ['data'] = {house = data.house, fid = data.fid} }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_properties:server:disposeFurniture', 'server', form, "Disposal confirmation")
end)

RegisterNetEvent('pw_properties:client:retrieveFurnitureStorage')
AddEventHandler('pw_properties:client:retrieveFurnitureStorage', function(data)
    local menu = {}
    if data.where == 'hold' then
        if data.holded then
            local meta = json.decode(data.holded)
            for k,v in pairs(meta) do
                local sub = {}
                table.insert(sub, { ['label'] = 'Retrieve', ['action'] = 'pw_properties:server:getThisHoldPiece', ['value'] = {house = data.house, piece = v, from = 'hold', fid = k, meta = meta}, ['triggertype'] = 'server', ['color'] = 'primary' })
                table.insert(menu, { ['label'] = v.name, ['color'] = 'primary', ['subMenu'] = sub })
            end
        end
    else
        local houseFurniture = Houses[data.where].furniture
        for k,v in pairs(houseFurniture) do
            if v.buyer == playerData.cid then
                local hSub = {}
                table.insert(hSub, { ['label'] = 'Retrieve', ['action'] = 'pw_properties:server:getThisHoldPiece', ['value'] = {house = data.house, piece = v, from = data.where, fid = k}, ['triggertype'] = 'server', ['color'] = 'primary' })
                table.insert(menu, { ['label'] = v.name, ['color'] = 'primary', ['subMenu'] = hSub })
            end
        end
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Retrieve Furniture")
end)

RegisterNetEvent('pw_properties:client:recieveRetrievedFurniture')
AddEventHandler('pw_properties:client:recieveRetrievedFurniture', function(props, house, hold)
    local menu = {}
    
    table.insert(menu, { ['label'] = (hold ~= nil and "Stored away" or "Nothing stored away"), ['action'] = 'pw_properties:client:retrieveFurnitureStorage', ['value'] = {house = house, where = 'hold', holded = hold}, ['triggertype'] = 'client', ['color'] = (hold ~= nil and 'info' or 'danger disabled') })
    
    if props ~= nil and #props > 0 then
        for i = 1, #props do
            table.insert(menu, { ['label'] = Houses[props[i]].name, ['action'] = 'pw_properties:client:retrieveFurnitureStorage', ['value'] = {house = house, where = props[i]}, ['triggertype'] = 'client', ['color'] = 'info' })
        end
    else
        table.insert(menu, { ['label'] = "No owned/rented properties", ['color'] = 'danger disabled' })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Retrieve Furniture")
end)

RegisterNetEvent('pw_properties:client:openStorageRoom')
AddEventHandler('pw_properties:client:openStorageRoom', function(house)
    local menu = {}
    table.insert(menu, { ['label'] = "Retrieve Furniture", ['action'] = 'pw_properties:server:retrieveFurniture', ['value'] = house, ['triggertype'] = 'server', ['color'] = 'info' })
    if Houses[house].furniture ~= nil and #Houses[house].furniture > 0 then
        for k,v in pairs(Houses[house].furniture) do
            if v.delivered and not v.placed and v.buyer == playerData.cid then
                local sub = {}
                table.insert(sub, { ['label'] = 'Place', ['action'] = 'pw_properties:client:placeFurniture', ['value'] = {house = house, fid = k}, ['triggertype'] = 'client', ['color'] = 'primary disabled'})
                table.insert(sub, { ['label'] = 'Change Label', ['action'] = 'pw_properties:client:changeFurnitureLabelMenu', ['value'] = {house = house, fid = k}, ['triggertype'] = 'client', ['color'] = ''})
                table.insert(sub, { ['label'] = '<b><span class="text-danger">Dispose</span></b>', ['action'] = 'pw_properties:client:disposeFurniture', ['value'] = {house = house, fid = k}, ['triggertype'] = 'client', ['color'] = '' })
                table.insert(menu, { ['label'] = v.name, ['color'] = 'primary', ['subMenu'] = sub })
            end
        end
    end
    if #menu <= 1 then
        table.insert(menu, { ['label'] = "Nothing stored here", ['color'] = 'danger disabled' })
    end
    TriggerEvent('pw_interact:generateMenu', menu, "Storage Room | "..Houses[house].name)
end)

function OpenFurnitureMenu(k, outside)
    local itemSub = {}
    table.insert(itemSub, { ['label'] = "Confirm", ['action'] = "pw_properties:server:checkMoneyForStashes", ['value'] = {house = k, type = 'inventory'}, ['triggertype'] = "server", ['color'] = "success" })
    table.insert(itemSub, { ['label'] = "Cancel", ['action'] = "", ['triggertype'] = "", ['color'] = "success" })

    local moneySub = {}
    table.insert(moneySub, { ['label'] = "Confirm", ['action'] = "pw_properties:server:checkMoneyForStashes", ['value'] = {house = k, type = 'money'}, ['triggertype'] = "server", ['color'] = "success" })
    table.insert(moneySub, { ['label'] = "Cancel", ['action'] = "", ['triggertype'] = "", ['color'] = "success" })

    local weaponSub = {}
    table.insert(weaponSub, { ['label'] = "Confirm", ['action'] = "pw_properties:server:checkMoneyForStashes", ['value'] = {house = k, type = 'weapon'}, ['triggertype'] = "server", ['color'] = "success" })
    table.insert(weaponSub, { ['label'] = "Cancel", ['action'] = "", ['triggertype'] = "", ['color'] = "success" })

    local menu = {}
    
    if not Houses[k].hasItems then
        table.insert(menu, { ['label'] = "Buy item stash ($"..Config.StashPrices["inventory"]..")", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "primary", ['subMenu'] = itemSub })
    else
        local itemOnSub = {}
        if not outside then
            table.insert(itemOnSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'items'}, ['triggertype'] = "client", ['color'] = "primary"})
            table.insert(menu, { ['label'] = "Item Stash", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = itemOnSub })
        else
            table.insert(menu, { ['label'] = "Item Stash", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success" })
        end
    end
    if not Houses[k].hasMoney then
        table.insert(menu, { ['label'] = "Buy money stash ($"..Config.StashPrices["money"]..")", ['action'] = "testAction2", ['triggertype'] = "triggerType", ['color'] = "primary", ['subMenu'] = moneySub })
    else
        local moneyOnSub = {}
        if not outside then
            table.insert(moneyOnSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'money'}, ['triggertype'] = "client", ['color'] = "primary"})
            table.insert(menu, { ['label'] = "Money Stash", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = moneyOnSub })
        else
            table.insert(menu, { ['label'] = "Money Stash", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success" })
        end
    end
    if not Houses[k].hasWeapons then
        table.insert(menu, { ['label'] = "Buy weapon stash ($"..Config.StashPrices["weapon"]..")", ['action'] = "testAction3", ['triggertype'] = "triggerType", ['color'] = "primary", ['subMenu'] = weaponSub })
    else
        local weaponsOnSub = {}
        if not outside then
            table.insert(weaponsOnSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'weapons'}, ['triggertype'] = "client", ['color'] = "primary"})
            table.insert(menu, { ['label'] = "Weapon Stash", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = weaponsOnSub })
        else
            table.insert(menu, { ['label'] = "Weapon Stash", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success" })
        end
    end

    if not outside then
        if Houses[k].hasGarage then
            local garageOnSub = {}
            table.insert(garageOnSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'garage'}, ['triggertype'] = "client", ['color'] = "primary"})
            table.insert(menu, { ['label'] = "Garage", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = garageOnSub })
        end

        local clothingSub = {}
        table.insert(clothingSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'clothing'}, ['triggertype'] = "client", ['color'] = "primary"})
        table.insert(menu, { ['label'] = "Wardrobe", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = clothingSub })
        
        if Houses[k].gang_id == 0 then
            local exitEntranceSub = {}
            table.insert(exitEntranceSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'exitEntrance'}, ['triggertype'] = "client", ['color'] = "primary"})
            table.insert(menu, { ['label'] = "Rear Door Entrance (Outside)", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = exitEntranceSub })

            local exitInsideSub = {}
            table.insert(exitInsideSub, { ['label'] = "Change position", ['action'] = "pw_properties:client:changeLuxuryPos", ['value'] = {house = k, type = 'exitInside'}, ['triggertype'] = "client", ['color'] = "primary"})
            table.insert(menu, { ['label'] = "Rear Door Exit (Inside)", ['action'] = "testAction1", ['triggertype'] = "triggerType", ['color'] = "success", ['subMenu'] = exitInsideSub })
        end
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Furniture Management | "..Houses[k].name)
end

function OpenHouseMenu(k, out)
    local menu = {}

    table.insert(menu, { ['label'] = "Luxury Options", ['action'] = "pw_properties:client:openFurnitureMenu", ['value'] = {house = k, outside = (out or false)}, ['triggertype'] = "client", ['color'] = "primary" })   
    if not isMoving and not out and Houses[k].gang_id == 0 then
        table.insert(menu, { ['label'] = "Renting Options", ['action'] = "pw_properties:client:openRentMenu", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "primary" })
    end
    table.insert(menu, { ['label'] = "House Options", ['action'] = "pw_properties:client:openOptionsMenu", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "primary" })
    if not isMoving and not out and Houses[k].gang_id == 0 then
        table.insert(menu, { ['label'] = "Switch Character", ['action'] = "pw_base:switchCharacter", ['triggertype'] = "client", ['color'] = "warning" })
    end
    if out then
        table.insert(menu, { ['label'] = "Payment Collection", ['action'] = "pw_properties:client:checkPayments", ['value'] = {house = k}, ['triggertype'] = "client", ['color'] = "warning" })
    end

    TriggerEvent('pw_interact:generateMenu', menu, (Houses[k].gang_id == 0 and "House" or "Gang HQ") .. " Management | "..Houses[k].name)
end

function TPHouse(house, type)
    local xPos, yPos, zPos
    if type == "enter" then
        SpawnFurniture(house)
        isInside = house
        xPos = tonumber(Houses[house].interior.x)
        yPos = tonumber(Houses[house].interior.y)
        zPos = tonumber(Houses[house].interior.z)
    else
        DeleteFurniture(house)
        isInside = false
        canToggle = false
        xPos = tonumber(Houses[house].entrance.x)
        yPos = tonumber(Houses[house].entrance.y)
        zPos = tonumber(Houses[house].entrance.z)
    end
    if Houses[house].autoLock and (playerData.cid == Houses[house].ownerCid or playerData.cid == Houses[house].rentor) then
        TriggerEvent('pw_properties:client:lockCheck')
    end
    if xPos and yPos and zPos then
        DoScreenFadeOut(500)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
        PW.Game.Teleport(xPos,yPos,zPos)
        Citizen.Wait(1500)
        DoScreenFadeIn(1000)
        TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'housedoor', 0.05, {x = xPos, y = yPos, z = zPos})
        if type == 'enter' then
            if playerData.cid == Houses[house].ownerCid or playerData.cid == Houses[house].rentor then
                exports.pw_notify:SendAlert('inform', 'Press <b><span style="color:#FFFF00">F</span></b> to toggle furniture edit mode', 15000)
                canToggle = true
            end
        end
    end
end

function TPHouseR(house, type)
    local xPos, yPos, zPos
    if type == "enter" then
        SpawnFurniture(house)
        if Houses[house].exitInside.x ~= nil and Houses[house].exitInside.x ~= 0.0 then
            isInside = house
            xPos = tonumber(Houses[house].exitInside.x)
            yPos = tonumber(Houses[house].exitInside.y)
            zPos = tonumber(Houses[house].exitInside.z)
        else
            exports.pw_notify:SendAlert('error', 'You haven\'t set your inside rear exit')
        end
    else
        if Houses[house].exitEntrance.x ~= nil and Houses[house].exitEntrance.x ~= 0.0 then
            DeleteFurniture(house)
            isInside = false
            canToggle = false
            xPos = tonumber(Houses[house].exitEntrance.x)
            yPos = tonumber(Houses[house].exitEntrance.y)
            zPos = tonumber(Houses[house].exitEntrance.z)
        else
            exports.pw_notify:SendAlert('error', 'You haven\'t set your inside rear entrance')
        end
    end
    if Houses[house].autoLock and (playerData.cid == Houses[house].ownerCid or playerData.cid == Houses[house].rentor) then
        TriggerEvent('pw_properties:client:rearlockCheck')
    end
    if xPos and yPos and zPos then
        DoScreenFadeOut(500)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
        PW.Game.Teleport(xPos,yPos,zPos)
        Citizen.Wait(1500)
        DoScreenFadeIn(1000)
        TriggerServerEvent('InteractSound_SV:PlayWithinDistanceCoords', 5.0, 'housedoor', 0.05, {x = xPos, y = yPos, z = zPos})

        if type == 'enter' then
            if playerData.cid == Houses[house].ownerCid or playerData.cid == Houses[house].rentor then
                exports.pw_notify:SendAlert('inform', 'Press <b><span style="color:#FFFF00">F</span></b> to toggle furniture edit mode', 15000)
                canToggle = true
            end
        end
    end
end

function CheckMoving()
    if isMoving == "garage" or isMoving == "exitEntrance" or not isMoving then
        return true
    else
        return false
    end
end

function DrawBlip(house, type)
    if blips[house] ~= nil then
        RemoveBlip(blips[house])
        blips[house] = nil
    end

	local coords = (type == 'gang' and Houses[house].location or Houses[house].entrance)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blip, Config.Blips.blipSprite)
    SetBlipScale(blip, Config.Blips.blipScale)
    SetBlipColour(blip, Config.Blips.color[type])
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    if type == 'owner' then
        AddTextComponentString("Owned Property - "..Houses[house].name)
    elseif type == 'rented' then
        AddTextComponentString("Rented Property - "..Houses[house].name)
    elseif type == 'gang' then
        AddTextComponentString("Gang HQ - "..Houses[house].name)
    end
	EndTextCommandSetBlipName(blip)

	blips[house] = blip
end

function CreateBlips()
    for k,v in pairs(Houses) do
        if playerData then
            if playerData.cid == v.ownerCid then
                DrawBlip(k, 'owner')
            elseif playerData.cid == v.rentor then
                DrawBlip(k, 'rented')
            elseif v.gang_id > 0 and playerData.gang.gang == v.gang_id then
                DrawBlip(k, 'gang')
            end
        end
    end
end

function CreateStoreBlips()
    while not playerLoaded do Wait(10); end
    for i = 1, #Config.FurnitureStore.Stores do
        DrawStoreBlip(i)
    end
end

function DeleteBlips()
    for k,v in pairs(blips) do
        if DoesBlipExist(v) then
            RemoveBlip(v)
        end
    end
end

function DeleteStoreBlips()
    for k,v in pairs(storeBlips) do
        if DoesBlipExist(v) then
            RemoveBlip(v)
        end
    end
end

function RefreshBlips()
    DeleteBlips()
    blips = {}
    CreateBlips()
end
    
local showGarage = false
function ShowGarage(x,y,z)
    Citizen.CreateThread(function()
        while showGarage do
            Citizen.Wait(10)
            if playerLoaded then
                DrawMarker(Config.Marker.markerType, x,y,z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, true, nil, nil, false)
            end
        end
    end)
end

local showFurnitureStore = false
function ShowFurnitureStore(store)
    Citizen.CreateThread(function()
        while showFurnitureStore do
            Citizen.Wait(10)
            if playerLoaded then
                DrawMarker(Config.FurnitureStore.markerType, Config.FurnitureStore.Stores[store].position.x, Config.FurnitureStore.Stores[store].position.y, Config.FurnitureStore.Stores[store].position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.FurnitureStore.markerSize.x, Config.FurnitureStore.markerSize.y, Config.FurnitureStore.markerSize.z, Config.FurnitureStore.markerColor.r, Config.FurnitureStore.markerColor.g, Config.FurnitureStore.markerColor.b, 100, false, true, 2, false, nil, nil, false)
            end
        end
    end)
end

function WaitingKeys(k, type, var)
    Citizen.CreateThread(function()
        while showing == var and not inCam do
            Citizen.Wait(1)
            if playerLoaded then
                if IsControlJustPressed(0,38) then
                    if type == 'exit1' then
                        TriggerEvent('pw_properties:client:enterCheck', 'exit', k)
                    elseif type == 'exit2' then
                        TriggerEvent('pw_properties:client:rearenterCheck', 'exit', k)
                    elseif type == 'menu1' then
                        OpenHouseMenu(k)
                    elseif type == 'menu2' then
                        OpenTenantMenu(k)
                    elseif type == 'weapons' or type == 'items' or type == 'money' or type == 'clothing' then
                        OpenInventoryMenu(k, type)
                    elseif type == 'garage' then
                        if Houses[k].brokenInto == 'police' then
                            if IsPedInAnyVehicle(GLOBAL_PED, false) then
                                TriggerEvent('pw_garage:client:parkWarrant', k)
                            else
                                TriggerEvent('pw_garage:client:openGarageWarrant', k)
                            end
                        else
                            TriggerEvent('pw_garage:client:privateGarage', k)
                        end
                    elseif type == 'store' then
                        TriggerEvent('pw_properties:client:openFurnitureStore', k)
                    end
                end
            end
        end
    end)
end

function CheckIfNearDoor()
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    local dist
    local sendTable = {}
    for k,v in pairs(Houses) do
        dist = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
        if dist <= Config.DrawDistance then
            sendTable = {['house'] = k, ['alarm'] = v.alarm, ['side'] = 'entrance'}
            return sendTable
        else
            dist = #(pedCoords - vector3(v.exitEntrance.x, v.exitEntrance.y, v.exitEntrance.z))
            if dist <= Config.DrawDistance then
                sendTable = {['house'] = k, ['alarm'] = v.alarm, ['side'] = 'exitEntrance'}
                return sendTable
            end
        end
    end

    return 0, false, nil
end

exports('checkIfNearHouse', function()
    return CheckIfNearDoor()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded and GLOBAL_COORDS then
            local ped = GLOBAL_PED
            local pedCoords = GLOBAL_COORDS
            local dist
            for k,v in pairs(Config.FurnitureStore.Stores) do
                dist = #(pedCoords - vector3(v.position.x, v.position.y, v.position.z))
                if dist < Config.FurnitureStore.markerDraw then
                    if not showFurnitureStore then
                        showFurnitureStore = true
                        ShowFurnitureStore(k)
                    end
                    if dist < 2.0 then
                        if not showing then
                            showing = 'store'..k
                            TriggerEvent('pw_drawtext:showNotification', {title = "<span style='font-size:18px' class='text-primary'>"..v.name.."</span>", message = "<span style='font-size:18px;'>Press <span style='color:#187200;'>[E]</span> to open the Furniture Catalog</span>", icon = "fad fa-store-alt"})
                            WaitingKeys(k, 'store', showing)
                        end
                    elseif showing == 'store'..k then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                else
                    if showFurnitureStore then showFurnitureStore = false; end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded and GLOBAL_COORDS then
            local ped = GLOBAL_PED
            local pedCoords = GLOBAL_COORDS
            local dist, door
            for k,v in pairs(Houses) do
                if v.gang_id == 0 then
                    if CheckMoving() then
                        dist = #(pedCoords - vector3(v.entrance.x, v.entrance.y, v.entrance.z))
                        if dist < Config.DrawDistance then
                            if playerData.cid ~= v.ownerCid and playerData.cid ~= v.rentor then
                                door = ""
                            else
                                door = "~g~Unlocked"
                                if v.doorStatus then
                                    door = "~r~Locked"
                                end
                            end
                            if not showing then
                                showing = k..'-entrance'
                                sendNUI("show", "frontdoor", v, playerData)
                            end
                        elseif showing == k..'-entrance' then 
                            showing = false
                            sendNUI("hide", "frontdoor") 
                        end

                        if v.exitEntrance.x ~= 0.0 and v.exitEntrance.y ~= 0.0 and v.exitEntrance.z ~= 0.0 then
                            dist = #(pedCoords - vector3(v.exitEntrance.x, v.exitEntrance.y, v.exitEntrance.z))
                            if dist < Config.DrawDistance then
                                if playerData.cid ~= v.ownerCid and playerData.cid ~= v.rentor then
                                    door = ""
                                else
                                    door = "~g~Unlocked"
                                    if v.doorStatus then
                                        door = "~r~Locked"
                                    end
                                end
                                if not showing then
                                    showing = k..'-exitEntrance'
                                    sendNUI("show", "backdoor", v, playerData)
                                end
                            elseif showing == k..'-exitEntrance' then 
                                showing = false
                                sendNUI("hide", "backdoor")
                            end
                        end

                        dist = #(pedCoords - vector3(v.exit.x, v.exit.y, v.exit.z))
                        if dist < Config.DrawDistance then
                            if playerData.cid ~= v.ownerCid and playerData.cid ~= v.rentor then
                                door = ""
                            else
                                door = "~g~Unlocked"
                                if v.doorStatus then
                                    door = "~r~Locked"
                                end
                            end
                            if not showing then
                                showing = k..'-exit1'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'exit1', showing)
                                    end
                                end
                                sendNUI("show", "exit", v, playerData)
                            end
                        elseif showing == k..'-exit1' then
                            showing = false
                            sendNUI("hide", "exit")
                        end

                        if v.exitInside.x ~= 0.0 and v.exitInside.y ~= 0.0 and v.exitInside.z ~= 0.0 then
                            dist = #(pedCoords - vector3(v.exitInside.x, v.exitInside.y, v.exitInside.z))
                            if dist < Config.DrawDistance then
                                if playerData.cid ~= v.ownerCid and playerData.cid ~= v.rentor then
                                    door = ""
                                else
                                    door = "~g~Unlocked"
                                    if v.doorStatus then
                                        door = "~r~Locked"
                                    end
                                end
                                if not showing then
                                    showing = k..'-exit2'
                                    if Config.EnableKeys then
                                        if dist < 1.5 then
                                            WaitingKeys(k, 'exit2', showing)
                                        end
                                    end
                                    sendNUI("show", "exit", v, playerData)
                                end
                            elseif showing == k..'-exit2' then 
                                showing = false
                                sendNUI("hide", "exit")
                            end
                        end
                    end
                end

                if not isMoving then
                    if playerData.cid == v.ownerCid or isGangBoss == v.gang_id then
                        dist = #(pedCoords - vector3(v.ownerMenu.x, v.ownerMenu.y, v.ownerMenu.z))
                        if dist < Config.DrawDistance then
                            if not showing then
                                showing = k..'-menu1'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'menu1', showing)
                                    end
                                end
                                sendNUI("show", "menu1", v, playerData)
                            end
                        elseif showing == k..'-menu1' then 
                            showing = false
                            sendNUI("hide", "menu1")
                        end
                    elseif playerData.cid == v.rentor and v.propertyRented then
                        dist = #(pedCoords - vector3(v.ownerMenu.x, v.ownerMenu.y, v.ownerMenu.z))
                        if dist < Config.DrawDistance then
                            if not showing then
                                showing = k..'-menu2'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'menu2', showing)
                                    end
                                end
                                sendNUI("show", "menu2", v, playerData)
                            end
                        elseif showing == k..'-menu2' then 
                            showing = false
                            sendNUI("hide", "menu2")
                        end
                    end

                    if ((v.hasGarage and isGangAuthed == v.gang_id) or (not v.propertyRented and playerData.cid == v.ownerCid and v.hasGarage) or (playerData.cid == v.rentor and v.hasGarage) or (v.hasGarage and v.brokenInto == 'police')) and v.garage.x ~= 0.0 and v.garage.y ~= 0.0 and v.garage.z ~= 0.0 then
                        dist = #(pedCoords - vector3(v.garage.x, v.garage.y, v.garage.z))
                        if dist < 4.0 then
                            if not showGarage then
                                showGarage = true
                                ShowGarage(v.garage.x, v.garage.y, v.garage.z)
                            end
                            if not showing then
                                showing = k..'-garage'
                                TriggerEvent('pw_garage:client:showPrivateInfo', k)
                                WaitingKeys(k, 'garage', showing)
                            end
                        elseif showing == k..'-garage' then 
                            showing = false
                            TriggerEvent('pw_garage:client:hidePrivateInfo', k)
                            if showGarage then showGarage = false; end
                        end
                    end

                    if ((v.hasWeapons and isGangAuthed == v.gang_id) or (not v.propertyRented and playerData.cid == v.ownerCid and v.hasWeapons) or (playerData.cid == v.rentor and v.hasWeaponsRent) or ((v.hasWeapons or v.hasWeaponsRent) and v.brokenInto)) and v.weapons.x ~= 0.0 and v.weapons.y ~= 0.0 and v.weapons.z ~= 0.0 then
                        dist = #(pedCoords - vector3(v.weapons.x, v.weapons.y, v.weapons.z))
                        if dist < Config.DrawDistance then
                            if not showing then
                                showing = k..'-weapon'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'weapons', showing)
                                    end
                                end 
                                TriggerEvent('pw_inventory:client:secondarySetup', "weapon", { type = ((v.hasWeapons and isGangAuthed == v.gang_id) and 32 or 20), owner = k, name = Houses[k].name })
                                sendNUI("show", "weapons", v, playerData)
                            end
                        elseif showing == k..'-weapon' then 
                            showing = false
                            TriggerEvent('pw_inventory:client:removeSecondary', "weapon")
                            sendNUI("hide", "weapons")                      
                        end
                    end

                    if ((v.hasItems and isGangAuthed == v.gang_id) or (not v.propertyRented and playerData.cid == v.ownerCid and v.hasItems) or (playerData.cid == v.rentor and v.hasItemsRent) or ((v.hasItems or v.hasItemsRent) and v.brokenInto)) and v.items.x ~= 0.0 and v.items.y ~= 0.0 and v.items.z ~= 0.0 then
                        dist = #(pedCoords - vector3(v.items.x, v.items.y, v.items.z))
                        if dist < Config.DrawDistance then
                            if not showing then
                                showing = k..'-inventory'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'items', showing)
                                    end
                                end
                                TriggerEvent('pw_inventory:client:secondarySetup', "property", { type = ((v.hasItems and isGangAuthed == v.gang_id) and 22 or Houses[k].storageLimit.id), owner = k, name = Houses[k].name })
                                sendNUI("show", "inventory", v, playerData)
                            end
                        elseif showing == k..'-inventory' then 
                            showing = false
                            TriggerEvent('pw_inventory:client:removeSecondary', "property")
                            sendNUI("hide", "inventory")                  
                        end
                    end

                    if ((v.hasMoney and isGangAuthed == v.gang_id) or (not v.propertyRented and playerData.cid == v.ownerCid and v.hasMoney) or (playerData.cid == v.rentor and v.hasMoneyRent) or ((v.hasMoney or v.hasMoneyRent) and v.brokenInto)) and v.money.x ~= 0.0 and v.money.y ~= 0.0 and v.money.z ~= 0.0  then
                        dist = #(pedCoords - vector3(v.money.x, v.money.y, v.money.z))
                        if dist < Config.DrawDistance then
                            if not showing then
                                showing = k..'-money'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'money', showing)
                                    end
                                end
                                sendNUI("show", "money", v, playerData)
                            end
                        elseif showing == k..'-money' then 
                            showing = false
                            sendNUI("hide", "money")
                        end
                    end

                    if (isGangAuthed == v.gang_id or (not v.propertyRented and playerData.cid == v.ownerCid) or (playerData.cid == v.rentor)) and v.clothing.x ~= 0.0 and v.clothing.y ~= 0.0 and v.clothing.z ~= 0.0 then
                        dist = #(pedCoords - vector3(v.clothing.x, v.clothing.y, v.clothing.z))
                        if dist < Config.DrawDistance then
                            if not showing then
                                showing = k..'-clothing'
                                if Config.EnableKeys then
                                    if dist < 1.5 then
                                        WaitingKeys(k, 'clothing', showing)
                                    end
                                end
                                sendNUI("show", "clothing", v, playerData)
                            end
                        elseif showing == k..'-clothing' then 
                            showing = false
                            sendNUI("hide", "clothing")
                        end
                    end
                end
            end
        end     
    end
end)

function DrawStoreBlip(store)
    if storeBlips[store] ~= nil then
        RemoveBlip(storeBlips[store])
        storeBlips[store] = nil
    end

    local blip = AddBlipForCoord(Config.FurnitureStore.Stores[store].position.x, Config.FurnitureStore.Stores[store].position.y, Config.FurnitureStore.Stores[store].position.z)

	SetBlipSprite(blip, Config.FurnitureStore.blipSprite)
    SetBlipScale(blip, Config.FurnitureStore.blipScale)
    SetBlipColour(blip, Config.FurnitureStore.blipColor)
    
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.FurnitureStore.Stores[store].name)
    EndTextCommandSetBlipName(blip)
    
    storeBlips[store] = blip
end

function DoRequestModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end
end

function DoRequestAnimSet(anim)
	RequestAnimDict(anim)
	while not HasAnimDictLoaded(anim) do
		Citizen.Wait(1)
	end
end
----------------------------------------
-- FOR DEV PURPOSES, DELETE WHEN RELEASE
----------------------------------------
RegisterNetEvent('pw_properties:client:setOwner')
AddEventHandler('pw_properties:client:setOwner', function(cid)
    Houses[1].ownerCid = cid
    Houses[1].rentor = 8278442
end)

RegisterNetEvent('pw_properties:client:setRentor')
AddEventHandler('pw_properties:client:setRentor', function(cid)
    Houses[1].rentor = cid
    Houses[1].ownerCid = 8278442
end)
-----------------------------------------

RegisterNetEvent('pw_furn:client:nuiClosed')
AddEventHandler('pw_furn:client:nuiClosed', function()
    furnMenu = false
    if isMoving == 'new' then exports.pw_notify:PersistentAlert('end', 'newFurn'); end
    isMoving = false
    movingHouse = false
end)

RegisterNUICallback("furnitureSave", function(data, cb)
    if pickedObj then
        local processed = false
        local objPos = GetEntityCoords(pickedObj)
        local objH = GetEntityHeading(pickedObj)
        local pedCoords = GLOBAL_COORDS
        if Houses[isInside].gang_id == 0 then
            local ret, newZ = GetGroundZFor_3dCoord(pedCoords.x, pedCoords.y, pedCoords.z, 0)
            local objret, objnewZ = GetGroundZFor_3dCoord(objPos.x, objPos.y, objPos.z, 0)
            if objnewZ and objnewZ ~= 0.0 then
                if (objPos.z - newZ) < Houses[isInside].furnitureZ then
                    if (newZ - objPos.z) < 0.2 then
                        local newPos = { ['x'] = objPos.x, ['y'] = objPos.y, ['z'] = objPos.z, ['h'] = objH }
                        processed = newPos
                        if Houses[isInside].furniture[pickedFurniture].name == GetFurnitureLabel(Houses[isInside].furniture[pickedFurniture].prop) then
                            ChangeFurnitureName(isInside, pickedFurniture)
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'Incorrect positioning (object below ground)', 5000)
                    end
                else
                    exports.pw_notify:SendAlert('error', 'Incorrect positioning (object above ceiling)', 5000)
                end
            else
                exports.pw_notify:SendAlert('error', 'Incorrect positioning (object outside property)', 5000)
            end
        else
            local check = exports.pw_gangs:checkPoly('poly', objPos, Houses[isInside].gang_id)
            if check then
                local newPos = { ['x'] = objPos.x, ['y'] = objPos.y, ['z'] = objPos.z, ['h'] = objH }
                processed = newPos
                if Houses[isInside].furniture[pickedFurniture].name == GetFurnitureLabel(Houses[isInside].furniture[pickedFurniture].prop) then
                    ChangeFurnitureName(isInside, pickedFurniture)
                end
            else
                exports.pw_notify:SendAlert('error', 'Incorrect positioning (object outside property boundaries)', 5000)
            end
        end
        StopMoving(nil, pickedObj)
        if processed then 
            TriggerServerEvent('pw_properties:server:updateFurniturePos', isInside, pickedFurniture, processed)
        else
            SpawnFurniture(isInside)
        end
        pickedFurniture, pickedObj = false, nil
    end
end)

RegisterNUICallback("furnitureReset", function(data, cb)
    if pickedObj then
        SetEntityCoordsNoOffset(pickedObj, tonumber(data.defaultP.x), tonumber(data.defaultP.y), tonumber(data.defaultP.z))
        SetEntityHeading(pickedObj, tonumber(data.defaultP.h) + 0.0)
    end
end)

RegisterNUICallback("furnitureCancel", function(data, cb)
    if pickedObj then
        StopMoving(nil, pickedObj)
        SpawnFurniture(isInside)
        pickedFurniture, pickedObj = false, nil
    end
end)

RegisterNUICallback("furnitureXUpdate", function(data, cb)
    if pickedObj then
        SetEntityCoordsNoOffset(pickedObj, tonumber(data.newvalue), tonumber(data.prevPos.y), tonumber(data.prevPos.z), 0.0, 0.0, 0.0, false)
    end
end)

RegisterNUICallback("furnitureYUpdate", function(data, cb)
    if pickedObj then
        SetEntityCoordsNoOffset(pickedObj, tonumber(data.prevPos.x), tonumber(data.newvalue), tonumber(data.prevPos.z), 0.0, 0.0, 0.0, false)
    end
end)

RegisterNUICallback("furnitureZUpdate", function(data, cb)
    if pickedObj then
        SetEntityCoordsNoOffset(pickedObj, tonumber(data.prevPos.x), tonumber(data.prevPos.y), tonumber(data.newvalue), 0.0, 0.0, 0.0, false)
    end
end)

RegisterNUICallback("furnitureHUpdate", function(data, cb)
    if pickedObj then
        SetEntityHeading(pickedObj, tonumber(data.newvalue) + 0.0)
    end
end)

function PlaceNewFurniture(furn)
    if not furnMenu and not pickedObj then
        furnMenu = true
        isMoving = 'new'
        movingHouse = isInside
        PW.Game.SpawnObjectNoOffset(Houses[isInside].furniture[furn].prop, Houses[isInside].charSpawn, function(obj)
            pickedObj = obj
            while pickedObj == nil do Wait(10); end
            FreezeEntityPosition(pickedObj, true)
            local initialCoords = Houses[isInside].charSpawn
            local initialH = Houses[isInside].charSpawn.h
            local x, y, z, h = initialCoords.x, initialCoords.y, initialCoords.z, initialH

            TriggerEvent('pw_furn:client:openNui', GetCurrentResourceName(), { ['x'] = x, ['y'] = y, ['z'] = z, ['h'] = h }, false)
            exports.pw_notify:PersistentAlert('start', 'newFurn', 'inform', 'Placing a new piece of furniture<br>Press <b><span style="color: #FFFF00">M</span></b> to toggle between the menu and the ped', {styling})
            
            local _, nearestMaxV = GetModelDimensions(Houses[isInside].furniture[furn].prop)
            Citizen.CreateThread(function()
                while playerLoaded and isInside and pickedFurniture == furn and furnMenu and pickedObj and not inCam do
                    Citizen.Wait(1)
                    local coords = GetEntityCoords(pickedObj)
                    DrawMarker(Config.Marker.markerType, coords.x, coords.y, coords.z + nearestMaxV.z + 0.145, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)

                    if IsControlJustPressed(0, 244) then
                        TriggerEvent('pw_furn:client:fadeBack')
                    end
                end
            end)
        end)
    end
end

function EditFurniture(furn)
    if not furnMenu and not pickedObj then
        furnMenu = true
        isMoving = true
        movingHouse = isInside
        local foundObj = spawnedFurniture[isInside][furn].obj
        local foundPos = GetEntityCoords(foundObj)
        local foundH = GetEntityHeading(foundObj)
        TriggerServerEvent('pw_properties:server:deleteFurnitureForEveryone', isInside, furn)
        Wait(100)
        PW.Game.SpawnObjectNoOffset(Houses[isInside].furniture[furn].prop, foundPos, function(obj)
            pickedObj = obj
            SetEntityHeading(pickedObj, foundH)
        end)
        while pickedObj == nil do Wait(10); end
        FreezeEntityPosition(pickedObj, true)
        local initialCoords = GetEntityCoords(pickedObj)
        local initialH = GetEntityHeading(pickedObj)
        local x, y, z, h = initialCoords.x, initialCoords.y, initialCoords.z, initialH
        if x and x ~= 0 and y and y ~= 0 and z and z ~= 0 then
            TriggerEvent('pw_furn:client:openNui', GetCurrentResourceName(), { ['x'] = x, ['y'] = y, ['z'] = z, ['h'] = h })

            Citizen.CreateThread(function()
                while playerLoaded and isInside and pickedFurniture == furn and furnMenu and not inCam do
                    Citizen.Wait(1)
                    if IsControlJustPressed(0, 244) then
                        TriggerEvent('pw_furn:client:fadeBack')
                    end
                end
            end)
        else
            StopMoving(nil, pickedObj)
            SpawnFurniture(isInside)
            pickedObj, pickedFurniture = nil, false
        end
    end
end

function ManageEditMod()
    toggleMod = not toggleMod
    if toggleMod then
        exports.pw_notify:PersistentAlert('start', 'editFurn', 'inform', 'You are now in furniture edit mod<br>Press <b><span style="color:#FFFF00">F</span></b> again to return to normal<br>Press <b><span style="color:#FFFF00">G</span></b> near a furniture object to edit it<br>Press <b><span style="color:#FFFF00">M</span></b> to toggle focus between the menu and the ped')
        
        local nearest, nearestMaxV, nearestDist
        Citizen.CreateThread(function()
            while playerLoaded and playerData and toggleMod and isInside do
                if Houses[isInside].furniture ~= nil and #Houses[isInside].furniture then
                    for k,v in pairs(Houses[isInside].furniture) do
                        if v.delivered and v.placed and playerData.cid == v.buyer then
                            local dist = #(GLOBAL_COORDS - vector3(v.position.x, v.position.y, v.position.z))
                            if dist < 3.0 then
                                if not nearestDist or dist < nearestDist then
                                    nearestDist = dist
                                    nearest = k
                                    _, nearestMaxV = GetModelDimensions(v.prop)
                                    Citizen.CreateThread(function()
                                        while nearest == k do
                                            nearestDist = #(GLOBAL_COORDS - vector3(Houses[isInside].furniture[nearest].position.x, Houses[isInside].furniture[nearest].position.y, Houses[isInside].furniture[nearest].position.z))
                                            Citizen.Wait(1)
                                        end
                                    end)
                                end
                            elseif nearest == k then
                                if pickedObj then StopMoving((isMoving == 'new' and 1 or nil), pickedObj); SpawnFurniture(isInside); end
                                pickedFurniture, pickedObj = false, nil                                
                                nearest, nearestMaxV, nearestDist, pickedFurniture, pickedObj = nil, nil, nil, false, nil
                                if furnMenu then TriggerEvent('pw_furn:client:closeNui'); end
                            end
                        end
                    end
                end
                Citizen.Wait(100)
            end
            nearest, nearestMaxV, nearestDist, pickedFurniture, pickedObj = nil, nil, nil, false, nil
            if furnMenu then TriggerEvent('pw_furn:client:closeNui'); end
        end)

        Citizen.CreateThread(function()
            while playerLoaded and toggleMod and isInside and not inCam do
                Citizen.Wait(1)
                if nearest then
                    local color
                    if not pickedFurniture then color = {255, 0, 0} else color = {0, 255, 0}; end
                    local coords = (pickedObj and GetEntityCoords(pickedObj) or vector3(Houses[isInside].furniture[nearest].position.x, Houses[isInside].furniture[nearest].position.y, Houses[isInside].furniture[nearest].position.z))
                    DrawMarker(Config.Marker.markerType, coords.x, coords.y, coords.z + nearestMaxV.z + 0.145, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, color[1], color[2], color[3], 100, false, true, 2, false, nil, nil, false)

                    if IsControlJustPressed(0, 47) then -- G
                        if pickedFurniture ~= nearest then
                            pickedFurniture = nearest
                            EditFurniture(pickedFurniture)
                        elseif pickedFurniture == nearest then
                            pickedFurniture = false
                            TriggerEvent('pw_furn:client:closeNui')
                        end
                    end
                end
            end
        end)
    else
        if pickedObj then StopMoving((isMoving == 'new' and 1 or nil), pickedObj); SpawnFurniture(isInside); end
        pickedFurniture, pickedObj = false, nil
        if furnMenu then TriggerEvent('pw_furn:client:closeNui'); end
        exports.pw_notify:PersistentAlert('end', 'editFurn')
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playerLoaded and isInside and canToggle and not inCam then 
            if IsControlJustPressed(0, 23) then -- F
                ManageEditMod()
            end
        end
    end
end)

RegisterNetEvent('pw_properties:client:camDisabled')
AddEventHandler('pw_properties:client:camDisabled', function()
    inCam = false
end)

RegisterNetEvent('pw_properties:client:cam')
AddEventHandler('pw_properties:client:cam', function(k)
    if not inCam then
        local targetHouse = k or isInside
        inCam = targetHouse
        if Houses[targetHouse].hasCams and Houses[targetHouse].cams then
            TriggerEvent('pw_cams:client:enableCam', Houses[targetHouse])
        else
            if not Houses[targetHouse].hasCams then
                exports.pw_notify:SendAlert('error', 'You don\'t own a security camera system', 4000)
            else
                exports.pw_notify:SendAlert('error', 'Your security camera system is disabled', 4000)
            end
        end
    end
end)