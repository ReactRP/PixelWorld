PW = nil
playerData, playerLoaded = nil, false
phoneStart = false
radioOpen = false
gamePlaying = false
gameResult = false
radioItemIdent = nil
phoneSilent = false

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
	end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            playerLoaded = true
			GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            phoneStart = true
            SendNUIMessage({
                status = "setJob",
                job = playerData.job.name,
                duty = playerData.job.duty,
            })
            PW.TriggerServerCallback('pw_phone:server:requestActiveNumber', function(num)
                if num ~= nil then
                    phoneNumber = num

                    PW.TriggerServerCallback('pw_phone:server:checkUnreadMessages', function(unread)
                        if unread > 0 then
                            notificationNui("textMessages", true)
                        end
                    end, phoneNumber)
                end

                Citizen.CreateThread(function()
                    SendNUIMessage({
                        status = "showHud",
                    })
                    while phoneStart do
                        if IsControlJustPressed(0, 288) then
                            if IsControlPressed(0, 21) then
                                if radioItemIdent ~= nil then
                                    SendNUIMessage({
                                        status = "closePhone",
                                    })
                                    openRadioControl()
                                end
                            else
                                SendNUIMessage({
                                    status = "closeRadio",
                                })
                                openPhoneControl()
                            end
                        end
                        Citizen.Wait(1)
                    end
                end)
            end)
        else
			playerData = data
        end
    else
        playerData = nil
		playerLoaded = false
		phoneStart = false
        SendNUIMessage({
            status = "hideHud",
        })
        deletePhone()
    end
end)

function gameTest()
    TriggerEvent('pw_phone:games:startNumberGame', {}, function(success)
        if success then
            print('passed')
        else
            print('failed')
        end
    end)
end

RegisterNUICallback("gameResult", function(data, cb)
    SetNuiFocus(false, false)
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    SendNUIMessage({
        status = "phoneGame",
        action = "end"
    })
    gameResult = data.result
    gamePlaying = false
end)

RegisterNetEvent('pw_phone:games:startNumberGame')
AddEventHandler('pw_phone:games:startNumberGame', function(options, cb)
    if options ~= nil and type(options) == "table" then
        options.tries = options.tries or 50
        options.failures = options.failures or 10
        options.duration = options.duration or 5000
        options.time = options.time or 2000
    else
        options = {}
        options.tries = 50
        options.failures = 10
        options.duration = 5000
        options.time = 2000
    end

    if not gamePlaying then
        gamePlaying = true
        gameResult = false
        SetNuiFocus(true, true)
        TriggerEvent('pw_voip:client:onlyAllowPTTOn')
        SendNUIMessage({
            status = "phoneGame",
            action = "start",
            tries = options.tries,
            failures = options.failures,
            duration = options.duration,
            time = options.time
        })
        Citizen.CreateThread(function()
            while true do
                    repeat Wait(0) until gamePlaying == false
                    cb(gameResult)
                break
                Citizen.Wait(0)
            end
        end)
    end
end)

--[[
Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            gameTest()
        end
        Citizen.Wait(1)
    end
end)]]

Citizen.CreateThread(function()
    while true do
        if playerLoaded then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerHeading = GetEntityHeading(playerPed)
            local coords = { ['x'] = playerCoords.x, ['y'] = playerCoords.y, ['z'] = playerCoords.z, ['h'] = playerHeading}
            SendNUIMessage({
                status = "playerCoords",
                coords = coords
            })
        end
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(data)
    if playerLoaded and playerData then
        playerData.job = data
        SendNUIMessage({
            status = "setJob",
            job = playerData.job.name,
            duty = playerData.job.duty,
        })
    end    
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if playerLoaded and playerData then
        playerData.job.duty = toggle
        SendNUIMessage({
            status = "setJob",
            job = playerData.job.name,
            duty = playerData.job.duty,
        })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded and playerData then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded and playerData and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)



RegisterNetEvent('pw_phone:client:activeRace')
AddEventHandler('pw_phone:client:activeRace', function(state)
    SendNUIMessage({
        status = "raceActive",
        raceState = state
    })
end)

RegisterNetEvent('pw_phone:client:activeContestants')
AddEventHandler('pw_phone:client:activeContestants', function(status)
    SendNUIMessage({
        status = "toggleContestants",
        state = status
    })
end)

function openRadioControl()
    if not checking then
        checking = true
        PW.TriggerServerCallback('pw_phone:server:openRadio', function(haveone)
            if haveone then
                SetNuiFocus(true, true)
                TriggerEvent('pw_voip:client:onlyAllowPTTOn')
                SendNUIMessage({
                    status = "openRadio",
                })
                RadioPlayIn() 
                checking = false
            else
                exports['pw_notify']:SendAlert("warning", "You do not have a Radio on you.", 5000)
                checking = false
            end
        end)
    end
end

function openPhoneControl()
    if not checking then
        checking = true
        PW.TriggerServerCallback('pw_phone:server:openPhone', function(simactive, number)
            if simactive then
                SetNuiFocus(true, true)
                TriggerEvent('pw_voip:client:onlyAllowPTTOn')
                SendNUIMessage({
                    status = "openPhone",
                    simcard = simactive,
                    activenumber = number
                })
                PhonePlayIn()
            else
                if number == "nosim" then
                    SetNuiFocus(true, true)
                    TriggerEvent('pw_voip:client:onlyAllowPTTOn')
                    SendNUIMessage({
                        status = "openPhone",
                        simcard = simactive,
                        activenumber = nil
                    })
                    PhonePlayIn()
                else
                    exports['pw_notify']:SendAlert("warning", "You do not own a Mobile Phone", 5000)
                end
            end
            checking = false
        end)
    end
end

function updateClock()
    local curHour = GetClockHours()
    local curMinute = GetClockMinutes()
    local hour, minute
    if curHour < 10 then
        hour = '0'..curHour
    else
        hour = curHour
    end
    if curMinute < 10 then
        minute = '0'..curMinute
    else
        minute = curMinute
    end
    local time = hour..':'..minute
    SendNUIMessage({
        status = "updateClock",
        time = time
    })
end

RegisterNetEvent('pw_voip:client:updateNUI')
AddEventHandler('pw_voip:client:updateNUI', function(action, message)
    if action == "primary" then
        SendNUIMessage({
            status = "updateVoice",
            mes = message
        })
    elseif action == "secondary" then
        if message == false then
            SendNUIMessage({
                status = "updateVoice2",
                show = false
            })
        else
            SendNUIMessage({
                status = "updateVoice2",
                mes = message,
                show = true
            })
        end
    elseif action == "level" then
        SendNUIMessage({
            status = "updateLevel",
            level = message
        })
    end
end) 

RegisterNetEvent('pw_phone:client:doPhoneActionFromCommand')
AddEventHandler('pw_phone:client:doPhoneActionFromCommand', function(action)
    TriggerServerEvent('pw_phone:server:doPhoneActionFromCommand', action, phoneNumber)
end)

RegisterNUICallback("closePhone", function(data, cb)
    SetNuiFocus(false, false)
    TriggerEvent('pw_voip:client:onlyAllowPTTOff')
    if not onPhoneCall then
        PhonePlayOut()
    end
end)

Citizen.CreateThread(function()
    while true do
        updateClock()
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        if playerLoaded and phoneNumber ~= nil then
            TriggerServerEvent('pw_phone:server:updateGPS', phoneNumber, GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z)
        end
    end
end)

RegisterNetEvent('pw_phone:client:usedRadioItem') 
AddEventHandler('pw_phone:client:usedRadioItem', function(data)
    if radioItemIdent ~= data.record_id then
        exports['pw_voip']:TurnRadioOff()
    end
    radioItemIdent = data.record_id
    SendNUIMessage({
        status = "closePhone",
    })
    openRadioControl()
    if data.metapublic ~= nil then
        local meta = data.metapublic
        if meta.channel ~= nil and meta.channel ~= 0 then
            exports['pw_voip']:SetRadioFrequency(tonumber(meta.channel))
        end
    end
end)

RegisterNetEvent('pw_phone:client:dropRadio')
AddEventHandler('pw_phone:client:dropRadio', function(radioIdentRemove)
    if radioIdentRemove == radioItemIdent then
        radioItemIdent = nil
        exports['pw_voip']:TurnRadioOff()
    end
end)

RegisterNetEvent('pw_phone:client:usePayPhone')
AddEventHandler('pw_phone:client:usePayPhone', function(targetNumber)
    print('Target PayPhone Num', targetNumber)
    if playerLoaded and targetNumber > 0 then
        local found = false
        for k, v in pairs(Config.PayPhones) do
            local payPhone = IsObjectNearPoint(v, GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, 1.8)
            if payPhone then 
                print('Use Payphone')
                TriggerServerEvent('pw_phone:server:startPayPhoneCall', targetNumber)
                found = true
            end
        end
        if not found then
            exports.pw_notify:SendAlert('error', 'No Payphone Nearby', 2500)
        end
    end
end)    