PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
motelComplexes, motelBlips, motelRooms, beingRobbed = {}, {}, {}, {}
local motelsLoaded = false
local showing, showingMarker = false, false
local setInventory = false

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
            showMotelRoomStuffShit()
        else
            playerData = data
            PW.TriggerServerCallback('pw_motels:server:receiveComplexes', function(complexes, rooms)
                motelComplexes = complexes
                motelRooms = rooms
                doBlips(complexes)
                motelsLoaded = true
                PW.Print(motelRooms[1])
            end)
        end
    else
        removeBlips()
        playerData = nil
        characterLoaded = false
    end
end)

RegisterNetEvent('pw_motels:client:updateRoom')
AddEventHandler('pw_motels:client:updateRoom', function(rid, data)
    repeat Wait(0) until motelsLoaded == true
    if motelRooms[rid] then 
        motelRooms[rid] = data
        if showing and tonumber(string.match(showing, "%d+")) == tonumber(rid) then showing = false; end
    end
end)

function doBlips(comp)
    for k, v in pairs(comp) do
        motelBlips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(motelBlips[k], 475)
        SetBlipDisplay(motelBlips[k], 4)
        SetBlipScale  (motelBlips[k], 0.8)
        SetBlipColour (motelBlips[k], 8)
        SetBlipAsShortRange(motelBlips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(motelBlips[k])
    end
end

function removeBlips()
    for k, v in pairs(motelBlips) do 
        RemoveBlip(v)
    end
    motelBlips = {}
    motelComplexes = {}
    motelRooms = {}
    motelsLoaded = false
    if showing then showing = false; end
end

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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

function doPlayerTeleport(room, action)
    if motelRooms[room] then
        local motelReq = motelRooms[room]
        local gotoCoords
        if action == "exit" then
            gotoCoords = motelReq.teleport_meta.entrance
        else
            gotoCoords = motelReq.teleport_meta.exit
        end
        
        DoScreenFadeOut(1000)
        Citizen.Wait(1001)
        SetEntityCoords(GLOBAL_PED, gotoCoords.x, gotoCoords.y, gotoCoords.z, 0, 0, 0, false)
        Citizen.Wait(1000)
        DoScreenFadeIn(1001)
        showing = false
    end
end

function showKeys(k, v, motel)
    local showable = {}
    if v == "weapons" or v == "items" then
        if v == "weapons" then
            table.insert(showable, {['type'] = "key", ['key'] = "e", ['action'] = "Weapons Stash"})
        elseif v == "items" then
            table.insert(showable, {['type'] = "key", ['key'] = "e", ['action'] = "Motel Storage"})
            table.insert(showable, {['type'] = "key", ['key'] = "f", ['action'] = "Switch Character"})
        end
        setInventory = true
        TriggerEvent('pw_inventory:client:setupThird', (v == "weapons" and 8 or 9), playerData.cid, motel.motel_name..' Room '..motel.room_number)
    elseif v == "clothing" then
        table.insert(showable, {['type'] = "key", ['key'] = "e", ['action'] = "Wardrobe"})
    end

    if #showable > 0 then
        TriggerServerEvent('pw_keynote:server:triggerShowable', true, showable)
    end

    Citizen.CreateThread(function()
        while showing == k..v and characterLoaded do
            if v == "items" then
                if IsControlJustPressed(0, 75) then
                    TriggerEvent('pw:switchCharacter')
                end
            elseif v == "exit" or v == "entrance" then
                if IsControlJustPressed(0, 38) and not motel.locked then
                    doPlayerTeleport(k, v)
                end

                if IsControlJustPressed(0, 182) and motel.occupierCID == playerData.cid then
                    TriggerServerEvent('pw_motels:server:triggerDoorLock', k)
                end
            elseif v == "clothing" then
                if IsControlJustPressed(0, 38) then
                    TriggerEvent('pw_character:client:openOutfitManagement')
                end
            end
            Citizen.Wait(1)
        end
    end)
end

function DrawGayMarker(v, type, var)
    print('drawing?', type)
    Citizen.CreateThread(function()
        while showingMarker == var do
            Citizen.Wait(1)
            if type == 'mainEntrance' then
                DrawMarker(25, v.x, v.y, v.z - 0.99, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 0, 255, 0, 250, false, false, 2, false, false, false, false)
            elseif type == 'entrance' then
                DrawMarker(25, v.x, v.y, v.z - 0.99, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 0, 255, 0, 250, false, false, 2, false, false, false, false)
            elseif type == 'exit' then
                DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 255, 0, 0, 250, false, false, 2, false, false, false, false)
            elseif type == 'inv' then
                DrawMarker(20, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 255, 0, 0, 250, false, false, 2, false, false, false, false)
            end
        end
    end)
end

function showMotelRoomStuffShit()
    Citizen.CreateThread(function()
        while characterLoaded and playerData do
            Citizen.Wait(100)
            if GLOBAL_PED and GLOBAL_COORDS then
                for k, v in pairs(motelRooms) do
                    -- Main Door Motels
                    if v.motel_type == "Door" and v.mainEntrance ~= nil and v.occupierCID == playerData.cid then
                        local distance = #(GLOBAL_COORDS - vector3(v.mainEntrance.x, v.mainEntrance.y, v.mainEntrance.z))
                        if distance < 10.0 then
                            if not showingMarker then
                                showingMarker = k..'mainEntrance'
                                DrawGayMarker(v.mainEntrance, 'mainEntrance', showingMarker)
                            end
                        elseif showingMarker == k..'mainEntrance' then
                            showingMarker = false
                        end
                    end

                    -- Teleport Door Motels
                    if (v.motel_type == "Teleport" and v.occupierCID == playerData.cid) or (v.motel_type == "Teleport" and v.occupierCID ~= playerData.cid and not v.locked) then
                        for e, r in pairs(v.teleport_meta) do
                            local distance = #(GLOBAL_COORDS - vector3(r.x,r.y,r.z))
                            if distance < 10.0 and e == "entrance" then
                                if not showingMarker then
                                    showingMarker = k..'entrance'..e
                                    DrawGayMarker(r, 'entrance', showingMarker)
                                end
                            elseif showingMarker == k..'entrance'..e then
                                showingMarker = false
                            end
                                
                            if distance < 2.0 and e == "exit" then
                                if not showingMarker then
                                    showingMarker = k..'exit'..e
                                    DrawGayMarker(r, 'exit', showingMarker)
                                end
                            elseif showingMarker == k..'exit'..e then
                                showingMarker = false
                            end
                                
                            if distance < 1.0 then
                                if not showing then
                                    if v.occupierCID ~= playerData.cid then
                                        TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = (e == "exit" and "Leave" or "Enter")}})
                                    else
                                        TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "key", ['key'] = "e", ['action'] = (e == "exit" and "Leave" or "Enter")}, {['type'] = "key", ['key'] = "l", ['action'] = (v.locked and "Unlock" or "Lock")}})
                                    end
                                    showing = k..e
                                    showKeys(k, e, v)
                                end
                            else
                                if showing == k..e then 
                                    TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                                    showing = false
                                end
                            end
                        end
                    end

                    -- Inventories and other Inner Markers
                    if (v.inventories ~= nil and beingRobbed[k]) or (v.inventories ~= nil and v.occupierCID == playerData.cid) then
                        for t, q in pairs(v.inventories) do 
                            local distance = #(GLOBAL_COORDS - vector3(q.x, q.y, q.z))
                            if distance < 1.5 then
                                if not showingMarker then
                                    showingMarker = k..'inv'..t
                                    DrawGayMarker(q, 'inv', showingMarker)
                                end
                            elseif showingMarker == k..'inv'..t then
                                showingMarker = false
                            end
                                
                            if distance < 0.75 then
                                if not showing then
                                    showing = k..t
                                    showKeys(k, t, v)
                                end
                            else
                                if showing == k..t then
                                    showing = false
                                    if setInventory then
                                        TriggerEvent('pw_inventory:client:removeThird', v.motel_name..' Room '..v.room_number)
                                        setInventory = false
                                    end
                                    TriggerServerEvent('pw_keynote:server:triggerShowable', false)
                                end
                            end
                        end                        
                    end
                end
            end
        end
    end)
end

exports('getOccupier', function(room)
    if motelRooms[room] then
        return motelRooms[room].occupierCID
    end
end)