PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

PW.RegisterServerCallback('pw_carwash:server:checkMoney', function(source, cb)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    cb(_char:Cash().getBalance())
end)

RegisterServerEvent('pw_carwash:server:finishCarWash')
AddEventHandler('pw_carwash:server:finishCarWash', function()
    local _src = source 
    local _char = exports.pw_core:getCharacter(_src)
    _char:Cash().removeCash(Config.Cost, function(done)
        if done then    
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Vehicle Washed for $' .. Config.Cost.. '.', length = 5000})
        end
    end)
end)