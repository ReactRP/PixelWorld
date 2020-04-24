exports.pw_chat:AddAdminChatCommand('polystart', function(source, args, rawCommand)
    local name = args[1]
    if name then
        TriggerClientEvent("polyzone:polystart", source, name)
    else
        TriggerClientEvent('pw:notification:SendAlert', source, { type = 'error', text = 'Name required', length = 5000 })
    end
end, {
    help = 'Starts creation of a shape for PolyZone.',
    params = {
        {
            name = 'name',
            help = 'Shape Name (required)',
        }
    }
}, -1)

exports.pw_chat:AddAdminChatCommand('polyadd', function(source, args, rawCommand)
    TriggerClientEvent("polyzone:polyadd", source)
end, {
    help = 'Adds point to shape.'
}, -1)

exports.pw_chat:AddAdminChatCommand('polyundo', function(source, args, rawCommand)
    TriggerClientEvent("polyzone:polyundo", source)
end, {
    help = 'Undoes the last point added.'
}, -1)

exports.pw_chat:AddAdminChatCommand('polyfinish', function(source, args, rawCommand)
    TriggerClientEvent("polyzone:polyfinish", source)
end, {
    help = 'Finishes and prints shape.'
}, -1)

exports.pw_chat:AddAdminChatCommand('polycancel', function(source, args, rawCommand)
    TriggerClientEvent("polyzone:polycancel", source)
end, {
    help = 'Cancel shape creation.'
}, -1)