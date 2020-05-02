local businessAccounts = {}

function createBusinessAccount(bid)
    if bid == nil then return; end
    if bid ~= nil then
        local self = {}
        self.bid = bid
        self.query = MySQL.Sync.fetchAll("SELECT * FROM `business_banking` WHERE `account_id` = @bid", {['@bid'] = self.bid})[1] or nil
        if self.query == nil then return; end
        
        if self.query ~= nil then
            local rTable = {}
            rTable.getBalance = function()
                return self.query.balance
            end

            rTable.addMoney = function(m)
                if type(m) == "number" then
                    MySQL.Async.execute("UPDATE `business_banking` SET `balance` = `balance` + @bal WHERE `account_id` = @aid", {['@bal'] = m, ['@aid'] = self.bid}, function(done)
                        if done > 0 then
                            self.query.balance = (self.query.balance + m)
                        end
                    end)
                end
            end

            rTable.removeMoney = function(m)
                if type(m) == "number" and (self.query.balance - m) >= 0 then
                    MySQL.Async.execute("UPDATE `business_banking` SET `balance` = `balance` - @bal WHERE `account_id` = @aid", {['@bal'] = m, ['@aid'] = self.bid}, function(done)
                        if done > 0 then
                            self.query.balance = (self.query.balance - m)
                        end
                    end)
                end
            end

            rTable.getAccountDetails = function()
                local returnTable = { ['account_number'] = self.query.account_number, ['sort_code'] = self.query.sort_code, ['iban'] = self.query.iban, ['meta'] = json.encode(self.query.account_meta) or {}, ['business_id'] = self.query.business, ['business_type'] = self.query.businessType }
                return returnTable
            end

            return rTable
        end
    end
end

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    TriggerEvent('pw_banking:business:createAccount', "city", 1, 100000000, {})
    MySQL.Async.fetchAll("SELECT * FROM `business_banking`", {}, function(businessAccts)
        for k, v in pairs(businessAccts) do
            if businessAccounts[v.businessType] == nil then
                businessAccounts[v.businessType] = {}
            end
            businessAccounts[v.businessType][v.business] = createBusinessAccount(v.account_id)
        end
    end)
end)

exports('getBusinessAccount', function(btype, bid)
    if businessAccounts[btype] then
        if businessAccounts[btype][bid] then
            return businessAccounts[btype][bid]
        end
    end
    return false
end)

RegisterServerEvent('pw_banking:business:createAccount')
AddEventHandler('pw_banking:business:createAccount', function(btype, bid, startingFunds, meta)
    MySQL.Async.fetchAll("SELECT * FROM `business_banking` WHERE `businessType` = @type AND `business` = @bid", {['@type'] = btype, ['@bid'] = bid}, function(acct)
        if acct[1] == nil then
            math.randomseed((os.time() * math.random(10)))
            local accountNumber = math.random(10000000,99999999)
            local sortCode = math.random(100000,999999)
            local IBAN = "IBAN"..math.random(1000000000,9999999999)
            MySQL.Async.insert("INSERT INTO `business_banking` (`businessType`, `business`, `account_number`, `sort_code`, `balance`, `type`, `account_meta`, `iban`, `creditScore`) VALUES (@type, @business, @ac, @sc, @bal, 'Business', @meta, @iban, @creditScore)", {
                ['@type'] = btype,
                ['@business'] = bid,
                ['@ac'] = accountNumber,
                ['@sc'] = sortCode,
                ['@bal'] = startingFunds or 0,
                ['@meta'] = json.encode(meta) or json.encode({}),
                ['@iban'] = IBAN,
                ['@creditScore'] = 0,
            }, function(bankCreated)
                if bankCreated > 0 then
                    if businessAccounts[btype] == nil then
                        businessAccounts[btype] = {}
                    end
                    businessAccounts[btype][bid] = createBusinessAccount(bankCreated)
                end
            end)
        end        
    end)
end)