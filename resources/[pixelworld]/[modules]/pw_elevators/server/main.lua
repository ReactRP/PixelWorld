PW = nil
local elevators = {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    FetchElevators()
end)

function FetchElevators(send)
    local done = false
    elevators = {}
    MySQL.Async.fetchAll("SELECT * FROM elevators", {}, function(elevations)
        for k, v in pairs(elevations) do
            local data = {}
            data.elevators = {}
            if v.elevator_meta ~= nil then
                data.elevators = json.decode(v.elevator_meta)
            end
            data.name = v.elevator_name
            data.id = v.elevator_id
            table.insert(elevators, data)
        end

        if send then
            TriggerClientEvent('pw_elevators:client:updateElevators', -1, elevators)
        end

        done = true
    end)

    while not done do Wait(10); end
end

PW.RegisterServerCallback('pw_elevators:server:requestElevators', function(source, cb)
    cb(elevators)
end)

RegisterServerEvent('pw_elevators:server:newFloor')
AddEventHandler('pw_elevators:server:newFloor', function(data)
    local _src = source

    local elev = tonumber(data.elevator.value)
    local floorName = data.name.value

    if string.len(floorName) > 2 then
        table.insert(elevators[elev].elevators, { ['label'] = floorName, ['x'] = data.coords.data.x, ['y'] = data.coords.data.y, ['z'] = data.coords.data.z })
        MySQL.Async.execute('UPDATE `elevators` SET `elevator_meta` = @meta WHERE `elevator_id` = @id', { ['@meta'] = json.encode(elevators[elev].elevators), ['@id'] = elevators[elev].id }, function()
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Floor \'' .. floorName .. '\' added to elevator \'' .. elevators[elev].name .. '\'', length = 5000 })
            FetchElevators(true)
            TriggerClientEvent('pw_elevators:client:adminManageElevators', _src)
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Floor name must have 3 or more characters', length = 5000 })
    end
end)

RegisterServerEvent('pw_elevators:server:deleteFloor')
AddEventHandler('pw_elevators:server:deleteFloor', function(data)
    local _src = source
    local elev = tonumber(data.elevator.value)
    local floor = tonumber(data.floor.value)
    elevators[elev].elevators[floor] = nil
    MySQL.Async.execute('UPDATE `elevators` SET `elevator_meta` = @meta WHERE `elevator_id` = @id', { ['@meta'] = json.encode(elevators[elev].elevators), ['@id'] = elevators[elev].id }, function()
        FetchElevators(true)
        TriggerClientEvent('pw_elevators:client:manageFloors', _src, elev)
    end)
end)

RegisterServerEvent('pw_elevators:server:deleteElevator')
AddEventHandler('pw_elevators:server:deleteElevator', function(data)
    local _src = source
    local elev = tonumber(data.elevator.value)
    MySQL.Async.execute('DELETE FROM `elevators` WHERE `elevator_id` = @id', { ['@id'] = elevators[elev].id }, function()
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Elevator ID ' .. elevators[elev].id .. ' deleted', length = 5000 })
        FetchElevators(true)
        TriggerClientEvent('pw_elevators:client:adminManageElevators', _src)
    end)
end)

RegisterServerEvent('pw_elevators:server:createElevator')
AddEventHandler('pw_elevators:server:createElevator', function(data)
    local _src = source
    if string.len(data.elevatorName.value) > 2 then
        MySQL.Async.insert('INSERT INTO `elevators` (`elevator_name`) VALUES (@elevator_name)', { ['@elevator_name'] = data.elevatorName.value }, function(inserted)
            if inserted > 0 then
                FetchElevators(true)
                TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Elevator created with ID '..inserted, length = 5000 })
                TriggerClientEvent('pw_elevators:client:adminMenu', _src)
            end
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Elevator name must be 3 characters or more', length = 5000 })
    end
end)

RegisterServerEvent('pw_elevators:server:changeNameFloor')
AddEventHandler('pw_elevators:server:changeNameFloor', function(data)
    local _src = source
    if string.len(data.floorName.value) > 2 then
        local elev = tonumber(data.elevator.value)
        local floor = tonumber(data.floor.value)
        elevators[elev].elevators[floor].label = data.floorName.value
        MySQL.Async.execute('UPDATE `elevators` SET `elevator_meta` = @meta WHERE `elevator_id` = @id', { ['@meta'] = json.encode(elevators[elev].elevators), ['@id'] = elevators[elev].id }, function()
            FetchElevators(true)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Floor name edited', length = 5000 })
            TriggerClientEvent('pw_elevators:client:manageFloors', _src, elev)
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Floor name must be 3 characters or more', length = 5000 })
    end
end)

exports.pw_chat:AddAdminChatCommand('elevators', function(source, args, rawCommand)
    TriggerClientEvent('pw_elevators:client:adminMenu', source)
end, {
    help = 'Open Admin Elevator Management menu',
    params = {}
}, -1)