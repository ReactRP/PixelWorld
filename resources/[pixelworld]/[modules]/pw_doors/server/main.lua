PW = nil
local Doors = {}

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.execute("UPDATE `doors` SET `lock` = `defaultLock`", {}, function()
        MySQL.Async.fetchAll("SELECT * FROM `doors`", {}, function(res)
            if res[1] ~= nil then
                for k,v in pairs(res) do
                    Doors[k] = v
                    Doors[k]['coords'] = json.decode(v.coords)
                    Doors[k]['auth'] = json.decode(v.auth)
                    Doors[k]['locking'] = false
                    if v.motel then
                        Doors[k]['motel'] = json.decode(v.motel)
                    end
                end
            end
        end)
    end)
end)

exports('toggleById', function(id, state)
    for k, v in pairs(Doors) do
        if v.id == id then
            TriggerEvent('pw_doors:server:updateDoor', v.id, state)
        end
    end
end)

RegisterServerEvent('pw_doors:server:updateDoor')
AddEventHandler('pw_doors:server:updateDoor', function(door, state)
    Doors[door].lock = state

    local multi = (Doors[door].multi > 0 and Doors[door].multi or false)
    if multi then Doors[GetMulti(door)].lock = state; end
    TriggerClientEvent('pw_doors:client:updateDoor', -1, door, state)
    MySQL.Async.execute("UPDATE `doors` SET `lock` = @lock WHERE `id` = @id"..(multi and " OR `id` = "..multi or ""), { ['@lock'] = state, ['@id'] = Doors[door].id }, function() end)
end)
 
RegisterServerEvent('pw_doors:server:updateLockingState')
AddEventHandler('pw_doors:server:updateLockingState', function(door, state)
    TriggerClientEvent('pw_doors:client:updateLockingState', -1, door, state)
end)

RegisterServerEvent('pw_doors:server:drawShit')
AddEventHandler('pw_doors:server:drawShit', function(door, locking)
    TriggerClientEvent('pw_doors:client:drawShit', -1, door, locking)
end)

RegisterServerEvent('pw_doors:server:addNewMotelDoor')
AddEventHandler('pw_doors:server:addNewMotelDoor', function(data)
    local _src = source

    local door = data.door.data
    local settings = data.settings.data
    local motelInfo = data.motelInfo.data

    local coords = json.encode(door.coords)
    local model = door.model
    local yaw = door.yaw
    local drawDistance = settings.drawDistance

    MySQL.Async.insert("INSERT INTO `doors` (`coords`, `model`, `lock`, `defaultLock`, `yaw`, `auth`, `drawDistance`, `public`, `multi`, `doorType`, `motel`) VALUES (@coords, @model, @lock, @defaultLock, @yaw, @auth, @drawDistance, @public, @multi, @doorType, @motel)", { ['@coords'] = coords, ['@model'] = model, ['@lock'] = true, ['@defaultLock'] = true, ['@yaw'] = yaw, ['@auth'] = json.encode({}), ['@drawDistance'] = drawDistance, ['@public'] = false, ['@multi'] = 0, ['@doorType'] = false, ['@motel'] = json.encode(motelInfo) }, function(inserted)
        if inserted > 0 then
            MySQL.Async.fetchAll("SELECT * FROM `doors` WHERE `id` = @id", { ['@id'] = inserted }, function(res)
                if res[1] ~= nil then
                    table.insert(Doors, res[1])
                    local lastIndex = GetLastTableElement(Doors)
                    Doors[lastIndex]['coords'] = json.decode(res[1].coords)
                    Doors[lastIndex]['auth'] = json.decode(res[1].auth)
                    Doors[lastIndex]['motel'] = json.decode(res[1].motel)
                    Doors[lastIndex]['locking'] = false
                    
                    TriggerClientEvent('pw_doors:client:updateNewDoor', -1, Doors[lastIndex])
                    TriggerClientEvent('pw_doors:client:adminCancelDoor', _src)
                    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'The door has been added with ID #'..inserted })
                end
            end)
        end
    end)
end)

RegisterServerEvent('pw_doors:server:addNewDoor')
AddEventHandler('pw_doors:server:addNewDoor', function(data)
    local _src = source

    local door = data.door.data
    local jobs = data.jobs.data
    local settings = data.settings.data
    local multiStuff = data.multi.data

    local coords = json.encode(door.coords)
    local model = door.model
    local defaultLock = (settings.defaultLock == "Locked" and true or false)
    local yaw, pitch = door.yaw, door.pitch
    local auth = json.encode(jobs)
    local drawDistance = settings.drawDistance
    local public = (settings.public == "Public" and true or false)
    local multi = multiStuff.multiId
    local gate = door.gate

    MySQL.Async.insert("INSERT INTO `doors` (`coords`, `model`, `lock`, `defaultLock`, `yaw`, `pitch`, `auth`, `drawDistance`, `public`, `multi`, `doorType`) VALUES (@coords, @model, @lock, @defaultLock, @yaw, @pitch, @auth, @drawDistance, @public, @multi, @gate)", { ['@coords'] = coords, ['@model'] = model, ['@lock'] = defaultLock, ['@defaultLock'] = defaultLock, ['@yaw'] = yaw, ['@pitch'] = pitch, ['@auth'] = auth, ['@drawDistance'] = drawDistance, ['@public'] = public, ['@multi'] = multi, ['@gate'] = gate }, function(inserted)
        if inserted > 0 then
            if multi > 0 then
                MySQL.Async.execute("UPDATE `doors` SET `multi` = @multi WHERE `id` = @id", { ['@multi'] = inserted, ['@id'] = multi }, function()
                    
                end)
            end

            MySQL.Async.fetchAll("SELECT * FROM `doors` WHERE `id` = @id", { ['@id'] = inserted }, function(res)
                if res[1] ~= nil then
                    table.insert(Doors, res[1])
                    local lastIndex = GetLastTableElement(Doors)
                    Doors[lastIndex]['coords'] = json.decode(res[1].coords)
                    Doors[lastIndex]['auth'] = json.decode(res[1].auth)
                    Doors[lastIndex]['locking'] = false

                    local multiIndex = GetMulti(lastIndex)
                    if multiIndex > 0 then Doors[multiIndex].multi = Doors[lastIndex].id; end
                    
                    TriggerClientEvent('pw_doors:client:updateNewDoor', -1, Doors[lastIndex])
                    TriggerClientEvent('pw_doors:client:adminCancelDoor', _src)
                    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'The door has been added with ID #'..inserted })
                end
            end)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'There was an error adding the door' })
        end
    end)
end)

function GetLastTableElement(table)
    local lastIndex = 0
    for k,v in pairs(table) do
        lastIndex = k
    end
    return lastIndex
end

RegisterServerEvent('pw_doors:server:manageDoor')
AddEventHandler('pw_doors:server:manageDoor', function(data)
    local _src = source
    
    local door = tonumber(data.door.value)
    local type = data.type.value
    local useMulti = false
    local multiIndex = GetMulti(door)
    
    if type == 'model' then
        local newHash = tonumber(data.hash.value)
        if Doors[door].multi > 0 then
            useMulti = Doors[door].multi
        end
        
        MySQL.Async.execute("UPDATE `doors` SET `model` = @model WHERE `id` = @id"..(useMulti and " or `id` = "..useMulti or ""), { ['@model'] = newHash, ['@id'] = Doors[door].id }, function()
            Doors[door].model = newHash
            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'model', newHash)
            if useMulti and multiIndex > 0 then
                Doors[multiIndex].model = newHash
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'model', newHash)
            end
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." model changed to "..newHash, length = 5000 })
        end)
    elseif type == 'toggleLock' then
        TriggerEvent('pw_doors:server:updateDoor', door, not Doors[door].lock)
        TriggerClientEvent('pw_doors:client:drawShit', -1, door)
        TriggerClientEvent('pw_doors:client:adminManageDoor', _src, door)
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." current lock updated to "..(not Doors[door].lock and "Unlocked" or "Locked"), length = 5000 })
    elseif type == 'toggleDefaultLock' then
        local newLock = not Doors[door].defaultLock
        if Doors[door].multi > 0 then
            useMulti = Doors[door].multi
        end
        MySQL.Async.execute("UPDATE `doors` SET `defaultLock` = @defaultLock WHERE `id` = @id"..(useMulti and " or `id` = "..useMulti or ""), { ['@defaultLock'] = newLock, ['@id'] = Doors[door].id }, function()
            Doors[door].defaultLock = newLock
            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'defaultLock', newLock)
            if useMulti and multiIndex > 0 then
                Doors[multiIndex].defaultLock = newLock
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'defaultLock', newLock)
            end
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." default lock updated to "..(newLock and "Locked" or "Unlocked"), length = 5000 })
        end)
    elseif type == 'auth' then
        local auth = data.auth.data
        local sendAuth = json.encode(auth)
        if Doors[door].multi > 0 then
            useMulti = Doors[door].multi
        end
        MySQL.Async.execute("UPDATE `doors` SET `auth` = @auth WHERE `id` = @id"..(useMulti and " or `id` = "..useMulti or ""), { ['@auth'] = sendAuth, ['@id'] = Doors[door].id }, function()
            Doors[door].auth = auth
            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'auth', auth)
            if useMulti and multiIndex > 0 then
                Doors[multiIndex].auth = auth
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'auth', auth)
            end
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." authorization access updated", length = 5000 })
        end)
    elseif type == 'drawDistance' then
        local newDraw = tonumber(data.drawDistance.value)
        if Doors[door].multi > 0 then
            useMulti = Doors[door].multi
        end
        MySQL.Async.execute("UPDATE `doors` SET `drawDistance` = @drawDistance WHERE `id` = @id"..(useMulti and " or `id` = "..useMulti or ""), { ['@drawDistance'] = newDraw, ['@id'] = Doors[door].id }, function()
            Doors[door].drawDistance = newDraw
            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'drawDistance', newDraw)
            if useMulti and multiIndex > 0 then
                Doors[multiIndex].drawDistance = newDraw
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'drawDistance', newDraw)
            end
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." draw distance updated to "..newDraw, length = 5000 })
        end)
    elseif type == 'togglePrivacy' then
        local newSet = not Doors[door].public
        if Doors[door].multi > 0 then
            useMulti = Doors[door].multi
        end
        MySQL.Async.execute("UPDATE `doors` SET `public` = @public WHERE `id` = @id"..(useMulti and " or `id` = "..useMulti or ""), { ['@public'] = newSet, ['@id'] = Doors[door].id }, function()
            Doors[door].public = newSet
            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'public', newSet)
            if useMulti and multiIndex > 0 then
                Doors[multiIndex].public = newSet
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'public', newSet)
            end
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." privacy settings updated to "..(newSet and "Public" or "Private"), length = 5000 })
        end)
    elseif type == 'multi' then
        local multi = data.multi.value
        if multi == "" then 
            multi = 0
        else
            multi = tonumber(multi)
            if multi >= 0 then
                if multi == 0 and Doors[door].multi > 0 then
                    if Doors[multiIndex] ~= nil then
                        MySQL.Async.execute("UPDATE `doors` SET `multi` = 0 WHERE `id` = @id", { ['@id'] = Doors[door].multi }, function()
                            Doors[multiIndex].multi = 0
                            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'multi', 0)
                        end)
                    end
                end
                MySQL.Async.execute("UPDATE `doors` SET `multi` = @multi WHERE `id` = @id", { ['@multi'] = multi, ['@id'] = Doors[door].id }, function()
                    Doors[door].multi = multi
                    TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'multi', multi)
                    if multi > 0 then
                        MySQL.Async.execute("UPDATE `doors` SET `multi` = @multi WHERE `id` = @id", { ['@multi'] = Doors[door].id, ['@id'] = multi }, function()
                            Doors[multiIndex].multi = door
                            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'multi', door)
                        end)
                    end
                    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." double-door settings updated", length = 5000 })
                end)
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Invalid Door ID (must be higher than 0)', length = 5000})
            end
        end
    elseif type == 'delete' then
        if Doors[door].multi > 0 then
            MySQL.Async.execute("UPDATE `doors` SET `multi` = 0 WHERE `id` = @id", { ['@id'] = Doors[door].multi }, function()
                Doors[multiIndex].multi = 0
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, multiIndex, 'multi', 0)
            end)
        end

        MySQL.Async.execute("DELETE FROM `doors` WHERE `id` = @id", { ['@id'] = Doors[door].id }, function()
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Door #'..Doors[door].id.." removed", length = 5000 })
            
            Doors[door] = nil
            TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'delete')
        end)
    elseif type == 'motelId' or type == 'roomId' then
        if Doors[door].motel ~= nil then
            print(type)
            Doors[door].motel[type] = tonumber(data[type].value)
            MySQL.Async.execute("UPDATE `doors` SET `motel` = @motel WHERE `id` = @id", { ['@motel'] = json.encode(Doors[door].motel), ['@id'] = Doors[door].id }, function()
                TriggerClientEvent('pw_doors:client:editDoor', -1, _src, door, 'motel', Doors[door].motel)
            end)
        end
    end
end)

PW.RegisterServerCallback('pw_doors:server:getDoors', function(source, cb)
    cb(Doors)    
end)

exports.pw_chat:AddAdminChatCommand('doors', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_doors:client:adminDoorsMenu', _src)
end, {
    help = "Open Door Management menu",
    params = {}
}, -1)

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