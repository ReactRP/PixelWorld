local offlineAccounts = {}

function createOfflineAccount(cid)
    --if cid == nil then return; end
    if cid then
        local self = {}
        self.cid = cid
        self.query = MySQL.Sync.fetchAll("SELECT * FROM `banking` WHERE `type` = 'Personal' AND `cid` = @cid", {['@cid'] = self.cid})[1] or nil
       -- if self.query == nil then return; end

        if self.query ~= nil then
            local rTable = {}

            rTable.chargeInterestOnOverdraft = function()
            local isOnline = exports['pw_core']:checkOnline(cid)
            if isOnline ~= false and isOnline > 0 then
                local _char = exports['pw_core']:getCharacter(isOnline)
                if _char then
                    local _bankInfo = _char:Bank().getEverything()
                    if _char:Bank().getBalance() < 0 and (_bankInfo.personal.meta.overdraft ~= 0 and _char:Bank().getBalance() >= (_bankInfo.personal.meta.overdraft * -1)) then
                        -- Arranged Overdraft 1.2% apr
                        local currentOverDrawn = math.floor((math.abs(_char:Bank().getBalance()) * 0.012))
                        if currentOverDrawn > 0 then
                            _char:Bank().forceRemoveMoney(tonumber(currentOverDrawn), "Authorised Overdraft 1.2% ($"..currentOverDrawn..") Interest", function(done)
                            end)
                        end
                    elseif _char:Bank().getBalance() < (_bankInfo.personal.meta.overdraft * -1) then
                        -- Unarranged Overdraft 3.5% apr -- Over there overdraft limit, this could only really happen on force removal of funds due to interest
                        local currentOverDrawn = (math.abs(_char:Bank().getBalance()) * 0.035)
                        if currentOverDrawn >= 1 then
                            _char:Bank().forceRemoveMoney(math.floor(tonumber(currentOverDrawn)), "Unauthorised Overdraft 3.5% Interest", function(done)
                            end)
                        end
                    end
                end
            else
                -- User is not Online do the same methods but for a offline account
                local _bankInfo = (json.decode(self.query.account_meta))
                if rTable.getBalance() < 0 and (_bankInfo.overdraft ~= 0 and rTable.getBalance() >= (_bankInfo.overdraft * -1)) then
                    -- Arranged Overdraft 1.2% apr
                    local currentOverDrawn = math.floor((math.abs(rTable.getBalance()) * 0.012))
                    if currentOverDrawn > 0 then
                        rTable.forceRemoveMoney(tonumber(currentOverDrawn), "Authorised Overdraft 1.2% ($"..currentOverDrawn..") Interest", function(done)
                        end)
                    end
                elseif rTable.getBalance() < (_bankInfo.overdraft * -1) then
                    -- Unarranged Overdraft 3.5% apr -- Over there overdraft limit, this could only really happen on force removal of funds due to interest
                    local currentOverDrawn = (math.abs(rTable.getBalance()) * 0.035)
                    if currentOverDrawn >= 1 then
                        rTable.forceRemoveMoney(math.floor(tonumber(currentOverDrawn)), "Unauthorised Overdraft 3.5% Interest", function(done)
                        end)
                    end
                end
            end
        end

            rTable.adjustStatement = function(action, amount, desc)
                local time = os.date("%Y-%m-%d %H:%M:%S")
                if action == "deposit" then
                    MySQL.Sync.insert("INSERT INTO `bank_statements` (`account`,`character_id`,`account_number`,`sort_code`,`deposited`,`balance`,`date`,`message`) VALUES (@account, @cid, @accountnumber, @sortcode, @deposited, @balance, @date, @message)", {
                        ['@account'] = "personal",
                        ['@cid'] = self.cid,
                        ['@accountnumber'] = self.query.account_number,
                        ['@sortcode'] = self.query.sort_code,
                        ['@deposited'] = amount,
                        ['@balance'] = self.query.balance,
                        ['@date'] = time,
                        ['@message'] = desc
                    })
                else
                    MySQL.Sync.insert("INSERT INTO `bank_statements` (`account`,`character_id`,`account_number`,`sort_code`,`withdraw`,`balance`,`date`,`message`) VALUES (@account, @cid, @accountnumber, @sortcode, @deposited, @balance, @date, @message)", {
                        ['@account'] = "personal",
                        ['@cid'] = self.cid,
                        ['@accountnumber'] = self.query.account_number,
                        ['@sortcode'] = self.query.sort_code,
                        ['@deposited'] = amount,
                        ['@balance'] = self.query.balance,
                        ['@date'] = time,
                        ['@message'] = desc
                    })
                end
            end

            rTable.addMoney = function(m, desc, cb)
                if m and type(m) == "number" then
                    MySQL.Async.fetchScalar("SELECT `balance` FROM `banking` WHERE `cid` = @cid AND `type` = 'Personal'", {['@cid'] = self.cid}, function(currentBalance)
                        if currentBalance ~= nil then
                            self.query.balance = currentBalance
                            MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` + @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                                if processed > 0 then
                                    self.query.balance = (self.query.balance + m)
                                    -- Insert Banking Deposit Query for Statements
                                    rTable.adjustStatement("deposit", m, desc)
                                    if cb then
                                        cb(true)
                                    end
                                else
                                    self.query.balance = self.query.balance
                                    if cb then
                                        cb(false)
                                    end
                                end
                            end)
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    end)
                else
                    self.query.balance = self.query.balance
                    if cb then
                        cb(false)
                    end
                end
            end

            rTable.removeMoney = function(m, desc, cb)
                if m and type(m) == "number" then
                    MySQL.Async.fetchScalar("SELECT `balance` FROM `banking` WHERE `cid` = @cid AND `type` = 'Personal'", {['@cid'] = self.cid}, function(currentBalance)
                        if currentBalance ~= nil then
                            self.query.balance = currentBalance
                            local accountMeta = json.decode(MySQL.Sync.fetchScalar("SELECT `account_meta` FROM `banking` WHERE `cid` = @cid AND `type` = 'Personal'", {['@cid'] = self.cid})) or {}
                            if (self.query.balance - m) >= (accountMeta.overdraft and (accountMeta.overdraft * -1) or 0) then
                                MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` - @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                                    if processed > 0 then
                                        self.query.balance = (self.query.balance - m)
                                        -- Insert Banking Withdraw Query for Statements
                                        rTable.adjustStatement("withdraw", m, desc)
                                        if cb then
                                            cb(true)
                                        end
                                    else
                                        self.query.balance = self.query.balance
                                        if cb then
                                            cb(false)
                                        end
                                    end
                                end)
                            else
                                if cb then
                                    cb(false)
                                end
                            end
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    end)
                else
                    self.query.balance = self.query.balance
                    if cb then
                        cb(false)
                    end
                end
            end

            rTable.forceRemoveMoney = function(m, desc, cb)
                if m and type(m) == "number" then
                    MySQL.Async.fetchScalar("SELECT `balance` FROM `banking` WHERE `cid` = @cid AND `type` = 'Personal'", {['@cid'] = self.cid}, function(currentBalance)
                        if currentBalance ~= nil then
                            self.query.balance = currentBalance
                            MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` - @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                                if processed > 0 then
                                    self.query.balance = (self.query.balance - m)
                                    -- Insert Banking Withdraw Query for Statements
                                    rTable.adjustStatement("withdraw", m, desc)
                                    if cb then
                                        cb(true)
                                    end
                                else
                                    self.query.balance = self.query.balance
                                    if cb then
                                        cb(false)
                                    end
                                end
                            end)
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    end)
                else
                    self.query.balance = self.query.balance
                    if cb then
                        cb(false)
                    end
                end
            end

            rTable.getBalance = function()
                return MySQL.Sync.fetchScalar("SELECT `balance` FROM `banking` WHERE `cid` = @cid AND `type` = 'Personal'", {['@cid'] = self.cid}) or 0
            end

            return rTable
        end
        
    end
end

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `banking` WHERE `type` = 'Personal'", {}, function(accts)
        for k, v in pairs(accts) do
            offlineAccounts[v.cid] = createOfflineAccount(v.cid)
        end
        TriggerEvent('cron:runAt', 01, 30, processOverDraft) -- Rent Payment
    end)
end)

function processOverDraft(d, h, m)
    print(' ^1[PixelWorld Banking] ^3- Running Overdraft Interest Charges^7')
    for k, v in pairs(offlineAccounts) do
        v.chargeInterestOnOverdraft()
    end
end

exports('getOfflineAccount', function(cid)
    if offlineAccounts[cid] then
        return offlineAccounts[cid]
    end
end)

RegisterServerEvent('pw_banking:offlineCharacter:server:reloadUserAccount')
AddEventHandler('pw_banking:offlineCharacter:server:reloadUserAccount', function(cid)
    if cid ~= nil then
        MySQL.Async.fetchAll("SELECT * FROM `banking` WHERE `type` = 'Personal' AND `cid` = @cid", {['@cid'] = tonumber(cid)}, function(accts)
            if accts[1] ~= nil and offlineAccounts[tonumber(cid)] then
                offlineAccounts[tonumber(cid)] = createOfflineAccount(tonumber(cid))
            end
        end)
    end
end)