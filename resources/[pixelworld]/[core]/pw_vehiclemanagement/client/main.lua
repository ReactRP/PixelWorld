PW = nil
playerLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        playerLoaded = false
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

exports('tracePlate', function(plate1)
    local rtplate = nil
    PW.Execute('pw_vehiclemanagement:server:tracePlate', function(plate)
        rtplate = plate
    end, plate1)
    repeat Wait(0) until rtplate ~= nil
    return rtplate
end)

exports('getVID', function(plate1)
    local rtvid = nil
    PW.Execute('pw_vehiclemanagement:server:getVID', function(vid)
        rtvid = vid
    end, plate1)
    repeat Wait(0) until rtvid ~= nil
    return rtvid
end)