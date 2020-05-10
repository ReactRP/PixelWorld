local coordsViewer = false
local noClip = false
local debugger = false

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
        if playerData.developer or playerData.owner then
            if data.type == "property" then
                TriggerEvent('pw_properties:spawnedInHome', tonumber(data.id))
            end
            local playerPed = GetPlayerPed(-1)
            SetEntityCoords(playerPed, tonumber(data.x), tonumber(data.y), tonumber(data.z))
            SetEntityHeading(playerPed, tonumber(data.h))
        end
    end
end)

RegisterNetEvent('pw_core:admin:loadPlayerMenu')
AddEventHandler('pw_core:admin:loadPlayerMenu', function(data)
    if playerLoaded then
        if playerData.developer or playerData.owner then
            local myCoords = GetEntityCoords(PlayerPedId())
            local myH = GetEntityHeading(PlayerPedId())
            myCoords = { ['x'] = myCoords.x, ['y'] = myCoords.y, ['z'] = myCoords.z, ['h'] = myH}
            local job = {}
            local injuries = {}

            if data.injuries ~= nil then
                table.insert(injuries, {['label'] = "<strong>Bleeding</strong> "..(data.injuries.isBleeding == 1 and "<font class='text-danger'>Is Bleeding</font>" or "<font class='text-success'>Not Bleeding</font>"), ['action'] = "noAction", ['triggertype'] = "client"})
                for k, v in pairs(data.injuries.limbs) do
                    table.insert(injuries, {['label'] = "<strong>"..v.label.."</strong> "..(v.isDamaged and "<font class='text-danger'>Injured</font>" or "<font class='text-success'>Healthy</font>"), ['action'] = "noAction", ['triggertype'] = "client"})
                end
            end

            local details = {
                {['label'] = "<strong>Name:</strong> "..data.name, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>Steam:</strong> "..data.steam, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>CID:</strong> "..data.cid, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>Source:</strong> "..data.source, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>PedID:</strong> "..data.ped, ['action'] = "noAction", ['triggertype'] = "client"},
            }

            local gang = {
                {['label'] = "<strong>Name:</strong> "..data.gang.name, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>GangID:</strong> "..data.gang.gang, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>Rank:</strong> "..data.gang.level_label, ['action'] = "noAction", ['triggertype'] = "client"},
                {['label'] = "<strong>PropertyID:</strong> "..data.gang.property, ['action'] = "noAction", ['triggertype'] = "client"}
            }

            if data.job.name == "unemployed" then
                job = {
                    {['label'] = "Unemployed", ['action'] = "noAction", ['triggertype'] = "client"},
                    {['label'] = "Benefit Award: $"..data.job.salery, ['action'] = "noAction", ['triggertype'] = "client"}
                }
            else
                if data.job.name == "ems" or data.job.name == "police" or data.job.name == "prison" or data.job.name == "fire" then
                    job = {
                        {['label'] = "<strong>Job:</strong> "..data.job.label, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Rank:</strong> "..data.job.grade_label, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Salary:</strong> $"..data.job.salery, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Duty:</strong> "..(data.job.duty and "<font class='text-success'>On-Duty</font>" or "<font class='text-danger'>Off Duty</font>"), ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Workplace:</strong> "..data.job.workplace, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Callsign:</strong> "..data.job.callSign, ['action'] = "noAction", ['triggertype'] = "client"},
                    }
                else
                    job = {
                        {['label'] = "<strong>Job:</strong> "..data.job.label, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Rank:</strong> "..data.job.grade_label, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Salary:</strong> $"..data.job.salery, ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Duty:</strong> "..(data.job.duty and "<font class='text-success'>On-Duty</font>" or "<font class='text-danger'>Off Duty</font>"), ['action'] = "noAction", ['triggertype'] = "client"},
                        {['label'] = "<strong>Workplace:</strong> "..data.job.workplace, ['action'] = "noAction", ['triggertype'] = "client"},
                    }
                end
            end


            local menu = {}

            table.insert(menu, { ['label'] = "Goto Player", ['action'] = "pw_core:client:admin:gotoPlayer", ['triggertype'] = "client", ['color'] = "info", ['value'] = data.coords})
            table.insert(menu, { ['label'] = "Bring Player", ['action'] = "pw_core:client:admin:bringPlayer", ['triggertype'] = "server", ['color'] = "primary", ['value'] = { ['source'] = data.source, ['coords'] = myCoords }})
            table.insert(menu, { ['label'] = "Player Info", ['action'] = "", ['triggertype'] = "", ['color'] = "info", ['subMenu'] = details}) 
            if data.injuries ~= nil then
                table.insert(menu, { ['label'] = "Player Injuries", ['action'] = "", ['triggertype'] = "", ['color'] = "info", ['subMenu'] = injuries}) 
            end
            table.insert(menu, { ['label'] = "Job Details", ['action'] = "", ['triggertype'] = "", ['color'] = "info", ['subMenu'] = job})
            if data.gang.gang ~= nil and data.gang.gang > 0 then
                table.insert(menu, { ['label'] = "Gang Details", ['action'] = "", ['triggertype'] = "", ['color'] = "info", ['subMenu'] = gang})
            end

            table.insert(menu, { ['label'] = "Kick Player", ['action'] = "pw_core:server:admin:dropPlayer", ['triggertype'] = "server", ['color'] = "warning", ['value'] = data.source })
            table.insert(menu, { ['label'] = "Ban Player", ['action'] = "pw_core:server:admin:banPlayer", ['triggertype'] = "server", ['color'] = "danger", ['value'] = { ['source'] = data.source, ['steam'] = data.steam, ['cid'] = data.cid}})

            TriggerEvent('pw_interact:generateMenu', menu, "Player Admin: "..data.name, { { ['trigger'] = 'pw_core:client:admin:openMenu', ['method'] = 'client' } })

        end
    end
end)

RegisterNetEvent('pw_core:client:admin:gotoPlayer')
AddEventHandler('pw_core:client:admin:gotoPlayer', function(coords)
    local PlayerPed = PlayerPedId()
    SetEntityCoords(PlayerPed, coords.x, coords.y, coords.z, 0, 0, 0, false)
end)

RegisterNetEvent('pw_core:client:admin:openMenu')
AddEventHandler('pw_core:client:admin:openMenu', function()
    openAdministrationMenu()
end)

function openAdministrationMenu()
    if playerLoaded then
        if playerData.developer or playerData.owner then
            PW.TriggerServerCallback('pw_core:server:admin:getTeleports', function(locs)
                PW.TriggerServerCallback('pw_core:server:admin:getActiveCharacters', function(chars)
                    local spawnLocs = {}
                    local charsOn = {}
                    for k, v in pairs(locs) do
                        table.insert(spawnLocs, {['label'] = v.name, ['action'] = "pw_core:admin:teleportToLocation", ['triggertype'] = "client", ['value'] = {['x'] = v.x, ['y'] = v.y, ['z'] = v.z, ['h'] = v.h, ['type'] = v.type, ['id'] = v.id}})
                    end

                    for t, q in pairs(chars) do
                        table.insert(charsOn, {['label'] = "["..q.source.."] "..q.name, ['action'] = "pw_core:admin:loadPlayerMenu", ['triggertype'] = "server", ['value'] = q})
                    end

                    local coordSaverSub = {
                        { ['label'] = (coordsViewer and "Disable Screen Coords" or "Enable Screen Coords"), ['action'] = "pw_core:admin:toggleScreenCoords", ['triggertype'] = "client" },
                        { ['label'] = "Toggle Saver Menu", ['action'] = "pw_core:admin:toggleSaverCoords", ['triggertype'] = "client" },
                    }
                    local menu = {
                        { ['label'] = "Active Playerlist", ['action'] = "noCall", ['triggertype'] = "server", ['color'] = "success", ['subMenu'] = charsOn },
                        { ['label'] = "Toggle Job Duty", ['action'] = "pw:toggleDuty", ['triggertype'] = "server", ['color'] = "info" },
                        { ['label'] = "Switch Character", ['action'] = "pw:switchCharacter", ['triggertype'] = "client", ['color'] = "success" },
                        { ['label'] = "Coordinates Saver", ['action'] = "pw_core:admin:loadCoordsSaver", ['triggertype'] = "client", ['color'] = "info", ['subMenu'] = coordSaverSub},
                        { ['label'] = "Teleport To", ['action'] = "noCall", ['triggertype'] = "client", ['color'] = "info", ['subMenu'] = spawnLocs},
                        { ['label'] = (noClip and "Disable No-Clip" or "Enable No-Clip"), ['action'] = "pw_core:noclip", ['triggertype'] = "client", ['color'] = (noClip and "danger" or "info") },
                        { ['label'] = (debugger and "Debugger Active" or "Enable Debug"), ['action'] = "hud:enabledebug", ['triggertype'] = "client", ['color'] = (debugger and "success" or "danger")}
                    }
                    TriggerEvent('pw_interact:generateMenu', menu, "PixelWorld Admin Menu")
                end)
            end)
        end
    end
end

RegisterNetEvent("hud:enabledebug")
AddEventHandler("hud:enabledebug",function()
    debugger = not debugger    
end)

RegisterNetEvent('pw_core:noclip')
AddEventHandler('pw_core:noclip', function()
    noClip = not noClip
end)


RegisterNetEvent('pw_core:admin:toggleSaverCoords')
AddEventHandler('pw_core:admin:toggleSaverCoords', function()
    if playerLoaded then
        if playerData.developer or playerData.owner then
            local playerX, playerY, playerZ = table.unpack(GetEntityCoords(GLOBAL_PED))
            local playerH = GetEntityHeading(GLOBAL_PED)

            playerX, playerY, playerZ, playerH = roundNum(playerX, 3), roundNum(playerY, 3), roundNum(playerZ, 3), roundNum(playerH, 3)

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

function roundNum(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

RegisterNetEvent('pw_core:admin:toggleScreenCoords')
AddEventHandler('pw_core:admin:toggleScreenCoords', function()
    coordsViewer = not coordsViewer
    Citizen.CreateThread(function()
        while coordsViewer do
            if GLOBAL_PED ~= nil then
                if playerLoaded then
                    if playerData.developer or playerData.owner then
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
            if playerData.developer or playerData.owner then
                if IsControlJustReleased(0, 57) then
                    openAdministrationMenu()
                end
            end
        end
        Citizen.Wait(5)
    end
end)

