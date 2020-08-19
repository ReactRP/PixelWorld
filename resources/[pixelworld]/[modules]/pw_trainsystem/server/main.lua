--Cunt

PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)


local runningTrains = { ['active'] = false, ['controllerSource'] = nil, ['metroTrainNetID'] = nil, ['metroCarriageNetID'] = nil, ['outerTrainNetID'] = nil, ['outerCarriageNetID'] = nil, ['MetroStop'] = 1}

RegisterServerEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function()
    local _src = source
    if not runningTrains.active then
        runningTrains.active = true
        runningTrains.controllerSource = _src
        print(' ^1[SynCity Train System] ^7', '^2Creating The Initial Trains With Player ID: ^2' .. _src .. '^7')
        TriggerClientEvent('pw_trainsystem:client:startTrainHostingInitital', _src)
    end 
end)

RegisterServerEvent('pw_trainsystem:server:saveNetIDsForTrains')
AddEventHandler('pw_trainsystem:server:saveNetIDsForTrains', function(MetroTrainNet, MetroCarriageNet, MetroStopID, OuterTrainNet, OuterCarriageNet, OuterStopID)
    local _src = source
    if runningTrains.controllerSource == _src then
        runningTrains.metroTrainNetID = MetroTrainNet
        runningTrains.metroCarriageNetID = MetroCarriageNet
        runningTrains.MetroStop = MetroStopID
    end
    --PW.Print(runningTrains)
end)

RegisterServerEvent('pw_trainsystem:server:updateCurrentMetroStop')
AddEventHandler('pw_trainsystem:server:updateCurrentMetroStop', function(stopID)
    local _src = source
    if runningTrains.active and runningTrains.controllerSource == _src then
        runningTrains.MetroStop = stopID
        --PW.Print(runningTrains)
    end
end)

AddEventHandler('playerDropped', function()
    local _src = source
    if runningTrains.active and (runningTrains.controllerSource ~= nil and runningTrains.controllerSource == _src) then -- if the owner drops then
        Wait(1000)
        -- NEED TO SEND THE TRAINS NET ID TO A RANDOM ONLINE CLIENT TO DELETE IT
        local onlineChars = exports['pw_core']:getOnlineCharacters()
        if #onlineChars > 0 then
            local selectedSource 
            for k,v in pairs(onlineChars) do
                if v.source ~= _src then
                    selectedSource = v.source
                    break
                end
            end
            if selectedSource ~= nil then
                if runningTrains.metroTrainNetID ~= nil and runningTrains.metroCarriageNetID ~= nil then
                    print(' ^1[SynCity Train System] ^7', '^2Train Control Hopefully Passed On To Player ID: ^2' .. selectedSource .. '^7')
                    TriggerClientEvent('pw_trainsystem:client:passControllingTrains', selectedSource, runningTrains.metroTrainNetID, runningTrains.metroCarriageNetID, runningTrains.MetroStop)
                    runningTrains.active = true
                    runningTrains.controllerSource = selectedSource
                else
                    print(' ^1[SynCity Train System] ^7', '^2Creating New Train With Player ID: ^2' .. selectedSource .. '^7')
                    TriggerClientEvent('pw_trainsystem:client:startTrainHostingInitital', selectedSource)
                    runningTrains.active = true
                    runningTrains.controllerSource = selectedSource
                end
            end
        else
            runningTrains.active = false
            runningTrains.controllerSource = 0
            runningTrains.metroTrainNetID = nil
            runningTrains.metroCarriageNetID = nil
        end
    end
end)

RegisterServerEvent('pw_trainsystem:server:startTrackingTrain')
AddEventHandler('pw_trainsystem:server:startTrackingTrain', function(source)
    local _src = source
    if runningTrains.controllerSource == _src then
        TriggerClientEvent('pw_trainsystem:client:startTrackingMetro', _src, runningTrains.metroTrainNetID, true)
    else
        TriggerClientEvent('pw_trainsystem:client:startTrackingMetro', _src, runningTrains.metroTrainNetID, false)
    end
end)

