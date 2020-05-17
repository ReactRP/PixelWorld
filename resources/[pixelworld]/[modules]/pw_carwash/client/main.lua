PW = nil
characterLoaded, playerData = false, nil
local showingtxt, drawingMarker, drawingAwaitMarker, awaitingwash, blips = false, false, false, false, {}

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
            createBlips()
        else
            playerData = data
        end
    else
        removeBlips()
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded and playerData then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and playerData and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        if characterLoaded then 
            for k,v in pairs(Config.Locations) do   
                local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z)) 
                if dist < 15.0 then
                    if not drawingMarker then
                        drawingMarker = k
                        DrawShit(drawingMarker)
                    end

                    if dist < 2.0 then
                        if not showingtxt then
                            showingtxt = k
                            DrawText(showingtxt)
                        end
                    elseif showingtxt == k then
                        showingtxt = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                    end  
                elseif drawingMarker == k then
                    drawingMarker = false   
                end          
            end        
        end    
    end
end) 


function DrawShit(var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, Config.Locations[var].coords.x, Config.Locations[var].coords.y, Config.Locations[var].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawShitAwaiting(var)
    Citizen.CreateThread(function()
        while drawingAwaitMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, Config.Locations[var].pull_forward.x, Config.Locations[var].pull_forward.y, Config.Locations[var].pull_forward.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, true, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(var)
    if awaitingwash == var then
        TriggerEvent('pw_drawtext:showNotification', { title = "Car Wash", message = "<span style='font-size:25px'>Pull Forward to Wash Car</span>", icon = "fad fa-car-wash" })
        TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "w", ['action'] = "Pull Forward"}})
    else
        TriggerEvent('pw_drawtext:showNotification', { title = "Car Wash", message = "<span style='font-size:25px'>Get Vehicle Washed</span>", icon = "fad fa-car-wash" })
        TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = "Car Wash"}})
    end

    Citizen.CreateThread(function()
        while showingtxt == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) and awaitingwash ~= var then
                if IsPedInAnyVehicle(GLOBAL_PED) then
                    local playerHeading = GetEntityHeading(GLOBAL_PED)
                    if playerHeading >= (Config.Locations[var].coords.h - 20.0) and playerHeading <= (Config.Locations[var].coords.h + 20.0) then
                        PW.TriggerServerCallback('pw_carwash:server:checkMoney', function(cash)
                            if cash >= Config.Cost then
                                BeginCarWash(var)
                            else
                                exports['pw_notify']:SendAlert('error', 'You don\'t have enough cash to use the carwash!', 5000)
                            end
                        end)
                    else
                        exports['pw_notify']:SendAlert('error', 'The vehicle either isn\'t straight or is facing the completely wrong way.', 5000)
                    end
                else
                    exports['pw_notify']:SendAlert('error', 'You need to actually be in a vehicle to use the carwash!', 5000)
                end
            end
        end
    end)
end

function BeginCarWash(carwash)
    local cV = GetClosestVehicle(Config.Locations[carwash].pull_forward.x, Config.Locations[carwash].pull_forward.y, Config.Locations[carwash].pull_forward.z, 5.0, 0, 71)
    if cV == 0 or cV == nil then
        AwaitingCarWashing(carwash)
        exports['pw_notify']:SendAlert('inform', '<b>Slowly</b> pull forward into the car wash and then the marker for the car wash to begin.', 5000)
    else
        exports['pw_notify']:SendAlert('error', 'There is either someone using the carwash or it is blocked!', 5000)
    end
end

function AwaitingCarWashing(carwash)
    awaitingwash = carwash
    showingtxt = false
    TriggerEvent('pw_drawtext:hideNotification')
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000)
            if characterLoaded then  
                local dist = #(GLOBAL_COORDS - vector3(Config.Locations[carwash].pull_forward.x, Config.Locations[carwash].pull_forward.y, Config.Locations[carwash].pull_forward.z))  
                if dist < 20.0 then
                    if not drawingAwaitMarker then
                        drawingAwaitMarker = carwash
                        DrawShitAwaiting(drawingAwaitMarker)
                    end
                    if dist < 2.0 then
                        WashCarFull(carwash)
                        break
                    end    
                elseif drawingAwaitMarker == carwash then
                    drawingAwaitMarker = false 
                    awaitingwash = false
                    exports['pw_notify']:SendAlert('error', 'Too far from the carwash.', 5000)
                    break  
                end               
            end    
        end
    end) 
end

function WashCarFull(carwash)
    drawingAwaitMarker = false
    if IsPedInAnyVehicle(GLOBAL_PED) then
        local vehicle = GetVehiclePedIsIn(GLOBAL_PED)
        FreezeEntityPosition(vehicle, true) 
        
        local dict, waterJet, soap = 'scr_carwash', 'ent_amb_car_wash_jet', 'ent_amb_car_wash'

        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Citizen.Wait(0)
        end

        local coords = GetEntityCoords(vehicle)

        TriggerEvent('pw_sound:client:PlayOnOne', 'carwash', 0.4)

        UseParticleFxAsset(dict)
        local particle = StartParticleFxLoopedAtCoord(waterJet, coords.x, coords.y, coords.z, 1.0, 1.0, 90.0, 4.0, 0.0, 0.0, 0.0, false)
        UseParticleFxAsset(dict)
        local particle2 = StartParticleFxLoopedAtCoord(soap, coords.x, coords.y, coords.z + 1.0, 1.0, 1.0, 1.0, 3.0, 0.0, 0.0, 0.0, false)

        TriggerEvent('pw:progressbar:progress',
        {
            name = 'recieving_car_wash',
            duration = 12000,
            label = 'Recieving Car Wash',
            useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
        },
        function(status)
            if not status then
                SetVehicleDirtLevel(vehicle, 0.1)
            end
        end)  

        Citizen.Wait(12000)

        StopParticleFxLooped(particle)
        StopParticleFxLooped(particle2)

        FreezeEntityPosition(vehicle, false)

        awaitingwash = false

        TriggerServerEvent('pw_carwash:server:finishCarWash')
    else
        exports['pw_notify']:SendAlert('error', 'You are no longer in a vehicle. Make sure to pull the vehicle forward and stay inside of it.', 8000)
        awaitingwash = false
    end
end


function createBlips()
    for k, v in pairs(Config.Locations) do
        blips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blips[k], Config.Blips.blipSprite)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], Config.Blips.blipScale)
        SetBlipColour (blips[k], Config.Blips.blipColor)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(tostring(Config.Blips.blipName))
        EndTextCommandSetBlipName(blips[k])
    end
end

function removeBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
    blips = {}
end
