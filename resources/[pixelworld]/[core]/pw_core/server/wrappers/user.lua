function loadUser(steam, src)
    local randomCode = math.random(0,20000)
    local apiKey = GetConvar("PWAPIKEY", "invalid")
    local apiKeyResp = GetConvar("PWAPIRESPONSE", "invalid")
    local authed = PWMySQL.Sync.fetchScalar("SELECT `respondWith` FROM `apiKeys` WHERE `keyId` = @api", {['@api'] = apiKey})

    if (tonumber(authed) + randomCode) ~= (tonumber(apiKeyResp) + randomCode) then
        DropPlayer(src, "Sorry this server is not autherised to use the PixelWorld Framework")
    else
        local self = {}
        local rTable = {}
        local time = os.date("%Y-%m-%d %H:%M:%S")
        self.source = src
        self.steam = steam
        self.loggedIn = false
        self.developer = false
        self.characterLoaded = false
        self.loadedCharacter = nil

        -- Do a User Identifier Update
        local update = MySQL.Sync.execute("UPDATE `users` SET `identifiers` = @ident, `last_login` = @login, `name` = @name WHERE `steam` = @steam", {
            ['@ident'] = json.encode(GetPlayerIdentifiers(src)),
            ['@login'] = time,
            ['@name'] = GetPlayerName(src),
            ['@steam'] = steam
        })

        if update > 0 then
            self.query = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `steam` = @steam", {['@steam'] = steam})
            if self.query[1] ~= nil then
                
                rTable.getName = function()
                    return self.query[1].name
                end

                rTable.getDBSteam = function()
                    return self.query[1].steam
                end

                rTable.getSteam = function()
                    return self.steam
                end

                rTable.getSource = function()
                    return self.source
                end

                rTable.userQuery = function()
                    return self.query[1]
                end

                rTable.getCreateDate = function()
                    return self.query[1].first_login
                end

                rTable.getLastLogin = function()
                    return self.query[1].last_login
                end

                rTable.getIdentifiers = function()
                    return json.decode(self.query[1].identifiers)
                end

                rTable.getEmailAddress = function()
                    return self.query[1].emailAddress
                end

                rTable.getDeveloperState = function()
                    return self.developer
                end

                rTable.getLoginState = function()
                    return self.loggedIn
                end

                rTable.getCharacters = function()
                    if self.loggedIn then
                        return MySQL.Sync.fetchAll("SELECT * FROM `characters` WHERE `steam` = @steam", {['@steam'] = self.steam})
                    else
                        return {}
                    end
                end

                rTable.deleteCharacter = function(cid)
                    if cid then
                        local deleted = MySQL.Sync.execute("DELETE FROM `characters` WHERE `cid` = @cid AND `steam` = @steam", {['@cid'] = cid, ['@steam'] = self.steam})
                        if deleted > 0 then
                            return true
                        end
                    end
                    return false
                end

                rTable.loadCharacter = function(src, cid)
                    Characters[src] = loadCharacter(src, self.steam, cid)
                    if Characters[src] then
                        TriggerEvent('pw_motels:server:assignMotelRoom', src, Characters[src].getCID())
                        self.loadedCharacter = Characters[src].getCID()
                        self.characterLoaded = true
                        return true
                    else
                        return false
                    end
                end

                rTable.unloadCharacter = function()
                    if Characters[self.source] then
                        TriggerEvent('pw_motels:server:unAssignMotelRoom', src, Characters[self.source].getCID())
                        Characters[self.source].saveCharacter(true)
                        TriggerClientEvent('pw_drawtext:hideNotification', src)
                        TriggerEvent('pw_keynote:server:triggerShowable', false)
                        Characters[self.source] = nil
                    end
                    self.loadedCharacter = nil
                    self.characterLoaded = false
                    return true
                end

                rTable.createCharacter = function(data)
                    if data then
                        local function generateCID(gid)
                            local complete = false
                            local res
                            MySQL.Async.fetchScalar("SELECT `cid` FROM `characters` WHERE `cid` = @gid", { ['@gid'] = gid }, function(newRes)
                                res = newRes
                                complete = true
                            end)
                            repeat Wait(0) until complete == true
                            return res
                        end

                        local function checkEmail(genemail)
                            local processed = false
                            local res
                            MySQL.Async.fetchScalar("SELECT `email` FROM `characters` WHERE `email` = @eml", {['@eml'] = genemail}, function(eml)
                                res = eml
                                processed = true
                            end)
                            repeat Wait(0) until processed == true
                            return res
                        end

                        local function checkTwitter(twitterHandle)
                            local processed = false
                            local res
                            MySQL.Async.fetchScalar("SELECT `twitter` FROM `characters` WHERE `twitter` = @twt", {['@twt'] = twitterHandle}, function(twt)
                                res = twt
                                processed = true
                            end)
                            repeat Wait(0) until processed == true
                            return res
                        end

                        local cid
                        local generatedEmail = data.firstName..data.lastName.."@pixelworld.com"
                        local generatedTwitter = '@'..data.firstName..'_'..data.lastName
                        local twitterCheck = checkTwitter(generatedTwitter)
                        local emailCheck = checkEmail(generatedEmail)

                        
                        repeat
                            math.randomseed(os.time())
                            cid = math.random(111111111,999999999)
                            local guid = generateCID(cid)
                        until guid == nil
                        
                        if twitterCheck ~= nil then
                            repeat
                                math.randomseed(os.time())
                                generatedTwitter = '@'..data.firstName..'_'..data.lastName..''..math.random(0,99)
                                local twitter = checkTwitter(generatedTwitter)
                            until twitter == nil
                        end

                        if emailCheck ~= nil then
                            repeat
                                math.randomseed(os.time())
                                generatedEmail = data.firstName..'.'..data.lastName..''..math.random(1,99)..'@pixelworld.com'
                                local email = checkEmail(generatedEmail)
                            until email == nil
                        end

                        if cid and generatedEmail and generatedTwitter then
                            local created = MySQL.Sync.insert("INSERT INTO `characters` (`cid`, `steam`, `slot`, `firstname`, `lastname`, `dateofbirth`, `biography`, `job`, `sex`, `cash`, `dailyWithdraw`, `needs`, `health`, `height`, `playtime`,`email`,`twitter`) VALUES (@cid, @steam, @slot, @firstname, @lastname, @dateofbirth, @biography, @job, @sex, @cash, @dailyWithdraw, @needs, @health, @height, @playtime, @email, @twitter)", {
                            ['@cid'] = cid,
                            ['@steam'] = self.steam,
                            ['@slot'] = data.slot,
                            ['@firstname'] = data.firstName,
                            ['@lastname'] = data.lastName,
                            ['@dateofbirth'] = data.dateOfBirth,
                            ['@biography'] = data.biography,
                            ['@sex'] = data.gender,
                            ['@cash'] = Config.NewCharacters.startCash,
                            ['@dailyWithdraw'] = Config.NewCharacters.dailyWithdraw,
                            ['@needs'] = json.encode(Config.NewCharacters.needs),
                            ['@job'] = json.encode(Config.NewCharacters.job),
                            ['@health'] = Config.NewCharacters.health,
                            ['@height'] = data.height,
                            ['@playtime'] = Config.NewCharacters.playtime,
                            ['@email'] = generatedEmail,
                            ['@twitter'] = generatedTwitter
                            })

                            if created > 0 then
                                local accountNumber = math.random(10000000,99999999)
                                local sortCode = math.random(100000,999999)
                                local IBAN = "IBAN"..math.random(1000000000,9999999999)
                                local createBankAccount = MySQL.Sync.insert("INSERT INTO `banking` (`cid`,`account_number`,`sort_code`,`balance`,`type`,`account_meta`,`iban`,`creditScore`) VALUES (@cid, @acct, @sc, @balance, @type, @meta, @iban, @cscore)", {
                                    ['@cid'] = cid,
                                    ['@acct'] = accountNumber,
                                    ['@sc'] = sortCode,
                                    ['@balance'] = Config.NewCharacters.startBank,
                                    ['@type'] = "Personal",
                                    ['@meta'] = json.encode({['overdraft'] = 0, ['currentloan'] = 0}),
                                    ['@iban'] = IBAN,
                                    ['@cscore'] = 500
                                })
                                if createBankAccount > 0 then
                                    return true
                                end
                            end
                        end
                        return false
                    end
                end

                rTable.verifyLogin = function(data)
                    local verified = { ['valid'] = nil }
                    PerformHttpRequest("https://auth.pixelworldrp.com/login/process/"..data.emailAddress.."/"..data.emailPassword.."/15", function(httpCode, data2, resultHeaders)
                        if data2 == self.steam then
                            MySQL.Async.execute("UPDATE `users` SET `emailAddress` = @email WHERE `steam` = @steam", {['@email'] = data.emailAddress, ['@steam'] = self.steam}, function(done)
                                if done > 0 then
                                    self.query[1].emailAddress = data.emailAddress
                                end
                            end)
                            self.loggedIn = true
                            PerformHttpRequest("https://auth.pixelworldrp.com/login/process/"..data.emailAddress.."/"..data.emailPassword.."/16", function(httpCode, data3, resultHeaders)
                                if data3 == self.steam then
                                    self.developer = true
                                    ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                    PW.doAdminLog(self.source, "Logged in as Admin", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                else
                                    self.developer = false
                                end
                                verified = {['valid'] = true}
                            end)
                        elseif data2 == "-1" then
                            verified = {['valid'] = false, ['reason'] = "The password you have entered is incorrect"}
                        else
                            verified = {['valid'] = false, ['reason'] = "Steam ID does not Match the Logged in Forum Account"}
                        end
                    end)
                    
                    repeat Wait(0) until verified.valid ~= nil
                    return verified
                end

                rTable.saveUser = function(notify)
                    local name = GetPlayerName(self.source)
                    local saved = MySQL.Sync.execute("UPDATE `users` SET `identifiers` = @ident, `name` = @name WHERE `steam` = @steam", {
                        ['@ident'] = json.encode(GetPlayerIdentifiers(self.source)),
                        ['@name'] = name,
                        ['@steam'] = steam
                    })
                    if saved > 0 then
                        if notify then
                            print(' ^1[PixelWorld Core] ^7- User (^4'..name..'^7) has been ^2successfully ^7saved and unloaded.^7')
                        end
                        return true
                    else
                        if notify then
                            print(' ^1[PixelWorld Core] ^7- User (^4'..name..'^7) has ^1not ^7been successfully saved but ^2successfully ^7unloaded.^7')
                        end
                        return false
                    end
                end

                print(' ^1[PixelWorld Core] ^7- User (^4'..self.query[1].name..'^7) has been successfully loaded.^7')
                return rTable
            else
                DropPlayer(src, "We could not locate your user account, please try reconnecting to PixelWorld again to resolve this.")
                return nil
            end
        end
    end
end