
RegisterServerEvent('pw_hud:client:saveStats')
AddEventHandler('pw_hud:client:saveStats', function(stats)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Needs().saveNeeds(stats.hunger, stats.thirst, stats.stress, stats.drugs, stats.drunk)
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == "joint" then
        TriggerClientEvent('pw_needs:client:usedJoint', _src, data)
    end
end)

exports['pw_chat']:AddAdminChatCommand('resetstats', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_needs:client:forceUpdate', _src, exports['pw_core']:getConfig("NewCharacters").needs)
end, {
    help = "[Admin] - Reset you Needs and Character Statistics"
}, -1)