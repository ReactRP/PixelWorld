local Advertisements = {}

function CreateAd(adData)
    Advertisements[adData.id] = adData
    TriggerClientEvent('pw_phone:client:updateSettings', -1, "adverts", Advertisements)
    TriggerClientEvent('pw_phone:client:newYPAd', -1, adData.id)
    return Advertisements[adData.id] ~= nil
end

function DeleteAd(_charid)
    if _charid ~= nil then
        Advertisements[_charid] = nil
        TriggerClientEvent('pw_phone:client:updateSettings', -1, "adverts", Advertisements)
        TriggerClientEvent('pw_phone:client:newYPAd', -1, _charid)
        return true
    else
        return false
    end
end

RegisterServerEvent('pw:switchCharacter')
AddEventHandler('pw:switchCharacter', function()
    local _src = source
    local _charid = exports['pw_core']:getCharacter(_src).getCID()
    DeleteAd(_charid)
end)

AddEventHandler('playerDropped', function()
    local _src = source
    local _charid = exports['pw_core']:getCharacter(_src).getCID()
    DeleteAd(_charid)
end)

PW.RegisterServerCallback('pw_phone:server:yp:getAdverts', function(source, cb)
    cb(Advertisements)
end)

PW.RegisterServerCallback('pw_phone:server:yp:DeleteAd', function(source, cb, data)
    local _src = source
    local _charid = exports['pw_core']:getCharacter(_src).getCID()
    cb(DeleteAd(_charid))
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