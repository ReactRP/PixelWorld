InvSlots = {--[[
	['misc'] = { slots = 10, label = 'Unknown' },
	['player'] = { slots = 40, label = 'Player' },
	['drop'] = { slots = 100, label = 'Drop' },
	['container'] = { slots = 100, label = 'Container' },
	['car-int'] = { slots = 5, label = 'Glove Box' },
	['car-ext'] = { slots = 50, label = 'Trunk' },
	['prop-1'] = { slots = 50, label = 'Property Stash' },
	['prop-2'] = { slots = 65, label = 'Property Stash' },
	['prop-3'] = { slots = 80, label = 'Property Stash' },
	['prop-4'] = { slots = 100, label = 'Property Stash' },
	['biz-1'] = { slots = 100, label = 'Property Stash' },
	['biz-2'] = { slots = 125, label = 'Property Stash' },
	['biz-3'] = { slots = 150, label = 'Property Stash' },
	['biz-4'] = { slots = 200, label = 'Property Stash' },
	['pd-evidence'] = { slots = 1000, label = 'Evidence Locker' },
	['pd-trash'] = { slots = 1000, label = 'Trash Locker' },
]]}

AddEventHandler('mythic_base:shared:ComponentsReady', function()
	local weapons = exports['mythic_base']:FetchComponent('WeaponData')

	for k, v in ipairs(weapons) do
		TriggerEvent('mythic_base:server:RegisterUsableItem', v, function(source, item)
			-- TriggerEvent('mythic_phone:server:StartInstallApp', source, item)
			local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
		
			if item.slot <= 5 then
				TriggerClientEvent('pw_inventory:client:AddWeapon', source, item.weapon)
			end
		end)
	end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
   -- exports['ghmattimysql']:execute('DELETE FROM inventory_items WHERE type IN (0, 2, 3, 6, 7, 8, 9)')
   -- exports['ghmattimysql']:execute('DELETE FROM inventory_items WHERE qty <= 0')
end)