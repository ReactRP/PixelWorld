PW = nil
playerLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
local Doors = {}
local showing, updated = false, false
-- admin control
local addingDoor, selectedObject = false, false

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
            for k,v in pairs(Doors) do
                SetInitialState(k)
            end

            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerLoaded = true
        else
            PW.TriggerServerCallback('pw_doors:server:getDoors', function(doors)
                Doors = doors
                playerData = data
            end)
        end
    else
        if showing then showing = false; end
        if updated then updated = false; end
        Doors = {}
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

function SetInitialState(door)
    local doorObj = GetControlOfDoor(door)
    
    if doorObj then
        FreezeEntityPosition(doorObj, Doors[door].lock)

        if Doors[door].lock then
            if Doors[door].doorType == 'gate' then
                SetEntityCoords(doorObj, Doors[door].coords.x, Doors[door].coords.y, Doors[door].coords.z)
            elseif  Doors[door].doorType == 'garage' then
                SetEntityRotation(doorObj, Doors[door].pitch + 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
            else
                SetEntityRotation(doorObj, 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
            end
        end
    end
end

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerData ~= nil then
        playerData.job = data
        showing = false
        TriggerEvent('pw_drawtext:hideNotification')
    end
end)

RegisterNetEvent('pw:setGang')
AddEventHandler('pw:setGang', function(data)
    if playerData ~= nil then
        playerData.gang = data
    end
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerData then
        playerData.job.duty = toggle
        showing = false
        TriggerEvent('pw_drawtext:hideNotification')
    end
end)

RegisterNetEvent('pw_doors:client:updateDoorPosition')
AddEventHandler('pw_doors:client:updateDoorPosition', function(door)
    if Doors[door].multi > 0 then
        ManageDoubleDoors(door)
    else
        ManageDoor(door)
    end
end)

RegisterNetEvent('pw_doors:client:deleteDoor')
AddEventHandler('pw_doors:client:deleteDoor', function(door)
    local doorObj = GetControlOfDoor(door)
    FreezeEntityPosition(doorObj, false)
    Doors[door] = nil
    if showing == door then showing = false; TriggerEvent('pw_drawtext:hideNotification'); end
end)

RegisterNetEvent('pw_doors:client:updateDoor')
AddEventHandler('pw_doors:client:updateDoor', function(door, state)
    local multi = (Doors[door].multi > 0 and Doors[door].multi or false)
    Doors[door].lock = state
    local lock = Doors[door].lock
    
    if multi then 
        local multiIndex = GetMulti(door)
        Doors[multiIndex].lock = state
        local doorObj2 = GetControlOfDoor(multiIndex)
        FreezeEntityPosition(doorObj2, lock)
        if lock then
            SetEntityRotation(doorObj2, 0.0, 0.0, Doors[multiIndex].yaw + 0.0, 2, true)
        end
    end

    local doorObj = GetControlOfDoor(door)
    FreezeEntityPosition(doorObj, lock)

    if lock then
        if Doors[door].doorType == 'door' then
            SetEntityRotation(doorObj, 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
        else
            SetEntityRotation(doorObj, Doors[door].pitch + 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
        end
    end
    
    updated = true
end)

function GetControlOfDoubleDoors(door)
    local multiIndex = GetMulti(door)
    local doorCoords = Doors[door].coords
    local doorCoords2 = Doors[multiIndex].coords
    local radius = ((Doors[door].doorType == 'gate' or Doors[door].doorType == 'garage') and 12.0 or 1.0)
    local doorObj = GetClosestObjectOfType(doorCoords.x, doorCoords.y, doorCoords.z, radius, Doors[door].model, false, false, false)
    local doorObj2 = GetClosestObjectOfType(doorCoords2.x, doorCoords2.y, doorCoords2.z, radius, Doors[multiIndex].model, false, false, false)

    return doorObj, doorObj2
end

function GetControlOfDoor(door)
    local doorCoords = Doors[door].coords
    local radius = ((Doors[door].doorType == 'gate' or Doors[door].doorType == 'garage') and 12.0 or 1.0)
    local doorObj = GetClosestObjectOfType(doorCoords.x, doorCoords.y, doorCoords.z, radius, Doors[door].model, false, false, false)
    
    if DoesEntityExist(doorObj) then        
        return doorObj
    else
        return false
    end
end

function ManageDoubleDoors(door)
    local doorObj, doorObj2 = GetControlOfDoubleDoors(door)

    local lock = not Doors[door].lock
    if lock then
        TriggerServerEvent('pw_doors:server:updateLockingState', door, true)
        if Doors[door].doorType ~= 'gate' and Doors[door].doorType ~= 'garage' then
            DoorAnim()
        end
        local done, done2, showNotif = false, false, false
        Citizen.CreateThread(function()
            local timeout = Config.SwingTimeout
            local continue = true
            while continue do
                Citizen.Wait(50)
                if timeout > 0 then
                    timeout = timeout - 50
                    local rX, rY, rZ = table.unpack(GetEntityRotationVelocity(doorObj))
                    if Doors[door].doorType == 'gate' then
                        if math.abs(rX) < 0.0000002 and math.abs(rY) < 0.0000002 then
                            local curCoords = GetEntityCoords(doorObj)
                            local dist = #(curCoords - vector3(Doors[door].coords.x, Doors[door].coords.y, Doors[door].coords.z))
                            if dist < 0.1 then
                                continue = false
                            end
                        end
                    else
                        local _,_,yaw = table.unpack(GetEntityRotation(doorObj, 2))
                        if (math.abs(yaw - Doors[door].yaw) < 1.0 or math.abs(yaw - (Doors[door].yaw * -1)) < 1.0) and math.abs(rX) < 0.0000002 and math.abs(rY) < 0.0000002 then
                            continue = false
                        end
                    end
                else
                    showNotif = true
                    lock = false
                    continue = false
                end
            end
            done = true
        end)
        
        local multiIndex = GetMulti(door)
        Citizen.CreateThread(function()
            local timeout2 = Config.SwingTimeout
            local continue2 = true
            while continue2 do
                Citizen.Wait(50)
                if timeout2 > 0 then
                    timeout2 = timeout2 - 50
                    local rX2, rY2, rZ2 = table.unpack(GetEntityRotationVelocity(doorObj2))
                    if Doors[multiIndex].doorType == 'gate' then
                        if math.abs(rX2) < 0.0000002 and math.abs(rY2) < 0.0000002 then
                            local curCoords2 = GetEntityCoords(doorObj2)
                            local dist2 = #(curCoords2 - vector3(Doors[multiIndex].coords.x, Doors[multiIndex].coords.y, Doors[multiIndex].coords.z))
                            if dist2 < 0.1 then
                                continue2 = false
                            end
                        end
                    else
                        local _,_,yaw2 = table.unpack(GetEntityRotation(doorObj2, 2))
                        if (math.abs(yaw2 - Doors[multiIndex].yaw) < 1.0 or math.abs(yaw2 - (Doors[multiIndex].yaw * -1)) < 1.0) and math.abs(rX2) < 0.0000002 and math.abs(rY2) < 0.0000002 then
                            continue2 = false
                        end
                    end
                else
                    showNotif = true
                    lock = false
                    continue2 = false
                end
            end
            done2 = true
        end)
            
        while (not done or not done2) do
            Wait(0)
        end

        TriggerServerEvent('pw_doors:server:updateLockingState', door, false)

        if lock then
            if Doors[door].doorType == 'gate' then
                SetEntityCoords(doorObj, Doors[door].coords.x, Doors[door].coords.y, Doors[door].coords.z, 0, 0, 0, 0)
                FreezeEntityPosition(doorObj, true)
                SetEntityCoords(doorObj2, Doors[multiIndex].coords.x, Doors[multiIndex].coords.y, Doors[multiIndex].coords.z, 0, 0, 0, 0)
                FreezeEntityPosition(doorObj2, true)
            else
                SetEntityRotation(doorObj, 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
                FreezeEntityPosition(doorObj, true)
                SetEntityRotation(doorObj2, 0.0, 0.0, Doors[multiIndex].yaw + 0.0, 2, true)
                FreezeEntityPosition(doorObj2, true)
            end
        end

        if showNotif then
            exports.pw_notify:SendAlert('error', 'There was something preventing one of the doors from closing', 5000)
        end
    else
        TriggerServerEvent('pw_doors:server:updateLockingState', door, false)
        if Doors[door].doorType ~= 'gate' and Doors[door].doorType ~= 'garage' then
            DoorAnim()
        end
        FreezeEntityPosition(doorObj, false)
        FreezeEntityPosition(doorObj2, false)
    end
    
    TriggerServerEvent('pw_doors:server:updateDoor', door, lock)
end

function DoorAnim()
    Citizen.CreateThread(function()
        while not HasAnimDictLoaded("anim@heists@keycard@") do
            RequestAnimDict("anim@heists@keycard@")
            Wait(10)
        end
        ClearPedSecondaryTask(GLOBAL_PED)
        TaskPlayAnim(GLOBAL_PED, "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
        Citizen.Wait(850)
        ClearPedTasks(GLOBAL_PED)
    end)
end

function ManageDoor(door)
    local doorObj = GetControlOfDoor(door)

    local lock = not Doors[door].lock
    if lock then
        TriggerServerEvent('pw_doors:server:updateLockingState', door, true)
        if Doors[door].doorType ~= 'gate' and Doors[door].doorType ~= 'garage' then
            DoorAnim()
        end
        local showNotif = false
        Citizen.CreateThread(function()
            local timeout = Config.SwingTimeout
            local continue = true
            while continue do
                Citizen.Wait(50)
                if timeout > 0 then
                    timeout = timeout - 50
                    local rX, rY, rZ = table.unpack(GetEntityRotationVelocity(doorObj))
                    if Doors[door].doorType == 'garage' then
                        local pitch,_,_ = table.unpack(GetEntityRotation(doorObj, 2))
                        if (math.abs(pitch - Doors[door].pitch) < 2.0 or math.abs(pitch - (Doors[door].pitch * -1)) < 2.0) and math.abs(rX) < 0.00002 and math.abs(rY) < 0.00002 then
                            SetEntityRotation(doorObj, Doors[door].pitch + 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
                            FreezeEntityPosition(doorObj, true)
                            continue = false
                        end
                    elseif Doors[door].doorType == 'gate' then
                        if math.abs(rX) < 0.0000002 and math.abs(rY) < 0.0000002 then
                            local curCoords = GetEntityCoords(doorObj)
                            local dist = #(curCoords - vector3(Doors[door].coords.x, Doors[door].coords.y, Doors[door].coords.z))
                            if dist < 0.1 then
                                SetEntityCoords(doorObj, Doors[door].coords.x, Doors[door].coords.y, Doors[door].coords.z, 0, 0, 0, 0)
                                FreezeEntityPosition(doorObj, true)
                                continue = false
                            end
                        end
                    else
                        local _,_,yaw = table.unpack(GetEntityRotation(doorObj, 2))
                        
                        if (math.abs(yaw - Doors[door].yaw) < 1.0 or math.abs(yaw - (Doors[door].yaw * -1)) < 1.0) and math.abs(rX) < 0.0000002 and math.abs(rY) < 0.0000002 then
                            SetEntityRotation(doorObj, 0.0, 0.0, Doors[door].yaw + 0.0, 2, true)
                            FreezeEntityPosition(doorObj, true)
                            continue = false
                        end
                    end
                else
                    showNotif = true
                    lock = false
                    continue = false
                end
            end
            
            if showNotif then
                exports.pw_notify:SendAlert('error', 'There was something preventing the door from closing', 5000)
            end

            TriggerServerEvent('pw_doors:server:updateLockingState', door, false)
            
            TriggerServerEvent('pw_doors:server:updateDoor', door, lock)
        end)
    else
        if Doors[door].doorType ~= 'gate' and Doors[door].doorType ~= 'garage' then
            DoorAnim()
        end
        FreezeEntityPosition(doorObj, false)
        TriggerServerEvent('pw_doors:server:updateLockingState', door, false)
        TriggerServerEvent('pw_doors:server:updateDoor', door, lock)
    end

    if Doors[door].doorType ~= 'gate' and Doors[door].doorType ~= 'garage' then
        DoorAnim()
    end
end

RegisterNetEvent('pw_doors:client:updateLockingState')
AddEventHandler('pw_doors:client:updateLockingState', function(door, state)
    Doors[door].locking = state
    if Doors[door].multi > 0 then
        Doors[GetMulti(door)].locking = state
    end
    
    TriggerServerEvent('pw_doors:server:drawShit', door, state)
end)

function IsAuthorized(door)
    if Doors[door].motel ~= nil then
        local room = tonumber(Doors[door].motel.roomId)

        local occupier = exports.pw_motels:getOccupier(room)
        if playerData.cid == occupier then
            return true
        end
    else
        local auths = Doors[door].auth
        
        for k,v in pairs(auths) do
            if playerData and (v.gang and playerData.gang.gang == v.gang and playerData.gang.level >= v.level) or (playerData.job.name == v.job and playerData.job.grade_level >= v.level and (v.workplace == 0 or (v.workplace > 0 and playerData.job.workplace == v.workplace)) and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                return true
            end
        end
    end

    return false
end

function ToggleDoorLock(door)
    TriggerEvent('pw_doors:client:updateDoorPosition', door)
end

RegisterNetEvent('pw_doors:client:drawShit')
AddEventHandler('pw_doors:client:drawShit', function(door, locking)
    if locking == nil then locking = false; end
    DrawInfo(door, locking)
end)

function GetMulti(door)
    local multi = Doors[door].multi
    if multi > 0 then
        for k,v in pairs(Doors) do
            if v.id == multi then
                return k
            end
        end
    end
    
    return 0
end

function DrawInfo(door, locking)
    local multiIndex = GetMulti(door)
    if showing == door or showing == multiIndex then
        local title, message, icon
        local authedMsg = ""
        local isAuthed = IsAuthorized(door)
        local title = (Doors[showing].motel ~= nil and 'Motel Room' or (Doors[showing].doorType == 'gate' and 'Gate' or (Doors[showing].doorType == 'garage' and 'Garage Gate' or 'Door')))
        
        if (Doors[door].locking or (Doors[door].multi > 0 and multiIndex > 0 and Doors[multiIndex].locking)) and (Doors[door].public or (not Doors[door].public and isAuthed)) then
            message = "<span style='font-size: 25px'><b>LOCKING..</b></span>"
            icon = "fad fa-key"
        else
            SetInitialState(door)
            if showing == multiIndex then SetInitialState(multiIndex); end
            if Doors[door].public or (not Doors[door].public and isAuthed) then
                local locked = Doors[door].lock
                authedMsg = (isAuthed and "<br><span style='font-size: 15px'>Press <span style='color:#187200;'>[E]</span> to " .. (locked and "unlock" or "lock") .. " the door</span>" or "")
                message = "<span style='font-size: 25px'>" .. (not locked and "<b><span style='color:#187200;'>UNLOCKED</span></b>" or "<b><span style='color:#ff0000;'>LOCKED</span></b>")
                icon = (locked and "fad fa-lock-alt" or "fad fa-lock-open-alt")
                
                message = message .. authedMsg
            end
        end

        if message ~= nil and icon ~= nil then
            TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
        end
    end
end

function ShowInfo(door)
    local authed = IsAuthorized(door)
    local public = Doors[door].public
    local multiIndex = GetMulti(door)
    SetInitialState(door)
    if multiIndex > 0 then SetInitialState(multiIndex); end
    if authed or public then
        DrawInfo(door)

        if authed then
            local multiIndex = GetMulti(door)
            Citizen.CreateThread(function()
                while (showing == door or showing == multiIndex) do
                    Citizen.Wait(1)
                    if playerLoaded and playerData then
                        if IsControlJustPressed(0, 38) then
                            ToggleDoorLock(door)
                        end
                    end
                end
            end)
        end
    end
end

exports('toggleLockClose', function(state)
    if showing then
        TriggerServerEvent('pw_doors:server:updateDoor', showing, state)
    end
end)

exports('toggleLockById', function(id, state)
    if id ~= nil and state ~= nil then
        for k, v in pairs(Doors) do
            if v.id == id then
                TriggerServerEvent('pw_doors:server:updateDoor', k, state)
                break
            end
        end
    end
end)

exports('toggleById', function(id)
    if id ~= nil then
        for k, v in pairs(Doors) do
            if v.id == id then
                ToggleDoorLock(k)
                break
            end
        end
    end
end)

exports('getDoorState', function(id)
    if id ~= nil then
        for k, v in pairs(Doors) do
            if v.id == id then
                return Doors[k].lock
            end
        end
    end
    return false
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
        if playerLoaded and playerData then
            local ped = GLOBAL_PED
            local pedCoords = GetEntityCoords(ped)
            for k,v in pairs(Doors) do
                local doorCoords = v.coords
                local dist = #(pedCoords - vector3(doorCoords.x, doorCoords.y, doorCoords.z))
                if dist < v.drawDistance then
                    if not showing then
                        showing = k
                        ShowInfo(k)
                    end
                elseif showing == k then
                    showing = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end
            end
        end
    end
end)

-- ADMIN DOOR MGMT

RegisterNetEvent('pw_doors:client:updateNewDoor')
AddEventHandler('pw_doors:client:updateNewDoor', function(door)
    table.insert(Doors, door)
    local lastIndex = GetLastTableElement(Doors)
    if Doors[lastIndex].multi > 0 then
        local multiIndex = GetMulti(lastIndex)
        Doors[multiIndex].multi = Doors[lastIndex].id
        Doors[multiIndex].lock = Doors[lastIndex].lock
        SetInitialState(multiIndex)
    end
    SetInitialState(lastIndex)
end)

function GetLastTableElement(table)
    if table ~= nil then
        local lastIndex = 0
        for k,v in pairs(table) do
            lastIndex = k
        end
        return lastIndex
    else
        return 0
    end
end

RegisterNetEvent('pw_doors:client:adminJobsConfirmed')
AddEventHandler('pw_doors:client:adminJobsConfirmed', function(data)
    local door = data.door.data
    local settings = data.settings.data
    local multi = data.multi.data
    local minGrades = data.minGrades.data
    local serverJobs = data.jobs.data
    local serverGangs = data.gangs.data
    local selectedJobs = {}
    for i = 1, Config.MaxAuthedJobs do
        if data['job'..i].data and data['job'..i].data.gang then
            selectedJobs[i] = data['job'..i].data
        else
            selectedJobs[i] = data['job'..i].value
        end
    end

    local jobAuth = {}
    local jobAuthString = ""
    for i = 1, #selectedJobs do
        if selectedJobs[i] ~= 'none' then
            if selectedJobs[i].gang then
                for k,v in pairs(serverGangs) do
                    if selectedJobs[i].id == v.id then
                        table.insert(jobAuth, { ['gang'] = selectedJobs[i].id, ['level'] = minGrades[i].level })
                        jobAuthString = jobAuthString .. "<br><b>"..v.name.."</b> (Min. Level: "..jobAuth[i].level..")"
                        break
                    end
                end
            else
                for k,v in pairs(serverJobs) do
                    if selectedJobs[i] == v.name then
                        table.insert(jobAuth, { ['job'] = data['job'..i].value, ['level'] = minGrades[i], ['workplace'] = (tonumber(data['workPlacejob'..i].value) or 0), ['dutyNeeded'] = (data['dutyNeeded'..i].value == "true" and true or false) })
                        jobAuthString = jobAuthString .. "<br><b>"..v.label.."</b> (Min. Level: "..jobAuth[i].level.." | Workplace: "..jobAuth[i].workplace.." | " .. (jobAuth[i].dutyNeeded and "Duty Needed" or "No Duty Needed") .. ")"
                        break
                    end
                end
            end
        end
    end
    
    local form = {
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Object: <b>"..door.obj.."</b><br>Model Hash: <b>"..door.model.."</b><br>Door type: <b>".. (door.gate == 'garage' and 'Garage Door' or (door.gate and 'Gate' or 'Door')) .."</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "X: <b>"..door.coords.x.."</b><br>Y: <b>"..door.coords.y.."</b><br>Z: <b>"..door.coords.z.."</b><br>H: <b>"..door.coords.h.."</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yaw: <b>"..door.yaw.."</b>" .. (door.gate == 'garage' and "<br>Close Pitch: <b>"..door.pitch.."</b>" or "") },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Default Lock: <b>"..settings.defaultLock.."</b><br>Privacy: <b>"..settings.public.."</b><br>Draw Distance: <b>" .. settings.drawDistance .. "</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Part of Double Door setup: <b>"..(not multi.multi and "No" or "Yes").."</b> " .. (multi.multi and multi.multiId > 0 and "(Door ID: <b>" .. multi.multiId .. "</b>)" or "") },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Authorized factions:"..jobAuthString },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door },
        { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings },
        { ['type'] = 'hidden', ['name'] = 'multi', ['data'] = multi },
        { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobAuth },
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:addNewDoor', 'server', form, "Review Settings", {}, false, "450px", { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminSetWorkplace')
AddEventHandler('pw_doors:client:adminSetWorkplace', function(data)
    local door = data.door.data
    local settings = data.settings.data
    local multi = data.multi.data
    local jobs = data.jobs.data
    local gangs = data.gangs.data
    local selectedJobs = data.selectedJobs.data
    local minGradeJobs = {}
    for i = 1, Config.MaxAuthedJobs do
        if data['job'..i].value ~= 'none' then
            if data['job'..i].data and data['job'..i].data.gang then
                for k,v in pairs(gangs) do
                    if v.id == data['job'..i].data.id then
                        local ranks = json.decode(v.ranks)
                        local minRank = tonumber(data['minGradejob'..i].value)
                        for j,b in pairs(ranks) do
                            if b.level == minRank then
                                minGradeJobs[i] = b
                            end
                        end
                    end
                end
            else
                minGradeJobs[i] = tonumber(data['minGradejob'..i].value)
            end
        end
    end

    local dutyOptions = {
        { ['label'] = "Yes", ['value'] = true },
        { ['label'] = "No", ['value'] = false },
    }

    local form = {}
    for i = 1, #selectedJobs do
        if selectedJobs[i] ~= 'none' then
            if not data['job'..i].data.gang then
                for k,v in pairs(jobs) do
                    if v.name == data['job'..i].value then
                        table.insert(form, { ['type'] = 'number', ['label'] = "Set workplace for <b>"..v.label.."</b>", ['name'] = 'workPlacejob'..i })
                        table.insert(form, { ['type'] = 'dropdown', ['label'] = "Duty needed to use door for <b>"..v.label.."</b>", ['name'] = 'dutyNeeded'..i, ['options'] = dutyOptions })
                        break
                    end
                end
            end
        end
    end

    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm final settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'multi', ['data'] = multi })
    for i = 1, Config.MaxAuthedJobs do
        table.insert(form, { ['type'] = 'hidden', ['name'] = 'job'..i, ['value'] = data['job'..i].value, ['data'] = ( (data['job'..i].data and data['job'..i].data.gang) and data['job'..i].data or {} ) })
    end
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'minGrades', ['data'] = minGradeJobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'gangs', ['data'] = gangs })

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminJobsConfirmed', 'client', form, "Set Workplaces")

end)

RegisterNetEvent('pw_doors:client:adminGetGrades')
AddEventHandler('pw_doors:client:adminGetGrades', function(data)
    local door = data.door.data
    local settings = data.settings.data
    local multi = data.multi.data
    local jobs = data.jobs.data
    local gangs = data.gangs.data

    local form = {}
    local selectedJobs = {}
    for i = 1, Config.MaxAuthedJobs do
        if data['job'..i].value ~= 'none' then
            if data['job'..i].data and data['job'..i].data.gang then
                for k,v in pairs(gangs) do
                    if v.id == data['job'..i].data.id then
                        local ranks = json.decode(v.ranks)
                        selectedJobs[i] = {}
                        for j = 1, #ranks do
                            selectedJobs[i][j] = { ['label'] = ranks[j].label, ['value'] = ranks[j].level, ['data'] = { ['gang'] = true } }
                        end
                        break
                    end
                end

                table.sort(selectedJobs[i], function(a,b) return a.value < b.value end)
            else
                selectedJobs[i] = PW.Base.GetAvaliableGrades(data['job'..i].value)
            end
        else
            selectedJobs[i] = 'none'
        end
    end

    local jobGrades = {}
    for i = 1, #selectedJobs do
        jobGrades[i] = {}
        if selectedJobs[i] ~= 'none' then
            for j = 1, #selectedJobs[i] do
                if selectedJobs[i][j].data and selectedJobs[i][j].data.gang then
                    jobGrades[i][j] = { ['label'] = selectedJobs[i][j].value .. " - " .. selectedJobs[i][j].label, ['value'] = selectedJobs[i][j].value }
                else
                    jobGrades[i][j] = { ['label'] = selectedJobs[i][j].level .. " - " .. selectedJobs[i][j].label, ['value'] = selectedJobs[i][j].level }
                end
            end

            table.sort(jobGrades[i], function(a,b) return a.value < b.value end)
        else
            jobGrades[i] = 'none'
        end
    end

    for i = 1, #selectedJobs do
        if selectedJobs[i] ~= 'none' then
            if data['job'..i].data and data['job'..i].data.gang then
                table.insert(form, { ['type'] = 'dropdown', ['label'] = "Select minimum rank for <b>"..data['job'..i].value.."</b>", ['name'] = 'minGradejob'..i, ['options'] = jobGrades[i] })
            else
                for k,v in pairs(jobs) do
                    if v.name == data['job'..i].value then
                        table.insert(form, { ['type'] = 'dropdown', ['label'] = "Select minimum rank for <b>"..v.label.."</b>", ['name'] = 'minGradejob'..i, ['options'] = jobGrades[i] })
                        break
                    end
                end
            end
        end
    end

    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'multi', ['data'] = multi })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'gangs', ['data'] = gangs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'selectedJobs', ['data'] = selectedJobs })
    for i = 1, Config.MaxAuthedJobs do
        table.insert(form, { ['type'] = 'hidden', ['name'] = 'job'..i, ['value'] = data['job'..i].value, ['data'] = ( (data['job'..i].data and data['job'..i].data.gang) and data['job'..i].data or {} )})
    end


    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminSetWorkplace', 'client', form, "Select Grades", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminMultiConfirmed')
AddEventHandler('pw_doors:client:adminMultiConfirmed', function(data)
    local door = data.door.data
    local settings = data.settings.data
    local multi = { ['multi'] = (data.multi.value == "Yes" and true or false), ['multiId'] = ((data.multiId.value ~= nil and data.multiId.value ~= "") and tonumber(data.multiId.value) or 0) }
    
    local availableJobsNoNone, availableJobs = {}, {}
    local jobs = PW.Base.GetAvaliableJobs()
    local gangs = PW.Base.GetAvaliableGangs()

    for i = 1, #jobs do
        table.insert(availableJobsNoNone, { ['label'] = jobs[i].label , ['value'] = jobs[i].name, ['data'] = {} })
    end
    table.insert(availableJobsNoNone, { ['label'] = "-- GANGS --" , ['value'] = 'none' })
    for i = 1, #gangs do
        table.insert(availableJobsNoNone, { ['label'] = gangs[i].name , ['value'] = gangs[i].name, ['data'] = { ['gang'] = true, ['id'] = gangs[i].id } })
    end
    table.insert(availableJobs, { ['label'] = "" , ['value'] = 'none' })
    for k,v in pairs(availableJobsNoNone) do
        table.insert(availableJobs, { ['label'] = v.label , ['value'] = v.value, ['data'] = ( (v.data and v.data.gang) and v.data or {} )})
    end

    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Grant up to <b>" .. Config.MaxAuthedJobs .. "</b> factions access to this door<br>" })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Make sure you select, at least, <b>1</b> faction. Leave the rest of the fields blank if you don't need them." })

    for i = 1, Config.MaxAuthedJobs do
        table.insert(form, { ['type'] = 'dropdown', ['label'] = "Faction "..i, ['name'] = 'job'..i, ['options'] = ( i == 1 and availableJobsNoNone or availableJobs ) })
    end

    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'multi', ['data'] = multi })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'gangs', ['data'] = gangs })

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminGetGrades', 'client', form, "Authed Jobs for New Door", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminMotelDoorConfirmed')
AddEventHandler('pw_doors:client:adminMotelDoorConfirmed', function(data)
    local door = data.door.data
    local settings = data.settings.data
    local motel = tonumber(data.motelId.value)
    local room = tonumber(data.room.value)

    local form = {
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Motel Room Door<br>Motel: <b>" .. motel .. "</b><br>Room ID: <b>" .. room .. "</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Object: <b>"..door.obj.."</b><br>Model Hash: <b>"..door.model.."</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "X: <b>"..door.coords.x.."</b><br>Y: <b>"..door.coords.y.."</b><br>Z: <b>"..door.coords.z.."</b><br>H: <b>"..door.coords.h.."</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yaw: <b>"..door.yaw.."</b>" },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door },
        { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings },
        { ['type'] = 'hidden', ['name'] = 'motelInfo', ['data'] = { ['motelId'] = motel, ['roomId'] = room } },
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:addNewMotelDoor', 'server', form, 'Confirm Motel Door Settings', {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminSettingsConfirmed')
AddEventHandler('pw_doors:client:adminSettingsConfirmed', function(data)
    local door = data.door.data
    local settings = { ['defaultLock'] = data.defaultLock.value, ['public'] = data.public.value, ['drawDistance'] = tonumber(data.drawDistance.value) + 0.0 }
    
    local doubleDoor = {
        { ['label'] = "No", ['value'] = "No" },
        { ['label'] = "Yes", ['value'] = "Yes" }
    }

    local lastIndex = GetLastTableElement(Doors)

    local form = {
        { ['type'] = 'dropdown', ['label'] = "Is this door part of a double door setup?", ['name'] = 'multi', ['options'] = doubleDoor },
        { ['type'] = 'number', ['label'] = "If not, leave blank<br>If yes, insert the other door ID or leave blank if this is the first door of the setup" .. ((lastIndex > 0 and Doors[lastIndex] ~= nil) and "<br>Last inserted door ID: <b>".. Doors[lastIndex].id.."</b>" or ""), ['name'] = 'multiId' },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door },
        { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminMultiConfirmed', 'client', form, "Double Door Setup", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminSettingsConfirmedMotel')
AddEventHandler('pw_doors:client:adminSettingsConfirmedMotel', function(data)
    local door = data.door.data
    local motelId = tonumber(data.motel.value)
    local settings = { ['defaultLock'] = 'Locked', ['public'] = 'Private', ['drawDistance'] = 1.2 }

    local proceed, rooms = false
    PW.TriggerServerCallback('pw_motels:server:requestMotelRooms', function(motelRooms)
        rooms = motelRooms
        proceed = true
    end, motelId)

    repeat Wait(0) until proceed == true

    if #rooms > 0 then
        local roomOptions = {}

        for k,v in pairs(rooms) do
            table.insert(roomOptions, { ['label'] = "Room " .. v.room_number, ['value'] = v.room_id })
        end

        form = {
            { ['type'] = "dropdown", ['label'] = "Select Room", ['name'] = "room", ['options'] = roomOptions },
            { ['type'] = 'hr' },
            { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
            { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
            { ['type'] = 'hidden', ['name'] = 'door', ['data'] = door },
            { ['type'] = 'hidden', ['name'] = 'settings', ['data'] = settings },
            { ['type'] = 'hidden', ['name'] = 'motelId', ['value'] = motelId }
        }

        TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminMotelDoorConfirmed', 'client', form, "Motel Door Setup", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
    end
end)

RegisterNetEvent('pw_doors:client:adminDoorConfirmed')
AddEventHandler('pw_doors:client:adminDoorConfirmed', function(data)
    local door = data.door.data
    local form = {}
    if data.gate.value == 'motel' then
        local proceed, motels = false
        PW.TriggerServerCallback('pw_motels:server:requestMotels', function(ids)
            motels = ids
            proceed = true
        end)

        repeat Wait(0) until proceed == true

        local motelOptions = {}
        for k,v in pairs(motels) do
            table.insert(motelOptions, { ['label'] = v.name, ['value'] = v.motel_id })
        end

        form = {
            { ['type'] = "dropdown", ['label'] = "Select Motel", ['name'] = "motel", ['options'] = motelOptions },
            { ['type'] = 'hr' },
            { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
            { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
            { ['type'] = 'hidden', ['name'] = 'door', ['data'] = { obj = door.obj, model = door.model, coords = {['x'] = door.coords.x, ['y'] = door.coords.y, ['z'] = door.coords.z, ['h'] = door.coords.h}, yaw = door.yaw, gate = false, motel = true }}
        }

        TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminSettingsConfirmedMotel', 'client', form, "Motel Door Settings", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
    else
        local lockOptions = {
            { ['label'] = 'Locked', ['value'] = 'Locked' },
            { ['label'] = 'Unlocked', ['value'] = 'Unlocked' }
        }

        local publicOptions = {
            { ['label'] = 'Public', ['value'] = 'Public' },
            { ['label'] = 'Authorized only', ['value'] = 'Private' }
        }

        form = {
            { ['type'] = "dropdown", ['label'] = "Default lock <i>(on server restart set lock to this)</i>", ['name'] = "defaultLock", ['options'] = lockOptions },
            { ['type'] = "dropdown", ['label'] = "Privacy options <i>(Public = any player can see the door lock state)</i> ", ['name'] = "public", ['options'] = publicOptions },
            { ['type'] = "range", ['label'] = "Draw Distance (from where you can interact with the door)", ['default'] = 2, ['min'] = 1, ['max'] = 20, ['name'] = 'drawDistance', ['step'] = 0.1 },
            { ['type'] = 'hr' },
            { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
            { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
            { ['type'] = 'hidden', ['name'] = 'door', ['data'] = { obj = door.obj, model = door.model, coords = {['x'] = door.coords.x, ['y'] = door.coords.y, ['z'] = door.coords.z, ['h'] = door.coords.h}, yaw = door.yaw, gate = data.gate.value, pitch = door.pitch }}
        }

        TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminSettingsConfirmed', 'client', form, "Door Settings", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
    end
end)

RegisterNetEvent('pw_doors:client:adminNewDoorType')
AddEventHandler('pw_doors:client:adminNewDoorType', function(data)
    local doorTypes = {
        { ['label'] = "Door", ['value'] = 'door' },
        { ['label'] = "Gate", ['value'] = 'gate' },
        { ['label'] = "Garage Door", ['value'] = 'garage' },
        { ['label'] = "Motel Room Door", ['value'] = 'motel' },
    }

    local door = data.door.data
    local form = {
        { ['type'] = "dropdown", ['label'] = "Door type", ['name'] = 'gate', ['options'] = doorTypes },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['data'] = { obj = door.obj, model = door.model, coords = {['x'] = door.coords.x, ['y'] = door.coords.y, ['z'] = door.coords.z, ['h'] = door.coords.h}, yaw = door.yaw, pitch = door.pitch }}
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminDoorConfirmed', 'client', form, "Add New Door", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminCancelDoor')
AddEventHandler('pw_doors:client:adminCancelDoor', function()
    addingDoor = false
    selectedObject = false
    TriggerEvent('pw_doors:client:adminDoorsMenu')
end)

function LoadObjectInfo(obj)
    local model = GetEntityModel(obj)
    local x, y, z = table.unpack(GetEntityCoords(obj))
    local heading = GetEntityHeading(obj)
    local pitch, _, yaw = table.unpack(GetEntityRotation(obj, 2))

    local form = {
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Object: <b>"..obj.."</b><br>Model Hash: <b>"..model.."</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "X: <b>"..x.."</b><br>Y: <b>"..y.."</b><br>Z: <b>"..z.."</b><br>H: <b>"..heading.."</b>" },
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yaw: <b>"..yaw.."</b>" },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Use this door?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['data'] = { obj = obj, model = model, coords = {['x'] = x, ['y'] = y, ['z'] = z, ['h'] = heading}, yaw = yaw, pitch = pitch }}
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminNewDoorType', 'client', form, "Add New Door", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end

RegisterNetEvent('pw_doors:client:adminAddDoor')
AddEventHandler('pw_doors:client:adminAddDoor', function()
    if not addingDoor then
        addingDoor = true
    
        exports.pw_notify:PersistentAlert('start', 'addDoor', 'inform', 'Point to a door and press <b><span style="color:#ffff00">SHIFT+X</span></b> to add it to the door system<br><b><span style="color:#ffff00">SHIFT+C</span></b> to cancel the operation')
        
        Citizen.CreateThread(function()
            while addingDoor and playerLoaded do
                Citizen.Wait(1)
                if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then -- Shift+x
                    local playerPed = GLOBAL_PED
                    local CoordFrom = GetEntityCoords(playerPed, true)
                    local CoordTo = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 12.0, 0.0)
                    local RayHandle = StartShapeTestRay(CoordFrom.x, CoordFrom.y, CoordFrom.z, CoordTo.x, CoordTo.y, CoordTo.z, 16, playerPed, 0)
                    local _, _, _, _, object = GetShapeTestResult(RayHandle)
                    if object ~= 0 then
                        selectedObject = object
                        local objCoords = GetEntityCoords(object)
                        Citizen.CreateThread(function()
                            while (addingDoor and selectedObject == object) do
                                Citizen.Wait(1)
                                DrawMarker(1, objCoords.x, objCoords.y, objCoords.z - 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.8, 255, 0, 0, 200, false, true, 2, false, nil, nil, false)
                            end
                        end)

                        LoadObjectInfo(object)
                    else
                        exports.pw_notify:SendAlert('error', 'Door not found', 4000)
                    end
                end

                if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then -- Shift+c
                    addingDoor = false
                    TriggerEvent('pw_doors:client:adminDoorsMenu')
                end
            end

            exports.pw_notify:PersistentAlert('end', 'addDoor')
        end)
    end
end)

RegisterNetEvent('pw_doors:client:adminManageDoorModel')
AddEventHandler('pw_doors:client:adminManageDoorModel', function(door)
    local form = {
        { ['type'] = 'number', ['label'] = 'Insert new hash', ['name'] = 'hash' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Save changes?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door },
        { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'model' }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Edit Door #"..Doors[door].id.." Hash Model", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorPrivacy')
AddEventHandler('pw_doors:client:adminManageDoorPrivacy', function(door)
    TriggerServerEvent('pw_doors:server:manageDoor', { ['type'] = { ['value'] = 'togglePrivacy' }, ['door'] = { ['value'] = door } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorDefaultLock')
AddEventHandler('pw_doors:client:adminManageDoorDefaultLock', function(door)
    TriggerServerEvent('pw_doors:server:manageDoor', { ['type'] = { ['value'] = 'toggleDefaultLock' }, ['door'] = { ['value'] = door } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorCurrentLock')
AddEventHandler('pw_doors:client:adminManageDoorCurrentLock', function(door)
    TriggerServerEvent('pw_doors:server:manageDoor', { ['type'] = { ['value'] = 'toggleLock' }, ['door'] = { ['value'] = door } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorType')
AddEventHandler('pw_doors:client:adminManageDoorType', function(door)
    TriggerServerEvent('pw_doors:server:manageDoor', { ['type'] = { ['value'] = 'toggleType' }, ['door'] = { ['value'] = door } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorAuthConfirm')
AddEventHandler('pw_doors:client:adminManageDoorAuthConfirm', function(data)
    local door = tonumber(data.door.value)
    local selectedJobs = data.selectedJobs.data
    local minGrades = data.minGradeJobs.data
    local serverJobs = data.jobs.data
    local serverGangs = data.gangs.data
    
    for i = 1, Config.MaxAuthedJobs do
        if data['job'..i].data and data['job'..i].data.gang then
            selectedJobs[i] = data['job'..i].data
        else
            selectedJobs[i] = data['job'..i].value
        end
    end

    local jobAuth = {}
    local jobAuthString = ""
    for i = 1, #selectedJobs do
        if selectedJobs[i] ~= 'none' then
            if selectedJobs[i].gang then
                for k,v in pairs(serverGangs) do
                    if selectedJobs[i].id == v.id then
                        table.insert(jobAuth, { ['gang'] = selectedJobs[i].id, ['level'] = minGrades[i] })
                        jobAuthString = jobAuthString .. "<br><b>"..v.name.."</b> (Min. Level: "..jobAuth[i].level..")"
                        break
                    end
                end
            else
                for k,v in pairs(serverJobs) do
                    if selectedJobs[i] == v.name then
                        table.insert(jobAuth, { ['job'] = data['job'..i].value, ['level'] = minGrades[i], ['workplace'] = (tonumber(data['workPlacejob'..i].value) or 0), ['dutyNeeded'] = (data['dutyNeeded'..i].value == "true" and true or false) })
                        jobAuthString = jobAuthString .. "<br><b>"..v.label.."</b> (Min. Level: "..jobAuth[i].level.." | Workplace: "..jobAuth[i].workplace.." | " .. (jobAuth[i].dutyNeeded and "Duty Needed" or "No Duty Needed") .. ")"
                        break
                    end
                end
            end
        end
    end
    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Authorized factions:"..jobAuthString })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'auth' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'auth', ['data'] = jobAuth })
    
    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Edit Door #"..Doors[door].id.." Authorization", {}, false, '450px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorAuthWorkplaces')
AddEventHandler('pw_doors:client:adminManageDoorAuthWorkplaces', function(data)
    local door = tonumber(data.door.value)
    local jobs = data.jobs.data
    local gangs = data.gangs.data
    local selectedJobs = data.selectedJobs.data
    local minGradeJobs = {}
    for i = 1, Config.MaxAuthedJobs do
        if data['job'..i].value ~= 'none' then
            minGradeJobs[i] = tonumber(data['minGradejob'..i].value)
        end
    end

    local dutyOptions = {
        { ['label'] = "Yes", ['value'] = true },
        { ['label'] = "No", ['value'] = false },
    }

    local form = {}
    for i = 1, #selectedJobs do
        if selectedJobs[i] ~= 'none' then
            if not data['job'..i].data.gang then
                for k,v in pairs(jobs) do
                    if v.name == data['job'..i].value then
                        table.insert(form, { ['type'] = 'number', ['label'] = "Set workplace for <b>"..v.label.."</b>", ['name'] = 'workPlacejob'..i })
                        table.insert(form, { ['type'] = 'dropdown', ['label'] = "Duty needed to use door for <b>"..v.label.."</b>", ['name'] = 'dutyNeeded'..i, ['options'] = dutyOptions })
                        break
                    end
                end
            end
        end
    end


    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'selectedJobs', ['data'] = selectedJobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'minGradeJobs', ['data'] = minGradeJobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'gangs', ['data'] = gangs })
    for i = 1, Config.MaxAuthedJobs do
        table.insert(form, { ['type'] = 'hidden', ['name'] = 'job'..i, ['value'] = data['job'..i].value, ['data'] = ( (data['job'..i].data and data['job'..i].data.gang) and data['job'..i].data or {} ) })
    end
    
    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminManageDoorAuthConfirm', 'client', form, "Edit Door #"..Doors[door].id.." Authorization", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorAuthGrades')
AddEventHandler('pw_doors:client:adminManageDoorAuthGrades', function(data)
    local door = tonumber(data.door.value)
    local jobs = data.jobs.data
    local gangs = data.gangs.data
    local selectedJobs = {}

    local form = {}
    local selectedJobs = {}
    for i = 1, Config.MaxAuthedJobs do
        if data['job'..i].value ~= 'none' then
            if data['job'..i].data and data['job'..i].data.gang then
                for k,v in pairs(gangs) do
                    if v.id == data['job'..i].data.id then
                        local ranks = json.decode(v.ranks)
                        selectedJobs[i] = {}
                        for j = 1, #ranks do
                            selectedJobs[i][j] = { ['label'] = ranks[j].label, ['value'] = j, ['data'] = { ['gang'] = true } }
                        end
                        break
                    end
                end

                table.sort(selectedJobs[i], function(a,b) return a.value < b.value end)
            else
                selectedJobs[i] = PW.Base.GetAvaliableGrades(data['job'..i].value)
            end
        else
            selectedJobs[i] = 'none'
        end
    end

    local jobGrades = {}
    for i = 1, #selectedJobs do
        jobGrades[i] = {}
        if selectedJobs[i] ~= 'none' then
            for j = 1, #selectedJobs[i] do
                if selectedJobs[i][j].data and selectedJobs[i][j].data.gang then
                    jobGrades[i][j] = { ['label'] = selectedJobs[i][j].value .. " - " .. selectedJobs[i][j].label, ['value'] = selectedJobs[i][j].value }
                else
                    jobGrades[i][j] = { ['label'] = selectedJobs[i][j].level .. " - " .. selectedJobs[i][j].label, ['value'] = selectedJobs[i][j].level }
                end
            end

            table.sort(jobGrades[i], function(a,b) return a.value < b.value end)
        else
            jobGrades[i] = 'none'
        end
    end

    for i = 1, #selectedJobs do
        if selectedJobs[i] ~= 'none' then
            if data['job'..i].data and data['job'..i].data.gang then
                table.insert(form, { ['type'] = 'dropdown', ['label'] = "Select minimum rank for <b>"..data['job'..i].value.."</b>", ['name'] = 'minGradejob'..i, ['options'] = jobGrades[i] })
            else
                for k,v in pairs(jobs) do
                    if v.name == data['job'..i].value then
                        table.insert(form, { ['type'] = 'dropdown', ['label'] = "Select minimum rank for <b>"..v.label.."</b>", ['name'] = 'minGradejob'..i, ['options'] = jobGrades[i] })
                        break
                    end
                end
            end
        end
    end

    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'selectedJobs', ['data'] = selectedJobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'gangs', ['data'] = gangs })
    for i = 1, Config.MaxAuthedJobs do
        table.insert(form, { ['type'] = 'hidden', ['name'] = 'job'..i, ['value'] = data['job'..i].value, ['data'] = ( (data['job'..i].data and data['job'..i].data.gang) and data['job'..i].data or {} ) })
    end

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminManageDoorAuthWorkplaces', 'client', form, "Edit Door #"..Doors[door].id.." Authorization", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorAuth')
AddEventHandler('pw_doors:client:adminManageDoorAuth', function(door)
    local availableJobsNoNone, availableJobs = {}, {}
    local jobs = PW.Base.GetAvaliableJobs()
    local gangs = PW.Base.GetAvaliableGangs()

    for i = 1, #jobs do
        table.insert(availableJobsNoNone, { ['label'] = jobs[i].label , ['value'] = jobs[i].name, ['data'] = {} })
    end
    table.insert(availableJobsNoNone, { ['label'] = "-- GANGS --" , ['value'] = 'none' })
    for i = 1, #gangs do
        table.insert(availableJobsNoNone, { ['label'] = gangs[i].name , ['value'] = gangs[i].name, ['data'] = { ['gang'] = true, ['id'] = gangs[i].id } })
    end
    table.insert(availableJobs, { ['label'] = "" , ['value'] = 'none' })
    for k,v in pairs(availableJobsNoNone) do
        table.insert(availableJobs, { ['label'] = v.label , ['value'] = v.value, ['data'] = ( (v.data and v.data.gang) and v.data or {} )})
    end

    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Grant up to <b>" .. Config.MaxAuthedJobs .. "</b> factions access to this door<br>" })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "Make sure you select, at least, <b>1</b> faction. Leave the rest of the fields blank if you don't need them." })

    for i = 1, Config.MaxAuthedJobs do
        table.insert(form, { ['type'] = 'dropdown', ['label'] = "Faction "..i, ['name'] = 'job'..i, ['options'] = ( i == 1 and availableJobsNoNone or availableJobs ) })
    end

    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'jobs', ['data'] = jobs })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'gangs', ['data'] = gangs })

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminManageDoorAuthGrades', 'client', form, "Edit Door #"..Doors[door].id.." Authorization", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorDraw')
AddEventHandler('pw_doors:client:adminManageDoorDraw', function(door)
    local form = {
        { ['type'] = "range", ['label'] = "Draw Distance (from where you can interact with the door)", ['default'] = 2, ['min'] = 1, ['max'] = 20, ['name'] = 'drawDistance', ['step'] = 0.1 },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door },
        { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'drawDistance' }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Edit Door #"..Doors[door].id.. " Draw Distance", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorDouble')
AddEventHandler('pw_doors:client:adminManageDoorDouble', function(door)
    local form = {
        { ['type'] = 'writting', ['align'] = 'left', ['value'] = 'Below, insert the Door ID of the door you wish to be paired with the door you are facing.<br>Leave blank or type 0 to disable double-door support.' },
        { ['type'] = 'number', ['label'] = 'Insert the target Door ID', ['name'] = 'multi' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Confirm settings?</b>" },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door },
        { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'multi' }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Edit Door #"..Doors[door].id.. " Double-Door settings", {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoorRemove')
AddEventHandler('pw_doors:client:adminManageDoorRemove', function(door)
    local form = {
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = 'This action is <b>irreversible</b> and will delete the door lock for this door.<br>Are you sure you want to delete this door?' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'No' },
        { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door },
        { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'delete' },
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Delete Door #"..Doors[door].id, {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:editDoor')
AddEventHandler('pw_doors:client:editDoor', function(src, door, type, value)
    if type == 'delete' then
        TriggerEvent('pw_doors:client:deleteDoor', door)

        if GetPlayerServerId(PlayerId()) == src then TriggerEvent('pw_doors:client:adminDoorsMenu'); end
    else
        Doors[door][type] = value
        if showing == door then 
            showing = false
            TriggerEvent('pw_drawtext:hideNotification')
        end
        
        if GetPlayerServerId(PlayerId()) == src then TriggerEvent('pw_doors:client:adminManageDoor', door); end
    end

end)

RegisterNetEvent('pw_doors:client:adminManageMotelDoorMotel')
AddEventHandler('pw_doors:client:adminManageMotelDoorMotel', function(door)
    local proceed, motels = false
    PW.TriggerServerCallback('pw_motels:server:requestMotels', function(ids)
        motels = ids
        proceed = true
    end)

    repeat Wait(0) until proceed == true

    local motelOptions = {}

    for k,v in pairs(motels) do
        table.insert(motelOptions, { ['label'] = v.name, ['value'] = v.motel_id })
    end

    local form = {
        { ['type'] = 'dropdown', ['label'] = 'Motel', ['name'] = 'motelId', ['options'] = motelOptions },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Confirm settings?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door },
        { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'motelId' }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Edit Motel ID Door #"..Doors[door].id, {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageMotelDoorRoom')
AddEventHandler('pw_doors:client:adminManageMotelDoorRoom', function(door)
    local proceed, rooms = false
    PW.TriggerServerCallback('pw_motels:server:requestMotelRooms', function(ids)
        rooms = ids
        proceed = true
    end, tonumber(Doors[door].motel.motelId))

    repeat Wait(0) until proceed == true

    local roomOptions = {}

    for k,v in pairs(rooms) do
        table.insert(roomOptions, { ['label'] = "Room " .. v.room_number, ['value'] = v.room_id })
    end

    local form = {
        { ['type'] = 'dropdown', ['label'] = 'Room', ['name'] = 'roomId', ['options'] = roomOptions },
        { ['type'] = 'hr' },
        { ['type'] = 'writting', ['align'] = 'center', ['value'] = '<b>Confirm settings?</b>' },
        { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door },
        { ['type'] = 'hidden', ['name'] = 'type', ['value'] = 'roomId' }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_doors:server:manageDoor', 'server', form, "Edit Motel Room Door #"..Doors[door].id, {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminManageDoor')
AddEventHandler('pw_doors:client:adminManageDoor', function(data)
    local door
    if data == nil then
        if showing then
            door = showing
        else 
            return
        end
    else
        if type(data) == 'number' then
            door = data
        elseif type(data) == 'table' then
            door = tonumber(data.door.value)
        end
    end

    local menu = {}

    if Doors[door].motel ~= nil then
        table.insert(menu, { ['label'] = 'Toggle Current Lock ' .. (Doors[door].lock and "<i class='fad fa-lock-alt fa-fw'></i>" or "<i class='fad fa-lock-open-alt fa-fw'></i>"), ['action'] = 'pw_doors:client:adminManageDoorCurrentLock', ['value'] = door, ['triggertype'] = 'client', ['color'] = (Doors[door].lock and 'danger' or 'success') })
        table.insert(menu, { ['label'] = 'Change Motel ID', ['action'] = 'pw_doors:client:adminManageMotelDoorMotel', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Change Room ID', ['action'] = 'pw_doors:client:adminManageMotelDoorRoom', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })

        TriggerEvent('pw_interact:generateMenu', menu, "Edit Motel Room Door #"..Doors[door].id, {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
    else
        --table.insert(menu, { ['label'] = '', ['action'] = 'pw_doors:client:adminManageDoor', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Toggle Current Lock ' .. (Doors[door].lock and "<i class='fad fa-lock-alt fa-fw'></i>" or "<i class='fad fa-lock-open-alt fa-fw'></i>"), ['action'] = 'pw_doors:client:adminManageDoorCurrentLock', ['value'] = door, ['triggertype'] = 'client', ['color'] = (Doors[door].lock and 'danger' or 'success') })
        table.insert(menu, { ['label'] = 'Toggle Default Lock ' .. (Doors[door].defaultLock and "<i class='fad fa-lock-alt fa-fw'></i>" or "<i class='fad fa-lock-open-alt fa-fw'></i>"), ['action'] = 'pw_doors:client:adminManageDoorDefaultLock', ['value'] = door, ['triggertype'] = 'client', ['color'] = (Doors[door].defaultLock and 'danger' or 'success') })
        table.insert(menu, { ['label'] = 'Toggle Privacy Settings ' .. (not Doors[door].public and "<i class='fad fa-lock-alt fa-fw'></i>" or "<i class='fad fa-lock-open-alt fa-fw'></i>"), ['action'] = 'pw_doors:client:adminManageDoorPrivacy', ['value'] = door, ['triggertype'] = 'client', ['color'] = (not Doors[door].public and 'danger' or 'success') })
        table.insert(menu, { ['label'] = 'Model Hash', ['action'] = 'pw_doors:client:adminManageDoorModel', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Authorization', ['action'] = 'pw_doors:client:adminManageDoorAuth', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Draw Distance', ['action'] = 'pw_doors:client:adminManageDoorDraw', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Double-Door Settings', ['action'] = 'pw_doors:client:adminManageDoorDouble', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Remove Door', ['action'] = 'pw_doors:client:adminManageDoorRemove', ['value'] = door, ['triggertype'] = 'client', ['color'] = 'danger' })

        TriggerEvent('pw_interact:generateMenu', menu, "Edit Door #"..Doors[door].id, {}, false, '350px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
    end
end)

RegisterNetEvent('pw_doors:client:adminInfoDoor')
AddEventHandler('pw_doors:client:adminInfoDoor', function(door)
    if door == nil then
        if showing then
            door = showing
        else
            exports.pw_notify:SendAlert('error', 'No doors found nearby', 4000)
            TriggerEvent('pw_doors:client:adminDoorsMenu')
            return
        end
    end

    local form = {}
    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Door ID: <b>"..Doors[door].id.."</b> ("..(Doors[door].lock and "Locked" or "Unlocked")..")<br>Model: <b>" .. Doors[door].model .. "</b><br>" .. (Doors[door].motel ~= nil and "<b>Motel Room Door" or "Door Type: <b>"..tostring(Doors[door].doorType)).."</b>" })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "X: <b>"..Doors[door].coords.x.."</b><br>Y: <b>"..Doors[door].coords.y.."</b><br>Z: <b>"..Doors[door].coords.z.."</b><br>H: <b>"..Doors[door].coords.h.."</b>" })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Yaw: <b>"..Doors[door].yaw.."</b>" })
    if Doors[door].motel == nil then
        local jobAuthString = ""
        for i = 1, #Doors[door].auth do
            if Doors[door].auth[i].gang then
                local gangInfo = exports.pw_gangs:getGangInfoById(Doors[door].auth[i].gang)
                jobAuthString = jobAuthString .. "<br><b>"..gangInfo.name.."</b> (Min. Level: "..Doors[door].auth[i].level..")"
            else
                jobAuthString = jobAuthString .. "<br><b>"..Doors[door].auth[i].job.."</b> (Min. Level: "..Doors[door].auth[i].level.." | Workplace: "..Doors[door].auth[i].workplace.." | " .. (Doors[door].auth[i].dutyNeeded and "Duty Needed" or "No Duty Needed") .. ")"
            end
        end

        table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Default Lock: <b>"..tostring(Doors[door].defaultLock).."</b><br>Privacy: <b>"..tostring(Doors[door].public).."</b><br>Draw Distance: <b>" .. Doors[door].drawDistance .. "</b>" })
        table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Part of Double Door setup: <b>"..(Doors[door].multi > 0 and "Yes" or "No").."</b> " .. (Doors[door].multi > 0 and "(Door ID: <b>" .. Doors[door].multi .. "</b>)" or "") })
        table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Authorized factions:"..jobAuthString })
    else
        table.insert(form, { ['type'] = 'writting', ['align'] = 'left', ['value'] = "Motel ID: <b>" .. Doors[door].motel.motelId .. "</b><br>Room ID: <b>" .. Doors[door].motel.roomId .. "</b>" })
    end
    table.insert(form, { ['type'] = 'hr' })
    table.insert(form, { ['type'] = 'writting', ['align'] = 'center', ['value'] = "<b>Edit this door?</b>" })
    table.insert(form, { ['type'] = 'yesno', ['success'] = 'Yes', ['reject'] = 'Cancel' })
    table.insert(form, { ['type'] = 'hidden', ['name'] = 'door', ['value'] = door })
    

    TriggerEvent('pw_interact:generateForm', 'pw_doors:client:adminManageDoor', 'client', form, "Edit Door #"..Doors[door].id, {}, false, '450px', { { ['trigger'] = 'pw_doors:client:adminCancelDoor', ['method'] = 'client' } })
end)

RegisterNetEvent('pw_doors:client:adminDoorsMenu')
AddEventHandler('pw_doors:client:adminDoorsMenu', function()
    local menu = {}

    table.insert(menu, { ['label'] = "Add Door", ['action'] = 'pw_doors:client:adminAddDoor', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Manage Near Doors", ['action'] = 'pw_doors:client:adminInfoDoor', ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Admin Door Management")
end)