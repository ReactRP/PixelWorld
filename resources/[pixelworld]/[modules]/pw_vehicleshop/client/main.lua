PW = nil
playerData, playerLoaded = nil, false
local playerPedIdent, playerCoords, testDriveVehicle, chosenVehicle = nil, nil, nil, nil
local testDriveTimer, testDriveDealer, displayedVeh, cam = 0, 0, 0, 0
local curShowroom, curShowroom, showing, waitingKey, showingDraw, inShopCatalogue, loading, forced, inVehDisplay, inCatDisplay, inSellVehMenu, inManageShowroom, inManageShowroomSpot = false, false, false, false, false, false, false, false, false, false, false, false, false
local spawned, Dealers = {}, {}

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
		Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw_vehicleshop:client:setDecor')
AddEventHandler('pw_vehicleshop:client:setDecor', function(id, property, toggle, dtype)
    if dtype == "bool" then
        typeid = 2
    elseif dtype == "int" then
        typeid = 3
    elseif dtype == "float" then
        typeid = 1
    end

    if DecorIsRegisteredAsType(property, typeid) then
        if not DecorExistOn(id, property) then
            if dtype == "bool" then
                DecorSetBool(id, property, toggle)
            elseif dtype == "int" then
                DecorGetInt(id, property, toggle)
            elseif dtype == "float" then
                DecorSetFloat(id, property, toggle)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            playerPedIdent = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            playerCoords = GetEntityCoords(playerPedIdent)
        end
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            PW.TriggerServerCallback('pw_vehicleshop:server:getDisplayed', function(disp, chos)
                displayedVeh = disp
                chosenVehicle = chos
                PW.TriggerServerCallback('pw_vehicleshop:server:requestConfig', function(deals)
                    Dealers = deals
                    playerPedIdent = PlayerPedId()
                    playerCoords = GetEntityCoords(playerPedIdent)
                    createBlips()
                    playerLoaded = true
                end)
            end)
        else
            playerData = data
        end
    else
        RemoveShowroom()
        destroyBlips()
        TriggerServerEvent('pw_vehicleshop:server:resetTestDriveDeposit')
        if testDriveVehicle then
            DeleteVehicle(testDriveVehicle)
            testDriveVehicle = nil
        end
        
        testDriveTimer = 0
        waitingKey = false
        showing = false
        displayedVeh = false
        chosenVehicle = false
        Dealers = {}
        playerLoaded = false
        playerData = nil
        playerData = nil
        playerLoaded = false
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
    end    
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
        showing = false
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        RemoveShowroom()
        TriggerEvent('pw_vehicleshop:client:deleteDisplayed')
        displayedVeh = 0
        chosenVehicle = nil
    end
end)

AddEventHandler('pw_interact:closeMenu', function()
    if inVehDisplay then
        TriggerEvent('pw_vehicleshop:client:openVehicleDisplay')
    elseif inCatDisplay or inSellVehMenu or inManageShowroom then
        TriggerEvent('pw_vehicleshop:dealerMenu')
    end
end)

function RemoveShowroom()
    if TblLen(spawned) > 0 then
        for k,v in pairs(spawned) do
            if v.obj ~= 0 and DoesEntityExist(v.obj) then
                DeleteEntity(v.obj)
            end
        end
    end
    spawned = {}
end

function TblLen(tbl)
    local count = 0
    if type(tbl) == 'table' then
        for _,_ in pairs(tbl) do
            count = count + 1
        end
    end
    return count
end

function GetVehInSpot(dealer, spot)
    if TblLen(Dealers[dealer].showroom) > 0 then
        for k,v in pairs(Dealers[dealer].showroom) do
            if v.spot == spot then
                return k
            end
        end
    end
    return false
end

RegisterNetEvent('pw_vehicleshop:client:spawnShowroomVehs')
AddEventHandler('pw_vehicleshop:client:spawnShowroomVehs', function(dealer)
    RemoveShowroom()
    curShowroom = dealer
    for i = 1, #Dealers[dealer].showroomspots do
        local vehSpot = GetVehInSpot(dealer, i)
        if vehSpot then
            local veh = Dealers[dealer].showroom[vehSpot]
            local vehProps = veh.vehicle
            local obj
            PW.Game.SpawnLocalVehicle(vehProps.model, vector3(Dealers[dealer].showroomspots[i].x, Dealers[dealer].showroomspots[i].y, Dealers[dealer].showroomspots[i].z), Dealers[dealer].showroomspots[i].h, function(veh)
                obj = veh
            end)
            repeat Wait(0) until obj ~= nil
            spawned[i] = { ['obj'] = obj, ['price'] = veh.price }
            SetVehicleOnGroundProperly(spawned[i]["obj"])
            Citizen.Wait(1000)
            FreezeEntityPosition(spawned[i]["obj"], true)
            SetEntityAsMissionEntity(spawned[i]["obj"], true, true)
            PW.Game.SetVehicleProperties(spawned[i]["obj"], vehProps)
            SetVehicleDoorsLocked(spawned[i]["obj"], 2)
        else
            spawned[i] = { ['obj'] = 0, ['price'] = 0 }
        end
    end
end)

-- Map Blips
local blips = {}

function createBlips()
    Citizen.CreateThread(function()
        while Dealers[1] == nil do Wait(100); end
        for k,v in pairs(Dealers) do
            blips[v.id] = AddBlipForCoord(v.coords.standard.x, v.coords.standard.y, v.coords.standard.z)
            SetBlipSprite(blips[v.id], Config.Marker[v.type].blipSprite)
            SetBlipDisplay(blips[v.id], 4)
            SetBlipScale  (blips[v.id], Config.Marker[v.type].blipScale)
            SetBlipColour (blips[v.id], Config.Marker[v.type].blipColor)
            SetBlipAsShortRange(blips[v.id], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.name)
            EndTextCommandSetBlipName(blips[v.id])
        end
    end)
end

function destroyBlips()
    if blips and blips[1] then
        for k,v in pairs(blips) do
            RemoveBlip(v)
        end
        blips = {}
    end
end


RegisterNetEvent('pw_vehicleshop:client:loadVehicleShowroom')
AddEventHandler('pw_vehicleshop:client:loadVehicleShowroom', function(data)
    if displayedVeh then 
        FreezeEntityPosition(displayedVeh, false)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        DeleteVehicle(displayedVeh)
    end
    PW.Game.SpawnOwnedVehicle(data.model, vector3(Dealers[curShowroom].coords.display.x, Dealers[curShowroom].coords.display.y, Dealers[curShowroom].coords.display.z), Dealers[curShowroom].coords.display.h, function(veh)
        displayedVeh = veh
        if not HasModelLoaded(GetHashKey(data.model)) then
            Citizen.Wait(10)
        else
            TriggerEvent('pw_interact:enableSlider')
        end
        TriggerServerEvent('pw_vehicleshop:server:updateDisplayed', displayedVeh, nil)
        FreezeEntityPosition(displayedVeh, true)
        local color = Config.AvailableColors[math.random(1, #Config.AvailableColors)].index
        PW.Game.SetVehicleProperties(displayedVeh, { ['dirtLevel'] = 0.0, ['color1'] = color, ['color2'] = color })
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:newModel')
AddEventHandler('pw_vehicleshop:client:newModel', function(dealer, spot, price, props)
    if curShowroom == dealer then
        local cV = GetClosestVehicle(Dealers[curShowroom].showroomspots[spot].x, Dealers[curShowroom].showroomspots[spot].y, Dealers[curShowroom].showroomspots[spot].z, 1.5, 0, 70)
        if cV then
            FreezeEntityPosition(cV, false)
            SetEntityAsMissionEntity(cV, true, true)
            DeleteVehicle(cV)
        end
        
        PW.Game.SpawnLocalVehicle(props.model, vector3(Dealers[curShowroom].showroomspots[spot].x, Dealers[curShowroom].showroomspots[spot].y, Dealers[curShowroom].showroomspots[spot].z), Dealers[curShowroom].showroomspots[spot].h, function(veh)
            local spawnedVeh = veh
            FreezeEntityPosition(spawnedVeh, true)
            SetEntityAsMissionEntity(spawnedVeh, true, true)
            PW.Game.SetVehicleProperties(spawnedVeh, props)
            SetVehicleDoorsLocked(spawnedVeh, 2)

            spawned[spot] = { ['obj'] = spawnedVeh, ['price'] = price }
        end)
    end
end)

RegisterNetEvent('pw_vehicleshop:client:addedSpot')
AddEventHandler('pw_vehicleshop:client:addedSpot', function(spot, props, price)
    if displayedVeh then 
        FreezeEntityPosition(displayedVeh, false)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        DeleteVehicle(displayedVeh)
    end
    displayedVeh = 0
    chosenVehicle = nil
    TriggerServerEvent('pw_vehicleshop:server:updateDisplayed', displayedVeh, chosenVehicle)
    TriggerServerEvent('pw_vehicleshop:server:newModel', curShowroom, spot, price, props)
    
end)

RegisterNetEvent('pw_vehicleshop:client:updateShowroomTable')
AddEventHandler('pw_vehicleshop:client:updateShowroomTable', function(dealer, table, src)
    Dealers[dealer].showroom = table
    if src ~= nil and GetPlayerServerId(PlayerId()) == src then
        TriggerEvent('pw_vehicleshop:manageShowroom')
    end
end)

RegisterNetEvent('pw_vehicleshop:client:sendSpot')
AddEventHandler('pw_vehicleshop:client:sendSpot', function(data)
    exports.pw_notify:PersistentAlert('end', 'modifyShowroom')
    local vehProps = PW.Game.GetVehicleProperties(displayedVeh)
    TriggerServerEvent('pw_vehicleshop:server:registerSpot', data.spot, vehProps, data.price, curShowroom)
    TriggerEvent('pw_vehicleshop:showroomCameraOff')    
end)

RegisterNetEvent('pw_vehicleshop:client:openCategoryShowroom')
AddEventHandler('pw_vehicleshop:client:openCategoryShowroom', function(cat)
    exports.pw_notify:PersistentAlert('start', 'modifyShowroom', 'inform', 'Modifying showroom spot #'..cat.spot)
    local slider = {}
    
    for k,v in pairs(cat.v.vehicles) do
        table.insert(slider, { ['label'] = v.name.."<br>($"..v.price..") ", ['data'] = { ['model'] = v.model, ['price'] = v.price, ['name'] = v.name, ['spot'] = cat.spot, ['trigger'] = "pw_vehicleshop:client:loadVehicleShowroom", ['triggerType'] = "client"} })
    end
    
    table.sort(slider, function(a,b) return a.data.price < b.data.price end)

    TriggerEvent('pw_interact:generateSlider', slider, 'pw_vehicleshop:client:sendSpot', 'client', cat.v.label.." vehicles", "", {vehicle = true}, { { ['trigger'] = "pw_vehicleshop:showroomCameraOff", ['method'] = "client"} } )
    TriggerEvent('pw_vehicleshop:showroomCamera')
end)

RegisterNetEvent('pw_vehicleshop:showroomCamera')
AddEventHandler('pw_vehicleshop:showroomCamera', function()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", vector3(Dealers[curShowroom].coords.camera.x, Dealers[curShowroom].coords.camera.y, Dealers[curShowroom].coords.camera.z), 0.00,0.00,0.00, 70.0, false, 0)
    PointCamAtCoord(cam, Dealers[curShowroom].coords.display.x, Dealers[curShowroom].coords.display.y, Dealers[curShowroom].coords.display.z)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
end)

RegisterNetEvent('pw_vehicleshop:showroomCameraOff')
AddEventHandler('pw_vehicleshop:showroomCameraOff', function()
    exports.pw_notify:PersistentAlert('end', 'modifyShowroom')
    if cam ~= 0 then
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 500, true, true)
        cam = 0
    end
end)

RegisterNetEvent('pw_vehicleshop:client:addShowroomVeh')
AddEventHandler('pw_vehicleshop:client:addShowroomVeh', function(res)
    local menu = {}
    PW.TriggerServerCallback('pw_vehicleshop:server:requestVehicles', function(vehs)
        if vehs then
            for k,v in pairs(vehs) do
                if (Dealers[curShowroom].type == 'Cars' and v.label ~= 'Motorcycles' and v.label ~= 'Custom Import') or (Dealers[curShowroom].type == 'Bikes' and v.label == 'Motorcycles') or (Dealers[curShowroom].type == 'Imports' and v.label == 'Custom Imports') then
                    table.insert(menu, { ['label'] = v.label, ['action'] = 'pw_vehicleshop:client:openCategoryShowroom', ['value'] = {v = v, spot = res}, ['triggertype'] = 'client', ['color'] = 'primary' })
                end
            end
        end
        
        table.sort(menu, function(a,b) return a.label < b.label end)

        TriggerEvent('pw_interact:generateMenu', menu, "Select a category")
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:updateColorShowroom')
AddEventHandler('pw_vehicleshop:client:updateColorShowroom', function(spot, props, dealer, showroom)
    PW.Game.SetVehicleProperties(spawned[spot]["obj"], props)
    Dealers[dealer].showroom = showroom
end)

RegisterNetEvent('pw_vehicleshop:client:switchColorShowroom')
AddEventHandler('pw_vehicleshop:client:switchColorShowroom', function(data)
    PW.Game.SetVehicleProperties(spawned[data.spot]["obj"], { ['dirtLevel'] = 0.0, ['color1'] = data.index, ['color2'] = data.index, ['pearlescentColor'] = 0 })
    local vehProps = PW.Game.GetVehicleProperties(spawned[data.spot]["obj"])
    TriggerServerEvent('pw_vehicleshop:server:updateSpotProps', curShowroom, data.spot, vehProps)
    TriggerEvent('pw_vehicleshop:client:colorPickerShowroom', data.spot)
end)

RegisterNetEvent('pw_vehicleshop:client:colorPickerShowroom')
AddEventHandler('pw_vehicleshop:client:colorPickerShowroom', function(spot)
    local menu = {}
    for k,v in pairs(Config.AvailableColors) do
        table.insert(menu, {['label'] = v.label, ['action'] = 'pw_vehicleshop:client:switchColorShowroom', ['value'] = { index = v.index, spot = spot }, ['triggertype'] = 'client', ['color'] = v.buttonColor })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Color")
end)

RegisterNetEvent('pw_vehicleshop:client:deleteShowroom')
AddEventHandler('pw_vehicleshop:client:deleteShowroom', function(spot, dealer, showroom)
    if curShowroom == dealer then
        FreezeEntityPosition(spawned[spot]["obj"], false)
        SetEntityAsMissionEntity(spawned[spot]["obj"], true, true)
        DeleteEntity(spawned[spot]["obj"])
        spawned[spot] = { ['obj'] = 0, ['price'] = 0 }
    end
    Dealers[dealer].showroom = showroom
end)

RegisterNetEvent('pw_vehicleshop:client:updatePrice')
AddEventHandler('pw_vehicleshop:client:updatePrice', function(newPrice)
    if chosenVehicle and displayedVeh then
        chosenVehicle.price = newPrice
        TriggerEvent('pw_vehicleshop:client:sellVehMenu')
    end
end)

RegisterNetEvent('pw_vehicleshop:client:setDefaultPriceShowroom')
AddEventHandler('pw_vehicleshop:client:setDefaultPriceShowroom', function(veh)
    veh.price = veh.defaultPrice
    TriggerEvent('pw_vehicleshop:client:sellVehMenu')
end)

RegisterNetEvent('pw_vehicleshop:client:modifyPriceFormShowroom')
AddEventHandler('pw_vehicleshop:client:modifyPriceFormShowroom', function(veh)
    local form = {  
        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Base Price: <b><span class='text-success'>$"..veh.defaultPrice.."</span></b><br>Margin: <span class='text-primary'>"..Dealers[curShowroom].bossSettings.Margin.."%</span>"},
        { ['type'] = "number", ['label'] = "Set Price (Min: <b><span class='text-success'>$"..math.floor(veh.defaultPrice * ((100 - Dealers[curShowroom].bossSettings.Margin) / 100)).."</span></b> | Max: <b><span class='text-success'>$"..math.floor(veh.defaultPrice * ((100 + Dealers[curShowroom].bossSettings.Margin) / 100)).."</span></b>)", ['name'] = "price" },
        { ['type'] = "hidden", ['name'] = "veh", ['data'] = { veh = veh } },
        { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:processPriceShowroom', 'server', form, "Set Price")
end)

RegisterNetEvent('pw_vehicleshop:client:manageShowroomSpot')
AddEventHandler('pw_vehicleshop:client:manageShowroomSpot', function(veh)
    inManageShowroom = false
    inManageShowroomSpot = true
    local menu = {}
    local carSub = {}
    if veh.type == 'empty' then
        table.insert(carSub, { ['label'] = '<b><span class="text-success">Assign Vehicle</span></b>', ['action'] = 'pw_vehicleshop:client:addShowroomVeh', ['value'] = veh.spot, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Vehicle: <b>Not assigned</b>', ['color'] = 'success', ['subMenu'] = carSub })
    else
        local vehProps = veh.vehicle
        if vehProps.plate then
            table.insert(carSub, { ['label'] = 'Change vehicle', ['action'] = 'pw_vehicleshop:client:addShowroomVeh', ['value'] = veh.spot, ['triggertype'] = 'client' }) -- ['value'] = {vehicle = veh}
            table.insert(carSub, { ['label'] = '<b><span class="text-danger">Remove</span></b>', ['action'] = 'pw_vehicleshop:server:removeShowroom', ['value'] = {spot = veh.spot, dealer = curShowroom}, ['triggertype'] = 'server' })
        end
        
        if vehProps.plate then
            local colorSub = {}
            table.insert(colorSub, { ['label'] = 'Change color', ['action'] = 'pw_vehicleshop:client:colorPickerShowroom', ['value'] = veh.spot, ['triggertype'] = 'client' })

            local priceSub = {}
            table.insert(priceSub, { ['label'] = "Modify", ['action'] = 'pw_vehicleshop:client:modifyPriceFormShowroom', ['value'] = veh, ['triggertype'] = 'client', ['color'] = 'primary' })
            table.insert(priceSub, { ['label'] = "Base Price", ['action'] = 'pw_vehicleshop:server:setDefaultPriceShowroom', ['value'] = { spot = veh.spot, default = veh.defaultPrice, dealer = curShowroom }, ['triggertype'] = 'server', ['color'] = 'primary' })

            table.insert(menu, { ['label'] = PW.Vehicles.GetName(vehProps.model), ['action'] = '', ['triggertype'] = 'client', ['color'] = "primary", ['subMenu'] = carSub })
            table.insert(menu, { ['label'] = "Color: "..GetColorByIndex(vehProps.color1), ['action'] = '', ['triggertype'] = 'client', ['color'] = "primary", ['subMenu'] = colorSub })
            table.insert(menu, { ['label'] = "Price: $"..veh.price, ['action'] = '', ['triggertype'] = 'client', ['color'] = "primary", ['subMenu'] = priceSub })
        end
    end

    TriggerEvent('pw_interact:generateMenu', menu, 'Manage Spot #'..veh.spot)
end)

function GetSpotFromTbl(tbl, spot)
    if type(tbl) == 'table' then
        for k,v in pairs(tbl) do
            if v.spot == spot then
                return k
            end
        end
    end
    return false
end

RegisterNetEvent('pw_vehicleshop:manageShowroom')
AddEventHandler('pw_vehicleshop:manageShowroom', function()
    inManageShowroom = true
    inManageShowroomSpot = false
    exports.pw_notify:PersistentAlert('end', 'modifyShowroom')
    local menu = {}
    for i = 1, #Dealers[curShowroom].showroomspots do
        local tblSpot = GetSpotFromTbl(Dealers[curShowroom].showroom, i)
        if tblSpot then
            local vehProps = Dealers[curShowroom].showroom[tblSpot].vehicle               
            table.insert(menu, { ['label'] = "#"..Dealers[curShowroom].showroom[tblSpot].spot.." "..PW.Vehicles.GetName(vehProps.model), ['action'] = 'pw_vehicleshop:client:manageShowroomSpot', ['value'] = Dealers[curShowroom].showroom[tblSpot], ['triggertype'] = 'client', ['color'] = 'primary' })
        else
            table.insert(menu, { ['label'] = "Empty", ['action'] = 'pw_vehicleshop:client:manageShowroomSpot', ['value'] = { spot = i, type = 'empty' }, ['triggertype'] = 'client', ['color'] = 'success' })
        end
    end
    TriggerEvent('pw_interact:generateMenu', menu, "Choose a spot | Showroom")
end)

RegisterNetEvent('pw_vehicleshop:client:updateDisplayed')
AddEventHandler('pw_vehicleshop:client:updateDisplayed', function(obj, chosen)
    displayedVeh = obj
    chosenVehicle = chosen
end)

RegisterNetEvent('pw_vehicleshop:client:loadVehicle')
AddEventHandler('pw_vehicleshop:client:loadVehicle', function(data)
    if displayedVeh then 
        FreezeEntityPosition(displayedVeh, false)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        DeleteEntity(displayedVeh)
    else
        local cV = GetClosestVehicle(Dealers[curShowroom].coords.display.x, Dealers[curShowroom].coords.display.y, Dealers[curShowroom].coords.display.z, 0.3, 0, 71)
        if cV ~= nil and cV ~= 0 then
            FreezeEntityPosition(cV, false)
            SetEntityAsMissionEntity(cV, true, true)
            DeleteEntity(cV)
        end
    end
    PW.Game.SpawnOwnedVehicle(data.model, Dealers[curShowroom].coords.display, Dealers[curShowroom].coords.display.h, function(veh)
        displayedVeh = veh
        local displayedNet = VehToNet(displayedVeh)
        SetNetworkIdExistsOnAllMachines(displayedNet, true)
        SetNetworkIdCanMigrate(displayedNet, true)
        if not HasModelLoaded(GetHashKey(data.model)) then
            Citizen.Wait(10)
        else
            TriggerEvent('pw_interact:enableSlider')
        end
        FreezeEntityPosition(displayedVeh, true)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        chosenVehicle = data
        chosenVehicle.color = Config.AvailableColors[math.random(1, #Config.AvailableColors)].index
        TriggerServerEvent('pw_vehicleshop:server:updateDisplayed', displayedVeh, chosenVehicle)
        PW.Game.SetVehicleProperties(displayedVeh, { ['dirtLevel'] = 0.0, ['color1'] = chosenVehicle.color, ['color2'] = chosenVehicle.color, ['pearlescentColor'] = 0 })
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:openCategory')
AddEventHandler('pw_vehicleshop:client:openCategory', function(cat)
    inVehDisplay = true
    inCatDisplay = false
    local slider = {}
    
    for k,v in pairs(cat.vehicles) do
        table.insert(slider, { ['label'] = v.name.."<br>($"..v.price..") ", ['data'] = { ['model'] = v.model, ['defaultPrice'] = v.price, ['price'] = v.price, ['name'] = v.name, ['trigger'] = "pw_vehicleshop:client:loadVehicle", ['triggerType'] = "client"} })
    end
    
    table.sort(slider, function(a,b) return a.data.defaultPrice < b.data.defaultPrice end)
    -- Maybe add a cancel event on the end var below to remove the vehicle if not saved?
    TriggerEvent('pw_interact:generateSlider', slider, 'pw_vehicleshop:client:openVehicleDisplay', 'client', cat.label.." vehicles", "", {vehicle = true}, { { ['trigger'] = "pw_vehicleshop:showroomCameraOff", ['method'] = "client"} })
    TriggerEvent('pw_vehicleshop:showroomCamera')
end)

RegisterNetEvent('pw_vehicleshop:client:enteringVehicle')
AddEventHandler('pw_vehicleshop:client:enteringVehicle', function(veh, net)
    local vehicleProps = PW.Game.GetVehicleProperties(veh)
    TriggerServerEvent('pw_vehicleshop:server:decideToRegisterVehicle', vehicleProps, veh, net)
end)

RegisterNetEvent('pw_vehicleshop:client:removeDisplay')
AddEventHandler('pw_vehicleshop:client:removeDisplay', function()
    if displayedVeh then 
        FreezeEntityPosition(displayedVeh, false)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        DeleteVehicle(displayedVeh)
    end
    displayedVeh = 0
    chosenVehicle = false
    TriggerServerEvent('pw_vehicleshop:server:updateDisplayed', displayedVeh, chosenVehicle)
    Wait(10)
    TriggerEvent('pw_vehicleshop:dealerMenu')
end)

RegisterNetEvent('pw_vehicleshop:client:openVehicleDisplay')
AddEventHandler('pw_vehicleshop:client:openVehicleDisplay', function()
    if inVehDisplay then
        TriggerEvent('pw_vehicleshop:showroomCameraOff')
        inVehDisplay = false
    end

    inCatDisplay = true

    local menu = {}
    local tempMenu = {}
    table.insert(menu, { ['label'] = "None", ['action'] = 'pw_vehicleshop:client:removeDisplay', ['triggertype'] = 'client', ['color'] = 'danger' })
    PW.TriggerServerCallback('pw_vehicleshop:server:requestVehicles', function(vehs)
        if vehs then
            for k,v in pairs(vehs) do
                if (Dealers[curShowroom].type == 'Cars' and v.label ~= 'Motorcycles' and v.label ~= 'Custom Import') or (Dealers[curShowroom].type == 'Bikes' and v.label == 'Motorcycles') or (Dealers[curShowroom].type == 'Imports' and v.label == 'Custom Import') then
                    table.insert(tempMenu, { ['label'] = v.label, ['action'] = 'pw_vehicleshop:client:openCategory', ['value'] = v, ['triggertype'] = 'client', ['color'] = 'primary' })
                end
            end
            table.sort(tempMenu, function(a,b) return a.label < b.label end)
            for k,v in pairs(tempMenu) do
                table.insert(menu, v)
            end

            TriggerEvent('pw_interact:generateMenu', menu, "Select a category")
        end
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:switchColor')
AddEventHandler('pw_vehicleshop:client:switchColor', function(index)
    if chosenVehicle and displayedVeh then
        PW.Game.SetVehicleProperties(displayedVeh, { ['dirtLevel'] = 0.0, ['color1'] = index, ['color2'] = index, ['pearlescentColor'] = 0 })
        chosenVehicle.color = index
        TriggerEvent('pw_vehicleshop:client:colorPicker')
    end
end)

RegisterNetEvent('pw_vehicleshop:client:colorPicker')
AddEventHandler('pw_vehicleshop:client:colorPicker', function()
    if chosenVehicle and displayedVeh then
        local menu = {}
        for k,v in pairs(Config.AvailableColors) do
            table.insert(menu, {['label'] = v.label, ['action'] = 'pw_vehicleshop:client:switchColor', ['value'] = v.index, ['triggertype'] = 'client', ['color'] = v.buttonColor })
        end

        TriggerEvent('pw_interact:generateMenu', menu, "Color")
    end
end)

RegisterNetEvent('pw_vehicleshop:client:updatePriceShowroom')
AddEventHandler('pw_vehicleshop:client:updatePriceShowroom', function(newPrice, spot, dealer, veh, dId, showroom)
    spawned[spot].price = newPrice
    Dealers[dId].showroom = showroom
    if dealer == GetPlayerServerId(PlayerId()) then
        TriggerEvent('pw_vehicleshop:client:manageShowroomSpot', veh)
    end
end)

RegisterNetEvent('pw_vehicleshop:client:updatePrice')
AddEventHandler('pw_vehicleshop:client:updatePrice', function(newPrice)
    if chosenVehicle and displayedVeh then
        chosenVehicle.price = newPrice
        TriggerEvent('pw_vehicleshop:client:sellVehMenu')
    end
end)

RegisterNetEvent('pw_vehicleshop:client:setDefaultPrice')
AddEventHandler('pw_vehicleshop:client:setDefaultPrice', function()
    if chosenVehicle and displayedVeh then
        chosenVehicle.price = chosenVehicle.defaultPrice
        TriggerEvent('pw_vehicleshop:client:sellVehMenu')
    end
end)

RegisterNetEvent('pw_vehicleshop:client:modifyPriceForm')
AddEventHandler('pw_vehicleshop:client:modifyPriceForm', function()
    if chosenVehicle and displayedVeh then
        local form = {  
            { ['type'] = "writting", ['align'] = 'left', ['value'] = "Base Price: <b><span class='text-success'>$"..chosenVehicle.defaultPrice.."</span></b><br>Margin: <span class='text-primary'>"..Dealers[curShowroom].bossSettings.Margin.."%</span>"},
            { ['type'] = "number", ['label'] = "Set Price (Min: <b><span class='text-success'>$"..math.floor(chosenVehicle.defaultPrice * ((100 - Dealers[curShowroom].bossSettings.Margin) / 100)).."</span></b> | Max: <b><span class='text-success'>$"..math.floor(chosenVehicle.defaultPrice * ((100 + Dealers[curShowroom].bossSettings.Margin) / 100)).."</span></b>)", ['name'] = "price" },
            { ['type'] = "hidden", ['name'] = "veh", ['data'] = { veh = chosenVehicle } },
            { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom }
        }

        TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:processPrice', 'server', form, "Set Price | "..chosenVehicle.name)
    end
end)

function GetColorByIndex(index)
    for k,v in pairs(Config.AvailableColors) do
        if index[1] == v.index[1] and index[2] == v.index[2] and index[3] == v.index[3] then
            return v.label
        end
    end
    return 'N/A'
end

RegisterNetEvent('pw_vehicleshop:client:deleteDisplayed')
AddEventHandler('pw_vehicleshop:client:deleteDisplayed', function()
    if  displayedVeh and displayedVeh ~= 0 then
        FreezeEntityPosition(displayedVeh, false)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        DeleteVehicle(displayedVeh)
    end
end)

RegisterNetEvent('pw_vehicleshop:client:vehicleSold')
AddEventHandler('pw_vehicleshop:client:vehicleSold', function(model, vehProps, availableSpawn)
    if displayedVeh ~= 0 and displayedVeh ~= nil and type(displayedVeh) == 'number' then
        FreezeEntityPosition(displayedVeh, false)
        SetEntityAsMissionEntity(displayedVeh, true, true)
        DeleteVehicle(displayedVeh)
    end
    PW.Game.SpawnOwnedVehicle(model, vector3(Dealers[curShowroom].sellspots[availableSpawn].x, Dealers[curShowroom].sellspots[availableSpawn].y, Dealers[curShowroom].sellspots[availableSpawn].z), Dealers[curShowroom].sellspots[availableSpawn].h, function(veh)
        local newVeh = veh
        PW.Game.SetVehicleProperties(newVeh, vehProps)
        SetEntityHeading(displayedVeh, Dealers[curShowroom].sellspots[availableSpawn].h)
        exports.pw_notify:SendAlert('inform', 'Your new vehicle is ready')
        displayedVeh = 0
        chosenVehicle = nil
        TriggerServerEvent('pw_vehicleshop:server:updateDisplayed', displayedVeh, chosenVehicle)
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:getNewVehProps')
AddEventHandler('pw_vehicleshop:client:getNewVehProps', function(method, model)
    local vehProps = PW.Game.GetVehicleProperties(displayedVeh)
    TriggerServerEvent('pw_vehicleshop:server:registerThis', vehProps, method, vehProps.color1, model)
end)

RegisterNetEvent('pw_vehicleshop:client:goToFinalFinance')
AddEventHandler('pw_vehicleshop:client:goToFinalFinance', function(data)
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Final Agreement</b>"},
        { ['type'] = "checkbox", ['label'] = 'By accepting to this terms, you commit to an immediate down payment of <b><span class="text-primary">$'..data.veh.data.downPayment..'</span></b> as well as the payment of a weekly cost of <b><span class="text-success">$'..data.veh.data.cost..'</span></b> deducted directly from your bank account for a period of <b><span class="text-info">'..data.veh.data.weeks..' weeks</span></b>.', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "veh", ['data'] = { weeks = data.veh.data.weeks, total = data.veh.data.total, cost = data.veh.data.cost, downPayment = data.veh.data.downPayment, props = data.veh.data.data.props, veh = data.veh.data.data.veh, dealer = data.veh.data.dealer, spawn = data.veh.data.spawn, use = data.veh.data.use } },
        { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:financeAgreed', 'server', form, "Financing Contract for "..data.veh.data.data.veh.name)
end)

RegisterNetEvent('pw_vehicleshop:client:sendFinance')
AddEventHandler('pw_vehicleshop:client:sendFinance', function(weeks, total, cost, downPayment, data, dealer, spawn, use)
    local form = {
        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Vehicle Price: <span class='text-primary'>$"..data.veh.price.."</span><br>Surcharge: <span class='text-primary'>"..Dealers[curShowroom].bossSettings.FinancingMargin.."%</span><br>Total amount: <b><span class='text-success'>$"..(math.floor(data.veh.price*((100+Dealers[curShowroom].bossSettings.FinancingMargin) / 100))).."</span></b>"},
        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Period chosen: <b>"..weeks.." weeks</b>"},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Weekly Cost<br> <span class='text-success' style='font size:28px;'>$"..cost.."</span></b></span>"},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Down Payment<br> <span class='text-primary' style='font size:28px;'>$"..downPayment.."</span></b></span>"},
        { ['type'] = "hidden", ['name'] = "veh", ['data'] = { weeks = weeks, total = total, cost = cost, downPayment = downPayment, data = data, dealer = dealer, spawn = spawn, use = use } }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:client:goToFinalFinance', 'client', form, "Financing Contract for "..data.veh.name)
end)

RegisterNetEvent('pw_vehicleshop:client:financeTerms')
AddEventHandler('pw_vehicleshop:client:financeTerms', function(data)
    local weeksOption = {}
    for i = 1, #Dealers[curShowroom].bossSettings.FinanceWeeks do
        table.insert(weeksOption, {['value'] = Dealers[curShowroom].bossSettings.FinanceWeeks[i], ['label'] = Dealers[curShowroom].bossSettings.FinanceWeeks[i].." Weeks"})
    end

    local form = {
        { ['type'] = "writting", ['align'] = 'left', ['value'] = "Vehicle Price: <span class='text-primary'>$"..data.data.veh.price.."</span><br>Surcharge: <span class='text-primary'>"..Dealers[curShowroom].bossSettings.FinancingMargin.."%</span><br>Total amount: <b><span class='text-success'>$"..(math.floor(data.data.veh.price*((100+Dealers[curShowroom].bossSettings.FinancingMargin) / 100))).."</span></b><br>Down Payment: <b>$"..(math.floor((data.data.veh.price*((100+Dealers[curShowroom].bossSettings.FinancingMargin) / 100)*(Dealers[curShowroom].bossSettings.Downpayment / 100)))).."</b> (<i>"..Dealers[curShowroom].bossSettings.Downpayment.."%</i>)"},
        { ['type'] = "dropdown", ['label'] = "Choose a Payment Period", ['name'] = "weeks", ['options'] = weeksOption},
        { ['type'] = "hidden", ['name'] = "veh", ['data'] = { data = data.data, spawn = data.spawn, use = data.use } },
        { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:calculateFinance', 'server', form, "Financing Contract for "..data.data.veh.name)
end)

RegisterNetEvent('pw_vehicleshop:client:pullVehicleUse')
AddEventHandler('pw_vehicleshop:client:pullVehicleUse', function(data, spawn)
    local menu = {}
    table.insert(menu, { ['label'] = 'Personal', ['action'] = 'pw_vehicleshop:client:manageUse', ['value'] = {data = data, spawn = spawn, use = 'Personal'}, ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = 'Business', ['action'] = 'pw_vehicleshop:client:manageUse', ['value'] = {data = data, spawn = spawn, use = playerData.job.name}, ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Select the Use type for this vehicle")
end)

RegisterNetEvent('pw_vehicleshop:client:manageUse')
AddEventHandler('pw_vehicleshop:client:manageUse', function(data)
    TriggerEvent('pw_vehicleshop:client:pullPaymentType', data.data, data.spawn, data.use)
end)

RegisterNetEvent('pw_vehicleshop:client:pullPaymentType')
AddEventHandler('pw_vehicleshop:client:pullPaymentType', function(data, spawn, use)
    local menu = {}
    table.insert(menu, { ['label'] = "Cash", ['action'] = 'pw_vehicleshop:server:paymentType', ['value'] = {dealer = curShowroom, data = data, type = 'cash', spawn = spawn, use = (use ~= nil and use or 'Personal')}, ['triggertype'] = 'server', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Debit Card", ['action'] = 'pw_vehicleshop:server:paymentType', ['value'] = {dealer = curShowroom, data = data, type = 'debit', spawn = spawn, use = (use ~= nil and use or 'Personal')}, ['triggertype'] = 'server', ['color'] = 'primary' })
    if data.veh.price >= 20000 then
        table.insert(menu, { ['label'] = "Financing", ['action'] = 'pw_vehicleshop:client:financeTerms', ['value'] = {data = data, spawn = spawn, use = (use ~= nil and use or 'Personal')}, ['triggertype'] = 'client', ['color'] = 'primary' })
    else
        table.insert(menu, { ['label'] = "No Financing Available", ['action'] = '', ['triggertype'] = 'trigger', ['color'] = 'danger disabled' })    
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Payment Type")
end)

RegisterNetEvent('pw_vehicleshop:client:checkBeforePull')
AddEventHandler('pw_vehicleshop:client:checkBeforePull', function(data)
    local availableSpawn = 0
    for k,v in pairs(Dealers[curShowroom].sellspots) do
        local cV = GetClosestVehicle(v.x, v.y, v.z, 2.0, 0, 71)
        if cV == 0 or cV == nil then
            availableSpawn = k
            break
        end
    end
    if availableSpawn > 0 then
        TriggerServerEvent('pw_vehicleshop:server:pullPaymentType', data, availableSpawn)
    else
        exports.pw_notify:SendAlert('error', 'The driveway outside is full of vehicles. Make some room first')
    end
end)

RegisterNetEvent('pw_vehicleshop:client:sellVehMenu')
AddEventHandler('pw_vehicleshop:client:sellVehMenu', function()
    inSellVehMenu = true
    if chosenVehicle and displayedVeh then
        local menu = {}
        table.insert(menu, { ['label'] = "Set Color", ['action'] = 'pw_vehicleshop:client:colorPicker', ['triggertype'] = 'client', ['color'] = 'primary' })

        local priceSub = {}
        table.insert(priceSub, { ['label'] = "Modify", ['action'] = 'pw_vehicleshop:client:modifyPriceForm', ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(priceSub, { ['label'] = "Base Price", ['action'] = 'pw_vehicleshop:client:setDefaultPrice', ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = "Price: $"..chosenVehicle.price, ['action'] = 'pw_vehicleshop:client:colorPicker', ['triggertype'] = 'client', ['color'] = 'primary', ['subMenu'] = priceSub })

        local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
        local nearbyPlayersSub = {}
        table.insert(nearbyPlayersSub, { ['label'] = "Self", ['action'] = "pw_vehicleshop:client:checkBeforePull", ['value'] = {props = PW.Game.GetVehicleProperties(displayedVeh), veh = chosenVehicle, target = GetPlayerServerId(PlayerId()), dealer = GetPlayerServerId(PlayerId())}, ['triggertype'] = "client", ['color'] = "warning" })
        if closestDistance <= 3.0 and closestPlayer ~= -1 then
            local pName 
            PW.TriggerServerCallback('pw_vehicleshop:server:getNearbyName', function(name)
                pName = name
            end, GetPlayerServerId(closestPlayer))

            while pName == nil do
                Wait(10)
            end

            if pName then
                table.insert(nearbyPlayersSub, { ['label'] = pName, ['action'] = "pw_vehicleshop:client:checkBeforePull", ['value'] = {props = PW.Game.GetVehicleProperties(displayedVeh), veh = chosenVehicle, target = GetPlayerServerId(closestPlayer), dealer = GetPlayerServerId(PlayerId())}, ['triggertype'] = "client", ['color'] = "warning" })
            end
        end

        table.insert(menu, { ['label'] = "Sell", ['action'] = '', ['triggertype'] = 'client', ['color'] = 'warning', ['subMenu'] = nearbyPlayersSub })

        TriggerEvent('pw_interact:generateMenu', menu, "Sell <b>"..chosenVehicle.name.."</b>")
    end
end)

RegisterNetEvent('pw_vehicleshop:dealerMenu')
AddEventHandler('pw_vehicleshop:dealerMenu', function()
    if displayedVeh and displayedVeh ~= 0 then
        NetworkRequestControlOfEntity(displayedVeh)
    end
    inCatDisplay = false
    inSellVehMenu = false
    inManageShowroom = false
    local menu = {}
    table.insert(menu, { ['label'] = "Display Vehicles", ['action'] = 'pw_vehicleshop:client:openVehicleDisplay', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = (chosenVehicle and "Sell <b><span class='text-warning'>"..chosenVehicle.name.."</span></b>" or "Select a vehicle first"), ['action'] = (chosenVehicle and 'pw_vehicleshop:client:sellVehMenu' or ''), ['triggertype'] = 'client', ['color'] = (chosenVehicle and 'primary' or 'danger')})
    table.insert(menu, { ['label'] = "Manage Showroom", ['action'] = 'pw_vehicleshop:manageShowroom', ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Dealership Menu", {['trigger'] = 'pw_vehicleshop:stopCameraMove', ['method'] = "client"})
end)

RegisterNetEvent('pw_vehicleshop:client:setMargins')
AddEventHandler('pw_vehicleshop:client:setMargins', function(type)
    local form = {}

    if type == 'DealerMargin' then
        form = {
            { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Dealer Margin<br>Current: <span class='text-primary' style='font size:28px;'>"..Dealers[curShowroom].bossSettings[type].."%</span></b></span>"},
            { ['type'] = "range", ['label'] = "Set Dealer Profit Margin (Min: 5% | Max: 20%)", ['default'] = Dealers[curShowroom].bossSettings[type], ['min'] = 5, ['max'] = 20, ['name'] = 'range', ['suffix'] = "%"}
        }
    elseif type == 'FinanceWeeks' then
        local currentWeeks 
        for i = 1, #Dealers[curShowroom].bossSettings['FinanceWeeks'] do
            if i == 1 then
                currentWeeks = Dealers[curShowroom].bossSettings['FinanceWeeks'][i]
            else
                currentWeeks = currentWeeks .. ', ' .. Dealers[curShowroom].bossSettings['FinanceWeeks'][i]           
            end
        end

        form = {
            { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Financing Weeks<br>Current: <span class='text-primary' style='font size:28px;'>"..currentWeeks.."</span></b></span>"},
        }
        
        table.insert(form, { ['type'] = "range", ['label'] = "Choose a Payment Period (Option #1)", ['default'] = Dealers[curShowroom].bossSettings['FinanceWeeks'][1], ['min'] = 1, ['max'] = 10, ['name'] = 'week1', ['suffix'] = "weeks"})
        table.insert(form, { ['type'] = "range", ['label'] = "Choose a Payment Period (Option #2)", ['default'] = Dealers[curShowroom].bossSettings['FinanceWeeks'][2], ['min'] = 11, ['max'] = 20, ['name'] = 'week2', ['suffix'] = "weeks"})
        table.insert(form, { ['type'] = "range", ['label'] = "Choose a Payment Period (Option #3)", ['default'] = Dealers[curShowroom].bossSettings['FinanceWeeks'][3], ['min'] = 21, ['max'] = 30, ['name'] = 'week3', ['suffix'] = "weeks"})
    elseif type == 'Downpayment' then
        form = {
            { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Financing Down Payment<br>Current: <span class='text-primary' style='font size:28px;'>"..Dealers[curShowroom].bossSettings[type].."%</span></b></span>"},
            { ['type'] = "range", ['label'] = "Set Down Payment Margin (Min: 15% | Max: 40%)", ['default'] = Dealers[curShowroom].bossSettings[type], ['min'] = 15, ['max'] = 40, ['name'] = 'range', ['suffix'] = "%"}
        }
    end
    table.insert(form, { ['type'] = "hidden", ['name'] = "margin", ['value'] = type })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom })
    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:sendMargin', 'server', form, "Set Margins")
end)

RegisterNetEvent('pw_vehicleshop:client:openMargins')
AddEventHandler('pw_vehicleshop:client:openMargins', function()
    local menu = {}

    table.insert(menu, { ['label'] = "Dealer Cut: "..Dealers[curShowroom].bossSettings['DealerMargin'].."%", ['action'] = 'pw_vehicleshop:client:setMargins', ['value'] = 'DealerMargin', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Financing Weeks", ['action'] = 'pw_vehicleshop:client:setMargins', ['value'] = 'FinanceWeeks', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Financing Down Payment: "..Dealers[curShowroom].bossSettings['Downpayment'].."%", ['action'] = 'pw_vehicleshop:client:setMargins', ['value'] = 'Downpayment', ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Margins")
end)

RegisterNetEvent('pw_vehicleshop:client:sendContractForm')
AddEventHandler('pw_vehicleshop:client:sendContractForm', function(formCopy, salary, grade, boss)
    local form = formCopy

    table.insert(form, { ['type'] = "checkbox", ['label'] = '<i>'..playerData.name.."</i>", ['name'] = "contractReview", ['value'] = 'yes'})
    table.insert(form, { ['type'] = "hidden", ['name'] = "salary", ['value'] = salary })
    table.insert(form, { ['type'] = "hidden", ['name'] = "grade", ['value'] = grade })
    table.insert(form, { ['type'] = "hidden", ['name'] = "bossSrc", ['value'] = boss })

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:contractSigned', 'server', form, 'Employment Contract', {}, false, '500px')
end)

RegisterNetEvent('pw_vehicleshop:client:bossHireReview')
AddEventHandler('pw_vehicleshop:client:bossHireReview', function(result)
    local formCopy = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employment Contract<br><span class='text-primary' style='font size:28px;'>"..result.data.data.name.."</span> | <span class='text-primary' style='font size:28px;'>" .. result.grades.value .. "</b></span>"},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'BE IT KNOWN, that this COMMISSION AGREEMENT, entered into by <b><span class="text-info">Premium Deluxe Motorsport</span></b>, (hereafter referred to as the "Company"), located in <b><span class="text-info">Los Santos</span></b>, and <b><span class="text-info">'.. result.data.data.name .. '</span></b> (hereafter referred to as the "Employee").'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>1. EMPLOYMENT</b><br>The Company does hereby employ in the position of dealer and the Employee does hereby agree to serve in such capacity. This contract may be terminated at any time at the owners discretion.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>2. COMPENSATION & BENEFITS</b><br>In accordance with the following terms and conditions of this Agreement, and throughout Employees period of employment, compensation for his/her services will be as follows:<br>Employee will receive daily base income of <b><span class="text-success">$'..tonumber(result.salary.value)..'</span></b>, by way of direct deposit.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>3. COMMISSION PAYMENTS</b><br>In addition to the Employee\'s daily base salary the Company shall provide <b><span class="text-info">' .. Dealers[curShowroom].bossSettings.DealerMargin .. '%</span></b> commission on the dollar for new sales revenue generated by the Employee.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Upon termination or death of Employee and/or this agreement, payments at such time will cease.'},
    }

    local form = {}
    for k, v in pairs(formCopy) do
        table.insert(form, { ['type'] = v.type, ['align'] = v.align, ['value'] = v.value })
    end
    table.insert(form, { ['type'] = "hidden", ['name'] = "formCopy", ['data'] = formCopy })
    table.insert(form, { ['type'] = "hidden", ['name'] = "target", ['value'] = result.data.data.target })
    table.insert(form, { ['type'] = "hidden", ['name'] = "salary", ['value'] = tonumber(result.salary.value) })
    table.insert(form, { ['type'] = "hidden", ['name'] = "grade", ['value'] = tonumber(result.grades.value) })
    table.insert(form, { ['type'] = "hidden", ['name'] = "bossSrc", ['value'] = GetPlayerServerId(PlayerId()) })

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:sendContractForm', 'server', form, 'Contract Review', {}, false, '500px')
end)

RegisterNetEvent('pw_vehicleshop:client:bossHire')
AddEventHandler('pw_vehicleshop:client:bossHire', function(result)
    local grades = {}
    local form = {}
    PW.TriggerServerCallback('pw_vehicleshop:server:getGrades', function(res)
        local jGrades = json.decode(res[1].grades)
        for i = 1, #jGrades do
            table.insert(grades, {['value'] = i, ['label'] = jGrades[i]})
        end

        table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employment Contract Details<br><span class='text-primary' style='font size:28px;'>"..result.name.."</span></b></span>" })
        table.insert(form, { ['type'] = "dropdown", ['label'] = 'Grade', ['name'] = "grades", ['options'] = grades })
        table.insert(form, { ['type'] = "number", ['label'] = "Set Salary", ['name'] = "salary" })
        table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })
        
        TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:client:bossHireReview', 'client', form, 'Set Contract Details')
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:changeGrade')
AddEventHandler('pw_vehicleshop:client:changeGrade', function(result)
    local grades = {}
    local form = {}
    PW.Base.GetAvaliableGrades('cardealer', function(gradescb)
        for i = 1, #gradescb do
            table.insert(grades, {['value'] = gradescb[i].grade, ['label'] = (gradescb[i].grade == result.job.grade and gradescb[i].label .. "  (Current)" or gradescb[i].label)})
        end

        table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employee<br><span class='text-primary' style='font size:28px;'>"..result.name.."</span></b></span>" })
        table.insert(form, { ['type'] = "dropdown", ['label'] = 'Grade', ['name'] = "grades", ['options'] = grades })
        table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = {result = result, grades = gradescb} })
        table.insert(form, { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom })
        
        TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:setNewGrade', 'server', form, 'Set Employee Grade')
    end)
end)

RegisterNetEvent('pw_vehicleshop:client:changeSalary')
AddEventHandler('pw_vehicleshop:client:changeSalary', function(result)
    local form = {}
    PW.TriggerServerCallback('pw_vehicleshop:server:getSalary', function(salary)
        table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employee<br><span class='text-primary' style='font size:28px;'>"..result.name.."</span></b></span>" })
        table.insert(form, { ['type'] = "range", ['label'] = "Set Employee Salary", ['default'] = salary, ['min'] = 5, ['max'] = 2000, ['name'] = 'range', ['suffix'] = "$"})
        table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })
        table.insert(form, { ['type'] = 'hidden', ['name'] = 'dealer', ['value'] = curShowroom })
            
        TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:setNewSalary', 'server', form, 'Set Employee Salary')
    end, result.cid)
end)

RegisterNetEvent('pw_vehicleshop:client:fireStaff')
AddEventHandler('pw_vehicleshop:client:fireStaff', function(result)
    local form = {}
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "<b><span class='text-primary'>"..result.name.."</span></b>," })
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "This letter is to inform you that your employment with <b>Premium Deluxe Motorsport</b> will end as of <b>today</b>."})
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "This decision is not reversible." })
    table.insert(form, { ['type'] = "checkbox", ['label'] = 'Premium Deluxe Motorsport Owner,<br><i>'..playerData.name..'</i>', ['name'] = "fire", ['value'] = 'yes' })
    table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:fireStaff', 'server', form, 'Contract Termination | '..result.name)
end)

RegisterNetEvent('pw_vehicleshop:client:manageStaff')
AddEventHandler('pw_vehicleshop:client:manageStaff', function()
    local menu = {}
    PW.TriggerServerCallback('pw_vehicleshop:server:getStaff', function(list)
        for k, v in pairs(list) do
            local staffSub = {}
            table.insert(staffSub, {['label'] = "Promote/Demote", ['action'] = "pw_vehicleshop:client:changeGrade", ['triggertype'] = 'client', ['value'] = v })
            table.insert(staffSub, {['label'] = "Change Salary", ['action'] = "pw_vehicleshop:client:changeSalary", ['triggertype'] = 'client', ['value'] = v })
            table.insert(staffSub, {['label'] = "<b><span class='text-danger'>Fire</span></b>", ['action'] = "pw_vehicleshop:client:fireStaff", ['triggertype'] = 'client', ['value'] = v })

            table.insert(menu, {['label'] = v.name, ['color'] = 'primary', ['subMenu'] = staffSub })
        end

        TriggerEvent('pw_interact:generateMenu', menu, "Staff List")
    end, Dealers[curShowroom].id)    
end)

RegisterNetEvent('pw_vehicleshop:client:openStaff')
AddEventHandler('pw_vehicleshop:client:openStaff', function()
    local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
        local nearbyPlayersSub = {}
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            local pName
            PW.TriggerServerCallback('pw_vehicleshop:server:getNearbyName', function(name)
                pName = name
            end, GetPlayerServerId(closestPlayer))

            while pName == nil do
                Wait(10)
            end

            if pName then
                table.insert(nearbyPlayersSub, { ['label'] = pName, ['action'] = "pw_vehicleshop:client:bossHire", ['value'] = {target = GetPlayerServerId(closestPlayer), name = pName}, ['triggertype'] = "client", ['color'] = "warning" })
            else
                table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = "", ['triggertype'] = "client", ['color'] = "warning" })
            end
        else
            table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = "", ['triggertype'] = "client", ['color'] = "warning" })
        end
    
    local menu = {}

    table.insert(menu, { ['label'] = "Hire", ['action'] = '', ['triggertype'] = 'client', ['color'] = 'success', ['subMenu'] = nearbyPlayersSub })
    table.insert(menu, { ['label'] = "Manage Current Staff", ['action'] = 'pw_vehicleshop:client:manageStaff', ['triggertype'] = 'client', ['color'] = 'warning' })

    TriggerEvent('pw_interact:generateMenu', menu, "Staff Management")
end)

RegisterNetEvent('pw_vehicleshop:client:openTestDriveTimer')
AddEventHandler('pw_vehicleshop:client:openTestDriveTimer', function()
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Test Drive Timer<br>Current: <span class='text-primary' style='font size:28px;'>"..Dealers[curShowroom].bossSettings.TestDriveTimer.." minutes</span></b></span>" },
        { ['type'] = "range", ['label'] = "Test Drive Limit", ['default'] = Dealers[curShowroom].bossSettings.TestDriveTimer, ['min'] = 1, ['max'] = 10, ['name'] = 'range', ['suffix'] = 'minutes' },
        { ['type'] = "hidden", ['name'] = "dealer", ['value'] = curShowroom },
        { ['type'] = "hidden", ['name'] = "id", ['value'] = Dealers[curShowroom].id }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_vehicleshop:server:updateTestDriveTimer', 'server', form, "Test Drive Settings")
end)

RegisterNetEvent('pw_vehicleshop:bossMenu')
AddEventHandler('pw_vehicleshop:bossMenu', function()
    local menu = {}

    table.insert(menu, { ['label'] = "Staff Management", ['action'] = 'pw_vehicleshop:client:openStaff', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Margins", ['action'] = 'pw_vehicleshop:client:openMargins', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Test Drive Timer: "..Dealers[curShowroom].bossSettings.TestDriveTimer.." minutes", ['action'] = 'pw_vehicleshop:client:openTestDriveTimer', ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Boss Menu")
end)

RegisterNetEvent('pw_vehicleshop:client:updateConfig')
AddEventHandler('pw_vehicleshop:client:updateConfig', function(id, settings)
    Dealers[id].bossSettings = settings
end)

RegisterNetEvent('pw_vehicles:client:testDrive')
AddEventHandler('pw_vehicles:client:testDrive', function(reqData)
    local color = math.random(1,#Config.AvailableColors)
    reqData.color = { ['label'] = Config.AvailableColors[color].label, ['index'] = Config.AvailableColors[color].index }
    local maths = reqData.price * 0.01
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'This Agreement is entered into between <b>Premium Deluxe Motorsport</b> (“Dealer”) and <b>'..playerData.name..'</b> (“Prospect”) (collectively the “Parties”)'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>1. VEHICLE</b><br>Model: <b><span class="text-primary">'.. reqData.name ..'</span></b><br>Color: <b><span class="text-primary">'.. reqData.color.label ..'</span></b>'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>2. TEST DRIVE TERMS</b><br>The term of this Agreement runs from time set by dealer. Prospect will not allow any other person to operate the Vehicle.<br>Test Drive time limit: <b><span class="text-primary">'..Dealers[curShowroom].bossSettings.TestDriveTimer..' minutes</span></b><br>Primary vehicle operator: <b><span class="text-primary">'..playerData.name..'</span></b><br>Vehicle return location: <b><span class="text-primary">Dealer\'s Servicing Park</span></b>'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>3. DEPOSIT FEES</b><br>Prospect will pay <b><span class="text-success">$'.. (maths > 500 and math.ceil(maths) or 500) ..'</span></b> to dealer as deposit fees for insurance against Vehicle.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = '<b>4. RESPONSABILITY</b><br> I must pay for any loss or damage to the vehicle that occurs while the vehicle is in my possession.<br>Additionally, I agree to defend, indemnify and hold harmless the Dealer from and against any and all losses, liabilities, damages, injuries, claims, demands, costs and expenses arising out of my use, possession or control of the vehicle and any breach of my responsibilities as set forth in this Agreement.'},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'This Test Drive Agreement constitutes the entire agreement between the Parties with respect to this arrangement.'},
        { ['type'] = "checkbox", ['label'] = '<i>(Prospect signature) <u>&nbsp;&nbsp;'..playerData.name..'&nbsp;&nbsp;</u></i>', ['name'] = "contractReview", ['value'] = 'yes'},
        { ['type'] = "hidden", ['name'] = "reqData", ['data'] = reqData }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_vehicles:client:testDriveAgreed', 'client', form, "Test Drive Agreement", {}, false, '500px')
end)

RegisterNetEvent('pw_vehicles:client:testDriveAgreed')
AddEventHandler('pw_vehicles:client:testDriveAgreed', function(data)
    if data.contractReview.value then
        local reqData = data.reqData.data
        
        if testDriveTimer == 0 then
            if CheckTestDriveCollision() then
                PW.TriggerServerCallback('pw_vehicleshop:server:checkMoneyForTestDrive', function(canDrive, deposit)
                    if canDrive then
                        StartTestDrive(reqData, deposit)
                    else
                        exports.pw_notify:SendAlert('error', 'You need to deposit $'..deposit..' as insurance to test drive this vehicle', 6000)
                    end
                end, reqData)
            else
                exports.pw_notify:SendAlert('error', 'The driveway out of the dealership has a vehicle nearby. Wait for a clear path and try again.', 6000)    
            end
        else
            exports.pw_notify:SendAlert('error', 'You can\'t test drive more than one vehicle at a time. Return the vehicle first.', 6000)
        end
    else
        exports.pw_notify:SendAlert('error', 'You must sign the Test Drive Agreement and tick the checkbox in order to get your test vehicle', 6000)
    end
end)

function CheckTestDriveCollision()
    local cV = GetClosestVehicle(Dealers[curShowroom].testdrive.spawner.x, Dealers[curShowroom].testdrive.spawner.y, Dealers[curShowroom].testdrive.spawner.z, 8.0, 0, 71)
    if cV == 0 or cV == nil then
        return true
    else
        return false    
    end
end

function StartTestDrive(veh, deposit)
    if veh ~= nil then
        PW.Game.SpawnOwnedVehicle(veh.model, vector3(Dealers[curShowroom].testdrive.spawner.x, Dealers[curShowroom].testdrive.spawner.y, Dealers[curShowroom].testdrive.spawner.z), Dealers[curShowroom].testdrive.spawner.h, function(vehicle)
            testDriveVehicle = vehicle
            testDriveDealer = curShowroom
            PW.Game.SetVehicleProperties(testDriveVehicle, { ['color1'] = veh.color.index, ['color2'] = veh.color.index, ['dirtLevel'] = 0.0 })
            local vehProps = PW.Game.GetVehicleProperties(testDriveVehicle)
            --PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
            --    TriggerServerEvent('pw_keys:issueKey', 'Vehicle', vin, false, false, false)
            --end, vehProps, testDriveVehicle)
            SetEntityAsMissionEntity(testDriveVehicle, true, true)
            testDriveTimer = Dealers[curShowroom].bossSettings.TestDriveTimer * 60
            exports['pw_notify']:SendAlert('inform', 'You have '..Dealers[curShowroom].bossSettings.TestDriveTimer..' minutes to test drive the '..veh.name..'.', 6000)
            exports['pw_notify']:SendAlert('inform', 'Drop the car in the servicing park in the back of the dealership.', 12000)
            exports['pw_notify']:SendAlert('inform', 'Make sure you don\'t damage the car or your deposit will be seized accordingly.', 12000)
            local vehDetails = PW.Game.GetVehicleProperties(testDriveVehicle)
            --TriggerServerEvent('pw_keys:issueKey', 'Vehicle', PW.Vehicles.GetVinNumber(vehDetails.plate), false, true, false)
            StartTimer(veh.name, deposit)
        end)
    end
end

function StartTimer(veh, deposit)
    Citizen.CreateThread(function()
        local notifyLoaded = false
        repeat
            if playerLoaded and playerData and testDriveTimer > 0 then
                local mins, secs = secondsToClock(testDriveTimer)
                local props = PW.Game.GetVehicleProperties(testDriveVehicle)
                local damage = math.ceil(math.abs(2000 - props.bodyHealth - props.engineHealth) / 2000 * 100)
                if waitingKey ~= 'testdrive' then
                    TriggerEvent('pw_drawtext:showNotification', {title = "<span style='font-size:18px;'>Test Driving: <span class='text-primary'>"..veh.."</span> (<span class='text-danger'>" .. damage .. "%</span>)</span>", message = "<span style='font-size:22px;'>Time left: <span style='color:#187200;'>".. mins .. ":" .. secs .."</span></span><br><span style='font-size:20px;'>Insurance Deposit: <span style='color:#187200;'>$"..deposit.."</span></span>", icon = "fad fa-clock"})
                end
                testDriveTimer = testDriveTimer - 1
                Citizen.Wait(950)
            end
            Citizen.Wait(50)
        until testDriveTimer == 0
        if waitingKey ~= 'testdrive' then
            TriggerEvent('pw_drawtext:hideNotification')
        end
        if forced then
            forced = false
        else
            StopTestDrive()
        end
    end)
end

function secondsToClock(seconds)
	local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0

	if seconds <= 0 then
		return 0, 0
	else
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))

		return mins, secs
	end
end

function StopTestDrive()
    local vehCoords = GetEntityCoords(testDriveVehicle)
    local dist = #(vector3(Dealers[testDriveDealer].testdrive.deliever.x, Dealers[testDriveDealer].testdrive.deliever.y, Dealers[testDriveDealer].testdrive.deliever.z) - vehCoords)
    if dist < 8.0 then
        local vehProps = PW.Game.GetVehicleProperties(testDriveVehicle)
        TriggerServerEvent('pw_vehicleshop:server:returnTestDriveDeposit', vehProps)
        --TriggerServerEvent('pw_keys:revokeVehicleKeys', vehProps.plate, playerData.cid)
    elseif not forced then
        exports.pw_notify:SendAlert('error', 'You didn\'t deliever the car to the right spot in time, you lost the right to get your insurance back.')
    end
    DeleteEntity(testDriveVehicle)
    testDriveDealer = false
    testDriveTimer = 0
    testDriveVehicle = nil
end

function WaitingKeys(type)
    Citizen.CreateThread(function()
        while waitingKey == type do
            Citizen.Wait(1)
            if IsControlJustPressed(0,38) then
                if type == 'standard' then
                    --TriggerEvent('pw_vehicleshop:openMenu')
                else
                    if playerData.job.duty then
                        if type == 'bossmenu' then
                            TriggerEvent('pw_vehicleshop:bossMenu')
                        elseif type == 'dealer' then
                            TriggerEvent('pw_vehicleshop:dealerMenu')
                        elseif type == 'duty' then
                            local currentDuty = not playerData.job.duty
                            TriggerServerEvent('pw_vehicleshop:toggleSignOn', currentDuty)
                        elseif type == 'testdrive' then
                            if testDriveVehicle and testDriveVehicle ~= 0 then
                                forced = true
                                testDriveTimer = 0
                                StopTestDrive()
                                TriggerEvent('pw_drawtext:hideNotification')
                                waitingKey = false
                                showing = false
                            end
                        end
                    end
                end
                showing = false
                waitingKey = false
            end
        end
    end)
end

function displayMarkerText(type)
    local message, title, icon
    if playerData ~= nil and playerData.job.name == 'cardealer' then
        if type == 'duty' then
            title = "Work Duty"
            message = "<b>[ <span class='text-danger'>E</span> ] Sign <span class ='text-" .. (playerData.job.duty and "danger'>OFF" or "success'>ON") .. "</span> Duty</b>"
            icon = "fad fa-user-tie"
        elseif type ~= 'bossmenu' and type == 'dealer' and playerData.job.duty then
            title = "Dealer Menu"
            message = "<b>[ <span class='text-danger'>E</span> ] <span class='text-primary'>DEALER</span> MENU</b>"
            icon = "fad fa-badge-dollar"
        elseif type == 'bossmenu' and playerData.job.grade == "boss" and playerData.job.duty then
            title = "Dealer Menu"
            message = "<b>[ <span class='text-danger'>E</span> ] <span class='text-primary'>BOSS</span> MENU</b>"
            icon = "fad fa-user-tie"
        end
    end
    if type == 'testdrive' and testDriveTimer > 0 then
        title = "Vehicle Drop Off Zone"
        message = "<b>[ <span class='text-danger'>E</span> ] to <span class='text-primary'>DELIEVER</span> the car<br>or just leave it here</b>"
        icon = "fad fa-garage-open"
    end

    if title and message and icon then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = "<span style='font-size:18px'>" .. message .. "</span>", icon = icon })
    end
end

function displayDraw(car, var)
    local model = GetEntityModel(car.obj)
        
    if model ~= 0 then
        TriggerEvent('pw_drawtext:showNotification', {title = "<span class='text-primary' style='font-size:18px;'>"..PW.Vehicles.GetName(model).."</span>", message = "<span style='color:#187200;font-size:25px;'>$"..car.price.."</span>", icon = "fad fa-car" })
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if playerLoaded and playerCoords and curShowroom then
            for i = 1, #Dealers[curShowroom].showroomspots do
                if spawned[i] ~= nil and spawned[i].obj ~= 0 then
                    local pos = vector3(Dealers[curShowroom].showroomspots[i].x, Dealers[curShowroom].showroomspots[i].y, Dealers[curShowroom].showroomspots[i].z)
                    local dist = #(pos - playerCoords)
                    if dist < 3.0 then
                        if not showingDraw then
                            showingDraw = i
                            displayDraw(spawned[i], showingDraw)
                        end
                    elseif showingDraw == i then
                        showingDraw = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if playerLoaded and playerCoords then
            for k,v in pairs(Dealers) do
                for j,b in pairs(v.coords) do
                    local dist
                    if j == 'standard' or (playerData.job.name == 'cardealer' and playerData.job.workplace == v.id) then
                        dist = #(playerCoords - vector3(b.x, b.y, b.z))
                        if j == 'standard' and dist <= 50.0 and not curShowroom then
                            curShowroom = k
                            TriggerEvent('pw_vehicleshop:client:spawnShowroomVehs', k)
                        elseif j == 'standard' and dist > 50.0 and (curShowroom == k or not curShowroom) then
                            RemoveShowroom()
                            curShowroom = false
                        end
                        if dist < 2.0 then
                            if not showing then
                                showing = j .. k
                                displayMarkerText(j)
                            end

                            if dist < 1.0 then
                                if not waitingKey then
                                    waitingKey = j
                                    WaitingKeys(j)
                                end
                            elseif waitingKey == j then
                                waitingKey = false
                            end
                        elseif showing == j .. k then
                            showing = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                    else
                        dist = #(playerCoords - vector3(v.testdrive.deliever.x, v.testdrive.deliever.y, v.testdrive.deliever.z))
                        if dist < 3.0 then
                            if testDriveTimer > 0 and waitingKey ~= 'testdrive' then
                                showing = 'testdrive'
                                displayMarkerText(showing)
                                waitingKey = 'testdrive'
                                WaitingKeys('testdrive')
                            end
                        elseif waitingKey == 'testdrive' or showing == 'testdrive' then
                            waitingKey = false
                            showing = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playerLoaded then
            RemoveVehiclesFromGeneratorsInArea(-33.76 - 50.0, -1103.28 - 50.0, 26.42 - 50.0, -33.76 + 50.0, -1103.28 + 50.0, 26.42 + 50.0)
        end
    end
end)

exports('vehicleMakes', function(model)
    for k, v in pairs(Config.Makes) do
        for meh, teh in pairs(v) do
            if string.lower(teh) == string.lower(model) then
                return k
            end
        end
    end
    return nil    
end)