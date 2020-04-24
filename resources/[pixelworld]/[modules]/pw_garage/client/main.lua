PW = nil
playerData, playerLoaded = nil, false
local showMarker, showingInfo, onVeh, waitingFuel, waitingPump, taxi, gotCan, ownsTaco = false, false, false, false, false, { ['veh'] = 0, ['ped'] = 0 }, false, false
local garages, privateGarages, units, prevSlots, prevPrivSlots, prevUnitSlots, prevUnitOwner, blips, unitBlips, insuranceBlips, spawnedVehicles, Tacos = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}

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
            playerLoaded = true
            CreateBlips()
            --CheckTacoOwner()
        else
            PW.TriggerServerCallback('pw_garage:server:getGarages', function(public, private, gunits)
                garages = public
                privateGarages = private
                units = gunits
                playerData = data
                --[[ PW.TriggerServerCallback('pw_taco:server:getTacos', function(tacos)
                    Tacos = tacos
                end) ]]
            end)
        end
    else
        DeleteBlips()
        HandleExit()
        playerLoaded = false
        playerData = nil
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded and playerData then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded and playerData and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw_taco:client:updateTacos')
AddEventHandler('pw_taco:client:updateTacos', function(tacos)
    Tacos = tacos
    CheckTacoOwner()
end)

RegisterNetEvent('pw_inventory:client:useItemNotif')
AddEventHandler('pw_inventory:client:useItemNotif', function(notif)
    if waitingFuel and notif[1].item.label == 'Jerrycan' then
        gotCan = true
    end
end)

function CheckTacoOwner()
    local found = false
    if Tacos ~= nil and Tacos[1] ~= nil then
        for k,v in pairs(Tacos) do
            if v.cid == playerData.cid then
                found = true
                break
            end
        end
    end
    ownsTaco = found
end

function DeleteBlips()
    if blips ~= nil then
        for k,v in pairs(blips) do
            RemoveBlip(v)
        end
    end

    if unitBlips ~= nil then
        for k,v in pairs(unitBlips) do
            RemoveBlip(v)
        end
    end

    if insuranceBlips ~= nil then
        for k,v in pairs(insuranceBlips) do
            RemoveBlip(v)
        end
    end

    blips = {}
    unitBlips = {}
    insuranceBlips = {}
end

function HandleExit()
    if spawnedVehicles ~= nil and spawnedVehicles[1] ~= nil then
        for k,v in pairs(spawnedVehicles) do
            if v.insurance.plan > 0 then
                HandleInsurance(v)
            end            
        end
        spawnedVehicles = {}
    end
end

AddEventHandler('playerDropped', function(reason)
    HandleExit()
end)

function HandleInsurance(vehicle)
    if vehicle.insurance.plan > 0 then
        TriggerServerEvent('pw_garage:server:useInsurance', vehicle.plate, vehicle.veh)
    end
end

RegisterNetEvent('pw_garage:client:insureVeh')
AddEventHandler('pw_garage:client:insureVeh', function(veh)
    local vehEntity = NetworkGetEntityFromNetworkId(veh)
    StoreVehicle(vehEntity)
end)

RegisterNetEvent('pw_garage:client:updatePrivGarages')
AddEventHandler('pw_garage:client:updatePrivGarages', function(id, newPos)
    privateGarages[id].spawnPoint = newPos
end)

RegisterNetEvent('pw_garage:client:autoUpdate')
AddEventHandler('pw_garage:client:autoUpdate', function(type, id, count)
    if playerLoaded then
        if type == 'public' then
            garages[id].curSlots = count
        else
            privateGarages[id].curSlots = count
        end
    end
end)

RegisterNetEvent('pw_garage:client:updateSlots')
AddEventHandler('pw_garage:client:updateSlots', function(gType, id, type)
    if gType == 'Public' or gType == 'Impound' or gType == 'Business' then
        if type == 'stored' then
            garages[id].curSlots = garages[id].curSlots + 1
        else
            if garages[id].curSlots > 0 then
                garages[id].curSlots = garages[id].curSlots - 1
            end
        end
    elseif gType == 'Private' then
        if type == 'stored' then
            privateGarages[id].curSlots = privateGarages[id].curSlots + 1
        else
            if privateGarages[id].curSlots > 0 then
                privateGarages[id].curSlots = privateGarages[id].curSlots - 1
            end
        end
    elseif gType == 'Unit' then
        if type == 'stored' then
            units[id].curSlots = units[id].curSlots + 1
        else
            if units[id].curSlots > 0 then
                units[id].curSlots = units[id].curSlots - 1
            end
        end
    end
end)

RegisterNetEvent('pw_garage:client:spawnAuto')
AddEventHandler('pw_garage:client:spawnAuto', function(vehicle, ins, plate)
    local vehNet = VehToNet(vehicle)
    table.insert(spawnedVehicles, { ['veh'] = vehNet, ['insurance'] = ins, ['plate'] = plate })
end)

RegisterNetEvent('pw_garage:client:spawnVehicle')
AddEventHandler('pw_garage:client:spawnVehicle', function(type, props, id, insurance, damage)
    local coords = vector3(0.0, 0.0, 0.0)
    if type == 'Public' or type == 'Impound' or type == 'Business' then
        coords = garages[id].spawnPoint
    elseif type == 'Private' then
        coords = privateGarages[id].spawnPoint
    elseif type == 'Unit' then
        coords = units[id].spawnPoint
    end
    if type == 'Auto' then
        TriggerServerEvent('pw_carpark:server:retrieveVehicle', id, props, insurance, damage)
    else
        TriggerEvent('pw_interact:closeMenu')
        PW.Game.SpawnOwnedVehicle(props.model, coords, coords.h, function(vehicle)
            SetEntityVisible(vehicle, false, 0)
            PW.Game.SetVehicleProperties(vehicle, props)
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
            SetVehDamage(vehicle, damage)
            local vehNet = VehToNet(vehicle)
            table.insert(spawnedVehicles, { ['veh'] = vehNet, ['insurance'] = insurance, ['plate'] = props.plate })
            Wait(500)
            SetEntityVisible(vehicle, true, 0)
            if type == 'Private' or type == 'Unit' then SetPedIntoVehicle(GLOBAL_PED, vehicle, -1); end
            exports.pw_notify:SendAlert('inform', (type ~= 'Impound' and 'Vehicle taken out of the garage' or 'Vehicle released from the Impound Lot'), 5000)
        end)
    end
end)

RegisterNetEvent('pw_garage:client:ownerFoundImpound')
AddEventHandler('pw_garage:client:ownerFoundImpound', function(props, entity)
    local menu = {}
    local damage = GetVehDamage(entity)
    for k,v in pairs(garages) do
        if v.type == 'Impound' then
            table.insert(menu, { ['label'] = v.name, ['action'] = 'pw_garage:server:sendToImpound', ['value'] = { garage = k, props = props, entity = entity, damage = damage }, ['triggertype'] = 'server', ['color'] = 'primary' })
        end
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Choose an Impound Lot to park the vehicle")
end)

RegisterNetEvent('pw_garage:client:deleteVehicle')
AddEventHandler('pw_garage:client:deleteVehicle', function(props)
    StoreVehicle(props)
end)

RegisterNetEvent('pw_garage:client:impoundVehicle')
AddEventHandler('pw_garage:client:impoundVehicle', function()
    local ped = GLOBAL_PED
    local pedCoords = GLOBAL_COORDS
    local closestVehicle = GetClosestVehicle(pedCoords.x, pedCoords.y, pedCoords.z, 2.0, 0, 71)
    if closestVehicle ~= 0 and closestVehicle ~= nil then
        local props = PW.Game.GetVehicleProperties(closestVehicle)
        exports['pw_progbar']:Progress({
            name = "police_impound",
            duration = 10000,
            label = "Impounding vehicle",
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = { 
                animDict = 'amb@medic@standing@kneel@idle_a',
                anim = 'idle_a',
                flags = 01,
            },
        }, function(status)
            if not status then
                ClearPedTasks(ped)
                TriggerServerEvent('pw_garage:server:checkPlateForImpound', props, closestVehicle)
            end
        end)
    end
end)

RegisterNetEvent('pw_garage:client:setDamage')
AddEventHandler('pw_garage:client:setDamage', function(veh, dmg)
    SetVehDamage(veh, dmg)
end)

exports('setDamage', function(veh, dmg)
    SetVehDamage(veh, dmg)
end)

exports('getDamage', function(veh)
    return GetVehDamage(veh)
end)

function GetVehDamage(vehicle)
    local damage, windows, doors, tires = {}, {}, {}, {}

    if not AreAllVehicleWindowsIntact(vehicle) then
        for i = 0, 13, 1 do
            if i ~= 10 then
                if not IsVehicleWindowIntact(vehicle, i) then
                    table.insert(windows, i)
                end
            end
        end
    end

    damage.windows = windows

    for i = 0, GetNumberOfVehicleDoors(vehicle), 1 do
        if IsVehicleDoorDamaged(vehicle, i) then
            table.insert(doors, i)
        end
    end

    damage.doors = doors

    for i = 0, 5, 1 do
        if IsVehicleTyreBurst(vehicle, i, true) then
            table.insert(tires, { ['wheel'] = i, ['burst'] = true, ['damage'] = 1000.0 })
        elseif IsVehicleTyreBurst(vehicle, i, false) then
            table.insert(tires, { ['wheel'] = i, ['burst'] = false, ['damage'] = GetVehicleWheelHealth(vehicle, i) })
        end
    end

    damage.tires = tires

    return damage
end

function SetVehDamage(vehicle, damage)
    if damage ~= nil then
        SetEntityVisible(vehicle, false, 0)
        if damage.windows and damage.windows[1] ~= nil then
            for k,v in pairs(damage.windows) do
                if v ~= 10 then
                    SmashVehicleWindow(vehicle, v)
                end
            end
        end

        if damage.doors and damage.doors[1] ~= nil then
            for k,v in pairs(damage.doors) do
                SetVehicleDoorBroken(vehicle, v, true)
            end
        end

        if damage.tires and damage.tires[1] ~= nil then
            for k,v in pairs(damage.tires) do
                SetVehicleTyreBurst(vehicle, v.wheel, v.burst, v.damage)
            end
        end
        SetEntityVisible(vehicle, true, 0)
    end
end

function MetaChecks(meta, id)
    for k,v in pairs(garages[id].meta.allowed) do
        if meta == v then
            return true
        end
    end
    return false
end

RegisterNetEvent('pw_garage:client:openGarageAfterClose')
AddEventHandler('pw_garage:client:openGarageAfterClose', function()
    if inParkedVehs.type ~= 'Auto' then OpenGarage(inParkedVehs.type, inParkedVehs.garage); end
end)

RegisterNetEvent('pw_garage:client:openGarage')
AddEventHandler('pw_garage:client:openGarage', function(type, id, auto)
    OpenGarage(type, id, auto)
end)

function OpenGarage(type, id, auto)
    inParkedVehs = false
    local ped = GLOBAL_PED
    local checkVeh
    if type == 'Public' or type == 'Private' or type == 'Unit' or type == 'Business' then
        checkVeh = IsPedInAnyVehicle(ped, false)
    end
    if checkVeh then
        local veh = GetVehiclePedIsIn(ped, false)
        if GetPedInVehicleSeat(veh, -1) == ped then
            if CanPark(type, id) then
                local props = PW.Game.GetVehicleProperties(veh)
                local vid = PW.Vehicles.GetVehId(props.plate)
                PW.TriggerServerCallback('pw_garage:server:checkOwner', function(owner)
                    if owner then
                        local canStore
                        if type ~= 'Impound' then
                            PW.TriggerServerCallback('pw_vehiclemanagement:server:getMeta', function(meta)
                                if (meta and garages[id].meta ~= nil and MetaChecks(meta, id)) or not meta then
                                    canStore = true
                                else
                                    canStore = false
                                end
                            end, vid)
                        end
                        repeat Wait(10) until canStore ~= nil
                        if canStore then
                            local damage = GetVehDamage(veh)
                            TriggerServerEvent('pw_garage:server:storeVehicle', type, props, id, damage)
                            StoreVehicle(veh)
                        end
                    else
                        exports.pw_notify:SendAlert('error', 'You are not the owner of this vehicle', 5000)
                    end
                end, vid)
            else
                exports.pw_notify:SendAlert('error', 'This garage is at its maximum capacity', 5000)
            end
        else
            exports.pw_notify:SendAlert('error', 'You must be in the driver\'s seat', 5000)
        end
    else
        local menu = {}
        PW.TriggerServerCallback('pw_garage:server:getParkedVehicles', function(vehs)
            if vehs then
                for k,v in pairs(vehs) do
                    local meta = json.decode(v.vehicle_metainformation)
                    local props = json.decode(v.vehicle_information)
                    table.insert(menu, { ['label'] = PW.Vehicles.GetName(meta.model), ['action'] = 'pw_garage:client:openVehicleStats', ['value'] = {type = type, garage = id, props = props, plate = v.plate, name = PW.Vehicles.GetName(meta.model), auto = auto}, ['triggertype'] = 'client', ['color'] = 'primary' })
                end
            else
                table.insert(menu, {['label'] = (type ~= 'Impound' and "No owned vehicles parked here" or "No vehicles impounded at this lot"), ['color'] = 'danger disabled'})
            end

            TriggerEvent('pw_interact:generateMenu', menu, ((type == 'Public' or type == 'Business') and 'Garage | '..garages[id].name or type == 'Private' and 'Private Garage | '..privateGarages[id].name or type == 'Impound' and 'Impound Lot | '..garages[id].name or type == 'Unit' and 'Garage Unit #'.. id .. ' | ' .. units[id].name))
        end, type, id)
    end
end

function ShowImpoundCostForm(data)
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b><span class='text-success'>"..data.name.."</span></b><br>Plate: <b><span class='text-info'>"..data.plate },
        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Owner: <b>"..playerData.name.."</b><br>Impound release cost: <b><span class='text-success'>$"..Config.PoliceImpoundCost.."</span></b>" },
        { ['type'] = "checkbox", ['label'] = '<i>(Owner signature) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "veh", ['data'] = {type = data.type, plate = PW.Vehicles.GetVehId(data.plate)}}
    }

    TriggerEvent('pw_interact:generateForm', 'pw_garage:server:takeVehicleImpound', 'server', form, 'Release of Impounded Vehicle')
end

RegisterNetEvent('pw_garage:client:checkClearPathForSpawn')
AddEventHandler('pw_garage:client:checkClearPathForSpawn', function(data)
    local closestVeh
    if data.type == 'Auto' then
        local rayHandle = StartShapeTestBox(data.auto.pos.x, data.auto.pos.y, data.auto.pos.z-1.0, 4.5, 7.1, 2.63281, 0.0, 0.0, 0.0, true, 2, 0)
        local _, hit, _, _, veh = GetShapeTestResult(rayHandle)
        closestVeh = hit
    elseif data.type == 'Public' or data.type == 'Business' or data.type == 'Impound' then
        closestVeh = GetClosestVehicle(garages[data.garage].spawnPoint.x, garages[data.garage].spawnPoint.y, garages[data.garage].spawnPoint.z, 8.0, 0, 71)
    elseif data.type == 'Private' then
        closestVeh = GetClosestVehicle(privateGarages[data.garage].spawnPoint.x, privateGarages[data.garage].spawnPoint.y, privateGarages[data.garage].spawnPoint.z, 8.0, 0, 71)
    elseif data.type == 'Unit' then
        closestVeh = GetClosestVehicle(units[data.garage].spawnPoint.x, units[data.garage].spawnPoint.y, units[data.garage].spawnPoint.z, 8.0, 0, 71)
    end
    if closestVeh == 0 or not closestVeh then
        if data.type == 'Impound' then
            ShowImpoundCostForm(data)
        else
            TriggerServerEvent('pw_garage:server:takeVehicle', data.type, PW.Vehicles.GetVehId(data.plate))
        end
    else
        exports.pw_notify:SendAlert('error', 'There\'s a vehicle blocking the way', 4000)
    end
end)

RegisterNetEvent('pw_garage:client:openVehicleStats')
AddEventHandler('pw_garage:client:openVehicleStats', function(data)
    inParkedVehs = {['type'] = data.type, ['garage'] = data.garage}
    local infoSub = {}

    if data.type == 'Impound' then
        table.insert(infoSub, { ['label'] = "Release from Impound Lot", ['action'] = 'pw_garage:client:checkClearPathForSpawn', ['value'] = {plate = data.props.plate, garage = data.garage, type = data.type, name = data.name}, ['triggertype'] = 'client', ['color'] = 'info'})
        table.insert(infoSub, { ['label'] = "Plate: "..data.props.plate, ['action'] = '', ['triggertype'] = 'client', ['color'] = 'primary'})
    else
        local engineHealth = math.ceil((data.props.engineHealth-100)/900*100)
        local bodyHealth = math.ceil((data.props.bodyHealth-100)/900*100)
        local fuelLevel = math.ceil(data.props.fuelLevel)
        table.insert(infoSub, { ['label'] = "Take Out", ['action'] = 'pw_garage:client:checkClearPathForSpawn', ['value'] = {plate = data.props.plate, garage = data.garage, type = data.type, auto = data.auto}, ['triggertype'] = 'client', ['color'] = 'info'})
        table.insert(infoSub, { ['label'] = "Plate: "..data.props.plate, ['action'] = '', ['triggertype'] = 'client', ['color'] = 'primary'})
        table.insert(infoSub, { ['label'] = "Fuel Level: "..fuelLevel.."%", ['action'] = '', ['triggertype'] = 'client', ['color'] = (fuelLevel < 25 and 'danger' or fuelLevel < 75 and 'warning' or 'success')})
        table.insert(infoSub, { ['label'] = "Engine Health: "..(engineHealth > 0 and engineHealth or 0).."%", ['action'] = '', ['triggertype'] = 'client', ['color'] = (engineHealth < 25 and 'danger' or engineHealth < 75 and 'warning' or 'success')})
        table.insert(infoSub, { ['label'] = "Body Health: "..(bodyHealth > 0 and bodyHealth or 0).."%", ['action'] = '', ['triggertype'] = 'client', ['color'] = (bodyHealth < 25 and 'danger' or bodyHealth < 75 and 'warning' or 'success')})
    end
    
    TriggerEvent('pw_interact:generateMenu', infoSub, data.name, { { ['trigger'] = 'pw_garage:client:openGarageAfterClose', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_garage:client:privateGarage')
AddEventHandler('pw_garage:client:privateGarage', function(house)
    OpenGarage('Private', house)                
end)

function StoreVehicle(veh)
    SetEntityAsMissionEntity(veh, true, true)
    DeleteEntity(veh)
    for k,v in pairs(spawnedVehicles) do
        local vNet = NetworkGetEntityFromNetworkId(v.veh)
        if vNet == veh then
            table.remove(spawnedVehicles, k)
            break
        end
    end
end

function CanPark(type, id)
    if type == 'Public' or type == 'Impound' or type == 'Business' then
        if garages[id].curSlots >= garages[id].maxSlots then
            return false
        else
            return true
        end
    elseif type == 'Private' then
        if privateGarages[id].curSlots >= privateGarages[id].maxSlots then
            return false
        else
            return true
        end
    elseif type == 'Unit' then
        if units[id].curSlots >= units[id].maxSlots then
            return false
        else
            return true
        end
    end
end

function ShowPrivateGarage(id)    
    Citizen.CreateThread(function()
        while showMarker == 'private'..id do
            local canPark = CanPark('Private', id)
            local checkVeh = IsPedInAnyVehicle(GLOBAL_PED, false)
            if not showingInfo or checkVeh ~= onVeh or prevPrivSlots[id] ~= privateGarages[id].curSlots then
                onVeh = checkVeh
                prevPrivSlots[id] = privateGarages[id].curSlots
                showingInfo = true
                TriggerEvent('pw_drawtext:showNotification', {title = "<span class='text-primary' style='font-size:20px;'>"..privateGarages[id].name.."</span>", message = "<span style='font-size:22px;'>Slots: <span style='color:" .. (canPark and '#187200' or '#FF0000')..";'>".. privateGarages[id].curSlots .. "</span>/<span class='text-primary'>" .. privateGarages[id].maxSlots .."</span></span><br>Press <span class='text-success'>[E]</span> to "..(onVeh and "park this vehicle" or "take a vehicle out"), icon = "fad fa-warehouse"})
            end
            Citizen.Wait(1)
        end
    end)
end

RegisterNetEvent('pw_garage:client:showPrivateInfo')
AddEventHandler('pw_garage:client:showPrivateInfo', function(id)
    if not showMarker then
        showMarker = 'private'..id
        ShowPrivateGarage(id)
    end
end)

RegisterNetEvent('pw_garage:client:hidePrivateInfo')
AddEventHandler('pw_garage:client:hidePrivateInfo', function(id)
    if showMarker == 'private'..id then showMarker = false;showingInfo = false; end
    TriggerEvent('pw_drawtext:hideNotification')
end)

RegisterNetEvent('pw_garage:client:abandonConfirm')
AddEventHandler('pw_garage:client:abandonConfirm', function(id)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b><span class="text-danger">ATTENTION</span></b><br>This action is <b>irreversible</b>. This Garage Unit will no longer be yours after you sign this form.' },
        { ['type'] = 'checkbox', ['label'] = 'I am aware of the implications that this signature has. I will no longer be able to access this unit unless I buy it again.<br><i>(Owner) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = 'contractReview', ['value'] = 'yes'},
        { ['type'] = 'hidden', ['name'] = 'id', ['value'] = id }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_garage:server:abandonUnit', 'server', form, 'Abandon Garage Unit #'..id)
end)

function OpenUnitMenu(id)
    local menu = {}
    --table.insert(menu, { ['label'] = "Give Keys", ['action'] = '', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Abandon Garage Unit", ['action'] = 'pw_garage:client:abandonConfirm', ['value'] = id, ['triggertype'] = 'client', ['color'] = 'danger' })

    TriggerEvent('pw_interact:generateMenu', menu, "Unit #"..id.." Options")
end


RegisterNetEvent('pw_garage:client:openUnitMenu')
AddEventHandler('pw_garage:client:openUnitMenu', function()
    if showingInfo and showMarker then
        if string.find(showMarker, "unit") ~= nil then
            local res, pos = string.gsub(showMarker, "unit", "")
            local id = tonumber(res)
            if playerData.cid == units[id].owner then
                OpenUnitMenu(id)
            end
        end
    end
end)

RegisterNetEvent('pw_garage:client:boughtUnit')
AddEventHandler('pw_garage:client:boughtUnit', function(id, cid)
    units[id].owner = cid
    showingInfo = false
    if playerData.cid == cid then
        DrawBlip(id, 'Unit')
    elseif cid == nil then
        RemoveBlip(unitBlips[id])
        unitBlips[id] = nil
    end
end)

RegisterNetEvent('pw_garage:client:signThisVeh')
AddEventHandler('pw_garage:client:signThisVeh', function(data)
    local processed, vehCost = false, 0

    PW.TriggerServerCallback('pw_garage:server:getVehCost', function(cost)
        vehCost = cost
        processed = true
    end, data.model)

    repeat Wait(0) until processed == true

    local dailyPayment = Config.Insurance.plans[data.plan].dailyCost + math.ceil((vehCost * (Config.Insurance.vehiclePercentage / 100)))
    data['payment'] = dailyPayment
    
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<i>Vehicles must have a valid license plate and visible VIN plate to be eligible for coverage.</i>' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>PLAN DETAILS</b><br><b><span class="text-info">' .. Config.Insurance.plans[data.plan].label .. '</span></b><br>Tows: <b><span class="text-primary">'.. (Config.Insurance.plans[data.plan].tows == -1 and "Unlimited" or Config.Insurance.plans[data.plan].tows) .. '</span></b> | Fuel: <b><span class="text-primary">'.. Config.Insurance.plans[data.plan].fuel ..' Jerrycans</span></b><br>Monthly Cost: <b><span class="text-success">$' .. dailyPayment ..'</span></b>' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>TOWING SERVICE</b><br>The closest Service Provider will arrange the towing service and will then tow your vehicle to any garage of your choice, service includes the use of flatbed car carriers.' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>FUEL DELIVERY SERVICE</b><br>The closest Service Provider will arrange a fuel delivery service that will supply you with an emergency jerrycan.' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>METHODS OF PAYMENT</b><br>The membership fees are payable monthly by automatic bank transfer.<br>The Insurance Company requires the payment of the first month upfront to link your bank account to the automatic bank transfer system.' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>CANCELLATION POLICY</b><br>Our services are provided through a monthly membership billing plan. Cancel any time at the closest Service Provider.' },
        
        { ['type'] = "checkbox", ['label'] = '<i>I agree with the mentioned terms and authorize this company to receive automatic bank transfers from my bank account, including the charge of the first month (<b><span class="text-success">$' .. dailyPayment .. '</span></b>) which will be processed as soon as the contract is submited.<br>(Vehicle owner signature) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = 'info', ['data'] = data }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_garage:server:createContract', 'server', form, "Insurance Terms", {}, false, '500px')
end)

RegisterNetEvent('pw_garage:client:signInsurancePlan')
AddEventHandler('pw_garage:client:signInsurancePlan', function(plan)
    local menu = {}
    local myVehs = {}
    PW.TriggerServerCallback('pw_garage:server:getOwnedVehs', function(vehs)
        myVehs = vehs
        if myVehs then
            for k,v in pairs(myVehs) do
                table.insert(menu, { ['label'] = v.plate .. ' (' .. PW.Vehicles.GetName(v.model) .. ')', ['action'] = (not v.cooldown and 'pw_garage:client:signThisVeh' or ''), ['value'] = { ['vid'] = v.vid, ['plan'] = plan, ['model'] = v.model }, ['triggertype'] = 'client', ['color'] = (not v.cooldown and 'primary' or 'danger') })
                if v.cooldown then
                    local sub = {}
                    table.insert(sub, { ['label'] = "Too soon to sign a new contract." })
                    menu[#menu]['subMenu'] = sub
                end
            end            
        else
            table.insert(menu, { ['label'] = 'No owned vehicles', ['color'] = 'danger disabled' })
        end

        TriggerEvent('pw_interact:generateMenu', menu, "Choose a vehicle")
    end)
end)

RegisterNetEvent('pw_garage:client:showPlans')
AddEventHandler('pw_garage:client:showPlans', function()
    local menu = {}

    for k,v in pairs(Config.Insurance.plans) do
        local sub = {}
        table.insert(sub, { ['label'] = 'Monthly Tows: <b>' .. (v.tows > -1 and v.tows or 'Unlimited') .. '</b>' })
        table.insert(sub, { ['label'] = 'Monthly Fuel: <b>' .. v.fuel .. ' Jerrycans</b>' })
        table.insert(sub, { ['label'] = 'Monthly Cost: <b><span class="text-success">$' .. v.dailyCost ..'</span></b> + <b><span class="text-primary">1%</span> vehicle cost</b>' })
        table.insert(sub, { ['label'] = '<b><span class="text-primary">Sign this plan</span></b>', ['action'] = 'pw_garage:client:signInsurancePlan', ['value'] = k, ['triggertype'] = 'client' })
        table.insert(menu, { ['label'] = v.label, ['color'] = 'primary', ['subMenu'] = sub })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Insurance Plans")
end)

RegisterNetEvent('pw_garage:client:endInsurance')
AddEventHandler('pw_garage:client:endInsurance', function(vid)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Your insurance contract will be terminated as of this instant.<br>Are you sure?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'vid', ['value'] = vid  }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_garage:server:endInsurance', 'server', form, 'Contract Termination')
end)

RegisterNetEvent('pw_garage:client:retrieveToGarage')
AddEventHandler('pw_garage:client:retrieveToGarage', function(data)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = 'Are you sure you want to pick <br><b><span class="text-primary">' .. garages[data.garage].name .. '</span></b><br>as the pickup location for your vehicle?' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'info', ['data'] = data }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_garage:server:sendVehToPickup', 'server', form, "Confirm pickup location")
end)

RegisterNetEvent('pw_garage:client:retrieveInsuredVeh')
AddEventHandler('pw_garage:client:retrieveInsuredVeh', function(vid)
    local menu = {}

    for k,v in pairs(garages) do
        if v.type == 'Public' then
            local full = v.curSlots >= v.maxSlots
            table.insert(menu, { ['label'] = v.name .. (full and ' (Full)' or ''), ['color'] = 'primary' .. (full and ' disabled' or '') })
            if not full then
                local sub = {}
                table.insert(sub, { ['label'] = 'Choose as destination', ['action'] = 'pw_garage:client:retrieveToGarage', ['value'] = { vid = vid, garage = k }, ['triggertype'] = 'client' })
                menu[#menu]['subMenu'] = sub
            end
        end
    end

    TriggerEvent('pw_interact:generateMenu', menu, 'Choose a vehicle pickup destination')
end)

RegisterNetEvent('pw_garage:client:loadInsurance')
AddEventHandler('pw_garage:client:loadInsurance', function(vid)
    local sub = {}
    local menu = {}
    PW.TriggerServerCallback('pw_garage:server:loadInsurance', function(info)
        if info.plan > 0 then
            if info.insured then
                table.insert(sub, { ['label'] = 'Retrieve vehicle', ['action'] = 'pw_garage:client:retrieveInsuredVeh', ['value'] = vid, ['triggertype'] = 'client' })
                table.insert(menu, { ['label'] = 'Vehicle towed by the Insurance Company', ['color'] = 'warning', ['subMenu'] = sub })
            end

            table.insert(menu, { ['label'] = 'Plan Type: '..info.plan, ['color'] = 'primary' })
            
            local planTows = Config.Insurance.plans[info.plan].tows
            local planFuel = Config.Insurance.plans[info.plan].fuel
            table.insert(menu, { ['label'] = 'Tows: ' .. (planTows ~= -1 and info.tows .. '/' .. planTows or 'Unlimited'), ['color'] = 'primary' })
            table.insert(menu, { ['label'] = 'Fuel: ' .. info.fuel .. '/' .. planFuel .. ' Jerrycans', ['color'] = 'primary' })
            
            if not info.insured then
                table.insert(menu, { ['label'] = 'Cancel Insurance', ['action'] = 'pw_garage:client:endInsurance', ['value'] = vid, ['triggertype'] = 'client', ['color'] = 'danger' })
            end
        else
            table.insert(sub, { ['label'] = 'Check Insurance Plans', ['action'] = 'pw_garage:client:showPlans', ['triggertype'] = 'client' })
            table.insert(menu, { ['label'] = 'Not insured', ['color'] = 'danger', ['subMenu'] = sub })
        end
        TriggerEvent('pw_interact:generateMenu', menu, 'Insurance Info')
    end, vid)

end)

RegisterNetEvent('pw_garage:client:openVehsInsurance')
AddEventHandler('pw_garage:client:openVehsInsurance', function(vehs)
    local menu = {}

    if vehs then
        for k,v in pairs(vehs) do
            table.insert(menu, { ['label'] = v.plate .. ' (' .. PW.Vehicles.GetName(v.model) .. ')', ['action'] = 'pw_garage:client:loadInsurance', ['value'] = v.vid, ['triggertype'] = 'client', ['color'] = 'primary' })
        end
    else
        table.insert(menu, { ['label'] = "No owned vehicles", ['color'] = 'danger disabled' })
    end
    
    TriggerEvent('pw_interact:generateMenu', menu, "Owned vehicles")
end)

RegisterNetEvent('pw_garage:client:askForFuel')
AddEventHandler('pw_garage:client:askForFuel', function()
    if not waitingFuel then
        if not DoesEntityExist(taxi.veh) then
            taxi.veh = CreateVeh()

            while not DoesEntityExist(taxi.veh) do
                Wait(1)
            end

            taxi.ped = CreateDriver(taxi.veh)

            while not DoesEntityExist(taxi.ped) do
                Wait(1)
            end
            
            local pumpObjCoords = GetClosestPump(taxi.ped)
            
            if pumpObjCoords then
                local closestPumpNode, closestNodePos = GetClosestVehicleNode(pumpObjCoords.x, pumpObjCoords.y, pumpObjCoords.z, 1, 3.0, 0)
                
                GoTo(taxi.ped, taxi.veh, closestNodePos)
                
                waitingPump = true
                taxi.status = 'goingStation'
                ChangeBlipText(GetBlipFromEntity(taxi.ped), taxi.status)
                CheckForPumpArrival(closestNodePos, pumpObjCoords)

            else
                exports.pw_notify:SendAlert('error', 'Service unavailable from this place', 4500)
                SendFuelAway()
            end
        end
    else
        exports.pw_notify:SendAlert('error', 'You already have a pending delivery ongoing', 4500)
    end
end)

function CheckForPumpArrival(nodeCoords, pumpCoords)
    local pastDist = 0
    local distDiff = 9999
    local pastNode = 0
    local closestPossible = false
    Citizen.CreateThread(function()
        while waitingPump do
            Citizen.Wait(500)
            waitingPump = CheckVehStatus(taxi)
            local pedCoords = GetEntityCoords(taxi.ped)
            local dist = #(pedCoords - nodeCoords)
            if dist < 50.0 then
                GoTo(taxi.ped, taxi.veh, nodeCoords, false, { ['speed'] = 6.0, ['stopRange'] = 2.0 })
                local goingToPump = true
                local lastPumpDist = 0
                while goingToPump do
                    Citizen.Wait(100)
                    pedCoords = GetEntityCoords(taxi.ped)
                    local pumpDist = #(pedCoords - nodeCoords)
                    
                    if pumpDist < 5.0 then
                        goingToPump = false
                    else
                        if math.abs(pumpDist - lastPumpDist) < 0.005 then
                            GoTo(taxi.ped, taxi.veh, nodeCoords, false, { ['speed'] = 6.0, ['stopRange'] = 2.0 })
                        end
                        lastPumpDist = pumpDist
                    end
                end
                taxi.status = 'picking'
                ChangeBlipText(GetBlipFromEntity(taxi.ped), taxi.status)
                Wait(Config.Insurance.fuelDeliveryJerrycanPicking * 1000)
                taxi.status = 'destination'
                ChangeBlipText(GetBlipFromEntity(taxi.ped), taxi.status)
                local closestPedNode, closestNodePos = GetClosestVehicleNode(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, 1, 3.0, 0)
                
                GoTo(taxi.ped, taxi.veh, closestNodePos, true)
                
                waitingFuel = true
                CheckForArrival()
                waitingPump = false
                walking = false
            end
        end
    end)
end

function CheckForArrival()
    local pastDist = 0
    local distDiff = 9999
    local pastNode = 0
    local closestPossible = false
    Citizen.CreateThread(function()
        while waitingFuel do
            Citizen.Wait(500)
            waitingFuel = CheckVehStatus(taxi)
            local playerPed = GLOBAL_PED
            local pedCoords = GLOBAL_COORDS
            local targetPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.45, -1.0)
            local vehCoords = GetEntityCoords(taxi.veh)
            local dist = #(pedCoords - vehCoords)
            distDiff = #(pastDist - vehCoords)

            if dist < 10.0 or closestPossible then
                if distDiff < 0.001 then
                    TaskLeaveVehicle(taxi.ped, taxi.veh, 1)
                    while IsPedInAnyVehicle(taxi.ped) do
                        Wait(0)
                    end

                    TaskGoToCoordAnyMeans(taxi.ped, targetPos, 1.0, 0, 0, 786603, 0xbf800000)
                    SetPedKeepTask(taxi.ped, true)
                    
                    GiveWeaponToPed(taxi.ped, GetHashKey("WEAPON_PETROLCAN"), 4500, true, true)
                    
                    local walking = true
                    while walking do
                        Citizen.Wait(100)
                        pedCoords = GLOBAL_COORDS
                        local npcCoords = GetEntityCoords(taxi.ped)
                        local npcDist = #(npcCoords - pedCoords)
                        if npcDist < 2.0 then
                            TriggerServerEvent('pw_base:giveWeapon', "WEAPON_PETROLCAN", 4500)
                            TaskTurnPedToFaceEntity(taxi.ped, playerPed, -1)
                            TaskTurnPedToFaceEntity(playerPed, taxi.ped, -1)
                            repeat Wait(0) until gotCan == true
                            gotCan = false

                            PlayGivingAnims(playerPed, taxi.ped)

                            walking = false
                            waitingFuel = false
                            SendFuelAway()
                        else
                            targetPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.45, -1.0)
                            TaskGoToCoordAnyMeans(taxi.ped, targetPos, 1.0, 0, 0, 786603, 0xbf800000)
                        end
                    end
                end
            else
                if not closestPossible and distDiff < 0.001 then -- npc stopped
                    local closestPedNode, closestNodePos = GetClosestVehicleNode(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, 1, 3.0, 0)
                    if pastNode == closestPedNode and dist < 10.0 then
                        closestPossible = true
                    else
                        GoTo(taxi.ped, taxi.veh, closestNodePos, true)
                        pastNode = closestPedNode
                    end
                end
            end
            pastDist = vehCoords
        end
    end)
end

function SendFuelAway()
    Citizen.CreateThread(function()
        TaskEnterVehicle(taxi.ped, taxi.veh, 15000, -1, 1.0, 1, 0)
        TaskVehicleDriveWander(taxi.ped, taxi.veh, 26.0, 1073741824)
        local blip = GetBlipFromEntity(taxi.veh)
    
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        Citizen.Wait(15000)
        if DoesEntityExist(taxi.veh) then    
            DeleteEntity(taxi.ped)
            DeleteEntity(taxi.veh)
        end
    
        if not DoesEntityExist(taxi.veh) and DoesEntityExist(taxi.ped) then
            DeleteEntity(taxi.ped)
        end

        taxi.veh = 0
        taxi.ped = 0
        taxi.status = 0
    end)
end

function OpenInsurance(id)
    local menu = {}

    local myVehs = {}
    PW.TriggerServerCallback('pw_garage:server:getOwnedVehs', function(vehs)
        myVehs = vehs
        table.insert(menu, { ['label'] = (not myVehs and "You don't own any vehicle" or "Check Vehicle Insurance info"), ['action'] = (myVehs and 'pw_garage:client:openVehsInsurance' or ''), ['triggertype'] = 'client', ['value'] = myVehs, ['color'] = (not myVehs and 'danger disabled' or 'primary') })
        table.insert(menu, { ['label'] = "View Insurance Plans", ['action'] = 'pw_garage:client:showPlans', ['triggertype'] = 'client', ['color'] = 'info' })
        
        TriggerEvent('pw_interact:generateMenu', menu, "Insurance Options")
    end)
end

function BuyUnit(id)
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Garage Unit <span class='text-info'>#"..id.."</span></b><br>Price: <b><span class='text-success'>$"..units[id].price },
        -- placeholder purchase form
        { ['type'] = "checkbox", ['label'] = '<i>(Buyer signature) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "unitId", ['value'] = id }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_garage:server:buyUnit', 'server', form, 'Garage Unit #'..id)
end

function ShowUnit(x,y,z,id)
    Citizen.CreateThread(function()
        while showMarker == 'unit'..id and playerData and playerLoaded do
            if units[id].owner ~= nil then
                if playerData.cid == units[id].owner then
                    DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, true, nil, nil, false)
                    local canPark = CanPark('Unit', id)
                    local checkVeh = IsPedInAnyVehicle(GLOBAL_PED, false)
                    if not showingInfo or checkVeh ~= onVeh or prevUnitSlots[id] ~= units[id].curSlots then
                        onVeh = checkVeh
                        prevUnitSlots[id] = units[id].curSlots
                        showingInfo = true
                        TriggerEvent('pw_drawtext:showNotification', {title = "<span class='text-primary' style='font-size:20px;'>"..units[id].name.." (#"..id..")</span>", message = "<span style='font-size:22px;'>Slots: <span style='color:" .. (canPark and '#187200' or '#FF0000')..";'>".. units[id].curSlots .. "</span>/<span class='text-primary'>" .. units[id].maxSlots .."</span></span><br>Press <span class='text-success'>[E]</span> to "..(onVeh and "park this vehicle" or "take a vehicle out"), icon = "fad fa-warehouse"})
                    end
                    if IsControlJustPressed(0, 38) then
                        OpenGarage('Unit', id)
                    end
                end
            else -- for sale
                DrawMarker(29, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, true, nil, nil, false)
                if not showingInfo or prevUnitOwner[id] ~= units[id].owner then
                    prevUnitOwner[id] = units[id].owner
                    showingInfo = true
                    TriggerEvent('pw_drawtext:showNotification', {title = "<span class='text-primary' style='font-size:20px;'>"..units[id].name.." (Garage Unit #"..id..")</span>", message = "<span style='font-size:22px;'>Price: <span class='text-success'>$"..units[id].price.."</span><br>Capacity: <span class='text-info'>".. units[id].maxSlots .. (units[id].maxSlots > 1 and " vehicles" or " vehicle") .. "</span></span><br>Press <span class='text-success'>[E]</span> to buy this garage unit", icon = "fad fa-warehouse"})
                end
                if IsControlJustPressed(0, 38) then
                    BuyUnit(id)
                end
            end
            Citizen.Wait(1)
        end
    end)
end

function ShowGarage(x,y,z,id,type)
    Citizen.CreateThread(function()
        while showMarker == 'garage'..id do
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, true, nil, nil, false)
            local checkVeh = IsPedInAnyVehicle(GLOBAL_PED, false)
            if not showingInfo or checkVeh ~= onVeh or prevSlots[id] ~= garages[id].curSlots then
                local canPark = CanPark(type, id)
                onVeh = checkVeh
                prevSlots[id] = garages[id].curSlots
                showingInfo = true
                TriggerEvent('pw_drawtext:showNotification', {title = "<span class='text-primary' style='font-size:20px;'>"..garages[id].name.."</span>", message = "<span style='font-size:22px;'>Slots: <span style='color:" .. (canPark and '#187200' or '#FF0000')..";'>".. garages[id].curSlots .. "</span>/<span class='text-primary'>" .. garages[id].maxSlots .."</span></span><br>Press <span class='text-success'>[E]</span> to "..(onVeh and "park this vehicle" or "take a vehicle out"), icon = "fad fa-warehouse"})
            end
            if IsControlJustPressed(0, 38) then
                OpenGarage(type, id)
            end
            Citizen.Wait(1)
        end
    end)
end

function ShowInsurance(id)
    Citizen.CreateThread(function()
        while showMarker == 'insurance'.. id do
            if playerLoaded then
                DrawMarker(Config.Marker.markerType, Config.Insurance.buildings[id].coords.x, Config.Insurance.buildings[id].coords.y, Config.Insurance.buildings[id].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, true, nil, nil, false)
                TriggerEvent('pw_drawtext:showNotification', {title = "<span class='text-primary' style='font-size:20px;'>"..Config.Insurance.buildings[id].name.."</span>", message = "Press <span class='text-success'>[E]</span> to check Insurance information", icon = "fad fa-user-shield"})
                if IsControlJustPressed(0, 38) then
                    OpenInsurance(id)
                end
            else
                showMarker = false
            end
            Citizen.Wait(1)
        end
    end)
end

function DrawBlip(id, type)
    local blip
    if type == 'Insurance' then
        blip = AddBlipForCoord(Config.Insurance.buildings[id].coords.x, Config.Insurance.buildings[id].coords.y, Config.Insurance.buildings[id].coords.z)
        SetBlipSprite(blip, Config.Insurance.buildings[id].blip.sprite)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip,Config.Insurance.buildings[id].blip.color)
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
    else
        if type == 'Unit' then
            blip = AddBlipForCoord(units[id].location.x, units[id].location.y, units[id].location.z)
        else
            blip = AddBlipForCoord(garages[id].location.x, garages[id].location.y, garages[id].location.z)
        end
        SetBlipSprite(blip, Config.Blips.blipSprite)
        SetBlipScale(blip, Config.Blips.blipScale)
        SetBlipColour(blip, Config.Blips.color[type])
        SetBlipDisplay(blip, 4)
        SetBlipAsShortRange(blip, true)
    end

    BeginTextCommandSetBlipName("STRING")
    if type == 'Public' then
        AddTextComponentString("Public Garage")
    elseif type == 'Business' then
        AddTextComponentString(garages[id].name)
    elseif type == 'Impound' then
        AddTextComponentString("Impound Lot")
    elseif type == 'Unit' then
        AddTextComponentString("Owned Garage Unit")
    elseif type == 'Insurance' then
        AddTextComponentString(Config.Insurance.buildings[id].name)
    end
    EndTextCommandSetBlipName(blip)

    if type == 'Public' or type == 'Impound' or type == 'Business' then
        blips[id] = blip
    elseif type == 'Unit' then
        unitBlips[id] = blip
    elseif type == 'Insurance' then
        insuranceBlips[id] = blip
    end
end

function CreateBlips()
    for k,v in pairs(garages) do
        DrawBlip(k, v.type)
    end
    for k,v in pairs(units) do
        if playerData.cid == v.owner then
            DrawBlip(k, 'Unit')
        end
    end
    for k,v in pairs(Config.Insurance.buildings) do
        DrawBlip(k, 'Insurance')
    end
end

Citizen.CreateThread(function()
    while true do
        if playerLoaded and garages ~= nil and #garages > 0 then
            local ped = GLOBAL_PED
            local pedCoords = GLOBAL_COORDS
            for i = 1, #garages do
                if garages[i].type == 'Public' or garages[i].type == 'Impound' or garages[i].type == 'Business' then
                    local dist = #(vector3(garages[i].location.x, garages[i].location.y, garages[i].location.z) - pedCoords)
                    if dist < Config.Marker.markerDraw then
                        if not showMarker then
                            local proceed = false
                            if garages[i].type == 'Business' then
                                if ownsTaco and MetaChecks('taco', i) then
                                    proceed = true
                                end
                            else
                                proceed = true
                            end

                            if proceed then
                                showMarker = 'garage'..i
                                ShowGarage(garages[i].location.x, garages[i].location.y, garages[i].location.z, i, garages[i].type)
                            end
                        end
                    else
                        if showMarker == 'garage'..i then
                            showMarker = false
                            showingInfo = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                    end
                end
            end
        end
        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        if playerLoaded and units ~= nil and #units > 0 then
            local ped = GLOBAL_PED
            local pedCoords = GLOBAL_COORDS
            for i = 1, #units do
                local dist = #(vector3(units[i].location.x, units[i].location.y, units[i].location.z) - pedCoords)
                if dist < Config.Marker.markerDraw then
                    if not showMarker then
                        showMarker = 'unit'..i
                        ShowUnit(units[i].location.x, units[i].location.y, units[i].location.z, i)
                    end
                else
                    if showMarker == 'unit'..i then
                        showMarker = false
                        showingInfo = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                end
            end
        end
        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        if playerLoaded then 
            local ped = GLOBAL_PED
            local pedCoords = GLOBAL_COORDS
            for i = 1, #Config.Insurance.buildings do
                local dist = #(vector3(Config.Insurance.buildings[i].coords.x, Config.Insurance.buildings[i].coords.y, Config.Insurance.buildings[i].coords.z) - pedCoords)
                if dist < 2.0 then
                    if not showMarker then
                        showMarker = 'insurance'..i
                        ShowInsurance(i)                        
                    end
                else
                    if showMarker == 'insurance'..i then
                        showMarker = false
                        showingInfo = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                end
            end
        end
        Citizen.Wait(100)
    end
end)