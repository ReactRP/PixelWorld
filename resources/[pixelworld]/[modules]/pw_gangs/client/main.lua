PW = nil
characterLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
local Gangs = {}

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
            PW.TriggerServerCallback('pw_gangs:server:getGangs', function(gangs)
                Gangs = gangs

                for k,v in pairs(Gangs) do
                    local vectors = {}
                    for j,b in pairs(v.hq.polys) do
                        table.insert(vectors, vector2(b[1], b[2]))
                    end
                    
                    Gangs[k].poly = PolyZone:Create(vectors,{
                        name = v.name,
                        minZ = v.hq.minz - 1.0,
                        maxZ = v.hq.maxz + 1.0,
                        debugGrid = false
                    })

                    vectors = {}
                    for j,b in pairs(v.hq.outpolys) do
                        table.insert(vectors, vector2(b[1], b[2]))
                    end
                    
                    Gangs[k].outpoly = PolyZone:Create(vectors,{
                        name = v.name .. 'out',
                        minZ = v.hq.minz - 1.0,
                        maxZ = v.hq.maxz + 1.0,
                        debugGrid = false
                    })

                    Citizen.CreateThread(function()
                        Gangs[k].poly:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
                            if isPointInside then
                                TriggerEvent('pw_properties:spawnedInHome', v.hq.property, BossCheck())
                            else
                                TriggerEvent('pw_properties:leftHQ', v.hq.property)
                            end
                        end, 100)
                    end)
                end        
                characterLoaded = true
            end)
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
    end
end)

function CheckInsidePoly(type, coords, gang)
    if (type == 'poly' or type == 'outpoly') and coords.x and coords.y and gang > 0 then
        return Gangs[gang][type]:isPointInside(coords)
    end
    return false
end

exports('checkPoly', function(type, coords, gang)
    return CheckInsidePoly(type, coords, gang)
end)

function BossCheck(level)
    if playerData then
        return ((playerData.gang.gang > 0 and playerData.gang.level >= (level or 4)) and playerData.gang.gang or false )
    end
    return false
end

exports('checkBoss', function(gang, level)
    return BossCheck(gang, level)
end)

RegisterNetEvent('pw:setGang')
AddEventHandler('pw:setGang', function(data)
    if characterLoaded and playerData then
        PW.TablePrint(data)
        playerData.gang = data
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded and playerData then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and playerData and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

function SpawnFurniture(k)

end

function DeleteFurniture(k)

end

function DrawNotif(var)
    local title, msg, icon, label

    if var == '' then
        title = Gangs[nearGang].name
        msg = 'Access Gang storage'
        icon = 'fad fa-box-alt'
        label = 'Storage'
    end

    TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = 'e', ['label'] = 'Access ' .. label}})
    TriggerEvent('pw_drawtext:showNotification', { title = title, msg = message, icon = icon })

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and playerData then
            --[[ if Gangs and #Gangs > 0 then
                for k,v in pairs(Gangs) do
                    local gangDist = #(GLOBAL_COORDS - vector3(v.locations.central.x, v.locations.central.y, v.locations.central.z))
                    if gangDist < 50.0 then
                        if not nearGang or (nearGang and nearGang ~= k) then
                            nearGang = k
                            SpawnFurniture(k)
                        end
                    elseif nearGang == k then
                        nearGang = false
                        DeleteFurniture()
                    end
                end

                if nearGang then
                    for j,b in pairs(Gangs[nearGang].locations) do
                        local placeDist = #(GLOBAL_COORDS - vector3(b.x, b.y, b.z))
                        if placeDist < 2.0 then
                            if not showing or (showing and showing ~= j) then
                                showing = j
                                DrawNotif(showing)
                            end
                        elseif showing == j then
                            showing = false
                            TriggerEvent('pw_drawtext:hideNotification')
                            if j == 'storage' then
                                TriggerEvent('pw_inventory:client:removeSecondary', 'storage')
                            end
                            TriggerEvent('pw_items:showUsableKeys', false)
                        end
                    end
                end
            end ]]
        end
    end
end)