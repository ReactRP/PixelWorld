RegisterNetEvent('pw_phone:client:yp:ReceiveAd')
AddEventHandler('pw_phone:client:yp:ReceiveAd', function(advert)
    if characterLoaded and playerData then
        if advert.phone ~= playerData.phone then
            SendNUIMessage({
                action = 'ReceiveAd',
                advert = advert
            })
        end
    end
end)

RegisterNetEvent('pw_phone:client:yp:DeleteAd')
AddEventHandler('pw_phone:client:yp:DeleteAd', function(id)
    if characterLoaded and playerData then
        if id ~= playerData.cid then
            SendNUIMessage({
                action = 'DeleteAd',
                id = id
            })
        end
    end
end)

RegisterNUICallback('NewAd', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:yp:NewAd', cb, data)
end)

RegisterNUICallback('DeleteAd', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:yp:DeleteAd', cb, data)
end)