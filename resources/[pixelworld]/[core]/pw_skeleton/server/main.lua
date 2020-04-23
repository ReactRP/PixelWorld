local beds = {}

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    beds = caches.beds
    for k, v in pairs(beds) do
    PW.Print(v.coords)
        local decode = json.decode(v.coords)
        if decode then
            beds[k].x = decode.x
            beds[k].y = decode.y
            beds[k].z = decode.z
            beds[k].h = decode.h
        end
    end
end)

local bedsTaken = {}
local injuryBasePrice = 100

PW = nil

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)

AddEventHandler('playerDropped', function()
    if bedsTaken[source] ~= nil then
        beds[bedsTaken[source]].taken = false
    end
end)

RegisterServerEvent('pw_skeleton:server:RequestBed')
AddEventHandler('pw_skeleton:server:RequestBed', function(zone)
    for k, v in pairs(beds) do
        if v.zone == zone and not v.taken then
            v.taken = true
            bedsTaken[source] = k
            TriggerClientEvent('pw_skeleton:client:SendToBed', source, k, v)
            return
        end
    end

    TriggerClientEvent('pw_notify:client:SendAlert', source, { type = 'error', text = 'No beds available' })
end)

RegisterServerEvent('pw_skeleton:server:RPRequestBed')
AddEventHandler('pw_skeleton:server:RPRequestBed', function(plyCoords)
    local foundbed = false
    for k, v in pairs(beds) do
        local distance = #(vector3(v.x, v.y, v.z) - plyCoords)
        if distance < 3.0 then
            if not v.taken then
                v.taken = true
                foundbed = true
                TriggerClientEvent('pw_skeleton:client:RPSendToBed', source, k, v)
                return
            else
                TriggerClientEvent('pw_notify:client:SendAlert', source, { type = 'error', text = '~r~That bed is taken' })
            end
        end
    end

    if not foundbed then
        TriggerClientEvent('pw_notify:client:SendAlert', source, { type = 'error', text = '~r~Not near a hospital bed' })
    end
end)

RegisterServerEvent('pw_skeleton:server:EnteredBed')
AddEventHandler('pw_skeleton:server:EnteredBed', function()
    local src = source
    local _char = exports['pw_core']:getCharacter(src)
    _char:Health().getInjuries(function(injuries)
        local totalBill = injuryBasePrice

        if injuries ~= nil then
            for k, v in pairs(injuries.limbs) do
                if v.isDamaged then
                    totalBill = totalBill + (injuryBasePrice * v.severity)
                end
            end

            if injuries.isBleeding > 0 then
                totalBill = totalBill + (injuryBasePrice * injuries.isBleeding)
            end
        end

        local injured = exports.pw_core:getCharacter(src)
        injured:Bank().removeMoney(totalBill)
        --injured:Bank().Remove(totalBill, "Medical Expenses")
        TriggerClientEvent('pw:notification:SendAlert', src, { type = 'inform', text = 'You were billed for $' .. totalBill .. ' for medical services & expenses' })
        TriggerClientEvent('pw_skeleton:client:FinishServices', src)
    end)
    
end)

RegisterServerEvent('pw_skeleton:server:LeaveBed')
AddEventHandler('pw_skeleton:server:LeaveBed', function(id)
    beds[id].taken = false
end)

RegisterServerEvent('pw_skeleton:server:RemoveInventory')
AddEventHandler('pw_skeleton:server:RemoveInventory', function()
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    _char:Inventory():Remove().All(function(res)
    end)
end)

PW.RegisterServerCallback("pw_skeleton:getOnline", function(source, cb)    
    cb(#PW.CheckOnlineDuty('ems'))
end)

exports.pw_chat:AddChatCommand('bed', function(source, args, rawCommand)
    local _src = source
    
    TriggerClientEvent('pw_skeleton:client:RPCheckPos', _src)
end, {
    help = "Lay on bed",
    params = {}
}, -1)