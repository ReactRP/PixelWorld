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