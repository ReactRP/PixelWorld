
function processPhoneTransfers()
    local currentTime = os.time(os.date("!*t"))
    MySQL.Async.fetchAll("SELECT * FROM `phone_transfers` WHERE `status` = 1", {}, function(trs)
        for k, v in pairs(trs) do
            if v.process_date <= currentTime then
                -- check if sender is online
                local senderOnline = exports['pw_core']:checkOnline(v.senderCID)
                if senderOnline then
                    -- Sender is Online
                    local _senderChar = exports['pw_core']:getCharacter(senderOnline)
                    if _senderChar then
                        local senderBank
                        if v.origin == "Personal" then
                            senderBank = _senderChar:Bank()
                        else
                            senderBank = _senderChar:Savings()
                        end
                        -- Check Receiver is online
                        local receiverOnline = exports['pw_core']:checkOnline(v.receiptCID)
                        if receiverOnline then
                            -- Receiver is Online
                            local _receiverCID = exports['pw_core']:getCharacter(receiverOnline)
                            if _receiverCID then
                                local receiptBank

                                if v.destination == "Personal" then
                                    receiptBank = _receiverCID:Bank()
                                else
                                    receiptBank = _receiverCID:Savings()
                                end

                                if senderBank.getBalance() >= v.amount then
                                    senderBank.removeMoney(v.amount, "Transfer to ".._receiverCID.getFullName(), function(success)
                                        if success then
                                            receiptBank.addMoney(v.amount, "Transfer from ".._senderChar.getFullName(), function(suc2)
                                                MySQL.Async.execute("UPDATE `phone_transfers` SET `status` = 2 WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id}, function(done)
                                                    if done > 0 then
                                                        updateTransfers(_senderChar.getSource())
                                                    end
                                                end)
                                            end)
                                        end
                                    end)
                                else
                                    -- Sender does not have enough funds
                                    MySQL.Async.execute("UPDATE `phone_transfers` SET `status` = 3, `reason` = 'Not Enough Funds' WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id}, function(done)
                                        if done > 0 then
                                            updateTransfers(_senderChar.getSource())
                                        end
                                    end)
                                end
                            end
                        else
                            -- Receiver is Offline
                            local receiptBank = exports['pw_banking']:getOfflineAccount(v.receiptCID)
                            local _receiverCID = exports['pw_core']:getOffline(v.receiptCID)
                            if receiptBank then
                                if senderBank.getBalance() >= v.amount then
                                    senderBank.removeMoney(v.amount, "Transfer to ".._receiverCID.getFullName(), function(success)
                                        if success then
                                            receiptBank:Bank().addMoney(v.amount, "Transfer from ".._senderChar.getFullName(), function(suc2)
                                                MySQL.Async.execute("UPDATE `phone_transfers` SET `status` = 2 WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id}, function(done)
                                                    if done > 0 then
                                                        updateTransfers(_senderChar.getSource())
                                                    end
                                                end)
                                            end)
                                        end
                                    end)
                                else
                                    MySQL.Async.execute("UPDATE `phone_transfers` SET `status` = 3, `reason` = 'Not Enough Funds' WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id}, function(done)
                                        if done > 0 then
                                            updateTransfers(_senderChar.getSource())
                                        end
                                    end)
                                end
                            end
                        end
                    end
                else
                    -- Sender is Offline
                    local senderBank = exports['pw_banking']:getOfflineAccount(v.senderCID)
                    local senderCID = exports['pw_core']:getOffline(v.senderCID)
                    local sendBank
                    if senderBank then
                        if v.origin == "Personal" then
                            sendBank = senderBank:Bank()
                        else
                            sendBank = senderBank:Savings()
                        end
                        
                        local receiverOnline = exports['pw_core']:checkOnline(v.receiptCID)
                        if receiverOnline then
                            local receiverCID = exports['pw_core']:getCharacter(receiverOnline)
                            if receiptCID then
                                local recBank
                                if v.destination == "Personal" then
                                    recBank = receiptCID:Bank()
                                else
                                    recBank = receiptCID:Savings()
                                end
                                if sendBank.getBalance() >= tonumber(data.amount) then
                                    sendBank.removeMoney(tonumber(data.amount), "Transfer to "..receiptCID.getFullName(), function(done)
                                        if done then
                                            recBank.addMoney(tonumber(data.amount), "Transfer from "..senderCID.getFullName(), function(done2)
                                                MySQL.Sync.execute("UPDATE `phone_transfers` SET `status` = 2 WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id})
                                            end)
                                        end
                                    end)
                                else
                                    MySQL.Sync.execute("UPDATE `phone_transfers` SET `status` = 3, `reason` = 'Not Enough Funds' WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id})
                                end
                            end
                        else
                            local receiptBank = exports['pw_banking']:getOfflineAccount(v.receiptCID)
                            local _receiverCID = exports['pw_core']:getOffline(v.receiptCID)
                            if receiptBank then
                                if sendBank.getBalance() >= tonumber(data.amount) then
                                    sendBank.removeMoney(v.amount, "Transfer to ".._receiverCID.getFullName(), function(success)
                                        if success then
                                            receiptBank:Bank().addMoney(v.amount, "Transfer from "..senderCID.getFullName(), function(suc2)
                                                MySQL.Async.execute("UPDATE `phone_transfers` SET `status` = 2 WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id})
                                            end)
                                        end
                                    end)
                                else
                                    MySQL.Sync.execute("UPDATE `phone_transfers` SET `status` = 3, `reason` = 'Not Enough Funds' WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id})
                                end
                            end
                        end
                    else
                        MySQL.Sync.execute("UPDATE `phone_transfers` SET `status` = 3, `reason` = 'Error Processing Request' WHERE `transfer_id` = @tid", {['@tid'] = v.transfer_id})
                    end
                end
            end
        end
    end)
    Citizen.SetTimeout(60000, processPhoneTransfers)
end

PW.RegisterServerCallback('pw_phone:server:banking:getActiveBanks', function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM `banks`", {}, function(bnks)
        local banks = {}
        for k, v in pairs(bnks) do
            table.insert(banks, {['name'] = v.name, ['coords'] = json.decode(v.coords)})
        end
        cb(banks)
    end)
end)

function updateTransfers(src)
    local _char = exports['pw_core']:getCharacter(src)
    MySQL.Async.fetchAll("SELECT * FROM `phone_transfers` WHERE `senderCID` = @cid", {['@cid'] = _char.getCID()}, function(transfers)
        local currentTransfers = {}
        if transfers[1] ~= nil then
            for k, v in pairs(transfers) do
                local characterTo = exports['pw_core']:getOffline(v.receiptCID)
                if characterTo then
                    table.insert(currentTransfers, {['transfer_id'] = v.transfer_id, ['reason'] = v.reason, ['from_account'] = v.from_account, ['origin'] = v.origin, ['to_account_number'] = v.to_account_number, ['to_sort_code'] = v.to_sort_code, ['amount'] = v.amount, ['request_date'] = v.request_date, ['process_date'] = v.process_date, ['status'] = v.status, ['receiptCID'] = v.receiptCID, ['receiptName'] = characterTo.getFirstName().."<br>"..characterTo.getLastName(), ['senderCID'] = v.senderCID })
                end
            end            
        end
        TriggerClientEvent('pw_phone:client:updateSettings', src, "bank-transfers", currentTransfers)
    end)
end

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    Citizen.SetTimeout(10000, processPhoneTransfers)
end)

PW.RegisterServerCallback('pw_phone:server:banking:getAccounts', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local accounts = {}

    table.insert(accounts, { ['account_id'] = _char:Bank().getAccountIdentifier(), ['account_rank'] = 1, ['account_type'] = "Personal", ['account_number'] = _char:Bank().requestDetails("account_number"), ['sort_code'] = _char:Bank().requestDetails("sort_code"), ['balance'] = _char:Bank().getBalance(), ['transactions'] = _char:Bank().getStatement() })

    if _char:Savings().checkExistance() then
        table.insert(accounts, { ['account_id'] = _char:Savings().getAccountIdentifier(), ['account_rank'] = 2, ['account_type'] = "Savings", ['account_number'] = _char:Savings().requestDetails("account_number"), ['sort_code'] = _char:Savings().requestDetails("sort_code"), ['balance'] = _char:Savings().getBalance(), ['transactions'] = _char:Savings().getStatement() })
    end
    cb(accounts)
end)

RegisterServerEvent('pw_phone:server:banking:forceUpdate')
AddEventHandler('pw_phone:server:banking:forceUpdate', function(source)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local accounts = {}

    table.insert(accounts, { ['account_id'] = _char:Bank().getAccountIdentifier(), ['account_rank'] = 1, ['account_type'] = "Personal", ['account_number'] = _char:Bank().requestDetails("account_number"), ['sort_code'] = _char:Bank().requestDetails("sort_code"), ['balance'] = _char:Bank().getBalance(), ['transactions'] = _char:Bank().getStatement() })

    if _char:Savings().checkExistance() then
        table.insert(accounts, { ['account_id'] = _char:Savings().getAccountIdentifier(), ['account_rank'] = 2, ['account_type'] = "Savings", ['account_number'] = _char:Savings().requestDetails("account_number"), ['sort_code'] = _char:Savings().requestDetails("sort_code"), ['balance'] = _char:Savings().getBalance(), ['transactions'] = _char:Savings().getStatement() })
    end
    TriggerClientEvent('pw_phone:client:updateSettings', _src, "banking", accounts)
end)


PW.RegisterServerCallback('pw_phone:server:banking:GetBankTransactions', function(source, cb, data)
    if data then
        if data.account_type == "Personal" or data.account_type == "Savings" then
            MySQL.Async.fetchAll("SELECT * FROM `bank_statements` WHERE `account_number` = @num AND `sort_code` = @sc AND `account` = @acct", {['@sc'] = data.sort_code, ['@num'] = data.account_number, ['@acct'] = data.account_type:lower()}, function(res)
                if res[1] ~= nil then
                    cb(res)
                else
                    cb({})
                end
            end)
        end
    end
end)

PW.RegisterServerCallback('pw_phone:server:banking:retreiveTransfers', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)

    MySQL.Async.fetchAll("SELECT * FROM `phone_transfers` WHERE `senderCID` = @cid", {['@cid'] = _char.getCID()}, function(transfers)
        local currentTransfers = {}
        if transfers[1] ~= nil then
            for k, v in pairs(transfers) do
                local characterTo = exports['pw_core']:getOffline(v.receiptCID)
                if characterTo then
                    table.insert(currentTransfers, {['transfer_id'] = v.transfer_id, ['reason'] = v.reason, ['from_account'] = v.from_account, ['origin'] = v.origin, ['to_account_number'] = v.to_account_number, ['to_sort_code'] = v.to_sort_code, ['amount'] = v.amount, ['request_date'] = v.request_date, ['process_date'] = v.process_date, ['status'] = v.status, ['receiptCID'] = v.receiptCID, ['receiptName'] = characterTo.getFirstName().."<br>"..characterTo.getLastName(), ['senderCID'] = v.senderCID })
                end
            end            
        end
        cb(currentTransfers)
    end)
end)

PW.RegisterServerCallback('pw_phone:server:banking:Transfer', function(source, cb, data)
    if tonumber(data.amount) > 100000 then
        cb(false)
    else
        local _src = source
        local _char = exports['pw_core']:getCharacter(_src)
        local currentTime = os.time(os.date("!*t"))
        local randomiseCompletion = math.random(300, 3600)
        local generatedCompletion = (currentTime + randomiseCompletion)

        if _char and generatedCompletion and currentTime then
            MySQL.Async.fetchAll("SELECT * FROM `banking` WHERE `account_number` = @ac AND `sort_code` = @sc", {['@ac'] = tonumber(data.account_number), ['@sc'] = tonumber(data.sort_code)}, function(account)
                if account[1] ~= nil then
                    local accountType = MySQL.Sync.fetchScalar('SELECT `type` FROM `banking` WHERE `account_id` = @ac', {['@ac'] = tonumber(data.from)})
                    MySQL.Async.insert("INSERT INTO `phone_transfers` (`from_account`,`to_account_number`,`to_sort_code`,`amount`,`request_date`,`process_date`,`status`,`receiptCID`, `senderCID`, `origin`, `destination`) VALUES (@fromac, @toac, @tosc, @amount, @request, @process, 1, @cid, @scid, @origin, @receiptType)", {
                        ['@fromac'] = tonumber(data.from),
                        ['@toac'] = tonumber(data.account_number),
                        ['@tosc'] = tonumber(data.sort_code),
                        ['@amount'] = tonumber(data.amount),
                        ['@request'] = currentTime,
                        ['@process'] = generatedCompletion,
                        ['@cid'] = account[1].cid,
                        ['@scid'] = _char.getCID(),
                        ['@origin'] = PW.Capitalize(accountType),
                        ['@receiptType'] = PW.Capitalize(account[1].type)
                    }, function(inserted)
                        if inserted > 0 then
                            MySQL.Async.fetchAll("SELECT * FROM `phone_transfers` WHERE `senderCID` = @cid", {['@cid'] = _char.getCID()}, function(transfers)
                                local currentTransfers = {}
                                if transfers[1] ~= nil then
                                    for k, v in pairs(transfers) do
                                        local characterTo = exports['pw_core']:getOffline(v.receiptCID)
                                        if characterTo then
                                            table.insert(currentTransfers, {['transfer_id'] = v.transfer_id, ['reason'] = v.reason, ['from_account'] = v.from_account, ['origin'] = v.origin, ['to_account_number'] = v.to_account_number, ['to_sort_code'] = v.to_sort_code, ['amount'] = v.amount, ['request_date'] = v.request_date, ['process_date'] = v.process_date, ['status'] = v.status, ['receiptCID'] = v.receiptCID, ['receiptName'] = characterTo.getFirstName().."<br>"..characterTo.getLastName(), ['senderCID'] = v.senderCID })
                                        end
                                    end            
                                end
                                TriggerClientEvent('pw_phone:client:updateSettings', _src, "bank-transfers", currentTransfers)
                                cb(true)
                            end)
                        else
                            cb(false)
                        end
                    end)
                else
                    cb(false)
                end        
            end)
        end
    end
end)