PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)


AddEventHandler('onResourceStart', function(res)
    if res == GetCurrentResourceName() then
        ResetWareHouses()
    end
end)

function ResetWareHouses()
    for k,v in pairs(Config.DeliveryTypesPerWareHouse) do
        for f, s in pairs(v) do
            if s.warehouseAmount ~= s.maxWarehouseAmount then
                s.warehouseAmount = s.maxWarehouseAmount
            end
        end
    end 
    print(' ^6[PixelWorld Trucking] ^7- All Truck Warehouses Refilled to 100% Capacity^7')
    PW.SetTimeout(Config.WarehouseRefreshTime * 60000, function()
        ResetWareHouses()
    end)
end


RegisterServerEvent('pw_trucking:server:toggleDuty')
AddEventHandler('pw_trucking:server:toggleDuty', function(depot)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Job().toggleDuty()
    TriggerClientEvent('pw_trucking:client:openDepotMenu', _src, depot)
end)

PW.RegisterServerCallback('pw_trucking:server:getDepotDeliveries', function(source, cb, depot)
    cb(Config.DeliveryTypesPerWareHouse[depot])
end)

PW.RegisterServerCallback('pw_trucking:server:canStartDelivery', function(source, cb, depot, type)
    if Config.DeliveryTypesPerWareHouse[depot][type] ~= nil then
        local curDelivery = Config.DeliveryTypesPerWareHouse[depot][type]
        if curDelivery.warehouseAmount > 0 then
            curDelivery.warehouseAmount = curDelivery.warehouseAmount - 1
            cb(true)
        else
            cb(false)
        end
    else 
        cb(false)
    end
    
end)

RegisterServerEvent('pw_trucking:server:successfullyCompletedADelivery')
AddEventHandler('pw_trucking:server:successfullyCompletedADelivery', function(startDepot, type)
    local _src = source
    if startDepot ~= nil and type ~= nil and Config.DeliveryTypesPerWareHouse[startDepot][type] ~= nil then
        local _char = exports['pw_core']:getCharacter(_src)
        local amount = math.random(Config.DeliveryTypesPerWareHouse[startDepot][type].minPay, Config.DeliveryTypesPerWareHouse[startDepot][type].maxPay)
        local payment = math.ceil(amount)
        _char:Bank().addMoney(payment, "Trucker - Delivery Payment", function(done)
            if done then
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'Delivery Complete Successfully<br>$'.. payment .. ' was Transferred to Your Bank Account', length = 10000 })
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'There Was An Issue With Payment For That Delivery', length = 2500 })
            end
        end)
    end
end)


RegisterServerEvent('pw_haulage:server:finishdelivery')
AddEventHandler('pw_haulage:server:finishdelivery', function(type)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    if type == 'regular' then
        local pay = math.random(Config.RegularDeliveryPay.min, Config.RegularDeliveryPay.max)      
        local _balance = _char:Cash().Add(pay)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = 'This Delivery Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})
    elseif type == 'special' then
        local pay = math.random(Config.RegularDeliveryPay.min, Config.RegularDeliveryPay.max)      
        local _balance = _char:Cash().Add(pay)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = 'This Specialist Delivery Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})
    elseif type == 'fuel' then
        local pay = math.random(Config.FuelDeliveryPay.min, Config.FuelDeliveryPay.max)      
        local _balance = _char:Cash().Add(pay)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "info", text = 'The Fuel Delivery Run Earnt You $' .. math.ceil(pay) .. ' in Cash!', length = 10000})  
    end       
end)

