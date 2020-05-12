RegisterServerEvent('pw_core:client:admin:saveCoordsLocation')
AddEventHandler('pw_core:client:admin:saveCoordsLocation', function(data)
    local _src = source

    if Characters[_src] then
        local _cid = Characters[_src].getCID()
        MySQL.Async.insert("INSERT INTO `character_spawns` (`name`,`x`,`y`,`z`,`h`,`cid`,`global`) VALUES (@name, @x, @y, @z, @h, @cid, @global)", {
            ['@name'] = data['Spawn Name'].value,
            ['@x'] = data.coords.data.x,
            ['@y'] = data.coords.data.y,
            ['@z'] = data.coords.data.z,
            ['@h'] = data.coords.data.h,
            ['@cid'] = _cid,
            ['@global'] = data.global_pos.value,
        }, function(done)
            if done > 0 then
                -- ?
            end
        end)
    end
end)

PW.RegisterServerCallback('pw_core:server:admin:getTeleports', function(source, cb)
    local _src = source
    if Characters[_src] then
        Characters[_src].getSpawns(function(spawnsLocs)
            cb(spawnsLocs)
        end)
    end
end)

PW.RegisterServerCallback('pw_core:server:admin:getActiveCharacters', function(source, cb)
    local Chars = {}
    for k, v in pairs(Characters) do
        table.insert(Chars, {['source'] = v:getSource(), ['cid'] = v:getCID(), ['name'] = v:getFullName(), ['steam'] = v:getSteam()})
    end
    cb(Chars, recentPlayerDisconnects)
end)

RegisterServerEvent('pw_core:admin:loadPlayerMenu')
AddEventHandler('pw_core:admin:loadPlayerMenu', function(data)
    local _src = source
    local _plySrc = tonumber(data.source)
    if _src and _plySrc and Characters[_plySrc] then
        local plyPed = GetPlayerPed(_plySrc)
        local plyCoords = GetEntityCoords(plyPed)
        local plyH = GetEntityHeading(plyPed)
        plyCoords = { ['x'] = plyCoords.x, ['y'] = plyCoords.y, ['z'] = plyCoords.z, ['h'] = plyH}

        local sendData = {
            ['ped'] = plyPed,
            ['coords'] = plyCoords,
            ['source'] = tonumber(data.source),
            ['name'] = data.name,
            ['cid'] = tonumber(data.cid),
            ['job'] = Characters[_plySrc]:Job().getJob(),
            ['gang'] = Characters[_plySrc]:Gang().getGang(),
            ['steam'] = Characters[_plySrc].getSteam(),
            ['injuries'] = Characters[_plySrc]:Health().getInjuries(),
            ['properties'] = Characters[_plySrc]:Properties().myProperties(),
            ['currenct'] = { ['cash'] = Characters[_plySrc]:Cash().getBalance(), ['bank'] = Characters[_plySrc]:Bank().getBalance()}
        }
        TriggerClientEvent('pw_core:admin:loadPlayerMenu', _src, sendData)
    end
end)

RegisterServerEvent('pw_core:client:admin:bringPlayer')
AddEventHandler('pw_core:client:admin:bringPlayer', function(data)
    if data and Characters[tonumber(data.source)] then
        TriggerClientEvent('pw_core:client:admin:gotoPlayer', tonumber(data.source), data.coords)
    end
end)

RegisterServerEvent('pw_core:server:admin:dropPlayer')
AddEventHandler('pw_core:server:admin:dropPlayer', function(src)
    if Users[src] then
        if not Users[src].getOwnerState() and not Users[src].getDeveloperState() then
            PW.doAdminLog(source, "User Kicked from Server", {['playerSrc'] = src, ['name'] = Characters[src].getFullName(), ['steam'] = Characters[src].getSteam(), ['cid'] = Characters[src].getCID()}, true)
            DropPlayer(tonumber(src), "You have been kicked from the PixelWorld Server by an administrator.")
        end
    end
end)

RegisterServerEvent('pw_core:server:admin:banPlayer')
AddEventHandler('pw_core:server:admin:banPlayer', function(data)
    if Users[tonumber(data.source)] then
        if not Users[tonumber(data.source)].getOwnerState() and not Users[tonumber(data.source)].getDeveloperState() then
            PW.doAdminLog(source, "User Kicked from Server", {['playerSrc'] = tonumber(data.source), ['name'] = Characters[tonumber(data.source)].getFullName(), ['steam'] = Characters[tonumber(data.source)].getSteam(), ['cid'] = Characters[tonumber(data.source)].getCID()}, true)
            DropPlayer(tonumber(data.source), "You have been banned from the PixelWorld Server by an administrator.")
            -- do other ban related stuff for the player here.
        end
    end
end)

RegisterServerEvent('pw_core:server:admin:cloakSelf')
AddEventHandler('pw_core:server:admin:cloakSelf', function()
    local _src = source
    local cloaked = false
    if cloakedPlayerList[_src] == nil then
        cloakedPlayerList[_src] = true
        TriggerClientEvent('pw_core:client:admin:updateCloakedPlayer', -1, _src, true)

        cloaked = true
        PW.doAdminLog(_src, "Admin Cloaked", {}, false)
        
    elseif cloakedPlayerList[_src] then
        TriggerClientEvent('pw_core:client:admin:updateCloakedPlayer', -1, _src, false)
        cloakedPlayerList[_src] = nil

        cloaked = false
    end
    TriggerClientEvent('pw_core:client:admin:toggleCloak', _src, cloaked)
end)