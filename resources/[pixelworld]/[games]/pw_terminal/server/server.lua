PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

exports.pw_chat:AddAdminChatCommand('terminal', function(source, args, rawCommand)
    TriggerClientEvent('pw_terminal:client:open', source)
end, {
    help = 'description',
    params = {}
}, -1)