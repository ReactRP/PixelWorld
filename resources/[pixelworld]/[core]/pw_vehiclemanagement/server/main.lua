AddEventHandler('pw:databaseCachesLoaded', function(caches)
    vehicles = {}
    --########################################################################################################################################################
    --[[
        Delete all the following that you do not need, if you dont need any of them, you can remove them all, and create your own starup method here
        This function will be called when two conditions are met, MySQL has been loaded and is ready, and the framework has loaded all required caches,
        This will also get triggered when ever a administrator runs the 'reloadcache' command in chat.
    ]]--
    --########################################################################################################################################################

    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles`", {}, function(vehsql)
        local total = 0
        for k, v in pairs(vehsql) do
            vehicles[v.vehicle_id] = registerVehicle(v.vehicle_id)
            total = total + 1
        end

        if total > 0 then
            print(' ^1[PixelWorld Vehicles] ^3- Owned Vehicles Database Loaded and Registered', '^4'..total..' Vehicles^7')
        end
    end)
end)

function tracePlate(plate)
    for k, v in pairs(vehicles) do
        if v.getCurrentPlate() == plate then
            return v.getOriginalPlate()
        end
    end
    return false
end

function getVID(plate)
    for k, v in pairs(vehicles) do
        if v.getCurrentPlate() == plate then
            return k
        end
    end
    return 0
end

function getVehicleByPlate(plate)
    for k, v in pairs(vehicles) do
        if v.getCurrentPlate() == plate then
            return v
        end
    end
    return false
end

exports('getVID', function(plate)
    return getVID(plate)
end)

exports('tracePlate', function(plate)
    return tracePlate(plate)
end)

PW.RegisterServerCallback('pw_vehiclemanagement:server:getVID', function(source, cb, plate)
    cb(getVID(plate))
end)

PW.RegisterServerCallback('pw_vehiclemanagement:server:tracePlace', function(source, cb, plate)
    cb(tracePlate(plate))
end)

function getVehicleByPlate(plate, cb)
    local vehicle = nil
    for k, v in pairs(vehicles) do
        if v.getOriginalPlate() == plate then
            vehicle = k
        end
    end

    if cb then
        if vehicle ~= nil then
            cb(vehicle)
        else
            cb(false) 
        end
    else
        if vehicle ~= nil then
            return vehicle
        else
            return false
        end
    end
end