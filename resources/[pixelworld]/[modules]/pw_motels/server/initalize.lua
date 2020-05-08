PW = nil
motelRooms = {}
rooms = {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    motels = caches.motels
    rooms = caches.motelRooms
 
    for k, v in pairs(rooms) do
        motelRooms[v.room_id] = loadMotelRoom(v.room_id)
    end

    PW.RegisterServerCallback('pw_motels:server:requestMotels', function(source, cb)
        cb(motels)
    end)

    PW.RegisterServerCallback('pw_motels:server:requestMotelRooms', function(source, cb, motelId)
        local fuckshitdicktwat = {}
        for k, v in pairs(rooms) do
            if v.motel_id == motelId and v.motel_type == "Door" then
                table.insert(fuckshitdicktwat, v)
            end
        end
        cb(fuckshitdicktwat)
    end)

    PW.RegisterServerCallback('pw_motels:server:receiveComplexes', function(source, cb)
        local tbl = {}
        local tbl2 = {}
        for k, v in pairs(motels) do 
            table.insert(tbl, {['name'] = v.name, ['coords'] = json.decode(v.location), ['motel_id'] = v.motel_id})
        end

        for t, q in pairs(rooms) do
            
            if q.motel_type == "Teleport" then
                local roomMeta = json.decode(q.roomMeta)
                table.insert(tbl2, { ['room_id'] = q.room_id, ['locked'] = roomMeta.doorLocked, ['motel_name'] = motels[q.motel_id].name, ['motel_id'] = q.motel_id, ['mainEntrance'] = (q.mainEntrance ~= nil and json.decode(q.mainEntrance) or nil), ['room_number'] = q.room_number, ['motel_type'] = q.motel_type, ['teleport_meta'] = json.decode(q.teleport_meta), ['inventories'] = json.decode(q.inventories), ['occupied'] = q.occupied, ['occupier'] = q.occupier, ['occupierCID'] = q.occupierCID, ['charSpawn'] = q.charSpawn, ['roomMeta'] = q.roomMeta})
            else
                table.insert(tbl2, { ['room_id'] = q.room_id, ['motel_name'] = motels[q.motel_id].name, ['motel_id'] = q.motel_id, ['mainEntrance'] = (q.mainEntrance ~= nil and json.decode(q.mainEntrance) or nil), ['room_number'] = q.room_number, ['motel_type'] = q.motel_type, ['inventories'] = json.decode(q.inventories), ['occupied'] = q.occupied, ['occupier'] = q.occupier, ['occupierCID'] = q.occupierCID, ['charSpawn'] = q.charSpawn, ['roomMeta'] = q.roomMeta})
            end
        end
        cb(tbl, tbl2)
    end)
end)

function assignRoom(src, cid)
    local randomiser = {}
    for k, v in pairs(motelRooms) do
        if not v.occupied() then
            table.insert(randomiser, {['id'] = k})
        end
    end

    if #randomiser > 0 then
        local selectedID = math.random(#randomiser)
        motelRooms[selectedID].updateOccupier(src, cid)
    end
end

function unassignRoom(src, cid)
    for k, v in pairs(motelRooms) do
        if v.occupier().source == src and v.occupier().cid == cid then
            v.unassignRoom()
        end
    end
end

exports('assignRoom', function(src, cid)
    assignRoom(src, cid)
end)

exports('unassignRoom', function(src, cid)
    unassignRoom(src, cid)
end)