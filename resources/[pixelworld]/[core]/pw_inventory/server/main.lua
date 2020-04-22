PW = nil
PWBase = PWBase or {}
PWBase.Inventory = PWBase.Inventory or {}
InvSlots = nil
shopSets = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
	InvSlots = caches.entities
	shopSets = caches.shopItemSets
end)

local Callbacks = nil

function PWBase.Inventory.ItemUsed(self, client, alerts)
	TriggerClientEvent('pw_inventory:client:ShowItemUse', client, alerts)
end

PW.RegisterServerCallback('pw_inventory:server:HasItem', function(source, cb, data)
	local char = exports['pw_core']:getCharacter(source)
	cb(CheckItems(1, char:GetData('id'), data))
end)

PW.RegisterServerCallback('pw_inventory:server:UseHotkey', function(source, cb, data)
	local _src = source
	if data.slot < 6 and data.slot > 0 then
		Citizen.CreateThread(function()
			local char = exports['pw_core']:getCharacter(_src)
			char:Inventory().getSlot(data.slot, function(item)
				if item ~= nil then
					if item.usable then
						--TriggerEvent("mythic_base:server:UseItem", mPlayer:GetData('source'), item, data.slot)
						cb(true)
					end
					cb(false)
				end
			end)
		end)
	else
		CancelEvent()
	end
end)

PW.RegisterServerCallback('pw_inventory:server:GetHotkeys', function(source, cb, data)
	local _src = source
	local char = exports['pw_core']:getCharacter(_src)
	char:Inventory().getHotBar(function(items)
		cb(items)
	end)
end)

function CheckItems(type, id, items, cb)
	local failed = nil
	for k, v in pairs(items) do
		checkItemCount(type, id, v.item, v.count, function(hasItem)
			if not hasItem then
				failed = true
				return
			end

			if k == #items then
				failed = false
			end
		end)
	end

	while failed == nil do
		Citizen.Wait(10)
	end

	if not failed then
		return true
	else
		return false
	end
end

function GetHotkeyItems(source, cb)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	char:Inventory().getHotBar(function(items)
		cb(items)
	end)
end

function GetPlayerInventory(source)
	local _src = source
	local char = exports['pw_core']:getCharacter(_src)

	Citizen.CreateThread(function()
		char:Inventory().getAll(function(items)
			local itemsObject = {}
			for k, v in pairs(items) do
				table.insert(itemsObject, {
					record_id = v["record_id"],
					item = v["item"],
					description = v["description"],
					qty = v["qty"],
					slot = v["slot"],
					label = v["label"],
					type = v["type"],
					max = v["max"],
					stackable = v["stackable"],
					unique = v["unique"],
					usable = v["usable"],
					metapublic = v['metapublic'],
					metaprivate = v['metaprivate'],
					canRemove = true,
					price = v["price"],
					needs = v["needs"],
					closeUi = v["closeUi"],
				})
			end
		
			local data = {
				invId = { type = 1, owner = char.getCID() },
				invTier = InvSlots[1],
				inventory = itemsObject,
			}
		
			TriggerClientEvent('pw_inventory:client:SetupUI', source, data)
		end)
	end)
end

function GetSecondaryInventory(source, inventory)

end

RegisterServerEvent('pw_inventory:server:MoveToEmpty')
AddEventHandler('pw_inventory:server:MoveToEmpty', function(originOwner, originItem, destinationOwner, destinationItem)
    local _src = source
	local char = exports['pw_core']:getCharacter(_src)
	
	Citizen.CreateThread(function()
		if originOwner.type == 18 then
			local items = json.decode(shopSets[tonumber(originOwner.owner)])
			local itemData = exports['pw_core']:itemData(items[originItem])
			local currentBalance = char:Cash().getBalance()

			if currentBalance >= (itemData.price * itemData.max) then
				char:Inventory():Add().Slot(1, items[originItem], itemData.max, {}, {}, destinationItem.slot, function(success)
					if success then
						char:Cash().removeCash((itemData.price * itemData.max), function(newBalance)
							TriggerClientEvent('pw_inventory:client:RefreshInventory', _src)
							Wait(50)
							TriggerClientEvent('pw_inventory:client:updateClientCash', _src, newBalance)
						end)
						
					end
				end)
			end
		else
			char:Inventory():Movement().Empty(originOwner.type, originOwner.owner, originItem, destinationOwner.type, destinationOwner.owner, destinationItem.slot, function(status)
				if originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner then
					--[[if status then
						  if destinationItem.type == "Weapon" then
							if originOwner.type == 1 then
								--TriggerClientEvent("pw_inventory:client:RemoveWeapon", mPlayer:GetData('source'), destinationItem.itemId)
							end
	
							if destinationOwner.type == "Weapon" then
								if destinationOwner.owner == char.getCID() then
									--TriggerClientEvent("pw_inventory:client:AddWeapon", mPlayer:GetData('source'), destinationItem.itemId)
									--TriggerClientEvent('mythic_base:client:AddComponentFromItem', mPlayer:GetData('source'), GetHashKey(destinationItem.itemId), destinationItem.metadata.components)
								else
									exports['ghmattimysql']:scalar('SELECT user FROM characters WHERE id = @charid LIMIT 1', { ['charid'] = tonumber(destinationOwner.owner) }, function(res)
										if res ~= nil then
											local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):UserId(res)
											if tPlayer ~= nil then
												--TriggerClientEvent("pw_inventory:client:AddWeapon", tPlayer:GetData('source'), destinationItem.itemId)
												--TriggerClientEvent('mythic_base:client:AddComponentFromItem', tPlayer:GetData('source'), GetHashKey(destinationItem.itemId), destinationItem.metadata.components)
											end
										end
									end)
								end
							end
						end
					end]]
	
					if originOwner.type == 2 then
						MySQL.Async.fetchScalar('SELECT COUNT(identifier) As DropInventory FROM stored_items WHERE inventoryType = @type AND identifier = @owner', { ['@type'] = originOwner.type, ['@owner'] = originOwner.owner}, function(count)
							if tonumber(count) < 1 then
								TriggerClientEvent('pw_inventory:client:CloseSecondary', -1, originOwner)
								TriggerEvent('pw_inventory:server:RemoveBag', originOwner)
							else
								TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
							end
						end)
					else
						TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
					end
				else
					TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
				end
			end)
		end
	end)
end)

RegisterServerEvent('pw_inventory:server:SplitStack')
AddEventHandler('pw_inventory:server:SplitStack', function(originOwner, originItem, destinationOwner, destinationItem, moveQty)
    local src = source
	local char = exports['pw_core']:getCharacter(src)
	Citizen.CreateThread(function()
		if originOwner.type == 18 then
			local itemData = exports['pw_core']:itemData(originItem.item)
			local currentBalance = char:Cash().getBalance()

			if currentBalance >= (itemData.price * moveQty) then
				char:Inventory():Add().Slot(1, originItem.item, moveQty, {}, {}, destinationItem.slot, function(success)
					if success then
						char:Cash().removeCash((originItem.price * moveQty), function(newBalance)
							TriggerClientEvent('pw_inventory:client:RefreshInventory', src)
							Wait(50)
							TriggerClientEvent('pw_inventory:client:updateClientCash', src, newBalance)
						end)
					end
				end)
			end
		else
			char:Inventory():Movement().Split(originOwner.type, originOwner.owner, originItem.slot, destinationOwner.type, destinationOwner.owner, destinationItem.slot, moveQty, function(status)
				
				if originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner then
					if originOwner.type == 2 then
						MySQL.Async.fetchScalar('SELECT COUNT(identifier) As DropInventory FROM stored_items WHERE inventoryType = @type AND identifier = @owner', { ['@type'] = originOwner.type, ['@owner'] = originOwner.owner}, function(count)
							if count < 1 then
								TriggerClientEvent('pw_inventory:client:CloseSecondary', -1, originOwner)
								TriggerEvent('pw_inventory:server:RemoveBag', originOwner)
							end
						end)
					else
						TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
					end
				else
					TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
				end
			end)
		end
	end)
end)

RegisterServerEvent('pw_inventory:server:CombineStack')
AddEventHandler('pw_inventory:server:CombineStack', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local char = exports['pw_core']:getCharacter(src)
	
	Citizen.CreateThread(function()
		char:Inventory():Movement().Combine(originOwner.type, originOwner.owner, originItem, destinationOwner.type, destinationOwner.owner, destinationItem.slot, function(status)
			local isDropClosing = false
			if originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner then
				if originOwner.type == 2 then
					MySQL.Async.fetchScalar('SELECT COUNT(identifier) As DropInventory FROM stored_items WHERE inventoryType = @type AND identifier = @owner', { ['@type'] = originOwner.type, ['@owner'] = originOwner.owner}, function(count)
						if count < 1 then
							isDropClosing = true
							TriggerClientEvent('pw_inventory:client:CloseSecondary', -1, originOwner)
							TriggerEvent('pw_inventory:server:RemoveBag', originOwner)
						else
							TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
						end
					end)
				else
					TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
				end
			else
				TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
			end
		end)
	end)
end)

RegisterServerEvent('pw_inventory:server:TopoffStack')
AddEventHandler('pw_inventory:server:TopoffStack', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local char = exports['pw_core']:getCharacter(src)

	
	Citizen.CreateThread(function()
		char:Inventory():Movement().TopOff(originOwner.type, originOwner.owner, originItem.slot, destinationOwner.type, destinationOwner.owner, destinationItem.slot, function()
			TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
		end)
	end)
end)

RegisterServerEvent('pw_inventory:server:SwapItems')
AddEventHandler('pw_inventory:server:SwapItems', function(originOwner, originItem, destinationOwner, destinationItem)
    local src = source
	local char = exports['pw_core']:getCharacter(src)

	Citizen.CreateThread(function()
		char:Inventory():Movement().Swap(originOwner.type, originOwner.owner, originItem.slot, destinationOwner.type, destinationOwner.owner, destinationItem.slot, function(status)
			--[[if (originOwner.type ~= destinationOwner.type or originOwner.owner ~= destinationOwner.owner) and status then
				if originOwner.type == 1 then
					exports['ghmattimysql']:scalar('SELECT user FROM characters WHERE id = @charid LIMIT 1', { ['charid'] = originOwner.owner }, function(res)
						if res ~= nil then
							local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):UserId(res)
							if destinationItem.type == "Weapon" then
								TriggerClientEvent("pw_inventory:client:RemoveWeapon", tPlayer:GetData('source'), destinationItem.itemId)
							end
							if originItem.type == "Weapon" then
								--TriggerClientEvent("pw_inventory:client:AddWeapon", tPlayer:GetData('source'), originItem.itemId)
								--TriggerClientEvent('mythic_base:client:AddComponentFromItem', tPlayer:GetData('source'), originItem.itemId, originItem.metadata.components)
							end
						end
					end)
				end

				if destinationOwner.type == 1 then
					exports['ghmattimysql']:scalar('SELECT user FROM characters WHERE id = @charid LIMIT 1', { ['charid'] = destinationOwner.owner }, function(res)
						if res ~= nil then
							local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):UserId(res)
							if originItem.type == "Weapon" then
								TriggerClientEvent("pw_inventory:client:RemoveWeapon", tPlayer:GetData('source'), originItem.itemId)
							end
							if destinationItem.type == "Weapon" then
								--TriggerClientEvent("pw_inventory:client:AddWeapon", tPlayer:GetData('source'), destinationItem.itemId)
								--TriggerClientEvent('mythic_base:client:AddComponentFromItem', tPlayer:GetData('source'), destinationItem.itemId, destinationItem.metadata.components)
							end
						end
					end)
				end
			end]]
			TriggerClientEvent('pw_inventory:client:RefreshInventory2', -1, originOwner, destinationOwner)
		end)
	end)
end)

RegisterServerEvent('pw_inventory:server:GiveItem')
AddEventHandler('pw_inventory:server:GiveItem', function(target, item, count)
    local src = source
	local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(src)
	local char = mPlayer:GetData('character')
	local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(target)

	if tPlayer ~= nil then
		local tChar = tPlayer:GetData('character')

		Citizen.CreateThread(function()
			char.Inventory.Remove:Give(tChar:GetData('id'), item.slot, count, function()
				TriggerClientEvent('pw_inventory:client:RefreshInventory', mPlayer:GetData('source'))
				TriggerClientEvent('pw_inventory:client:RefreshInventory', tPlayer:GetData('source'))
			end)
		end)
	end
end)

RegisterServerEvent('pw_inventory:server:RemoveItem')
AddEventHandler('pw_inventory:server:RemoveItem', function(uId, qty, disableNotif)
    local src = source
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(src)
	local char = mPlayer:GetData('character')
	
	if qty < 1 then
		qty = 1
	end

	Citizen.CreateThread(function()
		char.Inventory.Remove.Personal:UID(uId, qty, function(status)
			TriggerClientEvent('pw_inventory:client:RefreshInventory', src)
		end, disableNotif)
	end)
end)

RegisterServerEvent('pw_inventory:server:GetPlayerInventory')
AddEventHandler('pw_inventory:server:GetPlayerInventory', function()
	GetPlayerInventory(source)
end)

RegisterServerEvent('pw_inventory:server:GetSecondaryInventory')
AddEventHandler('pw_inventory:server:GetSecondaryInventory', function(source2, owner)
	if Config.Blacklist[owner.type] then return end
	local _src = source
    local src = source2
	local char = exports['pw_core']:getCharacter(_src) or exports['pw_core']:getCharacter(src)

	Citizen.CreateThread(function()
		if owner.type ~= 18 then
			char:Inventory().getSecondary(owner.type, owner.owner, function(items)
				local tier = 0
				if InvSlots[owner.type] ~= nil then
					tier = InvSlots[owner.type]
				else
					tier = InvSlots[0]
				end
			
				local data = {
					invId = owner,
					invTier = tier,
					inventory = items,
				}
				if owner.type == 2 and #items == 0 then
					TriggerEvent('pw_inventory:server:RemoveBag', owner)
				else
					TriggerClientEvent('pw_inventory:client:SetupSecondUI', src, data)
				end
			end)
		else
			local itemSet = MySQL.Sync.fetchScalar("SELECT `shop_items` FROM `shops` WHERE `shop_id` = @id", {['@id'] = tonumber(owner.owner)})
			local items = json.decode(shopSets[tonumber(itemSet)])
			local itemsObject = {}
			for k, itemId in pairs(items) do
				local v = exports['pw_core']:itemData(itemId)

				table.insert(itemsObject, {
					item = v['item'],
					description = v["description"],
					qty = 1,
					slot = k,
					label = v['label'],
					type = v['type'],
					max = v['max'],
					stackable = v['stackable'],
					unique = v['unique'],
					usable = false,
					metadata = nil,
					canRemove = true,
					price = v['price'],
					needs = v['needs'],
					closeUi = v['closeUi'],
				})
			end

			local tier = 0
			if InvSlots[owner.type] ~= nil then
				tier = InvSlots[owner.type]
			else
				tier = InvSlots[0]
			end
		
			local data = {
				invId = owner,
				invTier = tier,
				inventory = itemsObject,
			}
		
			if owner.type == 2 and #itemsObject == 0 then
				TriggerEvent('pw_inventory:server:RemoveBag', owner)
			else
				TriggerClientEvent('pw_inventory:client:SetupSecondUI', src, data)
			end
		end
		
	end)
end)

RegisterServerEvent('pw_inventory:server:RobPlayer')
AddEventHandler('pw_inventory:server:RobPlayer', function(target)
	local src = source

	local myPed = GetPlayerPed(src)
	local myPos = GetEntityCoords(myPed)
	local tPed = GetPlayerPed(target)
	local tPos = GetEntityCoords(tPed)

	local dist = #(myPos - tPos)

	if dist < 2.51 then
		local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
		local cData = char:GetData()
		local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(target)
		if tPlayer ~= nil then
			tChar = tPlayer:GetData('character'):GetData()
			TriggerEvent('pw_inventory:server:GetSecondaryInventory', target)
		end
	else
		exports['mythic_base']:FetchComponent('PownzorAction'):PermanentBanSource(src, 'Get Fucked', 'Pwnzor')
	end
end)