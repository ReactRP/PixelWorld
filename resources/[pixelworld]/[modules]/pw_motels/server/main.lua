RegisterServerEvent('pw_motels:server:triggerDoorLock')
AddEventHandler('pw_motels:server:triggerDoorLock', function(room)
    local _src = source

    if room then
        if motelRooms[room] then
            motelRooms[room].updateLock()
        end
    end

end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    PW.Print(data)
    if data.item == "screwdriver" then
        TriggerClientEvent('pw_motels:client:usedScrewdriver', _src, data)
    end
end)