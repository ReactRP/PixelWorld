PW = nil
TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_skeleton:server:GetInjuries', function(source, cb)
    local _char = exports.pw_core:getCharacter(source)
    _char:Health().getInjuries(function(injs)
        _char:Health().getHealth(function(hp)
            cb(injs or {}, hp or 200)
        end)
    end)    
end)

RegisterServerEvent('pw_skeleton:server:SyncInjuries')
AddEventHandler('pw_skeleton:server:SyncInjuries', function(data, hp)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)

    if _char then
        _char:Health().updateInjuries(data)
        _char:Health().updateHealth(hp)
    end
end)