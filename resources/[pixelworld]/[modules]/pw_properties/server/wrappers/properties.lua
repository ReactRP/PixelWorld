Houses = {}
InvSlots = {}

function getInventorySlots(invID)
    for k, v in pairs(InvSlots) do
        if v.id == invID then
            return { ['id'] = v.id, ['slots'] = v.slots, ['weight'] = 0.0 }
        end
    end
    return { ['id'] = 0, ['slots'] = 0, ['weight'] = 0.0}
end

function registerProperty(prop, v)
    local self = {}
    local rTable = {}
    local loaded = false
    if v then
        self.pid                = v.property_id
        self.name               = v.name
        self.storageInvLimit    = v.storageLimit
        self.basePrice          = v.purchaseCost
        if v.radials ~= nil then
            self.radiusLimits   = json.decode(v.radials)
            if self.radiusLimits.furnitureZ == nil then
                self.radiusLimits.furnitureZ = 3.0
                MySQL.Async.execute("UPDATE `properties` SET `radials` = @rad WHERE `property_id` = @pid", {['@rad'] = json.encode(self.radiusLimits), ['@pid'] = self.pid})
            end
        else
            self.radiusLimits   = {} 
            self.radiusLimits.inside = 20.0
            self.radiusLimits.outside = 10.0
            self.radiusLimits.furnitureZ = 3.0
        end
            
        if v.metainformation ~= nil then
            self.metaInformation                        = json.decode(v.metainformation)
            self.metaInformation['lockStatus']          = true
            self.metaInformation['brokenInto']          = false
        else
            self.DefaultCoords                          = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 }
            self.metaInformation                        = {}
            self.metaInformation['houseStatus']         = { ['forSale'] = true, ['forRent'] = false }
            self.metaInformation['houseState']          = { ['propertyOwned'] = false, ['propertyRented'] = false }
            self.metaInformation['CIDS']                = { ['owner'] = 0, ['rentor'] = 0 }
            self.metaInformation['lockStatus']          = true
            self.metaInformation['brokenInto']          = false
            self.metaInformation['allowRealEstate']     = false
            self.metaInformation['locations']           = { ['backInside'] = self.DefaultCoords, ['backEntrance'] = self.DefaultCoords, ['clothing'] = self.DefaultCoords, ['money'] = self.DefaultCoords, ['weapon'] = self.DefaultCoords, ['inventory'] = self.DefaultCoords, ['garage'] = self.DefaultCoords, ['location'] = json.decode(v.location), ['management'] = json.decode(v.manager), ['inside'] = json.decode(v.inside), ['charSpawn'] = json.decode(v.charSpawn), ['property'] = json.decode(v.location) }
            self.metaInformation['luxuryEnabled']       = { ['clothing'] = Config.DefaultLocationStatus.clothing, ['money'] = Config.DefaultLocationStatus.money, ['weapon'] = Config.DefaultLocationStatus.weapon, ['inventory'] = Config.DefaultLocationStatus.inventory, ['garage'] = Config.DefaultLocationStatus.garage, ['alarm'] = Config.DefaultLocationStatus.alarm }
            self.metaInformation['luxuryAvailable']     = { ['clothing'] = Config.DefaultLocationStatus.clothing, ['money'] = Config.DefaultLocationStatus.money, ['weapon'] = Config.DefaultLocationStatus.weapon, ['inventory'] = Config.DefaultLocationStatus.inventory, ['garage'] = Config.DefaultLocationStatus.garage }
            self.metaInformation['luxuryCost']          = { ['clothing'] = Config.StashPrices.clothing, ['inventory'] = Config.StashPrices.inventory, ['money'] = Config.StashPrices.money, ['garage'] = Config.StashPrices.garage, ['weapon'] = Config.StashPrices.weapon, ['alarm'] = Config.AlarmPrice }
            self.metaInformation['costs']               = { ['purchase'] = v.purchaseCost, ['rental'] = v.purchaseCost / 100 / 2 }
            self.metaInformation['radialLimits']        = { ['inside'] = self.radiusLimits.inside, ['outside'] = self.radiusLimits.outside, ['furnitureZ'] = self.radiusLimits.furnitureZ }
            self.metaInformation['rents']               = { ['total'] = 0, ['paid'] = 0, ['missed'] = 0, ['arrears'] = 0, ['pot'] = 0, ['securityDeposit'] = 0, ['evicting'] = false, ['evictingLeft'] = Config.EvictionCooldown }
            self.metaInformation['options']             = { ['autolock'] = false, ['alarm'] = false}
            MySQL.Async.execute("UPDATE `properties` SET `metainformation` = @meta WHERE `property_id` = @pid", {['@pid'] = self.pid, ['@meta'] = json.encode(self.metaInformation)})
        end

        if v.furniture ~= nil then
            self.furniture = json.decode(v.furniture)
        else
            self.furniture = {}
            MySQL.Async.execute("UPDATE `properties` SET `furniture` = @furn WHERE `property_id` = @pid", {['@pid'] = self.pid, ['@furn'] = json.encode(self.furniture)})
        end
        loaded = true
    end

    self.SaveHouse = function()
        MySQL.Async.execute("UPDATE `properties` SET `metainformation` = @meta WHERE `property_id` = @pid", { ['@pid'] = self.pid, ['@meta'] = json.encode(self.metaInformation) })
    end

    self.SaveFurniture = function()
        if self.furniture ~= nil and #self.furniture == 0 then self.furniture = {}; end
        MySQL.Async.execute("UPDATE `properties` SET `furniture` = @meta WHERE `property_id` = @pid", { ['@pid'] = self.pid, ['@meta'] = json.encode(self.furniture) })  
    end
    -------------------------------------
    -- Functions to retreive information
    -------------------------------------
    local pro = false
    MySQL.Async.fetchAll("SELECT * FROM `cash_stashes` WHERE `stash_identifier` = @pid AND `stash_type` = 'Property'", {['@pid'] = self.pid}, function(cashStorage)
        if cashStorage[1] ~= nil then
            self.storedCash = cashStorage[1].stash_amount
            pro = true
        else
            MySQL.Async.insert("INSERT INTO `cash_stashes` (`stash_type`, `stash_identifier`, `stash_amount`) VALUES ('Property', @pid, 0)", {['pid'] = self.pid}, function(done)
                self.storedCash = 0
                pro = true
            end)
        end
    end)
    repeat Wait(0) until pro == true
    pro = nil

    rTable.getName = function()
        return self.name
    end

    rTable.getStorageLimit = function()
        return getInventorySlots(tonumber(self.storageInvLimit))
    end

    rTable.getPid = function()
        return tonumber(self.pid)
    end

    rTable.getPropertyId = function()
        return self.pid
    end

    rTable.getOwner = function()
        return self.metaInformation['CIDS']['owner']
    end

    rTable.readMeta = function(key)
        if self.metaInformation[key] then
            return self.metaInformation[key]
        else
            return nil
        end
    end

    rTable.setMeta = function(key, value)
        if not self.metaInformation[key] then
            self.metaInformation[key] = value
            self.SaveHouse()
        end
    end

    rTable.updateMeta = function(key, value)
        if self.metaInformation[key] then
            self.metaInformation[key] = value
            self.SaveHouse()
        end
    end

    rTable.deleteMeta = function(key)
        if self.metaInformation[key] then
            self.metaInformation[key] = nil
            self.SaveHouse()
        end
    end

    rTable.getRadialLimit = function(req)
        if req ~= nil then
            if self.metaInformation['radialLimits'][req] then
                return self.metaInformation['radialLimits'][req]
            else
                return 0.0
            end
        else
            return 0.0
        end
    end

    self.storageLimit = { ['money'] = 5000000}

    rTable.GetStoredCash = function()
        return self.storedCash
    end

    rTable.GetLimits = function(req)
        return self.storageLimit[req]
    end

    rTable.getForSale = function()
        return self.metaInformation['houseStatus']['forSale']
    end

    rTable.getForRent = function()
        return self.metaInformation['houseStatus']['forRent']
    end

    rTable.getRentor = function()
        return self.metaInformation['CIDS']['rentor']
    end

    rTable.getLock = function()
        return self.metaInformation['lockStatus']
    end

    rTable.getStatus = function(req)
        if req == "owned" then
            return self.metaInformation['houseState']['propertyOwned']
        elseif req == "rented" then
            return self.metaInformation['houseState']['propertyRented']
        end
    end
    
    rTable.getCoords = function(req)
        if self.metaInformation['locations'][req] ~= nil then
            return self.metaInformation['locations'][req]
        else
            return { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0}
        end
    end

    rTable.getLuxaryStatus = function(req)
        return self.metaInformation['luxuryEnabled'][req]
    end

    rTable.getLuxaryRentStatus = function(req)
        return self.metaInformation['luxuryAvailable'][req]
    end
    
    rTable.getLuxaryLabel = function(req)
        if req == "money" then
            return "Money Stash"
        elseif req == "weapon" then
            return "Weapon Stash"
        elseif req == "inventory" then
            return "Item Stash"
        else
            return false
        end
    end
    
    rTable.getInventoryCost = function(req)
        return self.metaInformation['luxuryCost'][req]
    end
    
    rTable.getPurchaseCost = function()
        return self.metaInformation['costs']['purchase']
    end

    rTable.getBasePrice = function()
        return self.basePrice
    end
    
    rTable.getRentalCost = function()
        if self.metaInformation['costs']['rental'] == nil or self.metaInformation['costs']['rental'] == 0 then
            local math = self.metaInformation['costs']['purchase'] / 100 / 2
            return math
        else
            return self.metaInformation['costs']['rental']  
        end
    end
    
    rTable.getOwnerName = function()
        if self.metaInformation['CIDS']['owner'] ~= nil or self.metaInformation['CIDS']['owner'] ~= 0 then
            local ownerNameReturn
            local processed = false
            MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.metaInformation['CIDS']['owner'] }, function(ownerName)
                if ownerName[1] ~= nil then
                    ownerNameReturn = ownerName[1].firstname..' '..ownerName[1].lastname
                else
                    ownerNameReturn = nil
                end
                processed = true
            end)
            repeat Wait(0) until processed == true
            return ownerNameReturn
        else
            return nil
        end
    end
    
    rTable.getRentorName = function()
        if self.metaInformation['CIDS']['rentor'] ~= nil or self.metaInformation['CIDS']['rentor'] ~= 0 then
            local rentName
            local processed = false
            MySQL.Async.fetchAll("SELECT * FROM `characters` WHERE `cid` = @cid", {['@cid'] = self.metaInformation['CIDS']['rentor'] }, function(rentorName)
                if rentorName[1] ~= nil then
                    rentName = rentorName[1].firstname..' '..rentorName[1].lastname
                else
                    rentName = nil
                end
                processed = true
            end)
            repeat Wait(0) until processed == true
            return rentName
        else
            return nil
        end
    end

    rTable.getRent = function(req)
        return self.metaInformation['rents'][req]
    end
    
    rTable.getOptions = function(req)
        return self.metaInformation['options'][req]
    end

    rTable.getBroken = function()
        return self.metaInformation['brokenInto']
    end

    rTable.getRentRealEstate = function()
        return self.metaInformation['allowRealEstate']
    end

    rTable.getFurniture = function()
        return self.furniture
    end

    -- Generate the Specific House Table to be able to interact Client Side -- This must be below the GetInformation functions!!
    Houses[self.pid] = {
        ['entrance'] = rTable.getCoords('property'),
        ['interior'] = rTable.getCoords('inside'),
        ['exit'] = rTable.getCoords('inside'),
        ['ownerMenu'] = rTable.getCoords('management'),
        ['garage'] = rTable.getCoords('garage'),
        ['weapons'] = rTable.getCoords('weapon'),
        ['items'] = rTable.getCoords('inventory'),
        ['clothing'] = rTable.getCoords('clothing'),
        ['money'] = rTable.getCoords('money'),
        ['charSpawn'] = rTable.getCoords('charSpawn'),
        ['exitEntrance'] = rTable.getCoords('backEntrance'),
        ['exitInside'] = rTable.getCoords('backInside'),
        ['storageLimit'] = rTable.getStorageLimit(),
        ['hasGarage'] = rTable.getLuxaryStatus('garage'), ['hasWeapons'] = rTable.getLuxaryStatus('weapon'), ['hasItems'] = rTable.getLuxaryStatus('inventory'), ['hasMoney'] = rTable.getLuxaryStatus('money'), ['hasAlarm'] = rTable.getLuxaryStatus('alarm'),
        ['hasWeaponsRent'] = rTable.getLuxaryRentStatus('weapon'), ['hasItemsRent'] = rTable.getLuxaryRentStatus('inventory'), ['hasMoneyRent'] = rTable.getLuxaryRentStatus('money'),
        ['ownerCid'] = rTable.getOwner(), ['price'] = rTable.getPurchaseCost(), ['basePrice'] = rTable.getBasePrice(), ['name'] = rTable.getName(),
        ['bought'] = rTable.getStatus('owned'), ['forSale'] = rTable.getForSale(), ['doorStatus'] = rTable.getLock(),
        ['propertyRented'] = rTable.getStatus('rented'), ['rentor'] = rTable.getRentor(), ['forRent'] = rTable.getForRent(), ['rentPrice'] = rTable.getRentalCost(),
        ['radiusInside'] = rTable.getRadialLimit('inside'), ['radiusOutside'] = rTable.getRadialLimit('outside'), ['furnitureZ'] = rTable.getRadialLimit('furnitureZ'),
        ['totalRents'] = rTable.getRent('total'), ['amountRentsPaid'] = rTable.getRent('paid'), ['amountRentsMissed'] = rTable.getRent('missed'), ['arrears'] = rTable.getRent('arrears'), ['pot'] = rTable.getRent('pot'), ['securityDeposit'] = rTable.getRent('securityDeposit'),
        ['evicting'] = rTable.getRent('evicting'), ['evictingLeft'] = rTable.getRent('evictingLeft'), ['autoLock'] = rTable.getOptions('autolock'), ['alarm'] = rTable.getOptions('alarm'),
        ['itemStashCost'] = rTable.getInventoryCost('inventory'), ['weaponStashCost'] = rTable.getInventoryCost('weapon'), ['moneyStashCost'] = rTable.getInventoryCost('money'), ['alarmCost'] = rTable.getInventoryCost('alarm'), ['wardrobeCost'] = rTable.getInventoryCost('clothing'),
        ['furniture'] = rTable.getFurniture(), ['brokenInto'] = rTable.getBroken(), ['allowRealEstate'] = rTable.getRentRealEstate(),
    }
    --------------------
    -- Update Functions
    --------------------
    
    self.rebuildTable = function()
        Houses[self.pid] = {
            ['entrance'] = rTable.getCoords('property'),
            ['interior'] = rTable.getCoords('inside'),
            ['exit'] = rTable.getCoords('inside'),
            ['ownerMenu'] = rTable.getCoords('management'),
            ['garage'] = rTable.getCoords('garage'),
            ['weapons'] = rTable.getCoords('weapon'),
            ['items'] = rTable.getCoords('inventory'),
            ['clothing'] = rTable.getCoords('clothing'),
            ['money'] = rTable.getCoords('money'),
            ['charSpawn'] = rTable.getCoords('charSpawn'),
            ['exitEntrance'] = rTable.getCoords('backEntrance'),
            ['exitInside'] = rTable.getCoords('backInside'),
            ['storageLimit'] = rTable.getStorageLimit(),
            ['hasGarage'] = rTable.getLuxaryStatus('garage'), ['hasWeapons'] = rTable.getLuxaryStatus('weapon'), ['hasItems'] = rTable.getLuxaryStatus('inventory'), ['hasMoney'] = rTable.getLuxaryStatus('money'),
            ['hasWeaponsRent'] = rTable.getLuxaryRentStatus('weapon'), ['hasItemsRent'] = rTable.getLuxaryRentStatus('inventory'), ['hasMoneyRent'] = rTable.getLuxaryRentStatus('money'),
            ['ownerCid'] = rTable.getOwner(), ['price'] = rTable.getPurchaseCost(), ['basePrice'] = rTable.getBasePrice(), ['name'] = rTable.getName(),
            ['bought'] = rTable.getStatus('owned'), ['forSale'] = rTable.getForSale(), ['doorStatus'] = rTable.getLock(),
            ['propertyRented'] = rTable.getStatus('rented'), ['rentor'] = rTable.getRentor(), ['forRent'] = rTable.getForRent(), ['rentPrice'] = rTable.getRentalCost(),
            ['radiusInside'] = rTable.getRadialLimit('inside'), ['radiusOutside'] = rTable.getRadialLimit('outside'), ['furnitureZ'] = rTable.getRadialLimit('furnitureZ'),
            ['totalRents'] = rTable.getRent('total'), ['amountRentsPaid'] = rTable.getRent('paid'), ['amountRentsMissed'] = rTable.getRent('missed'), ['arrears'] = rTable.getRent('arrears'), ['pot'] = rTable.getRent('pot'), ['securityDeposit'] = rTable.getRent('securityDeposit'),
            ['evicting'] = rTable.getRent('evicting'), ['evictingLeft'] = rTable.getRent('evictingLeft'), ['autoLock'] = rTable.getOptions('autolock'), ['alarm'] = rTable.getOptions('alarm'),
            ['itemStashCost'] = rTable.getInventoryCost('inventory'), ['weaponStashCost'] = rTable.getInventoryCost('weapon'), ['moneyStashCost'] = rTable.getInventoryCost('money'), ['alarmCost'] = rTable.getInventoryCost('alarm'), ['wardrobeCost'] = rTable.getInventoryCost('clothing'),
            ['furniture'] = rTable.getFurniture(), ['brokenInto'] = rTable.getBroken(), ['allowRealEstate'] = rTable.getRentRealEstate(),
        }
        TriggerClientEvent('pw_properties:client:updateRent', -1, self.pid, Houses[self.pid])
    end

    rTable.setRentPrice = function(price)
        self.metaInformation['costs']['rental'] = price
        self.SaveHouse()
        Houses[self.pid].rentPrice = self.metaInformation['costs']['rental']
        TriggerClientEvent('pw_properties:client:setRentPrice', -1, self.pid, self.metaInformation['costs']['rental'])
    end

    rTable.setSellPrice = function(price, src)
        self.metaInformation['costs']['purchase'] = price
        self.SaveHouse()
        Houses[self.pid].price = self.metaInformation['costs']['purchase']
        TriggerClientEvent('pw_properties:client:setSellPrice', -1, self.pid, self.metaInformation['costs']['purchase'])

        if src ~= nil then
            TriggerClientEvent('pw_realestate:client:propertySettings', src, self.pid)
        end
    end
    
    rTable.moveMarker = function(marker, coords, h)
        local tempCoords = { ['x'] = coords.x, ['y'] = coords.y, ['z'] = coords.z, ['h'] = h}
        local encodedCoords = json.encode(tempCoords)

        if marker == "money" then
            Houses[self.pid].money = tempCoords
            self.metaInformation['locations']['money'] = tempCoords
        elseif marker == "weapons" then
            Houses[self.pid].weapons = tempCoords
            self.metaInformation['locations']['weapon'] = tempCoords
        elseif marker == "items" then
            Houses[self.pid].items = tempCoords
            self.metaInformation['locations']['inventory'] = tempCoords
        elseif marker == "garage" then
            Houses[self.pid].garage = tempCoords
            self.metaInformation['locations']['garage'] = tempCoords
            TriggerClientEvent('pw_garage:client:updatePrivGarages', -1, self.pid, tempCoords)
        elseif marker == "clothing" then
            Houses[self.pid].clothing = tempCoords
            self.metaInformation['locations']['clothing'] = tempCoords
        elseif marker == "exitInside" then
            Houses[self.pid].exitInside = tempCoords
            self.metaInformation['locations']['backInside'] = tempCoords
        elseif marker == "exitEntrance" then
            Houses[self.pid].exitEntrance = tempCoords
            self.metaInformation['locations']['backEntrance'] = tempCoords
        elseif marker == "charSpawn" then
            self.metaInformation['locations']['charSpawn'] = tempCoords
        end
        self.SaveHouse()
        if marker ~= "charSpawn" then
            TriggerClientEvent('pw_properties:client:updateMarkerPos', -1, self.pid, marker, tempCoords)
        end
        -- CLIENT EVENT HERE TO UPDATE ALL CLIENTS OF NEW COORDS ?
    end

    rTable.toggleLock = function(status)
        self.metaInformation['lockStatus'] = status
        self.SaveHouse()
        Houses[self.pid].doorStatus = self.metaInformation['lockStatus']
        TriggerClientEvent('pw_properties:client:changeLock', -1, self.pid, self.metaInformation['lockStatus'])
    end

    rTable.toggleLockPhone = function()
        self.metaInformation['lockStatus'] = not self.metaInformation['lockStatus']
        self.SaveHouse()
        Houses[self.pid].doorStatus = self.metaInformation['lockStatus']
        TriggerClientEvent('pw_properties:client:changeLock', -1, self.pid, self.metaInformation['lockStatus'])
    end

    rTable.toggleLockNoCl = function(status)
        self.metaInformation['lockStatus'] = status
        self.SaveHouse()
        Houses[self.pid].doorStatus = self.metaInformation['lockStatus']
    end

    rTable.updateStatus = function(req)
        if req == "owned" then
            self.metaInformation['houseState']['propertyOwned'] = not self.metaInformation['houseState']['propertyOwned']
            Houses[self.pid].bought = self.metaInformation['houseState']['propertyOwned']
        elseif req == "rented" then
            self.metaInformation['houseState']['propertyRented'] = not self.metaInformation['houseState']['propertyRented']
            Houses[self.pid].propertyRented = self.metaInformation['houseState']['propertyRented']
        elseif req == "forRent" then
            self.metaInformation['houseStatus']['forRent'] = not self.metaInformation['houseStatus']['forRent']
            Houses[self.pid].forRent = self.metaInformation['houseState']['forRent']
        elseif req == "forSale" then
            self.metaInformation['houseStatus']['forSale'] = not self.metaInformation['houseStatus']['forSale']
            Houses[self.pid].forSale = self.metaInformation['houseState']['forSale']
        end
        self.SaveHouse()
        
        TriggerClientEvent('pw_properties:client:updateStatus', -1, self.pid, req)
    end

    rTable.updateOwner = function(cid)
        self.metaInformation['CIDS']['owner'] = cid
        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:updateOwnerRentor', -1, self.pid, 'ownerCid', cid)
    end

    rTable.updateRentor = function(cid)
        self.metaInformation['CIDS']['rentor'] = cid
        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:updateOwnerRentor', -1, self.pid, 'rentor', cid)
    end

    rTable.toggleLuxary = function(req)
        self.metaInformation['luxuryEnabled'][req] = not self.metaInformation['luxuryEnabled'][req]
        if req == "money" then
            Houses[self.pid].hasMoney = self.metaInformation['luxuryEnabled'][req]
        elseif req == "weapon" then
            Houses[self.pid].hasWeapons = self.metaInformation['luxuryEnabled'][req]
        elseif req == "inventory" then
            Houses[self.pid].hasItems = self.metaInformation['luxuryEnabled'][req]
        elseif req == "garage" then
            Houses[self.pid].hasGarage = self.metaInformation['luxuryEnabled'][req]
        elseif req == "alarm" then
            Houses[self.pid].hasAlarm = self.metaInformation['luxuryEnabled'][req]
        end
        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:updateStashes', -1, self.pid, req)
    end

    rTable.toggleLuxaryRent = function(req)
        self.metaInformation['luxuryAvailable'][req] = not self.metaInformation['luxuryAvailable'][req]
        if req == "money" then
            Houses[self.pid].hasMoneyRent = self.metaInformation['luxuryAvailable'][req]
        elseif req == "weapon" then
            Houses[self.pid].hasWeaponsRent = self.metaInformation['luxuryAvailable'][req]
        elseif req == "inventory" then
            Houses[self.pid].hasItemsRent = self.metaInformation['luxuryAvailable'][req]
        elseif req == "garage" then
            Houses[self.pid].hasGarage = self.metaInformation['luxuryAvailable'][req]
        end
        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:updateStashesRent', -1, self.pid, req)
    end

    rTable.rentDue = function()
        rTable.updateRent('newRent')
    end

    rTable.updateRent = function(req, value)
        if req == "total" then
            if value then
                self.metaInformation.rents.total = value
            else
                self.metaInformation.rents.total = self.metaInformation.rents.total + 1
            end
            Houses[self.pid].totalRents = self.metaInformation.rents.total
        elseif req == "paid" then
            if value == 0 then
                self.metaInformation.rents.paid = 0
            elseif value ~= nil then
                self.metaInformation.rents.paid = self.metaInformation.rents.paid + value
            else
                self.metaInformation.rents.paid = self.metaInformation.rents.paid + 1
            end
            Houses[self.pid].amountRentsPaid = self.metaInformation.rents.paid
        elseif req == "missed" then
            if value == 0 then
                self.metaInformation.rents.missed = 0
            elseif value ~= nil then
                self.metaInformation.rents.missed = self.metaInformation.rents.missed + value
            else
                self.metaInformation.rents.missed = self.metaInformation.rents.missed + 1
            end
            Houses[self.pid].amountRentsMissed = self.metaInformation.rents.missed
        elseif req == "arrears" then
            if value == 0 then
                self.metaInformation.rents.arrears = 0
            elseif value ~= nil then
                self.metaInformation.rents.arrears = self.metaInformation.rents.arrears + value
            end
            Houses[self.pid].arrears = self.metaInformation.rents.arrears
        elseif req == "pot" then
            if value == 0 then
                self.metaInformation.rents.pot = 0
            elseif value ~= nil then
                self.metaInformation.rents.pot = self.metaInformation.rents.pot + value
            end
            Houses[self.pid].pot = self.metaInformation.rents.pot
        elseif req == "newRent" then
            self.metaInformation.rents.total = self.metaInformation.rents.total + 1
            Houses[self.pid].totalRents = self.metaInformation.rents.total

            self.metaInformation.rents.missed = self.metaInformation.rents.missed + 1
            Houses[self.pid].amountRentsMissed = self.metaInformation.rents.missed

            self.metaInformation.rents.arrears = self.metaInformation.rents.arrears + rTable.getRentalCost()
            Houses[self.pid].arrears = self.metaInformation.rents.arrears
        elseif req == "deposit" then
            if value == "add" then
                self.metaInformation.rents.securityDeposit = rTable.getRentalCost() * 2
                Houses[self.pid].securityDeposit = self.metaInformation.rents.securityDeposit
            elseif value == "remove" then
                self.metaInformation.rents.securityDeposit = 0
                Houses[self.pid].securityDeposit = self.metaInformation.rents.securityDeposit
            end
        elseif req == 'evicting' then
            self.metaInformation.rents.evicting = value
            Houses[self.pid].evicting = self.metaInformation.rents.evicting
        elseif req == 'evictingLeft' then
            if value then
                self.metaInformation.rents.evictingLeft = value
                Houses[self.pid].evictingLeft = self.metaInformation.rents.evictingLeft
            else
                self.metaInformation.rents.evictingLeft = self.metaInformation.rents.evictingLeft - 1
                Houses[self.pid].evictingLeft = self.metaInformation.rents.evictingLeft
            end
        end

        self.SaveHouse()
        self.rebuildTable()
    end

    rTable.setOptions = function(option, value, src, lockpick)
        if option == 'autolock' then
            self.metaInformation['options']['autolock'] = value
            Houses[self.pid].autoLock = self.metaInformation['options']['autolock']
        elseif option == 'alarm' then
            self.metaInformation['options']['alarm'] = value
            Houses[self.pid].alarm = self.metaInformation['options']['alarm']
        end

        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:updateOptions', -1, self.pid, option, self.metaInformation['options'][option], src, lockpick)
    end

    rTable.rentRealEstate = function(state)
        self.metaInformation['allowRealEstate'] = state
        Houses[self.pid]['allowRealEstate'] = state

        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:toggleRentRealEstate', -1, self.pid, state)
    end

    rTable.addMultiplePendingFurniture = function(data, method, cid)
        local finalMeta = { ['left'] = Config.DeliveryMethods[method]['delay'], ['method'] = method, ['complete'] = false, ['order'] = {} }
        local sendMeta
        for i = 1, #data do
            if data[i].qty > 1 then
                for j = 1, data[i].qty do
                    sendMeta = {['prop'] = data[i].prop,
                                ['name'] = GetFurnitureLabel(data[i].prop),
                                ['price'] = GetPropPrice(data[i].prop),
                                ['buyer'] = cid,
                                ['delivered'] = false,
                                ['position'] = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 },
                                ['placed'] = false,
                                ['qty'] = 1
                                }
                    while sendMeta.name == nil do Wait(50); end
                    table.insert(finalMeta.order, sendMeta)
                end
            else
                sendMeta = {['prop'] = data[i].prop,
                            ['name'] = GetFurnitureLabel(data[i].prop),
                            ['price'] = GetPropPrice(data[i].prop),
                            ['buyer'] = cid,
                            ['delivered'] = false,
                            ['position'] = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 },
                            ['placed'] = false,
                            ['qty'] = 1
                            }
                while sendMeta.name == nil do Wait(50); end
                table.insert(finalMeta.order, sendMeta)
            end
        end
        MySQL.Async.insert("INSERT INTO `furniture_pending` (`house`,`metainformation`) VALUES (@house, @sendMeta)", { ['@house'] = self.pid, ['@sendMeta'] = json.encode(finalMeta) }, function()
            
        end)

    end

    rTable.addPendingFurniture = function(prop, method, cost, cid)
        local sendMeta = {  ['prop'] = prop,
                            ['name'] = GetFurnitureLabel(prop),
                            ['method'] = method,
                            ['price'] = cost,
                            ['buyer'] = cid,
                            ['left'] = Config.DeliveryMethods[method]['delay'],
                            ['delivered'] = false,
                            ['position'] = { ['x'] = 0.0, ['y'] = 0.0, ['z'] = 0.0, ['h'] = 0.0 },
                            ['placed'] = false
                        }
        
        while sendMeta.name == nil do Wait(50); end
        
        MySQL.Async.insert("INSERT INTO `furniture_pending` (`house`,`metainformation`) VALUES (@house, @sendMeta)", { ['@house'] = self.pid, ['@sendMeta'] = json.encode(sendMeta) }, function()
            
        end)
    end

    rTable.removeFurniture = function(fid)
        table.remove(self.furniture, fid)
        Houses[self.pid].furniture = self.furniture
        
        self.SaveFurniture()
        
        TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture)
    end

    rTable.addFurniture = function(furniture)
        table.insert(self.furniture, furniture)
        Houses[self.pid].furniture = self.furniture
        
        self.SaveFurniture()

        TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture)
    end


    rTable.addMultiFurniture = function(furniture)
        if self.furniture == nil then self.furniture = {}; end
        if furniture ~= nil then
            if #furniture > 0 then
                for i = 1, #furniture, 1 do
                    furniture[i].delivered = true
                    if furniture[i].qty > 1 then
                        for j = 1, furniture[i].qty, 1 do
                            table.insert(self.furniture, furniture[i])
                        end
                    else
                        table.insert(self.furniture, furniture[i])
                    end
                end
            end

            Houses[self.pid].furniture = self.furniture
            self.SaveFurniture()

            TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture)
        end
    end

    rTable.addMultipleFurniture = function(furniture)
        if self.furniture == nil then self.furniture = {}; end
        if furniture ~= nil then
            for k,v in pairs(furniture) do
                table.insert(self.furniture, v)
            end
        
            Houses[self.pid].furniture = self.furniture
            self.SaveFurniture()

            TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture)
        end
    end

    rTable.updateFurniture = function(id, req, value)
        if self.furniture[id] ~= nil then
            if req == 'position' and not self.furniture[id].placed then self.furniture[id].placed = true; end
            
            self.furniture[id][req] = value
            Houses[self.pid].furniture = self.furniture
            
            self.SaveFurniture()

            if req ~= 'name' then
                TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture, true)
            else
                TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture, false)
            end
        end
    end

    rTable.updateFurnitureAfterEviction = function(furniture, ownedFurniture, owner)
        self.furniture = furniture
        Houses[self.pid].furniture = self.furniture

        self.SaveFurniture()
        TriggerClientEvent('pw_properties:client:addedFurniture', -1, self.pid, self.furniture, true)

        MySQL.Async.fetchScalar("SELECT `furniture` FROM `furniture_hold` WHERE `cid` = @cid", {['@cid'] = owner}, function(res)
            local meta = ownedFurniture
            if res then
                meta = json.decode(res)
                table.insert(meta, ownedFurniture)
                
                MySQL.Async.execute("UPDATE `furniture_hold` SET `furniture` = @meta WHERE `cid` = @cid", {['@cid'] = owner, ['@meta'] = json.encode(meta) })
            else
                MySQL.Async.execute("INSERT INTO `furniture_hold` (`cid`,`furniture`) VALUES (@cid, @meta)", {['@cid'] = owner, ['@meta'] = json.encode(meta) })
            end
        end)        
    end

    rTable.toggleBroken = function(state)
        self.metaInformation.brokenInto = state
        Houses[self.pid].brokenInto = self.metaInformation.brokenInto
        self.SaveHouse()
        TriggerClientEvent('pw_properties:client:updateBroken', -1, self.pid, state)
    end
    -----------------------------
    -- INVENTORIES MANAGEMENTS  -
    -----------------------------

    self.getCurrentLimits = function(invtype)
        return
    end

    rTable.GetInventory = function(invtype)
        return
    end

    rTable.PutItem = function(source, invtype, itemName, amount, public, private)
        return
    end

    rTable.TakeItem = function(id, amount) 
        return
    end

    rTable.AddMoney = function(source, m)
        local _src = source
        local success = false
        local currentCashAvaliable = exports.pw_base:Source(_src):Cash().getCash()
        if type(m) == "number" then
            local moneyLimit = self.storageLimit['money']
            local addition = self.storedCash + m

            if (addition <= moneyLimit) and (m <= currentCashAvaliable) then
                local playerRemoved = exports.pw_base:Source(_src):Cash().Remove(m)
                if playerRemoved then
                    self.storedCash = addition
                    MySQL.Async.execute("UPDATE `cash_stashes` SET `stash_amount` = @newAmount WHERE `stash_identifier` = @pid AND `stash_type` = 'Property'", {['@newAmount'] = self.storedCash, ['@pid'] = self.pid})
                    success = true
                end
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Your attempting to store too much money, Properties can only store a maximum of $"..moneyLimit, length = 5000})
            end
        end
        return success
    end

    rTable.RemoveMoney = function(source, m)
        local _src = source
        local success = false
        if type(m) == "number" then
            if self.storedCash >= m then
                local playerAdded = exports.pw_base:Source(_src):Cash().Add(m)
                if playerAdded then
                    self.storedCash = self.storedCash - m
                    MySQL.Async.execute("UPDATE `cash_stashes` SET `stash_amount` = @newAmount WHERE `stash_identifier` = @pid AND `stash_type` = 'Property'", {['@newAmount'] = self.storedCash, ['@pid'] = self.pid})
                    success = true
                end
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You do not have enough cash stored, you only have $"..self.storedCash.." avaliable.", length = 5000})
            end
        end
        return success
    end

    return rTable

end

function GetFurnitureLabel(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs (Config.Furniture[k].props) do
            if b.prop == prop then
                return b.label
            end
        end
    end
    return "Piece of Furniture"
end

function GetPropPrice(prop)
    for k,v in pairs(Config.Furniture) do
        for j,b in pairs(Config.Furniture[k].props) do
            if b.prop == prop then
                return b.price
            end
        end
    end
    return false
end
