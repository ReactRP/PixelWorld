local Advertisements = {}

function CreateAd(adData)
    Advertisements[adData.id] = adData
    TriggerClientEvent('pw_phone:client:updateSettings', -1, "adverts", Advertisements)
    TriggerClientEvent('pw_phone:client:newYPAd', -1, Advertisements[adData.id])
    return Advertisements[adData.id] ~= nil
end

function DeleteAd(source)
    local char = exports['pw_core']:getCharacter(source)
    if char ~= nil then
            local id = char.getCID()
            Advertisements[id] = nil
            TriggerClientEvent('pw_phone:client:updateSettings', -1, "adverts", Advertisements)
            TriggerClientEvent('pw_phone:client:newYPAd', -1, Advertisements[id])
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
        id = char.getCID(),
        author = char.getFullName(),
        number = char:Phone().getNumber(),
        date = data.date,
        title = data.title,
        message = data.message
    }))
end)