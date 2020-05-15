local Advertisements = {}

function CreateAd(adData)
    Advertisements[adData.id] = adData
    TriggerClientEvent('pw_phone:client:updateSettings', -1, "adverts", Advertisements)
    return Advertisements[adData.id] ~= nil
end

function DeleteAd(source)
    if Advertisements[source] then
        Advertisements[source] = nil
        TriggerClientEvent('pw_phone:client:updateSettings', -1, "adverts", Advertisements)
        return true
    else
        return false
    end  
end

RegisterServerEvent('pw:switchCharacter')
AddEventHandler('pw:switchCharacter', function()
    DeleteAd(source)
end)

AddEventHandler('playerDropped', function()
    DeleteAd(source)
end)

PW.RegisterServerCallback('pw_phone:server:yp:getAdverts', function(source, cb)
    cb(Advertisements)
end)

PW.RegisterServerCallback('pw_phone:server:yp:DeleteAd', function(source, cb, data)
    cb(DeleteAd(source))
end)

PW.RegisterServerCallback('pw_phone:server:yp:NewAd', function(source, cb, data)
    local char = exports['pw_core']:getCharacter(source)
    cb(CreateAd({
        id = source,
        author = char.getFullName(),
        number = char:Phone().getNumber(),
        date = data.date,
        title = data.title,
        message = data.message
    }))
end)