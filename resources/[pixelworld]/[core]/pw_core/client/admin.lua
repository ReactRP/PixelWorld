local coordsViewer = false
local noClip = false

function DrawGenericText(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(7)
	SetTextScale(0.378, 0.378)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.40, 0.00)
end

FormatCoord = function(coord)
	if coord == nil then
		return "unknown"
	end

	return tonumber(string.format("%.2f", coord))
end

RegisterNetEvent('pw_core:admin:teleportToLocation')
AddEventHandler('pw_core:admin:teleportToLocation', function(data)
    if playerLoaded then
        if playerData.developer then
            if data.type == "property" then
                TriggerEvent('pw_properties:spawnedInHome', tonumber(data.id))
            end
            local playerPed = GetPlayerPed(-1)
            SetEntityCoords(playerPed, tonumber(data.x), tonumber(data.y), tonumber(data.z))
            SetEntityHeading(playerPed, tonumber(data.h))
        end
    end
end)

function openAdministrationMenu()
    if playerLoaded then
        if playerData.developer then
            PW.TriggerServerCallback('pw_core:server:admin:getTeleports', function(locs)
                local spawnLocs = {}
                for k, v in pairs(locs) do
                    table.insert(spawnLocs, {['label'] = v.name, ['action'] = "pw_core:admin:teleportToLocation", ['triggertype'] = "client", ['value'] = {['x'] = v.x, ['y'] = v.y, ['z'] = v.z, ['h'] = v.h, ['type'] = v.type, ['id'] = v.id}})
                end
                local coordSaverSub = {
                    { ['label'] = (coordsViewer and "Disable Screen Coords" or "Enable Screen Coords"), ['action'] = "pw_core:admin:toggleScreenCoords", ['triggertype'] = "client" },
                    { ['label'] = "Toggle Saver Menu", ['action'] = "pw_core:admin:toggleSaverCoords", ['triggertype'] = "client" },
                }
                local menu = {
                    { ['label'] = "Toggle Job Duty", ['action'] = "pw:toggleDuty", ['triggertype'] = "server", ['color'] = "info" },
                    { ['label'] = "Switch Character", ['action'] = "pw:switchCharacter", ['triggertype'] = "client", ['color'] = "success" },
                    { ['label'] = "Coordinates Saver", ['action'] = "pw_core:admin:loadCoordsSaver", ['triggertype'] = "client", ['color'] = "info", ['subMenu'] = coordSaverSub},
                    { ['label'] = "Teleport To", ['action'] = "noCall", ['triggertype'] = "client", ['color'] = "info", ['subMenu'] = spawnLocs},
                    { ['label'] = (noClip and "Disable No-Clip" or "Enable No-Clip"), ['action'] = "pw_core:noclip", ['triggertype'] = "client", ['color'] = (noClip and "danger" or "info") },
                }
                TriggerEvent('pw_interact:generateMenu', menu, "PixelWorld Admin Menu")
            end)
        end
    end
end

RegisterNetEvent('pw_core:noclip')
AddEventHandler('pw_core:noclip', function()
    noClip = not noClip
end)


RegisterNetEvent('pw_core:admin:toggleSaverCoords')
AddEventHandler('pw_core:admin:toggleSaverCoords', function()
    if playerLoaded then
        if playerData.developer then
            local playerX, playerY, playerZ = table.unpack(GetEntityCoords(GLOBAL_PED))
            local playerH = GetEntityHeading(GLOBAL_PED)

            local form = {}
            table.insert(form, {['type'] = "writting", ['align'] = "left", ['value'] = "X Position: <strong>"..playerX.."</strong>" })
            table.insert(form, {['type'] = "writting", ['align'] = "left", ['value'] = "Y Position: <strong>"..playerY.."</strong>" })
            table.insert(form, {['type'] = "writting", ['align'] = "left", ['value'] = "Z Position: <strong>"..playerZ.."</strong>" })
            table.insert(form, {['type'] = "writting", ['align'] = "left", ['value'] = "Heading: <strong>"..playerH.."</strong>" })
            table.insert(form, {['type'] = "text", ['name'] = "Spawn Name", ['label'] = "Spawn Name"})
            table.insert(form, {['type'] = "checkbox", ['name'] = "global_pos", ['label'] = "Global Spawn"})
            table.insert(form, { ['type'] = 'hidden', ['name'] = 'coords', ['data'] = { ['x'] = playerX, ['y'] = playerY, ['z'] = playerZ, ['h'] = playerH } })

            TriggerEvent('pw_interact:generateForm', 'pw_core:client:admin:saveCoordsLocation', 'server', form, 'Coordinates Saver Menu', false, false, "350px", {}, { allowCoords = true})
        end
    end
end)



RegisterNetEvent('pw_core:admin:toggleScreenCoords')
AddEventHandler('pw_core:admin:toggleScreenCoords', function()
    coordsViewer = not coordsViewer
    Citizen.CreateThread(function()
        while coordsViewer do
            if GLOBAL_PED ~= nil then
                if playerLoaded then
                    if playerData.developer then
                        local playerX, playerY, playerZ = table.unpack(GetEntityCoords(GLOBAL_PED))
                        local playerH = GetEntityHeading(GLOBAL_PED)
                        DrawGenericText(("~g~X~w~: %s ~g~Y~w~: %s ~g~Z~w~: %s ~g~H~w~: %s"):format(FormatCoord(playerX), FormatCoord(playerY), FormatCoord(playerZ), FormatCoord(playerH)))                
                    end
                end
            else
                Citizen.Wait(100)
            end
            Citizen.Wait(1)
        end
    end)
end)

RegisterNetEvent('pw_core:admin:spawnVehicle')
AddEventHandler('pw_core:admin:spawnVehicle', function(model)
    if playerLoaded then
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        PW.Game.SpawnOwnedVehicle(model, {x = playerCoords.x+2.0, y = playerCoords.y+2.0, z = playerCoords.z}, playerHeading, function(vehicle)
            if vehicle ~= nil and vehicle ~= 0 then

            end
        end)
    end
end)

function GetControlOfVeh(veh)
    local tNet = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(tNet, true)
    NetworkRegisterEntityAsNetworked(VehToNet(veh))
    
    local timeout = 2000
    NetworkRequestControlOfNetworkId(tNet)
    while not NetworkHasControlOfNetworkId(tNet) do
        if timeout <= 0 then
            break
        else
            timeout = timeout - 100
        end
        NetworkRequestControlOfNetworkId(tNet);
        Wait(100);
    end
    SetEntityAsMissionEntity(NetworkGetEntityFromNetworkId(tNet), true, true)
    return tNet
end

RegisterNetEvent('pw_core:admin:deleteVehicle')
AddEventHandler('pw_core:admin:deleteVehicle', function()
    local playerPed = GetPlayerPed(-1)
    local deleted = false
    local tNet
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        tNet = GetControlOfVeh(vehicle)
        if DecorExistOn(vehicle, "player_owned_veh") then
            DecorRemove(vehicle, "player_owned_veh")
        end
        DeleteVehicle(NetworkGetEntityFromNetworkId(tNet))
        deleted = true
    else
        local vehicle, distance, info = PW.Game.GetClosestVehicle()
        if distance < 5.0 then
            tNet = GetControlOfVeh(vehicle)
            if DecorExistOn(vehicle, "player_owned_veh") then
                DecorRemove(vehicle, "player_owned_veh")
            end
            DeleteVehicle(NetworkGetEntityFromNetworkId(tNet))
            deleted = true
        end
    end

    if deleted then
        exports['pw_notify']:SendAlert("success", "Vehicle has been deleted successfully.", 5000)
    else
        exports['pw_notify']:SendAlert("error", "Vehicle can not be deleted.", 5000)
    end
end)








Citizen.CreateThread(function()
    while true do
        if playerLoaded then
            if playerData.developer then
                if IsControlJustReleased(0, 57) then
                    openAdministrationMenu()
                end
            end
        end
        Citizen.Wait(5)
    end
end)

