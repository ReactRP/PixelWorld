PW = nil
currentBanks = {}

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

RegisterServerEvent('pw:databaseCachesLoaded')
AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `banks`", {}, function(banks)
        if banks ~= nil then
            for k, v in pairs(banks) do
                currentBanks[v.id] = { ['name'] = v.name, ['coords'] = json.decode(v.coords), ['bankOpen'] = v.bankOpen, ['bankCooldown'] = v.bankCooldown, ['bankType'] = v.bankType }
            end
        end
    end)
    print('Required Loan Credit Scores\nLower: '..Config.Loans.scores.lower..' \nMedium: '..Config.Loans.scores.medium..' \nHigh: '..Config.Loans.scores.high)
end)

PW.RegisterServerCallback('pw_banking:server:requestBanks', function(source, cb)
    cb(currentBanks)
end)

RegisterServerEvent('pw_banking:server:quickTransfer')
AddEventHandler('pw_banking:server:quickTransfer', function(data)
    if data then
        local _src = source
        local _char = exports['pw_core']:getCharacter(_src)
        local _currentBalance = _char:Bank().getBalance()
        local _savingsBalance = _char:Savings().getBalance()
        local _cashBalance = _char:Cash().getBalance()
        if data.account == "current" then
            if data.type == "withdraw" then
                if _currentBalance >= data.amount then
                    _char:Bank().removeMoney(tonumber(data.amount), "Cash Withdraw", function(success)
                        if success then
                            _char:Cash().addCash(tonumber(data.amount), function(success2)
                                if success2 then
                                    TriggerClientEvent('pw_banking:client:sendUpdate', _src, _char:Bank().getEverything())
                                end
                            end)
                        end
                    end)
                end
            else
                if _cashBalance >= data.amount then
                    _char:Cash().removeCash(tonumber(data.amount), function(success)
                        if success then
                            _char:Bank().addMoney(tonumber(data.amount), "Cash Deposit", function(success2)
                                if success2 then
                                    TriggerClientEvent('pw_banking:client:sendUpdate', _src, _char:Bank().getEverything())
                                end
                            end)
                        end
                    end)
                end
            end
        elseif data.account == "savings" then
            if data.type == "withdraw" then
                if _savingsBalance >= data.amount then
                    _char:Savings().removeMoney(tonumber(data.amount), "Savings Withdraw", function(success)
                        if success then
                            _char:Bank().addMoney(tonumber(data.amount), "Savings Transfer - Withdraw", function(success2)
                                if success2 then
                                    TriggerClientEvent('pw_banking:client:sendUpdate', _src, _char:Bank().getEverything())
                                end
                            end)
                        end
                    end)
                end
            else
                if _currentBalance >= data.amount then
                    _char:Bank().removeMoney(tonumber(data.amount), "Savings Transfer - Deposit", function(success)
                        if success then
                            _char:Savings().addMoney(tonumber(data.amount), "Savings Deposit", function(success2)
                                if success2 then
                                    TriggerClientEvent('pw_banking:client:sendUpdate', _src, _char:Bank().getEverything())
                                end
                            end)
                        end
                    end)
                end
            end
        else

        end
    end
end)

PW.RegisterServerCallback('pw_banking:server:requestBankingInformation', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    cb(_char:Bank().getEverything())
end)

RegisterServerEvent('pw_banking:server:requestOpenSavings')
AddEventHandler('pw_banking:server:requestOpenSavings', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    if _char then
        _char:Savings().createAccount(function(success)
            if success then
                TriggerClientEvent('pw_banking:client:sendUpdate', _src, _char:Bank().getEverything())
                Wait(150)
                TriggerClientEvent('pw_banking:client:savingsOpened', _src)
            end
        end)
    end
end)

RegisterNetEvent('pw_banking:server:completeExternalTransfer')
AddEventHandler('pw_banking:server:completeExternalTransfer', function(data)
    if data then
        local _src = source
        local _char = exports['pw_core']:getCharacter(_src)

        if _char then
            if _char:Bank().getBalance() >= tonumber(data.amount) then
                MySQL.Async.fetchAll("SELECT * FROM `banking` WHERE `account_number` = @ac AND `sort_code` = @sc", {['@ac'] = data.accountnumber, ['@sc'] = data.sortcode}, function(acct)
                    if acct[1] ~= nil and acct[1].cid ~= nil then
                        local _targetSrc = exports['pw_core']:checkOnline(acct[1].cid)
                        if _targetSrc ~= false then
                            -- User is online.
                            local _target = exports['pw_core']:getCharacter(_targetSrc)
                            if _target then
                                _char:Bank().removeMoney(tonumber(data.amount), "Transfer to ".._target.getFullName(), function(success)
                                    if success then
                                        if acct[1].type == "Personal" then
                                            _target:Bank().addMoney(tonumber(data.amount), "Transfer from ".._char.getFullName(), function(success2)
                                                if success2 then
                                                    TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "success", "Your transfer has been successfully made to ".._target.getFullName())
                                                else
                                                    _char:Bank().addMoney(tonumber(data.amount), "Money Reversal due to error", function(success3)
                                                        if success3 then
                                                            TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "danger", "Your transfer failed, money has been reversed into your account.")
                                                        end
                                                    end)
                                                end
                                            end)
                                        else
                                            _target:Savings().addMoney(tonumber(data.amount), "Transfer from ".._char.getFullName(), function(success2)
                                                if success2 then
                                                    TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "success", "Your transfer has been successfully made to ".._target.getFullName())
                                                else
                                                    _char:Bank().addMoney(tonumber(data.amount), "Money Reversal due to error", function(success3)
                                                        if success3 then
                                                            TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "danger", "Your transfer failed, money has been reversed into your account.")
                                                        end
                                                    end)
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                        else
                            -- User is offline
                            MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid", {['@cid'] = acct[1].cid}, function(char)
                                if char[1] ~= nil then
                                    _char:Bank().removeMoney(tonumber(data.amount), "Transfer to "..char[1].firstname..' '..char[1].lastname, function(success)
                                        if success then
                                            MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` + @amount WHERE `cid` = @cid AND `account_number` = @ac AND `sort_code` = @sc", {['@cid'] = acct[1].cid, ['@amount'] = tonumber(data.amount), ['@ac'] = data.accountnumber, ['@sc'] = data.sortcode}, function(success)
                                                if success > 0 then
                                                    MySQL.Async.insert("INSERT INTO `bank_statements` (`account`, `character_id`, `account_number`, `sort_code`, `deposited`, `balance`, `date`,`message`) VALUES (@account, @cid, @ac, @sc, @deposted, @balance, @date, @message)", {
                                                        ['@account'] = (acct[1].type == "Personal" and "personal" or "savings"),
                                                        ['@cid'] = acct[1].cid,
                                                        ['@ac'] = acct[1].account_number,
                                                        ['@sc'] = acct[1].sort_code,
                                                        ['@deposted'] = data.amount,
                                                        ['@balance'] = (acct[1].balance + tonumber(data.amount)),
                                                        ['@date'] = os.date("%Y-%m-%d %H:%M:%S"),
                                                        ['@message'] = "Transfer from ".._char.getFullName()
                                                    }, function(done)
                                                        if done > 0 then
                                                            TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "success", "Your transfer has been successfully made to "..char[1].firstname..' '..char[1].lastname)
                                                        end
                                                    end)
                                                else
                                                    _char:Bank().addMoney(tonumber(data.amount), "Money Reversal due to error", function(success3)
                                                        if success3 then
                                                            TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "danger", "Your transfer failed, money has been reversed into your account.")
                                                        end
                                                    end)
                                                end
                                            end)
                                        end
                                    end)
                                end
                            end)
                        end
                    else
                        TriggerClientEvent('pw_banking:client:externalTransferMessage', _src, "danger", "The account number or sort code you have entered does not appear to exist.")
                    end
                end)
            end
        end
    end
end)

RegisterServerEvent('pw_banking:server:createDebitCard')
AddEventHandler('pw_banking:server:createDebitCard', function(data)
    if data then
        local _src = source
        local _char = exports['pw_core']:getCharacter(_src)

        if _char then
            _char:Bank().getDetails(function(details)
                _char:DebitCards().createCard(details.account_number, details.sort_code, tonumber(data.pin), function(cardCreated)
                    PW.Print(cardCreated)
                end)
            end)
        end
    end
end)

RegisterNetEvent('pw_banking:server:completeInternalTransfer')
AddEventHandler('pw_banking:server:completeInternalTransfer', function(data)
    if data then
        local _src = source
        local _char = exports['pw_core']:getCharacter(_src)
        if _char then
            PW.Print(data)
            if data.from == "cash" then
                if _char:Cash().getBalance() >= tonumber(data.amount) then
                    _char:Cash().removeCash(tonumber(data.amount), function(success)
                        if success then
                            if data.to == "current" then
                                _char:Bank().addMoney(tonumber(data.amount), "Cash Deposit", function(success3)
                                end)
                            else -- to savings
                                _char:Savings().addMoney(tonumber(data.amount), "Cash Deposit", function(success3)
                                end)
                            end
                        end
                    end)
                end
            elseif data.from == "current" then
                PW.Print('doing this fucker?')
                if _char:Bank().getBalance() >= tonumber(data.amount) then
                    _char:Bank().removeMoney(tonumber(data.amount), "Withdraw from Current Account", function(success)
                        if data.to == "cash" then
                            _char:Cash().addCash(tonumber(data.amount), function(success)
                            end)
                        else -- to savings
                            _char:Savings().addMoney(tonumber(data.amount), "Deposit from Current Account", function(success3)
                            end)
                        end
                    end)
                end
            else -- From Savings
                if _char:Savings().getBalance() >= tonumber(data.amount) then
                    _char:Savings().removeMoney(tonumber(data.amount), "Withdraw from Savings Account", function(success)
                        if to == "current" then
                            _char:Bank().addMoney(tonumber(data.amount), "Savings Transfer", function(success3)
                            end)
                        else -- to Cash
                            _char:Cash().addCash(tonumber(data.amount), function(success)
                            end)
                        end
                    end)
                end
            end
        end
    end
end)