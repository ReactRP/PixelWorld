PW = nil
registeredWeapons, itemStore, weaponsDB = {}, {}, {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

--[[
    example table for registering a weapon AKA the "info" table
    info = {
        ['name'] = "WEAPON_SMG",
        ['ammo'] = 120,
        ['cid'] = exports['pw_core']:getCharacter(_src).getCID(),
        ['source'] = 0,
        ['purchaseMethod'] = { ['method'] = "card/cash/none", ['card'] = 32523598732575, ['cost'] = 1000, ['obtainedBy'] = "shop/drop" }
    }
]]

function registerWeapon(info)
    if info == nil then return; end
    if info then
        local self = {}
        self.serial = math.random(10000000,99999999)
        self.info = {['name'] = info.name, ['ammo'] = info.ammo, ['owner'] = info.cid, ['source'] = (info.source or nil), ['purchaseDate'] = os.date("%Y-%m-%d"), ['purchaseServerTime'] = os.date("%H:%M:%S"), ['purchaseMethod'] = { ['method'] = info.purchaseMethod.method, ['card'] = (info.purchaseMethod.card or nil), ['cost'] = (info.purchaseMethod.cost or 0), ['itemIdent'] = 0 }}
        self.meta = { ['used'] = false, ['killed'] = false, ['reloaded'] = false, ['evidence'] = false}
        local weaponConfig = retreiveWeapon(info.name)
        self.components = {}
        for k, v in pairs(weaponConfig.components) do
            self.components[v.hash] = v 
        end
        if info.source ~= nil and info.source > 0 then
            self.char = exports['pw_core']:getCharacter(info.source)
        end

        MySQL.Async.insert("INSERT INTO `registered_weapons` (`weapon_serial`,`weapon_name`,`weapon_information`,`weapon_components`,`weapon_meta`) VALUES (@serial, @name, @info, @comp, @meta)", {
            ['@serial'] = self.serial,
            ['@name'] = self.info.name,
            ['@info'] = json.encode(self.info),
            ['@comp'] = json.encode(self.components),
            ['@meta'] = json.encode(self.meta)
        }, function(inserted)
            if inserted > 0 then
                if self.char then
                    self.char:Inventory():Add().Default(1, self.info.name, 1, {['serial'] = self.serial, ['owner'] = self.char.getFullName()}, {['serial'] = self.serial, ['cid'] = info.cid, ['table'] = "registered_weapons", ['tableid'] = inserted}, function(done)
                        if done then
                            registeredWeapons[self.serial] = loadWeapon(inserted)
                            if registeredWeapons[self.serial] then
                                registeredWeapons[self.serial].updateItemID(tonumber(done.record_id))
                            end
                        end
                    end)
                else
                    registeredWeapons[self.serial] = loadWeapon(inserted)
                end
            end
        end)
    end
end

exports('registerWeapon', function(info)
    if info and type(info) == "table" then
        if itemStore[info.name] then
            registerWeapon(info)
        else
            return nil
        end
    end
end)

exports('getClientLoadWeapon', function(serial)
    if registeredWeapons[tonumber(serial)] then
        return registeredWeapons[tonumber(serial)].loadClientData()
    else
        return nil
    end
end)

function loadWeapon(id)
    if id == nil then return; end

    if id then
        local self = {}
        local rTable = {}
        self.wid = id

        self.query = MySQL.Sync.fetchAll("SELECT * FROM `registered_weapons` WHERE `weapon_id` = @wid", {['@wid'] = self.wid})[1] or nil

        if self.query == nil then return; end

        if self.query then
            self.weaponinfo = (json.decode(self.query.weapon_information) or nil)
            self.weaponmeta = (json.decode(self.query.weapon_meta) or nil)
            self.weaponComponents = (json.decode(self.query.weapon_components) or {})
            if self.weaponinfo.itemIdent ~= nil and self.weaponinfo.itemIdent > 0 then
                self.health = MySQL.Sync.fetchScalar("SELECT `health` FROM `stored_items` WHERE `record_id` = @record", {['@record'] = self.weaponinfo.itemIdent}) or 100
            end

            rTable.getSerial = function()
                return self.query.weapon_serial
            end

            rTable.getWeaponHash = function()
                return self.query.weapon_name
            end

            rTable.getWeaponComponents = function()
                return self.weaponComponents
            end

            rTable.getAmmo = function()
                return self.weaponinfo.ammo
            end

            rTable.getItemID = function()
                return self.weaponinfo.itemIdent
            end

            rTable.getOwner = function()
                return self.weaponinfo.owner
            end

            rTable.getWeaponMeta = function()
                return self.weaponmeta
            end

            rTable.updateAmmo = function(ammo)
                if ammo and type(ammo) == "number" then
                    self.weaponinfo.ammo = ammo
                    MySQL.Sync.execute("UPDATE `registered_weapons` SET `weapon_information` = @info WHERE `weapon_id` = @wid", {['@info'] = json.encode(self.weaponinfo), ['@wid'] = self.wid})
                end
            end

            rTable.decreaseAmmo = function()
                self.weaponinfo.ammo = (self.weaponinfo.ammo - 1)
                self.health = (self.health - 0.09)
                MySQL.Sync.execute("UPDATE `registered_weapons` SET `weapon_information` = @info WHERE `weapon_id` = @wid", {['@info'] = json.encode(self.weaponinfo), ['@wid'] = self.wid})
                if self.health ~= nil and self.weaponinfo.itemIdent ~= nil and self.weaponinfo.itemIdent ~= 0 then
                    MySQL.Sync.execute("UPDATE `stored_items` SET `health` = @health WHERE `record_id` = @record", {['@health'] = self.health, ['@record'] = self.weaponinfo.itemIdent})
                end

            end

            rTable.updateItemID = function(id)
                self.weaponinfo.itemIdent = id
                MySQL.Sync.execute("UPDATE `registered_weapons` SET `weapon_information` = @info WHERE `weapon_id` = @wid", {['@info'] = json.encode(self.weaponinfo), ['@wid'] = self.wid})
                self.health = MySQL.Sync.fetchScalar("SELECT `health` FROM `stored_items` WHERE `record_id` = @record", {['@record'] = self.weaponinfo.itemIdent}) or 100
            end

            rTable.updateMeta = function(k, v)
                self.weaponmeta[k] = v
                MySQL.Sync.execute("UPDATE `registered_weapons` SET `weapon_meta` = @info WHERE `weapon_id` = @wid", {['@info'] = json.encode(self.weaponmeta), ['@wid'] = self.wid})
            end

            rTable.getMeta = function(k)
                if self.weaponmeta[k] then
                    return self.weaponmeta[k]
                else
                    return false
                end
            end

            rTable.loadClientData = function()
                local returnTable = {
                    ['WEAPON_ID'] = self.query.weapon_id,
                    ['WEAPON_NAME'] = self.query.weapon_name,
                    ['WEAPON_HASH'] = GetHashKey(self.query.weapon_name),
                    ['WEAPON_AMMO'] = self.weaponinfo.ammo,
                    ['WEAPON_COMP'] = self.weaponComponents,
                    ['WEAPON_SERIAL'] = self.query.weapon_serial
                }
                return returnTable
            end

            return rTable
        end      
    end
end

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    itemStore = caches.itemStore -- The Servers Item Database
    weaponsDB = caches.weapons -- The Servers Weapons Cache Database
    for k, v in pairs(weaponsDB) do
        registeredWeapons[tonumber(v.weapon_serial)] = loadWeapon(tonumber(v.weapon_id))
    end
end)


