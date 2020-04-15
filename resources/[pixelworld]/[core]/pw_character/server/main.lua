PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

RegisterServerEvent('pw_character:server:exitCharCreator')
AddEventHandler('pw_character:server:exitCharCreator', function(data)
    if data ~= nil then
        local _src = source
        local _char = exports['pw_core']:getCharacter(source)
        _char.toggleNewCharacter()
        TriggerEvent('pw_character:server:initialCharSave', _src, data, 'Default')
        TriggerClientEvent('pw_character:client:completedCharCreation', _src)
    end
end)

RegisterServerEvent('pw_character:server:initialCharSave')
AddEventHandler('pw_character:server:initialCharSave', function(source, data, name)
    local _char = exports['pw_core']:getCharacter(source)
    local _cid = _char.getCID()
    local _steam = _char.getSteam()
    if data ~= nil and name ~= nil then
        local skin = {
            ['hair1'] = data.drawables[2],
            ['hair2'] = data.drawtextures[3],
            ['hairColor'] = data.hairColor,
            ['headOverlay'] = data.headOverlay,
            ['headStructure'] = data.headStructure,
            ['headBlend'] = data.headBlend,
        }

        local updatedSkin = json.encode(skin)

        MySQL.Async.execute("UPDATE `characters` SET `skin` = @skin WHERE `steam` = @steam AND `cid` = @cid", {['@skin'] = updatedSkin, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
            if updated > 0 then
                print('Set Initial Character Skin')
            end
        end)

        local outfit = {
            ['model'] = data.model,
            ['drawables'] = data.drawables,
            ['drawtextures'] = data.drawtextures,
            ['props'] = data.props,
            ['proptextures'] = data.proptextures,
        }

        local newOutfit = json.encode(outfit)

        MySQL.Async.insert("INSERT INTO `character_outfits` (`cid`,`name`,`data`) VALUES (@cid, @name, @data)", {['@cid'] = _cid, ['@name'] = name, ['@data'] = newOutfit}, function(outfitId)
            if outfitId > 0 then
                MySQL.Async.execute("UPDATE `characters` SET `cur_outfit` = @cur_outfit WHERE `steam` = @steam AND `cid` = @cid", {['@cur_outfit'] = outfitId, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
                    if updated > 0 then
                        _char.setLastOutfit(outfitId)
                    end
                end)
            end
        end)
    end
end)

PW.RegisterServerCallback('pw_character:server:updateSkinData', function(source, cb, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _cid = _char.getCID()
    local _steam = _char.getSteam()
    skin = {
        ['hair1'] = data.drawables[2],
        ['hair2'] = data.drawtextures[3],
        ['hairColor'] = data.hairColor,
        ['headOverlay'] = data.headOverlay,
        ['headStructure'] = data.headStructure,
        ['headBlend'] = data.headBlend,
    }

    local updatedSkin = json.encode(skin)

    MySQL.Async.execute("UPDATE `characters` SET `skin` = @skin WHERE `steam` = @steam AND `cid` = @cid", {['@skin'] = updatedSkin, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
        if updated > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_character:server:saveNewOutfit', function(source, cb, data, name)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _cid = _char.getCID()
    local _steam = _char.getSteam()
    local outfit = {
        ['model'] = data.model,
        ['drawables'] = data.drawables,
        ['drawtextures'] = data.drawtextures,
        ['props'] = data.props,
        ['proptextures'] = data.proptextures,
    }

    local newOutfit = json.encode(outfit)

    MySQL.Async.fetchAll("SELECT * FROM `character_outfits` WHERE `cid` = @cid", {['@cid'] = _cid}, function(outfitAmount)
        local total = #outfitAmount
        if total < 10 then
            MySQL.Async.insert("INSERT INTO `character_outfits` (`cid`,`name`,`data`) VALUES (@cid, @name, @data)", {['@cid'] = _cid, ['@name'] = name, ['@data'] = newOutfit}, function(outfitId)
                if outfitId > 0 then
                    MySQL.Async.execute("UPDATE `characters` SET `cur_outfit` = @cur_outfit WHERE `steam` = @steam AND `cid` = @cid", {['@cur_outfit'] = outfitId, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
                        if updated > 0 then
                            _char.setLastOutfit(outfitId)
                            cb(true, total)
                        else
                            cb(false, total)
                        end
                    end)
                else
                    cb(false, total)
                end
            end)
        else
            cb(false, total)
        end
    end)
end)

PW.RegisterServerCallback('pw_character:server:replaceCurrentOutfit', function(source, cb, data)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _cid = _char.getCID()
    local _currentOutfit = _char.getLastOutfit()
    local outfit = {
        ['model'] = data.model,
        ['drawables'] = data.drawables,
        ['drawtextures'] = data.drawtextures,
        ['props'] = data.props,
        ['proptextures'] = data.proptextures,
    }

    local newOutfit = json.encode(outfit)

    MySQL.Async.execute("UPDATE `character_outfits` SET `data` = @data WHERE `outfit_id` = @outfit_id AND `cid` = @cid", {['@outfit_id'] = _currentOutfit, ['@cid'] = _cid, ['@data'] = newOutfit}, function(updated)
        if updated > 0 then
            cb(true)
        else
            cb(false)
        end
    end)
end)

PW.RegisterServerCallback('pw_character:server:updateTattoos', function(source, cb, tattoos)
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    local _cid = _char.getCID()
    if tattoos ~= nil then

        local newTattoos = json.encode(tattoos)

        MySQL.Async.execute("UPDATE `characters` SET `tattoos` = @tattoos WHERE `cid` = @cid", {['@tattoos'] = newTattoos, ['@cid'] = _cid}, function(updated)
            if updated > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    else
        cb(false)
    end
end)

PW.RegisterServerCallback('pw_character:server:getTattooData', function(source, cb)
    local _char = exports['pw_core']:getCharacter(source)
    local _cid = _char.getCID()
    local TattooData = MySQL.Sync.fetchScalar("SELECT `tattoos` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
    local charTattoos = nil
    if TattooData ~= nil then
        charTattoos = json.decode(TattooData)
    end
    cb(charTattoos)
end)


PW.RegisterServerCallback('pw_character:server:getCharSkin', function(source, cb)
    local _char = exports['pw_core']:getCharacter(source)
    local _cid = _char.getCID()
    local _steam = _char.getSteam()
    local _lastout = _char.getLastOutfit()
    local outfitData = MySQL.Sync.fetchScalar("SELECT `data` FROM `character_outfits` WHERE `outfit_id` = @id", {['@id'] = _lastout})
    local SkinData = MySQL.Sync.fetchScalar("SELECT `skin` FROM `characters` WHERE `steam` = @steam AND `cid` = @cid", {['@steam'] = _steam, ['@cid'] = _cid})
    local TattooData = MySQL.Sync.fetchScalar("SELECT `tattoos` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
    if outfitData ~= nil and SkinData ~= nil then
        local newOutfitData = json.decode(outfitData)
        local newSkinData = json.decode(SkinData)
        local charTattoos = nil
        if TattooData ~= nil then
            charTattoos = json.decode(TattooData)
        end

        local actualSkin = {
            ['model'] = tonumber(newOutfitData.model),
            ['drawables'] = newOutfitData.drawables,
            ['drawtextures'] = newOutfitData.drawtextures,
            ['props'] = newOutfitData.props,
            ['proptextures'] = newOutfitData.proptextures,
            ['hairColor'] = newSkinData.hairColor,
            ['headOverlay'] = newSkinData.headOverlay,
            ['headStructure'] = newSkinData.headStructure,
            ['headBlend'] = newSkinData.headBlend,
        }
        actualSkin.drawables["2"] = newSkinData.hair1
        actualSkin.drawtextures[3] = newSkinData.hair2

        cb(actualSkin, charTattoos)
    else
        cb(false)
    end
end)

PW.RegisterServerCallback('pw_character:server:getOutfitData', function(source, cb, outfitId)
    local outfit = tonumber(outfitId)
    if outfit ~= nil then
        local _char = exports['pw_core']:getCharacter(source)
        local _cid = _char.getCID()
        local _steam = _char.getSteam()
        local outfitData = MySQL.Sync.fetchScalar("SELECT `data` FROM `character_outfits` WHERE `outfit_id` = @outfit_id AND `cid` = @cid", {['@outfit_id'] = outfit, ['@cid'] = _cid})
        local SkinData = MySQL.Sync.fetchScalar("SELECT `skin` FROM `characters` WHERE `steam` = @steam AND `cid` = @cid", {['@steam'] = _steam, ['@cid'] = _cid})
        local TattooData = MySQL.Sync.fetchScalar("SELECT `tattoos` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
        if outfitData ~= nil and SkinData ~= nil then
            MySQL.Async.execute("UPDATE `characters` SET `cur_outfit` = @cur_outfit WHERE `steam` = @steam AND `cid` = @cid", {['@cur_outfit'] = outfitId, ['@steam'] = _steam, ['@cid'] = _cid}, function(updated)
                if updated > 0 then
                    _char.setLastOutfit(outfitId)
                end
            end)
            local charTattoos = nil
            if TattooData ~= nil then
                charTattoos = json.decode(TattooData)
            end
            local newOutfitData = json.decode(outfitData)
            local newSkinData = json.decode(SkinData)

            local actualSkin = {
                ['model'] = tonumber(newOutfitData.model),
                ['drawables'] = newOutfitData.drawables,
                ['drawtextures'] = newOutfitData.drawtextures,
                ['props'] = newOutfitData.props,
                ['proptextures'] = newOutfitData.proptextures,
                ['hairColor'] = newSkinData.hairColor,
                ['headOverlay'] = newSkinData.headOverlay,
                ['headStructure'] = newSkinData.headStructure,
                ['headBlend'] = newSkinData.headBlend,
            }
            actualSkin.drawables["2"] = newSkinData.hair1
            actualSkin.drawtextures[3] = newSkinData.hair2

            cb(actualSkin, charTattoos)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

PW.RegisterServerCallback('pw_character:server:getCharactersOutfits', function(source, cb)
    local _char = exports['pw_core']:getCharacter(source)
    local _cid = _char.getCID()
    local characterOutfits = MySQL.Sync.fetchAll("SELECT * FROM `character_outfits` WHERE `cid` = @cid", { ['@cid'] = _cid})
    cb(characterOutfits)
end)

RegisterServerEvent('pw_character:server:deleteCharacterOutfit')
AddEventHandler('pw_character:server:deleteCharacterOutfit', function(outfitData)
    local _src = source
    local _char = exports['pw_core']:getCharacter(source)
    local _cid = _char.getCID()
    local _steam = _char.getSteam()
    local _curout = _char.getLastOutfit()
    if (outfitData.outfit ~= nil) and (outfitData.outfit ~= _curout) then
        MySQL.Async.fetchScalar("SELECT COUNT(*) FROM `character_outfits` WHERE `cid` = @cid", {['@cid'] = _cid}, function(tot)
            if tot > 1 then
                MySQL.Async.execute("DELETE FROM `character_outfits` WHERE `cid` = @cid AND `outfit_id` = @oid", {['@cid'] = _cid, ['@oid'] = outfitData.outfit}, function()
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Deleted Outfit: ' .. outfitData.outfitName, length = 5000})
                end)
            end
        end)
    else
        TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'error', text = 'You can\'t delete the outfit you are currently wearing!', length = 5000})
    end
end)

PW.RegisterServerCallback('pw_character:server:doesCharHaveEnoughMoney', function(source, cb)
    local _src = source
    local _char = exports['pw_core']:getCharacter(source)
    cb(_char:Cash().getBalance())
end)

RegisterServerEvent('pw_character:server:payForMenu')
AddEventHandler('pw_character:server:payForMenu', function(menutype, purchaseName)
    local _src = source
    if menutype ~= nil and purchaseName ~= nil then
        local _char = exports['pw_core']:getCharacter(_src)
        local amount = Config.Costs[menutype]
        if amount ~= nil then
            _char:Cash().removeCash(amount)
            TriggerClientEvent('pw:notification:SendAlert', _src, {type = 'success', text = 'Paid $' .. amount .. ' for ' .. purchaseName .. '.', length = 2500})
        end
    end
end)


exports.pw_chat:AddChatCommand('toggleclothes', function(source, args, rawCommand)
    local _src = source
    TriggerClientEvent('pw_character:client:characterAccessoryMenu', _src)
end, {
    help = "Toggle Your Clothing Items",
}, -1)


