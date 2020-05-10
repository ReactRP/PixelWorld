TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    motels = caches.motels
    rooms = caches.motelRooms
 
    for k, v in pairs(rooms) do
        motelRooms[v.room_id] = loadMotelRoom(v.room_id)
    end
end)

PW.RegisterServerCallback('pw_motels:server:requestMotels', function(source, cb)
    cb(motels)
end)

PW.RegisterServerCallback('pw_motels:server:requestRooms', function(source, cb)
    cb(rooms)
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
    repeat Wait(0) until motelRooms ~= nil
    for t, q in pairs(motelRooms) do
        rooms[q.roomID] = q.requestClient()
    end
    cb(tbl, tbl2)
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

        if selectedID > 0 then
            selectedID = randomiser[selectedID].id
        end

        if motelRooms[selectedID] then 
            print(selectedID)
            print(src, cid)
            motelRooms[selectedID].updateOccupier(src, cid)
        else
            print('Motel not fucking foudn?')
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