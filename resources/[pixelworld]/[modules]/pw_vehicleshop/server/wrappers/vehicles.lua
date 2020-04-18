PW = nil

vehicles = {}
registeredVehicles = {}

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)

function loadVehicle(vin, temp)

    local self = {}
    local temporarilyVehicle = temp or nil
    self.vin = vin

    if temporarilyVehicle == nil then
        self.ownedVehicle = true
        local processed = false
        MySQL.Async.fetchAll("SELECT * FROM `owned_vehicles` WHERE `vin` = @vin", { ['@vin'] = self.vin }, function(query)
            if query[1] ~= nil then
                self.vehicleInformation = json.decode(query[1].vehicle_information)
                if query[1].vehicle_metainformation ~= nil then
                    self.metainformation = json.decode(query[1].vehicle_metainformation)

                    if self.metainformation.defaultSettings == nil then
                        self.metainformation.defaultSettings = {}
                        self.metainformation.defaultSettings.lockpicked = false
                        self.metainformation.defaultSettings.searched = false
                        self.metainformation.defaultSettings.alarm = false
                        self.metainformation.defaultSettings.hotwired = false
                        self.metainformation.defaultSettings.enginestate = false
                        self.metainformation.defaultSettings.successbroken = false
                        self.metainformation.defaultSettings.doorLocked = true

                    end
                    -- Default Global Settings
                else
                    self.metainformation = {}
                end

                if query[1].insurance ~= nil then
                    self.insurance = json.decode(query[1].insurance)
                else
                    self.insurance = {}
                    self.insurance.plan = 0
                    self.insurance.tows = 0
                    self.insurance.cost = 0
                    self.insurance.fuel = 0
                    self.insurance.insured = false
                    self.insurance.cooldown = false
                end
            end
            processed = true
        end)
        repeat Wait(0) until processed == true
    else
        self.ownedVehicle = false
        self.metainformation = {}
        self.metainformation.owner = "Unregistered"
        self.metainformation.currentVin = self.vin
        self.metainformation.defaultSettings = {}
        self.metainformation.defaultSettings.lockpicked = false
        self.metainformation.defaultSettings.searched = false
        self.metainformation.defaultSettings.alarm = false
        self.metainformation.defaultSettings.hotwired = false
        self.metainformation.defaultSettings.enginestate = false
        self.metainformation.defaultSettings.successbroken = false
        self.metainformation.defaultSettings.doorLocked = true
        self.vehicleInformation = temporarilyVehicle.vehProps
        self.metainformation.fuelLevel = math.random(30,60)
    end

    self.saveVehicle = function()
        if temporarilyVehicle == nil then
            MySQL.Async.execute("UPDATE `owned_vehicles` SET `vehicle_information` = @vehi, `vehicle_metainformation` = @vehm, `insurance` = @vehins WHERE `vin` = @vin", {['@vehi'] = json.encode(self.vehicleInformation), ['@vehm'] = json.encode(self.metainformation), ['@vehins'] = json.encode(self.insurance), ['@vin'] = self.vin } )
        end
    end

    while self.vehicleInformation == nil do Wait(0) end

    local rTable = {}

    rTable.GetOwner = function()
        if self.metainformation.owner then
            return self.metainformation.owner
        else
            return nil
        end
    end

    rTable.policeRecovery = function()
        self.metainformation.defaultSettings.lockpicked = false
        self.metainformation.defaultSettings.searched = false
        self.metainformation.defaultSettings.alarm = false
        self.metainformation.defaultSettings.hotwired = false
        self.metainformation.defaultSettings.enginestate = false
        self.metainformation.defaultSettings.successbroken = false
        self.metainformation.defaultSettings.doorLocked = true
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.getEngineState = function()
        return self.metainformation.defaultSettings.enginestate
    end

    rTable.getStolenSuccess = function()
        return self.metainformation.defaultSettings.successbroken
    end

    rTable.getDoorState = function()
        return self.metainformation.defaultSettings.doorLocked
    end

    rTable.updateDoorState = function(toggle)
        self.metainformation.defaultSettings.doorLocked = toggle
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.updateStolenSuccess = function(toggle)
        self.metainformation.defaultSettings.successbroken = toggle
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.updateEngineState = function(tog)
        self.metainformation.defaultSettings.enginestate = tog
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.getVehicleStatus = function()
        return self.ownedVehicle
    end

    rTable.getLockpickStatus = function()
        return self.metainformation.defaultSettings.lockpicked
    end

    rTable.getFuelLevel = function()
        return self.metainformation.fuelLevel
    end

    rTable.setFuelLevel = function(amt)
        if type(amt) == "number" then
            self.metainformation.fuelLevel = amt
        end
    end

    rTable.toggleLockpick = function()
        self.metainformation.defaultSettings.lockpicked = not self.metainformation.defaultSettings.lockpicked
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.getHotwireStatus = function()
        return self.metainformation.defaultSettings.hotwired
    end

    rTable.toggleHotwireStatus = function()
        self.metainformation.defaultSettings.hotwired = not self.metainformation.defaultSettings.hotwired
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.getSearchedStatus = function()
        return self.metainformation.defaultSettings.searched
    end

    rTable.toggleSearched = function()
        self.metainformation.defaultSettings.searched = not self.metainformation.defaultSettings.searched
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.getAlarmStatus = function()
        return self.metainformation.defaultSettings.alarm
    end

    rTable.toggleAlarm = function()
        self.metainformation.defaultSettings.alarm = not self.metainformation.defaultSettings.alarm
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.updateSetting = function(key, value)
        if self.metainformation.defaultSettings[key] then
            self.metainformation.defaultSettings[key] = value
        else
            self.metainformation.defaultSettings[key] = value
        end

        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.getOwnedStatus = function()
        if temporarilyVehicle == nil then
            return true
        else
            return false
        end
    end

    rTable.retreiveSetting = function(k)
        if self.metainformation.defaultSettings[k] then
            return self.metainformation.defaultSettings[k]
        else
            return nil
        end
    end

    rTable.getCurrentVin = function()
        return self.metainformation.currentVin
    end

    rTable.getOriginalVin = function()
        return self.vin
    end

    rTable.getCurrentPlate = function()
        return self.vehicleInformation.plate
    end
    --[[
        -- Come back to this after some brainstorming.

    rTable.placeFakePlate = function()
        local randomPlate = string.upper(PW.RandomString(8))
        self.vehicleInformation.plate = randomPlate
        self.saveVehicle()
        return randomPlate
    end

    rTable.removeFakePlate = function()
        self.vehicleInformation.plate = self.plate
        self.saveVehicle()
    end
    ]]
    rTable.adjustVin = function(newVin)
        local success = false
        if newVin ~= nil then
            self.metainformation.currentVin = newVin
            success = true
            if temporarilyVehicle == nil then
                self.saveVehicle()
            end
        else
            self.metainformation.currentVin = 'SCRATCHED'
            success = true
            if temporarilyVehicle == nil then
                self.saveVehicle()
            end
        end

        return success
    end

    rTable.GetPlate = function()
        return self.vehicleInformation.plate
    end

    rTable.GetVehicleProperties = function()
        return self.vehicleInformation
    end

    rTable.SetVehicleProperties = function(props)
        self.vehicleInformation = props
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    rTable.UpdateMeta = function(k, v)
        if self.metainformation[k] then
            self.metainformation[k] = v
            if temporarilyVehicle == nil then
                self.saveVehicle()
            end
        end
    end

    rTable.GetMeta = function(k)
        if self.metainformation[k] then
            return self.metainformation[k]
        elseif k == 'business' then
            return false
        end
    end

    rTable.UpdateInsurance = function(k, v)
        if self.insurance[k] ~= nil then

            self.insurance[k] = v
            if temporarilyVehicle == nil then
                self.saveVehicle()
            end
        end
    end

    rTable.GetInsurance = function(k)
        if self.insurance ~= nil then
            if k ~= nil then
                if self.insurance[k] then
                    return self.insurance[k]
                end
            else
                return self.insurance
            end
        end
    end

    rTable.ResetInsurance = function()
        self.insurance = {}
        self.insurance.plan = 0
        self.insurance.tows = 0
        self.insurance.cost = 0
        self.insurance.fuel = 0
        self.insurance.insured = false
        self.insurance.cooldown = false
        
        if temporarilyVehicle == nil then
            self.saveVehicle()
        end
    end

    return rTable
end


-- REGISTERING A NEW VEHICLE



function registerVehicle(vehicleproperties, vehiclemetainformation, use, src)

    --[[
        vehicleproperties would be the entire table of pw.game.getvehicleproperties function, simply pass this function into here as is,
        vehiclemetainformation will accept a table, that is defined by yourself this will be the meta information regarding the vehicle, like owner, etc.. and the DEFAULT 
        values should be passed they can later be amended in the above function which manages each vehicle.
            This will also automatically register the vehicle at the end of the creation function.
    ]]

    local self = {}

    if vehicleproperties ~= nil then
        self.vehicleInformation = vehicleproperties
        self.plate = self.vehicleInformation.plate
    else
        return false
    end

    local generatedVin = string.upper(PW.RandomString(17))

    if vehiclemetainformation ~= nil then
        self.vehicle_metainformation = vehiclemetainformation
        self.vehicle_metainformation.currentVin = generatedVin
        self.vehicle_metainformation.currentPlate = self.plate
        self.vehicle_metainformation.fuelLevel = 100
        if self.vehicle_metainformation.defaultSettings == nil then
            self.vehicle_metainformation.defaultSettings = {}
            self.vehicle_metainformation.defaultSettings.lockpicked = false
            self.vehicle_metainformation.defaultSettings.searched = false
            self.vehicle_metainformation.defaultSettings.alarm = false
            self.vehicle_metainformation.defaultSettings.hotwired = false
            self.vehicle_metainformation.defaultSettings.enginestate = false
            self.vehicle_metainformation.defaultSettings.successbroken = false
            self.vehicle_metainformation.defaultSettings.doorLocked = true
        end
        if self.vehicle_metainformation.owner then
            MySQL.Async.insert("INSERT INTO `character_keys` (`identifier`, `owner_id`, `holder_id`, `given`, `stolen`, `job`, `type`) VALUES (@ident, @owner, @owner, 0, @stolen, @job, @type)", {
                ['@ident'] = generatedVin,
                ['@owner'] = exports.pw_base:Source(src):Character():getCID(),
                ['@stolen'] = false,
                ['@job'] = (use == 'Personal' and false or true),
                ['@type'] = 'Vehicle'
            }, function(insert)
                if insert > 0 then
                    success = true
                    processed = true
                else
                    success = false
                    processed = true
                end
            end)
            repeat Wait(0) until processed == true
        end
    else
        self.vehicle_metainformation = {}
        self.vehicle_metainformation.currentVin = generatedVin
        self.vehicle_metainformation.currentPlate = self.plate
        self.vehicle_metainformation.fuelLevel = 100
        self.vehicle_metainformation.defaultSettings = { ['lockpicked'] = false, ['searched'] = false, ['alarm'] = false, ['hotwired'] = false, ['enginestate'] = false, ['successbroken'] = false, ['doorLocked'] = true }
    end

    self.insurance = {}
    self.insurance.plan = 0
    self.insurance.tows = 0
    self.insurance.cost = 0
    self.insurance.fuel = 0
    self.insurance.insured = false
    self.insurance.cooldown = false

    local processed = false
    MySQL.Async.insert("INSERT INTO `owned_vehicles` (`vin`, `plate`, `vehicle_information`, `vehicle_metainformation`, `use`, `insurance`) VALUES (@vin, @plate, @info, @meta, @use, @insurance)", {['@vin'] = generatedVin, ['@plate'] = self.plate, ['@info'] = json.encode(self.vehicleInformation), ['@meta'] = json.encode(self.vehicle_metainformation), ['@use'] = (use ~= 'Personal' and 'Business' or 'Personal'), ['@insurance'] = json.encode(self.insurance) }, function()
        MySQL.Async.execute('UPDATE `avaliable_vehicles` SET `sold` = `sold` + 1 WHERE `model` = @model', {['@model'] = self.vehicle_metainformation.model}, function()
            MySQL.Async.insert("INSERT INTO `vehicles_sold` (`plate`, `model`, `buyer`, `seller`, `price`, `date`) VALUES (@plate, @model, @buyer, @seller, @price, @date)", {['@plate'] = self.plate, ['@model'] = self.vehicle_metainformation.model, ['@buyer'] = self.vehicle_metainformation.owner, ['@seller'] = self.vehicle_metainformation.soldBy, ['@price'] = self.vehicle_metainformation.price, ['@date'] = self.vehicle_metainformation.purchaseDate}, function()
                registeredVehicles[generatedVin] = loadVehicle(generatedVin)        
                processed = true
            end)
        end)
    end)
    repeat Wait(0) until processed == true
    return true
end

exports('registerVehicle', function(vehicleproperties, vehiclemetainformation, use, src)
    registerVehicle(vehicleproperties, vehiclemetainformation, use, src)
end)

function createTemporaryVehicle(vehProps)
    local generatedVin = string.upper(PW.RandomString(17))
    registeredVehicles[generatedVin] = loadVehicle(generatedVin, {vehProps = vehProps})   
    return generatedVin
end

exports('createTempVehicle', function(vehProps)
    createTemporaryVehicle(vehProps)
end)