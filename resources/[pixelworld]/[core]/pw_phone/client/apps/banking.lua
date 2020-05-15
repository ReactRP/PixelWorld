local banks = {}
local banksLoaded = false
local atmModels = {
    [-1126237515] = true,
    [506770882] = true,
    [-1364697528] = true,
    [-870868698] = true,
}

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if not ready then
            PW.TriggerServerCallback('pw_phone:server:banking:getActiveBanks', function(bnks)
                if bnks[1] ~= nil then
                    for k, v in pairs(bnks) do
                        table.insert(banks, {['x'] = v.coords.x, ['y'] = v.coords.y, ['z'] = v.coords.z})
                    end
                end
                banksLoaded = true
            end)
        end
    else
        banksLoaded = false
        banks = {}
    end
end)

RegisterNUICallback('GetBankTransactions', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:banking:GetBankTransactions', cb, { account_number = data.account_number, sort_code = data.account_sortcode, account_type = data.account_type })
end)

RegisterNUICallback('Transfer', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:banking:Transfer', cb, { from = data.from, account_number = data.account_number, sort_code = data.sort_code, amount = data.amount })
end)

RegisterNUICallback('Transfer', function(data, cb)
    PW.TriggerServerCallback('pw_phone:server:banking:Transfer', cb, { from = data.from, account_number = data.account_number, sort_code = data.sort_code, amount = data.amount })
end)

function FindNearestBranch()
    local shortest = 100000
    local bank = nil
    for k, v in ipairs(banks) do
        local dist = #(vector3(v.x, v.y, v.z) - GLOBAL_COORDS)
        if dist < shortest then
            shortest = dist
            bank = v
        end
    end

    return bank
end

function FindNearestATM()
	local atms = {}
	local handle, object = FindFirstObject()
	local success

	repeat
		if atmModels[GetEntityModel(object)] then
			table.insert(atms, object)
		end

        success, object = FindNextObject(handle, object)
	until not success
    PW.Print(atms)
	EndFindObject(handle)

	local atmObject = false
	local atmDistance = 100000

    for k,v in pairs(atms) do
        local dstcheck = #(GLOBAL_COORDS - GetEntityCoords(v))

        if dstcheck < atmDistance then
			atmDistance = dstcheck
			atmObject = v
            print(atmObject, atmDistance)
		end
    end
    
    if atmObject then
        return atmObject, atmDistance
    else
        print('dint find one')
        return false, false
    end
end

RegisterNUICallback('FindNearestBranch', function(data, cb)
    if characterLoaded and banksLoaded then
        local bank = FindNearestBranch()
        SetNewWaypoint(bank.x, bank.y)
    end
end)

RegisterNUICallback('FindNearestAtm', function(data, cb)
    if characterLoaded then
        local o, d = FindNearestATM()
        if o then
            local pos = GetEntityCoords(o)
            SetNewWaypoint(pos.x, pos.y)
            cb(true)
        else
            cb(false)
        end
    end
end)

