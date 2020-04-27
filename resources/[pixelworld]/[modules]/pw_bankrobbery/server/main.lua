PW = nil
Banks, CardReaders = {}, {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `banks`", {}, function(banks)
        if banks ~= nil and banks[1] ~= nil then
            Banks = banks
            for i = 1, #Banks do
                Banks[i].coords                 = json.decode(Banks[i].coords)
                Banks[i].cashiercoords          = json.decode(Banks[i].cashiercoords)
                Banks[i].cashiercoords.open     = false
                Banks[i].cashiercoords.disabled = false
                Banks[i].vaults                 = json.decode(Banks[i].vaults)
                Banks[i].vaults.open            = false
                Banks[i].vaults.disabled        = false
                Banks[i].vaultgate              = json.decode(Banks[i].vaultgate)
                Banks[i].vaultgate.open         = false
                Banks[i].vaultgate.disabled     = false
                if Banks[i].beforevaults ~= nil then
                    Banks[i].beforevaults           = json.decode(Banks[i].beforevaults)
                    Banks[i].beforevaults.open      = false
                    Banks[i].beforevaults.disabled  = false
                end

                if Banks[i].finalgate ~= nil then
                    Banks[i].finalgate              = json.decode(Banks[i].finalgate)
                    Banks[i].finalgate.open         = false
                    Banks[i].finalgate.disabled     = false
                end
                Banks[i].vg_spots               = json.decode(Banks[i].vg_spots)
                Banks[i].m_spots                = json.decode(Banks[i].m_spots)

                if Banks[i].bankType == 'Small' or Banks[i].bankType == 'Paleto' then
                    for j = 1, #Banks[i].cashiercoords.counters do
                        Banks[i].cashiercoords.counters[j].open = false
                    end
                end

                for j = 1, #Banks[i].vg_spots do
                    Banks[i].vg_spots[j].open = false
                end

                for j = 1, #Banks[i].m_spots do
                    Banks[i].m_spots[j].open = false
                end
            end
        end

        MySQL.Async.fetchScalar("SELECT `settings` FROM `config` WHERE `resource` = 'bankcardreaders'", {}, function(locations)
            if locations ~= nil then
                CardReaders = json.decode(locations)
            end
        end)
    end)
end)

RegisterServerEvent('pw_bankrobbery:server:readCard')
AddEventHandler('pw_bankrobbery:server:readCard', function(bank, hours, universal, data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local charEmail = _char.getEmail()

    local message
    if universal then
        message = "Vault Universal Card info:<hr><b>Bank: <span class='text-primary'>Any</span><br>Shift: <span class='text-primary'>Any</span>"
    else
        message = "Vault Card info:<hr><b>Bank: <span class='text-primary'>" .. Banks[bank].name .. "</span><br>Shift: <span class='text-primary'>" .. (hours[1] < 10 and "0"..hours[1] or hours[1]) .. "h</span> - <span class='text-primary'>" .. (hours[2] < 10 and "0"..hours[2] or hours[2]) .. "h</span>"
    end

    TriggerEvent('pw_phone:server:sendEmail', charEmail, 'Bank Card Info', message)
    _char:Inventory():Add().Slot(1, 'vaultcard', 1, { ['decoded'] = true }, data.metaprivate, data.slot)
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == "screwdriver" then
        TriggerClientEvent('pw_bankrobbery:client:usedScrewdriver', _src)
    elseif data.item == "lockpick" then
        TriggerClientEvent('pw_bankrobbery:client:usedLockpick', _src, data)
    elseif data.item == "usbhack" then
        TriggerClientEvent('pw_bankrobbery:client:usedUsbHack', _src, data)
    elseif data.item == 'vaultcard' then
        TriggerClientEvent('pw_bankrobbery:client:usedVaultCard', _src, data)
    elseif data.item == 'thermite' then
        TriggerClientEvent('pw_bankrobbery:client:usedThermite', _src, data)
    end
end)

RegisterServerEvent('pw_bankrobbery:server:removeItem')
AddEventHandler('pw_bankrobbery:server:removeItem', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    _char:Inventory():Remove().Slot(data.slot, 1)
end)

RegisterServerEvent('pw_bankrobbery:server:bankLockdown')
AddEventHandler('pw_bankrobbery:server:bankLockdown', function(bank, state)
    if state then
        if Banks[bank].bankOpen then
            ChangeBankState(bank, 'bankOpen', false)
            PW.SetTimeout(Config.BankLockdown * 1000, function()
                ChangeBankState(bank, 'bankOpen', true)
            end)
        end
    else
        ChangeBankState(bank, 'bankOpen', true)
    end
end)

RegisterServerEvent('pw_bankrobbery:server:disableHacking')
AddEventHandler('pw_bankrobbery:server:disableHacking', function(bank, type, state)
    if state then
        PW.SetTimeout((type == 'cashiercoords' and Config.CountersLockdown or Config.VaultGateScannerLockdown) * 1000, function()
            ChangeHackingState(bank, type, true)
        end)
    else
        ChangeHackingState(bank, type, false)
    end
end)

function ChangeHackingState(bank, type, state)
    Banks[bank][type].disabled = state
    TriggerClientEvent('pw_bankrobbery:client:disableHacking', -1, bank, type, state)
end

function ChangeBankState(bank, type, state)
    Banks[bank][type] = state
    TriggerClientEvent('pw_bankrobbery:client:modifyBank', -1,  bank, type, state)
    TriggerEvent('pw_banking:server:modifyBank', bank, type, state)
end

RegisterServerEvent('pw_bankrobbery:server:awardVaultGoods')
AddEventHandler('pw_bankrobbery:server:awardVaultGoods', function(bank)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    math.randomseed(os.time())

    if Banks[bank].bankType == 'Small' then
        local awardGoods = math.random(Config.VaultValuableGoods.min, Config.VaultValuableGoods.max)

        if awardGoods > 0 then
            _char:Inventory():Add().Default(1, 'valuegood', awardGoods, {}, {}, function(done) end)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found ' .. awardGoods .. ' valuable goods inside this box' })
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'This box was empty' })
        end
    elseif Banks[bank].bankType == 'Big' then
        local bagMoney = math.random(Config.MoneyBags.min, Config.MoneyBags.max)
        _char:Inventory():Add().Default(1, 'moneybag', 1, { ['amount'] = bagMoney }, {}, function(done) end)
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found a bag with some money inside' })
    else
        local bagChance = math.random(1,100)
        if bagChance <= Config.PaletoBagChance then
            local bagCash = math.random(Config.PaletoMoneyBags.min, Config.PaletoMoneyBags.max)
            _char:Inventory():Add().Default(1, 'moneybag', 1, { ['amount'] = bagCash }, {}, function(done) end)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found a bag with some money inside' })
        else
            local awardGoods = math.random(Config.VaultValuableGoods.min, Config.VaultValuableGoods.max)

            if awardGoods > 0 then
                _char:Inventory():Add().Default(1, 'valuegood', awardGoods, {}, {}, function(done) end)
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found ' .. awardGoods .. ' valuable goods inside this box' })
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'This box was empty' })
            end
        end
    end
end)

RegisterServerEvent('pw_bankrobbery:server:syncThermite')
AddEventHandler('pw_bankrobbery:server:syncThermite', function(bank, location, obj)
    local _src = source
    if bank ~= nil then
        TriggerClientEvent('pw_bankrobbery:client:startThermiteFire', -1, bank, location, _src, obj)
    end
end)

RegisterServerEvent('pw_bankrobbery:server:awardVaultMoney')
AddEventHandler('pw_bankrobbery:server:awardVaultMoney', function(bank)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    math.randomseed(os.time())

    local awardMoney = math.random(Config.VaultMoney.min, Config.VaultMoney.max)

    if awardMoney > 0 then
        _char:Cash().addCash(awardMoney, function(done)
            if done then
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found $' .. awardMoney .. ' inside this box' })
            end
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'This box was empty' })
    end

    if Banks[bank].bankType == 'Big' then
        local awardGoods = math.random(Config.VaultValuableGoods.min, Config.VaultValuableGoods.max)

        if awardGoods > 0 then
            _char:Inventory():Add().Default(1, 'valuegood', awardGoods, {}, {}, function(done) end)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found ' .. awardGoods .. ' valuable goods inside this box' })
        end
    end
end)

RegisterServerEvent('pw_bankrobbery:server:counterRewards')
AddEventHandler('pw_bankrobbery:server:counterRewards', function(bank)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    math.randomseed(os.time())

    local cardChance = math.random(1, 100)
    if cardChance <= Config.BankCardChance then
        local cardReaderSpot = math.random(1,#CardReaders)
        local universalCardChance = math.random(1,100)
        if universalCardChance <= Config.UniversalCardChance then
            _char:Inventory():Add().Default(1, 'vaultcard', 1, {}, { ['hours'] = {0, 0}, ['bank'] = 0, ['bankName'] = "Universal", ['reader'] = cardReaderSpot }, function(done) end)
        else
            local firstHour = math.random(0,23)
            local secondHour
            if firstHour == 23 then 
                secondHour = 0
            else
                secondHour = firstHour + 1
            end
            _char:Inventory():Add().Default(1, 'vaultcard', 1, {}, { ['hours'] = {firstHour, secondHour}, ['bank'] = bank, ['bankName'] = Banks[bank].name, ['reader'] = cardReaderSpot }, function(done) end)
        end
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'You found a card', length = 4500 })
    end

    local awardMoney = math.random(Config.CountersMoney.min, Config.CountersMoney.max)

    if awardMoney > 0 then
        _char:Cash().addCash(awardMoney, function(done)
            if done then
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found $' .. awardMoney .. ' near the computer', length = 4500 })
            end
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'You didn\'t find anything on this counter', length = 4500 })
    end
end)

RegisterServerEvent('pw_bankrobbery:server:syncCashierDoorOpening')
AddEventHandler('pw_bankrobbery:server:syncCashierDoorOpening', function(bank, state)
    Banks[bank].cashiercoords.lockpicking = state
    TriggerClientEvent('pw_bankrobbery:client:syncCashierDoorOpening', -1, bank, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncVaultGateHacking')
AddEventHandler('pw_bankrobbery:server:syncVaultGateHacking', function(bank, gate, state)
    Banks[bank][gate].hacking = state
    TriggerClientEvent('pw_bankrobbery:client:syncVaultGateHacking', -1, bank, gate, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncVaultBoxes')
AddEventHandler('pw_bankrobbery:server:syncVaultBoxes', function(bank, boxes, spot, type, state)
    Banks[bank][boxes][spot][type] = state
    TriggerClientEvent('pw_bankrobbery:client:syncVaultBoxes', -1, bank, boxes, spot, type, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncVaultsDisabled')
AddEventHandler('pw_bankrobbery:server:syncVaultsDisabled', function(bank, vault, state)
    Banks[bank][vault].disabled = state
    TriggerClientEvent('pw_bankrobbery:client:syncVaultsDisabled', -1, bank, vault, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncVaults')
AddEventHandler('pw_bankrobbery:server:syncVaults', function(bank, vault, openDoor, state)
    Banks[bank][vault].open = state
    TriggerClientEvent('pw_bankrobbery:client:syncVaults', -1, bank, vault, openDoor, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncCounters')
AddEventHandler('pw_bankrobbery:server:syncCounters', function(bank, counter, type, state)
    Banks[bank].cashiercoords.counters[counter][type] = state
    TriggerClientEvent('pw_bankrobbery:client:syncCounters', -1, bank, counter, type, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncSpots')
AddEventHandler('pw_bankrobbery:server:syncSpots', function(bank, type, spot, state)
    Banks[bank][type][spot].open = state
    TriggerClientEvent('pw_bankrobbery:client:syncSpots', -1, bank, type, spot, state)
end)

RegisterServerEvent('pw_bankrobbery:server:syncCashierDoor')
AddEventHandler('pw_bankrobbery:server:syncCashierDoor', function(bank, state)
    Banks[bank].cashiercoords.open = state
    TriggerClientEvent('pw_bankrobbery:client:syncCashierDoor', -1, bank, state)
end)

PW.RegisterServerCallback('pw_bankrobbery:server:getBanks', function(source, cb)
    cb(Banks, CardReaders)
end)

PW.RegisterServerCallback('pw_bankrobbery:server:getPolice', function(source, cb)
    cb(#PW.CheckOnlineDuty('police'))
end)