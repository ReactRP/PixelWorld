PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
local currentWeapon = nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            characterLoaded = true
        else
            playerData = data
        end
    else
        if currentWeapon then
            TriggerEvent('pw_weaponmanagement:client:unLoadWeapon', currentWeapon)
        end
        playerData = nil
        characterLoaded = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

RegisterNetEvent('pw_weaponmanagement:client:loadWeapon')
AddEventHandler('pw_weaponmanagement:client:loadWeapon', function(weaponDetails)
    if IsWeaponValid(weaponDetails.WEAPON_HASH) then
        GiveWeaponToPed(GLOBAL_PED, weaponDetails.WEAPON_HASH, 0, false, true)
        SetPedAmmo(GLOBAL_PED, weaponDetails.WEAPON_HASH, weaponDetails.WEAPON_AMMO)
        currentWeapon = weaponDetails
    end
end)

RegisterNetEvent('pw_weaponmanagement:client:unLoadWeapon')
AddEventHandler('pw_weaponmanagement:client:unLoadWeapon', function(weaponDetails)
    if IsWeaponValid(weaponDetails.WEAPON_HASH) then
        if HasPedGotWeapon(GLOBAL_PED, weaponDetails.WEAPON_HASH, 0) then
            if weaponDetails.WEAPON_SERIAL == currentWeapon.WEAPON_SERIAL then
                SetPedAmmo(GLOBAL_PED, weaponDetails.WEAPON_HASH, 0)
                RemoveWeaponFromPed(GLOBAL_PED, weaponDetails.WEAPON_HASH)
                currentWeapon = nil
                print('removed')
            end
        end
    end
end)

