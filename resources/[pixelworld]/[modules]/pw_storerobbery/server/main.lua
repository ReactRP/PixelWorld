PW = nil
Stores = {}

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.fetchAll("SELECT * FROM `shops` WHERE `marker` = 1 AND `robbery` IS NOT NULL", {}, function(stores)
        if stores and stores[1] ~= nil then
            Stores = stores
            for k,v in pairs(Stores) do
                Stores[k].shop_coords = json.decode(v.shop_coords)
                Stores[k].robbery = json.decode(v.robbery)
                Stores[k].robbed = false
                Stores[k].robbing = false
                Stores[k].npcSpawned = false
                Stores[k].robbery.safe.code = GenerateRegisterCode()
            end
        end
    end)
end)

function GenerateRegisterCode()
    local num1 = math.random(0,9)
    local num2 = math.random(0,9)
    local num3 = math.random(0,9)
    local num4 = math.random(0,9)

    return num1 .. num2 .. num3 .. num4
end


RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == 'lockpick' then
        TriggerClientEvent('pw_storerobbery:client:usedLockpick', _src, data)
    end
end)

RegisterServerEvent('pw_storerobbery:server:awardSafe')
AddEventHandler('pw_storerobbery:server:awardSafe', function(store)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)

    local awardMoney = math.random(Config.SafeMoney.min, Config.SafeMoney.max)

    _char:Inventory():Add().Default(1, 'moneybag', 1, {['amount'] = awardMoney }, {}, function(done) end)

    TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found a bag with some money inside.', length = 5000 })
    TriggerEvent('pw_storerobbery:server:updateSafe', store, 'robbing', false)
    TriggerEvent('pw_storerobbery:server:updateSafe', store, 'cooldown', true)
end)

RegisterServerEvent('pw_storerobbery:server:updateSafe')
AddEventHandler('pw_storerobbery:server:updateSafe', function(store, var, state)
    Stores[store].robbery.safe[var] = state
    TriggerClientEvent('pw_storerobbery:client:updateSafe', -1, store, var, state)
    if var == 'cooldown' and state then
        PW.SetTimeout(Config.SafeCooldown * 1000, function()
            Stores[store].robbery.safe['cooldown'] = false
            TriggerClientEvent('pw_storerobbery:client:updateSafe', -1, store, 'cooldown', false)
            ResetSafe(store)
        end)
    end
end)

function ResetSafe(store)
    Stores[store].robbery.safe.robbing = false
    Stores[store].robbery.safe.code = GenerateRegisterCode()

    TriggerClientEvent('pw_storerobbery:client:resetSafe', -1, store, Stores[store].robbery.safe)
end

RegisterServerEvent('pw_storerobbery:server:removeItem')
AddEventHandler('pw_storerobbery:server:removeItem', function(data)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    _char:Inventory():Remove().Single("lockpick", function(h) end)
end)

RegisterServerEvent('pw_storerobbery:server:awardRegisters')
AddEventHandler('pw_storerobbery:server:awardRegisters', function(store, register)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    
    local awardMoney = math.random(Config.RegistersMoney.min, Config.RegistersMoney.max)
    if awardMoney > 0 then
        _char:Cash().addCash(awardMoney, function(done)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found $' .. awardMoney .. ' inside the register.', length = 4500 })
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'The register is empty.', length = 4500 })
    end
    
    local noteChance = (math.random(1,100) <= Config.RegistersNoteChance)
    if noteChance then
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You found a note.', length = 4500 })
        TriggerClientEvent('pw_notes:client:createNote', _src, Stores[store].robbery.safe.code)
    end

    TriggerEvent('pw_storerobbery:server:updateRegister', store, register, 'robbing', false)
    TriggerEvent('pw_storerobbery:server:updateRegister', store, register, 'cooldown', true)
end)

RegisterServerEvent('pw_storerobbery:server:updateRegister')
AddEventHandler('pw_storerobbery:server:updateRegister', function(store, register, var, state)
    Stores[store].robbery.registers[register][var] = state
    TriggerClientEvent('pw_storerobbery:client:updateRegister', -1, store, register, var, state)
    if var == 'cooldown' and state then
        PW.SetTimeout(Config.RegistersCooldown * 1000, function()
            Stores[store].robbery.registers[register]['cooldown'] = false
            TriggerClientEvent('pw_storerobbery:client:updateRegister', -1, store, register, 'cooldown', false)
        end)
    end
end)

RegisterServerEvent('pw_storerobbery:server:startRobbery')
AddEventHandler('pw_storerobbery:server:startRobbery', function(store)
    Stores[store].clerkMoney = math.random(Config.ClerkMoney.min, Config.ClerkMoney.max)
    TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'clerkMoney', Stores[store].clerkMoney)
    Stores[store].paymentsLeft = Config.ClerkPayments
    TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'paymentsLeft', Stores[store].paymentsLeft)
    Stores[store].clerkCooldown = true
    TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'clerkCooldown', true)
    TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'robbing', true)
    PW.SetTimeout(Config.ClerkCooldown * 1000, function()
        Stores[store].clerkCooldown = false
        TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'clerkCooldown', false)
        ResetStore(store)
    end)
end)

function ResetStore(store)
    Stores[store].robbed = false
    Stores[store].robbing = false
    Stores[store].npcSpawned = false
    Stores[store].npcObj = nil

    TriggerClientEvent('pw_storerobbery:client:resetStore', -1, store, Stores[store])
end

RegisterServerEvent('pw_storerobbery:server:payClerk')
AddEventHandler('pw_storerobbery:server:payClerk', function(store)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)

    Stores[store].paymentsLeft = Stores[store].paymentsLeft - 1
    TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'paymentsLeft', Stores[store].paymentsLeft)

    local payNow
    if Stores[store].paymentsLeft == 0 then
        payNow = Stores[store].clerkMoney
    else
        payNow = math.random(0, Stores[store].clerkMoney)
    end
    Stores[store].clerkMoney = Stores[store].clerkMoney - payNow

    _char:Cash().addCash(payNow, function(done)
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'The clerk gave you $' .. payNow, length = 5000 })
    end)
    if Stores[store].paymentsLeft == 0 then
        PW.SetTimeout(Config.ClerkMoneyDelay * 1000, function()
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'The clerk doesn\'t have any money left.<br>Check the register' .. (#Stores[store].robbery.registers > 1 and "s!" or "!"), length = 7000 })
            TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'robbing', false)
        end)
    end
end)

RegisterServerEvent('pw_storerobbery:server:updateStore')
AddEventHandler('pw_storerobbery:server:updateStore', function(store, var, state)
    Stores[store][var] = state
    TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, var, state)
end)

RegisterServerEvent('pw_storerobbery:server:updateNpc')
AddEventHandler('pw_storerobbery:server:updateNpc', function(store, ped)
    Stores[store].npcObj = ped
    TriggerClientEvent('pw_storerobbery:client:updateNpc', -1, store, ped)
    if ped ~= nil then
        Stores[store].npcSpawned = true
        TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'npcSpawned', true)
        TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'spawningNpc', false)
    else
        Stores[store].npcSpawned = false
        TriggerClientEvent('pw_storerobbery:client:updateStore', -1, store, 'npcSpawned', false)
    end
end)

PW.RegisterServerCallback('pw_storerobbery:server:getStores', function(source, cb)
    cb(Stores)
end)