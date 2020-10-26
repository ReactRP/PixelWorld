
local playerIDsActive = false

RegisterNetEvent('pw_core:client:openPlayerListing') -- F9 Key (see admin.lua)
AddEventHandler('pw_core:client:openPlayerListing', function()
    if playerLoaded then
        local playerList = {}
        local recentDisconnectsList = {}
        PW.TriggerServerCallback('pw_core:server:admin:getActiveCharacters', function(activeChars, recentPlayerDisconnects)
            local mySource = GetPlayerServerId(PlayerId())
            for k,v in pairs(recentPlayerDisconnects) do 
                if not v.cleared and v.source ~= mySource then
                    table.insert(recentDisconnectsList, {['label'] = ("["..v.source.."] "..v.steam .. " ["..v.name.."]"), ['action'] = "", ['triggertype'] = "client"})
                end
            end

            table.insert(playerList, { ['label'] = (playerIDsActive and "Disable ID Overlay" or "Enable Temporary ID Overlay"), ['action'] = "pw_core:client:togglePlayerHeadIDs", ['triggertype'] = "client", ['color'] = (playerIDsActive and "danger" or "success"), ['value'] = { ['toggle'] = (not playerIDsActive), ['activeChars'] = activeChars}})
            table.insert(playerList, { ['label'] = "Recent Disconnects", ['action'] = "", ['triggertype'] = "client", ['color'] = "info", ['subMenu'] = recentDisconnectsList}) 

            for t,q in pairs(activeChars) do 
                if q.source ~= mySource then
                    table.insert(playerList, {['label'] = "["..q.source.."] ".. q.steam, ['action'] = "", ['triggertype'] = "client", ['value'] = q.source, ['color'] = "info disabled"})
                else
                    table.insert(playerList, {['label'] = "<strong>[You] ["..q.source.."] ".. q.steam .. "</strong>", ['action'] = "", ['triggertype'] = "client", ['value'] = q.source, ['color'] = "info disabled"})
                end
            end

            TriggerEvent('pw_interact:generateMenu', playerList, "Active Character List")
        end)
    end
end)


RegisterNetEvent('pw_core:client:togglePlayerHeadIDs')
AddEventHandler('pw_core:client:togglePlayerHeadIDs', function(data)
    if data.toggle then
        playerIDsActive = true
        startDrawingHeadIDs(data.activeChars)

        Citizen.SetTimeout(60000, function() -- Turn IDs Back Off After 1 Min
            playerIDsActive = false
        end)
    else
        playerIDsActive = false
    end
end)


function startDrawingHeadIDs(activeChars)
    Citizen.CreateThread(function()
        while playerIDsActive and playerLoaded do
            local myPlayerPed = PlayerPedId()
            local myPlayerPedCoords = GetEntityCoords(myPlayerPed)
            for k,v in pairs(activeChars) do
                local playersID = GetPlayerFromServerId(v.source)
                local playersPed = GetPlayerPed(playersID)
                if playersPed ~= nil and (playersPed ~= myPlayerPed) then
                    local playersPedCoords = GetEntityCoords(playersPed)
                    local dist = #(myPlayerPedCoords - playersPedCoords)
                    if dist < 12.0 then
                        DrawPlayerHeadText(playersPedCoords.x, playersPedCoords.y, (playersPedCoords.z + 1.0), v.source) 
                    end
                end
            end
            Citizen.Wait(5)
        end
    end)
end

function DrawPlayerHeadText(x, y, z, text) 
    local onScreen, screenX , screenY = World3dToScreen2d(x, y, z)
    local gameCamCoords = GetGameplayCamCoords()
    local dist = #(gameCamCoords - vector3(x, y, z))
    local scale = ((1 / dist) * 2)
    local fov = ((1 / GetGameplayCamFov()) * 100)
    local scale = (scale * fov)
    if onScreen then
        SetTextScale((0.0 * scale), (0.55 * scale))
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(51, 153, 255, 155)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end