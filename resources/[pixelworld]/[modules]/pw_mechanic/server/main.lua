Vehicles = {}
local proceed = false
PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    for k, v in pairs(Config.Locations) do 
        TriggerEvent('pw_banking:business:createAccount', 'mechanic', k, 1000000, {})
    end

    MySQL.Async.fetchScalar("SELECT `settings` FROM `config` WHERE `resource` = 'mechanic'", {}, function(res)
        if res == nil then
            for k,v in pairs(Config.Locations) do
                Config.MySQL[k] = Config.Defaults
            end

            MySQL.Async.execute("UPDATE `config` SET `settings` = @meta WHERE `resource` = 'mechanic'", { ['@meta'] = json.encode(Config.MySQL) }, function() end)
        else
            local decode = json.decode(res)
            local needsUpdate = false
            if #decode ~= #Config.Locations then
                for i = 1, #Config.Locations do
                    if decode[i] == nil then
                        needsUpdate = true
                        Config.MySQL[i] = Config.Defaults
                    else
                        Config.MySQL[i] = decode[i]
                    end
                end

                if needsUpdate then
                    MySQL.Async.execute("UPDATE `config` SET `settings` = @meta WHERE `resource` = 'mechanic'", { ['@meta'] = json.encode(Config.MySQL) }, function() end)
                end
            else
                Config.MySQL = decode
            end
        end
    end)
end)

RegisterServerEvent('pw_mechanic:server:getVeh')
AddEventHandler('pw_mechanic:server:getVeh', function(data)
    local _src = source
    MySQL.Async.execute("UPDATE `owned_vehicles` SET `stored_garage` = 0, `stored_garagetype` = 'None', `stored_garageid` = 0 WHERE `vehicle_id` = @vin", {['@vin'] = data.vin }, function() 
        TriggerClientEvent('pw_mechanic:client:spawnVehicle', _src, data.props, data.garage)
    end)
end)

RegisterServerEvent('pw_mechanic:server:toggleDuty')
AddEventHandler('pw_mechanic:server:toggleDuty', function()
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Job().toggleDuty()
    TriggerClientEvent('pw_mechanic:client:openMechanicActions', _src)
end)

RegisterServerEvent('pw_mechanic:server:storeVehicle')
AddEventHandler('pw_mechanic:server:storeVehicle', function(vin, garage)
    MySQL.Async.execute("UPDATE `owned_vehicles` SET `stored_garage` = 1, `stored_garagetype` = 'Business', `stored_garageid` = @garage WHERE `vehicle_id` = @vin", {['@vin'] = vin, ['@garage'] = garage }, function() end)
end)

RegisterServerEvent('pw_mechanic:server:updateProps')
AddEventHandler('pw_mechanic:server:updateProps', function(vin, props, vNet)
    local vehicle = exports.pw_vehiclemanagement:getVehicleByVID(vin)
    if vehicle then
        vehicle.SetVehicleProperties(props)
    end
    TriggerClientEvent('pw_mechanic:server:updateEveryone', -1, props, vNet)
end)

function GetMakeParts(make)
    local avg, sendParts, tier
    MySQL.Async.fetchScalar("SELECT AVG(`price`) FROM `avaliable_vehicles` WHERE `make` = @make", { ['@make'] = make }, function(avrg)
        avg = math.floor(avrg)
        for i = 1, #Config.AvgMakes do
            if avg < Config.AvgMakes[i].maxValue then
                sendParts = Config.AvgMakes[i].cost
                tier = i
                break
            end
        end
        if sendParts == nil then
            sendParts = 5
            tier = 4
        end
    end)

    repeat Wait(0) until sendParts ~= nil
    
    return sendParts, tier
end

function GetPiecePrice(cat, opt, level, withParts)
    local sendHour, sendParts, tier
    local make = exports.pw_vehicleshop:vehicleMakes(GetDisplayNameFromVehicleModel(curVeh.props['model']))
    if withParts == nil then withParts = false; end
    if make == nil then make = 'Stock'; end
    if not withParts then
        for k,v in pairs(Config.Prices) do
            if k == make then
                sendHour = v[cat]
            end
        end
    end
    
    sendParts, tier = GetMakeParts(make)

    if level ~= nil then
        if not level or level == -1  then
            if not withParts then
                return sendHour, 0
            else
                return 0, 0
            end
        elseif level == true then level = 1; end        
    else
        level = 1
    end
    if not withParts then
        sendParts = sendParts + (level * tier)
        return sendHour, sendParts
    else
        return sendParts, tier
    end
end

RegisterServerEvent('pw_mechanic:server:checkout')
AddEventHandler('pw_mechanic:server:checkout', function(parts, garage)
    local _src = source
    local success = true
    for k,v in pairs(parts) do
        if v.repair == nil then
            exports.pw_inventory:getItemCount(19, garage, v.item, function(partsCount)
                if partsCount < v.qty then
                    success = false
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough '.. v.itemLabel .. ' parts (Missing: '..(v.qty - partsCount)..")", length = 6000})
                    TriggerClientEvent('pw_mechanic:client:openMenu', _src, 'main', garage)
                end
            end)
        end
    end

    if success then
        TriggerClientEvent('pw_mechanic:client:checkoutParts', _src, parts, garage)
    end
end)

RegisterServerEvent('pw_mechanic:server:pinEntered')
AddEventHandler('pw_mechanic:server:pinEntered', function(data)
    local _src = source
    local garage = data.data.curGarage
    local parts = data.data.stuff.parts.data
    local plate = data.data.vehPlate
    local mech = tonumber(data.data.stuff.mech.value)
    local vin = data.data.vehVin

    local allGood = true
    for i = 1, #parts do
        if parts[i].repair == nil then
            exports.pw_inventory:getItemCount(19, garage, parts[i].item, function(partsCount)
                if partsCount < parts[i].qty then
                    allGood = false
                end
            end)
            if not allGood then break; end
        end
    end
    if allGood then
        local bank = exports.pw_banking:getBusinessAccount('mechanic', garage)
        for i = 1, #parts do
            local partValue 
            if parts[i].repair == nil then
                partValue = parts[i].hours + ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and parts[i].partsCost or 0)
                exports['pw_inventory']:removeItemFromInventory(19, garage, parts[i].item, parts[i].qty)
                bank.addMoney(partValue, 'Installation of '..parts[i].itemLabel..' (Hour Rate: $'..parts[i].hours..((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and ' + Parts Cost: $'..parts[i].partsCost or "")..') on vehicle with plate '..plate)
            else
                partValue = parts[i].partsCost
                bank.addMoney(partValue, 'Service: '..parts[i].label.. ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and 'Service Cost: $'..parts[i].partsCost or "")..') on vehicle with plate '..plate)
            end
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Payment successful'})
        TriggerClientEvent('pw:notification:SendAlert', mech, {type = 'success', text = 'Payment confirmed'})
        CreatePendingInstall(vin, plate, mech, garage, parts)

        TriggerClientEvent('pw_mechanic:client:emptyCart', mech, 'main', garage)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'There was a problem processing your order'})
        TriggerClientEvent('pw:notification:SendAlert', mech, {type = 'error', text = 'One or more parts aren\'t available.'})
        TriggerClientEvent('pw_mechanic:client:openMenu', mech, 'main', garage)
    end
end)

RegisterServerEvent('pw_mechanic:server:fireStaff')
AddEventHandler('pw_mechanic:server:fireStaff', function(data)
    local _src = source
    local pSrc = exports.pw_core:checkOnline(data.data.data.cid)
    local _char
    if not pSrc then
        _char = exports.pw_core:getOffline(data.data.data.cid)
    else
        _char = exports.pw_core:getCharacter(pSrc)
    end
    if data.fire.value then
        _char:Job().setJob("unemployed", "unemployed")
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You have fired '..data.data.data.name})
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You have to sign the contract termination form'})
    end
end)

RegisterServerEvent('pw_mechanic:server:payDebit')
AddEventHandler('pw_mechanic:server:payDebit', function(data)
    local _src = source
    local parts = data.stuff.parts.data
    local totalAmount = 0

    for i = 1, #parts do
        totalAmount = totalAmount + (parts[i].hours or 0) + ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and parts[i].partsCost or 0)
    end

    TriggerClientEvent('pw_debitcard:openPinTerminal', _src, 'pw_mechanic:server:pinEntered', 'server', { ['amount'] = totalAmount, ['to'] = "Mechanics", ['statement'] = 'Payment of services' }, { ['data'] = data, ['amt'] = totalAmount})
end)

RegisterServerEvent('pw_mechanic:server:payStuff')
AddEventHandler('pw_mechanic:server:payStuff', function(data)
    local _src = source
    
    local parts = data.stuff.parts.data
    local totalAmount = 0

    for i = 1, #parts do
        totalAmount = totalAmount + (parts[i].hours or 0) + ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and parts[i].partsCost or 0)
    end

    local _char = exports.pw_core:getCharacter(_src)
    if data.type == 'cash' then
        local allGood = true
        for i = 1, #parts do
            if parts[i].repair == nil then
                exports.pw_inventory:getItemCount(19, tonumber(data.stuff.garage.value), parts[i].item, function(partsCount)
                    if partsCount < parts[i].qty then
                        allGood = false
                    end
                end)
                if not allGood then break; end
            end
        end
        if allGood then
            _char:Cash().removeCash(totalAmount, function(done)
                if done then
                    local bank = exports.pw_banking:getBusinessAccount('mechanic', tonumber(data.stuff.garage.value))
                    for i = 1, #parts do
                        local partValue 
                        if parts[i].repair == nil then
                            partValue = parts[i].hours + ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and parts[i].partsCost or 0)
                            exports['pw_inventory']:removeItemFromInventory(19, tonumber(data.stuff.garage.value), parts[i].item, parts[i].qty)
                            bank.addMoney(partValue, 'Installation of '..parts[i].itemLabel..' (Hour Rate: $'..parts[i].hours..((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and ' + Parts Cost: $'..parts[i].partsCost or "")..') on vehicle with plate '..data.stuff.veh.data.plate)
                        else
                            partValue = parts[i].partsCost
                            bank.addMoney(partValue, 'Service: '..parts[i].label.. ((parts[i].partsCost ~= nil and parts[i].partsCost > 0) and 'Service Cost: $'..parts[i].partsCost or "")..') on vehicle with plate '..data.stuff.veh.data.plate)
                        end
                    end
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Payment successful'})
                    TriggerClientEvent('pw:notification:SendAlert', tonumber(data.stuff.mech.value), {type = 'success', text = 'Payment confirmed'})
                    CreatePendingInstall(data.vehVin, data.vehPlate, tonumber(data.stuff.mech.value), tonumber(data.stuff.garage.value), parts)
                    TriggerClientEvent('pw_mechanic:client:emptyCart', tonumber(data.stuff.mech.value), 'main', tonumber(data.stuff.garage.value))
                else
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough cash'})
                    TriggerClientEvent('pw:notification:SendAlert', tonumber(data.stuff.mech.value), {type = 'error', text = 'Customer hasn\'t got enough cash'})
                    TriggerClientEvent('pw_mechanic:client:openMenu', tonumber(data.stuff.mech.value), 'main', tonumber(data.stuff.garage.value))
                end
            end)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'There was a problem processing your order'})
            TriggerClientEvent('pw:notification:SendAlert', tonumber(data.stuff.mech.value), {type = 'error', text = 'One or more parts aren\'t available.'})
            TriggerClientEvent('pw_mechanic:client:openMenu', tonumber(data.stuff.mech.value), 'main', tonumber(data.stuff.garage.value))
        end
    end
end)

function CreatePendingInstall(vin, plate, mech, garage, parts)
    local sendInstall = json.encode(parts)
    local mechChar = exports.pw_core:getCharacter(mech)
    local meta = { ['mech'] = mechChar.getFullName(), ['garage'] = garage, ['date'] = os.date('%d/%m/%Y %H:%M') }
    local sendMeta = json.encode(meta)
    proceed = false
    MySQL.Async.insert("INSERT INTO `pending_mechanic` (`vehicle_id`, `plate`, `install`, `meta`) VALUES (@vin, @plate, @install, @meta)", { ['@vin'] = vin, ['@plate'] = plate, ['@install'] = sendInstall, ['@meta'] = sendMeta }, function(inserted)
        MySQL.Async.fetchAll("SELECT * FROM `pending_mechanic` WHERE `order_id` = @id", { ['@id'] = inserted }, function(insertedData)
            if insertedData[1] then
                TriggerClientEvent('pw_mechanic:client:newOrder', mech, insertedData[1])
            end
            proceed = true
        end)
    end)
    repeat Wait(0) until proceed == true
end

RegisterServerEvent('pw_mechanic:server:sendFormAmount')
AddEventHandler('pw_mechanic:server:sendFormAmount', function(data)
    local _src = source
    local parts = data.parts.data
    
    local gucci = true
    for i = 1, #parts do
        if data['cost'..i] ~= nil then
            local cost = tonumber(data['cost'..i].value)
            if (cost > 0 and parts[i].repair == nil and cost > parts[i].hours) or (cost > 0 and parts[i].repair) then
                parts[i].partsCost = cost
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Invalid amount for Item #'..i..(parts[i].repair and ' service' or ' parts')..' cost. Try again.', length = 5000})
                TriggerClientEvent('pw_mechanic:client:openMenu', _src, 'main', tonumber(data.garage.value))
                gucci = false
                break
            end
        end
    end
    if gucci then
        TriggerClientEvent('pw_mechanic:client:showBill', tonumber(data.target.value), parts, tonumber(data.mech.value), tonumber(data.garage.value), data.veh.data, data.vin.value)
    end
end)

RegisterServerEvent('pw_mechanic:server:contractSigned')
AddEventHandler('pw_mechanic:server:contractSigned', function(res)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Job().setJob('mechanic', res.grade.value, tonumber(res.garage.value))
    TriggerClientEvent('pw:notification:SendAlert', tonumber(res.bossSrc.value), {type = 'inform', text = _char.getFullName() .. " signed the contract and is now one of your employees"})
end)

RegisterServerEvent('pw_mechanic:server:sendContractForm')
AddEventHandler('pw_mechanic:server:sendContractForm', function(res)
    local target = tonumber(res.target.value)
    local grade = res.grade.value
    local bossSrc = tonumber(res.bossSrc.value)
    local garage = tonumber(res.garage.value)
    local formCopy = res.formCopy.data
    TriggerClientEvent('pw_mechanic:client:sendContractForm', target, formCopy, grade, bossSrc, garage)
end)

RegisterServerEvent('pw_mechanic:server:setNewGrade')
AddEventHandler('pw_mechanic:server:setNewGrade', function(data)
    local _src = source
    local statusEmployee = exports.pw_core:checkOnline(data.data.data.result.cid)
    local _char
    if statusEmployee then
        _char = exports.pw_core:getCharacter(statusEmployee)
    else
        _char = exports.pw_core:getOffline(data.data.data.result.cid)
    end
    _char:Job().setJob('mechanic', data.grades.value, tonumber(data.data.data.garage))
    local newGrade, newLevel
    for k,v in pairs(data.data.data.grades) do
        if v.value == data.grades.value then
            newGrade = v.label
            newLevel = v.level
        end
    end
    if newGrade == nil then newGrade = 'Undefined'; end
    if data.data.data.result.job.grade_level < tonumber(newLevel) then
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You were promoted to '..newGrade})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You promoted '.. data.data.data.result.name ..' to '..newGrade})
    else
        if statusEmployee then
            TriggerClientEvent('pw:notification:SendAlert', statusEmployee, {type = 'inform', text = 'You were demoted to '..newGrade})
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = 'You demoted '.. data.data.data.result.name ..' to '..newGrade})
    end    
end)


RegisterServerEvent('pw_mechanic:server:changeRates')
AddEventHandler('pw_mechanic:server:changeRates', function(res)
    local _src = source
    local newRate = tonumber(res.range.value)
    local rate = res.rates.data.type
    local garage = res.rates.data.garage

    Config.MySQL[garage][rate] = newRate
    local newSets = json.encode(Config.MySQL)
    MySQL.Async.execute("UPDATE `config` SET `settings` = @meta WHERE `resource` = 'mechanic'", { ['@meta'] = newSets }, function()
        TriggerClientEvent('pw_mechanic:client:updateRates', -1, garage, rate, newRate)
        TriggerClientEvent('pw_mechanic:client:openRates', _src, garage)
    end)
end)

RegisterServerEvent('pw_mechanic:server:deletePending')
AddEventHandler('pw_mechanic:server:deletePending', function(vin, garage, id)
    MySQL.Async.execute("DELETE FROM `pending_mechanic` WHERE `order_id` = @id", { ['@id'] = id })
end)

RegisterServerEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(vehicle, seat, name)
    local _src = source
    TriggerClientEvent('pw_mechanic:client:enterVehCheck', _src, vehicle)
end)

RegisterServerEvent('baseevents:leftVehicle')
AddEventHandler('baseevents:leftVehicle', function(vehicle, seat, name)
    local _src = source
    TriggerClientEvent('pw_mechanic:client:exitVehCheck', _src, vehicle)
end)

PW.RegisterServerCallback('pw_mechanic:server:getPendings', function(source, cb, garage)
    MySQL.Async.fetchAll("SELECT * FROM `pending_mechanic`", {}, function(data)
        if data then
            local gotOne = false
            for k,v in pairs(data) do
                local dCode = json.decode(v.meta)
                if dCode.garage == garage then
                    gotOne = true
                else
                    data[k] = nil
                end
            end
            if gotOne then
                cb(data)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_mechanic:server:getPending', function(source, cb, vin, garage)
    MySQL.Async.fetchAll("SELECT * FROM `pending_mechanic` WHERE `vehicle_id` = @vin", { ['@vin'] = vin }, function(data)
        if data then
            local sent = false
            for k,v in pairs(data) do
                local dCode = json.decode(v.meta)
                if dCode.garage == garage then
                    sent = true
                    cb(data[k])
                    break
                end
            end
            if not sent then cb(false); end
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_mechanic:server:getMakeAvg', function(source, cb, make)
    MySQL.Async.fetchScalar("SELECT AVG(`price`) FROM `avaliable_vehicles` WHERE `make` = @make", { ['@make'] = make }, function(avg)
        cb(avg)
    end)
end)

PW.RegisterServerCallback('pw_mechanic:server:getStaff', function(source, cb, garage)
    local staffList = exports.pw_core:getStaff('mechanic', garage)
    cb(staffList)
end)

PW.RegisterServerCallback('pw_mechanic:server:getConfig', function(source, cb)
    cb(Config.MySQL)
end)

PW.RegisterServerCallback('pw_mechanic:server:getVehicleJob', function(source, cb, vin)
    local vehicle = exports.pw_vehiclemanagement:getVehicleByVID(vin)
    cb(vehicle.GetOwner())
end)

PW.RegisterServerCallback('pw_mechanic:server:getJobGarage', function(source, cb, garage)
    MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `stored_garage` = 1 AND `stored_garagetype` = 'Business' AND `stored_garageid` = @garage AND `use` = 'Business'", { ['@garage'] = garage }, function(vehicles)
        if vehicles ~= nil and countTableSize(vehicles) > 0 then
            local sendTable = {} 
            for k,v in pairs(vehicles) do
                local meta = json.decode(v.vehicle_metainformation)
                if meta.owner == 'mechanic' then
                    table.insert(sendTable, { ['props'] = json.decode(v.vehicle_information), ['vid'] = v.vehicle_id })
                end
            end

            if #sendTable > 0 then
                cb(sendTable)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)


PW.RegisterServerCallback('pw_mechanic:server:getGrades', function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `job_name` = 'mechanic'", {}, function(res)
        cb(res)
    end)
end)

exports.pw_chat:AddChatCommand('tow', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_mechanic:client:tow', _src)
end, {
    help = "Tow a vehicle",
    params = {}
}, -1, { "mechanic" })

function countTableSize(table)
    local n = 0
    for k, v in pairs(table) do
        n = n + 1
    end
    return n
end