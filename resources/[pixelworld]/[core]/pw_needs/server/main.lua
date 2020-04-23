
RegisterServerEvent('pw_needs:server:saveStats')
AddEventHandler('pw_needs:server:saveStats', function(stats)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Needs().saveNeeds(stats.hunger, stats.thirst, stats.stress, stats.drugs, stats.drunk, stats.armour)
end)

exports['pw_chat']:AddAdminChatCommand('resetstats', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_needs:client:forceUpdate', _src, exports['pw_core']:getConfig("NewCharacters").needs)
end, {
    help = "[Admin] - Reset you Needs and Character Statistics"
}, -1)