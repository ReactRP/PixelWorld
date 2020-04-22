function loadCharacter(source, steam, cid)
    local self = {}
    local rTable = {}
    self.cid = cid
    self.source = source
    self.steam = steam
    self.banking = {}
    self.cash = {}
    
    self.query = MySQL.Sync.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid AND `steam` = @steam", {['@cid'] = self.cid, ['@steam'] = self.steam})
    self.banking.personal = MySQL.Sync.fetchAll("SELECT * FROM `banking` WHERE `cid` = @cid AND `type` = 'Personal'", {['@cid'] = self.cid})[1] or nil
    self.banking.savings = MySQL.Sync.fetchAll("SELECT * FROM `banking` WHERE `cid` = @cid AND `type` = 'Savings'", {['@cid'] = self.cid})[1] or nil
    self.banking.debitcards = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `owner_cid` = @cid", {['@cid'] = self.cid}) or nil

    if self.banking.personal ~= nil then
        self.banking.personal.statement = MySQL.Sync.fetchAll("SELECT * FROM `bank_statements` WHERE `character_id` = @cid AND `account_number` = @ac AND `sort_code` = @sc ORDER BY `record_id` DESC LIMIT 30", {['@cid'] = self.cid, ['@ac'] = self.banking.personal.account_number, ['@sc'] = self.banking.personal.sort_code})
    end
    if self.banking.savings ~= nil then
        self.banking.savings.statement = MySQL.Sync.fetchAll("SELECT * FROM `bank_statements` WHERE `character_id` = @cid AND `account_number` = @ac AND `sort_code` = @sc ORDER BY `record_id` DESC LIMIT 30", {['@cid'] = self.cid, ['@ac'] = self.banking.savings.account_number, ['@sc'] = self.banking.savings.sort_code})
    end

    if self.query[1] ~= nil then
        self.cash.balance = self.query[1].cash
        -- Basic Information Regarding Character

        rTable.getCID = function()
            return self.cid
        end

        rTable.getSource = function()
            return self.source
        end

        rTable.getSteam = function()
            return self.steam
        end

        rTable.getFirstName = function()
            return self.query[1].firstname
        end

        rTable.getLastName = function()
            return self.query[1].lastname
        end

        rTable.getFullName = function()
            return self.query[1].firstname..' '..self.query[1].lastname
        end

        rTable.getEmail = function()
            return self.query[1].email
        end

        rTable.getTwitter = function()
            return self.query[1].twitter
        end

        rTable.getDob = function()
            return self.query[1].dateOfBirth
        end

        rTable.getBio = function()
            return self.query[1].biography
        end

        rTable.getHealth = function()
            return self.query[1].getHealth
        end

        rTable.getLastOutfit = function()
            return self.query[1].cur_outfit
        end

        rTable.setLastOutfit = function(id)
            self.query[1].cur_outfit = id
        end

        rTable.getSex = function()
            return self.query[1].sex
        end

        rTable.getJob = function()
            return json.decode(self.query[1].job)
        end

        rTable.newCharacterCheck = function()
            return self.query[1].newCharacter
        end

        rTable.toggleNewCharacter = function()
            MySQL.Async.execute("UPDATE `characters` SET `newCharacter` = 0 WHERE `cid` = @cid AND `steam` = @steam", {['@cid'] = self.cid, ['@steam'] = self.steam}, function(updated)
                if updated > 0 then
                    self.query[1].newCharacter = false
                end
            end)
        end

        rTable.saveCharacter = function(notify)
            if notify then
                print(' ^1[PixelWorld Core] ^4- Character Saved. '..self.query[1].firstname..' '..self.query[1].lastname)
            end
        end

        rTable.getSpawns = function()   
            return MySQL.Sync.fetchAll("SELECT * from `character_spawns` WHERE `global` = 1 OR `global` = 0 AND `cid` = @cid", {['@cid'] = self.cid})
        end

        rTable.Needs = function()
            local needs = {}

            needs.getNeeds = function()
                return json.decode(self.query[1].needs)
            end

            needs.saveNeeds = function(hunger, thirst, stress, drugs, drink)
                local createNeedsTable = { ['drunk'] = drink, ['drugs'] = drugs, ['thirst'] = thirst, ['hunger'] = hunger, ['stress'] = stress }
                MySQL.Async.execute("UPDATE `characters` SET `needs` = @needs WHERE `cid` = @cid", {['@needs'] = json.encode(createNeedsTable), ['@cid'] = self.cid}, function(done)
                    if done > 0 then
                        self.query[1].needs = json.encode(createNeedsTable)
                    end
                end)
            end

            return needs
        end

        rTable.Custody = function()
            local custody = {}

            custody.getPrisonState = function()
                local theTable
                
                if self.query[1].jailed == nil then
                    theTable = { ['inPrison'] = false, ['time'] = 0, ['total'] = 0 }
                else
                    theTable = json.decode(self.query[1].jailed)
                end

                return theTable
            end

            custody.updatePrisonStatus = function(toggle, time)
                local success = false
                local theTable = { ['inPrison'] = toggle, ['time'] = time, ['total'] = (rTable.Custody().getPrisonState().total == 0 and time or rTable.Custody().getPrisonState().total) }
                if not toggle then
                    theTable['time'] = 0
                    theTable['total'] = 0
                end
                local queried = MySQL.Sync.execute("UPDATE `characters` SET `jailed` = @jail WHERE `cid` = @cid", {['@jail'] = json.encode(theTable), ['@cid'] = self.cid})
                
                if queried > 0 then
                    self.query[1].jailed = json.encode(theTable)
                    success = true
                end

                return success
            end

            return custody
        end

        rTable.Health = function()
            local health = {}

            health.getHealth = function(cb)
                local getHealth = MySQL.Sync.fetchScalar("SELECT `health` FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.cid})
                return (getHealth or 200)
            end

            health.updateHealth = function(amt)
                local saveValue = tonumber(amt)
                MySQL.Sync.execute("UPDATE `characters` SET `health` = @health WHERE `cid` = @cid", {['@health'] = saveValue, ['@cid'] = self.cid})
            end

            health.getInjuries = function()
                local processed = false
                local info = {}
                MySQL.Async.fetchScalar("SELECT `injuries` FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.cid}, function(inj)
                    if inj ~= nil then
                        info = json.decode(inj)
                        processed = true
                    end
                end)
                repeat Wait(0) until processed == true
                return info
            end

            health.updateInjuries = function(tbl)
                local processed = false
                MySQL.Async.execute("UPDATE `characters` SET `injuries` = @inj WHERE `cid` = @cid", {['@inj'] = json.encode(tbl), ['@cid'] = self.cid}, function(done)
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return processed
            end

            return health
        end

        rTable.Gang = function()
            local gang = {}

            gang.setGang = function(gangid, level)
                if gangid ~= nil and type(gangid) == "number" then
                    MySQL.Async.fetchAll("SELECT * FROM `gangs` WHERE `id` = @gang", {['@gang'] = gangid}, function(gangsql)
                        if gangsql[1] ~= nil then
                            local ranks = json.decode(gangsql[1].ranks)
                            local hq = json.decode(gangsql[1].hq)
                            if level == nil then
                                level = 1
                            end

    
                            for k, v in pairs(ranks) do
                                if k == level then
                                    local gangTable = { ['gang'] = gangid, ['name'] = gangsql[1].name, ['level'] = level, ['property'] = hq.property }
                                    local gangEncrypted = json.encode(gangTable)
                                    MySQL.Async.execute("UPDATE `characters` SET `gang` = @gang WHERE `cid` = @cid", {['@gang'] = gangEncrypted, ['@cid'] = self.cid}, function(updated)
                                        if updated == 1 then
                                            if self.source ~= nil and self.source > 0 then
                                                TriggerClientEvent('pw:setGang', self.source, gangTable)
                                                TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "success", text = "Your gang has changed to "..gangsql[1].name, length = 5000})
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end)
                end
            end

            gang.getGang = function()
                local processed = false
                local gangInformation
                MySQL.Async.fetchScalar("SELECT `gang` FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.cid}, function(gang)
                    if gang ~= nil then
                        gangInformation = json.decode(gang)
                    else
                        local gangTable = { ['gang'] = 0, ['name'] = 'None', ['level'] = 1}
                        gangInformation = gangTable
                    end
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return gangInformation
            end

            return gang
        end

        rTable.Job = function()
            local job = {}
            local jobData = json.decode(self.query[1].job)
            job.getJob = function()
                return jobData
            end

            job.setJob = function(job, grade, workplace, salery)
                MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs` WHERE `name` = @job", {['@job'] = job}, function(ajob)
                    if ajob[1] ~= nil then
                        MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job AND `grade` = @grade", {['@job'] = ajob[1].name, ['@grade'] = grade}, function(agrade)
                            if agrade[1] ~= nil then
                                local temp = { ['name'] = jobData.name, ['grade'] = jobData.grade, ['salery'] = jobData.name, ['workplace'] = jobData.workplace, ['duty'] = jobData.duty }
                                jobData.name = ajob[1].name
                                jobData.grade = agrade[1].grade
                                jobData.grade_level = agrade[1].level
                                jobData.salery = (salery or agrade[1].salery)
                                jobData.workplace = workplace
                                jobData.duty = false
                                jobData.label = ajob[1].label
                                jobData.grade_label = agrade[1].label
                                MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@cid'] = self.cid, ['@job'] = json.encode(jobData)}, function(done)
                                    if done > 0 then
                                        self.query[1].job = json.encode(jobData)
                                        TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "success", text = "Your job has been set<br><strong>Job:</strong> "..ajob[1].label.."<br><strong>Grade:</strong> "..agrade[1].label.."<br><strong>Salery:</strong> $"..jobData.salery.."<br><strong>Workplace ID:</strong> "..jobData.workplace, length = 5000})
                                    else
                                        TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "error", text = "There was an error setting the job and grade you requested.", length = 5000})
                                        jobData = temp
                                    end
                                    TriggerClientEvent('pw:updateJob', self.source, jobData)
                                end)
                            else
                                TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "error", text = "The Grade you specified '"..grade.."' was not found.", length = 5000})
                            end
                        end)
                    else
                        TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "error", text = "The Job you specified '"..job.."' was not found.", length = 5000})
                    end                    
                end)
            end

            job.removeJob = function()
                jobData = Config.NewCharacters.job
                MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@cid'] = self.cid, ['@job'] = json.encode(jobData)}, function(done)
                    if done > 0 then
                        self.query[1].job = json.encode(jobData)
                        TriggerClientEvent('pw:updateJob', self.source, jobData)
                        TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "success", text = "Your job has been removed", length = 5000})
                    end
                end)
            end

            job.setSalery = function(amt)
                if amt and type(amt) == number then
                    jobData.salery = amt
                    MySQL.Async.execute("UPDATE `characters` SET `job` = @job WHERE `cid` = @cid", {['@cid'] = self.cid, ['@job'] = json.encode(jobData)}, function(done)
                        if done > 0 then
                            self.query[1].job = json.encode(jobData)
                            TriggerClientEvent('pw:notification:SendAlert', self.source, {type = "success", text = "You salery has been adjusted to $"..jobData.salery, length = 5000})
                        end
                    end)
                end
            end

            job.toggleDuty = function()
                jobData.duty = not jobData.duty
                self.query[1].job = json.encode(jobData)
                TriggerClientEvent('pw_chat:refreshChat', self.source)
                TriggerClientEvent('pw:toggleDuty', self.source, jobData.duty)
            end

            return job
        end

        rTable.DebitCards = function()
            local debitcards = {}

            debitcards.createCard = function(account, sortcode, pin, cb)
                local cardType = math.random(1,2)
                local cardnumber
                if cardType == 1 then
                    cardnumber = "4147"..math.random(100000000000,999999999999) -- Visa Prefix
                else
                    cardnumber = "5355"..math.random(100000000000,999999999999) -- Mastercard Prefix
                end

                local generatedMeta = { ['cardPin'] = pin, ['account'] = account, ['sortcode'] = sortcode, ['locked'] = false, ['stolen'] = false }

                MySQL.Async.insert("INSERT INTO `debitcards` (`owner_cid`, `cardnumber`, `cardmeta`,`type`) VALUES (@cid, @number, @meta, @type)", {
                    ['@cid'] = self.cid,
                    ['@number'] = cardnumber,
                    ['@meta'] = json.encode(generatedMeta),
                    ['@type'] = (cardType == 1 and "Visa" or "Mastercard")
                }, function(inserted)
                    if inserted > 0 then
                        self.banking.debitcards = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `owner_cid` = @cid", {['@cid'] = self.cid}) or nil
                        local itemMeta = { ['debitcardid'] = inserted, ['cardnumber'] = cardnumber }
                        rTable.Inventory().Add().Default(1, (cardType == 1 and "visacard" or "mastercard"), 1, itemMeta, itemMeta, function(done)
                            TriggerClientEvent('pw_banking:client:sendUpdate', self.source, rTable.Bank().getEverything())
                            if cb then
                                cb(done)
                            end
                        end, self.cid) 
                    end
                end) 
            end

            debitcards.refreshDebitCards = function()
                self.banking.debitcards = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `owner_cid` = @cid", {['@cid'] = self.cid}) or nil
            end

            debitcards.changePin = function(card, oldpin, newpin, cb)
                MySQL.Async.fetchAll("SELECT * FROM `debitcards` WHERE `record_id` = @card", {['@card'] = card}, function(cardinfo)
                    if cardinfo[1] ~= nil then
                        local metaDecode = json.decode(cardinfo[1].cardmeta)
                        if not metaDecode.stolen then
                            if metaDecode.cardPin == oldpin then
                                metaDecode.cardPin = newpin
                                MySQL.Async.execute("UPDATE `debitcards` SET `cardmeta` = @meta WHERE `record_id` = @card", {['@card'] = card, ['@meta'] = json.encode(metaDecode)}, function(done)
                                    self.banking.debitcards = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `owner_cid` = @cid", {['@cid'] = self.cid}) or nil
                                    if cb then
                                        if done > 0 then
                                            cb(true)
                                        else
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
                    end
                end)
            end

            debitcards.toggleLock = function(card, cb) 
                MySQL.Async.fetchAll("SELECT * FROM `debitcards` WHERE `record_id` = @card", {['@card'] = card}, function(cardinfo)
                    if cardinfo[1] ~= nil then
                        local metaDecode = json.decode(cardinfo[1].cardmeta)
                        if not metaDecode.stolen then
                            metaDecode.locked = not metaDecode.locked
                            MySQL.Async.execute("UPDATE `debitcards` SET `cardmeta` = @meta WHERE `record_id` = @card", {['@card'] = card, ['@meta'] = json.encode(metaDecode)}, function(done)
                                self.banking.debitcards = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `owner_cid` = @cid", {['@cid'] = self.cid}) or nil
                                if cb then
                                    if done > 0 then
                                        cb(true)
                                    else
                                        cb(false)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end

            debitcards.toggleStolen = function(card, cb)
                MySQL.Async.fetchAll("SELECT * FROM `debitcards` WHERE `record_id` = @card", {['@card'] = card}, function(cardinfo)
                    if cardinfo[1] ~= nil then
                        local metaDecode = json.decode(cardinfo[1].cardmeta)
                        if not metaDecode.stolen then
                            local time = os.time(os.date("!*t"))
                            local plus24 = (time + 86400)
                            metaDecode.stolen = true
                            metaDecode.locked = true
                            metaDecode.stolenReport = time
                            metaDecode.stolenDelete = plus24
                            MySQL.Async.execute("UPDATE `debitcards` SET `cardmeta` = @meta WHERE `record_id` = @card", {['@card'] = card, ['@meta'] = json.encode(metaDecode)}, function(done)
                                self.banking.debitcards = MySQL.Sync.fetchAll("SELECT * FROM `debitcards` WHERE `owner_cid` = @cid", {['@cid'] = self.cid}) or nil
                                if cb then
                                    if done > 0 then
                                        cb(true)
                                    else
                                        cb(false)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end

            return debitcards
        end

        rTable.Properties = function()
            local properties = {}
            
            properties.myProperties = function()
                local processed = false
                local propertiesTbl = {}
                MySQL.Async.fetchAll("SELECT * FROM `properties` WHERE `metainformation` LIKE '%\"owner\":"..self.cid.."%' OR `metainformation` LIKE '%\"rentor\":"..self.cid.."%'", {}, function(props)
                    propertiesTbl = props
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return propertiesTbl
            end

            return properties
        end

        rTable.Cash = function()
            local cash = {}

            cash.addCash = function(m, cb)
                if m and type(m) == "number" then
                    MySQL.Async.execute("UPDATE `characters` SET `cash` = `cash` + @cash WHERE `cid` = @cid", {['@cid'] = self.cid, ['@cash'] = m}, function(processed)
                        if processed > 0 then
                            self.cash.balance = (self.cash.balance + m)
                            if cb then
                                cb(self.cash.balance)
                            end
                        else
                            self.cash.balance = self.cash.balance
                            if cb then
                                cb(self.cash.balance)
                            end
                        end
                        TriggerClientEvent('pw:characters:cashAdjustment', self.source, self.cash.balance)
                    end)
                else
                    self.cash.balance = self.cash.balance
                    if cb then
                        cb(self.cash.balance)
                    end
                end
            end

            cash.removeCash = function(m, cb)
                if m and type(m) == "number" then
                    if (self.cash.balance >= 0) then
                        MySQL.Async.execute("UPDATE `characters` SET `cash` = `cash` - @cash WHERE `cid` = @cid", {['@cid'] = self.cid, ['@cash'] = m}, function(processed)
                            if processed > 0 then
                                self.cash.balance = (self.cash.balance - m)
                                if cb then
                                    cb(self.cash.balance)
                                end
                            else
                                self.cash.balance = self.cash.balance
                                if cb then
                                    cb(self.cash.balance)
                                end
                            end
                            TriggerClientEvent('pw:characters:cashAdjustment', self.source, self.cash.balance)
                        end)
                    else
                        self.cash.balance = self.cash.balance
                        if cb then
                            cb(self.cash.balance)
                        end
                    end
                else
                    self.cash.balance = self.cash.balance
                    if cb then
                        cb(self.cash.balance)
                    end
                end
            end

            cash.getBalance = function()
                return self.cash.balance or 0
            end

            return cash
        end

        rTable.Savings = function()
            local savings = {}

            savings.createAccount = function(cb)
                local accountNumber = math.random(10000000,99999999)
                local sortCode = self.banking.personal.sort_code
                local IBAN = self.banking.personal.iban.."-1"
                local createBankAccount = MySQL.Sync.insert("INSERT INTO `banking` (`cid`,`account_number`,`sort_code`,`balance`,`type`,`account_meta`,`iban`,`creditScore`) VALUES (@cid, @acct, @sc, @balance, @type, @meta, @iban, @cscore)", {
                    ['@cid'] = cid,
                    ['@acct'] = accountNumber,
                    ['@sc'] = sortCode,
                    ['@balance'] = 0,
                    ['@type'] = "Savings",
                    ['@meta'] = json.encode({['overdraft'] = 0, ['currentloan'] = 0}),
                    ['@iban'] = IBAN,
                    ['@cscore'] = 0,
                })
                if createBankAccount > 0 then
                    self.banking.savings = MySQL.Sync.fetchAll("SELECT * FROM `banking` WHERE `cid` = @cid AND `type` = 'Savings'", {['@cid'] = self.cid})[1] or nil
                    cb(true)
                else
                    cb(false)
                end
            end

            savings.addMoney = function(m, desc, cb)
                if self.banking.savings ~= nil then
                    if m and type(m) == "number" then
                        MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` + @balance WHERE `cid` = @cid AND `type` = 'Savings'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                            if processed > 0 then
                                self.banking.savings.balance = (self.banking.savings.balance + m)
                                -- Insert Banking Deposit Query for Statements
                                rTable.Bank().adjustStatement("deposit", "savings", m, desc)
                                if cb then
                                    cb(true)
                                end
                            else
                                self.banking.savings.balance = self.banking.savings.balance
                                if cb then
                                    cb(false)
                                end
                            end
                            TriggerClientEvent('pw:characters:bankSavingsAdjustment', self.source, self.banking.savings.balance)
                        end)
                    else
                        self.banking.savings.balance = self.banking.savings.balance
                        if cb then
                            cb(false)
                        end
                    end
                end
            end

            savings.getDetails = function(cb)
                local details = { ['account_number'] = self.banking.savings.account_number, ['sort_code'] = self.banking.savings.sort_code, ['iban'] = self.banking.savings.iban }
                if cb then
                    cb(details)
                else
                    return details
                end
            end

            savings.checkExistance = function()
                if self.banking.savings == nil then
                    return false
                else
                    return true
                end
            end

            savings.removeMoney = function(m, desc, cb)
                if self.banking.savings ~= nil then
                    if m and type(m) == "number" then
                        MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` - @balance WHERE `cid` = @cid AND `type` = 'Savings'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                            if processed > 0 then
                                self.banking.savings.balance = (self.banking.savings.balance - m)
                                -- Insert Banking Withdraw Query for Statements
                                rTable.Bank().adjustStatement("withdraw", "savings", m, desc)
                                if cb then
                                    cb(true)
                                end
                            else
                                self.banking.savings.balance = self.banking.savings.balance
                                if cb then
                                    cb(false)
                                end
                            end
                            TriggerClientEvent('pw:characters:bankSavingsAdjustment', self.source, self.banking.savings.balance)
                        end)
                    else
                        self.banking.savings.balance = self.banking.savings.balance
                        if cb then
                            cb(false)
                        end
                    end
                end
            end

            savings.getBalance = function()
                if(self.banking.personal) then
                    return self.banking.savings.balance
                else
                    return 0
                end
            end

            return savings
        end

        rTable.Bank = function()
            local banking = {}

                banking.getEverything = function()
                    local bank = { ['personal'] = {}, ['savings'] = {}, ['creditScore'] = 0, ['cards'] = {}}

                    if self.banking.personal ~= nil then
                        bank.personal.exist = true
                        bank.personal.balance = self.banking.personal.balance or 0
                        bank.personal.statement = self.banking.personal.statement or {}
                        bank.personal.accountdetails = { ['account_number'] = self.banking.personal.account_number, ['sort_code'] = self.banking.personal.sort_code, ['iban'] = self.banking.personal.iban}
                        bank.personal.meta = json.decode(self.banking.personal.account_meta) or {}
                        bank.creditScore = self.banking.personal.creditScore or 0
                    else
                        bank.personal.exist = false
                    end

                    if self.banking.savings ~= nil then
                        bank.savings.exist = true
                        bank.savings.balance = self.banking.savings.balance or 0
                        bank.savings.statement = self.banking.savings.statement or {}
                        bank.savings.accountdetails = { ['account_number'] = self.banking.savings.account_number, ['sort_code'] = self.banking.savings.sort_code, ['iban'] = self.banking.savings.iban}
                        bank.savings.meta = json.decode(self.banking.savings.account_meta) or {}
                    else
                        bank.savings.exist = false
                    end

                    if self.banking.debitcards[1] ~= nil then
                        bank.cardsexist = true
                        bank.cards = self.banking.debitcards
                    else
                        bank.cardsexist = false
                    end

                    return bank
                end

                banking.getDetails = function(cb)
                    local details = { ['account_number'] = self.banking.personal.account_number, ['sort_code'] = self.banking.personal.sort_code, ['iban'] = self.banking.personal.iban, ['creditscore'] = (self.banking.personal.creditScore or 0) }
                    if cb then
                        cb(details)
                    else
                        return details
                    end
                end

                banking.adjustStatement = function(action, account, amount, desc)
                    local time = os.date("%Y-%m-%d %H:%M:%S")
                    if action == "deposit" then
                        MySQL.Async.insert("INSERT INTO `bank_statements` (`account`,`character_id`,`account_number`,`sort_code`,`deposited`,`balance`,`date`,`message`) VALUES (@account, @cid, @accountnumber, @sortcode, @deposited, @balance, @date, @message)", {
                            ['@account'] = account,
                            ['@cid'] = self.cid,
                            ['@accountnumber'] = (account == "personal" and self.banking.personal.account_number or self.banking.savings.account_number),
                            ['@sortcode'] = (account == "personal" and self.banking.personal.sort_code or self.banking.savings.sort_code),
                            ['@deposited'] = amount,
                            ['@balance'] = (account == "personal" and self.banking.personal.balance or self.banking.savings.balance),
                            ['@date'] = time,
                            ['@message'] = desc
                        }, function(done)
                            if done > 0 then
                                if account == "personal" then
                                    self.banking.personal.statement = MySQL.Sync.fetchAll("SELECT * FROM `bank_statements` WHERE `character_id` = @cid AND `account_number` = @ac AND `sort_code` = @sc ORDER BY `record_id` DESC LIMIT 30", {['@cid'] = self.cid, ['@ac'] = self.banking.personal.account_number, ['@sc'] = self.banking.personal.sort_code})
                                else
                                    self.banking.savings.statement = MySQL.Sync.fetchAll("SELECT * FROM `bank_statements` WHERE `character_id` = @cid AND `account_number` = @ac AND `sort_code` = @sc ORDER BY `record_id` DESC LIMIT 30", {['@cid'] = self.cid, ['@ac'] = self.banking.savings.account_number, ['@sc'] = self.banking.savings.sort_code})
                                end
                                TriggerClientEvent('pw_banking:client:sendUpdate', self.source, rTable.Bank().getEverything())
                            end
                        end)
                    else
                        MySQL.Async.insert("INSERT INTO `bank_statements` (`account`,`character_id`,`account_number`,`sort_code`,`withdraw`,`balance`,`date`,`message`) VALUES (@account, @cid, @accountnumber, @sortcode, @deposited, @balance, @date, @message)", {
                            ['@account'] = account,
                            ['@cid'] = self.cid,
                            ['@accountnumber'] = (account == "personal" and self.banking.personal.account_number or self.banking.savings.account_number),
                            ['@sortcode'] = (account == "personal" and self.banking.personal.sort_code or self.banking.savings.sort_code),
                            ['@deposited'] = amount,
                            ['@balance'] = (account == "personal" and self.banking.personal.balance or self.banking.savings.balance),
                            ['@date'] = time,
                            ['@message'] = desc
                        }, function(done)
                            if done > 0 then
                                if account == "personal" then
                                    self.banking.personal.statement = MySQL.Sync.fetchAll("SELECT * FROM `bank_statements` WHERE `character_id` = @cid AND `account_number` = @ac AND `sort_code` = @sc ORDER BY `record_id` DESC LIMIT 30", {['@cid'] = self.cid, ['@ac'] = self.banking.personal.account_number, ['@sc'] = self.banking.personal.sort_code})
                                else
                                    self.banking.savings.statement = MySQL.Sync.fetchAll("SELECT * FROM `bank_statements` WHERE `character_id` = @cid AND `account_number` = @ac AND `sort_code` = @sc ORDER BY `record_id` DESC LIMIT 30", {['@cid'] = self.cid, ['@ac'] = self.banking.savings.account_number, ['@sc'] = self.banking.savings.sort_code})
                                end
                                TriggerClientEvent('pw_banking:client:sendUpdate', self.source, rTable.Bank().getEverything())
                            end
                        end)
                    end
                end

                banking.addMoney = function(m, desc, cb)
                    if m and type(m) == "number" then
                        MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` + @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                            if processed > 0 then
                                self.banking.personal.balance = (self.banking.personal.balance + m)
                                -- Insert Banking Deposit Query for Statements
                                rTable.Bank().adjustStatement("deposit", "personal", m, desc)
                                if cb then
                                    cb(true)
                                end
                            else
                                self.banking.personal.balance = self.banking.personal.balance
                                if cb then
                                    cb(false)
                                end
                            end
                            TriggerClientEvent('pw:characters:bankAdjustment', self.source, self.banking.personal.balance)
                            TriggerEvent('pw_banking:offlineCharacter:server:reloadUserAccount', self.cid)
                        end)
                    else
                        self.banking.personal.balance = self.banking.personal.balance
                        if cb then
                            cb(false)
                        end
                    end
                end

                banking.removeMoney = function(m, desc, cb)
                    if m and type(m) == "number" then
                        local bankingMeta = json.decode(self.banking.personal.account_meta) or {}
                        if (self.banking.personal.balance - m) >= (bankingMeta.overdraft and (bankingMeta.overdraft * -1) or 0) then 
                            MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` - @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                                if processed > 0 then
                                    self.banking.personal.balance = (self.banking.personal.balance - m)
                                    -- Insert Banking Withdraw Query for Statements
                                    rTable.Bank().adjustStatement("withdraw", "personal", m, desc)
                                    if cb then
                                        cb(true)
                                    end
                                else
                                    self.banking.personal.balance = self.banking.personal.balance
                                    if cb then
                                        cb(false)
                                    end
                                end
                                TriggerClientEvent('pw:characters:bankAdjustment', self.source, self.banking.personal.balance)
                                TriggerEvent('pw_banking:offlineCharacter:server:reloadUserAccount', self.cid)
                            end)
                        else
                            if cb then
                                cb(false)
                            end
                        end
                    else
                        self.banking.personal.balance = self.banking.personal.balance
                        if cb then
                            cb(false)
                        end
                    end
                end

                banking.forceRemoveMoney = function(m, desc, cb)
                    if m and type(m) == "number" then
                        MySQL.Async.execute("UPDATE `banking` SET `balance` = `balance` - @balance WHERE `cid` = @cid AND `type` = 'Personal'", {['@balance'] = m, ['@cid'] = self.cid}, function(processed)
                            if processed > 0 then
                                self.banking.personal.balance = (self.banking.personal.balance - m)
                                -- Insert Banking Withdraw Query for Statements
                                rTable.Bank().adjustStatement("withdraw", "personal", m, desc)
                                if cb then
                                    cb(true)
                                end
                            else
                                self.banking.personal.balance = self.banking.personal.balance
                                if cb then
                                    cb(false)
                                end
                            end
                            TriggerClientEvent('pw:characters:bankAdjustment', self.source, self.banking.personal.balance)
                            TriggerEvent('pw_banking:offlineCharacter:server:reloadUserAccount', self.cid)
                        end)
                    else
                        self.banking.personal.balance = self.banking.personal.balance
                        if cb then
                            cb(false)
                        end
                    end
                end

                banking.getBalance = function()
                    if(self.banking.personal) then
                        return self.banking.personal.balance
                    else
                        return 0
                    end
                end

                banking.getStatement = function()

                end

            return banking
        end

        rTable.Inventory = function()
            local inventory = {}
            inventory.getAll = function(cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `identifier` = @cid AND `inventoryType` = 1", {['@cid'] = self.cid}, function(items)
                    local itemStore = {}
                    if items ~= nil then
                        for k, v in pairs(items) do
                            itemStore[v.record_id] = CreateItemObject(v)
                        end
                    end
                    cb(itemStore)
                end)
            end

            inventory.getSecondary = function(type, owner, cb)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `identifier` = @cid AND `inventoryType` = @type", {['@type'] = type, ['@cid'] = owner}, function(items)
                    local itemStore = {}
                    if items ~= nil then
                        for k, v in pairs(items) do
                            local item = CreateItemObject(v)
                            table.insert(itemStore, item)
                        end
                        cb(itemStore)
                    else
                        cb({})
                    end
                end)
            end

            inventory.NextSlot = function(type, owner, cb)
                local inv = {}
                rTable:Inventory().getAll(function(itemsReturned)
                    for k, v in pairs(itemsReturned) do
                        inv[v.slot] = v
                    end

                    local foundSlot = false
                    for i = 1, PWBase.Storage.entities[type].slots, 1 do
                        if inv[i] == nil then
                            foundSlot = true
                            cb(i)
                            return
                        end
                    end

                    if not foundSlot then
                        cb(nil)
                    end
                end)
            end

            inventory.getHotBar = function(cb)
                MySQL.Async.fetchAll('SELECT * FROM `stored_items` WHERE `inventoryType` = @type AND `identifier` = @owner AND slot in (1, 2, 3, 4, 5) ORDER BY slot ASC', { ['@type'] = 1, ['@owner'] = self.cid }, function(items)
                    local itemsData = {}
                    if items[1] ~= nil then
                        for k, v in pairs(items) do
                            itemsData[v.slot] = CreateItemObject(v)
                        end
                        cb(itemsData)
                    end
                end)
            end

            inventory.getSlot = function(slot, cb, itype, ident)
                local intype = (itype == 0 and 1 or itype)
                local owner = (ident == 0 and self.cid or ident)
                MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `inventoryType` = @ty AND `identifier` = @cid AND `slot` = @slot", {['@ty'] = intype, ['@cid'] = owner, ['@slot'] = slot}, function(item)
                    local itemsData
                    if item[1] ~= nil then
                        for k, v in pairs(item) do
                            itemsData = CreateItemObject(v)
                        end
                        cb(itemsData)
                    end
                end)
            end

            inventory.getAllCount = function(cb)
                MySQL.Async.fetchScalar("SELECT * FROM `stored_items` WHERE `identifier` = @cid AND `inventoryType` = 1", {['@cid'] = self.cid}, function(items)
                    cb((#items or 0))
                end)
            end

            inventory.getItemCount = function(item, cb)
                MySQL.Async.fetchScalar("SELECT SUM(count) FROM `stored_items` WHERE `item` = @item AND `identifier` = @cid AND `inventoryType` = 1", {['@item'] = item, ['@cid'] = self.cid}, function(itemc)
                    cb((itemc or 0))
                end)
            end

            inventory.getItemCountofType = function(item, cb)
                MySQL.Async.fetchScalar("SELECT SUM(count) FROM `stored_items` WHERE `type` = @item AND `identifier` = @cid AND `inventoryType` = 1", {['@item'] = item, ['@cid'] = self.cid}, function(itemc)
                    cb((itemc or 0))
                end)
            end


            -- Movement Actions
            inventory.Remove = function()
                local remove = {}
                    remove.Default = function(uId, qty, cb)
                        MySQL.Async.fetchScalar('SELECT `count` FROM `stored_items` WHERE `record_id` = @uId', { ['@uId'] = uId }, function(dbQty)
                            if dbQty ~= nil then
                                if dbQty <= qty then
                                    MySQL.Async.execute('DELETE FROM `stored_items` WHERE `record_id` = @uId', { ['@uId'] = uId }, function(response)
                                        if response > 0 then
                                            cb(true)
                                        else
                                            cb(false)
                                        end
                                    end)
                                else
                                    MySQL.Async.execute('UPDATE stored_items SET `count` = `count` - @qty WHERE `record_id` = @uId', { ['@qty'] = qty, ['@uId'] = uId }, function(response)
                                        if response > 0 then
                                            cb(true)
                                        else
                                            cb(false)
                                        end
                                    end)
                                end
                            else
                                cb(false)
                            end
                        end)
                    end

                    remove.Single = function(item, cb)
                        if item then
                            MySQL.Async.fetchAll("SELECT * FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @cid", {['@cid'] = self.cid}, function(selectedItem)
                                if selectedItem[1] ~= nil then
                                    if (selectedItem.count - 1) <= 0 then
                                        MySQL.Sync.execute("DELETE FROM `stored_items` WHERE `record_id` = @rid", {['@rid'] = selectedItem[1].record_id})
                                    else
                                        MySQL.Sync.execute("UPDATE `stored_items` SET `count` = `count` - 1 WHERE `record_id` = @rid", {['@rid'] = selectedItem[1].record_id})
                                    end
                                    if cb then
                                        cb(true)
                                    end
                                else
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
                    end

                    remove.All = function(cb)
                        MySQL.Async.execute("DELETE FROM `stored_items` WHERE `inventoryType` = 1 AND `identifier` = @cid", {['@cid'] = self.cid}, function(done)
                            cb(done)
                        end)
                    end

                    remove.Give = function(origin, ntarget, slot, count, cb)
                        local targetChar = exports['pw_core']:getCharacter(ntarget)
                        local target = targetChar.getCID()
                        MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = 1, ['@id'] = origin, ['@slot'] = slot }, function(item)
                            if item[1] ~= nil then
                                local itemData = CreateItemObject(item[1])
                                rTable:Inventory().NextSlot(1, target, function(tslot)
                                    if count == 0 or count >= itemData.qty then
                                        MySQL.Async.execute('UPDATE stored_items SET identifier = @target, slot = @tslot WHERE inventoryType = 1 AND identifier = @origin AND slot = @slot', { ['@target'] = target, ['@tslot'] = tslot, ['@origin'] = origin, ['@slot'] = slot }, function(status)
                                            cb(status > 0)
                                        end)
                                    else
                                        MySQL.Async.execute('UPDATE stored_items SET count = count - @count WHERE inventoryType = 1 AND identifier = @origin AND slot = @slot', { ['@count'] = count, ['@origin'] = origin, ['@slot'] = slot }, function(status)
                                            if status > 0 then
                                                targetChar:Inventory():Add().Default(1, target, itemData.item, count, itemData.metapublic, itemData.metaprivate, function(done)
                                                    if itemData.type == "Simcard" and destinationType == 1 and originType ~= 18 then
                                                        if exports['pw_phone']:simCard(tonumber(itemData.metaprivate.number)).getOwner() ~= target then
                                                            exports['pw_phone']:simCard(tonumber(itemData.metaprivate.number)).updateOwner(tonumber(target))
                                                        end                            
                                                    end
                                                    cb(true)
                                                end)
                                            else
                                                cb(false)
                                            end
                                        end)
                                    end
                                end)
                            end
                        end)
                    end
                return remove
            end

            inventory.Update = function()
                local update = {}

                update.MetaData = function(type, uId, metapub, metapri, cb, id)
                    local owner = id or self.cid
                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @owner AND record_id = @uid LIMIT 1', {
                        ['@type'] = tonumber(type),
                        ['@owner'] = owner,
                        ['@uid'] = uId
                    }, function(items)
                        if items[1] ~= nil then
                            MySQL.Async.execute('UPDATE stored_items SET metapublic = @metapub, metaprivate = @metapri WHERE record_id = @uid', {
                                ['@metapub'] = json.encode(metapub),
                                ['@metapri'] = json.encode(metapri),
                                ['@uid'] = uId
                            }, function(status)
                                cb(status > 0)
                            end)
                        else
                            cb(false)
                        end
                    end)
                end
                return update
            end


            inventory.Add = function()
                local add = {}
                add.Default = function(type, itemid, qty, metapub, metapri, cb, owner)
                    local owner = owner or self.cid
                    MySQL.Async.fetchAll('SELECT inv.* FROM stored_items inv INNER JOIN items_database i ON i.item_name = inv.item WHERE inv.inventoryType = @type AND inv.identifier = @charid AND inv.item = @item AND i.item_stackable = 1 LIMIT 1000', { ['@type'] = type, ['@charid'] = owner, ['@item'] = itemid }, function(existingItems)
                        if existingItems[1] ~= nil then
                            local validStack = false
                            for k, v in pairs(existingItems) do
                                if v['count'] + qty <= PWBase.Storage.itemStore[v['item']].max then
                                    MySQL.Async.execute('UPDATE stored_items SET count = count + @addQty WHERE inventoryType = @type AND identifier = @charid AND slot = @slot', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@slot'] = v['slot'], ['@addQty'] = qty }, function(response)
                                        if response > 0 then
                                            MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @charid AND slot = @slot LIMIT 10', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@slot'] = v['slot'] }, function(item)
                                                if item[1] ~= nil then
                                                    local itemData = CreateItemObject(item[1])
                                                    cb({ record_id = item[1].record_id, item = itemData })
                                                end
                                            end)
                                        end
                                        validStack = true
                                        return
                                    end)
                                elseif k == #existingItems and not validStack then
                                    rTable:Inventory().NextSlot(type, owner, function(nextSlot)
                                        if nextSlot ~= nil then
                                            if PWBase.Storage.itemStore[itemid].type == "Simcard" and metapub['number'] == nil then
                                                local simCard = exports['pw_phone']:registerSim(self.cid)
                                                repeat Wait(0) until simCard ~= nil
                                                metapub['number'] = simCard
                                                metapri['number'] = simCard
                                            end
                                            MySQL.Async.insert('INSERT INTO stored_items (`inventoryType`, `identifier`, `item`, `count`, `slot`, `metapublic`, `metaprivate`, `type`) VALUES(@type, @charid, @itemid, @qty, @slot, @metapub, @metapri, @itype)', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@itemid'] = itemid, ['@qty'] = qty, ['@slot'] = nextSlot, ['@metapub'] = json.encode(metapub), ['@metapri'] = json.encode(metapri), ['@itype'] = PWBase.Storage.itemStore[itemid].type }, function(response)
                                                if response > 0 then
                                                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @charid AND slot = @slot LIMIT 10', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@slot'] = nextSlot }, function(item)
                                                        if item[1] ~= nil then
                                                            local itemData = CreateItemObject(item[1])
                                                            cb({ record_id = item[1].record_id, item = itemData })
                                                        end
                                                    end)
                                                end
                                            end)
                                        else
                                            cb(nil)
                                        end
                                    end)
                                end
                            end
                        else
                            rTable:Inventory().NextSlot(type, owner, function(nextSlot)
                                if nextSlot ~= nil then
                                    if PWBase.Storage.itemStore[itemid].type == "Simcard" and metapub['number'] == nil then
                                        local simCard = exports['pw_phone']:registerSim(self.cid)
                                        repeat Wait(0) until simCard ~= nil
                                        metapub['number'] = simCard
                                        metapri['number'] = simCard
                                    end
                                    MySQL.Async.insert('INSERT INTO stored_items (`inventoryType`, `identifier`, `item`, `count`, `slot`, `metapublic`, `metaprivate`, `type`) VALUES(@type, @charid, @itemid, @qty, @slot, @metapub, @metapri, @itype)', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@itemid'] = itemid, ['@qty'] = qty, ['@slot'] = nextSlot, ['@metapub'] = json.encode(metapub), ['@metapri'] = json.encode(metapri), ['@itype'] = PWBase.Storage.itemStore[itemid].type }, function(response)
                                        if response > 0 then
                                            MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @charid AND slot = @slot LIMIT 10', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@slot'] = nextSlot }, function(item)
                                                if item[1] ~= nil then
                                                    local itemData = CreateItemObject(item[1])
                                                    cb({ record_id = item[1].record_id, item = itemData })
                                                end
                                            end)
                                        end
                                    end)
                                else
                                    cb(nil)
                                end
                            end)
                        end
                    end)
                end

                add.Slot = function(type, itemid, qty, metapub, metapri, slot, cb, id)
                    local owner = id or self.cid
                    MySQL.Async.fetchAll('SELECT * from stored_items WHERE inventoryType = @type AND identifier = @owner AND slot = @slot', { ['@type'] = type, ['@owner'] = owner, ['@slot'] = tonumber(slot) }, function(item)
                        if item[1] == nil then
                            if PWBase.Storage.itemStore[itemid].type == "Simcard" and metapub['number'] == nil then
                                local simCard = exports['pw_phone']:registerSim(self.cid)
                                repeat Wait(0) until simCard ~= nil
                                metapub['number'] = simCard
                                metapri['number'] = simCard
                            end
                            MySQL.Async.insert('INSERT INTO stored_items (`inventoryType`, `identifier`, `item`, `count`, `slot`, `metapublic`, `metaprivate`, `type`) VALUES(@type, @charid, @itemid, @qty, @slot, @metapub, @metapri, @itype)', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@itemid'] = itemid, ['@qty'] = qty, ['@slot'] = tonumber(slot), ['@metapub'] = json.encode(metapub), ['@metapri'] = json.encode(metapri), ['@itype'] = PWBase.Storage.itemStore[itemid].type }, function(response)
                                if response > 0 then
                                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @charid AND slot = @slot LIMIT 10', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@slot'] = tonumber(slot) }, function(item2)
                                        if item2[1] ~= nil then
                                            local itemData = CreateItemObject(item2[1])
                                            cb({ record_id = item2[1].record_id, item = itemData })
                                        end
                                    end)
                                end
                            end)
                        else
                            MySQL.Async.execute('UPDATE stored_items SET count = count + @count WHERE record_id = @uID AND inventoryType = @type AND identifier = @owner', { ['@qty'] = qty, ['@uId'] = item.record_id, ['@type'] = type, ['@owner'] = owner }, function(response)
                                if response > 0 then
                                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @charid AND slot = @slot LIMIT 10', { ['@type'] = tonumber(type), ['@charid'] = owner, ['@slot'] = tonumber(slot) }, function(item2)
                                        if item2[1] ~= nil then
                                            local itemData = CreateItemObject(item2[1])
                                            cb({ record_id = item2[1].record_id, item = itemData })
                                        end
                                    end)
                                end
                            end)
                        end
                    end)
                end

                add.Drop = function(id, item, qty, cb)
                    if item ~= nil then
                        rTable:Inventory().NextSlot(2, id, function(nextSlot)
                            if qty ~= item.qty and qty ~= 0 then
                                MySQL.Async.execute('UPDATE stored_items SET count = count - @qty WHERE record_id = @uId', { ['@qty'] = qty, ['@uId'] = item.record_id }, function(response)
                                    if response > 0 then
                                        PW.Print(item)
                                        MySQL.Async.execute('INSERT INTO stored_items (`inventoryType`, `identifier`, `item`, `count`, `slot`, `metapublic`, `metaprivate`, `type`) VALUES(2, @id, @item, @qty, @slot, @metapub, @metapri, @type)', { ['@id'] = id, ['@item'] = item.item, ['@qty'] = qty, ['@slot'] = nextSlot, ['@metapub'] = json.encode(item.metapublic) or json.encode({}), ['@metapri'] = json.encode(item.metaprivate) or json.encode({}), ['@type'] = PWBase.Storage.itemStore[item.item].type }, function(response2)
                                            cb(response2 > 0)
                                        end)
                                    end
                                end)
                            else
                                MySQL.Async.execute('UPDATE stored_items SET inventoryType = 2, identifier = @owner, slot = @nextSlot WHERE record_id = @uId', { ['@owner'] = id, ['@nextSlot'] = nextSlot, ['@uId'] = item.record_id }, function(response)
                                    cb(response > 0)
                                end)
                            end
                        end)
                    else
                        --MYTH.Pwnzor:CheatLog('Mythic Base', '^8ATTEMPT TO ADD TO DROP WITH NIL ITEM, POSSIBLE SMALL DICK BITCH TRYING TO DUPE - Data : ' .. json.encode({ owner = owner, item = item, qty = qty }))
                    end
                end

                return add
            end


            inventory.Movement = function()
                local movement = {}
                movement.Empty = function(originType, originId, originSlot, destinationType, destinationId, destinationSlot, cb)
                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @originSlot LIMIT 1', { ['@type'] = tonumber(originType), ['@id'] = originId, ['@originSlot'] = originSlot }, function(item)
                        if item[1] ~= nil then
                            local itemData = CreateItemObject(item[1])
                            MySQL.Async.execute('UPDATE stored_items SET inventoryType = @type, identifier = @owner, slot = @destinationSlot WHERE record_id = @itemUid', { ['@type'] = tonumber(destinationType), ['@owner'] = destinationId, ['@destinationSlot'] = destinationSlot, ['@itemUid'] = itemData.record_id }, function(res)
                                if res > 0 then
                                    if itemData.type == "Simcard" and destinationType == 1 and originType ~= 18 then
                                        if exports['pw_phone']:simCard(tonumber(itemData.metaprivate.number)).getOwner() ~= self.cid then
                                            exports['pw_phone']:simCard(tonumber(itemData.metaprivate.number)).updateOwner(tonumber(self.cid))
                                        end                            
                                    end
                                    cb(itemData.type == 1)
                                else
                                    cb(nil)
                                end
                            end)
                        end
                    end)
                end

                movement.Split = function(originType, originId, originSlot, destinationType, destinationId, destinationSlot, moveQty, cb)
                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot LIMIT 1', { ['@type'] = tonumber(originType), ['@id'] = originId, ['@slot'] = originSlot }, function(item)
                        if item[1] ~= nil then
                            local itemData = CreateItemObject(item[1])
                
                            MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot LIMIT 1', { ['@type'] = tonumber(destinationType), ['@id'] = destinationId, ['@slot'] = destinationSlot  }, function(ditem)
                                MySQL.Async.execute('UPDATE stored_items SET count = count - @moveQty WHERE record_id = @itemUid', { ['moveQty'] = moveQty, ['itemUid'] = itemData.record_id }, function(response)
                                    if response > 0 then
                                        if ditem[1] ~= nil then
                                            local itemData2 = CreateItemObject(ditem[1])
                                            if itemData.item == itemData2.item then
                                                MySQL.Async.execute('UPDATE stored_items SET count = count + @moveQty WHERE record_id = @itemUid', { ['@moveQty'] = moveQty , ['@itemUid'] = itemData2.record_id }, function(res2)
                                                    cb(response > 0 and res2 > 0)
                                                end)
                                            end
                                        else
                                            MySQL.Async.insert('INSERT INTO stored_items (`inventoryType`, `identifier`, `item`, `count`, `slot`) VALUES(@type, @id, @itemid, @moveQty, @slot)', { ['@type'] = tonumber(destinationType), ['@id'] = destinationId, ['@itemid'] = itemData.item, ['@moveQty'] = moveQty , ['@slot'] = destinationSlot }, function(res2)
                                                cb(response > 0 and res2 > 0)
                                            end)
                                        end
                                    end
                                end)
                            end)	
                        end
                    end)
                end

                movement.Combine = function(originType, originId, originSlot, destinationType, destinationId, destinationSlot, cb)
                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = tonumber(originType), ['@id'] = originId, ['@slot'] = originSlot }, function(item)
                        if item[1] ~= nil then
                            local itemData = CreateItemObject(item[1])
                            MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = tonumber(destinationType), ['@id'] = destinationId, ['@slot'] = destinationSlot }, function(ditem)
                                if ditem[1] ~= nil then
                                    local itemData2 = CreateItemObject(ditem[1])
                                    if itemData.item == itemData2.item then
                                        MySQL.Async.execute('DELETE FROM stored_items WHERE record_id = @itemUid', { ['@itemUid'] = itemData.record_id }, function(response)
                                            if response > 0 then
                                                MySQL.Async.execute('UPDATE stored_items SET count = count + @originQty WHERE record_id = @itemUid', { ['@originQty'] = itemData.qty, ['@itemUid'] = itemData2.record_id }, function(res2)
                                                    cb(itemData.type == 1 or itemData2.type == 1)
                                                end)
                                            end
                                        end)
                                    end
                                end
                            end)
                        end
                    end)
                end

                movement.TopOff = function(originType, originId, originSlot, destinationType, destinationId, destinationSlot, cb)
                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = tonumber(originType), ['@id'] = originId, ['@slot'] = originSlot }, function(item)
                        if item[1] ~= nil then
                            local itemData = CreateItemObject(item[1])
                            MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = tonumber(destinationType), ['@id'] = destinationId, ['@slot'] = destinationSlot }, function(ditem)
                                if ditem[1] ~= nil then
                                    local itemData2 = CreateItemObject(ditem[1])
                                    if itemData.item == itemData2.item then
                                        local topOff = itemData2.max - itemData2.qty
                                        MySQL.Async.execute('UPDATE stored_items SET count = count - @topOff WHERE record_id = @itemUid', { ['@topOff'] = topOff, ['@itemUid'] = itemData.record_id }, function(response)
                                            if response > 0 then
                                                MySQL.Async.execute('UPDATE stored_items SET count = count + @topOff WHERE record_id = @itemUid', { ['@topOff'] = topOff, ['@itemUid'] = itemData2.record_id }, function(res2)
                                                    cb(itemData.type == 1 or itemData2.type == 1)
                                                end)
                                            end
                                        end)
                                    end
                                end
                            end)
                        end
                    end)
                end
 
                movement.Swap = function(originType, originId, originSlot, destinationType, destinationId, destinationSlot, cb)
                    MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = tonumber(originType), ['@id'] = originId, ['@slot'] = originSlot }, function(item)
                        if item[1] ~= nil then
                            local itemData = CreateItemObject(item[1])
                            MySQL.Async.fetchAll('SELECT * FROM stored_items WHERE inventoryType = @type AND identifier = @id AND slot = @slot', { ['@type'] = tonumber(destinationType), ['@id'] = destinationId, ['@slot'] = destinationSlot }, function(ditem)
                                if ditem[1] ~= nil then
                                    local itemData2 = CreateItemObject(ditem[1])
                                    MySQL.Async.execute('UPDATE stored_items SET inventoryType = @type, identifier = @id, slot = @slot WHERE record_id = @itemUid', { ['@type'] = tonumber(destinationType), ['@id'] = destinationId, ['@slot'] = destinationSlot, ['@itemUid'] = itemData.record_id}, function(response)
                                        if response > 0 then
                                            MySQL.Async.execute('UPDATE stored_items SET inventoryType = @type, identifier = @id, slot = @slot WHERE record_id = @itemUid', { ['@type']= tonumber(originType), ['@id'] = originId, ['@slot'] = originSlot, ['@itemUid'] = itemData2.record_id}, function(response2)
                                                if response2 > 0 then
                                                    if itemData.type == "Simcard" and destinationType == 1 and originType ~= 18 then
                                                        if exports['pw_phone']:simCard(tonumber(itemData.metaprivate.number)).getOwner() ~= self.cid then
                                                            exports['pw_phone']:simCard(tonumber(itemData.metaprivate.number)).updateOwner(tonumber(self.cid))
                                                        end                            
                                                    end
                                                    cb(itemData.type == 1 or itemData.type == 2)
                                                end
                                            end)
                                        end
                                    end)
                                end
                            end)
                        end
                    end)
                end

                return movement
            end

            return inventory
        end

        return rTable
    else    
        return false
    end

end