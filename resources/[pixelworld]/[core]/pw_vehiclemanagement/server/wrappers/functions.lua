PW = nil
vehicles = {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

function registerVehicle(vid)
    if vid == nil then return; end

    if vid ~= nil then
        local self = {}
        local rTable = {}
        self.vid = vid

        self.query = MySQL.Sync.fetchAll("SELECT * FROM `owned_vehicles` WHERE `vehicle_id` = @vid", {['@vid'] = self.vid})[1]
        if self.query == nil then return; end

        if self.query ~= nil then
            self.vehicleInformation = json.decode(self.query.vehicle_information)
            self.metaInformation = json.decode(self.query.vehicle_metainformation) or {}
            self.insurance = json.decode(self.query.insurance) or {}

                if self.metaInformation.defaultSettings == nil then
                    self.metaInformation.defaultSettings = {}
                    self.metaInformation.defaultSettings.lockpicked = false
                    self.metaInformation.defaultSettings.searched = false
                    self.metaInformation.defaultSettings.alarm = false
                    self.metaInformation.defaultSettings.hotwired = false
                    self.metaInformation.defaultSettings.enginestate = false
                    self.metaInformation.defaultSettings.successbroken = false
                    self.metaInformation.defaultSettings.doorLocked = true
                end

                if self.insurance == nil then
                    self.insurance.plan = 0
                    self.insurance.tows = 0
                    self.insurance.cost = 0
                    self.insurance.fuel = 0
                    self.insurance.insured = false
                    self.insurance.cooldown = false
                end
        end

        -- Vehicle Functions

        rTable.getOwner = function()
            return self.query.owner
        end

        rTable.getEngineState = function()
            return self.metaInformation.defaultSettings.enginestate
        end

        rTable.getStolenState = function()
            return self.metaInformation.defaultSettings.successbroken
        end

        rTable.getDoorState = function()
            return self.metaInformation.defaultSettings.doorLocked
        end

        rTable.getLockpickState = function()
            return self.metaInformation.defaultSettings.lockpicked
        end

        rTable.getHotwireState = function()
            return self.metaInformation.defaultSettings.hotwired
        end

        rTable.getSearchState = function()
            return self.metaInformation.defaultSettings.searched
        end

        rTable.getAlarmState = function()
            return self.metaInformation.defaultSettings.alarm
        end

        rTable.getOriginalVin = function()
            return self.query.vin
        end

        rTable.getOriginalPlate = function()
            return self.query.plate
        end

        rTable.getCurrentPlate = function()
            return self.vehicleInformation.plate
        end

        rTable.getVehicleProperties = function()
            return self.vehicleInformation
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

        -- END OF RETREIVAL OF INFORMATION SETTINGS

        rTable.setVehicleProperties = function(props)
            self.vehicleInformation = props
            MySQL.Sync.execute("UPDATE `owned_vehicles` SET `vehicle_information` = @meta WHERE `vehicle_id` = @vid", {['@vid'] = self.vid, ['@meta'] = json.encode(self.vehicleInformation)})
        end

        rTable.UpdateInsurance = function(k, v)
            if self.insurance[k] then
                self.insurance[k] = v
                MySQL.Sync.execute("UPDATE `owned_vehicles` SET `insurance` = @meta WHERE `vehicle_id` = @vid", {['@vid'] = self.vid, ['@meta'] = json.encode(self.insurance)})
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
            MySQL.Sync.execute("UPDATE `owned_vehicles` SET `insurance` = @meta WHERE `vehicle_id` = @vid", {['@vid'] = self.vid, ['@meta'] = json.encode(self.insurance)})
        end

        return rTable
    end
end

function createVeh(cid, props, othermeta, use, src)
    if cid == nil then return; end
    if props == nil then return; end

    if cid ~= nil and props ~= nil then
        local self = {}
        self.owner = cid
        self.plate = props.plate
        self.vin = string.upper(PW.RandomString(17))
        self.insurance = {}
        self.garage = {}
        self.metaInformation = othermeta or {}
        self.vehicleInformation = props

        self.garage.current = 0
        self.garage.type = "None"
        self.garage.location = 0

        self.use = use or "Personal"

        self.insurance.plan = 0
        self.insurance.tows = 0
        self.insurance.cost = 0
        self.insurance.fuel = 0
        self.insurance.insured = false
        self.insurance.cooldown = false
        
        self.metaInformation.defaultSettings = {}
        self.metaInformation.defaultSettings.lockpicked = false
        self.metaInformation.defaultSettings.searched = false
        self.metaInformation.defaultSettings.alarm = false
        self.metaInformation.defaultSettings.hotwired = false
        self.metaInformation.defaultSettings.enginestate = false
        self.metaInformation.defaultSettings.successbroken = false
        self.metaInformation.defaultSettings.doorLocked = true

        self.inserted = MySQL.Sync.insert("INSERT INTO `owned_vehicles` (`vin`, `plate`,`owner`,`vehicle_information`,`vehicle_metainformation`,`stored_garage`,`stored_garagetype`,`stored_garageid`,`use`,`insurance`) VALUES (@vin, @plate, @owner, @vinfo, @vmeta, @garage, @gtype, @gid, @use, @insur)", {
            ['@vin'] = self.vin,
            ['@plate'] = self.plate,
            ['@owner'] = self.owner,
            ['@vinfo'] = json.encode(self.vehicleInformation),
            ['@vmeta'] = json.encode(self.metaInformation),
            ['@garage'] = self.garage.current,
            ['@gtype'] = self.garage.type,
            ['@gid'] = self.garage.location,
            ['@use'] = self.use,
            ['@insur'] = json.encode(self.insurance)
        })

        if self.inserted > 0 then
            vehicles[self.inserted] = registerVehicle(self.inserted)
        end

    end
end

exports('createVeh', function(...)
    createVeh(...)
end)