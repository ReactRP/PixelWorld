PW = nil

TriggerEvent('pw:loadFramework', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_lockpick:server:getBobbyPins', function(source, cb)
    local _src = source
    local _character = exports['pw_core']:getCharacter(_src)
    _character:Inventory().getItemCount('bobbypin', function(_bobbyPins)
        _character:Inventory().getItemCount('screwdriver', function(_screwdriver)
            if (_bobbyPins == nil or _bobbyPins == 0) and (_screwdriver == nil or _screwdriver == 0) then
                cb(0, 0)
            else
                cb(_bobbyPins, _screwdriver)
            end    
        end)
    end)
end)

RegisterServerEvent('pw_lockpick:server:removePin')
AddEventHandler('pw_lockpick:server:removePin', function()
    local _src = source
    local _char = exports['pw_core']:getCharacter(_src)
    _char:Inventory():Remove().Single('bobbypin', function(done)
        
    end)
end)