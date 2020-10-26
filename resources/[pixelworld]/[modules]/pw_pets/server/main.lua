registeredPets = {}
PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `character_pets`", {}, function(petLoad)
        if petLoad[1] ~= nil then
            for i = 1, #petLoad do
                local petIdent = tonumber(petLoad[i].record_id)
                registeredPets[petIdent] = generatePet(petIdent)
            end
            print(' ^1[SynCity Pets] ^3- We have registered ^6'..#petLoad..' ^3pets in the system.^7')
        end
    end)
end)

--[[

    ALL PETS ARE REGISTERED UNDER THE REGISTEREDPETS TABLE, REGARDLESS IF THERE ACTIVE OR NOT, ALL FUNCTIONS ARE ASSIGNED LIKE OTHER FUNCTIONS IN OTHER RESOURCES
    FOR EXAMPLE,
    registeredPets[PETID].getName(), will retreive the name from the database,
    registeredPets[PETID].getPed(), will return the PedID of the pet, this can be set also by doing registeredPets[PETID].updatePed(PEDNUMBER)

    within the function programming a local internal save function is assigned for each pet, there is meta information assigned to the pet on the self.meta variable,
        This meta is saved by running the 'self.savePet()' function after a edit,

    The needs of the pet will only adjust if the ped id is set, for example, needs will not adjust on the pet if the pedid is set to 0 or nil, we will assume if this is the case the pet
    has been sent "away" by the owner, needs for the pet reduce on a 60 second basis for all pets that are considered "active" so when a player send the pet away (as in its no longer needed)
    update the pets Ped back to 0, by default the database will load with the ped id as 0, and this ped id is also not stored in the database, but is cached within the main function,

]]

function adjustPetNeeds()
    for k, v in pairs(registeredPets) do
        local pet = v
        if pet.getPed() ~= nil and pet.getPed() ~= 0 then
            -- Pet must be spawned as the Ped ID is not nil or 0
            pet.performNeedsAdjustment()
        end
    end
    SetTimeout(60000, function() adjustPetNeeds() end)
end

SetTimeout(60000, function() adjustPetNeeds() end)

RegisterServerEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(src)
    local _src = src or source
    local _char = exports.pw_core:getCharacter(_src)
    MySQL.Async.fetchAll('SELECT * FROM `character_pets` WHERE `character_id` = @cid', {['@cid'] = _char.getCID()}, function(result)
        if result then
            local tempTable = {}

            for i = 1, #result do
                tempTable[i] = {
                    ['id'] = result[i].record_id, 
                    ['hash'] = result[i].pet_hash, 
                    ['name'] = result[i].pet_name,
                    ['color'] = result[i].pet_color,
                    ['ped'] = 0, 
                    ['needs'] = registeredPets[result[i].record_id].specificMeta('needs'), 
                    ['health'] = registeredPets[result[i].record_id].specificMeta('health'), 
                    ['chip'] = registeredPets[result[i].record_id].getChip(),
                }
            end

            TriggerClientEvent('pw_pets:client:getPets', _src, tempTable)
        end
    end)
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == 'dogbowl' or data.item == 'cheapdogfood' or data.item == 'premiumdogfood' or data.item == 'dogtracker' or data.item == 'dogcollar' then
        TriggerClientEvent('pw_pets:useItem', _src, data)
    end
end)

RegisterServerEvent('pw_pets:server:addChip')
AddEventHandler('pw_pets:server:addChip', function(id)
    local _src = source
    registeredPets[id].addChip(_src)
end)

RegisterServerEvent('pw_pets:server:updateHealth')
AddEventHandler('pw_pets:server:updateHealth', function(id, health)
    if registeredPets[id] then
        registeredPets[id].updateHealth(health)
    end
end)

RegisterServerEvent('pw_pets:server:returnEmptyBowl')
AddEventHandler('pw_pets:server:returnEmptyBowl', function()
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Inventory():Add().Default(1, "dogbowl", 1, {}, {}, function(item) end)
end)

RegisterServerEvent('pw_pets:server:useItem')
AddEventHandler('pw_pets:server:useItem', function(id, data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local returnItem, takeItem, removeItem = {}, {}, false
    if data.item == "dogbowl" then
        if registeredPets[id].getNeeds('thirst') < Config.PetTickRates.maxValue.thirst then
            registeredPets[id].addNeed('thirst', Config.Needs['water'].addNeed)
            table.insert(returnItem, {['name'] = 'plastic', ['qty'] = 1 })
            table.insert(takeItem, {['name'] = 'water', ['qty'] = 1})
            removeItem = true
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = registeredPets[id].getName() .. '\'s thirst level is already at the maximum', length = 4000})
        end
    else -- change this else if there are more usable items for pets in the future that are not hunger boosts
        if registeredPets[id].getNeeds('hunger') < Config.PetTickRates.maxValue.hunger then
            registeredPets[id].addNeed('hunger', Config.Needs[data.item].addNeed)
            removeItem = true
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'inform', text = registeredPets[id].getName() .. '\'s hunger level is already at the maximum', length = 4000})
        end
    end

    if takeItem[1] ~= nil then
        _char:Inventory():Remove().ByName(takeItem[1].name, takeItem[1].qty, function(done) end)
    end

    if removeItem then
        PW.Print(data)
        _char:Inventory():Remove().Default(data.record_id, 1, function(done) end)
    end

    if returnItem[1] ~= nil then
        _char:Inventory():Add().Default(1, returnItem[1].name, returnItem[1].qty, {}, {}, function(item) end)
    end
end)

RegisterServerEvent('pw_pets:server:removeThis')
AddEventHandler('pw_pets:server:removeThis', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Inventory():Remove().Default(data.record_id, 1)
end)

RegisterServerEvent('pw_pets:server:setName')
AddEventHandler('pw_pets:server:setName', function(data)
    local _src = source
    if data.newName.value ~= nil then
        if string.len(data.newName.value) > 3 or string.len(data.newName.value) > 16 then
            registeredPets[tonumber(data.petId.value)].setName(data.newName.value, _src)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must specify a name with at least 4 characters (max: 16)'})
            TriggerClientEvent('pw_pets:client:setName', _src, tonumber(data.petId.value))
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You must specify a name for your pet'})
        TriggerClientEvent('pw_pets:client:setName', _src, tonumber(data.petId.value))
    end
end)

RegisterServerEvent('pw_pets:server:createPed')
AddEventHandler('pw_pets:server:createPed', function(id, ped)
    local _src = source
    registeredPets[id].updatePed(ped, _src)
end)

RegisterServerEvent('pw_pets:server:buyPet')
AddEventHandler('pw_pets:server:buyPet', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local breed = (data.breed or data)
    local petCost = Config.Pets[breed].price
    if _char:Cash().getBalance() >= petCost then
        _char:Cash().removeCash(petCost, function(done)
            if done then
                MySQL.Async.insert('INSERT INTO `character_pets` (`character_id`, `pet_hash`, `pet_name`, `pet_color`) VALUES (@cid, @petHash, @petName, @petColor)', {['@cid'] = _char.getCID(), ['@petHash'] = Config.Pets[breed].hash, ['@petName'] = pet, ['@petColor'] = (data.color or 0) }, function(rid)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'You just bought a '..breed })
                    registeredPets[rid] = generatePet(rid)
                    TriggerClientEvent('pw_pets:client:newPet', _src, {['id'] = rid, ['hash'] = Config.Pets[breed].hash, ['name'] = breed, ['ped'] = 0, ['needs'] = registeredPets[rid].specificMeta('needs'), ['health'] = registeredPets[rid].specificMeta('health') })
                    TriggerClientEvent('pw_pets:client:setName', _src, rid)
                end)
            end
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'Not enough money' })
    end
end)

PW.RegisterServerCallback('pw_pets:server:getOwnedProperties', function(source, cb)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    cb(_char.myProperties())
end)

exports.pw_chat:AddChatCommand('pets', function(source, args, rawCommand)
    local _src = source
    
    TriggerClientEvent('pw_pets:client:ownerMenu', _src)
end, {
    help = "Open Pet Menu",
    params = {}
}, -1)
