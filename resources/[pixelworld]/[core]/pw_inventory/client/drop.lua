local isLoggedIn = false
local dropsNear = {}
local dropList = {}
local dropProps = {}
local nearBar = false
bagId = nil

function openDrop()
    if bagId ~= nil then
        PWBase.Inventory.Load:Secondary(bagId)
    end
end

RegisterNetEvent('pw_inventory:client:RecieveActiveDrops')
AddEventHandler('pw_inventory:client:RecieveActiveDrops', function(drops)
    for k, v in pairs(drops) do
        dropList[v.owner] = v 
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            PW.TriggerServerCallback('pw_inventory:server:getcurrentDrops', function(dps)
                dropList = dps
                isLoggedIn = true
            end)
        end
    else
        isLoggedIn = false
        nearBar = false
        bagId = nil
    end
end)


RegisterNetEvent('pw_inventory:client:createDropForAll')
AddEventHandler('pw_inventory:client:createDropForAll', function(owner, tbl)
    dropList[owner] = tbl
end)

RegisterNetEvent('pw_inventory:client:RemoveBagNew')
AddEventHandler('pw_inventory:client:RemoveBagNew', function(owner)
    if dropList[owner] then
        dropList[owner] = nil
    end
    if dropsNear[owner] then
        dropsNear[owner] = nil
    end
    if dropProps[owner] then
        PW.Game.DeleteObject(dropProps[owner])
        dropProps[owner] = nil
    end
    bagId = nil
    nearBar = false
end)

RegisterNetEvent('pw_inventory:client:CleanDropItems')
AddEventHandler('pw_inventory:client:CleanDropItems', function()
    dropList = {}
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            local pedCoord = GetEntityCoords(PlayerPedId())
            if dropList ~= nil then
                local plyCoords = GetEntityCoords(PlayerPedId())
                for k, v in pairs(dropList) do
                    local dist = #(vector3(v.position.x, v.position.y, v.position.z) - plyCoords)
                    if dist < 30.0 then
                        -- spawn local bag object from distance?
                        if not dropProps[k] then
                            dropProps[k] = true
                            PW.Game.SpawnLocalObjectNoOffset("prop_paper_bag_01", {['x'] = v.position.x, ['y'] = v.position.y, ['z'] = v.position.z}, function(obj)
                                SetEntityCollision(obj, false, false)
                                PlaceObjectOnGroundProperly(obj)
                                FreezeEntityPosition(obj, true)
                                dropProps[k] = obj
                            end)
                        end
                    else
                        -- delete local spawned object
                        if dropProps[k] then
                            PW.Game.DeleteObject(dropProps[k])
                            dropProps[k] = nil
                        end
                    end

                    if dist < 20.0 then
                        dropsNear[k] = v
                        if dist < 5.0 then
                            if not nearBar then
                                bagId = v
                                nearBar = k
                            end
                        else
                            if nearBar == k then
                                bagId = nil
                                nearBar = false
                            end
                        end
                    else
                        nearBar = false
                        dropsNear[k] = nil
                    end
                end
            else
                nearBar = false
                dropsNear = {}
                if dropProps[owner] then
                    PW.Game.DeleteObject(dropProps[k])
                    dropProps[owner] = nil
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            for k, v in pairs(dropsNear) do
                DrawMarker(20, v.position.x, v.position.y, v.position.z - 0.50, 0, 0, 0, 0, 180.0, 0, 0.15, 0.15, 0.15, 255, 255, 255, 250, false, false, 2, true, false, false, false)
                DrawMarker(25, v.position.x, v.position.y, v.position.z - 0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 139, 16, 20, 250, false, false, 2, false, false, false, false)
            end
        end
        Citizen.Wait(1)
    end
end)