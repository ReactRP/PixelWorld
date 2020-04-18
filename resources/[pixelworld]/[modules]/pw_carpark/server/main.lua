PW = nil
authed = false
Parks = {}

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    Parks = Config.Parks
end)

RegisterServerEvent('pw_carpark:server:retrievalDone')
AddEventHandler('pw_carpark:server:retrievalDone', function(park, data, baseCoords)
    TriggerClientEvent('pw_carpark:client:retrievalDone', -1, park, data, baseCoords)
end)

RegisterServerEvent('pw_carpark:server:parkVeh')
AddEventHandler('pw_carpark:server:parkVeh', function(park, props, dmg)
    local _src = source
    if not Parks[park].parking then
        Parks[park].parking = _src
        TriggerClientEvent('pw_carpark:client:setParkState', -1, park, 'parking', _src)
        TriggerClientEvent('pw_carpark:client:parkVeh', -1, park, props, dmg)
        TriggerEvent('pw_garage:server:storeVehicle', 'Auto', props, park, dmg)
    end
end)

RegisterServerEvent('pw_carpark:server:setParkState')
AddEventHandler('pw_carpark:server:setParkState', function(park, var, state)
    Parks[park][var] = state
    TriggerClientEvent('pw_carpark:client:setParkState', -1, park, var, state)
end)

RegisterServerEvent('pw_carpark:server:retrieveVehicle')
AddEventHandler('pw_carpark:server:retrieveVehicle', function(park, props, ins, dmg)
    local _src = source
    
    TriggerEvent('pw_carpark:server:setParkState', park, 'parking', _src)
    TriggerClientEvent('pw_carpark:client:retrieveVehicle', -1, park, props, _src, ins, dmg)
end)

PW.RegisterServerCallback('pw_carpark:server:getParkStates', function(source, cb)
    cb(Parks)
end)