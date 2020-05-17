function generatePet(petid)
    local self = {}

    self.petid = petid
    self.pedIdent = 0
    self.source = 0

    self.savePet = function()
        MySQL.Sync.execute("UPDATE `character_pets` SET `pet_meta` = @json WHERE `character_id` = @cid AND `record_id` = @pid", {['@json'] = json.encode(self.meta), ['@cid'] = self.owner, ['@pid'] = self.petid})
    end

    local petSQL = MySQL.Sync.fetchAll("SELECT * FROM `character_pets` WHERE `record_id` = @pid", { ['@pid'] = self.petid, ['@cid'] = self.owner })

    if petSQL[1] ~= nil then
        self.owner = petSQL[1].character_id

        if petSQL[1].pet_name ~= nil then
            self.name = petSQL[1].pet_name
        else
            self.name = "Unnamed"
        end

        self.hash = petSQL[1].pet_hash

        if petSQL[1].pet_meta ~= nil then
            self.meta = json.decode(petSQL[1].pet_meta)
        else
            self.meta = {}
            self.meta['needs'] = { ['hunger'] = 1000000, ['thirst'] = 1000000, ['excercise'] = 1000000 }
            self.meta['health'] = 200
            self.meta['chip'] = false
            -- Save the Default Meta information to the database so its easily loaded instead next load.
            self.savePet()
        end
    end

    local rTable = {}

    rTable.getPed = function()
        return self.pedIdent
    end

    -- Retreival Functions
    rTable.getName = function()
        return self.name
    end

    rTable.getOwnerSource = function()
        return self.source
    end

    rTable.getOwner = function()
        return self.owner
    end

    rTable.petIdent = function()
        return self.petid
    end

    rTable.getHash = function()
        return self.hash
    end

    rTable.getAllMeta = function()
        return self.meta
    end

    rTable.specificMeta = function(key)
        if self.meta[key] then
            return self.meta[key]
        else
            return nil
        end
    end

    rTable.setMeta = function(key, value)
        if not self.meta[key] then
            self.meta[key] = value
        end
    end

    rTable.updateMeta = function(key, value)
        if self.meta[key] then
            self.meta[key] = value
        end
    end

    rTable.getNeeds = function(req)
        if self.meta.needs then
            if self.meta.needs[req] then
                return self.meta.needs[req]
            else
                return 0
            end
        else
            return nil
        end
    end

    rTable.getChip = function()
        return self.meta.chip
    end

    --- UPDATE FUNCTIONS 

    rTable.setName = function(name, source)
        if name ~= nil then
            self.name = name
            self.source = source
            MySQL.Sync.execute("UPDATE `character_pets` SET `pet_name` = @name WHERE `record_id` = @pid AND `character_id` = @cid", { ['@name'] = self.name, ['@pid'] = self.petid, ['@cid'] = self.owner })
            TriggerClientEvent('pw_pets:client:updateName', self.source, self.petid, self.name)
            TriggerClientEvent('pw:notification:SendAlert', self.source, {type = 'inform', text = 'You set your pet\'s name to '..self.name})
        end
    end

    rTable.updatePed = function(pid, source)
        if pid then
            self.pedIdent = pid
            self.source = source
        end
    end

    rTable.updateHealth = function(amt)
        if type(amt) == "number" then
            self.meta['health'] = amt
            self.savePet()
        end
    end

    rTable.performNeedsAdjustment = function()
        if self.meta['needs'] then
            if self.meta['needs'].hunger - Config.PetTickRates.change.hunger < 0 then
                self.meta['needs'].hunger = 0
            else
                self.meta['needs'].hunger = self.meta['needs'].hunger - Config.PetTickRates.change.hunger
            end

            if self.meta['needs'].thirst - Config.PetTickRates.change.thirst < 0 then
                self.meta['needs'].thirst = 0
            else
                self.meta['needs'].thirst = self.meta['needs'].thirst - Config.PetTickRates.change.thirst
            end

            if self.meta['needs'].excercise - Config.PetTickRates.change.excercise < 0 then
                self.meta['needs'].excercise = 0
            else
                self.meta['needs'].excercise = self.meta['needs'].excercise - Config.PetTickRates.change.excercise
            end
            if self.source ~= 0 then
                TriggerClientEvent('pw_pets:client:updateNeeds', self.source, self.petid, self.meta['needs'])
            end
            self.savePet()
        end
    end

    rTable.addNeed = function(need, amount)
        if need and type(amount) == "number" then
            if self.meta['needs'][need] then
                if self.meta['needs'][need] + amount > Config.PetTickRates.maxValue[need] then
                    self.meta['needs'][need] = Config.PetTickRates.maxValue[need]
                else
                    self.meta['needs'][need] = self.meta['needs'][need] + amount
                end
            end
            TriggerClientEvent('pw_pets:client:updateNeeds', self.source, self.petid, self.meta['needs'])
        end
    end

    rTable.addChip = function(source)
        self.source = source
        
        if not self.meta.chip then
            self.meta.chip = true
            self.savePet()
            TriggerClientEvent('pw_pets:client:updateChip', self.source, self.petid, true)
        end
    end

    return rTable
end