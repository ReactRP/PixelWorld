PW = nil

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    MySQL.Async.execute("DELETE FROM `character_keys` WHERE `stolen` = '1'", {}, function(rowsDeleted)
        if rowsDeleted > 0 then
            print(' ^1[PixelWorld] ^3- We have deleted '..rowsDeleted..' keys from the system.')
        end
    end)
    MySQL.Async.execute("DELETE FROM `character_keys` WHERE `job` = '1'", {}, function(rowsDeleted)
        if rowsDeleted > 0 then
            print(' ^1[PixelWorld] ^3- We have deleted '..rowsDeleted..' job vehicle keys from the system.')
        end
    end)
end)

PW.RegisterServerCallback('pw_keys:checkKeyHolder', function(source, cb, type, identifier)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local processed = false
    MySQL.Async.fetchAll("SELECT * FROM `character_keys` WHERE `type` = @type AND `identifier` = @ident AND `holder_id` = @holder", {
        ['@type'] = type,
        ['@ident'] = identifier,
        ['@holder'] = tonumber(_char.getCID())
    }, function(res)
        cb(res[1] ~= nil)
    end)
end)

RegisterServerEvent('pw_keys:revokeKeys')
AddEventHandler('pw_keys:revokeKeys', function(typee, identifier, job, cid)
    if job == true then
        MySQL.Async.execute("DELETE FROM `character_keys` WHERE `job` = 1 AND `type` = @type AND `identifier` = @ident", {['@type'] = typee, ['@ident'] = identifier} )
    else
        if identifier and cid ~= nil and type(cid) == "number" and type(identifier) == "number" then
            MySQL.Async.execute("DELETE FROM `character_keys` WHERE `owner_id` = @cid AND `type` = @type AND `identifier` = @ident", {['@type'] = typee, ['@cid'] = cid, ['@ident'] = identifier} )
        end
    end
end)

RegisterServerEvent('pw_keys:issueKey')
AddEventHandler('pw_keys:issueKey', function(keytype, identifier, stolen, job, notify, src)
    local _src = src or source
    local _char = exports.pw_core:getCharacter(_src)
    if identifier and keytype ~= nil then
        if stolen == nil then
            stolen = false
        end
        if job == nil then 
            job = false
        end
        MySQL.Async.insert("INSERT INTO `character_keys` (`identifier`, `owner_id`, `holder_id`, `given`, `stolen`, `job`, `type`) VALUES (@ident, @owner, @owner, 0, @stolen, @job, @type)", {
            ['@ident'] = identifier,
            ['@owner'] = _char.getCID(),
            ['@stolen'] = stolen,
            ['@job'] = job,
            ['@type'] = keytype
        }, function(keyCreated)
            if keyCreated > 0 then
                if notify then
                    if keytype == "Vehicle" then
                        TriggerClientEvent('pw:notification:SendAlert', _char.getSource(), {type = "inform", text = "You have received keys for the vehicle with plate "..identifier, length = 5000})
                    elseif keytype == "Property" then
                        TriggerClientEvent('pw:notification:SendAlert', _char.getSource(), {type = "inform", text = "You have received keys for the property "..identifier, length = 5000})
                    elseif keytype == "Unit" then
                        TriggerClientEvent('pw:notification:SendAlert', _char.getSource(), {type = "inform", text = "You have received keys for the garage unit "..identifier, length = 5000})
                    end
                end
            end
        end)
    end
end)

RegisterServerEvent('pw_keys:giveKey')
AddEventHandler('pw_keys:giveKey', function(keytype, identifier, target)
    local _src = source
    local _target = target
    local _ident = identifier
    local _type = keytype

    if _type ~= nil and _ident ~= nil and _target ~= nil and _src ~= nil then
        local _srcPlayer = exports.pw_core:getCharacter(_src)
        local _tgtPlayer = exports.pw_core:getCharacter(_target)

        local checkOwnerShip = MySQL.Sync.fetchAll("SELECT * FROM `character_keys` WHERE `owner_id` = @scid AND `type` = @type AND `identifier` = @ident", {['@scid'] = _srcPlayer.getCID(), ['@type'] = _type, ['@ident'] = _ident})

        if checkOwnerShip[1] ~= nil then
            if _type == "vehicle" or _type == "Vehicle" then
                MySQL.Async.fetchAll("SELECT * FROM `character_keys` WHERE `identifier` = @ident AND `holder_id` = @tcid AND `owner_id` = @scid AND `type` = 'Vehicle'", {['@ident'] = _ident, ['@tcid'] = _tgtPlayer.getCID(), ['@scid'] = _srcPlayer.getCID()}, function(checkHolder)
                    if checkHolder[1] == nil then
                        TriggerClientEvent('pw:notification:SendAlert', _target, {type = "inform", text = "You have received keys for the vehicle with plate "..identifier, length = 5000})
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "You have given keys to ".._tgtPlayer.getFullName().." for your vehicle with plate "..identifier, length = 5000})
                        MySQL.Sync.insert("INSERT INTO `character_keys` (`identifier`, `owner_id`, `holder_id`, `given`, `stolen`, `job`, `type`) VALUES (@ident, @owner, @holder, 0, @stolen, @job, @type)", {
                            ['@ident'] = identifier,
                            ['@owner'] = _srcPlayer.getCID(),
                            ['@holder'] = _tgtPlayer.getCID(),
                            ['@stolen'] = false,
                            ['@job'] = false,
                            ['@type'] = _type
                        })
                    else
                        TriggerClientEvent('pw:notification:SendAlert', _target, {type = "error", text = "You already have keys for this vehicle.", length = 5000})
                        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = _tgtPlayer.getFullName().." already has keys for this vehicle.", length = 5000})
                    end
                end)
                
            else
                MySQL.Async.fetchAll("SELECT * FROM `character_keys` WHERE `identifier` = @ident AND `holder_id` = @tcid AND `owner_id` = @scid AND `type` = 'Property'", {['@ident'] = _ident, ['@tcid'] = _tgtPlayer.getCID(), ['@scid'] = _srcPlayer.getCID()}, function(checkHolder)
                    MySQL.Async.fetchScalar("SELECT `name` FROM `properties` WHERE `property_id` = @ident", {['@ident'] = _ident}, function(getPropertyName)
                        if checkHolder[1] == nil then
                            TriggerClientEvent('pw:notification:SendAlert', _target, {type = "inform", text = "You have received keys for "..getPropertyName, length = 5000})
                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "You have given keys to ".._tgtPlayer.getFullName().." for "..getPropertyName, length = 5000})
                            MySQL.Async.insert("INSERT INTO `character_keys` (`identifier`, `owner_id`, `holder_id`, `given`, `stolen`, `job`, `type`) VALUES (@ident, @owner, @holder, 0, @stolen, @job, @type)", {
                                ['@ident'] = identifier,
                                ['@owner'] = _srcPlayer.getCID(),
                                ['@holder'] = _tgtPlayer.getCID(),
                                ['@stolen'] = false,
                                ['@job'] = false,
                                ['@type'] = _type
                            }, function() end)
                        else
                            TriggerClientEvent('pw:notification:SendAlert', _target, {type = "error", text = "You already have keys for "..getPropertyName, length = 5000})
                            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = _tgtPlayer.getFullName().." already has keys for "..getPropertyName, length = 5000})
                        end
                    end)
                end)
            end
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You do not have permission to give a key to this person.", length = 5000})
        end
    end
end)

exports.pw_chat:AddChatCommand('givekey', function(source, args, rawCommand)
    local _src = source
    local keyType = args[1]

    if args[1] ~= nil then
        if args[1] == "property" or args[1] == "Property" or args[1] == "PROPERTY" then
            TriggerClientEvent('pw_properties:client:giveKey', _src)
        elseif args[1] == "vehicle" or args[1] == "Vehicle" or args[1] == "VEHICLE" then
            
        else
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "The Type of Key you have specified is not valid please specify either Property or Vehicle.", length = 5000})
        end
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You have not specified which type of key to give.", length = 5000})
    end
end, {
    help = "Give the closest person a key to your house of vehicle.",
    params = {{
        name = "Type",
        help = "Can either be 'property' or 'vehicle' depending which type you are giving"
    }}
}, -1)