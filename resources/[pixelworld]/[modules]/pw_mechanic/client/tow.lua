local currentSelection, towtruck, target
local towSetupMode, towing, waiting = false, false, false
local helpstate = 1
local lastFound = { ['model'] = 0, ['check'] = false }

RegisterNetEvent('pw_mechanic:client:tow')
AddEventHandler('pw_mechanic:client:tow', function()
    if not waiting then
        Tow()
    end
end)

function StartNotify(id, type, text)
    StopNotify()
    exports.pw_notify:PersistentAlert('start', id, type, text)
end

function Tow()
    ClearAllHelpMessages()
    ClearHelp(true)
    ClearDrawOrigin()
    if towing then
        local coords = GetOffsetFromEntityInWorldCoords(NetworkGetEntityFromNetworkId(towtruck), 0.0, -10.0, 0.0)
        local cV = GetClosestVehicle(coords, 6.0, 0, 71)
        if cV == nil or cV == 0 then
            towing = false
            NetworkRequestControlOfNetworkId(target)
            while not NetworkHasControlOfNetworkId(target) do NetworkRequestControlOfNetworkId(target);Wait(0); end
            DetachEntity(NetworkGetEntityFromNetworkId(target), true, true)
            SetEntityCoords(NetworkGetEntityFromNetworkId(target), coords, false, false, false, false)
            SetVehicleOnGroundProperly(NetworkGetEntityFromNetworkId(target))
            towtruck = nil
            target = nil
        else
            exports.pw_notify:SendAlert('error', 'Make sure the area behind the truck is clear to unload the vehicle safely', 6000)
        end
    else
        if target ~= nil and towtruck ~= nil then
            NetworkRequestControlOfNetworkId(target)
            while not NetworkHasControlOfNetworkId(target) do NetworkRequestControlOfNetworkId(target);Wait(0); end
            local towPos = GetOffsetFromEntityInWorldCoords(NetworkGetEntityFromNetworkId(towtruck), 0.0, -1.9, 1.05)
            SetEntityHeading(NetworkGetEntityFromNetworkId(target), GetEntityHeading(NetworkGetEntityFromNetworkId(towtruck)))
            SetEntityCoordsNoOffset(NetworkGetEntityFromNetworkId(target), towPos, false, false, false, false)
            waiting = true
            Citizen.Wait(2000)
            waiting = false
            local targetPos = GetEntityCoords(NetworkGetEntityFromNetworkId(target), true)
            local attachPos = GetOffsetFromEntityGivenWorldCoords(NetworkGetEntityFromNetworkId(towtruck), targetPos.x, targetPos.y, targetPos.z)
            AttachEntityToEntity(NetworkGetEntityFromNetworkId(target), NetworkGetEntityFromNetworkId(towtruck), -1, attachPos.x, attachPos.y, attachPos.z, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
            towSetupMode = false
            helpstate = 0
            towing = true
            StopNotify()
        elseif not towSetupMode then
            StartNotify('tow', 'inform', 'Press <b><span style="color:#ffff00">HOME</span></b> when you see a marker above your Tow Truck to select it')
            towSetupMode = true
            towtruck = nil
            target = nil
            helpstate = 1
        else
            StopNotify()
            towSetupMode = false
            towtruck = nil
            target = nil
            helpstate = 3
        end
    end
end

function StopNotify()
    exports.pw_notify:PersistentAlert('end', 'tow')
    exports.pw_notify:PersistentAlert('end', 'target')
    exports.pw_notify:PersistentAlert('end', 'end')
end

function CheckAllowedTow(veh)
    local model = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(veh)))
    for i = 1, #Config.AllowedTows do
        if model == Config.AllowedTows[i] then
            return true
        end
    end
    return false
end

function GetControlOfVeh(veh)
    local tNet = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(tNet, true)
    NetworkRegisterEntityAsNetworked(VehToNet(veh))
    NetworkRequestControlOfNetworkId(tNet)
    while not NetworkHasControlOfNetworkId(tNet) do NetworkRequestControlOfNetworkId(tNet);Wait(10); end
    return tNet
end

Citizen.CreateThread(function()
    while true do
        if towSetupMode then
            local veh = nil
            if helpstate == 3 then
                helpstate = 0
            end
            if helpstate ~= 0 then
                local tNet, vNet
                local pos = GetEntityCoords(PlayerPedId(), true)
                local targetPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, -1.0)
                local rayCast = StartShapeTestCapsule(pos.x, pos.y, pos.z, targetPos.x, targetPos.y, targetPos.z, 2, 10, PlayerPedId(), 7)
                local _,hit,_,_,veh = GetShapeTestResult(rayCast)
                if hit and DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                    if towtruck == nil then
                        if lastFound.model ~= veh then
                            lastFound.model = veh
                            if CheckAllowedTow(veh) then
                                lastFound.check = true
                                tNet = GetControlOfVeh(veh)
                                currentSelection = tNet
                            else
                                lastFound.check = false
                            end
                        elseif lastFound.model == veh and lastFound.check then
                            tNet = GetControlOfVeh(veh)
                            currentSelection = tNet
                        end
                    elseif towtruck ~= nil then
                        if GetVehicleNumberOfPassengers(veh) == 0 and IsVehicleSeatFree(veh, -1) then
                            vNet = GetControlOfVeh(veh)
                            currentSelection = vNet
                        end
                    end
                    if (IsControlJustPressed(0, 213)) then
                        if helpstate == 1 then
                            StartNotify('target', 'inform', 'Press <b><span style="color:#ffff00">HOME</span></b> when you see a marker above the target vehicle to select it')
                            towtruck = tNet
                            helpstate = 2
                        elseif helpstate == 2 and vNet ~= towtruck then
                            StartNotify('end', 'inform', 'Type <b><span style="color:#ffff00">/tow</span></b> to start towing or press <b><span style="color:#ffff00">HOME</span></b> to cancel')
                            target = vNet
                            helpstate = 3
                        end
                    end
                else
                    currentSelection = nil
                end
            elseif helpstate == 0 and IsControlJustPressed(0, 213) and towtruck ~= nil and target ~= nil then
                towtruck = nil
                target = nil
                helpstate = 1
            end
            
            DisableControlAction(0, 44)
        else
            currentSelection = nil
        end
        Citizen.Wait(1)
    end
end)

local markerType = 2
local scale = 0.3
local alpha = 255
local bounce = false
local faceCam = true
local iUnk = 0
local rotate = false
local textureDict = nil
local textureName = nil
local drawOnents = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if towSetupMode then
            if (currentSelection ~= nil and currentSelection ~= towtruck) then
                local pos = GetEntityCoords(NetworkGetEntityFromNetworkId(currentSelection), true)
                local red = 255
                local green = 255
                local blue = 0
                DrawMarker(markerType, pos.x, pos.y, pos.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, scale, scale, scale, red, green, blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnents)
            end
            if (towtruck ~= nil) then
                local pos = GetEntityCoords(NetworkGetEntityFromNetworkId(towtruck), true)
                local red = 255
                local green = 50
                local blue = 0
                DrawMarker(markerType, pos.x, pos.y, pos.z + 1.75, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, scale, scale, scale, red, green, blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnents)
            end
            if (target ~= nil) then
                local pos = GetEntityCoords(NetworkGetEntityFromNetworkId(target), true)
                local red = 255
                local green = 0
                local blue = 50
                DrawMarker(markerType, pos.x, pos.y, pos.z + 1.75, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, scale, scale, scale, red, green, blue, alpha, bounce, faceCam, iUnk, rotate, textureDict, textureName, drawOnents)
            end
        end
    end
end)
