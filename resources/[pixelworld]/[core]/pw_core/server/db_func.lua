function CreateItemObject(itemDb)
	if (PWBase.Storage.itemStore[itemDb.item] ~= nil) then
		local item = {
            record_id = itemDb.record_id,
            item_id = itemDb.record_id,
			item = itemDb.item,
			description =  PWBase.Storage.itemStore[itemDb.item].description,
			qty = itemDb.count,
			slot = itemDb.slot,
			label = PWBase.Storage.itemStore[itemDb.item].label,
			type = PWBase.Storage.itemStore[itemDb.item].type,
			max = PWBase.Storage.itemStore[itemDb.item].max,
			stackable = PWBase.Storage.itemStore[itemDb.item].stackable,
			unique = PWBase.Storage.itemStore[itemDb.item].unique,
			usable = PWBase.Storage.itemStore[itemDb.item] ~= nil,
            metapublic = (itemDb.metapublic ~= nil and json.decode(itemDb.metapublic) or {}),
            metaprivate = (itemDb.metaprivate ~= nil and json.decode(itemDb.metaprivate) or {}),
			price = PWBase.Storage.itemStore[itemDb.item].price,
			needs = PWBase.Storage.itemStore[itemDb.item].needs,
            closeUi = PWBase.Storage.itemStore[itemDb.item].closeUi,
            meta = PWBase.Storage.itemStore[itemDb.item].metal,
		}
		return item
	end
end

function itemData(itemDb)
	if (PWBase.Storage.itemStore[itemDb] ~= nil) then
		local item = {
			item = itemDb,
			description =  PWBase.Storage.itemStore[itemDb].description,
			label = PWBase.Storage.itemStore[itemDb].label,
			type = PWBase.Storage.itemStore[itemDb].type,
			max = (PWBase.Storage.itemStore[itemDb].stackable and PWBase.Storage.itemStore[itemDb].max or 1),
			stackable = PWBase.Storage.itemStore[itemDb].stackable,
			unique = PWBase.Storage.itemStore[itemDb].unique,
			usable = PWBase.Storage.itemStore[itemDb] ~= nil,
			price = PWBase.Storage.itemStore[itemDb].price,
			needs = PWBase.Storage.itemStore[itemDb].needs,
            closeUi = PWBase.Storage.itemStore[itemDb].closeUi,
            meta = PWBase.Storage.itemStore[itemDb].metal,
		}
		return item
	end
end

exports('itemData', function(item)
	return itemData(item)
end)