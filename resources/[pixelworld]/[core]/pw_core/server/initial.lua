PWBase['StartUp'] = {
    AuthCheck = function()
        local randomInt = math.random(0,50000)
        if apiKey ~= nil and apiKey ~= "invalid" then
            PWMySQL.Async.fetchScalar("SELECT `respondWith` FROM `apiKeys` WHERE `keyId` = @api", {['@api'] = apiKey}, function(test)
                if (tonumber(test) + randomInt) ~= (tonumber(apiKeyResp) + randomInt) then
                    print(' ^2[PixelWorld API Server] ^7- Server license key authentication ^1FAILED^7')
                    StopResource("pw_core")
                else
                    print('\n ^2=^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^7-^9-^1-^2-^3-^4-^5-^7-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^1=^7')
                    print(' ^2= ^1██████╗ ^2██╗^3██╗  ██╗^4███████╗^5██╗     ^6██╗    ██╗^7 ██████╗ ^8██████╗ ^9██╗     ^1██████╗ ^7 ^2=')
                    print(' ^3= ^1██╔══██╗^2██║^3╚██╗██╔╝^4██╔════╝^5██║     ^6██║    ██║^7██╔═══██╗^8██╔══██╗^9██║     ^1██╔══██╗^7 ^3=')
                    print(' ^4= ^1██████╔╝^2██║^3 ╚███╔╝ ^4█████╗  ^5██║     ^6██║ █╗ ██║^7██║   ██║^8██████╔╝^9██║     ^1██║  ██║^7 ^4=')
                    print(' ^5= ^1██╔═══╝ ^2██║^3 ██╔██╗ ^4██╔══╝  ^5██║     ^6██║███╗██║^7██║   ██║^8██╔══██╗^9██║     ^1██║  ██║^7 ^5=')
                    print(' ^6= ^1██║     ^2██║^3██╔╝ ██╗^4███████╗^5███████╗^6╚███╔███╔╝^7╚██████╔╝^8██║  ██║^9███████╗^1██████╔╝^7 ^6=')
                    print(' ^7= ^1╚═╝     ^2╚═╝^3╚═╝  ╚═╝^4╚══════╝^5╚══════╝^6 ╚══╝╚══╝ ^7 ╚═════╝ ^8╚═╝  ╚═╝^9╚══════╝^1╚═════╝ ^7 ^7=')
                    print(' ^8=       ^8██████╗ ^7 ██████╗ ^6██╗     ^5███████╗^4██████╗ ^3██╗     ^2 █████╗ ^1██╗   ██╗^7       ^8=')
                    print(' ^9=       ^8██╔══██╗^7██╔═══██╗^6██║     ^5██╔════╝^4██╔══██╗^3██║     ^2██╔══██╗^1╚██╗ ██╔╝^7       ^9=')
                    print(' ^1=       ^8██████╔╝^7██║   ██║^6██║     ^5█████╗  ^4██████╔╝^3██║     ^2███████║^1 ╚████╔╝ ^7      ^1 =')
                    print(' ^2=       ^8██╔══██╗^7██║   ██║^6██║     ^5██╔══╝  ^4██╔═══╝ ^3██║     ^2██╔══██║^1  ╚██╔╝  ^7      ^2 =')
                    print(' ^3=       ^8██║  ██║^7╚██████╔╝^6███████╗^5███████╗^4██║     ^3███████╗^2██║  ██║^1   ██║   ^7      ^3 =')
                    print(' ^4=       ^8╚═╝  ╚═╝^7 ╚═════╝ ^6╚══════╝^5╚══════╝^4╚═╝     ^3╚══════╝^2╚═╝  ╚═╝^1   ╚═╝   ^7      ^4 =')
                    print(' ^5=                          ^5██╗   ██╗^8███████╗^2   ^1 ██████╗ ^7                         ^5=')
                    print(' ^6=                          ^5██║   ██║^8██╔════╝^2   ^1██╔═████╗^7                         ^6=')
                    print(' ^7=                          ^5██║   ██║^8███████╗^2   ^1██║██╔██║^7                         ^7=')
                    print(' ^8=                          ^5╚██╗ ██╔╝^8╚════██║^2   ^1████╔╝██║^7                         ^8=')
                    print(' ^9=                          ^5 ╚████╔╝ ^8███████║^2██╗^1╚██████╔╝^7                         ^9=')
                    print(' ^1=                          ^5  ╚═══╝  ^8╚══════╝^2╚═╝^1 ╚═════╝ ^7                         ^1=')
                    print(' ^2=^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^7-^9-^1-^2-^3-^4-^5-^7-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^9-^1-^2-^3-^4-^5-^6-^7-^8-^1=^7')
                    print('\n Welcome to the PixelWorld Rolaplay Framework V5.0.\n This framework has been redeveloped with security features for leaks.\n')
                    print(' ^2[PixelWorld API Server] ^7- API authentication ^2SUCCEEDED^7')
                    PWBase['StartUp'].SQLCheck(apiKey, apiKeyResp)
                end
            end)
        else

        end
    end,
    SQLCheck = function(key, resp)
        print(' ^2[PixelWorld MySQL] ^7- FiveM Server Database Connection ^2SUCCEEDED^7')
        PWBase['StartUp'].DatabaseLoads(false, key, resp)
    end,
    DatabaseLoads = function(force, key, resp)
        local loaded = 0
        if not force then
            print(' ^1[PixelWorld Core] ^7', '^3Loading PixelWorld Database Caches...^7')
        else
            print(' ^1[PixelWorld Core] ^7', '^3Refreshing PixelWorld Database Caches...^7')
        end
        PWBase['StartUp'].InventoryLoad(function(items)
            PWBase['Storage'].itemStore = items
            if not force then
                print(' ^1[PixelWorld Core] ^7', 'Inventory Database Loaded^4', PW.CountTable(items)..'^7 items.')
            end
            loaded = (loaded + 1)
        end)
        repeat Wait(0) until loaded == 1
        PWBase['StartUp'].loadUsers(function(usersLoaded)
            PWBase['Storage'].users = usersLoaded
            if not force then
                print(' ^1[PixelWorld Core] ^7', 'Users Database Loaded^4', '', PW.CountTable(usersLoaded)..'^7 users.')
            end
            loaded = (loaded + 1)
        end)
        repeat Wait(0) until loaded == 2
        PWBase['StartUp'].loadCharacters(function(loadCharacters)
            PWBase['Storage'].characters = loadCharacters
            if not force then
                print(' ^1[PixelWorld Core] ^7', 'Characters Database Loaded^4', PW.CountTable(loadCharacters)..'^7 characters.')
            end
            loaded = (loaded + 1)
        end)
        repeat Wait(0) until loaded == 3
        PWBase['StartUp'].EntityLoad(function(loadEnts)
            PWBase['Storage'].entities = loadEnts
            loaded = (loaded + 1)
        end, force)
        repeat Wait(0) until loaded == 4
        PWBase['StartUp'].loadVehicles(function(loadVehicles)
            PWBase['Storage'].vehicles = loadVehicles
            if not force then
                print(' ^1[PixelWorld Core] ^7', 'Vehicles Database Loaded^4', PW.CountTable(loadVehicles)..'^7 vehicles.')
            end
            loaded = (loaded + 1)
        end)
        repeat Wait(0) until loaded == 5
        PWBase['StartUp'].loadProperties(function(loadProperties)
            PWBase['Storage'].properties = loadProperties
            if not force then
                print(' ^1[PixelWorld Core] ^7', 'Properties Database Loaded^4', PW.CountTable(loadProperties)..'^7 properties.')
            end
            loaded = (loaded + 1)
        end)
        repeat Wait(0) until loaded == 6
        PWBase['StartUp'].loadShopItems(function(sets)
            PWBase['Storage'].shopItemSets = sets
            if not force then
                print(' ^1[PixelWorld Core] ^7', 'Shop Itemsets Loaded^4', PW.CountTable(sets)..'^7 sets.')
            end
            loaded = (loaded + 1)
        end)
        repeat Wait(0) until loaded == 7
        if force then
            print(' ^1[PixelWorld Core] ^7', '^2Database Cache has been successfully refreshed^7')
        else
            print(' ^1[PixelWorld Core] ^7', '^2Finished Loading PixelWorld Caches^7')
        end
        TriggerEvent('pw:databaseCachesLoaded', PWBase['Storage'])
        if not force then
            TriggerEvent('pw:serverProcessSuccessful', key, resp)       
        end
    end,
    loadShopItems = function(cb)
        local sets = {}
        MySQL.Async.fetchAll("SELECT * FROM `shop_items`", {}, function(sitems)
            for k, v in pairs(sitems) do
                sets[v.itemset_id] = v.items
            end
            cb(sets)
        end)
    end,
    loadUsers = function(cb)
        MySQL.Async.fetchAll("SELECT * FROM `users`", {}, function(usersTbl)
            if usersTbl ~= nil then
                cb(usersTbl)
            else
                cb(nil)
            end
        end)
    end,
    loadVehicles = function(cb)
        MySQL.Async.fetchAll("SELECT * FROM `avaliable_vehicles` WHERE `show` = 1 ORDER BY `name` ASC", {}, function(vehs)
            if vehs ~= nil then
                cb(vehs)
            else
                cb(nil)
            end
        end)
    end,
    loadProperties = function(cb)
        MySQL.Async.fetchAll("SELECT * FROM `properties`", {}, function(props)
            if props ~= nil then
                cb(props)
            else
                cb(nil)
            end
        end)
    end,
    loadCharacters = function(cb)
        MySQL.Async.fetchAll("SELECT * FROM `characters`", {}, function(charsTbl)
            if charsTbl ~= nil then
                for k, v in pairs(charsTbl) do
                    offlineCharacter[v.cid] = generateOfflineDetails(v.cid)
                end
                cb(charsTbl)
            else
                cb(nil)
            end
        end)
    end,
    EntityLoad = function(cb, force)
        local data = {}
        MySQL.Async.fetchAll("SELECT * FROM `entity_types`", {}, function(ents)
            if ents ~= nil then
                for k, v in pairs(ents) do
                    data[v.id] = {
						label = v.label,
						slots = v.slots
					}
                end
                if not force then
                    print(' ^1[PixelWorld Core] ^7', 'Entities Database Loaded^4', PW.CountTable(data)..'^7 entity types.')
                end
            else
                data = {
					[0] = { label = 'Unknown', slots = 10 },
					[1] = { label = 'Player', slots = 40 },
					[2] = { label = 'Drop', slots = 100 },
					[3] = { label = 'Container', slots = 100 },
					[4] = { label = 'Glove Box', slots = 5 },
					[5] = { label = 'Player Glove Box', slots = 7 },
					[6] = { label = 'Trunk', slots = 20 },
					[7] = { label = 'Player Trunk', slots = 40 },
					[8] = { label = 'Motel Weapon Stash', slots = 15 },
					[9] = { label = 'Motel Storage', slots = 30 },
					[10] = { label = 'Property Weapon Stash', slots = 25 },
					[11] = { label = 'Property Stash', slots = 50 },
					[12] = { label = 'Property Stash', slots = 65 },
					[13] = { label = 'Property Stash', slots = 75 },
					[14] = { label = 'Property Stash', slots = 100 },
					[15] = { label = 'Police Evidence', slots = 1000 },
					[16] = { label = 'Police Trash', slots = 1000 },
                }
                if not force then
                    print(' ^1[PixelWorld Core] ^7', 'Default Entities Database Loaded^4', PW.CountTable(data)..'^7 entity types.')
                end
            end
            cb(data)
        end)
    end,
    InventoryLoad = function(cb)
        local itemList = {}
        MySQL.Async.fetchAll("SELECT * FROM `items_database`", {}, function(items)
            if items[1] ~= nil then
                for k, v in pairs(items) do
					local isStackable = true
					if not v['item_stackable'] then
						isStackable = false
					end
	
					local closeUI = false
					if v['item_closeui'] then
						closeUI = true
					end

					local metalDetect = false
					if v['item_metalDetect'] then
						metalDetect = true
                    end
                    
                    local removableItem = false
                    if v['item_removable'] then
						removableItem = true
                    end

                    local evidenceItem = false
                    if v['item_evidence'] then
						evidenceItem = true
                    end
	
					local isUnique = v['item_unique']
	
					itemList[v['item_name']] = {
						name = v['item_name'],
						label = v['item_label'],
						description = v['item_description'],
						unique = isUnique,
						stackable = isStackable,
						max = v['item_max'],
						type = v['item_type'],
                        price = v['item_price'],
                        removable = removableItem,
                        weight = v['item_weight'],
                        image = v['item_image'],
                        reqMeta = (v['item_reqmeta'] ~= nil and json.decode(v['item_reqmeta']) or {}),
                        craftingMeta = (v['item_crafting'] ~= nil and json.decode(v['item_crafting']) or {}),
                        evidence = evidenceItem,
						needs = (v['item_needsboost'] ~= nil and json.decode(v['item_needsboost']) or {}),
						metal = metalDetect,
						closeUi = closeUI
					}
				end
				cb(itemList)
            else
                cb(nil)
            end
        end)
    end,
    CreateUser = function(steam, src)
        if steam then
            local exists = MySQL.Sync.fetchAll("SELECT * FROM `users` WHERE `steam` = @steam", {['@steam'] = steam})
            if exists[1] == nil then
                print(' ^1[PixelWorld Core] ^4- Attempting User Creation')
                local time = os.date("%Y-%m-%d %H:%M:%S")
                local create = MySQL.Sync.insert("INSERT INTO `users` (`steam`, `name`, `first_login`, `last_login`, `identifiers`) VALUES (@steam, @name, @firstl, @lastl, @idents)", {
                    ['@steam'] = steam,
                    ['@name'] = GetPlayerName(src),
                    ['@firstl'] = time,
                    ['@lastl'] = time,
                    ['@idents'] = json.encode(GetPlayerIdentifiers(src))
                })
                if create > 0 then
                    print(' ^1[PixelWorld Core] ^4- New User Created')
                    PWBase['StartUp'].loadUsers(function(usersLoaded)
                        PWBase['Storage'].users = usersLoaded
                        print(' ^1[PixelWorld Core] ^7', 'Users Database Recached^4', '', PW.CountTable(usersLoaded)..'^7 users')
                    end)
                    return true
                else
                    return PWBase['StartUp'].CreateUser(steam, src)
                end
            else
                return true
            end
        else
            DropPlayer(src, "Failed to create a User Account on PixelWorld, please try reconnecting.")
        end
    end,
    LoadUser = function(steam, src)
        if steam and src then
            if not Users[src] then
                print(' ^1[PixelWorld Core] ^4- User Connecting...')
                Users[src] = loadUser(steam, src)
                TriggerEvent("pw:playerLoaded", Users[src])
                PWBase['StartUp'].LoadLogin(src)
            end
        else
            DropPlayer(src, "Your User account could not be loaded, please try reconnecting to PixelWorld")
        end
    end,
    LoadLogin = function(src)
        if src and Users[src] then
            TriggerClientEvent('pw_core:nui:loadLogin', src, Users[src].getSteam(), Users[src].getEmailAddress())
        end
    end,
}

PWBase['Characters'] = {
    CreateCharacter = function(src, data)
        if Users[src] then
            if Users[src].createCharacter(data) then
                TriggerClientEvent('pw_core:nui:loadCharacters', src, Users[src].getCharacters())
                PWBase['StartUp'].loadCharacters(function(loadCharacters)
                    PWBase['Storage'].characters = loadCharacters
                    print(' ^1[PixelWorld Core] ^7', 'Characters Database Recached^4', PW.CountTable(loadCharacters)..'^7 characters')
                end)
            end
        end
    end,
    LoadCharacter = function(src, cid)
        return Users[src].loadCharacter(src, tonumber(cid))
    end,
}

RegisterServerEvent('pw_core:server:createCharacter')
AddEventHandler('pw_core:server:createCharacter', function(data)
    local _src = source
    if data then
        PWBase['Characters'].CreateCharacter(_src, data)
    end
end)

RegisterServerEvent('pw:switchCharacter')
AddEventHandler('pw:switchCharacter', function()
    local _src = source
    if Characters[_src] and Users[_src] then
        TriggerClientEvent('pw:characterLoaded', _src, true)
        Wait(1000)
        TriggerClientEvent('pw_core:nui:openFS', _src)
        if Users[_src].unloadCharacter() then
            TriggerClientEvent('pw_core:nui:loadCharacters', _src, Users[_src].getCharacters())
        end
    end
end)

RegisterServerEvent('pw_core:server:selectCharacter')
AddEventHandler('pw_core:server:selectCharacter', function(data)
    local _src = source
    if data and Users[_src] then
        if PWBase['Characters'].LoadCharacter(_src, data.cid) then
            if Characters[_src] then
                local characterData = {
                    ['name'] = Characters[_src].getFullName(),
                    ['firstname'] = Characters[_src].getFirstName(),
                    ['lastname'] = Characters[_src].getLastName(),
                    ['dateofbirth'] = Characters[_src].getDob(),
                    ['steam'] = Users[_src].getSteam(),
                    ['cid'] = Characters[_src].getCID(),
                    ['email'] = Characters[_src].getEmail(),
                    ['twitter'] = Characters[_src].getTwitter(),
                    ['gender'] = Characters[_src].getSex(),
                    ['job']  = Characters[_src]:Job().getJob(),
                    ['developer'] = Users[_src].getDeveloperState(),
                    ['loggedin'] = Users[_src].getLoginState(),
                    ['cash'] = Characters[_src]:Cash().getBalance(),
                    ['bank'] = Characters[_src]:Bank().getBalance(),
                    ['needs'] = Characters[_src]:Needs().getNeeds()
                }
                TriggerClientEvent('pw:characterLoaded', _src, false, false, characterData)
                if Characters[_src].newCharacterCheck() then
                    -- Load into Character Creator
                    local selectedSpawn = PW.GenerateCharCreLoc(_src)
                    TriggerClientEvent('pw_core:client:transitiontoCharCreation', _src, Characters[_src].getSex(), selectedSpawn)
                else
                    -- Load Character Spawn Locations
                    TriggerClientEvent('pw_core:nui:loadCharacterSpawns', _src, Characters[_src].getSpawns())
                end
            end
        else
            TriggerClientEvent('pw_core:nui:loadCharacters', _src, Users[_src].getCharacters())
        end
    end
end)

RegisterServerEvent('pw_core:server:playerReady')
AddEventHandler('pw_core:server:playerReady', function()
    local _src = source
    if _src then
        TriggerClientEvent('pw:characterLoaded', _src, false, true)
    end
end)

PWMySQL.ready(function()
    PWBase['StartUp'].AuthCheck()
end)