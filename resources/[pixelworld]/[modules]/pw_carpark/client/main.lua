PW = nil
playerLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
local nearPark, attached, retrieving, spawnedProps, Parks, blips = false, false, false, {}, {}, {}

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
            PW.TriggerServerCallback('pw_carpark:server:getParkStates', function(parks)
                Parks = parks
                GLOBAL_PED = PlayerPedId()
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                playerLoaded = true
                CreateBlips()
            end)
        else
            playerData = data
        end
    else
        DeleteProps()
        DeleteBlips()
        if attached then
            DeleteVehicle(attached)
            attached = false
        end
        playerLoaded = false
        playerData = nil
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw:playerTeleported')
AddEventHandler('pw:playerTeleported', function()
    nearPark, nearScreen = false, false
end)

function CreateBlips()
    while not playerLoaded or not playerData == nil do Wait(10); end
    for i = 1, #Config.Parks do
        DrawBlip(i)
    end
end

function DeleteBlips()
    for k,v in pairs(blips) do
        RemoveBlip(v)
    end

    blips = {}
end

function DrawBlip(id)
    if blips[id] ~= nil and DoesBlipExist(id) then RemoveBlip(blips[id]); end
    local blip = AddBlipForCoord(Config.Parks[id].screen.x, Config.Parks[id].screen.y, Config.Parks[id].screen.z)
    SetBlipSprite(blip, Config.Blips.blipSprite)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, Config.Blips.color)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Auto-Park")
    EndTextCommandSetBlipName(blip)

    blips[id] = blip
end

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

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        if spawnedProps and (spawnedProps['fence'] or spawnedProps['base']) then
            DeleteProps()
        end

        if attached then DeleteVehicle(attached); end
    end
end)

RegisterNetEvent('pw_carpark:client:setParkState')
AddEventHandler('pw_carpark:client:setParkState', function(park, var, state)
    Parks[park][var] = state
end)

function GetRetrieveHeading(park)
    if (Parks[park].h.base - 180.0) < 0 then
        return (Parks[park].h.base + 180.0)
    else
        return (Parks[park].h.base - 180.0)
    end
end

function Park(type)
    if nearPark then
        local yOff
        local newCoords
        if type == 'park' then
            yOff = 0.0
            while yOff < 8.0 do
                yOff = yOff + 0.15
                newCoords = GetOffsetFromEntityInWorldCoords(spawnedProps['base'], 0.0, 0.15, 0.0)
                SetEntityCoordsNoOffset(spawnedProps['base'], newCoords)
                Wait(10)
            end
            if not retrieving and attached then
                DeleteVehicle(attached)
                attached = false
            end
            Wait(5000)
            Park('back')
        else
            if retrieving then
                local baseCoords = GetEntityCoords(spawnedProps['base'])
                local useH = GetRetrieveHeading(nearPark)

                PW.Game.SpawnLocalVehicle(retrieving.props.model, baseCoords, useH, function(vehicle)
                    TriggerEvent('pw_interact:closeMenu')
                    PW.Game.SetVehicleProperties(vehicle, retrieving.props)
                    TriggerEvent('pw_garage:client:setDamage', vehicle, retrieving.dmg)
                    attached = vehicle
                    AttachEntityToEntity(vehicle, spawnedProps['base'], -1, 0.0, 0.0, 0.5, 0.0, 0.0, useH, false, true, true, false, 2, false)
                end)

                while not attached do Wait(10); end
            end
            Wait(1000)
            yOff = 0.0
            while yOff > -8.0 do
                yOff = yOff - 0.15
                newCoords = GetOffsetFromEntityInWorldCoords(spawnedProps['base'], 0.0, -0.15, 0.0)
                SetEntityCoordsNoOffset(spawnedProps['base'], newCoords)
                Wait(10)
            end
            SetEntityCoordsNoOffset(spawnedProps['base'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z - 5.099)
            Wait(1000)
            Elevator('up')
        end
    end
end

function Elevator(type)
    if nearPark then
        if type == 'down' then
            local zOff = 0.0
            while zOff > -5.0 do
                zOff = zOff - 0.025
                SetEntityCoordsNoOffset(spawnedProps['base'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z + zOff)
                Wait(10)
            end
            zOff = -5.099
            SetEntityCoordsNoOffset(spawnedProps['base'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z + zOff)
            Wait(1000)
            Park('park')
        else
            local zOff = -5.0
            while zOff < 0.0 do
                zOff = zOff + 0.025
                SetEntityCoordsNoOffset(spawnedProps['base'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z + zOff)
                Wait(10)
            end
            SetEntityCoordsNoOffset(spawnedProps['base'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z)
            Wait(1000)
            Fences('down')
        end
    end
end

function Fences(type)
    if nearPark then
        if type == 'up' then
            local zOff = 0.0
            while zOff < 2.63281 do
                zOff = zOff + 0.025
                SetEntityCoordsNoOffset(spawnedProps['fence'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z + zOff)
                Wait(10)
            end
            zOff = 2.63281
            SetEntityCoordsNoOffset(spawnedProps['fence'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z + zOff)
            Wait(1000)
            Elevator('down')
        else
            local zOff = 2.63281
            while zOff > 0.0 do
                zOff = zOff - 0.025
                SetEntityCoordsNoOffset(spawnedProps['fence'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z + zOff)
                Wait(10)
            end
            SetEntityCoordsNoOffset(spawnedProps['fence'], Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z)
            if Parks[nearPark].parking == GetPlayerServerId(PlayerId()) then
                TriggerServerEvent('pw_carpark:server:setParkState', nearPark, 'parking', false)
            end
            if retrieving.owner == GetPlayerServerId(PlayerId()) then
                TriggerServerEvent('pw_carpark:server:retrievalDone', nearPark, retrieving, GetEntityCoords(spawnedProps['base']))
            end
        end
    end
end

RegisterNetEvent('pw_carpark:client:retrievalDone')
AddEventHandler('pw_carpark:client:retrievalDone', function(park, data, baseCoords)
    if nearPark == park and attached then
        DeleteVehicle(attached)
        attached = false
        SetEntityCoordsNoOffset(spawnedProps['base'], baseCoords)
        SetEntityHeading(spawnedProps['base'], Config.Parks[park].h.base)

        if data.owner == GetPlayerServerId(PlayerId()) then
            PW.Game.SpawnOwnedVehicle(data.props.model, GetEntityCoords(spawnedProps['base']), (Config.Parks[nearPark].h.base - 180.0), function(vehicle)
                TriggerEvent('pw_interact:closeMenu')
                PW.Game.SetVehicleProperties(vehicle, data.props)
                TriggerEvent('pw_garage:client:setDamage', vehicle, data.dmg)
                SetVehicleEngineHealth(vehicle, data.props.engineHealth + 0.0)
                SetVehicleBodyHealth(vehicle, data.props.bodyHealth + 0.0)
                TriggerEvent('pw_garage:client:spawnAuto', vehicle, data.ins, data.props.plate)
            end)
        end
        retrieving = false
    end
end)

RegisterNetEvent('pw_carpark:client:parkVeh')
AddEventHandler('pw_carpark:client:parkVeh', function(park, props, dmg)
    if nearPark == park then
        PW.Game.SpawnLocalVehicle(props.model, {x = 0.0, y = 0.0, z = 0.0}, 0.0, function(vehicle)
            PW.Game.SetVehicleProperties(vehicle, props)
            AttachEntityToEntity(vehicle, spawnedProps['base'], -1, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            TriggerEvent('pw_garage:client:setDamage', vehicle, dmg)
            attached = vehicle
            Fences('up')
        end)
    end
end)

function AttachVehicle()
    if nearPark and not attached and not Parks[nearPark].parking then
        local rayHandle = StartShapeTestBox(Config.Parks[nearPark].pos.x, Config.Parks[nearPark].pos.y, Config.Parks[nearPark].pos.z-1.0, 5.0, 10.0, 4.0, 0.0, 0.0, 0.0, true, 2, 0)
        local _, hit, _, _, veh = GetShapeTestResult(rayHandle)
        if hit and hit ~= 0 then
            if DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                if GetVehicleNumberOfPassengers(veh) == 0 and IsVehicleSeatFree(veh, -1) then
                    local vehicleProps = PW.Game.GetVehicleProperties(veh)
                    PW.TriggerServerCallback('pw_garage:server:checkOwner', function(owner)
                        if owner then
                            local dmg = exports.pw_garage:getDamage(veh)
                            Wait(300)
                            while not NetworkHasControlOfEntity(veh) do
                                NetworkRequestControlOfEntity(veh)
                                Wait(10)
                            end
                            DeleteVehicle(veh)
                            TriggerServerEvent('pw_carpark:server:parkVeh', nearPark, vehicleProps, dmg)
                        else
                            exports.pw_notify:SendAlert('error', 'This vehicle doesn\'t belong to you', 5000)
                        end
                    end, PW.Vehicles.GetVehId(vehicleProps.plate))
                end
            end
        end
    end
end

function SpawnProps(k, type)
    if type == 'all' then
        DeleteProps()
    end
    local spawned = 0

    if type == 'all' or type == 'fence' then
        PW.Game.SpawnLocalObjectNoOffset(Config.Props.fence, { x = Config.Parks[k].pos.x, y = Config.Parks[k].pos.y, z = Config.Parks[k].pos.z }, function(fenceObject)
            SetEntityHeading(fenceObject, Config.Parks[k].h.fence)
            spawnedProps['fence'] = fenceObject
            FreezeEntityPosition(spawnedProps['fence'], true)
            SetEntityCollision(spawnedProps['fence'], true, true)
            spawned = spawned + 1
        end)
    end

    if type == 'all' or type == 'base' then
        PW.Game.SpawnLocalObjectNoOffset(Config.Props.base, { x = Config.Parks[k].pos.x, y = Config.Parks[k].pos.y, z = Config.Parks[k].pos.z }, function(baseObject)
            SetEntityHeading(baseObject, Config.Parks[k].h.base)
            spawnedProps['base'] = baseObject
            FreezeEntityPosition(spawnedProps['base'], true)
            SetEntityCollision(spawnedProps['base'], true, true)
            spawned = spawned + 1
        end)
    end

    if type == 'all' then
        repeat Wait(10) until spawned == 2
    end
    --UpdateStates(k)
end

function DeleteProps()
    if spawnedProps['fence'] ~= nil and DoesEntityExist(spawnedProps['fence']) then
        DeleteObject(spawnedProps['fence'])
        while DoesEntityExist(spawnedProps['fence']) do Wait(10); end
        spawnedProps['fence'] = nil
    else
    
    end

    if spawnedProps['base'] ~= nil and DoesEntityExist(spawnedProps['base']) then
        DeleteObject(spawnedProps['base'])
        while DoesEntityExist(spawnedProps['base']) do Wait(10); end
        spawnedProps['base'] = nil
    end
end

RegisterNetEvent('pw_carpark:client:retrieveVehicle')
AddEventHandler('pw_carpark:client:retrieveVehicle', function(park, props, owner, ins, dmg)
    if nearPark == park  then
        if not attached then
            retrieving = { ['props'] = props, ['ins'] = ins, ['dmg'] = dmg, ['owner'] = owner }
            Fences('up')
        end
    end
end)

RegisterNetEvent('pw_carpark:client:getParked')
AddEventHandler('pw_carpark:client:getParked', function(park)
    TriggerEvent('pw_garage:client:openGarage', 'Auto', park, Config.Parks[park])
end)

RegisterNetEvent('pw_carpark:client:checkPark')
AddEventHandler('pw_carpark:client:checkPark', function()
    if not IsPedInAnyVehicle(GLOBAL_PED) then AttachVehicle(); end
end)

function OpenScreen(k)
    local menu = {}
    
    table.insert(menu, { ['label'] = 'Park Vehicle', ['action'] = 'pw_carpark:client:checkPark', ['triggertype'] = 'client', ['color'] = 'primary' .. (Parks[k].parking and ' disabled' or '') })
    table.insert(menu, { ['label'] = 'Retrieve Vehicle', ['action'] = 'pw_carpark:client:getParked', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' .. (Parks[k].parking and ' disabled' or '') })
    
    TriggerEvent('pw_interact:generateMenu', menu, 'Automated Car Parking | ' .. Config.Parks[k].name)
end

function HandleScreen(var)
    local title, msg, icon

    title = Config.Parks[var].name .. " | Auto-Parking"
    msg = "Keep your car safe with our<br>Automated Parking System"
    icon = "fad fa-garage-car"

    TriggerEvent('pw_drawtext:showNotification', { title = title, message = msg, icon = icon })
    TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Access"}})

    Citizen.CreateThread(function()
        while (playerLoaded and nearScreen == var) do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                OpenScreen(var)
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if playerLoaded then
            for k,v in pairs(Config.Parks) do
                local dist = #(GLOBAL_COORDS - vector3(v.pos.x, v.pos.y, v.pos.z))
                if dist < Config.DrawObjects then
                    if not nearPark or (nearPark and nearPark ~= k) then
                        if nearPark and nearPark ~= k then
                            nearScreen = false
                            TriggerEvent('pw_items:showUsableKeys', false)
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                        nearPark = k
                        SpawnProps(nearPark, 'all')
                    end

                    local screenDist = #(GLOBAL_COORDS - vector3(v.screen.x, v.screen.y, v.screen.z))
                    if screenDist < 1.2 and not Parks[k].parking then
                        if not nearScreen then
                            nearScreen = k
                            HandleScreen(nearScreen)
                        elseif nearScreen == k and Parks[k].parking then
                            nearScreen = false
                            TriggerEvent('pw_items:showUsableKeys', false)
                            TriggerEvent('pw_drawtext:hideNotification')
                        end
                    elseif nearScreen == k then
                        nearScreen = false
                        TriggerEvent('pw_items:showUsableKeys', false)
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                elseif nearPark == k then
                    nearPark = false
                    DeleteProps()
                end
            end
        end
    end
end)