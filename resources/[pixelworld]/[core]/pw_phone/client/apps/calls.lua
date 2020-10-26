Call = {}
local isLoggedIn = false

local Ringtones = {
    { name = 'Default', duration = 2000, file = 'ringtone1' },
    { name = 'Memes', duration = 20000, file = 'ringtone2' },
}

function IsInCall()
    return (Call.number ~= nil and Call.status == 1) or (Call.number ~= nil and Call.status == 0 and Call.initiator)
end

RegisterNetEvent('pw_phone:client:calls:CreateCall')
AddEventHandler('pw_phone:client:calls:CreateCall', function(number)
    Call.number = number
    Call.status = 0
    Call.initiator = true

    PhonePlayCall(false)

    Citizen.CreateThread(function()
        while Call.status == 0 do
            TriggerServerEvent('pw_sound:server:PlayOnSource', 'dialtone', 0.1)
            Citizen.Wait(100)
        end
    end)

    local count = 0
    Citizen.CreateThread(function()
        while Call.status == 0 do
            if count >= 30 then
                TriggerServerEvent('pw_phone:server:calls:EndCall')
                TriggerEvent('pw_sound:client:StopOnOne', 'dialtone')

                if isPhoneOpen then
                    PhoneCallToText()
                else
                    PhonePlayOut()
                end

                Call = {}
            else
                count = count + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent('pw_phone:client:calls:AcceptCall')
AddEventHandler('pw_phone:client:calls:AcceptCall', function(channel, initiator)
    if Call.number ~= nil and Call.status == 0 then
        Call.status = 1
        Call.channel = channel
        Call.initiator = initiator
        exports['pw_voip']:addPlayerToCall(Call.channel)
        --exports['tokovoip_script']:addPlayerToRadio(Call.channel, false)

        if initiator then
            SendNUIMessage({
                action = 'acceptCallSender',
                number = Call.number
            })
            exports['pw_notify']:PersistentAlert('start', 'active-call', 'inform', 'You\'re In A Call', { ['background-color'] = '#ff8555', ['color'] = '#ffffff' })
        else
            exports['pw_notify']:PersistentAlert('end', Config.IncomingNotifId)
            exports['pw_notify']:PersistentAlert('start', 'active-call', 'inform', 'You\'re In A Call', { ['background-color'] = '#ff8555', ['color'] = '#ffffff' })
            PhonePlayCall(false)
            SendNUIMessage({
                action = 'acceptCallReceiver',
                number = Call.number
            })
        end

        TriggerEvent('pw_sound:client:StopOnOne', 'dialtone')
        TriggerServerEvent('pw_sound:server:StopWithinDistance', 'ringtone'..Config.Settings.ringtone)
    end
end)

RegisterNetEvent('pw_phone:client:calls:EndCall')
AddEventHandler('pw_phone:client:calls:EndCall', function()
    SendNUIMessage({
        action = 'endCall'
    })

    TriggerEvent('pw_sound:client:StopOnOne', 'dialtone')
    TriggerServerEvent('pw_sound:server:StopWithinDistance', 'ringtone'..Config.Settings.ringtone)
    exports['pw_notify']:SendAlert('inform', 'Call Ended', 2500, { ['background-color'] = '#ff8555', ['color'] = '#ffffff' })
    exports['pw_notify']:PersistentAlert('end', Config.IncomingNotifId)
    exports['pw_notify']:PersistentAlert('end', 'active-call')
    --exports['tokovoip_script']:removePlayerFromRadio(Call.channel)
    exports['pw_voip']:removePlayerFromCall()

    Call = {}

    if isPhoneOpen then
        PhoneCallToText()
    else
        PhonePlayOut()
    end
end)

RegisterNetEvent('pw_phone:client:calls:ReceiveCall')
AddEventHandler('pw_phone:client:calls:ReceiveCall', function(number)
    Call.number = number
    Call.status = 0
    Call.initiator = false

    SendNUIMessage({
        action = 'receiveCall',
        number = number
    })

    Citizen.CreateThread(function()
        while Call.status == 0 do
            TriggerServerEvent('pw_sound:server:PlayWithinDistance', 10.0, 'ringtone'..Config.Settings.ringtone, 0.1 * (Config.Settings.volume / 100))

            Citizen.Wait(500)
        end
    end)

    local count = 0
    Citizen.CreateThread(function()
        while Call.status == 0 do
            if count >= 30 then
                TriggerServerEvent('pw_sound:server:StopWithinDistance', 'ringtone'..Config.Settings.ringtone)
                TriggerServerEvent('pw_phone:server:calls:EndCall')
                Call = {}
            else
                count = count + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent('pw_phone:client:calls:OtherToggleHold')
AddEventHandler('pw_phone:client:calls:OtherToggleHold', function(number)
    if Call.number ~= nil and Call.status ~= 0 then
        Call.OtherHold = not Call.OtherHold
    end
end)

RegisterNUICallback('CreateCall', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:calls:CreateCall', cb, { number = data.number, nonStandard = data.nonStandard })
end)

RegisterNUICallback('AcceptCall', function(data, cb)
    TriggerServerEvent('pw_phone:server:calls:AcceptCall')
end)

RegisterNUICallback('EndCall', function(data, cb)
    TriggerServerEvent('pw_phone:server:calls:EndCall', Call)
end)

RegisterNUICallback('ToggleHold', function( data, cb )
    if Call.number ~= nil and Call.number ~= 0 then
        Call.Hold = not Call.Hold
        TriggerServerEvent('pw_phone:server:calls:ToggleHold', Call)
        if Call.Hold then
            --exports['tokovoip_script']:removePlayerFromRadio(Call.channel)
            exports['pw_voip']:removePlayerFromCall()
            if isPhoneOpen then
                PhoneCallToText()
            else
                PhonePlayOut()
            end
        else
            exports['pw_voip']:addPlayerToCall(Call.channel)
            --exports['tokovoip_script']:addPlayerToRadio(Call.channel, false)
            PhonePlayCall(false)
        end

        cb(Call.Hold)
    end
end)

RegisterNUICallback('DeleteCallRecord', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:calls:DeleteCallRecord', cb, { id = data.id })
end)

local PlayerDied = false

RegisterNetEvent('pw:playerDied')
AddEventHandler('pw:playerDied', function()
    PlayerDied = true
end)

RegisterNetEvent('pw:playerRevived')
AddEventHandler('pw:playerRevived', function()
    PlayerDied = false
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            isLoggedIn = true
            Citizen.CreateThread(function()
                while isLoggedIn do
                    if IsInCall() and Call ~= nil and Call.status ~= 0 then
                        if IsControlJustReleased(1, 51) then
                            Call.Hold = not Call.Hold
                            TriggerServerEvent('pw_phone:server:calls:ToggleHold', Call)
                            if Call.Hold then
                                exports['pw_voip']:removePlayerFromCall()
                                --exports['tokovoip_script']:removePlayerFromRadio(Call.channel)
                                if isPhoneOpen then
                                    PhoneCallToText()
                                else
                                    PhonePlayOut()
                                end
                            else
                                exports['pw_voip']:addPlayerToCall(Call.channel)
                                --exports['tokovoip_script']:addPlayerToRadio(Call.channel, false)
                                PhonePlayCall(false)
                            end
                        elseif IsControlJustReleased(1, 47) and not Call.Hold then
                            TriggerServerEvent('pw_phone:server:calls:EndCall', Call)
                        end
            
                        if PlayerDied then
                            TriggerServerEvent('pw_phone:server:calls:EndCall', Call)
                        end
            
                        Citizen.Wait(1)
                    else
                        Citizen.Wait(1000)
                    end
                end
            end)
            
            Citizen.CreateThread(function()
                while isLoggedIn do
                    if IsInCall() and Call ~= nil and Call.status ~= 0 then
                        if not Call.OtherHold then
                            if not Call.Hold then
                                DrawUIText("~r~[E] ~s~Hold ~r~| [G] ~s~Hangup", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                            else
                                DrawUIText("~r~[E] ~s~Resume ~r~| [G] ~s~Hangup", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                            end
                        else
                            if not Call.Hold then
                                DrawUIText("~r~[E] ~s~Hold ~r~| [G] ~s~Hangup ~r~| ~s~On Hold", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                            else
                                DrawUIText("~r~[E] ~s~Resume ~r~| [G] ~s~Hangup ~r~| ~s~On Hold", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                            end
                        end
                        Citizen.Wait(1)
                    else
                        Citizen.Wait(1000)
                    end
                end
            end)
        end
    else
        isLoggedIn = false
    end
end)