onPhoneCall = false

RegisterNetEvent('pw_phone:client:loadData')
AddEventHandler('pw_phone:client:loadData', function(act, data)
    if act == "getNearbyPlayers" then
        data['players'] = PW.Game.GetNearbyPlayers(20.0)
        SendNUIMessage({
            status = "phonePopulation",
            sub = act,
            data = data
        })
    else
        SendNUIMessage({
            status = "phonePopulation",
            sub = act,
            data = data
        })
    end
end)

RegisterNUICallback("requestData", function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:retreiveMeta', function()
    end, data.request, true, data.number, data)
end)

RegisterNUICallback("silentMode", function(data, cb)
    phoneSilent = not phoneSilent
    exports.pw_notify:SendAlert('info', 'Silent Mode ' .. (phoneSilent and 'On' or 'Off'), 2500)
end)

RegisterNUICallback("sendSound", function(data, cb)
    if not phoneSilent then
        if data.sound == 'dialPad' then
            TriggerEvent('pw_sound:client:PlayOnOne', 'cell-phone-1-nr'.. data.number, 0.2)
        end
    end
end)

RegisterNUICallback("loseFocus", function(data, cb)
    SetNuiFocus(false, false)
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
end)

RegisterNUICallback("setWaypoint", function(data, cb)
    if data then
        if IsWaypointActive() then
            ClearGpsPlayerWaypoint()
        end
        local x = tonumber(data.x)
        local y = tonumber(data.y)
        SetNewWaypoint(x, y)
        exports['pw_notify']:SendAlert('success', 'Marker has been set on your map', 5000)
    else
        exports['pw_notify']:SendAlert('error', 'Failed to set Marker on map', 5000)
    end
end)

local awaitingAcceptCall = false
local awaitingSomeoneToAcceptCall = false

RegisterNetEvent('pw_phone:client:connectCall')
AddEventHandler('pw_phone:client:connectCall', function(callid, name, with)
    if callid == false then
        onPhoneCall = false
        PhonePlayCall()
        PhonePlayText()
        exports['pw_voip']:removePlayerFromCall()
        SendNUIMessage({
            status = "callEnded",
        }) 
    else
        awaitingAcceptCall = false
        awaitingSomeoneToAcceptCall = false
        PhonePlayCall()
        onPhoneCall = true
        exports['pw_voip']:addPlayerToCall(tonumber(callid))
        exports['pw_voip']:AddCallChannelName(tonumber(callid), with)
        SendNUIMessage({
            status = "callConnected",
            name = name,
            with = with,
        })   
    end
end)

RegisterNetEvent('pw_phone:client:ringPhone')
AddEventHandler('pw_phone:client:ringPhone', function(name, incoming, failed, reason, terminate, number)
    if incoming then
        print('receiving call event received client side?')
        SendNUIMessage({
            status = "receiving",
            name = name,
            incomming = incoming,
            failed = failed,
            reason = reason,
            terminate = terminate,
            mynumber = number,
        })
        print(terminate)
        if terminate == false then
            awaitingAcceptCall = true
            if not phoneSilent then
                StartRinger()
            end
        else
            awaitingAcceptCall = false
        end
    else
        SendNUIMessage({
            status = "makingCall",
            name = name,
            incomming = incoming,
            failed = failed,
            reason = reason,
            terminate = terminate
        })
        print(terminate)
        if terminate == false then
            awaitingSomeoneToAcceptCall = true
            if not phoneSilent then
                StartAwaitingCaller()
            end
        else
            awaitingSomeoneToAcceptCall = false
            if not phoneSilent then
                TriggerEvent('pw_sound:client:PlayOnOne', 'declinedcall', 0.2)
            end
        end
    end
end)

function StartRinger()
    while awaitingAcceptCall do
        TriggerServerEvent('pw_sound:server:PlayWithinDistance', 2.0, 'cellcall', 0.4)
        Citizen.Wait(2300)
    end
end

function StartAwaitingCaller()
    while awaitingSomeoneToAcceptCall do
        TriggerServerEvent('pw_sound:server:PlayWithinDistance', 2.0, 'calldialawaiting', 0.3)
        Citizen.Wait(2300)
    end
end

RegisterNUICallback("stopPhoneDialingSound", function(data, cb)
    awaitingSomeoneToAcceptCall = false
    Citizen.Wait(1000)
    TriggerEvent('pw_sound:client:PlayOnOne', 'declinedcall', 0.2)
end)

Citizen.CreateThread(function()
    local pauseActive = false
    while true do
        if IsPauseMenuActive() then
            if not pauseActive then
                SendNUIMessage({
                    status = "hideHud",
                })
            pauseActive = true
            end
        else
            if pauseActive then
                SendNUIMessage({
                    status = "showHud",
                })
            pauseActive = false
            end
        end
        Citizen.Wait(1)
    end
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end

RegisterNUICallback("setRadioChannel", function(data, cb)
    if data then
        if data.toggle then
            if radioItemIdent ~= nil then
                TriggerServerEvent('pw_phone:server:setRadioChannel', radioItemIdent, data.channel)
                exports['pw_voip']:SetRadioFrequency(tonumber(data.channel))
            end
        else
            exports['pw_voip']:TurnRadioOff()
        end
    end
end)

RegisterNUICallback("toggleRadioClicks", function(data, cb)
    if data then
        exports.pw_notify:SendAlert('inform', 'Mic Clicks '.. (data.toggle and 'Enabled' or 'Disabled'), 2000)
        exports['pw_voip']:SetMumbleProperty("micClicks", data.toggle)
    end
end)

RegisterNUICallback("sendData", function(data, cb)
    if data.request == "removeSim" then
        phoneNumber = nil
    end
    if data.request == "loadSim" then
        phoneNumber = tonumber(data.number)
    end
    TriggerServerEvent('pw_phone:server:sendData', data)
end)

RegisterNUICallback("addContact", function(data, cb)
    TriggerServerEvent('pw_phone:server:addContact', data)
end)