local offlineAccounts = {}

function createOfflineAccount(cid)
    if cid == nil then return; end
    if cid then
        local self = {}
        self.cid = cid
        self.query = MySQL.Sync.fetchAll("SELECT * FROM `banking` WHERE `type` = 'Personal' AND `cid` = @cid", {['@cid'] = self.cid})[1] or nil
        if self.query == nil then return; end
        
        if self.query ~= nil then
            local rTable = {}

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

            rTable.addMoney = function(m, desc)
                if m and type(m) == "number" then
                    MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` + @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                        if processed > 0 then
                            self.query.balance = (self.query.balance + m)
                            -- Insert Banking Deposit Query for Statements
                            rTable.adjustStatement("deposit", m, desc)
                        else
                            self.query.balance = self.query.balance
                        end
                    end)
                else
                    self.query.balance = self.query.balance
                end
            end

            rTable.removeMoney = function(m, desc)
                if m and type(m) == "number" then
                    MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` - @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                        if processed > 0 then
                            self.query.balance = (self.query.balance - m)
                            -- Insert Banking Withdraw Query for Statements
                            rTable.adjustStatement("withdraw", m, desc)
                        else
                            self.query.balance = self.query.balance
                        end
                    end)
                else
                    self.query.balance = self.query.balance
                end
            end

            rTable.getBalance = function()
                return self.query.balance
            end

            return rTable
        end
        
    end
end

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `banking` WHERE `type` = 'Personal'", {}, function(accts)
        for k, v in pairs(accts) do
            offlineAccounts[v.cid] = createOfflineAccount(v.account_id)
        end
    end)
end)

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
                offlineAccounts[tonumber(cid)] = createOfflineAccount(accts[1].account_id)
            end
        end)
    end
end)