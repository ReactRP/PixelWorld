PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            characterLoaded = true
        else
            playerData = data
            PW.TriggerServerCallback('pw_phone:server:retreiveSettings', function(settings)
                PW.TriggerServerCallback('pw_phone:server:setupData', function(data)
                    PW.TriggerServerCallback('pw_phone:server:retreiveContacts', function(contacts)
                        PW.TriggerServerCallback('pw_phone:server:twitterr:retreiveTweets', function(tweets)
                            PW.TriggerServerCallback('pw_phone:server:banking:getAccounts', function(banking)
                                PW.TriggerServerCallback('pw_phone:server:banking:retreiveTransfers', function(transfers)
                                    PW.TriggerServerCallback('pw_phone:server:yp:getAdverts', function(ads)
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = {{name = 'settings', data = (settings or Config.Settings)}},
                                        })
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = data
                                        })
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = { (contacts or {}) }
                                        })
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = {{ name = "tweets", data = (tweets or {}) }}
                                        })
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = {{ name = "banking", data = (banking or {}) }}
                                        })
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = {{ name = "bank-transfers", data = (transfers or {}) }}
                                        })
                                        SendNUIMessage({
                                            action = 'setup',
                                            data = {{ name = "adverts", data = (ads or {}) }}
                                        })
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end
    else
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(500)
        if characterLoaded then
            local playerPed = PlayerPedId()
            if playerPed ~= GLOBAL_PED then
                GLOBAL_PED = playerPed
            end
        end
    end
end)

function GetAppData(app)
    local appl = nil
    local done = false
    PW.TriggerServerCallback('pw_phone:server:all:getAppData', function(v)
        appl = v
        done = true
    end, app)
    repeat Wait(0) until done == true
    return appl
end

function SetAppData(app)
    --for k, v in pairs(Config.DefaultApps) do
    --    if v.container == app.container then
    --        v = app
    --    end
    --end
end

function UpdateAppUnread(app, unread)
    PW.TriggerServerCallback('pw_phone:server:all:updateUnread', function(meh)
        if meh then
            print('updated?')
            SendNUIMessage({
                action = 'updateUnread',
                app = app,
                unread = unread
            })
        
            if not phoneOpen then
                SendNUIMessage({
                    action = 'AddClosedAlert',
                    app = app
                })
            end
        end
    end, app, unread)
end

RegisterNetEvent('pw_phone:client:updateSettings')
AddEventHandler('pw_phone:client:updateSettings', function(key, data)
    SendNUIMessage({
        action = 'setup',
        data = {{name = key, data = data}}
    })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)