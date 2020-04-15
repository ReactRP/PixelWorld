PW = nil
local loaded = false
local inCustody = {}
local currentlyAllowingBreakOuts = false

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_prison:server:checkBreakouts', function(source, cb)
    cb(currentlyAllowingBreakOuts)
end)

exports('toggleBreakout', function()
    currentlyAllowingBreakOuts = not currentlyAllowingBreakOuts
end)

PW.RegisterServerCallback('pw_prison:server:checkCustodyState', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _prisonCheck = _char:Custody().getPrisonState()
    cb(_prisonCheck.inPrison, _prisonCheck.time)
end)

RegisterServerEvent('pw_prison:server:registerPrison')
AddEventHandler('pw_prison:server:registerPrison', function(time)
    local _src = source
    exports['pw_core']:getCharacter(_src):Custody().updatePrisonStatus(true, time)
end)

RegisterServerEvent('pw_prison:server:addPrisoner')
AddEventHandler('pw_prison:server:addPrisoner', function(time)
    local _src = source
    inCustody[_src] = { ['countUp'] = 0, ['timeLeft'] = time, ['source'] = _src }
end)

RegisterServerEvent('pw_prison:server:removeFromTimer')
AddEventHandler('pw_prison:server:removeFromTimer', function()
    local _src = source
    if inCustody[_src] then
        inCustody[_src] = nil
    end
end)

AddEventHandler('playerDropped', function()
    local _src = source
    if inCustody[_src] then
        inCustody[_src] = nil
    end
end)

RegisterServerEvent('pw_prison:server:jailBreakComplete')
AddEventHandler('pw_prison:server:jailBreakComplete', function(toggle)
    currentlyAllowingBreakOuts = toggle
end)

RegisterServerEvent('pw_prison:server:playerBrokeOut')
AddEventHandler('pw_prison:server:playerBrokeOut', function()
    local _src = source
    if inCustody[_src] then
        exports['pw_core']:getCharacter(_src):Custody().updatePrisonStatus(false, 0)
        inCustody[_src] = nil
    end
end)

RegisterServerEvent('pw_prison:server:completedWork')
AddEventHandler('pw_prison:server:completedWork', function(timeReduction)
    local _src = source
    if _src ~= nil and _src > 0 then
        adjustSentence(_src, timeReduction)
    end
end)

function adjustSentence(src, time)
    local _src = src
    if _src ~= nil and _src > 0 then
        if inCustody[_src] then
            if inCustody[_src].timeLeft - time == 0 then
                exports['pw_core']:getCharacter(_src):Custody().updatePrisonStatus(false, 0)
                TriggerClientEvent('pw_prison:client:updatePrisonTime', _src, 0)
                inCustody[_src] = nil
            else
                inCustody[_src].timeLeft = inCustody[_src].timeLeft - time
                TriggerClientEvent('pw_prison:client:updatePrisonTime', _src, inCustody[_src].timeLeft)
                exports['pw_core']:getCharacter(_src):Custody().updatePrisonStatus(true, inCustody[_src].timeLeft)
            end
        end
    end
end

RegisterServerEvent('pw_prison:server:increaseTime')
AddEventHandler('pw_prison:server:increaseTime', function(timeReduction)
    local _src = source
    if _src ~= nil and _src > 0 then
        adjustSentenceInc(_src, timeReduction)
    end
end)

function adjustSentenceInc(src, time)
    local _src = src
    if _src ~= nil and _src > 0 then
        if inCustody[_src] then
            inCustody[_src].timeLeft = (inCustody[_src].timeLeft + time)
            TriggerClientEvent('pw_prison:client:updatePrisonTime', _src, inCustody[_src].timeLeft)
            exports['pw_core']:getCharacter(_src):Custody().updatePrisonStatus(true, inCustody[_src].timeLeft)
        end
    end
end

function manageInmates()
    for k, v in pairs(inCustody) do
        v.countUp = v.countUp + 5
        if v.countUp >= 60 then
            v.timeLeft = v.timeLeft - 1
            v.countUp = 0
            TriggerClientEvent('pw_prison:client:updatePrisonTime', v.source, v.timeLeft)
            exports['pw_core']:getCharacter(v.source):Custody().updatePrisonStatus(true, v.timeLeft)
        end

        if v.timeLeft <= 0 then
            exports['pw_core']:getCharacter(v.source):Custody().updatePrisonStatus(false, 0)
            inCustody[v.source] = nil
        end
    end
    SetTimeout(5000, function() manageInmates() end)
end

MySQL.ready(function ()
    SetTimeout(5000, function() manageInmates() end)
end)