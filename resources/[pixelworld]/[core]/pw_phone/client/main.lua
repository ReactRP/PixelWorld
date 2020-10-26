PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        SendNUIMessage({
            action = 'setup',
            data = {{name = 'settings', data = Config.Settings}},
        })
        SendNUIMessage({
            action = 'loadInitialSettings',
        })
    end
end)

function DrawUIText(text, font, centre, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x , y) 
end

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
                PW.TriggerServerCallback('pw_phone:server:setupData', function(dataply)
                    PW.TriggerServerCallback('pw_phone:server:retreiveContacts', function(contacts)
                        PW.TriggerServerCallback('pw_phone:server:twitterr:retreiveTweets', function(tweets)
                            PW.TriggerServerCallback('pw_phone:server:banking:getAccounts', function(banking)
                                PW.TriggerServerCallback('pw_phone:server:banking:retreiveTransfers', function(transfers)
                                    PW.TriggerServerCallback('pw_phone:server:yp:getAdverts', function(ads)
                                        PW.TriggerServerCallback('pw_phone:server:setupJob', function(job)
                                            PW.TriggerServerCallback('pw_phone:server:messages:receiveInitialMessages', function(messages)
                                                if settings ~= nil then
                                                    Config.Settings = settings
                                                end
                                                SendNUIMessage({
                                                    action = 'setup',
                                                    data = {{name = 'settings', data = (settings or Config.Settings)}},
                                                })
                                                SendNUIMessage({
                                                    action = 'loadInitialSettings',
                                                })
                                                SendNUIMessage({
                                                    action = 'setup',
                                                    data = {{ name = "job", data = job }}
                                                })
                                                SendNUIMessage({
                                                    action = 'setup',
                                                    data = dataply
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
                                                    data = {{ name = "adverts", data = (ads)}}
                                                })
                                                SendNUIMessage({
                                                    action = 'setup',
                                                    data = {{ name = "messages", data = (messages or {}) }}
                                                })
                                            end)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end
    else
        SendNUIMessage({
            action = 'logout',
        })
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