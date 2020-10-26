AddEventHandler('pw:databaseCachesLoaded', function(caches)
    vehicles = {}
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles`", {}, function(vehsql)
        local total = 0
        for k, v in pairs(vehsql) do
            vehicles[v.vehicle_id] = registerVehicle(v.vehicle_id)
            total = total + 1
        end

        if total > 0 then
            print(' ^1[SynCity Vehicles] ^3- Owned Vehicles Database Loaded and Registered', '^4'..total..' Vehicles^7')
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

function getVehicleByPlate(plate, cb)
    local vehicle = nil
    for k, v in pairs(vehicles) do
        if v.getOriginalPlate() == plate then
            vehicle = k
            break
        end
    end

    if cb then
        cb(vehicle or false)
    else
        return (vehicle or false)
    end
end

function getAll()
    return vehicles
end

exports('getVehicleByPlate', function(plate)
    return getVehicleByPlate(plate)
end)

exports('getAllVehicles', function()
    return getAll()
end)

exports('getVehicleByVID', function(id)
    local vid = tonumber(id)
    return vehicles[vid]
end)

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

PW.RegisterServerCallback('pw_vehiclemanagement:server:getMeta', function(source, cb, vid)
    cb(vehicles[vid].GetMeta('business'))
end)