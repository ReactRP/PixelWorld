RegisterServerEvent('pw_motels:server:triggerDoorLock')
AddEventHandler('pw_motels:server:triggerDoorLock', function(room)
    local _src = source

    if room then
        if motelRooms[room] then
            motelRooms[room].updateLock()
        end
    end

end)