PW = nil
characterLoaded, playerData = false, nil
local GLOBAL_PED, GLOBAL_COORDS
local showing, signedUp, onService = false, false, false
local serviceStatus = { ['status'] = false }
local activeSignup

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
            PW.TriggerServerCallback('pw_chopshop:server:connected', function(spot)
                activeSignup = spot
                playerData = data
                GLOBAL_PED = PlayerPedId()
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                characterLoaded = true
            end)
        else
            playerData = data
        end
    else
        if onService then
            TriggerServerEvent('pw_chopshop:server:stopService')
        end
        characterLoaded = false
        playerData = nil
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

RegisterNetEvent('pw_chopshop:client:signedUp')
AddEventHandler('pw_chopshop:client:signedUp', function()
    signedUp = true
end)

RegisterNetEvent('pw_chopshop:client:serviceTimeout')
AddEventHandler('pw_chopshop:client:serviceTimeout', function()
    DeleteEntity(NetToVeh(onService.obj))
    RemoveBlip(onService.blip)
    onService = false
    signedUp = false
    HideDraw()
end)

RegisterNetEvent('pw_chopshop:client:newService')
AddEventHandler('pw_chopshop:client:newService', function()
    local npcModel = Config.NPCModels[math.random(1, #Config.NPCModels)]
    local npcLocation = Config.Locations.NPC[math.random(1, #Config.Locations.NPC)]
    
    SpawnNpc(npcModel, npcLocation)
    TriggerServerEvent('pw_chopshop:server:sendNpcLocation', npcLocation)
end)

function SpawnNpc(model, location)
    DoRequestModel(model)
    local npc = CreatePed(2, model, location.x, location.y, location.z-0.987, location.h, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    TaskSetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityInvincible(npc, true)
    SetPedFleeAttributes(npc, 0, 0)
    Wait(100)
    FreezeEntityPosition(npc, true)
    serviceStatus = { ['status'] = 'npc', ['info'] = location, ['ped'] = PedToNet(npc) }
end

function GetInfo()
    local npcPed = NetToPed(serviceStatus.ped)
    Citizen.SetTimeout(5000, function()
        FreezeEntityPosition(npcPed, false)
        TaskSmartFleePed(npcPed, GLOBAL_PED, 1000.0, -1, true, true)
        Citizen.Wait(15000)
        DeleteEntity(npcPed)
    end)
    serviceStatus = { ['status'] = false }
    local carModel = Config.VehicleModels[math.random(1, #Config.VehicleModels)].model
    local deliverySite = Config.Locations.Dropoff[math.random(1, #Config.Locations.Dropoff)]
    onService = { ['coords'] = deliverySite, ['veh'] = carModel, ['vehLabel'] = PW.Vehicles.GetName(carModel) }
    SpawnVeh()
    repeat Wait(0) until onService.vehPlate ~= nil
    TriggerServerEvent('pw_chopshop:server:sendVehInfo', onService)
end

function SpawnVeh()
    local spawnLocation = Config.Locations.Spawns[math.random(1, #Config.Locations.Spawns)]
    local vehModel = GetHashKey(onService.veh)
    DoRequestModel(vehModel)
    PW.Game.SpawnOwnedVehicle(vehModel, {x = spawnLocation.x, y = spawnLocation.y, z = spawnLocation.z}, spawnLocation.h, function(vehicle)
        onService.vehObj = VehToNet(vehicle)
        onService.vehPlate = PW.Game.GetVehicleProperties(vehicle).plate
        TriggerEvent('pw_vehicleshop:client:setDecor', vehicle, "pw_veh_chopShop", true, "bool")
    end)
    CreateBlip(spawnLocation)
end

function CreateBlip(coords)
    math.randomseed(GetGameTimer())
    local random1 = math.random(300,1000)
    local random1p = (math.random(2) > 1 and -1 or 1)
    local random2 = math.random(300,1000)
    local random2p = (math.random(2) > 1 and -1 or 1)
    local newCoords = vector3(coords.x + (random1 * random1p), coords.y + (random1p * random2p), coords.z)
    local nodeId, nodePos = GetClosestVehicleNode(newCoords.x, newCoords.y, newCoords.z, 100.0, 2.5)
    onService.blip = AddBlipForRadius(nodePos.x, nodePos.y, nodePos.z, 1000.0)
    SetBlipColour (onService.blip, 6)
    SetBlipAlpha(onService.blip, 100)
    SetBlipDisplay(onService.blip, 8)
end

function SignUp()
    TriggerEvent('pw_terminal:client:open')
end

function CheckVeh()
    local pedIn = GetVehiclePedIsIn(GLOBAL_PED)
    local vehProps = PW.Game.GetVehicleProperties(pedIn)
    local pedVeh = GetEntityModel(pedIn)
    if pedVeh == GetHashKey(onService.veh) and vehProps.plate == onService.vehPlate then
        DeleteEntity(pedIn)
        RemoveBlip(onService.blip)
        TriggerServerEvent('pw_chopshop:server:vehDelivered', onService.veh, vehProps)
        onService = false
    else
        exports.pw_notify:SendAlert('error', 'Wrong vehicle')
    end
end

function DrawText(type)
    local title, message, icon

    if type == 'signup' then
        title = "Laptop"
        message = "<b><span style='font-size:18px'>[ <span class='text-danger'>E</span> ] <span class='text-primary'>ACCESS LAPTOP</span></b>"
        icon = "fad fa-laptop"
    elseif type == 'dropoff' then
        title = "Drop Zone"
        message = "<b><span style='font-size:18px'>[ <span class='text-danger'>E</span> ] <span class='text-primary'>DELIEVER VEHICLE</span></b>"
        icon = "fad fa-car-garage"
    elseif type == 'npc' then
        title = "Contact"
        message = "<b><span style='font-size:18px'>[ <span class='text-danger'>E</span> ] <span class='text-primary'>GET INFORMATION</span></b>"
        icon = "fad fa-comment-dots"
    end

    if title and message and icon then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showing == type do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'signup' then
                    SignUp()
                elseif type == 'npc' then
                    GetInfo()
                elseif type == 'dropoff' then
                    if IsPedInAnyVehicle(GLOBAL_PED) then
                        CheckVeh()
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

function DoRequestModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end
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
        if characterLoaded and GLOBAL_PED and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and GLOBAL_PED and GLOBAL_COORDS then
            if not signedUp then
                local dist = #(GLOBAL_COORDS - activeSignup)
                if dist <= 1.2 then
                    if not showing then
                        showing = 'signup'
                        DrawText(showing)
                    end
                elseif showing == 'signup' then
                    HideDraw()
                end
            elseif signedUp and showing == 'signup' then
                HideDraw()
            elseif signedUp and type(onService) == 'boolean' and serviceStatus.status == 'npc' then
                dist = #(GLOBAL_COORDS - vector3(serviceStatus.info.x, serviceStatus.info.y, serviceStatus.info.z))
                if dist < 1.2 then
                    if not showing then
                        showing = 'npc'
                        DrawText(showing)
                    end
                elseif showing == 'npc' then
                    HideDraw()
                end
            elseif showing == 'npc' and serviceStatus.status ~= 'npc' then
                HideDraw()
            elseif signedUp and type(onService) == 'table' then
                dist = #(GLOBAL_COORDS - onService.coords)
                if dist < 3.0 then
                    if not showing then
                        showing = 'dropoff'
                        DrawText(showing)
                    end
                elseif showing == 'dropoff' then
                    HideDraw()
                end
            elseif not onService and showing == 'dropoff' then
                HideDraw()
            end
        end
    end
end)