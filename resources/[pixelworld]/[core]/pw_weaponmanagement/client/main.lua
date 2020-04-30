PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
local currentWeapon = nil
local previousAmmo = nil

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
        previousAmmo = weaponDetails.WEAPON_AMMO
        currentWeapon = weaponDetails
        manageWeapon()
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
            end
        end
    end
end)

function CameraForwardVec()
    local rot = (math.pi / 180.0) * GetGameplayCamRot(2)
    return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function Raycast(dist)
    local start = GetGameplayCamCoord()
    local target = start + (CameraForwardVec() * dist)
 
    local ray = StartShapeTestRay(start, target, -1, PlayerPedId(), 1)
    local a, b, c, d, ent = GetShapeTestResult(ray)
    return {
        a = a,
        b = b,
        HitPosition = c,
        HitCoords = d,
        HitEntity = ent
    }
end

function WaterTest()
    local fV, sV = TestVerticalProbeAgainstAllWater(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z, 0, 1.0)
    return fV
 end

function manageWeapon()
    Citizen.CreateThread(function()
        while currentWeapon do
            if currentWeapon.WEAPON_SERIAL then
                local currentAmmo = GetAmmoInPedWeapon(GLOBAL_PED, currentWeapon.WEAPON_HASH)
                if currentAmmo ~= previousAmmo then
                    previousAmmo = currentAmmo
                    --if playerData.job ~= "police" or (playerData.job.name == "police" and not playerData.job.duty) then 
                        local a = Raycast(150.0)
                        if a.HitPosition then
                            local weaponFiredInformation
                            if IsEntityAVehicle(a.HitEntity) and math.random(4) > 1 then
                                local r, g, b = GetVehicleColor(a.HitEntity)
                                weaponFiredInformation = { 
                                    ['weaponTypeGroup'] = GetWeapontypeGroup(GetSelectedPedWeapon(GLOBAL_PED)), 
                                    ['pedWeapon'] = GetSelectedPedWeapon(GLOBAL_PED), 
                                    ['evidenceType'] = "vehiclefragment", 
                                    ['other'] = currentWeapon, 
                                    ['hitCoords'] = {['x'] = a.HitPosition.x, ['y'] = a.HitPosition.y, ['z'] = a.HitPosition.z }, 
                                    ['hitEntity'] = { ['type'] = "vehicle", ['entity'] = a.HitEntity, ['r'] = r, ['g'] = g, ['b'] = b, ['class'] = GetVehicleClass(a.HitEntity) },
                                    ['meta'] = { ['hit'] = "Vehicle", ['color'] = {['r'] = r, ['g'] = g, ['b'] = b}, ['entity'] = a.HitEntity, ['serial'] = currentWeapon.WEAPON_SERIAL, ['plate'] = GetVehicleNumberPlateText(a.HitEntity) },
                                    ['shooterCid'] = playerData.cid, 
                                    ['zone'] = GetNameOfZone(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z), 
                                    ['zoneid'] = GetZoneAtCoords(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z)  }
                                TriggerServerEvent('pw_evidence:server:registerProjectile', weaponFiredInformation)
                            elseif IsEntityAPed(a.HitEntity) and IsPedAPlayer(a.HitEntity) and math.random(4) > 1 then
                                print('meg?')
                                PW.GetPlayerData(a.HitEntity, function(data)
                                    PW.Print(data)
                                    weaponFiredInformation = { 
                                        ['weaponTypeGroup'] = GetWeapontypeGroup(GetSelectedPedWeapon(GLOBAL_PED)), 
                                        ['pedWeapon'] = GetSelectedPedWeapon(GLOBAL_PED), 
                                        ['evidenceType'] = "dna", 
                                        ['other'] = currentWeapon, 
                                        ['hitCoords'] = {['x'] = a.HitPosition.x, ['y'] = a.HitPosition.y, ['z'] = a.HitPosition.z }, 
                                        ['hitEntity'] = { ['type'] = "ped", ['entity'] = a.HitEntity },
                                        ['meta'] = { ['hit'] = "Ped", ['entity'] = a.HitEntity, ['serial'] = currentWeapon.WEAPON_SERIAL, ['player'] = data },
                                        ['shooterCid'] = playerData.cid, 
                                        ['zone'] = GetNameOfZone(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z), 
                                        ['zoneid'] = GetZoneAtCoords(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z)  }
                                    TriggerServerEvent('pw_evidence:server:registerProjectile', weaponFiredInformation)
                                end)
                            else
                                weaponFiredInformation = { 
                                    ['weaponTypeGroup'] = GetWeapontypeGroup(GetSelectedPedWeapon(GLOBAL_PED)), 
                                    ['pedWeapon'] = GetSelectedPedWeapon(GLOBAL_PED), 
                                    ['evidenceType'] = "projectile", 
                                    ['other'] = currentWeapon, 
                                    ['hitCoords'] = {['x'] = a.HitPosition.x, ['y'] = a.HitPosition.y, ['z'] = a.HitPosition.z }, 
                                    ['meta'] = { ['hit'] = "Strayed", ['entity'] = a.HitEntity, ['serial'] = currentWeapon.WEAPON_SERIAL },
                                    ['shooterCid'] = playerData.cid,
                                    ['zone'] = GetNameOfZone(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z), 
                                    ['zoneid'] = GetZoneAtCoords(GLOBAL_COORDS.x, GLOBAL_COORDS.y, GLOBAL_COORDS.z) }
                                TriggerServerEvent('pw_evidence:server:registerProjectile', weaponFiredInformation)
                            end
                        --end
                    end
                    TriggerServerEvent('pw_weaponmanagement:server:updateAmmoCount', currentWeapon.WEAPON_SERIAL)
                end
            end
            Citizen.Wait(20)
        end
    end)
end

exports('retreiveWeaponByHash', function(hash)
	return retreiveWeaponByHash(hash)
end)