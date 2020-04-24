PW = nil
itemStore = {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    itemStore = caches.itemStore -- The Servers Item Database
end)

RegisterServerEvent('pw_keynote:server:triggerShowable')
AddEventHandler('pw_keynote:server:triggerShowable', function(show, items)
    local _src = source
    if show then
        if items then
            local showTable = {}
            for k, v in pairs(items) do
                if v.type == "item" then
                    if itemStore[v.item] then
                        table.insert(showTable, {['image'] = itemStore[v.item].image, ['label'] = itemStore[v.item].label, ['type'] = "item"})
                    end
                end

                if v.type == "key" then
                    table.insert(showTable, {['image'] = v.key..".png", ['label'] = "Use "..string.upper(v.key), ['type'] = "key", ['action'] = v.action})
                end
            end
            TriggerClientEvent('pw_keynote:client:triggerShowable', _src, true, showTable)
        end
    else
        TriggerClientEvent('pw_keynote:client:triggerShowable', _src, false)
    end
end)