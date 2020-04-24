local currentlyEquip = {}

RegisterServerEvent('pw_weaponmanagement:server:loadWeapon')
AddEventHandler('pw_weaponmanagement:server:loadWeapon', function(src, clientInfo)
    local _src = src
    if not currentlyEquip[_src] then
        currentlyEquip[_src] = true
        print('loading?')
        TriggerClientEvent('pw_weaponmanagement:client:loadWeapon', _src, clientInfo)
    else
        currentlyEquip[_src] = nil
        print('uloading?')
        TriggerClientEvent('pw_weaponmanagement:client:unLoadWeapon', _src, clientInfo)
    end
end)