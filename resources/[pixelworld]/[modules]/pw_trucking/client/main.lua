
PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

local playerCurrentlyAnimated, playerCurrentlyHasProp, firstAnim, playerPropList = false, false, true, {}
local LastAD, LastA, LastBody = nil, nil, nil
local showingDeliveryMarker, showingDepotDrawText, deliveryblip, onDelivery, blips = false, false, nil, false, {}
local charVehicleInfo = {['truck'] = 0, ['trailer'] = 0}
local currentDeliveryInfo = { ['type'] = 'regular', ['startDepot'] = 0, ['fuelStations'] = 0, ['foodDelivery'] = 0}

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
            if playerData.job.name == "trucker" then
                createBlips()
            end
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
        destroyBlips()
        TriggerEvent('pw_trucking:client:cancelCurrentDelivery')
        TriggerEvent('pw_trucking:StopAnimation')
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
    if playerData ~= nil then
        playerData.job = data
        if playerData.job.name == "trucker" then
            createBlips()
        else
            destroyBlips()
        end
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
        if playerData.job.name == "trucker" and onDelivery then
            TriggerEvent('pw_trucking:client:cancelCurrentDelivery')
        end
    end
end)


function MarkerDrawDelivery(x, y, z)
    Citizen.CreateThread(function()
        while characterLoaded and showingDeliveryMarker do
            Citizen.Wait(1)   
            DrawMarker(Config.DeliveryMarker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.DeliveryMarker.markerSize.x, Config.DeliveryMarker.markerSize.y, Config.DeliveryMarker.markerSize.z, Config.DeliveryMarker.markerColor.r, Config.DeliveryMarker.markerColor.g, Config.DeliveryMarker.markerColor.b, 100, true, true, 2, true, nil, nil, false)          
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded then
            if playerData.job.name == 'trucker' then
                for k,v in pairs(Config.TruckingPoints) do
                    for x,y in pairs(v.locations) do
                        local dist = #(GLOBAL_COORDS - vector3(y.coords.x, y.coords.y, y.coords.z))
                        if dist < 4.0 then
                            if not showingDepotDrawText then
                                showingDepotDrawText = k..x
                                DrawDepotText(k, x, showingDepotDrawText)
                            end
                        elseif showingDepotDrawText == k..x then
                            showingDepotDrawText = false
                            TriggerEvent('pw_drawtext:hideNotification')
                            TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                        end
                    end
                end
            elseif showingDepotDrawText then
                showingDepotDrawText = false
                TriggerEvent('pw_drawtext:hideNotification')
            end
        end  
    end
end)

function DrawDepotText(depot, type, var)
    local title, message, icon, key
    if type == 'depot' then
        title = "Truck Depot | " .. Config.TruckingPoints[depot].depotName
        message = "<span style='font-size:25px'>Access Truck Depot" .. (playerData.job.duty and "" or " and Go <span class='danger'>On Duty</span>") .. "</b></span>"
        icon = "fad fa-truck"
        key = "Access Truck Depot"
    end 
    if title ~= nil and message ~= nil and icon ~= nil and key ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
        TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = key}})
    end

    Citizen.CreateThread(function()
        while showingDepotDrawText == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'depot' then
                    TriggerEvent('pw_trucking:client:openDepotMenu', depot)   
                end
            end
        end
    end)
end

RegisterNetEvent('pw_trucking:client:openDepotMenu')
AddEventHandler('pw_trucking:client:openDepotMenu', function(depot)
    local menu = {
        { ['label'] = 'Go ' .. (playerData.job.duty and 'Off' or 'On') .. ' Duty', ['action'] = 'pw_trucking:server:toggleDuty', ['value'] = depot, ['triggertype'] = 'server', ['color'] = (playerData.job.duty and 'danger' or 'success')}
    }
    if playerData.job.name == 'trucker' and playerData.job.duty then
        table.insert(menu, { ['label'] = (onDelivery and 'Cancel Current Trucking Delivery' or 'Start New Delivery'), ['action'] = (onDelivery and 'pw_trucking:client:cancelCurrentDelivery' or 'pw_trucking:client:openDeliveryStart'), ['value'] = depot, ['triggertype'] = 'client', ['color'] = (onDelivery and 'danger' or 'success')})
    end
    TriggerEvent('pw_interact:generateMenu', menu, "Trucker Depot | " .. Config.TruckingPoints[depot].depotName)
end)

RegisterNetEvent('pw_trucking:client:openDeliveryStart')
AddEventHandler('pw_trucking:client:openDeliveryStart', function(depot)
    local menu = {}
    if depot ~= nil then
        PW.TriggerServerCallback('pw_trucking:server:getDepotDeliveries', function(data)
            for k,v in pairs(Config.DeliveryTypesPerWareHouse[depot]) do
                local wareHouseAmount = data[k].warehouseAmount
                table.insert(menu, { ['label'] = v.name .. ' | ' .. (wareHouseAmount > 0 and 'Deliveries: ' .. wareHouseAmount or 'No Deliveries Available'), ['action'] = 'pw_trucking:client:startTruckDelivery', ['value'] = { ['type'] = k, ['depot'] = depot}, ['triggertype'] = 'client', ['color'] = (wareHouseAmount > 0 and 'info' or 'info disabled')}) 
            end
            table.sort(menu, function(a,b) return a.label < b.label end)
            TriggerEvent('pw_interact:generateMenu', menu, "Available Deliveries | " .. Config.TruckingPoints[depot].depotName)
        end, depot)
    end
end)

RegisterNetEvent('pw_trucking:client:cancelCurrentDelivery')
AddEventHandler('pw_trucking:client:cancelCurrentDelivery', function(depot)
    if characterLoaded and onDelivery then
        RemoveDeliveryBlip()
        onDelivery = false
        TriggerEvent('pw_trucking:StopAnimation')
        charVehicleInfo = { ['truck'] = 0, ['trailer'] = 0 }
        currentDeliveryInfo = { ['type'] = 'regular', ['startDepot'] = 0, ['fuelStations'] = 0, ['foodDelivery'] = 0}
        TriggerEvent('pw_trucking:client:openDepotMenu', depot)
    end
end)

RegisterNetEvent('pw_trucking:client:startTruckDelivery')
AddEventHandler('pw_trucking:client:startTruckDelivery', function(data)
    if data ~= nil then
        local depot, type = data.depot, data.type
        if Config.DeliveryTypesPerWareHouse[depot][type] ~= nil then
            local spawnCoords = Config.TruckingPoints[depot].spawnCoords
            local spawnID = 0
            for i = 1, #spawnCoords do
                local trailerCoords = spawnCoords[i].trailer
                local truckCoords = spawnCoords[i].truck
                local cV = GetClosestVehicle(trailerCoords.x, trailerCoords.y, trailerCoords.z, 10.0, 0, 71)
                local cv2 = GetClosestVehicle(truckCoords.x, truckCoords.y, truckCoords.z, 10.0, 0, 71)
                if (cV == 0 or cV == nil) and (cV2 == 0 or c2 == nil) then
                    spawnID = i
                    break
                else
                    spawnID = 0
                end
            end
            if spawnID ~= 0 then
                PW.TriggerServerCallback('pw_trucking:server:canStartDelivery', function(yes)
                    if yes then
                        local trailerCoords = Config.TruckingPoints[depot].spawnCoords[spawnID].trailer
                        local truckCoords = Config.TruckingPoints[depot].spawnCoords[spawnID].truck
                        local vehicleModels = Config.Vehicles[type]
                        local truckModel = vehicleModels.truck[math.random(1, #vehicleModels.truck)]
                        PW.Game.SpawnOwnedVehicle(truckModel, truckCoords, truckCoords.h, function(spawnedTruck)
                            -- give keys ect
                            charVehicleInfo.truck = spawnedTruck
                        end)

                        if vehicleModels.trailer ~= nil then
                            local trailerModel = vehicleModels.trailer[math.random(1, #vehicleModels.trailer)]
                            PW.Game.SpawnOwnedVehicle(trailerModel, trailerCoords, trailerCoords.h, function(spawnedTrailer)
                                -- give keys ect
                                charVehicleInfo.trailer = spawnedTrailer
                            end)
                            Citizen.Wait(350)
                            AttachVehicleToTrailer(charVehicleInfo.truck, charVehicleInfo.trailer, 100)
                        else
                            charVehicleInfo.trailer = 0
                        end
                        exports.pw_notify:SendAlert('success', 'The Vehicle Has Been Spawned - Locate It And Get In', 5000)
                        Citizen.Wait(6000)
                        onDelivery = true
                        currentDeliveryInfo.type = type
                        currentDeliveryInfo.startDepot = depot
                        if type == 'regular' then
                            startRegularDelivery()
                        elseif type == 'specialist' then
                            startSpecialistDelivery()
                        elseif type == 'fuel' then
                            startFuelDelivery()
                        elseif type == 'food' then
                            currentDeliveryInfo.foodDelivery = 3
                            startFoodDelivery()
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'Error Starting Delivery', 2500)
                    end
                end, depot, type)
            else
                exports.pw_notify:SendAlert('error', 'There is a Vehicle Blocking the Spawn Point', 2500)
            end
        end
    end
end)

function startRegularDelivery()
    local deliveryLocation = Config.DeliveryPoints.regular[math.random(1, #Config.DeliveryPoints.regular)]
    local street, cross = GetStreetNameAtCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    local deliveryStreet = GetStreetNameFromHashKey(street)
    local tonne = math.random(15,30)
    exports.pw_notify:SendAlert('info', 'Started Regular Delivery<br>Destination: '.. deliveryStreet .. '<br>Weight (Tonnes): '.. tonne, 10000)
    CreateDeliveryBlip(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
            if dist < 30.0 then
                if not showingDeliveryMarker then
                    showingDeliveryMarker = true
                    MarkerDrawDelivery(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
                end
                if dist < 2.0 then
                    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED, false)
                    local pedHasTrailer, pedTrailerID = GetVehicleTrailerVehicle(pedVeh)
                    if (pedVeh == charVehicleInfo.truck) and (pedTrailerID == charVehicleInfo.trailer) then
                        exports.pw_notify:SendAlert('info', 'Whilst Waiting - Make Sure You Are Safely Parked so the Trailer can Be Unloaded. ', 10000)
                        Citizen.Wait(10000)
                        dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
                        if dist < 5.0 then -- Double Check if still in area
                            TriggerEvent('pw:progressbar:progress', 
                            {
                                name = 'unloading_goods_reg',
                                duration = (tonne * 1000),
                                label = 'Unloading Trailer',
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = { disableMovement = false, disableCarMovement = true, disableMouse = false, disableCombat = false, },
                            }, function(status)
                                if not status then
                                    showingDeliveryMarker = false
                                    pleaseReturnVehicleTo(currentDeliveryInfo.startDepot)
                                end
                            end)
                            break
                        else
                            exports.pw_notify:SendAlert('error', 'Moved Away From the Unloading Area. Move Back.', 2500)
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'Not using the Original Truck and/or the Used Trailer is Missing/Incorrect', 4000)
                    end
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end

function startSpecialistDelivery()
    local deliveryLocation = Config.DeliveryPoints.specialist[math.random(1, #Config.DeliveryPoints.specialist)]
    local street, cross = GetStreetNameAtCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    local deliveryStreet = GetStreetNameFromHashKey(street)
    exports.pw_notify:SendAlert('info', 'Started Specialist Delivery<br>Destination: '.. deliveryStreet, 10000)
    CreateDeliveryBlip(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
            if dist < 30.0 then
                if not showingDeliveryMarker then
                    showingDeliveryMarker = true
                    MarkerDrawDelivery(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
                end
                if dist < 2.0 then
                    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED, false)
                    local pedHasTrailer, pedTrailerID = GetVehicleTrailerVehicle(pedVeh)
                    if (pedVeh == charVehicleInfo.truck) and (pedTrailerID == charVehicleInfo.trailer) then
                        exports.pw_notify:SendAlert('info', 'Whilst Waiting - Make Sure You Are Safely Parked so the Trailer can Be Unloaded. ', 10000)
                        Citizen.Wait(10000)
                        dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
                        if dist < 5.0 then -- Double Check if still in area
                            TriggerEvent('pw:progressbar:progress', 
                            {
                                name = 'unloading_goods_reg',
                                duration = 20000,
                                label = 'Unloading Trailer',
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = { disableMovement = false, disableCarMovement = true, disableMouse = false, disableCombat = false, },
                            }, function(status)
                                if not status then
                                    showingDeliveryMarker = false
                                    pleaseReturnVehicleTo(currentDeliveryInfo.startDepot)
                                end
                            end)
                            break
                        else
                            exports.pw_notify:SendAlert('error', 'Moved Away From the Unloading Area. Move Back.', 2500)
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'Not using the Original Truck and/or the Used Trailer is Missing/Incorrect', 4000)
                    end
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end

function startFuelDelivery()
    currentDeliveryInfo.fuelStations = 1
    local deliveryLocation = Config.DeliveryPoints.fuel[1]
    local street, cross = GetStreetNameAtCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    local deliveryStreet = GetStreetNameFromHashKey(street)
    exports.pw_notify:SendAlert('info', 'Started Fuel Delivery Route<br>Start By Collecting the Fuel', 10000)
    CreateDeliveryBlip(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
            if dist < 30.0 then
                if not showingDeliveryMarker then
                    showingDeliveryMarker = true
                    MarkerDrawDelivery(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
                end
                if dist < 2.0 then
                    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED, false)
                    local pedHasTrailer, pedTrailerID = GetVehicleTrailerVehicle(pedVeh)
                    if (pedVeh == charVehicleInfo.truck) and (pedTrailerID == charVehicleInfo.trailer) then
                        exports.pw_notify:SendAlert('info', 'Whilst Waiting - Make Sure You Are Safely Parked so the Trailer can Be Unloaded. ', 10000)
                        Citizen.Wait(10000)
                        dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
                        if dist < 5.0 then -- Double Check if still in area
                            TriggerEvent('pw:progressbar:progress', 
                            {
                                name = 'loading_fuel_tanker',
                                duration = 30000,
                                label = 'Loading Tanker With Fuel',
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = { disableMovement = false, disableCarMovement = true, disableMouse = false, disableCombat = false, },
                            }, function(status)
                                if not status then
                                    showingDeliveryMarker = false
                                    continueFuelDelivery()
                                end
                            end)
                            break
                        else
                            exports.pw_notify:SendAlert('error', 'Moved Away From the Unloading Area. Move Back.', 2500)
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'Not using the Original Truck and/or the Used Trailer is Missing/Incorrect', 4000)
                    end
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end

function continueFuelDelivery()
    RemoveDeliveryBlip()
    currentDeliveryInfo.fuelStations = currentDeliveryInfo.fuelStations + 1
    local deliveryLocation = Config.DeliveryPoints.fuel[currentDeliveryInfo.fuelStations]
    local street, cross = GetStreetNameAtCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    local deliveryStreet = GetStreetNameFromHashKey(street)
    exports.pw_notify:SendAlert('info', 'Fuel Dropoff<br>Delivery Location: '.. deliveryStreet, 10000)
    CreateDeliveryBlip(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
            if dist < 30.0 then
                if not showingDeliveryMarker then
                    showingDeliveryMarker = true
                    MarkerDrawDelivery(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
                end
                if dist < 2.0 then
                    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED, false)
                    local pedHasTrailer, pedTrailerID = GetVehicleTrailerVehicle(pedVeh)
                    if (pedVeh == charVehicleInfo.truck) and (pedTrailerID == charVehicleInfo.trailer) then
                        exports.pw_notify:SendAlert('info', 'Whilst Waiting - Make Sure You Are Safely Parked so the Fuel Can be Transfered', 10000)
                        Citizen.Wait(10000)
                        dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
                        if dist < 5.0 then -- Double Check if still in area
                            TriggerEvent('pw:progressbar:progress', 
                            {
                                name = 'unloading_fuel_tanker',
                                duration = 20000,
                                label = 'Tranferring Fuel',
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = { disableMovement = false, disableCarMovement = true, disableMouse = false, disableCombat = false, },
                            }, function(status)
                                if not status then
                                    showingDeliveryMarker = false
                                    if currentDeliveryInfo.fuelStations == #Config.DeliveryPoints.fuel then
                                        pleaseReturnVehicleTo(currentDeliveryInfo.startDepot)
                                    else
                                        continueFuelDelivery()
                                    end
                                end
                            end)
                            break
                        else
                            exports.pw_notify:SendAlert('error', 'Moved Away From the Unloading Area. Move Back.', 2500)
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'Not using the Original Truck and/or the Used Trailer is Missing/Incorrect', 4000)
                    end
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end

function startFoodDelivery()
    RemoveDeliveryBlip()
    local randomDelivery = math.random(1, #Config.DeliveryPoints.food[currentDeliveryInfo.startDepot])
    currentDeliveryInfo.foodDelivery = currentDeliveryInfo.foodDelivery - 1
    local deliveryLocation = Config.DeliveryPoints.food[currentDeliveryInfo.startDepot][randomDelivery].parking
    local street, cross = GetStreetNameAtCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    local deliveryStreet = GetStreetNameFromHashKey(street)
    exports.pw_notify:SendAlert('info', 'Started Food Box Truck Delivery<br>Destination: '.. deliveryStreet, 10000)
    CreateDeliveryBlip(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
            if dist < 30.0 then
                if not showingDeliveryMarker then
                    showingDeliveryMarker = true
                    MarkerDrawDelivery(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
                end
                if dist < 2.0 then
                    local pedVeh = GetVehiclePedIsIn(GLOBAL_PED, false)
                    if (pedVeh == charVehicleInfo.truck) then
                        showingDeliveryMarker = false
                        removeGoodsFromFoodDelivery(randomDelivery)
                        break
                    else
                        exports.pw_notify:SendAlert('error', 'Not using the Original Truck and/or the Used Trailer is Missing/Incorrect', 4000)
                    end
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end

function removeGoodsFromFoodDelivery(foodLocationID)
    RemoveDeliveryBlip()
    exports.pw_notify:SendAlert('info', 'Remove The Goods From the Rear of the Vehicle', 10000)
    SetVehicleDoorOpen(charVehicleInfo.truck, 5, false, false)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local bone = GetEntityBoneIndexByName(charVehicleInfo.truck, 'platelight')
            local locationofbone = GetWorldPositionOfEntityBone(charVehicleInfo.truck, bone)
            local dist = #(GLOBAL_COORDS - vector3(locationofbone.x, locationofbone.y, (locationofbone.z + 0.8)))
            if dist < 30.0 then
                showingDeliveryMarker = false
                Citizen.Wait(100)
                showingDeliveryMarker = true
                MarkerDrawDelivery(locationofbone.x, locationofbone.y, (locationofbone.z + 0.8) )
                if dist < 1.0 then
                    showingDeliveryMarker = false
                    TriggerEvent('pw_trucking:Animation', 'anim@heists@box_carry@', 'idle', 49) -- Load/Start animation
                    loadPropDict('prop_sacktruck_02b')
                    TriggerEvent('pw_trucking:AttachProp', 'prop_sacktruck_02b', "SKEL_Pelvis", -0.075, 0.90, -0.86, -20.0, 0.5, 181.0)
                    deliverGoodsToCounter(foodLocationID)
                    break
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end

function deliverGoodsToCounter(foodLocationID)
    local deliveryLocation = Config.DeliveryPoints.food[currentDeliveryInfo.startDepot][foodLocationID].counter
    exports.pw_notify:SendAlert('info', 'Deliver Goods to Inside the Premises', 10000)
    CreateDeliveryBlip(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
    Citizen.CreateThread(function()
        while characterLoaded and onDelivery do
            Citizen.Wait(1000)
            local dist = #(GLOBAL_COORDS - vector3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
            if dist < 30.0 then
                if not showingDeliveryMarker then
                    showingDeliveryMarker = true
                    MarkerDrawDelivery(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
                end
                if dist < 1.0 then
                    SetVehicleDoorsShut(charVehicleInfo.truck, false)
                    showingDeliveryMarker = false
                    TriggerEvent('pw_trucking:StopAnimation')
                    print('delivered')
                    if currentDeliveryInfo.foodDelivery == 1 then
                        pleaseReturnVehicleTo(currentDeliveryInfo.startDepot)
                    else
                        startFoodDelivery()
                    end
                    break
                end
            elseif showingDeliveryMarker then
                showingDeliveryMarker = false
            end
        end
    end)
end


function pleaseReturnVehicleTo(depot)
    if Config.TruckingPoints[depot] ~= nil then
        RemoveDeliveryBlip()
        local location = Config.TruckingPoints[depot].locations.depotReturn.coords
        exports.pw_notify:SendAlert('info', 'Return the Vehicle Back to the Depot: <br>'.. Config.TruckingPoints[depot].depotName, 10000)
        local shown = false
        CreateDeliveryBlip(location.x, location.y, location.z)
        Citizen.CreateThread(function()
            while characterLoaded and onDelivery do
                Citizen.Wait(1000)
                local dist = #(GLOBAL_COORDS - vector3(location.x, location.y, location.z))
                if dist < 30.0 then
                    if not showingDeliveryMarker then
                        showingDeliveryMarker = true
                        MarkerDrawDelivery(location.x, location.y, location.z)
                    end
                    if dist < 2.0 then
                        if IsPedInAnyVehicle(GLOBAL_PED, false) then
                            local pedVeh = GetVehiclePedIsIn(GLOBAL_PED, false)
                            local pedHasTrailer, pedTrailerID = GetVehicleTrailerVehicle(pedVeh)
                            if pedVeh == charVehicleInfo.truck and (charVehicleInfo.trailer == 0 or (pedTrailerID == charVehicleInfo.trailer)) then
                                showingDeliveryMarker = false
                                print('Completed Delivery', currentDeliveryInfo.type, onDelivery)
                                TriggerServerEvent('pw_trucking:server:successfullyCompletedADelivery', currentDeliveryInfo.startDepot, currentDeliveryInfo.type)
                                RemoveDeliveryBlip()
                                ParkAndDeleteVehicle()
                                onDelivery = false
                                break
                            else
                                if not shown then
                                    exports.pw_notify:SendAlert('error', 'Not the Original Vehicle or the Trailer is Missing/Incorrect', 2500)
                                end
                                Citizen.Wait(2000)
                            end
                        else
                            Citizen.Wait(2000)
                        end
                    end
                elseif showingDeliveryMarker then
                    showingDeliveryMarker = false
                end
            end
        end) 
    end   
end

function ParkAndDeleteVehicle()
    SetEntityAsMissionEntity(charVehicleInfo.truck, true, true)
    DeleteEntity(charVehicleInfo.truck)
    if charVehicleInfo.trailer ~= 0 then
        SetEntityAsMissionEntity(charVehicleInfo.trailer, true, true)
        DeleteEntity(charVehicleInfo.trailer)
    end
end

-- Delivery Blips
function CreateDeliveryBlip(coordsx, coordsy, coordsz)
    if deliveryblip == nil then
        deliveryblip = AddBlipForCoord(coordsx, coordsy, coordsz)
        SetBlipColour(deliveryblip, 57)
        SetBlipRoute(deliveryblip, true)
        SetBlipRouteColour(deliveryblip, 57)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Delivery Location')
        EndTextCommandSetBlipName(deliveryblip)   
    end
end

function RemoveDeliveryBlip()
    if deliveryblip ~= nil then
	    RemoveBlip(deliveryblip)
	    deliveryblip = nil
    end
end 

function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.TruckingPoints) do
            blips[k] = AddBlipForCoord(v.locations.depot.coords.x, v.locations.depot.coords.y, v.locations.depot.coords.z)
            SetBlipSprite(blips[k], Config.Blips.type)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale  (blips[k], Config.Blips.scale)
            SetBlipColour (blips[k], Config.Blips.color)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Blips.name)
            EndTextCommandSetBlipName(blips[k])  
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end

RegisterNetEvent('pw_trucking:Animation')
AddEventHandler('pw_trucking:Animation', function(ad, anim, body)
    LastAD = ad
    LastA = anim
    LastBody = body
	loadAnimDict(ad)
	TaskPlayAnim(GLOBAL_PED, ad, anim, 4.0, 1.0, -1, body, 0, 0, 0, 0 )  
	RemoveAnimDict(ad)
    playerCurrentlyAnimated = true
    Citizen.CreateThread(function()
        while playerCurrentlyAnimated do
            Citizen.Wait(3000)
            loadAnimDict(LastAD)
            TaskPlayAnim(GLOBAL_PED, LastAD, LastA, 4.0, 1.0, -1, LastBody, 0, 0, 0, 0 )  
            RemoveAnimDict(LastAD)
        end
    end)
end)

RegisterNetEvent('pw_trucking:AttachProp')
AddEventHandler('pw_trucking:AttachProp', function(prop_one, boneone, x1, y1, z1, r1, r2, r3)
	local x,y,z = table.unpack(GetEntityCoords(GLOBAL_PED))
	if not HasModelLoaded(prop_one) then
		loadPropDict(prop_one)
	end
	prop = CreateObject(GetHashKey(prop_one), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, GLOBAL_PED, GetEntityBoneIndexByName(GLOBAL_PED, boneone), x1, y1, z1, r1, r2, r3, true, false, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop_one)
	table.insert(playerPropList, prop)
	playerCurrentlyHasProp = true
end)

RegisterNetEvent('pw_trucking:StopAnimation')
AddEventHandler('pw_trucking:StopAnimation', function()
    if playerCurrentlyAnimated then
        if LastAD then
            RemoveAnimDict(LastAD)
        end
        if playerCurrentlyHasProp then
            for _,v in pairs(playerPropList) do
                DeleteEntity(v)
            end
            playerCurrentlyHasProp = false
        end
        playerCurrentlyAnimated = false
        Citizen.Wait(3000)
        ClearPedTasks(GLOBAL_PED)
    end
end)

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end

function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end



