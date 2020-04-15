local currentDrops = {}

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `drops`", {}, function(drops)
        if drops ~= nil then
            for k, v in pairs(drops) do
                currentDrops[v.drop_id] = {type = 2, owner = v.drop_id, position = json.decode(v.coords)}
            end
        end
    end)
end)

PW.RegisterServerCallback('pw_inventory:server:getcurrentDrops', function(source, cb)
    cb(currentDrops)
end)

PWBase.Inventory.Drops = {
    Process = function(self, source, item, count, coords)
        local mPlayer = exports['pw_core']:getCharacter(source)
        if mPlayer ~= nil then
            Citizen.CreateThread(function()
                MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = 1 AND identifier = @charid AND slot = @slot LIMIT 1', { ['slot'] = item.slot, ['charid'] = mPlayer.getCID() }, function(dbItem)
                    if dbItem[1] ~= nil then
                        local retreiveDrops = MySQL.Sync.fetchAll("SELECT * FROM `drops`", {})
                        if count > tonumber(dbItem[1].count) then
                            count = tonumber(dbItem[1].count)
                        end
    
                        local dropinv = nil
                        local pos = GetEntityCoords(GetPlayerPed(source))

                        for k, v in pairs(retreiveDrops) do
                            if v.coords ~= nil then
                                v.position = json.decode(v.coords)
                                local dist = #(vector3(v.position.x, v.position.y, v.position.z) - pos)
                                if dist < 3.5 then
                                    PWBase.Inventory.Drops:Add(source, mPlayer, v.drop_id, item, count, function()
                                        TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, v, v)
                                    end)
                                    return
                                end
                            end
                        end
    
                        PWBase.Inventory.Drops:Create(source, mPlayer, item, count, coords, function(drop)
                            TriggerEvent('pw_inventory:server:GetSecondaryInventory', source, drop)
                        end)
                    end
                end)
            end)
        
        end
    end,
    Create = function(self, src, char, item, count, coords, cb)
        local fuck = {
            x = coords.x,
            y = coords.y,
            z = coords.z,
        }
        MySQL.Async.insert("INSERT INTO `drops` (`coords`,`owner`) VALUES (@coords, @owner)", {['@coords'] = json.encode(fuck), ['@owner'] = char.getCID()}, function(dropid)
            if dropid > 0 then
                local newDrop = { type = 2, owner = dropid, position = fuck }
                char.Inventory():Add().Drop(dropid, item, count, function(s)
                    if item.type == "Weapon" then
                        TriggerClientEvent("pw_inventory:client:RemoveWeapon", src, item.name)
                    end
                    
                    TriggerClientEvent('pw_inventory:client:createDropForAll', -1, dropid, {type = 2, owner = dropid, position = fuck})
                    currentDrops[dropid] = {type = 2, owner = dropid, position = fuck}            
                    cb(newDrop)
                end)
            end
        end)
    end,
    Add = function(self, src, char, owner, item, count, cb)
        MySQL.Async.fetchScalar("SELECT `drop_id` FROM `drops` WHERE `drop_id` = @drop", {['@drop'] = owner}, function(exist)
            if exist ~= nil then
                char.Inventory():Add().Drop(owner, item, count, function(s)
                    if item.type == 1 then
                        TriggerClientEvent("pw_inventory:client:RemoveWeapon", src, item.name)
                    end
                    cb(s)
                end)
            end
        end)
    end,
    Store = {}
}
drops = {}

RegisterServerEvent('pw_inventory:server:GetActiveDrops')
AddEventHandler('pw_inventory:server:GetActiveDrops', function()
    TriggerClientEvent('pw_inventory:client:RecieveActiveDrops', source, PWBase.Inventory.Drops.Store)
end)

RegisterServerEvent('pw_inventory:server:Drop')
AddEventHandler('pw_inventory:server:Drop', function(item, count, coords)
    PWBase.Inventory.Drops:Process(source, item, count, coords)
end)

RegisterServerEvent('pw_inventory:server:RemoveBag')
AddEventHandler('pw_inventory:server:RemoveBag', function(dropInv)
    MySQL.Async.execute("DELETE FROM `drops` WHERE `drop_id` = @drop", {['@drop'] = dropInv.owner}, function(done)
        currentDrops[dropInv.owner] = nil
        TriggerClientEvent('pw_inventory:client:RemoveBagNew', -1, dropInv.owner)
    end)
    
end)