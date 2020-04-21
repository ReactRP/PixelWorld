PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

RegisterServerEvent('pw_fooddelivery:server:toggleDuty')
AddEventHandler('pw_fooddelivery:server:toggleDuty', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Job().toggleDuty()
end)

RegisterServerEvent('pw_fooddelivery:server:finishdelivery')
AddEventHandler('pw_fooddelivery:server:finishdelivery', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local pay = math.random(Config.DeliveryPay.min, Config.DeliveryPay.max)      
    local _balance = _char:Cash().addCash(pay)
    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = 'You were paid $' .. math.ceil(pay) .. ' in cash for that food delivery.', length = 3000})
end)

