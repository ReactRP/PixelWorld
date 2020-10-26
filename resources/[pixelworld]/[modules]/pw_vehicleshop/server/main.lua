local displayedVeh, chosenVehicle = 0, nil
local activeFinances, testDriveDeposit, Dealers = {}, {}, {}
vehiclesCache = {}

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    vehiclesCache = caches.vehicles -- The Servers Vehicles Database
    MySQL.Async.fetchAll("SELECT * FROM `vehicle_categories`", {}, function(categorys)
        for p, q in pairs(categorys) do
            vehicles[q.name] = { ['name'] = q.name, ['label'] = q.label, ['vehicles'] = {} }
            for k, v in pairs(vehiclesCache) do
                if v.category == q.name then
                    vehicles[q.name].vehicles[v.model] = v
                end
            end
        end

        MySQL.Async.fetchAll("SELECT * FROM `vehicle_financing`", {}, function(res)
            if #res > 0 then
                for i = 1, #res do
                    table.insert(activeFinances, res[i])
                end
                print(' ^1[SynCity Vehicles] ^3- We have loaded ^4'..#res..' ^3vehicle financing contracts.')
            end
            StartPayments()
        end)

        MySQL.Async.fetchAll("SELECT * FROM `dealerships`", {}, function(deals)
            if deals ~= nil and deals[1] ~= nil then
                Dealers = deals
                for k,v in pairs(Dealers) do
                    Dealers[k].coords = json.decode(v.coords)
                    Dealers[k].showroomspots = json.decode(v.showroomspots)
                    if v.showroom ~= nil then
                        Dealers[k].showroom = json.decode(v.showroom)
                    else
                        Dealers[k].showroom = {}
                    end
                    Dealers[k].testdrive = json.decode(v.testdrive)
                    Dealers[k].sellspots = json.decode(v.sellspots)
                    Dealers[k].bossSettings = json.decode(v.bossSettings)
                    TriggerEvent('pw_banking:business:createAccount', 'cardealer', v.id, 1000000, {})
                end
            end
        end)
    end)
end)

function StartPayments()
    TriggerEvent('cron:runAt', 01, 00, PaymentDue)
end

RegisterServerEvent('baseevents:enteringVehicle')
AddEventHandler('baseevents:enteringVehicle', function(veh, one, two, network)
    local _src = source
    TriggerClientEvent('pw_vehicleshop:client:enteringVehicle', _src, veh, network)
end)

RegisterServerEvent('pw_vehicleshop:server:decideToRegisterVehicle')
AddEventHandler('pw_vehicleshop:server:decideToRegisterVehicle', function(properties, veh, net)
    local _src = source
    local _vehicle = exports['pw_vehiclemanagement']:getVehicleByPlate(properties.plate)
    repeat Wait(0) until _vehicle ~= nil 

    --TriggerClientEvent('pw_vehicleshop:client:setDecor', _src, veh, "pw_veh_playerOwned", registeredVehicles[_vehicle].getVehicleStatus(), "bool") 
end)

PW.RegisterServerCallback('pw_vehicleshop:server:registerPotentialVin', function(source, cb, props, veh)
    local _src = source
    local _vehicle = exports['pw_vehiclemanagement']:getVehicleByPlate(props.plate)
    if _vehicle == nil then
        createTemporaryVehicle(props)
        _vehicle = exports['pw_vehiclemanagement']:getVehicleByPlate(props.plate)
    end
    repeat Wait(0) until _vehicle ~= nil 
    TriggerClientEvent('pw_vehicleshop:client:setDecor', _src, veh, "pw_veh_playerOwned", registeredVehicles[_vehicle].getVehicleStatus(), "bool") 
    cb(_vehicle)
end)

exports('getVehicles', function()
    return registeredVehicles
end)

exports('getVehicleByPlate', function(plate)
    return getVehicleByPlate(plate)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:requestConfig', function(source, cb)
    cb(Dealers)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getDisplayed', function(source, cb)
    local _src = source
    cb(displayedVeh, chosenVehicle)
end)

RegisterServerEvent('pw_vehicleshop:server:updateDisplayed')
AddEventHandler('pw_vehicleshop:server:updateDisplayed', function(obj, chosen)
    displayedVeh = obj
    chosenVehicle = chosen
    TriggerClientEvent('pw_vehicleshop:client:updateDisplayed', -1, displayedVeh, chosenVehicle)
end)

RegisterServerEvent('pw_vehicleshop:server:newModel')
AddEventHandler('pw_vehicleshop:server:newModel', function(dealer, spot, price, props)
    TriggerClientEvent('pw_vehicleshop:client:newModel', -1, dealer, spot, price, props)
end)

RegisterServerEvent('pw_vehicleshop:server:getShowroom')
AddEventHandler('pw_vehicleshop:server:getShowroom', function()
    local _src = source
    TriggerClientEvent('pw_vehicleshop:client:spawnShowroomVehs', _src, Dealers[dealer].showroom)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:checkOwnedVehicle', function(source, cb, plate)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE `plate` = @plate", {['@plate'] = plate}, function(res)
        if res[1] ~= nil then
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:storeVehicle')
AddEventHandler('pw_vehicleshop:server:storeVehicle', function(plate, vehinfo)
    if plate ~= nil then
        local vehicle = exports['pw_vehiclemanagement']:getVehicleByPlate(plate)
        if vehicle then
            vehicle.SetVehicleProperties(vehinfo)
        end
    end
end)

RegisterServerEvent('pw_vehicleshop:toggleSignOn')
AddEventHandler('pw_vehicleshop:toggleSignOn', function(toggle)
    local _src = source
    local _char = exports.pw_core:Source(_src)
    _char:Job().toggleDuty()
end)

RegisterServerEvent('pw_vehicleshop:server:processPriceShowroom')
AddEventHandler('pw_vehicleshop:server:processPriceShowroom', function(data)
    local _src = source
    local spot = tonumber(data.veh.data.veh.spot)
    local oldPrice = tonumber(data.veh.data.veh.price)
    local defaultPrice = tonumber(data.veh.data.veh.defaultPrice)
    local inputedPrice = tonumber(data.price.value)
    local dealer = tonumber(data.dealer.value)
    local min = math.floor(defaultPrice * ((100 - Dealers[dealer].bossSettings.Margin) / 100))
    local max = math.floor(defaultPrice * ((100 + Dealers[dealer].bossSettings.Margin) / 100))
    if inputedPrice >= min and inputedPrice <= max then
        data.veh.data.veh.price = inputedPrice
        local tblSpot = CheckShowroomSpot(dealer, spot)
        Dealers[dealer].showroom[tblSpot].price = inputedPrice
        local sendMeta = json.encode(Dealers[dealer].showroom)
        MySQL.Async.execute('UPDATE `dealerships` SET `showroom` = @sendMeta WHERE `id` = @id', {['@sendMeta'] = sendMeta, ['@id'] = Dealers[dealer].id }, function()
            TriggerClientEvent('pw_vehicleshop:client:updatePriceShowroom', -1, inputedPrice, spot, _src, data.veh.data.veh, dealer, showroom)
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Your set price exceeds the margin'})
        TriggerClientEvent('pw_vehicleshop:client:modifyPriceForm', _src)
    end
end)

RegisterServerEvent('pw_vehicleshop:server:processPrice')
AddEventHandler('pw_vehicleshop:server:processPrice', function(data)
    local _src = source

    local oldPrice = tonumber(data.veh.data.veh.price)
    local defaultPrice = tonumber(data.veh.data.veh.defaultPrice)
    local inputedPrice = tonumber(data.price.value)
    local dealer = tonumber(data.dealer.value)
    local min = math.floor(defaultPrice * ((100 - Dealers[dealer].bossSettings.Margin) / 100))
    local max = math.floor(defaultPrice * ((100 + Dealers[dealer].bossSettings.Margin) / 100))
    if inputedPrice >= min and inputedPrice <= max then
        TriggerClientEvent('pw_vehicleshop:client:updatePrice', _src, inputedPrice)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Your set price exceeds the margin'})
        TriggerClientEvent('pw_vehicleshop:client:modifyPriceForm', _src)
    end
end)

function CheckStock(model)
    local result
    local processed = false
    MySQL.Async.fetchAll('SELECT * FROM `avaliable_vehicles` WHERE `model` = @model', {['@model'] = model}, function(res)
        result = res
        processed = true
    end)
    repeat Wait(0) until processed == true
    return (result[1].maxStock - result[1].sold)
end

RegisterServerEvent('pw_vehicleshop:server:pullPaymentType')
AddEventHandler('pw_vehicleshop:server:pullPaymentType', function(data, spawn)
    local _char = exports.pw_core:getCharacter(data.target)
    local jobData = _char:Job():getJob().grade
    if jobData == "boss" then
        TriggerClientEvent('pw_vehicleshop:client:pullVehicleUse', data.target, data, spawn) -- data.target
    else
        TriggerClientEvent('pw_vehicleshop:client:pullPaymentType', data.target, data, spawn) --data.target
    end
end)

RegisterServerEvent('pw_vehicleshop:server:paymentType')
AddEventHandler('pw_vehicleshop:server:paymentType', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local veh = data.data.veh
    if CheckStock(veh.model) > 0 then
        local dealer = data.dealer
        if data.type == 'cash' then
            local curMoney = _char:Cash().getBalance()
            if curMoney >= veh.price then
                _char:Cash().removeCash(veh.price)
                local bank = exports.pw_banking:getBusinessAccount('cardealer', Dealers[dealer].id)
                local dealerCarCost = veh.defaultPrice * (Dealers[dealer].bossSettings.DealershipBuyMargin / 100)
                bank.addMoney(veh.price, 'Selling of a '..veh.name)
                bank.removeMoney(dealerCarCost, 'Purchase of a '..veh.name)
                local dealerProfit = ((veh.price - (veh.defaultPrice * (Dealers[dealer].bossSettings.DealershipBuyMargin / 100))) * (Dealers[dealer].bossSettings.DealerMargin / 100)) 
                _dealer = exports.pw_core:getCharacter(data.data.dealer)
                bank.removeMoney(dealerProfit, 'Commission for '.._dealer.getFullName() .. ' for selling a '..veh.name)
                _dealer:Cash().addCash(dealerProfit)
                TriggerEvent('pw_vehicleshop:server:registerThis', data.data.props, 'cash', data.data.props.color1, veh.model, _src, data.spawn, _dealer.getCID(), veh.price, data.use)
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Transaction successful'})
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough cash in your pocket'})
            end
        elseif data.type == 'debit' then
            data.src = _src
            TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_vehicleshop:server:pinEntered', 'server', { ['amount'] = veh.price, ['to'] = "Car Dealership", ['statement'] = 'Purchase of '..veh.name.. ' from Dealership' }, { ['data'] = data})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'There are no more available units of that model'})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:pinEntered')
AddEventHandler('pw_vehicleshop:server:pinEntered', function(data)
    local _src = source
    local veh = data.data.data.veh
    local dealer = data.data.dealer
    local bank = exports.pw_banking:getBusinessAccount('cardealer', Dealers[dealer].id)
    bank.addMoney(veh.price, 'Selling of '..veh.name)
    bank.removeMoney(dealerCarCost, 'Purchase of '..veh.name)
    local dealerProfit = ((veh.price - (veh.defaultPrice * (Dealers[dealer].bossSettings.DealershipBuyMargin / 100))) * (Dealers[dealer].bossSettings.DealerMargin / 100)) 
    _dealer = exports.pw_core:getCharacter(data.data.data.dealer)
    bank.removeMoney(dealerProfit, 'Commission for '.._dealer.getFullName() .. ' for selling a '..veh.name)
    _dealer:Cash().addCash(dealerProfit)

    TriggerClientEvent('pw_vehicleshop:client:deleteDisplayed', data.data.data.dealer)
    TriggerEvent('pw_vehicleshop:server:registerThis', data.data.data.props, 'debit', data.data.data.props.color1, veh.model, data.data.src, data.data.spawn, _dealer.getCID(), veh.price, data.data.use)
end)

RegisterServerEvent('pw_vehicleshop:server:downPaymentPaid')
AddEventHandler('pw_vehicleshop:server:downPaymentPaid', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local res = data.data.veh.data
    local veh = res.veh
    local props = res.props
    local dealer = data.data.dealer
    
    bank = exports.pw_banking:getBusinessAccount('cardealer', Dealers[dealer].id)
    local curBalance = bank.getBalance()
    
    local dealerCarCost = veh.defaultPrice * (Dealers[dealer].bossSettings.DealershipBuyMargin / 100)
    if curBalance >= dealerCarCost then
        bank.removeMoney(dealerCarCost, 'Purchase of a '..veh.name)
        bank.addMoney(res.downPayment, 'Down Payment of a '..veh.name..' made by '.._char.getFullName())
        _dealer = exports.pw_core:getCharacter(res.dealer)
        local dealerProfit = ((veh.price - (veh.defaultPrice * (Dealers[dealer].bossSettings.DealershipBuyMargin / 100))) * (Dealers[dealer].bossSettings.DealerMargin) / 100) 
        bank.removeMoney(dealerProfit, 'Commission for '.._dealer.getFullName() .. ' for selling a '..veh.name)
        _dealer:Cash().addCash(dealerProfit)
        TriggerClientEvent('pw_vehicleshop:client:deleteDisplayed', res.dealer)
        TriggerEvent('pw_vehicleshop:server:registerThis', props, 'finance', props.color1, veh.model, _src, res.spawn, _dealer.GetCID(), res.total, res.use)
        
        StartFinance(props.plate, _char.getCID(), res.weeks, res.total, res.cost, res.downPayment, _src)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Transaction failed'})
        TriggerClientEvent('pw:notification:SendAlert', res.dealer, {type = 'error', text = 'Your business account hasn\'t enough money for purchasing the car' })
    end
end)

function PaymentDue(d, h, m)
    if #activeFinances == 0 then return; end
    for i = 1, #activeFinances do
        local statusOwner = exports.pw_core:checkOnline(activeFinances[i].cid)
        if activeFinances[i].remainingWeeks == 0 then
            if activeFinances[i].failedPayments > 0 then
                TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'The vehicle with the plate '..activeFinances[i].plate.. ' is flagged for Repossession for failing to make payments on legal terms', length = 6000})
            else
                MySQL.Async.execute('DELETE FROM `vehicle_financing` WHERE `plate` = @plate', {['@plate'] = activeFinances[i].plate}, function()
                    table.remove(activeFinances, i)
                    registeredVehicles[activeFinances[i].plate] = loadVehicle(activeFinances[i].plate)
                    registeredVehicles[activeFinances[i].plate].UpdateMeta('paid', true)
                end)
                if statusOwner then
                    TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'Your financing period has ended and your debt is now fully paid for the vehicle with the plate '..activeFinances[i].plate})
                end
            end
        else
            local status
            if statusOwner then
                local _char = exports.pw_core:getCharacter(statusOwner)
                local curBank = _char:Bank():getBalance()
                if curBank >= activeFinances[i].weeklyCost then
                    _char:Bank().removeMoney(activeFinances[i].weeklyCost, 'Weekly financing payment for the plate '..activeFinances[i].plate)
                    status = true
                else
                    status = false
                end
            else
                local playerBank = exports.pw_banking:getOfflineAccount(activeFinances[i].cid)

                if playerBank.getBalance() >= activeFinances[i].weeklyCost then
                    playerBank.removeMoney(amount, 'Weekly financing payment for the plate '..activeFinances[i].plate)
                    status = true
                else
                    status = false
                end
            end

            if status then
                MySQL.Async.execute('UPDATE `vehicle_financing` SET `remainingWeeks` = `remainingWeeks` - 1, `amountLeft` = `amountLeft` - `weeklyCost` WHERE `plate` = @plate', {['@plate'] = activeFinances[i].plate}, function()
                    activeFinances[i].remainingWeeks = activeFinances[i].remainingWeeks - 1
                    activeFinances[i].amountLeft = activeFinances[i].amountLeft - activeFinances[i].weeklyCost
                    if statusOwner then
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'The weekly payment for your vehicle with the plate '..activeFinances[i].plate..' has been deducted from your bank account', length = 10000})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'Status: '..(activeFinances[i].period - activeFinances[i].remainingWeeks)..'/'..activeFinances[i].period..' weeks | Amount left: $'..math.floor(activeFinances[i].amountLeft), length = 12500})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'Failed payments: '..activeFinances[i].failedPayments, length = 15000})
                    end
                end)
            else
                MySQL.Async.execute('UPDATE `vehicle_financing` SET `remainingWeeks` = `remainingWeeks` - 1, `failedPayments` = `failedPayments` + 1 WHERE `plate` = @plate', {['@plate'] = activeFinances[i].plate}, function()
                    activeFinances[i].remainingWeeks = activeFinances[i].remainingWeeks - 1
                    activeFinances[i].failedPayments = activeFinances[i].failedPayments + 1
                    if statusOwner then
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'Failed to process the payment of your weekly financing obligations for the vehicle with the plate '..activeFinances[i].plate, length = 10000})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'inform', text = 'Status: '..activeFinances[i].remainingWeeks..'/'..activeFinances[i].period..' weeks | Amount left: $'..math.floor(activeFinances[i].amountLeft), length = 12500})
                        TriggerClientEvent('pw:notification:SendAlert', statusOwner, {type = 'error', text = 'Failed payments: '..activeFinances[i].failedPayments, length = 15000})
                    end
                end)
            end
        end
    end
end

function StartFinance(plate, ownerCid, period, total, weeklyCost, downPayment, _src)
    MySQL.Async.insert('INSERT INTO `vehicle_financing` (plate, cid, period, remainingWeeks, totalAmount, amountLeft, weeklyCost, failedPayments) VALUES (@plate, @ownerCid, @period, @period, @total, @left, @weeklyCost, 0)', 
    {   ['@plate'] = plate,
        ['@ownerCid'] = ownerCid,
        ['@period'] = period,
        ['@total'] = total,
        ['@left'] = total - downPayment,
        ['@weeklyCost'] = weeklyCost
    }, function()
        table.insert(activeFinances, { ['plate'] = plate, ['cid'] = ownerCid, ['period'] = period, ['remainingWeeks'] = period, ['totalAmount'] = total, ['amountLeft'] = total - downPayment, ['weeklyCost'] = weeklyCost, ['failedPayments'] = 0 })
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Your financing period of '..period..' weeks has started. Make sure you have the money in your bank account by the time we deduct the weekly expenses.', length = 10000})
    end)
end

RegisterServerEvent('pw_vehicleshop:server:financeAgreed')
AddEventHandler('pw_vehicleshop:server:financeAgreed', function(data)
    local _src = source
    if data.contractReview.value then
        if CheckStock(data.veh.data.veh.model) > 0 then
            data.dealer = tonumber(data.dealer.value)
            TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_vehicleshop:server:downPaymentPaid', 'server', { ['amount'] = data.veh.data.downPayment, ['to'] = "Car Dealership", ['statement'] = 'Down Payment of a '..data.veh.data.veh.name }, { ['data'] = data })
        else
            TriggerClientEvent('pw:notification:SendAlert', data.veh.data.dealer, {type = 'error', text = 'There are no more available units of that model'})
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'There are no more available units of that model'})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must agree to the terms by ticking the checkbox'})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:calculateFinance')
AddEventHandler('pw_vehicleshop:server:calculateFinance', function(data)
    local _src = source
    local veh = data.veh.data.data.veh
    local dealer = data.veh.data.data.dealer
    local dealership = tonumber(data.dealer.value)
    local weeks = tonumber(data.weeks.value)
    local totalAmount = veh.price * ((100+Dealers[dealership].bossSettings.FinancingMargin) / 100)
    local downPayment = math.floor(totalAmount * (Dealers[dealership].bossSettings.Downpayment / 100))
    local weeklyCost = math.floor((totalAmount - downPayment) / weeks)

    TriggerClientEvent('pw_vehicleshop:client:sendFinance', _src, weeks, totalAmount, weeklyCost, downPayment, data.veh.data.data, dealer, data.veh.data.spawn, data.veh.data.use)
end)

RegisterServerEvent('pw_vehicleshop:server:registerThis')
AddEventHandler('pw_vehicleshop:server:registerThis', function(vehProps, method, color, model, source, spawn, dealer, price, use)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local sendMeta = {  ['owner'] = (use == 'Personal' and _char:getCID() or use), ['originalColor'] = color, ['purchaseDate'] = os.date('%c'), ['model'] = model, ['price'] = price,
                        ['paid'] = ((method == 'cash' or method == 'debit') and true or false), ['paymentMethod'] = method, ['soldBy'] = dealer
                    }
    exports['pw_vehiclemanagement']:createVeh(_char:getCID(), vehProps, sendMeta, use, _src)
    TriggerClientEvent('pw_vehicleshop:client:vehicleSold', _src, model, vehProps, spawn)
end)

RegisterServerEvent('pw_vehicleshop:server:registerSpot')
AddEventHandler('pw_vehicleshop:server:registerSpot', function(spot, props, price, dealer)
    local _src = source
    if TblLen(Dealers[dealer].showroom) > 0 then
        local hasSpot = CheckShowroomSpot(dealer, spot)
        if hasSpot then
            Dealers[dealer].showroom[hasSpot] = nil
        end
    end
    table.insert(Dealers[dealer].showroom, { spot = spot, vehicle = props, price = price, defaultPrice = price })
    local sendMeta = json.encode(Dealers[dealer].showroom)
    MySQL.Async.execute('UPDATE `dealerships` SET `showroom` = @sendMeta WHERE `id` = @id', {['@sendMeta'] = sendMeta, ['@id'] = Dealers[dealer].id }, function()
        TriggerClientEvent('pw_vehicleshop:client:addedSpot', _src, spot, props, price)
        TriggerClientEvent('pw_vehicleshop:client:updateShowroomTable', -1, dealer, Dealers[dealer].showroom, _src)
    end)
end)

function CheckShowroomSpot(dealer, spot)
    for k,v in pairs(Dealers[dealer].showroom) do
        if v.spot == spot then
            return k
        end
    end
    return false
end

function TblLen(tbl)
    local count = 0
    if type(tbl) == 'table' then
        for _,_ in pairs(tbl) do
            count = count + 1
        end
    end
    return count
end

RegisterServerEvent('pw_vehicleshop:server:setDefaultPriceShowroom')
AddEventHandler('pw_vehicleshop:server:setDefaultPriceShowroom', function(data)
    local _src = source
    local dealer = tonumber(data.dealer)
    local setPrice = tonumber(data.default)
    local spot = tonumber(data.spot)
    local tblSpot = CheckShowroomSpot(dealer, spot)
    Dealers[dealer].showroom[tblSpot].price = setPrice
    local sendMeta = json.encode(Dealers[dealer].showroom)
    MySQL.Async.execute("UPDATE `dealerships` SET `showroom` = @sendMeta WHERE `id` = @id", { ['@sendMeta'] = sendMeta, ['@id'] = Dealers[dealer].id }, function()
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Vehicle price updated to $' .. setPrice })
        TriggerClientEvent('pw_vehicleshop:client:updateShowroomTable', -1, dealer, Dealers[dealer].showroom, _src)
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:removeShowroom')
AddEventHandler('pw_vehicleshop:server:removeShowroom', function(data)
    local _src = source
    local tblSpot = CheckShowroomSpot(data.dealer, data.spot)
    table.remove(Dealers[data.dealer].showroom, tblSpot)
    local sendMeta = json.encode(Dealers[data.dealer].showroom)
    MySQL.Async.execute('UPDATE `dealerships` SET `showroom` = @sendMeta WHERE `id` = @id', {['@sendMeta'] = sendMeta, ['@id'] = Dealers[data.dealer].id }, function()
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle removed from showroom spot #'..data.spot})
        TriggerClientEvent('pw_vehicleshop:client:deleteShowroom', -1, data.spot, data.dealer, Dealers[data.dealer].showroom)
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:updateSpotProps')
AddEventHandler('pw_vehicleshop:server:updateSpotProps', function(dealer, spot, props)
    local _src = source
    local tblSpot = CheckShowroomSpot(dealer, spot)
    Dealers[dealer].showroom[tblSpot].vehicle = props
    local sendMeta = json.encode(Dealers[dealer].showroom)
    MySQL.Async.execute('UPDATE `dealerships` SET `showroom` = @sendMeta WHERE `id` = @id', {['@sendMeta'] = sendMeta, ['@id'] = Dealers[dealer].id }, function()
        TriggerClientEvent('pw_vehicleshop:client:updateColorShowroom', -1, spot, props, dealer, Dealers[dealer].showroom)
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'Vehicle color changed successfully'})
    end)
end)

RegisterServerEvent('pw_vehicleshop:server:sendMargin')
AddEventHandler('pw_vehicleshop:server:sendMargin', function(data)
    local _src = source
    local type = data.margin.value
    local dealer = tonumber(data.dealer.value)
    if type == 'FinanceWeeks' then
        Dealers[dealer].bossSettings[type] = { tonumber(data.week1.value), tonumber(data.week2.value), tonumber(data.week3.value) }
    else
        Dealers[dealer].bossSettings[type] = tonumber(data.range.value)
    end
    UpdateSettings(_src, dealer, 'margins')
    
end)

RegisterServerEvent('pw_vehicleshop:server:contractSigned')
AddEventHandler('pw_vehicleshop:server:contractSigned', function(res)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Job().setJob('cardealer', tonumber(res.grade.value))
    TriggerClientEvent('pw:notification:SendAlert', tonumber(res.bossSrc.value), {type = 'inform', text = _char.getFullName() .. " signed the contract and is now one of your employees"})
end)

RegisterServerEvent('pw_vehicleshop:server:sendContractForm')
AddEventHandler('pw_vehicleshop:server:sendContractForm', function(res)
    local target = tonumber(res.target.value)
    local salary = tonumber(res.salary.value)
    local grade = tonumber(res.grade.value)
    local bossSrc = tonumber(res.bossSrc.value)
    local formCopy = res.formCopy.data
    TriggerClientEvent('pw_vehicleshop:client:sendContractForm', target, formCopy, salary, grade, bossSrc)
end)

RegisterServerEvent('pw_vehicleshop:server:setNewSalary')
AddEventHandler('pw_vehicleshop:server:setNewSalary', function(data)
    local _src = source
    local statusEmployee = exports.pw_core:checkOnline(data.data.data.cid)
    local dealer = tonumber(data.dealer.value)
    local _char
    if statusEmployee then
        _char = exports.pw_core:getCharacter(statusEmployee)
    else
        _char = exports.pw_core:getOffline(data.data.data.cid)
    end
    _char:Job().setJob('cardealer', _char:Job().getJob().grade, Dealers[dealer].id)
    local raise = tonumber(data.range.value) - data.data.data.job.wages
    if raise > 0 then
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You received a $'..raise..' raise! (New salary: $'..tonumber(data.range.value)..')'})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You raised '.. data.data.data.name ..'\'s salary to $'..tonumber(data.range.value)})
    else
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'Your salary was lowered by $'..(raise * -1)..' (New salary: $'..tonumber(data.range.value)..')'})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You lowered '.. data.data.data.name ..'\'s salary to $'..tonumber(data.range.value)})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:setNewGrade')
AddEventHandler('pw_vehicleshop:server:setNewGrade', function(data)
    local _src = source
    local statusEmployee = exports.pw_core:checkOnline(data.data.data.result.cid)
    local dealer = tonumber(data.dealer.value)
    local _char
    if statusEmployee then
        _char = exports.pw_core:getCharacter(statusEmployee)
    else
        _char = exports.pw_core:getOffline(data.data.data.result.cid)
    end
    --local grades = json.decode(data.data.data.grades[1].grades)
    local gradeName
    
    for k, v in pairs(data.data.data.grades) do
        if v.grade == data.grades.value then
            gradeName = v.label
        end
    end    
    _char:Job().setJob('cardealer', data.grades.value, Dealers[dealer].id)
    if statusEmployee then
        TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You were promoted/demoted to '..gradeName})
    end
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You promoted/demoted '.. data.data.data.result.name ..' to '..gradeName})
end)

RegisterServerEvent('pw_vehicleshop:server:fireStaff')
AddEventHandler('pw_vehicleshop:server:fireStaff', function(data)
    local _src = source
    local pSrc = exports.pw_core:checkOnline(data.data.data.cid)
    local _char
    if pSrc > 0 then
        _char = exports.pw_core:getCharacter(pSrc)
    else
        _char = exports.pw_core:getOfflineCharacter(data.data.data.cid)
    end
    if data.fire.value then
        _char:Job().setJob("unemployed", "unemployed")
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You have fired '..data.data.data.name})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You have to sign the contract termination form'})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:updateTestDriveTimer')
AddEventHandler('pw_vehicleshop:server:updateTestDriveTimer', function(data)
    local _src = source
    local dealer = tonumber(data.dealer.value)
    Dealers[dealer].bossSettings.TestDriveTimer = tonumber(data.range.value)
    UpdateSettings(_src, dealer, 'boss')
end)

RegisterServerEvent('pw_vehicleshop:server:returnTestDriveDeposit')
AddEventHandler('pw_vehicleshop:server:returnTestDriveDeposit', function(props)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local totalDamage = math.abs(2000 - props.bodyHealth - props.engineHealth) / 2000
    local depositToReturn, overDamage
    if totalDamage > 0.10 then
        depositToReturn = math.ceil(testDriveDeposit[_src] * (1-totalDamage))
        overDamage = true
    else
        depositToReturn = testDriveDeposit[_src]
    end
    _char:Cash().addCash(depositToReturn)
    testDriveDeposit[_src] = 0
    if overDamage then
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You received $'..depositToReturn..' back (' .. (math.floor((1-totalDamage) * 100))..'% of your deposit)', length = 6000})
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You delivered the car with '..(math.ceil(totalDamage * 100))..'% of damage', length = 6000})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You received $'..depositToReturn..' back (full deposit)', length = 6000})
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You delivered the car with less than 10% of damage', length = 6000})
    end
end)

RegisterServerEvent('pw_vehicleshop:server:resetTestDriveDeposit')
AddEventHandler('pw_vehicleshop:server:resetTestDriveDeposit', function()
    local _src = source
    testDriveDeposit[_src] = 0
end)

function UpdateSettings(_src, tableId, menu)
    local sendMeta = json.encode(Dealers[tableId].bossSettings)
    MySQL.Async.execute("UPDATE `dealerships` SET `bossSettings` = @meta WHERE `id` = @id", {['@meta'] = sendMeta, ['@id'] = Dealers[tableId].id}, function()
        TriggerClientEvent('pw_vehicleshop:client:updateConfig', -1, tableId, Dealers[tableId].bossSettings)
        if _src then
            if menu == 'margins' then
                TriggerClientEvent('pw_vehicleshop:client:openMargins', _src)
            elseif menu == 'boss' then
                TriggerClientEvent('pw_vehicleshop:bossMenu', _src)
            end
        end
    end)
end

PW.RegisterServerCallback('pw_vehicleshop:server:checkMoneyForTestDrive', function(source, cb, data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local cost = tonumber(data.price)
    if cost > 0 then
        local maths = cost * 0.01
        local calcCost = (maths > 500 and math.ceil(maths) or 500)
        testDriveDeposit[_src] = calcCost
        if _char:Cash().getBalance() >= testDriveDeposit[_src] then
            _char:Cash().removeCash(testDriveDeposit[_src])
            cb(true, testDriveDeposit[_src])
        else
            testDriveDeposit[_src] = 0
            cb(false, calcCost)
        end
    end
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getSalary', function(source, cb, id)
    local statusId = exports.pw_core:checkOnline(id)
    local _char
    if statusId then
        _char = exports.pw_core:getCharacter(statusId)
    else
        _char = exports.pw_core:getOffline(id)
    end
    cb(_char:Job().getJob().salery)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getStaff', function(source, cb, workplace)
    local staffList = exports.pw_core:getStaff('cardealer', workplace)
    cb(staffList)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getGrades', function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `job_name` = 'cardealer'", {}, function(res)
        cb(res)
    end)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:getNearbyName', function(source, cb, id)
    local _char = exports.pw_core:getCharacter(id)
    if _char == nil then cb(false); end
    local name = _char.getFullName()
    if name ~= nil then
        cb(name)
    else
        cb(false)
    end
end)

PW.RegisterServerCallback('pw_vehicleshop:server:currentShowroom', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM `showroom_vehicles`', {}, function(res)
        cb(res)
    end)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:requestVehicles', function(source, cb)
    cb(vehicles)
end)

PW.RegisterServerCallback('pw_vehicleshop:server:checkEnoughMoney', function(source, cb, money)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    if _char:Cash().getBalance() >= money then
        cb(true)
    else
        cb(false)
    end
end)

exports('vehicleMakes', function(model)
    for k, v in pairs(Config.Makes) do
        for meh, teh in pairs(v) do
            if string.lower(teh) == string.lower(model) then
                return k
            end
        end
    end
    return nil    
end)