PW = nil
authed = false
local Sellers, Meth = {}, {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_npcdrugs:server:updateState')
AddEventHandler('pw_npcdrugs:server:updateState', function(state, info)
    local _src = source
    Sellers[_src] = state and info or nil
    TriggerClientEvent('pw_npcdrugs:client:updateSellers', -1, Sellers)
end)

RegisterServerEvent('pw_npcdrugs:server:processDrugSell')
AddEventHandler('pw_npcdrugs:server:processDrugSell', function(info)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local total = info.price * info.amount
    _char:Inventory():Remove().ByName(Config.ItemName[info.drug], info.amount, function(idone)
        if idone then
            _char:Cash().addCash(total, function(cdone)
                if cdone then
                    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Sold '..info.amount..' bags of '..string.gsub(info.drug, "^%l", string.upper)..' for $'..total, length = 4500 })
                end
            end)
        end
    end)
end)

RegisterServerEvent('pw_npcdrugs:server:updateMethRun')
AddEventHandler('pw_npcdrugs:server:updateMethRun', function(state)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local cid = _char.getCID()
    Meth[cid] = state
end)

RegisterServerEvent('pw_npcdrugs:server:startMethCooldown')
AddEventHandler('pw_npcdrugs:server:startMethCooldown', function()
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local cid = _char.getCID()
    Citizen.SetTimeout(Config.MethRun.cooldown * 60 * 1000, function()
        Meth[cid] = nil
        TriggerClientEvent('pw_npcdrugs:client:resetDropoffs', _src)
    end)
end)

RegisterServerEvent('pw_npcdrugs:server:processMethSale')
AddEventHandler('pw_npcdrugs:server:processMethSale', function(qtyRem, curQty)
    local _src = source
    local qty = math.random((curQty > qtyRem and qtyRem or curQty))
    local pp = math.random(Config.Prices['meth'].min, Config.Prices['meth'].max)
    local award = qty * pp
    local _char = exports.pw_core:getCharacter(_src)
    _char:Inventory():Remove().ByName(Config.ItemName['meth'], qty, function(idone)
        if idone then
            _char:Cash().addCash(award, function(cdone)
                if cdone then
                    TriggerClientEvent('pw_npcdrugs:client:saleConfirmed', _src, award, qty)
                end
            end)
        end
    end)
end)

RegisterServerEvent('pw_npcdrugs:server:loadVehTrunkWithMeth')
AddEventHandler('pw_npcdrugs:server:loadVehTrunkWithMeth', function(vin)
    local _src = source
    MySQL.Async.insert("INSERT INTO `stored_items` (`identifier`, `inventoryType`, `item`, `count`, `metapublic`, `metaprivate`, `type`, `slot`) VALUES (@vin, @invType, @item, @count, @metapub, @metapriv, @itemType, @slot)", {
        ['@vin'] = vin,
        ['@invType'] = 7,
        ['@item'] = Config.ItemName['meth'],
        ['@count'] = Config.MethRun.qty,
        ['@metapub'] = json.encode({}),
        ['@metapriv'] = json.encode({}),
        ['@itemType'] = 'Item',
        ['@slot'] = 1
    }, function() end)
end)

PW.RegisterServerCallback('pw_npcdrugs:server:checkMethCooldown', function(source, cb)
    local _char = exports.pw_core:getCharacter(source)
    local cid = _char.getCID()
    cb(Meth[cid] or false)
end)

PW.RegisterServerCallback('pw_npcdrugs:server:checkCashForRun', function(source, cb, amount)
    local _char = exports.pw_core:getCharacter(source)
    _char:Cash().removeCash(amount, function(done)
        cb(done)
    end)
end)

exports.pw_chat:AddChatCommand('weed', function(source, args, rawCommand)
    TriggerClientEvent('pw_npcdrugs:client:sell', source, 'weed')
end, {
    help = 'Start/Stop Weed corner selling'
}, -1)

exports.pw_chat:AddChatCommand('coke', function(source, args, rawCommand)
    TriggerClientEvent('pw_npcdrugs:client:sell', source, 'coke')
end, {
    help = 'Start/Stop Cocaine corner selling'
}, -1)