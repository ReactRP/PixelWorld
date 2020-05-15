phoneOpen = false
local counter = 0

function CalculateTimeToDisplay()
    hour = GetClockHours()
    minute = GetClockMinutes()
    
    local obj = {}
    
    if hour <= 9 then
        hour = "0" .. hour
    end
    
    if minute <= 9 then
        minute = "0" .. minute
    end
    
    obj.hour = hour
    obj.minute = minute

    return obj
end

Citizen.CreateThread(function()
    while true do
        if not phoneOpen and IsDisabledControlJustPressed(0, 288) then
            startPhone()
        end

        if counter <= 0 then
            local time = CalculateTimeToDisplay()
            SendNUIMessage({
                action = 'updateTime',
                time = time.hour .. ':' .. time.minute
            })
            counter = 50
        else
            counter = counter - 1
        end

        Citizen.Wait(1)
    end
end)

RegisterCommand('nuioff', function()
    SetNuiFocus(false, false)
end)

function startPhone()
    phoneOpen = true
    SetNuiFocus(phoneOpen, phoneOpen)
    SendNUIMessage( { action = 'SetServerID', id = GetPlayerServerId(PlayerId()) } )
    SendNUIMessage( { action = 'show' } )
end

RegisterNUICallback('ClosePhone', function(data, cb)
    phoneOpen = false
    SetNuiFocus(phoneOpen, phoneOpen)
end)

RegisterNUICallback('markRead', function(data, cb)
    if data and data.app then
        TriggerServerEvent('pw_phone:server:all:markRead', data.app)
    end
end)