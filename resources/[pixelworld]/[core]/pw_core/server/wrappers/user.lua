function loadUser(steam, src, temp)
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
        self.owner = false
        self.privAccess = false
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

                rTable.getOwnerState = function()
                    return self.owner
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

                rTable.privAccess = function()
                    return self.privAccess
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
                        exports['pw_motels']:assignRoom(self.source, cid)
                        --TriggerEvent('pw_motels:server:assignMotelRoom', src, Characters[src].getCID())
                        self.loadedCharacter = Characters[src].getCID()
                        self.characterLoaded = true
                        return true
                    else
                        return false
                    end
                end

                rTable.unloadCharacter = function()
                    if Characters[self.source] then
                        local cid = Characters[self.source].getCID()
                        exports['pw_motels']:unassignRoom(self.source, cid)
                        --TriggerEvent('pw_motels:server:unAssignMotelRoom', src, cid)
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

                rTable.doLogin = function(info, cb)
                    if info.success then
                        local adminLogged = false
                        if info.owner then
                            self.owner = true
                            ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                            if not adminLogged then
                                PW.doAdminLog(self.source, "Logged in as a Owner", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                adminLogged = true
                            end
                        end

                        if info.developer then
                            self.developer = true
                            ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                            if not adminLogged then
                                PW.doAdminLog(self.source, "Logged in as a Developer", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                adminLogged = true
                            end
                        end

                        if info.privAccess then
                            self.privAccess = true
                            if not adminLogged then
                                PW.doAdminLog(self.source, "Logged in as a Privileged", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                adminLogged = true
                            end
                        end                       
                        self.loggedIn = true
                        cb(self.loggedIn)
                    else
                        DropPlayer(self.source, "You user account has not been validated correctly.")
                        cb(self.loggedIn)
                    end
                end

                rTable.verifyOTP = function(otp, cb)
                    PerformHttpRequest("https://api.pixelworldrp.com/2fa/"..self.steam.."/"..otp, function(err, text, headers)
                        if text ~= nil then
                            local data = json.decode(text)
                            if data.access == true then
                                local validAccess = false
                                if self.steam == data.steam then
                                    local doneAdminLog = false
                                    if tonumber(data.primary_group) == 8 then
                                        self.owner = true
                                        validAccess = true
                                    end

                                    if not validAccess then
                                        for k, v in pairs(data.groups) do
                                            if tonumber(v) == 8 then
                                                self.owner = true
                                                validAccess = true
                                                break;
                                            end
                                            
                                            if tonumber(v) == 16 then
                                                self.developer = true
                                                validAccess = true
                                                break;
                                            end

                                            if tonumber(v) == 19 then
                                                self.privAccess = true
                                                validAccess = true
                                                break;
                                            end

                                            if tonumber(v) == 18 then
                                                DropPlayer(self.source, "Sorry you have been banned from accessing the PixelWorld Services")
                                                Users[self.source] = nil
                                            end
        
                                            if tonumber(v) == 15 then
                                                validAccess = true
                                            end
                                        end
                                    end
    
                                    if validAccess then
                                        self.loggedIn = true
                                        cb({ ['success'] = true, ['reason'] = "We have validated your account.", ['developer'] = self.developer, ['privAccess'] = self.privAccess, ['owner'] = self.owner})
                                    else
                                        cb({ ['success'] = false, ['reason'] = "You are not whitelisted on our FiveM Server."})
                                    end
                                else
                                    cb({ ['success'] = false, ['reason'] = "Your Steam ID Does not match your forum account."})
                                end
                            else
                                cb({ ['success'] = false, ['reason'] = data.reason.."."})
                            end
                        else
                            cb({ ['success'] = false, ['reason'] = "We could not validate your account."})
                        end
                    end)
                end

                rTable.verifyLogin = function(info, secondary) 
                    if secondary then


                    else
                        PerformHttpRequest("https://api.pixelworldrp.com/2fa/"..self.steam.."/"..otp, function(err, text, headers)
                            if text ~= nil then
                                local data = json.decode(text)
                                if data.access == true then
                                    local validAccess = false
                                    if self.steam == data.steam then
                                        local doneAdminLog = false
                                        if tonumber(data.primary_group) == 8 then
                                            self.owner = true
                                            if not temp then
                                                ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                                if not doneAdminLog then
                                                    PW.doAdminLog(self.source, "Logged in as Owner", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                    doneAdminLog = true
                                                end
                                            end
                                        end
    
                                        for k, v in pairs(data.groups) do
                                            if tonumber(v) == 8 then
                                                self.developer = true
                                                if not temp then
                                                    ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                                    if not doneAdminLog then
                                                        PW.doAdminLog(self.source, "Logged in as Admin", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                        doneAdminLog = true
                                                    end
                                                end
                                            end
                                            
                                            if tonumber(v) == 16 then
                                                self.developer = true
                                                if not temp then
                                                    ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                                    if not doneAdminLog then
                                                        PW.doAdminLog(self.source, "Logged in as Admin", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                        doneAdminLog = true
                                                    end
                                                end
                                            end
    
                                            if tonumber(v) == 19 then
                                                self.privAccess = true
                                                if not temp then
                                                    if not doneAdminLog then
                                                        PW.doAdminLog(self.source, "Logged in as Development Tester", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                        doneAdminLog = true
                                                    end
                                                end
                                            end
    
                                            if tonumber(v) == 18 then
                                                DropPlayer(self.source, "Sorry you have been banned from accessing the PixelWorld Services")
                                                Users[self.source] = nil
                                            end
        
                                            if tonumber(v) == 15 then
                                                validAccess = true
                                            end
                                        end
        
                                        if validAccess then
                                                self.loggedIn = true
                                                cb({ ['success'] = true, ['reason'] = "We have validated your account.", ['developer'] = self.developer, ['privAccess'] = self.privAccess, ['owner'] = self.owner})
                                            --TriggerClientEvent('pw_core:nui:showNotice', self.source, "success", "You have successfully validated your account.", 5000)
                                            --TriggerClientEvent('pw_core:nui:loadCharacters', self.source, Users[self.source].getCharacters()) 
                                        else
                                            cb({ ['success'] = false, ['reason'] = "You are not whitelisted on our FiveM Server."})
                                            --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", "You are not whitelisted on our FiveM Server.", 5000)
                                            --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                                        end
                                    else
                                        cb({ ['success'] = false, ['reason'] = "Your Steam ID Does not match your forum account."})
                                        --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", "Your Steam ID Does not match your forum account.", 5000)
                                        --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                                    end
                                else
                                    cb({ ['success'] = false, ['reason'] = data.reason.."."})
                                    --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", data.reason..".", 5000)
                                    --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                                end
                            else
                                cb({ ['success'] = false, ['reason'] = "We could not validate your account."})
                                --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", "We could not validate your account.", 5000)
                                --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                            end
                        end)
                    end
--[[
                    PW.Print('Authenticating User '..username..' '..password)
                    MySQL.Sync.execute("UPDATE `users` SET `emailAddress` = @email WHERE `steam` = @steam", {['@email'] = username, ['@steam'] = self.steam})
                    PerformHttpRequest("https://auth.pixelworldrp.com/login/newprocess/"..username.."/"..password, function(err, text, headers)
                        if text ~= nil then
                            local data = json.decode(text)
                            if data.access == true then
                                local validAccess = false
                                if self.steam == data.steam then
                                    local doneAdminLog = false
                                    if tonumber(data.primary_group) == 8 then
                                        self.owner = true
                                        if not temp then
                                            ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                            if not doneAdminLog then
                                                PW.doAdminLog(self.source, "Logged in as Owner", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                doneAdminLog = true
                                            end
                                        end
                                    end

                                    for k, v in pairs(data.groups) do
                                        if tonumber(v) == 8 then
                                            self.developer = true
                                            if not temp then
                                                ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                                if not doneAdminLog then
                                                    PW.doAdminLog(self.source, "Logged in as Admin", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                    doneAdminLog = true
                                                end
                                            end
                                        end
                                        
                                        if tonumber(v) == 16 then
                                            self.developer = true
                                            if not temp then
                                                ExecuteCommand(('add_principal identifier.%s group.admin'):format(self.steam))
                                                if not doneAdminLog then
                                                    PW.doAdminLog(self.source, "Logged in as Admin", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                    doneAdminLog = true
                                                end
                                            end
                                        end

                                        if tonumber(v) == 19 then
                                            self.privAccess = true
                                            if not temp then
                                                if not doneAdminLog then
                                                    PW.doAdminLog(self.source, "Logged in as Development Tester", {['name'] = GetPlayerName(self.source), ['time'] = os.date("%Y-%m-%d %H:%M:%S")}, true)
                                                    doneAdminLog = true
                                                end
                                            end
                                        end

                                        if tonumber(v) == 18 then
                                            DropPlayer(self.source, "Sorry you have been banned from accessing the PixelWorld Services")
                                            Users[self.source] = nil
                                        end
    
                                        if tonumber(v) == 15 then
                                            validAccess = true
                                        end
                                    end
    
                                    if validAccess then
                                            self.loggedIn = true
                                            cb({ ['success'] = true, ['reason'] = "We have validated your account.", ['developer'] = self.developer, ['privAccess'] = self.privAccess, ['owner'] = self.owner})
                                        --TriggerClientEvent('pw_core:nui:showNotice', self.source, "success", "You have successfully validated your account.", 5000)
                                        --TriggerClientEvent('pw_core:nui:loadCharacters', self.source, Users[self.source].getCharacters()) 
                                    else
                                        cb({ ['success'] = false, ['reason'] = "You are not whitelisted on our FiveM Server."})
                                        --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", "You are not whitelisted on our FiveM Server.", 5000)
                                        --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                                    end
                                else
                                    cb({ ['success'] = false, ['reason'] = "Your Steam ID Does not match your forum account."})
                                    --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", "Your Steam ID Does not match your forum account.", 5000)
                                    --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                                end
                            else
                                cb({ ['success'] = false, ['reason'] = data.reason.."."})
                                --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", data.reason..".", 5000)
                                --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                            end
                        else
                            cb({ ['success'] = false, ['reason'] = "We could not validate your account."})
                            --TriggerClientEvent('pw_core:nui:showNotice', self.source, "danger", "We could not validate your account.", 5000)
                            --TriggerClientEvent('pw_core:nui:loadLogin', self.source, Users[self.source].getSteam(), Users[self.source].getEmailAddress(), true)
                        end
                    end)]]
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
                            if not temp then
                                print(' ^1[PixelWorld Core] ^7- User (^4'..name..'^7) has been ^2successfully ^7saved and unloaded.^7')
                            end
                        end
                        return true
                    else
                        if notify then
                            if not temp then
                                print(' ^1[PixelWorld Core] ^7- User (^4'..name..'^7) has ^1not ^7been successfully saved but ^2successfully ^7unloaded.^7')
                            end
                        end
                        return false
                    end
                end
                if not temp then
                    print(' ^1[PixelWorld Core] ^7- User (^4'..self.query[1].name..'^7) has been successfully loaded.^7')
                end
                return rTable
            else
                DropPlayer(src, "We could not locate your user account, please try reconnecting to PixelWorld again to resolve this.")
                return nil
            end
        end
    end
end