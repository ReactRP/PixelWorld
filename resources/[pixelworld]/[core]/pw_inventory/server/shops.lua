PW.RegisterServerCallback('pw_inventory:server:shopRequest', function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM `shops`", {}, function(query)
        local shops = {}
        if query[1] ~= nil then
            for k, v in pairs(query) do
                shops[v.shop_Id] = {['name'] = v.shop_name, ['shop_itemset'] = v.shop_items, ['shop_coords'] = json.decode(v.shop_coords), ['marker'] = v.marker}
            end
            cb(shops)
        end
    end)
end)