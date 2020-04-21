RegisterNetEvent('pw_keynote:client:triggerShowable')
AddEventHandler('pw_keynote:client:triggerShowable', function(show, items)
    if show then
        if items then
            SendNUIMessage({
                action = 'showUsableBar',
                items = items
            })
        end
    else
        SendNUIMessage({
            action = 'hideUsableBar',
        })
    end
end)