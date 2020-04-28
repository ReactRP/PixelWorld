local shops = nil
local shopBlips = {}
local inMarker = false

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if not ready then
            -- Start Shop Blips
            PW.ExecuteServerCallback('pw_inventory:server:shopRequest', function(shopsdata)
                if shops == nil then
                    shops = shopsdata
                    doShopsBlip()
                end
            end)
        end
    else
        -- Remove Blips
        if shops ~= nil then
            removeShopsBlip()
        end
    end
end)

RegisterNetEvent('pw:characters:cashAdjustment')
AddEventHandler('pw:characters:cashAdjustment', function(amount)
    if playerLoaded and playerData then
        playerData.cash = tonumber(amount)
    end
end)

RegisterNetEvent('pw_inventory:client:updateClientCash')
AddEventHandler('pw_inventory:client:updateClientCash', function(cash)
    SendNUIMessage({
        action = "updateCash",
        cash = cash
    })
end)

function removeShopsBlip()
    for k, v in pairs(shopBlips) do
        RemoveBlip(v)
    end
end

function doShopsBlip()
    for k, v in pairs(shops) do
        if v.marker then
            shopBlips[k] = AddBlipForCoord(v.shop_coords.x, v.shop_coords.y, v.shop_coords.z)
            SetBlipSprite(shopBlips[k], 59)
            SetBlipDisplay(shopBlips[k], 4)
            SetBlipScale  (shopBlips[k], 0.8)
            SetBlipColour (shopBlips[k], 7)
            SetBlipAsShortRange(shopBlips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Shop")
            EndTextCommandSetBlipName(shopBlips[k])
        end
    end
end

Citizen.CreateThread(function()
    while true do
        if isLoggedIn and GLOBAL_COORDS ~= nil then
            for k, v in pairs(shops) do
                local distance = #(GLOBAL_COORDS - vector3(v.shop_coords.x, v.shop_coords.y, v.shop_coords.z))
                if distance < 10.0 then
                    DrawMarker(25, v.shop_coords.x, v.shop_coords.y, v.shop_coords.z - 0.99, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 139, 16, 20, 250, false, false, 2, false, false, false, false)
                end
                if distance < 1.2 then
                    if inMarker ~= k then
                        thirdInventory = { type = 18, owner = k, req = v.name }
                        thirdOpenAllowed = true
                        inMarker = k
                    end
                else
                    if inMarker == k then
                        thirdInventory = nil
                        thirdOpenAllowed = false
                        inMarker = false
                    end
                end
            end
        end
        Citizen.Wait(1)
    end
end)