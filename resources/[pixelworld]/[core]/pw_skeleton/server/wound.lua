PW = nil
TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

function GetCharsInjuries(src)
    local _char = exports.pw_core:getCharacter(src)
    return _char:Health():getInjuries(), _char:Health().getHealth()
end

PW.RegisterServerCallback('pw_skeleton:server:GetInjuries', function(source, cb)
    local _src = source
    local injuries = {}
    sendInjuries, sendHealth = GetCharsInjuries(_src)
    cb(sendInjuries, (sendHealth or 200))
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