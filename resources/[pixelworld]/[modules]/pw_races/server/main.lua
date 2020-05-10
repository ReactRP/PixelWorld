PW = nil
Races = {}
local activeRace, raceContestants = {}, {}

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    FetchRaces()
end)

function FetchRaces(update)
    local done = false
    MySQL.Async.fetchAll('SELECT * FROM `races`', {}, function(races)
        Races = races
        for k,v in pairs(Races) do
            Races[k].positions =    json.decode(v.positions)
            Races[k].start =        json.decode(v.start)
            Races[k].finish =       json.decode(v.finish)
            Races[k].checkpoints =  json.decode(v.checkpoints)
            if v.records ~= nil then
                Races[k].records =  json.decode(v.records)
            end
            Races[k].typeLabel =    Config.RaceTypes[Races[k].raceType].type
        end
        
        if update then
            TriggerClientEvent('pw_races:client:updateRaces', -1, Races)
        end

        done = true
    end)

    while not done do Wait(10); end
end

function GetContestantIndex(src)
    for k,v in pairs(raceContestants) do
        if v.src == src then
            return k
        end
    end

    return false
end

RegisterServerEvent('pw_races:server:deleteRace')
AddEventHandler('pw_races:server:deleteRace', function(data)
    local raceId = tonumber(data.tId)
    if raceId > 0 then
        MySQL.Async.execute('DELETE FROM `races` WHERE `id` = @id', { ['@id'] = raceId }, function()
            FetchRaces(true)
        end)
    end
end)

RegisterServerEvent('pw_races:server:saveNewRace')
AddEventHandler('pw_races:server:saveNewRace', function(raceInfo)
    local _src = source

    MySQL.Async.insert('INSERT INTO `races` (`name`, `raceType`, `positions`, `max`, `start`, `finish`, `checkpoints`, `records`) VALUES (@name, @raceType, @positions, @max, @start, @finish, @checkpoints, @records)', {['@name'] = raceInfo.name, ['@raceType'] = raceInfo.type, ['@positions'] = json.encode(raceInfo.positions), ['@max'] = raceInfo.max, ['@start'] = json.encode(raceInfo.startPosition), ['@finish'] = json.encode(raceInfo.finishPosition), ['@checkpoints'] = json.encode(raceInfo.checkpoints), ['@records'] = json.encode({}) }, function(inserted)
        if inserted > 0 then
            FetchRaces(true)
            TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Race \''.. raceInfo.name ..'\' created (ID: '..inserted..')' })
        end
    end)
end)

RegisterServerEvent('pw_races:server:activeRace')
AddEventHandler('pw_races:server:activeRace', function(race, laps, contestants)
    local _src = source

    if race == false or race == 'end' then
        activeRace = {}
        if race == false then TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'Race canceled', length = 4000 }); end
    else
        activeRace.id = race
        activeRace.settings = { ['laps'] = laps, ['contestants'] = contestants }
        activeRace.organizer = _src
        activeRace.info = Races[race]
        raceContestants = {}
    end
    TriggerClientEvent('pw_races:client:activeRace', -1, activeRace)
end)

RegisterServerEvent('pw_races:server:signedUpOff')
AddEventHandler('pw_races:server:signedUpOff', function()
    local _src = source
    local index = GetContestantIndex(_src)
    if index then
        table.remove(raceContestants, index)
    end        
end)

function CheckAllDone()
    local allDone = true
    for k,v in pairs(raceContestants) do
        if not v.finished then
            allDone = false
            break
        end
    end

    return allDone
end

function UpdateRecords(race)
    local times, newTable = {}, {}
    if Races[race].records ~= nil and Races[race].records[1] ~= nil then
        for k,v in pairs(Races[race].records) do
            table.insert(times, v)
        end

        for k,v in pairs(raceContestants) do
            table.insert(times, (Races[race].raceType == 1 and v.time.best or v.time))
        end

        table.sort(times, function(a,b) return (type(a.total) == 'number' and a.total or 999999999) < (type(b.total) == 'number' and b.total or 999999999) end)

        for i = 1, 5 do
            if times[i] ~= nil then
                table.insert(newTable, times[i])
            end
        end
    else
        for k,v in pairs(raceContestants) do
            table.insert(times, v.time)
        end

        table.sort(times, function(a,b) return (type(a.total) == 'number' and a.total or 999999999) < (type(b.total) == 'number' and b.total or 999999999) end)

        for i = 1, 5 do
            if times[i] ~= nil and times[i].total ~= 'DNF' then
                table.insert(newTable, times[i])
            end
        end
    end

    MySQL.Async.execute('UPDATE `races` SET `records` = @records WHERE `id` = @id', { ['@records'] = json.encode(newTable), ['@id'] = Races[race].id }, function()
        FetchRaces(true)
    end)
end

RegisterServerEvent('pw_races:server:finished')
AddEventHandler('pw_races:server:finished', function(raceTime)
    local _src = source
    local index = GetContestantIndex(_src)
    if index then
        raceContestants[index].finished = true
        local _char = exports.pw_core:getCharacter(_src)
        local name = _char.getFullName()
        if raceTime == 'DNF' then
            raceContestants[index].time = { ['name'] = name, ['total'] = 'DNF', ['display'] = 'DNF' }
            if Races[activeRace.id].raceType == 1 then
                raceContestants[index].time.best = { ['name'] = name, ['total'] = 'DNF', ['display'] = 'DNF' }
            end
        else
            raceContestants[index].time = { ['name'] = name, ['total'] = raceTime.total, ['display'] = raceTime.display, ['topSpeed'] = raceTime.topSpeed }
            if Races[activeRace.id].raceType == 1 then
                raceContestants[index].time.best = raceTime.best
                raceContestants[index].time.best['name'] = name
            end
        end
        if CheckAllDone() then
            UpdateRecords(activeRace.id)
            table.sort(raceContestants, function(a,b) return a.time.total < b.time.total end)
            local organizer = activeRace.organizer
            local raceId = activeRace.id
            local msg = "Race ended. Results:"
            Citizen.SetTimeout(16000, function()
                for i = 1, #raceContestants, 1 do
                    msg = msg .. '<br>#' .. i .. ": " .. raceContestants[i].time.name .. " - " .. raceContestants[i].time.display .. ((Races[raceId].raceType == 1 and raceContestants[i].time.total ~= 'DNF') and " (Best: " .. raceContestants[i].time.best.display .. ")" or "")
                end
                local sentOrganizer = false
                for i = 1, #raceContestants do
                    if raceContestants[i].src == organizer then sentOrganizer = true; end
                    TriggerClientEvent('pw:notification:SendAlert', raceContestants[i].src, { type = 'inform', text = msg, length = 30000 })    
                end
                if not sentOrganizer then TriggerClientEvent('pw:notification:SendAlert', organizer, { type = 'inform', text = msg, length = 30000 }); end
            end)
            activeRace = {}
        end
        TriggerClientEvent('pw_races:client:joinedRace', _src, false)
        TriggerEvent('pw_races:server:activeRace', false)
    end
end)

RegisterServerEvent('pw_races:server:clearRecord')
AddEventHandler('pw_races:server:clearRecord', function(data)
    local raceId = tonumber(data.tId)
    if raceId > 0 then
        MySQL.Async.execute("UPDATE `races` SET `records` = @records WHERE `id` = @id", { ['@records'] = json.encode({}), ['@id'] = raceId }, function()
            FetchRaces(true)
        end)
    end
end)

RegisterServerEvent('pw_races:server:signUp')
AddEventHandler('pw_races:server:signUp', function(plate, model)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local charName = _char.getFullName()

    if #raceContestants < Races[activeRace.id].max then
        if Races[activeRace.id].raceType ~= 4 then
            table.insert(raceContestants, { ['src'] = _src, ['name'] = charName, ['finished'] = false, ['time'] = {}, ['plate'] = plate, ['model'] = model } )
        else
            table.insert(raceContestants, { ['src'] = _src, ['name'] = charName, ['finished'] = false, ['time'] = {} } )
        end
        TriggerClientEvent('pw_races:client:joinedRace', _src, true)
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'inform', text = 'You have signed up for the race', 4000 })
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Race is full', 4000 })
    end
end)

PW.RegisterServerCallback('pw_races:server:getContestants', function(source, cb)
    cb(#raceContestants > 0 and raceContestants or false)
end)

RegisterServerEvent('pw_races:server:changePole')
AddEventHandler('pw_races:server:changePole', function(src, data)
    local tempCur = raceContestants[data.curPos]
    local tempNew = raceContestants[data.newPos]
    raceContestants[data.curPos] = tempNew
    raceContestants[data.newPos] = tempCur
    
    TriggerClientEvent('pw_phone:client:loadData', src, 'updatePole', raceContestants)
end)

RegisterServerEvent('pw_races:server:disqualify')
AddEventHandler('pw_races:server:disqualify', function()
    local _src = source
    local index = GetContestantIndex(_src)
    if index > 0 then
        raceContestants[index] = nil
        TriggerClientEvent('pw_races:client:joinedRace', _src, false)
    end
end)

RegisterServerEvent('pw_races:server:raceReady')
AddEventHandler('pw_races:server:raceReady', function()
    local _src = source

    if activeRace.organizer == _src then
        if raceContestants ~= nil and #raceContestants > 0 then -- and #raceContestants > Config.RaceTypes[Races[activeRace].raceType].min
            for k,v in pairs(raceContestants) do
                if v.src ~= nil then
                    TriggerClientEvent('pw_races:client:setPositions', v.src, activeRace.id, k, v.plate, v.model)
                    Wait(1000)
                end
            end

            local countdown = 10
            Citizen.CreateThread(function()
                while countdown > 0 do
                    TriggerClientEvent('pw_races:client:countdown', -1, countdown, activeRace.settings.laps)
                    countdown = countdown - 1
                    Citizen.Wait(1000)
                end

                TriggerClientEvent('pw_races:client:fookingGO', -1)
            end)
        end
    end
end)

RegisterServerEvent('pw_races:server:sendActive')
AddEventHandler('pw_races:server:sendActive', function(src, pkey)
    if activeRace.id ~= nil and activeRace.id ~= false then
        TriggerClientEvent('pw_phone:client:loadData', src, pkey, { ['active'] = activeRace, ['contestants'] = raceContestants, ['org'] = (src == activeRace.organizer) })
    end
end)

RegisterServerEvent('pw_races:server:getRacesForPhone')
AddEventHandler('pw_races:server:getRacesForPhone', function(src, pkey)
    if pkey == 'manageTracks' then
        TriggerClientEvent('pw_phone:client:loadData', src, pkey, Races)
    else
        if activeRace.id == nil then
            TriggerClientEvent('pw_phone:client:loadData', src, pkey, Races)
        else
            TriggerClientEvent('pw_phone:client:loadData', src, pkey, false)
        end
    end
end)

PW.RegisterServerCallback('pw_races:server:getRaces', function(source, cb)
    cb(Races, activeRace)
end)

exports.pw_chat:AddAdminChatCommand('races', function(source, args, rawCommand)
    TriggerClientEvent('pw_races:client:adminRaceMenu', source)
end, {
    help = 'Race Management',
    params = {}
}, -1)

exports.pw_chat:AddAdminChatCommand('createrace', function(source, args, rawCommand)
    TriggerClientEvent('pw_races:client:startRaceMenu', source)
end, {
    help = 'Race Management',
    params = {}
}, -1)

exports.pw_chat:AddAdminChatCommand('joinrace', function(source, args, rawCommand)
    if activeRace.id then
        TriggerClientEvent('pw_races:client:joinRace', source)
    end
end, {
    help = 'Race Management',
    params = {}
}, -1)