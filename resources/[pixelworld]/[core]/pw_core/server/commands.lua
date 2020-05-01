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

exports['pw_chat']:AddAdminChatCommand('addcash', function(source, args, rawCommand)
    local _src = source
    if _src then
        local target = tonumber(args[1])
        if target and Characters[target] then
            if args[2] then
                Characters[target]:Cash().addCash(tonumber(args[2]), function(done)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "$"..args[2].." has been added to "..Characters[target].getFullName().." cash account.", length = 5000})
                end)
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This player is not online", length = 5000})
        end
    end
end, {
    help = "[Admin Only] - Add Cash to Player",
    params = {{ name = "Target", help = "The Target PayPal ID"}, { name = "Amount", help = "The Amount to Give"} }
}, -1)

exports['pw_chat']:AddAdminChatCommand('addbank', function(source, args, rawCommand)
    local _src = source
    if _src then
        local target = tonumber(args[1])
        if target and Characters[target] then
            if args[2] then
                Characters[target]:Bank().addMoney(tonumber(args[2]), "Admin Add Money of $"..args[2], function(done)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "$"..args[2].." has been added to "..Characters[target].getFullName().." bank account.", length = 5000})
                end)
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This player is not online", length = 5000})
        end
    end
end, {
    help = "[Admin Only] - Add Bank Money to Player",
    params = {{ name = "Target", help = "The Target PayPal ID"}, { name = "Amount", help = "The Amount to Give"} }
}, -1)

exports['pw_chat']:AddAdminChatCommand('addsavings', function(source, args, rawCommand)
    local _src = source
    if _src then
        local target = tonumber(args[1])
        if target and Characters[target] then
            if Characters[target]:Savings().checkExistance() then
                if args[2] then
                    Characters[target]:Savings().addMoney(tonumber(args[2]), "Admin Add Money of $"..args[2], function(done)
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "$"..args[2].." has been added to "..Characters[target].getFullName().." savings account.", length = 5000})
                    end)
                end
            else
                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This player has not opened a savings account yet.", length = 5000})
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This player is not online", length = 5000})
        end
    end
end, {
    help = "[Admin Only] - Add Bank Money to Player",
    params = {{ name = "Target", help = "The Target PayPal ID"}, { name = "Amount", help = "The Amount to Give"} }
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
            char:Job().setJob(args[1], args[2], (tonumber(args[3]) or 0), (tonumber(args[4]) or nil))
        end
    end, {
            help = "[Admin Only] - Set your characters job.",
            params = {{ name = "Job", help = "The Job Name"}, { name = "Grade", help = "Job Grade"}, {name = "WorkplaceID", help = "ID Of the desired workplace"}, {name = "Salery", help = "[Optional] Set a Salery for this person"} }
    }, -1)

exports.pw_chat:AddChatCommand('callsign', function(source, args, rawCommand)
    local _src = source
    if _src then
        if Characters[_src] then
            local _job = Characters[_src]:Job().getJob()
            if _job.name == "police" or _job.name == "ems" or _job.name == "fire" or _job.name == "prison" then
                if args[1] then
                    local avaliable = true
                    for k, v in pairs(Characters) do
                        if v:Job().getJob().callSign == tonumber(args[1]) then
                            avaliable = false
                        end
                    end

                    if avaliable then
                        Characters[_src]:Job().setCallSign(tonumber(args[1]))
                    else
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "This callsign is already assigned to someone.", length = 5000})
                    end
                end
            end
        end
    end
end, {
    help = '[PD/EMS/FIRE] - Set your Callsign',
    params = { { name = "Number", help = "The Callsign Number you wish to assign."} }
}, -1, { 'police', 'ems', 'fire' })

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
        if PWBase.Storage.itemStore[args[1]].type ~= "Weapon" then
            Characters[_src]:Inventory():Add().Default(1, args[1], amount, {}, {}, function(meh)
                PW.doAdminLog(source, "Item Added", {['item'] = args[1], ['amount'] = amount, ['cid'] = Characters[_src].getCID()}, true)
            end, Characters[_src].getCID())
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You can not give weapons via this command please use /giveweapon", length = 5000})
        end
    end
end, {
    help = "[Admin] - Give yourself a item",
    params = {{ name = "Item Name", help = "The Database Name of the Item"}, { name = "Amount", help = "the Amount of this item to give."} }
}, -1)

exports['pw_chat']:AddAdminChatCommand('setgang', function(source, args, rawCommand)
    local _src = source
    if args[1] ~= nil and args[2] ~= nil then
        local xTarget = tonumber(args[1])
        if Characters[xTarget] then
            local workplace
            if args[3] ~= nil then
                level = args[3]
            else
                level = 0
            end
            exports['pw_core']:getCharacter(xTarget):Gang().setGang(tonumber(args[2]), tonumber(level))
            PW.doAdminLog(source, "Set Gang", {['gang'] = args[2], ['rank'] = level, ['srctarget'] = xTarget}, false)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online", length = 5000})
        end
    end

end, {
    help = "Set the Gang of the requested Player",
    params = {
    {
        name = "PlayerID",
        help = "The Server ID of the player."
    },
    {
        name = "GangID",
        help = "The Unique Identifier for the Gang"
    },
    {
        name = "Level",
        help = "Optional will default to 0 if not set."
    }
}
}, -1)

exports['pw_chat']:AddAdminChatCommand('giveweapon', function(source, args, rawCommand)
    local _src = source
    local targetSrc = tonumber(args[1])
    if Characters[targetSrc] then
        if PWBase.Storage.itemStore[args[2]].type == "Weapon" then
            local info = {
                ['name'] = args[2],
                ['ammo'] = tonumber(args[3]),
                ['cid'] = Characters[targetSrc].getCID(),
                ['source'] = tonumber(targetSrc),
                ['purchaseMethod'] = { ['method'] = "none", ['card'] = 0, ['cost'] = 0, ['obtainedBy'] = "admin" }
            }
            exports['pw_weaponmanagement']:registerWeapon(info)
            PW.doAdminLog(source, "Weapon Issued", {['weapon'] = args[2], ['ammo'] = tonumber(args[3]), ['srctarget'] = tonumber(args[1]), ['characterName'] = Characters[targetSrc].getFullName(), ['characterCID'] = Characters[targetSrc].getCID()}, true)
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "Only weapons can be given via this command, use /giveitem for anything else.", length = 5000})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The requested Player ID is not online.", length = 5000})
    end
end, {
    help = "[Admin] - Give a player a Weapon",
    params = {{name = "Player ID", "[Server ID] The Player to issue the weapon to"}, { name = "Weapon Name", help = "The Database Name of the Weapon"}, { name = "Ammo", help = "The amount of ammo to go with the weapon."} }
}, -1)