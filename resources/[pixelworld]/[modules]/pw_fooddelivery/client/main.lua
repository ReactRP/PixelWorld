local showing, blip, showingMarker = false, 0, false
local onDelivery, currentDeliveryID, deliveryBlip, deliveryStreet, deliveryAwaitingPickup, deliveryFoodName = false, 1, 0, nil, false, nil
local playerCurrentlyAnimated, playerCurrentlyHasProp, firstAnim, playerPropList = false, false, true, {}

PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
            if playerData.job.name == "fooddelivery" then
                createBlips()
            end
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
        showingMarker = false
        destroyBlips()
        DeliveryDone(true)
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

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if characterLoaded and playerData then
        playerData.job.duty = toggle
        showing = false
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
        if playerData.job.name == "fooddelivery" then
            createBlips()
        else
            destroyBlips()
        end
    end
end)

function MarkerDraw(x, y, z)
    Citizen.CreateThread(function()
        while showingMarker do
            Citizen.Wait(1)
            DrawMarker(Config.Markers.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Markers.markerSize.x, Config.Markers.markerSize.y, Config.Markers.markerSize.z, Config.Markers.markerColor.r, Config.Markers.markerColor.g, Config.Markers.markerColor.b, 100, false, true, 2, true, nil, nil, false)              
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if characterLoaded and playerData then
            if playerData.job.name == 'fooddelivery' then
                local dist = #(GLOBAL_COORDS - vector3(Config.DutyPos.coords.x, Config.DutyPos.coords.y, Config.DutyPos.coords.z))
                if dist < 30.0 then
                    if not showingMarker then
                        showingMarker = true
                        MarkerDraw(Config.DutyPos.coords.x, Config.DutyPos.coords.y, Config.DutyPos.coords.z)
                    end
                    if dist < 2.0 then
                        if not showing then
                            showing = true
                            DrawFText(showing)
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                    end
                elseif showingMarker then 
                    showingMarker = false
                end        
            elseif showing then
                showing = false
                TriggerEvent('pw_drawtext:hideNotification')
                TriggerServerEvent('pw_keynote:server:triggerShowable', false)
            end
        end  
    end
end)

function DrawFText(var)
    TriggerEvent('pw_drawtext:showNotification', { title = "Food Delivery Office", message = "<span style='font-size:25px'>Go <b><span class='text-"..(playerData.job.duty and "danger'>Off" or "success'>On").."</span></b> Duty</span>", icon = "far fa-mail-bulk" })
    TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = "Go on Duty"}})
    Citizen.CreateThread(function()
        while showing do
            Citizen.Wait(5)
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('pw_fooddelivery:server:toggleDuty')   
            end
        end
    end)
end


RegisterNetEvent('pw_fooddelivery:client:phoneFoodDelivery')
AddEventHandler('pw_fooddelivery:client:phoneFoodDelivery', function(pkey)
    if pkey == "startNewFoodJob" and not onDelivery then
        DeliveryStart()
    elseif pkey == "cancelOldFoodJob" and onDelivery then
        DeliveryDone(true)
    end
end)

function SendPhoneUpdate()
    local phoneData = {
        isOnActiveDelivery = onDelivery,
        activeDeliveryID = currentDeliveryID,
        foodName = deliveryFoodName,
        currentFoodInstructions = (deliveryAwaitingPickup and ' awaiting pickup on ') or ' waiting to be dropped off on ',
        currentAwaitingLocation = deliveryStreet
    }
    TriggerEvent('pw_phone:client:loadData', "startNewFoodJob", phoneData)
end

function DeliveryStart()
    onDelivery = true
    currentDeliveryID = math.random(1, #Config.DeliveryPoints)
    print('Current Delivery ID:', currentDeliveryID)
    local PickupID = Config.DeliveryPoints[currentDeliveryID].pickupPosID
    local street, cross = GetStreetNameAtCoord(Config.DeliveryPickupPoints[PickupID].parkingPos.x, Config.DeliveryPickupPoints[PickupID].parkingPos.y, Config.DeliveryPickupPoints[PickupID].parkingPos.z)
    deliveryStreet = GetStreetNameFromHashKey(street)
    deliveryFoodName = Config.FoodNames[Config.DeliveryPoints[currentDeliveryID].foodType]
    exports.pw_notify:SendAlert('info', 'New food delivery pickup set, check phone for details', 12000)
    deliveryAwaitingPickup = true
    SendPhoneUpdate()
    InitialAwaitingFoodPickup(currentDeliveryID)  
end

function DeliveryDone(cancel, toofar)
	if cancel and onDelivery then
        exports.pw_notify:SendAlert('error', 'Delivery has been cancelled' .. (toofar and ' as you were to far from the delivery point or vehicle.' or '.'), 8000)
        onDelivery = false
    elseif onDelivery then
        TriggerServerEvent('pw_fooddelivery:server:finishdelivery')
        onDelivery = false
    end
    TriggerEvent('pw_fooddelivery:StopAnimation')
    destroyDeliveryBlips()
    SendPhoneUpdate()
end

local drawingAwaitingFoodPickup = false

function DrawShitInitialAwaitingFoodPickup(id)
    Citizen.CreateThread(function()
        local PickupID = Config.DeliveryPoints[id].pickupPosID
        while drawingAwaitingFoodPickup == id and onDelivery do
            Citizen.Wait(1)
            DrawMarker(2, Config.DeliveryPickupPoints[PickupID].parkingPos.x, Config.DeliveryPickupPoints[PickupID].parkingPos.y, Config.DeliveryPickupPoints[PickupID].parkingPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 132, 18, 255, 100, true, true, 2, true, nil, nil, false)
        end
    end)
end

function InitialAwaitingFoodPickup(currentDeliveryID)
    local PickupID = Config.DeliveryPoints[currentDeliveryID].pickupPosID
    createDeliveryBlip(Config.DeliveryPickupPoints[PickupID].parkingPos, 'Food Pickup Location', true)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then
                local dist = #(GLOBAL_COORDS - vector3(Config.DeliveryPickupPoints[PickupID].parkingPos.x, Config.DeliveryPickupPoints[PickupID].parkingPos.y, Config.DeliveryPickupPoints[PickupID].parkingPos.z))  
                if dist < 30.0 then
                    if not drawingAwaitingFoodPickup then
                        drawingAwaitingFoodPickup = currentDeliveryID
                        DrawShitInitialAwaitingFoodPickup(drawingAwaitingFoodPickup)
                    end
                    if dist < 1.5 then
                        if IsPedInAnyVehicle(GLOBAL_PED, false) then
                            local vehicle = GetVehiclePedIsIn(GLOBAL_PED, false)
                            local platebone = GetEntityBoneIndexByName(vehicle, 'seat_pside_f')
                            local vehicleClass = GetVehicleClass(vehicle)
                            if platebone ~= -1 and platebone ~= nil then
                                drawingAwaitingFoodPickup = false
                                InitialAwaitingFoodPickupFoot(currentDeliveryID, vehicle)
                                break
                            else
                                exports.pw_notify:SendAlert('error', 'You cannot use this vehicle for deliveries.', 2000)
                                Citizen.Wait(2500)
                            end
                        else
                            exports.pw_notify:SendAlert('error', 'You need to be in a vehicle', 2000)
                            Citizen.Wait(2500)
                        end
                    end
                end
            end
        end
    end)
end

local drawingAwaitingFoodPickupFoot = false

function DrawShitInitialAwaitingFoodPickupFoot(id)
    Citizen.CreateThread(function()
        local PickupID = Config.DeliveryPoints[id].pickupPosID
        while drawingAwaitingFoodPickupFoot == id and onDelivery do
            Citizen.Wait(1)
            DrawMarker(2, Config.DeliveryPickupPoints[PickupID].foodPos.x, Config.DeliveryPickupPoints[PickupID].foodPos.y, Config.DeliveryPickupPoints[PickupID].foodPos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 132, 18, 255, 100, true, true, 2, true, nil, nil, false)
        end
    end)
end

function InitialAwaitingFoodPickupFoot(currentDeliveryID, vehicle)
    exports.pw_notify:SendAlert('info', 'Pick up the food and take it back to the vehicle', 5000)
    local PickupID = Config.DeliveryPoints[currentDeliveryID].pickupPosID
    createDeliveryBlip(Config.DeliveryPickupPoints[PickupID].foodPos, 'Food Pickup Location', true)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then
                local dist = #(GLOBAL_COORDS - vector3(Config.DeliveryPickupPoints[PickupID].foodPos.x, Config.DeliveryPickupPoints[PickupID].foodPos.y, Config.DeliveryPickupPoints[PickupID].foodPos.z))  
                if dist < 30.0 then
                    if not drawingAwaitingFoodPickupFoot then
                        drawingAwaitingFoodPickupFoot = currentDeliveryID
                        DrawShitInitialAwaitingFoodPickupFoot(drawingAwaitingFoodPickupFoot)
                    end
                    if dist < 1.5 then
                        drawingAwaitingFoodPickupFoot = false
                        TriggerEvent('pw:progressbar:progress',
                        {                                     
                            name = 'pickup_food',
                            duration = 3000,
                            label = 'Collecting The Food',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                local deliveryFoodType = Config.DeliveryPoints[currentDeliveryID].foodType
                                TriggerEvent('pw_fooddelivery:Animation', Config.PropsAnimations[deliveryFoodType].animation.ad, Config.PropsAnimations[deliveryFoodType].animation.anim, Config.PropsAnimations[deliveryFoodType].animation.body)
                                loadPropDict(Config.PropsAnimations[deliveryFoodType].item.prop)
                                TriggerEvent('pw_fooddelivery:AttachProp', Config.PropsAnimations[deliveryFoodType].item.prop, Config.PropsAnimations[deliveryFoodType].item.boneone, Config.PropsAnimations[deliveryFoodType].item.x1, Config.PropsAnimations[deliveryFoodType].item.y1, Config.PropsAnimations[deliveryFoodType].item.z1, Config.PropsAnimations[deliveryFoodType].item.r1, Config.PropsAnimations[deliveryFoodType].item.r2, Config.PropsAnimations[deliveryFoodType].item.r3)
                                InitialAwaitingFoodPickupPutInCar(currentDeliveryID, vehicle)
                            end
                        end)
                        break
                    end
                end
            end
        end
    end)
end

function InitialAwaitingFoodPickupPutInCar(currentDeliveryID, vehicle)
    exports.pw_notify:SendAlert('info', 'Take the food to the passenger side of the vehicle to put it in the front seat.', 8000)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then
                local bone = GetEntityBoneIndexByName(vehicle, 'seat_pside_f')
                local locationofbone = GetWorldPositionOfEntityBone(vehicle, bone)
                if locationofbone ~= nil then
                    local dist = #(GLOBAL_COORDS - vector3(locationofbone.x, locationofbone.y, locationofbone.z))  
                    if dist < 80.0 then
                        if dist < 1.5 and not IsPedInAnyVehicle(GLOBAL_PED, true) then
                            drawingAwaitingFoodPickupBackInCar = false
                            SetVehicleDoorOpen(vehicle, 1, false, false)
                            TriggerEvent('pw_fooddelivery:Animation', 'anim@narcotics@trash', 'drop_front', 4)
                            TriggerEvent('pw:progressbar:progress',
                            {                                     
                                name = 'add_food_vehicle',
                                duration = 3000,
                                label = 'Placing Food Into Vehicle',
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = false,
                                    disableMouse = false,
                                    disableCombat = true,
                                },
                            },
                            function(status)
                                if not status then
                                    TriggerEvent('pw_fooddelivery:StopAnimation')
                                    TriggerEvent('pw_fooddelivery:Animation', 'anim@narcotics@trash', 'drop_front', 4)
                                    SetVehicleDoorShut(vehicle, 1, false)
                                    AwaitingDeliveryVehicle(currentDeliveryID, vehicle)
                                end
                            end)
                            break
                        end
                    else
                        DeliveryDone(true, true)
                    end
                else
                    DeliveryDone(true, true)
                end
            end
        end
    end)
end


local drawingAwaitMarkerVehicle = false

function DrawShitAwaitingVehicle(id)
    Citizen.CreateThread(function()
        while drawingAwaitMarkerVehicle == id and onDelivery do
            Citizen.Wait(1)
            DrawMarker(2, Config.DeliveryPoints[currentDeliveryID].parkVeh.x, Config.DeliveryPoints[currentDeliveryID].parkVeh.y, Config.DeliveryPoints[currentDeliveryID].parkVeh.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 132, 18, 255, 100, true, true, 2, true, nil, nil, false)
        end
    end)
end

function AwaitingDeliveryVehicle(currentDeliveryID, vehicle)
    deliveryAwaitingPickup = false
    local street, cross = GetStreetNameAtCoord(Config.DeliveryPoints[currentDeliveryID].parkVeh.x, Config.DeliveryPoints[currentDeliveryID].parkVeh.y, Config.DeliveryPoints[currentDeliveryID].parkVeh.z)
    deliveryStreet = GetStreetNameFromHashKey(street)
    SendPhoneUpdate()
    exports.pw_notify:SendAlert('info', 'Take the food to the marked delivery destination at ' .. deliveryStreet, 12000)
    createDeliveryBlip(Config.DeliveryPoints[currentDeliveryID].parkVeh, 'Food Delivery Destination', true)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then
                local bone = GetEntityBoneIndexByName(vehicle, 'seat_pside_f')
                local locationofbone = GetWorldPositionOfEntityBone(vehicle, bone)
                local dist = #(GLOBAL_COORDS - vector3(Config.DeliveryPoints[currentDeliveryID].parkVeh.x, Config.DeliveryPoints[currentDeliveryID].parkVeh.y, Config.DeliveryPoints[currentDeliveryID].parkVeh.z))  
                if dist < 30.0 then
                    if not drawingAwaitMarkerVehicle then
                        drawingAwaitMarkerVehicle = currentDeliveryID
                        DrawShitAwaitingVehicle(drawingAwaitMarkerVehicle)
                    end
                    if dist < 1.5 then
                        if IsPedInAnyVehicle(GLOBAL_PED, false) and (GetVehiclePedIsIn(GLOBAL_PED, false) == vehicle) then
                            drawingAwaitMarkerVehicle = false
                            AwaitingDeliveryOutOfVehicle(currentDeliveryID, vehicle)
                            break
                        else
                            exports.pw_notify:SendAlert('error', 'You are either not in a vehicle at all or are not in the vehicle you were using for this delivery.<br> Find the correct vehicle or cancel this delivery.', 3000)
                            Citizen.Wait(3000)
                        end
                    end
                end
            end
        end
    end)
end

function AwaitingDeliveryOutOfVehicle(currentDeliveryID, vehicle)
    exports.pw_notify:SendAlert('info', 'Park the vehicle safely and retrieve the food to be delivered from the front passenger seat.', 8000)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then
                local bone = GetEntityBoneIndexByName(vehicle, 'seat_pside_f')
                local locationofbone = GetWorldPositionOfEntityBone(vehicle, bone)
                if locationofbone ~= nil then
                    local dist = #(GLOBAL_COORDS - vector3(locationofbone.x, locationofbone.y, locationofbone.z))  
                    if dist < 80.0 then
                        if dist < 1.5 and not IsPedInAnyVehicle(GLOBAL_PED, true) then
                            SetVehicleDoorOpen(vehicle, 1, false, false)
                            TriggerEvent('pw_fooddelivery:Animation', 'anim@narcotics@trash', 'drop_front', 4)
                            TriggerEvent('pw:progressbar:progress',
                            {                                     
                                name = 'remove_food_vehicle',
                                duration = 3000,
                                label = 'Getting Food Out of Vehicle',
                                useWhileDead = false,
                                canCancel = false,
                                controlDisables = {
                                    disableMovement = true,
                                    disableCarMovement = false,
                                    disableMouse = false,
                                    disableCombat = true,
                                },
                            },
                            function(status)
                                if not status then
                                    local deliveryFoodType = Config.DeliveryPoints[currentDeliveryID].foodType
                                    TriggerEvent('pw_fooddelivery:Animation', Config.PropsAnimations[deliveryFoodType].animation.ad, Config.PropsAnimations[deliveryFoodType].animation.anim, Config.PropsAnimations[deliveryFoodType].animation.body)
                                    loadPropDict(Config.PropsAnimations[deliveryFoodType].item.prop)
                                    TriggerEvent('pw_fooddelivery:AttachProp', Config.PropsAnimations[deliveryFoodType].item.prop, Config.PropsAnimations[deliveryFoodType].item.boneone, Config.PropsAnimations[deliveryFoodType].item.x1, Config.PropsAnimations[deliveryFoodType].item.y1, Config.PropsAnimations[deliveryFoodType].item.z1, Config.PropsAnimations[deliveryFoodType].item.r1, Config.PropsAnimations[deliveryFoodType].item.r2, Config.PropsAnimations[deliveryFoodType].item.r3)
                                    AwaitingDeliveryDoor(currentDeliveryID)
                                    SetVehicleDoorShut(vehicle, 1, false)
                                end
                            end)
                            break
                        end
                    else
                        DeliveryDone(true, true)
                    end
                else
                    exports.pw_notify:SendAlert('error', 'The delivery vehicle you were using no can no longer be found', 2500)
                    DeliveryDone(true, true)
                end
            end
        end
    end)
end

local drawingAwaitMarkerFoot = false

function DrawShitAwaitingFoot(id)
    Citizen.CreateThread(function()
        while drawingAwaitMarkerFoot == id and onDelivery do
            Citizen.Wait(1)
            DrawMarker(2, Config.DeliveryPoints[currentDeliveryID].doorDrop.x, Config.DeliveryPoints[currentDeliveryID].doorDrop.y, Config.DeliveryPoints[currentDeliveryID].doorDrop.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 132, 18, 255, 100, true, true, 2, true, nil, nil, false)
        end
    end)
end

function AwaitingDeliveryDoor(currentDeliveryID)
    exports.pw_notify:SendAlert('info', 'Take the food to the door of the house and get payment. Check the GPS if You Can\'t Find It', 5000)
    createDeliveryBlip(Config.DeliveryPoints[currentDeliveryID].doorDrop, 'Delivery Door Destination', false)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then
                local dist = #(GLOBAL_COORDS - vector3(Config.DeliveryPoints[currentDeliveryID].doorDrop.x, Config.DeliveryPoints[currentDeliveryID].doorDrop.y, Config.DeliveryPoints[currentDeliveryID].doorDrop.z))  
                if dist < 90.0 then
                    if not drawingAwaitMarkerFoot then
                        drawingAwaitMarkerFoot = deliveryid
                        DrawShitAwaitingFoot(drawingAwaitMarkerFoot)
                    end
                    if dist < 1.5 then
                        drawingAwaitMarkerFoot = false
                        TriggerEvent('pw:progressbar:progress',
                        {                                     
                            name = 'pickup_food',
                            duration = 3000,
                            label = 'Delivering Food to Customer',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                TriggerEvent('pw_fooddelivery:StopAnimation')
                                DeliveryDone(false, false)
                            end
                        end)
                        break
                    end
                else
                    drawingAwaitMarkerFoot = false 
                    DeliveryDone(true, true)
                    break
                end
            end
        end
    end)
end

function createDeliveryBlip(coords, name, route)
    if deliveryBlip == 0 then
        deliveryBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(deliveryBlip, 1)
        SetBlipColour(deliveryBlip, 83)
        SetBlipScale(deliveryBlip, 0.7)
        if route then
            SetBlipRoute(deliveryBlip, true)
            SetBlipRouteColour(deliveryBlip, 83)
        end
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(deliveryBlip)
    else
        destroyDeliveryBlips()
        createDeliveryBlip(coords, name, route)
    end
end

function destroyDeliveryBlips()
    if deliveryBlip ~= 0 then
	    RemoveBlip(deliveryBlip)
        deliveryBlip = 0
        ClearAllBlipRoutes()
    end
end  

function createBlips()
    Citizen.CreateThread(function()
        blip = AddBlipForCoord(Config.DutyPos.coords.x, Config.DutyPos.coords.y, Config.DutyPos.coords.z)
        SetBlipSprite(blip, Config.Blips.type)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, Config.Blips.scale)
        SetBlipColour (blip, Config.Blips.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Blips.name)
        EndTextCommandSetBlipName(blip)
    end)
end

function destroyBlips()
    RemoveBlip(blip)
end

-- Animation Stuff

RegisterNetEvent('pw_fooddelivery:Animation')
AddEventHandler('pw_fooddelivery:Animation', function(ad, anim, body)
    local GLOBAL_PED = PlayerPedId()
	if firstAnim then
		LastAD = ad
		firstAnim = false
	end
    loadAnimDict(ad)
	TaskPlayAnim(GLOBAL_PED, ad, anim, 4.0, 1.0, -1, body, 0, 0, 0, 0 )  
	RemoveAnimDict(ad)
	playerCurrentlyAnimated = true
end)

RegisterNetEvent('pw_fooddelivery:AttachProp')
AddEventHandler('pw_fooddelivery:AttachProp', function(prop_one, boneone, x1, y1, z1, r1, r2, r3)
    local GLOBAL_PED = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(GLOBAL_PED))
	if not HasModelLoaded(prop_one) then
		loadPropDict(prop_one)
	end
	prop = CreateObject(GetHashKey(prop_one), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, GLOBAL_PED, GetPedBoneIndex(GLOBAL_PED, boneone), x1, y1, z1, r1, r2, r3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop_one)
	table.insert(playerPropList, prop)
	playerCurrentlyHasProp = true
end)

RegisterNetEvent('pw_fooddelivery:StopAnimation')
AddEventHandler('pw_fooddelivery:StopAnimation', function()
    local GLOBAL_PED = PlayerPedId()
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
        ClearPedTasks(GLOBAL_PED)
        playerCurrentlyAnimated = false
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



