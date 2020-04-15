function checkItemCount(type, id, itemid, count, cb)
	MySQL.Async.fetchScalar('SELECT SUM(qty) FROM stored_items WHERE inventoryType = @type AND identifier = @id AND item = @item', { ['item'] = itemid, ['type'] = type, ['id'] = id }, function(has)
		if has ~= nil then
			cb(has >= count)
		else
			cb(false)
		end
	end)
end