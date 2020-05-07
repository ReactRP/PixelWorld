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
        for k, v in pairs(motels) do 
            table.insert(tbl, {['name'] = v.name, ['coords'] = json.decode(v.location), ['motel_id'] = v.motel_id})
        end
        cb(tbl, rooms)
    end)
end)

function assignRoom(src, cid)
    for k, v in pairs(motelRooms) do
        if not v.occupied() then
            v.updateOccupier(src, cid)
            break;
        end
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