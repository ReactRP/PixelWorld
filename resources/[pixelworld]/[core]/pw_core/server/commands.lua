exports['pw_chat']:AddAdminChatCommand('goto', function(source, args, rawCommand)
    local _src = source
    if _src then
        if args[1] and args[2] and args[3] then
            coords = { ['x'] = tonumber(args[1]), ['y'] = tonumber(args[2]), ['z'] = tonumber(args[3]) }
            PW.doAdminLog(_src, "Teleported", coords, true)
        else
            PW.doAdminLog(_src, "Teleported", {['towaypoint'] = true}, true)
            coords = { ['x'] = false, ['y'] = false, ['z'] = false }
        end
        TriggerClientEvent('pw:teleport', _src, coords)
    end
end, {
    help = "[Admin Only] - Goto a Location",
    params = {{ name = "X", help = "The X Position"}, { name = "Y", help = "The Y Position"}, {name = "Z", help = "The Z Position"} }
}, -1)

exports['pw_chat']:AddAdminChatCommand('noclip', function(source, args, rawCommand)
    if source > 0 then 
            TriggerClientEvent("pw_core:noclip", source)
            PW.doAdminLog(source, "NoClip", {['toggled'] = true}, false)
        end
    end, {
            help = "[Admin Only] - Enable / Disable NoClipping",
    }, -1)

exports['pw_chat']:AddAdminChatCommand('reloadcache', function(source, args, rawCommand)
    if source > 0 then 
            PWBase['StartUp'].DatabaseLoads(true)
            PW.doAdminLog(source, "Database Cache Reload", {['toggled'] = true}, true)
        end
    end, {
            help = "[Admin Only] - Reload the Database Server Cache",
    }, -1)

exports['pw_chat']:AddAdminChatCommand('setjob', function(source, args, rawCommand)
    if source > 0 then 
            local char = exports['pw_core']:getCharacter(source)
            char:Job().setJob(args[1], args[2], tonumber(args[3]), (tonumber(args[4]) or nil))
        end
    end, {
            help = "[Admin Only] - Set your characters job.",
            params = {{ name = "Job", help = "The Job Name"}, { name = "Grade", help = "Job Grade"}, {name = "WorkplaceID", help = "ID Of the desired workplace"}, {name = "Salery", help = "[Optional] Set a Salery for this person"} }
    }, -1)

exports['pw_chat']:AddAdminChatCommand('removejob', function(source, args, rawCommand)
    if source > 0 then 
            local char = exports['pw_core']:getCharacter(source)
            char:Job().removeJob()
        end
    end, {
            help = "[Admin Only] - Remove job from your character",
    }, -1)

exports['pw_chat']:AddAdminChatCommand('setsalery', function(source, args, rawCommand)
    if source > 0 then 
            local char = exports['pw_core']:getCharacter(source)
            char:Job().setSalery(tonumber(args[1]))
        end
    end, {
            help = "[Admin Only] - Set your Characters current salery",
            params = {{ name = "Salery Figure", help = "The amount to set as your salery"} }
    }, -1)

exports['pw_chat']:AddChatCommand('me', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil then
        TriggerClientEvent('pw_core:startMeText', _src, args)
    end
end, {
    help = "Send a Me Action Message"
}, -1)

exports['pw_chat']:AddAdminChatCommand('sv', function(source, args, rawCommand)
    local _src = source
    local model = args[1] or "r820"
    TriggerClientEvent('pw_core:admin:spawnVehicle', _src, model)
    PW.doAdminLog(source, "Vehicle Spawned", {['toggled'] = true, ['vehicle'] = model}, true)
end, {
    help = "[Admin] - Spawn a Vehicle",
    params = {
    {
        name = "MODEL",
        help = "Model Name or Blank for the 'Audi R820'"
    },
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('dv', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_core:admin:deleteVehicle', _src)
end, {
    help = "[Admin] - Despawn a Vehicle"
}, -1)

exports['pw_chat']:AddAdminChatCommand('giveitem', function(source, args, rawCommand)
    local _src = source
    if Characters[_src] then
        local amount = (tonumber(args[2]) or 1)
        Characters[_src]:Inventory():Add().Default(1, args[1], amount, {}, {}, function(meh)
            PW.doAdminLog(source, "Item Added", {['item'] = args[1], ['amount'] = amount, ['cid'] = Characters[_src].getCID()}, true)
        end, Characters[_src].getCID())
    end
end, {
    help = "[Admin] - Give yourself a item",
    params = {{ name = "Item Name", help = "The Database Name of the Item"}, { name = "Amount", help = "the Amount of this item to give."} }
}, -1)