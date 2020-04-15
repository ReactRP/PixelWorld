local isBleeding, bleedTickTimer, advanceBleedTimer, fadeOutTimer, blackoutTimer = 0, 0, 0, 0, 0

local onPainKiller, wasOnPainKillers = 0, false
local onDrugs, wasOnDrugs = 0, false

local legCount, armcount, headCount = 0, 0, 0

local playerHealth, playerArmour = nil, nil

local limbNotifId = 'MHOS_LIMBS'
local bleedNotifId = 'MHOS_BLEED'
local bleedMoveNotifId = 'MHOS_BLEEDMOVE'

local BodyParts, injured = {}, {}

PW = nil 

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

function TerminatePersistentNotifications()
    exports['pw_notify']:PersistentAlert('end', limbNotifId)
    exports['pw_notify']:PersistentAlert('end', bleedNotifId)
    exports['pw_notify']:PersistentAlert('end', bleedMoveNotifId)
end

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            PW.TriggerServerCallback('pw_skeleton:server:GetInjuries', function(inj, hp)
                TriggerEvent('pw_skeleton:client:LoadInjuries', inj)
                SetEntityHealth(PlayerPedId(), hp)
                playerLoaded = true
            end)
        else
            if Config.DisableAutoRespawn then
                exports.spawnmanager:setAutoSpawn(false)
            end
            playerData = data
        end
    else
        TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        }, GetEntityHealth(PlayerPedId()))   
        TerminatePersistentNotifications()
        playerData = nil
        playerLoaded = false
    end
end)

RegisterNetEvent('pw:switchCharacter')
AddEventHandler('pw:switchCharacter', function()
    TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    }, GetEntityHealth(PlayerPedId()))
    TerminatePersistentNotifications()
end)

RegisterNetEvent('pw_skeleton:client:LoadInjuries')
AddEventHandler('pw_skeleton:client:LoadInjuries', function(table)
    if table.limbs ~= nil and table.limbs['HEAD'] ~= nil then
        TriggerEvent('pw_skeleton:client:SyncLimbs', table.limbs)
        TriggerEvent('pw_skeleton:client:SyncBleed', tonumber(table.isBleeding))
    else
        BodyParts = {
            ['HEAD'] =          { label = 'Head', causeLimp = false, isDamaged = false, severity = 0 },
            ['NECK'] =          { label = 'Neck', causeLimp = false, isDamaged = false, severity = 0 },
            ['SPINE'] =         { label = 'Spine', causeLimp = true, isDamaged = false, severity = 0 },
            ['UPPER_BODY'] =    { label = 'Upper Body', causeLimp = false, isDamaged = false, severity = 0 },
            ['LOWER_BODY'] =    { label = 'Lower Body', causeLimp = true, isDamaged = false, severity = 0 },
            ['LARM'] =          { label = 'Left Arm', causeLimp = false, isDamaged = false, severity = 0 },
            ['LHAND'] =         { label = 'Left Hand', causeLimp = false, isDamaged = false, severity = 0 },
            ['LFINGER'] =       { label = 'Left Hand Fingers', causeLimp = false, isDamaged = false, severity = 0 },
            ['LLEG'] =          { label = 'Left Leg', causeLimp = true, isDamaged = false, severity = 0 },
            ['LFOOT'] =         { label = 'Left Foot', causeLimp = true, isDamaged = false, severity = 0 },
            ['RARM'] =          { label = 'Right Arm', causeLimp = false, isDamaged = false, severity = 0 },
            ['RHAND'] =         { label = 'Right Hand', causeLimp = false, isDamaged = false, severity = 0 },
            ['RFINGER'] =       { label = 'Right Hand Fingers', causeLimp = false, isDamaged = false, severity = 0 },
            ['RLEG'] =          { label = 'Right Leg', causeLimp = true, isDamaged = false, severity = 0 },
            ['RFOOT'] =         { label = 'Right Foot', causeLimp = true, isDamaged = false, severity = 0 },
        }
        TriggerEvent('pw_skeleton:client:SyncLimbs', BodyParts)
        TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        }, GetEntityHealth(PlayerPedId()))
    end
end)

function IsInjuryCausingLimp()
    for k, v in pairs(BodyParts) do
        if v.causeLimp and v.isDamaged then
            return true
        end
    end

    return false
end

exports('IsInjuryCausingLimp', function()
    return IsInjuryCausingLimp()
end)

function IsInjuredOrBleeding()
    if isBleeding > 0 then
        return true
    else
        for k, v in pairs(BodyParts) do
            if v.isDamaged then
                return true
            end
        end
    end

    return false
end

exports('IsInjuredOrBleeding', function()
    return IsInjuredOrBleeding()
end)

function GetDamagingWeapon(ped)
    for k, v in pairs(Config.Weapons) do
        if HasPedBeenDamagedByWeapon(ped, k, 0) then
            ClearEntityLastDamageEntity(ped)
            return v
        end
    end

    return nil
end

function ProcessRunStuff(ped)
    if IsInjuryCausingLimp() and not (onPainKiller > 0)  then
        RequestAnimSet("move_m@injured")
        while not HasAnimSetLoaded("move_m@injured") do
            Citizen.Wait(1)
        end
        SetPedMovementClipset(ped, "move_m@injured", 1 )
        SetPlayerSprint(PlayerId(), false)

        if wasOnPainKillers then
            SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
            wasOnPainKillers = false
            exports['pw_notify']:SendAlert('inform', 'You\'ve realized doing drugs does not fix all your problems', 5000, { ['background-color'] = '#760036' })
        end
    else
        SetPedMoveRateOverride(ped, 1.0)
        ResetPedMovementClipset(ped, 1.0)

        if not wasOnPainKillers and (onPainKiller > 0) then wasOnPainKillers = true end

        if onPainKiller > 0 then
            onPainKiller = onPainKiller - 1
        end
    end
end

exports('runStuff', function()
    ProcessRunStuff(PlayerPedId())
end)

function ProcessDamage(ped)
    if not IsEntityDead(ped) or not (onDrugs > 0) then
        for k, v in pairs(injured) do
            if (v.part == 'LLEG' and v.severity > 1) or (v.part == 'RLEG' and v.severity > 1) or (v.part == 'LFOOT' and v.severity > 2) or (v.part == 'RFOOT' and v.severity > 2) then
                if legCount >= Config.LegInjuryTimer then
                    if not IsPedRagdoll(ped) and IsPedOnFoot(ped) then
                        local chance = math.random(100)
                        if (IsPedRunning(ped) or IsPedSprinting(ped)) then
                            if chance <= Config.LegInjuryChance.Running then
                                exports['pw_notify']:SendAlert('inform', 'You\'re Having A Hard Time Running', 5000, { ['background-color'] = '#760036' })
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                SetPedToRagdollWithFall(ped, 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        else
                            if chance <= Config.LegInjuryChance.Walking then
                                exports['pw_notify']:SendAlert('inform', 'You\'re Having A Hard Using Your Legs', 5000, { ['background-color'] = '#760036' })
                                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                SetPedToRagdollWithFall(ped, 1500, 2000, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                            end
                        end
                    end
                    legCount = 0
                else
                    legCount = legCount + 1
                end
            elseif (v.part == 'LARM' and v.severity > 1) or (v.part == 'LHAND' and v.severity > 1) or (v.part == 'LFINGER' and v.severity > 2) or (v.part == 'RARM' and v.severity > 1) or (v.part == 'RHAND' and v.severity > 1) or (v.part == 'RFINGER' and v.severity > 2) then
                if armcount >= Config.ArmInjuryTimer then
                    local chance = math.random(100)

                    if (v.part == 'LARM' and v.severity > 1) or (v.part == 'LHAND' and v.severity > 1) or (v.part == 'LFINGER' and v.severity > 2) then
                        local isDisabled = 15
                        Citizen.CreateThread(function()
                            while isDisabled > 0 do
                                if IsPedInAnyVehicle(ped, true) then
                                    DisableControlAction(0, 63, true) -- veh turn left
                                end

                                if IsPlayerFreeAiming(PlayerId()) then
                                    DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
                                end

                                isDisabled = isDisabled - 1
                                Citizen.Wait(1)
                            end
                        end)
                    else
                        local isDisabled = 15
                        Citizen.CreateThread(function()
                            while isDisabled > 0 do
                                if IsPedInAnyVehicle(ped, true) then
                                    DisableControlAction(0, 63, true) -- veh turn left
                                end

                                if IsPlayerFreeAiming(PlayerId()) then
                                    DisableControlAction(0, 25, true) -- Disable weapon firing
                                end

                                isDisabled = isDisabled - 1
                                Citizen.Wait(1)
                            end
                        end)
                    end

                    armcount = 0
                else
                    armcount = armcount + 1
                end
            elseif (v.part == 'HEAD' and v.severity > 2) then
                if headCount >= Config.HeadInjuryTimer then
                    local chance = math.random(100)

                    if chance <= Config.HeadInjuryChance then
                        exports['pw_notify']:SendAlert('inform', 'You Suddenly Black Out', 5000, { ['background-color'] = '#760036' })
                        SetFlash(0, 0, 100, 10000, 100)

                        DoScreenFadeOut(100)
                        while not IsScreenFadedOut() do
                            Citizen.Wait(1)
                        end

                        if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                            SetPedToRagdoll(ped, 5000, 1, 2)
                        end

                        Citizen.Wait(5000)
                        DoScreenFadeIn(250)
                    end
                    headCount = 0
                else
                    headCount = headCount + 1
                end
            end
        end

        if wasOnDrugs then
            SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
            wasOnDrugs = false
            exports['pw_notify']:SendAlert('inform', 'You\'ve Realized Doing Drugs Does Not Fix All Your Problems', 5000, { ['background-color'] = '#760036' })
        end
    else
        onDrugs = onDrugs - 1

        if not wasOnDrugs then
            wasOnDrugs = true
        end
    end
end

function CheckDamage(ped, bone, weapon)
    if weapon == nil then return end

    if Config.Bones[bone] ~= nil then
        if BodyParts[Config.Bones[bone]] ~= nil and not BodyParts[Config.Bones[bone]].isDamaged then
            BodyParts[Config.Bones[bone]].isDamaged = true
            BodyParts[Config.Bones[bone]].severity = 1
            --exports['pw_notify']:SendAlert('inform', 'Your ' .. BodyParts[Config.Bones[bone]].label .. ' feels ' .. Config.WoundStates[BodyParts[Config.Bones[bone]].severity], { ['background-color'] = '#760036' })
            if weapon == Config.WeaponClasses['SMALL_CALIBER'] or weapon == Config.WeaponClasses['MEDIUM_CALIBER'] or weapon == Config.WeaponClasses['CUTTING'] or weapon == Config.WeaponClasses['WILDLIFE'] or weapon == Config.WeaponClasses['OTHER'] or weapon == Config.WeaponClasses['LIGHT_IMPACT'] then
                if (Config.Bones[bone] == 'UPPER_BODY' or Config.Bones[bone] == 'LOWER_BODY' or Config.Bones[bone] == 'SPINE') and (weapon == Config.WeaponClasses['SMALL_CALIBER'] or weapon == Config.WeaponClasses['MEDIUM_CALIBER']) then
                    if GetPedArmour(ped) > 0 then
                        local chance = math.random(100)
                        if chance <= math.ceil(Config.BodyArmorStaggerChance / 2) then
                            SetPedToRagdoll(ped, 1500, 2000, 2, true, true, false)
                        end
                    else
                        if Config.Bones[bone] == 'SPINE' then
                            SetPedToRagdoll(ped, 1500, 2000, 2, true, true, false)
                        end

                        ApplyBleed(1)
                    end
                end
            elseif weapon == Config.WeaponClasses['HIGH_CALIBER'] or weapon == Config.WeaponClasses['HEAVY_IMPACT'] or weapon == Config.WeaponClasses['SHOTGUN'] or weapon == Config.WeaponClasses['EXPLOSIVE'] then
                if (Config.Bones[bone] == 'UPPER_BODY' or Config.Bones[bone] == 'LOWER_BODY' or Config.Bones[bone] == 'SPINE') and (weapon == Config.WeaponClasses['HIGH_CALIBER'] or weapon == Config.WeaponClasses['SHOTGUN']) then
                    if GetPedArmour(ped) > 0 then
                        local chance = math.random(100)
                        if chance <= math.ceil(Config.BodyArmorStaggerChance) then
                            SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
                        end

                        if isBleeding < 1 then
                            local chance = math.random(100)
                            if chance <= math.ceil(Config.AmorHighCalBleedChance) then
                                ApplyBleed(1)
                            end
                        end
                    else
                        if Config.Bones[bone] == 'SPINE' then
                            SetPedToRagdoll(ped, 1500, 2000, 3, true, true, false)
                        end
                        ApplyBleed(2)
                    end
                else
                    ApplyBleed(1)
                end
            end

            table.insert(injured, {
                part = Config.Bones[bone],
                label = BodyParts[Config.Bones[bone]].label,
                severity = BodyParts[Config.Bones[bone]].severity
            })

            TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
                limbs = BodyParts,
                isBleeding = tonumber(isBleeding)
            }, GetEntityHealth(PlayerPedId()))

            ProcessRunStuff(ped)
            DoLimbAlert()
            DoBleedAlert()
        else
            if weapon == Config.WeaponClasses['SMALL_CALIBER'] or weapon == Config.WeaponClasses['MEDIUM_CALIBER'] or weapon == Config.WeaponClasses['CUTTING'] or weapon == Config.WeaponClasses['WILDLIFE'] or weapon == Config.WeaponClasses['OTHER'] or weapon == Config.WeaponClasses['LIGHT_IMPACT'] then
                if (Config.Bones[bone] == 'UPPER_BODY' or Config.Bones[bone] == 'LOWER_BODY' or Config.Bones[bone] == 'SPINE') and (weapon == Config.WeaponClasses['SMALL_CALIBER'] or weapon == Config.WeaponClasses['MEDIUM_CALIBER']) then
                    if GetPedArmour(ped) > 0 then
                        local chance = math.random(100)
                        if chance <= math.ceil(Config.BodyArmorStaggerChance / 2) then
                            SetPedToRagdoll(ped, 1500, 2000, 2, true, true, false)
                        end
                    else
                        if Config.Bones[bone] == 'SPINE' then
                            SetPedToRagdoll(ped, 1500, 2000, 2, true, true, false)
                        end

                        ApplyBleed(1)
                    end
                end
            elseif weapon == Config.WeaponClasses['HIGH_CALIBER'] or weapon == Config.WeaponClasses['HEAVY_IMPACT'] or weapon == Config.WeaponClasses['SHOTGUN'] or weapon == Config.WeaponClasses['EXPLOSIVE'] then
                if (Config.Bones[bone] == 'UPPER_BODY' or Config.Bones[bone] == 'LOWER_BODY' or Config.Bones[bone] == 'SPINE') and (weapon == Config.WeaponClasses['HIGH_CALIBER'] or weapon == Config.WeaponClasses['SHOTGUN']) then
                    if GetPedArmour(ped) > 0 then
                        local chance = math.random(100)
                        if chance <= math.ceil(Config.BodyArmorStaggerChance) then
                            SetPedToRagdoll(playerPed, 1500, 2000, 3, true, true, false)
                        end

                        if isBleeding < 1 then
                            local chance = math.random(100)
                            if chance <= math.ceil(Config.AmorHighCalBleedChance) then
                                ApplyBleed(1)
                            end
                        end
                    else
                        if Config.Bones[bone] == 'SPINE' then
                            SetPedToRagdoll(playerPed, 1500, 2000, 3, true, true, false)
                        end

                        ApplyBleed(2)
                    end
                end
            end

            --if bone ~= nil and Config.Bones[bone] ~= nil and BodyParts[Config.Bones[bone]] ~= nil then
                if BodyParts[Config.Bones[bone]].severity < 4 then
                    BodyParts[Config.Bones[bone]].severity = BodyParts[Config.Bones[bone]].severity + 1
                    TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
                        limbs = BodyParts,
                        isBleeding = tonumber(isBleeding)
                    }, GetEntityHealth(PlayerPedId()))

                    for k, v in pairs(injured) do
                        if v.part == Config.Bones[bone] then
                            v.severity = BodyParts[Config.Bones[bone]].severity
                        end
                    end
                end
            --end

            ProcessRunStuff(ped)
            DoLimbAlert()
            DoBleedAlert()
        end
    else
        print('Bone Not In Index - Report This! - ' .. bone)
    end
end

function ApplyBleed(level)
    if isBleeding ~= 4 then
        if isBleeding + level > 4 then
            isBleeding = 4
        else
            isBleeding = isBleeding + level
        end
        
        DoBleedAlert()
    end
end

function DoLimbAlert()
    local player = PlayerPedId()
    if not IsEntityDead(player) then
        if #injured > 0 then
            local limbDamageMsg = ''
            if #injured > 1 and #injured < 3 then
                for k, v in pairs(injured) do
                    limbDamageMsg = limbDamageMsg .. 'Your ' .. v.label .. ' feels ' .. Config.WoundStates[v.severity]
                    if k < #injured then
                        limbDamageMsg = limbDamageMsg .. ' | '
                    end
                end
            elseif #injured > 2 then
                limbDamageMsg = 'You Feel Multiple Pains'
            else
                limbDamageMsg = 'Your ' .. injured[1].label .. ' feels ' .. Config.WoundStates[injured[1].severity]
            end

            exports['pw_notify']:PersistentAlert('start', limbNotifId, 'inform', limbDamageMsg, { ['background-color'] = '#760036' })
        else
            exports['pw_notify']:PersistentAlert('end', limbNotifId)
        end
    else
        exports['pw_notify']:PersistentAlert('end', limbNotifId)
    end
end

exports('DoLimbAlert', function()
    DoLimbAlert()
end)

function DoBleedAlert()
    local player = PlayerPedId()
    if not IsEntityDead(player) and isBleeding > 0 then
        exports['pw_notify']:PersistentAlert('start', bleedNotifId, 'inform', 'You Have ' .. Config.BleedingStates[isBleeding], { ['background-color'] = '#760036' })
    else
        exports['pw_notify']:PersistentAlert('end', bleedNotifId)
    end
end

exports('DoBleedAlert', function()
    DoBleedAlert()
end)

RegisterNetEvent('pw_skeleton:client:SyncLimbs')
AddEventHandler('pw_skeleton:client:SyncLimbs', function(limbs)
    BodyParts = limbs

	injured = {}
    for k, v in pairs(BodyParts) do
        if v.isDamaged then
            table.insert(injured, {
                part = k,
                label = v.label,
                severity = v.severity
            })
        end
    end

    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
end)

RegisterNetEvent('pw_skeleton:client:SyncBleed')
AddEventHandler('pw_skeleton:client:SyncBleed', function(bleedStatus)
    isBleeding = tonumber(bleedStatus)
    DoBleedAlert()
end)

RegisterNetEvent('pw_skeleton:client:FieldTreatLimbs')
AddEventHandler('pw_skeleton:client:FieldTreatLimbs', function()
    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 1
    end

    
--[[
    for k, v in pairs(injured) do
        if v.part == Config.Bones[bone] then
            v.severity = BodyParts[Config.Bones[bone]]--[[.severity
        end
    end
]]
    TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    }, GetEntityHealth(PlayerPedId()))

    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
end)

RegisterNetEvent('pw_skeleton:client:FieldTreatBleed')
AddEventHandler('pw_skeleton:client:FieldTreatBleed', function()
    if isBleeding > 1 then
        isBleeding = tonumber(isBleeding) - 1

        TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        }, GetEntityHealth(PlayerPedId()))

        ProcessRunStuff(PlayerPedId())
        DoBleedAlert()
    end
end)

RegisterNetEvent('pw_skeleton:client:ReduceBleed')
AddEventHandler('pw_skeleton:client:ReduceBleed', function()
    if isBleeding > 0 then
        isBleeding = tonumber(isBleeding) - 1

        TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
            limbs = BodyParts,
            isBleeding = tonumber(isBleeding)
        }, GetEntityHealth(PlayerPedId()))

        ProcessRunStuff(PlayerPedId())
        DoBleedAlert()
    end
end)


RegisterNetEvent('pw_skeleton:client:ResetLimbs')
AddEventHandler('pw_skeleton:client:ResetLimbs', function()
    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end

    injured = {}

    TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    }, GetEntityHealth(PlayerPedId()))

    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
end)

RegisterNetEvent('pw_skeleton:client:RemoveBleed')
AddEventHandler('pw_skeleton:client:RemoveBleed', function()
    isBleeding = 0

    TriggerServerEvent('pw_skeleton:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    }, GetEntityHealth(PlayerPedId()))

    ProcessRunStuff(PlayerPedId())
    DoBleedAlert()
end)

RegisterNetEvent('pw_skeleton:client:UsePainKiller')
AddEventHandler('pw_skeleton:client:UsePainKiller', function(tier)
    if tier < 10 then
        onPainKiller = 90 * tier
    end

    exports['pw_notify']:SendAlert('inform', 'You feel the pain subside temporarily', 5000)
    ProcessRunStuff(PlayerPedId())
end)

RegisterNetEvent('pw_skeleton:client:UseAdrenaline')
AddEventHandler('pw_skeleton:client:UseAdrenaline', function(tier)
    if tier < 10 then
        onDrugs = 180 * tier
    end

    exports['pw_notify']:SendAlert('inform', 'You\'re Able To Ignore Your Body Failing', 5000)
    ProcessRunStuff(PlayerPedId())
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playerLoaded then
            if #injured > 0 then
                local level = 0
                for k, v in pairs(injured) do
                    if v.severity > level then
                        level = v.severity
                    end
                end

                SetPedMoveRateOverride(PlayerPedId(), Config.MovementRate[level])
                
                Citizen.Wait(5)
            else
                Citizen.Wait(1000)
            end
        end
	end
end)

local prevPos = nil
Citizen.CreateThread(function()
    Citizen.Wait(2500)
    prevPos = GetEntityCoords(PlayerPedId(), true)
    while true do
        Citizen.Wait(1)
        if playerLoaded then
            local player = PlayerPedId()
            if bleedTickTimer >= Config.BleedTickRate then
                if not IsEntityDead(player) then
                    if isBleeding > 0 then
                        if isBleeding == 1 then
                            SetFlash(0, 0, 100, 100, 100)
                        elseif isBleeding == 2 then
                            SetFlash(0, 0, 100, 250, 100)
                        elseif isBleeding == 3 then
                            SetFlash(0, 0, 100, 500, 100)
                            --Function.Call(Hash.SET_FLASH, 0, 0, 100, 500, 100);
                        elseif isBleeding == 4 then
                            SetFlash(0, 0, 100, 500, 100)
                            --Function.Call(Hash.SET_FLASH, 0, 0, 100, 500, 100);
                        end

                        if fadeOutTimer % Config.FadeOutTimer == 0 then
                            if blackoutTimer >= Config.BlackoutTimer then
                                exports['pw_notify']:SendAlert('inform', 'You Suddenly Black Out', 5000)
                                SetFlash(0, 0, 100, 7000, 100)

                                DoScreenFadeOut(500)
                                while not IsScreenFadedOut() do
                                    Citizen.Wait(1)
                                end

                                if not IsPedRagdoll(player) and IsPedOnFoot(player) and not IsPedSwimming(player) then
                                    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.08) -- change this float to increase/decrease camera shake
                                    SetPedToRagdollWithFall(PlayerPedId(), 7500, 9000, 1, GetEntityForwardVector(player), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                                end

                                Citizen.Wait(1500)
                                DoScreenFadeIn(1000)
                                blackoutTimer = 0
                            else
                                DoScreenFadeOut(2000)
                                while not IsScreenFadedOut() do
                                    Citizen.Wait(1)
                                end
                                DoScreenFadeIn(2000)
                                if isBleeding > 3 then
                                    blackoutTimer = blackoutTimer + 2
                                else
                                    blackoutTimer = blackoutTimer + 1
                                end
                                fadeOutTimer = 0
                            end
                        else
                            fadeOutTimer = fadeOutTimer + 1
                        end

                        --exports['pw_notify']:SendAlert('inform', 'You Have ' .. Config.BleedingStates[isBleeding], 25000)
                        local bleedDamage = tonumber(isBleeding) * Config.BleedTickDamage
                        ApplyDamageToPed(player, bleedDamage, false)
                        playerHealth = playerHealth - bleedDamage

                        if advanceBleedTimer >= Config.AdvanceBleedTimer then
                            ApplyBleed(1)
                            advanceBleedTimer = 0
                        else
                            advanceBleedTimer = advanceBleedTimer + 1
                        end

                    end
                end
                bleedTickTimer = 0
            else
                if math.floor(bleedTickTimer % (Config.BleedTickRate / 10)) == 0 then
                    local currPos = GetEntityCoords(player, true)
                    local moving = #(vector2(prevPos.x, prevPos.y) - vector2(currPos.x, currPos.y))
                    if (moving > 1 and not IsPedInAnyVehicle(player)) and isBleeding > 2 then
                        exports['pw_notify']:PersistentAlert('start', bleedMoveNotifId, 'inform', 'You notice blood oozing from your wounds faster when you\'re moving', { ['background-color'] = '#4d0e96' })
                        advanceBleedTimer = advanceBleedTimer + Config.BleedMovementAdvance
                        bleedTickTimer = bleedTickTimer + Config.BleedMovementTick
                        prevPos = currPos
                    else
                        exports['pw_notify']:PersistentAlert('end', bleedMoveNotifId)
                        bleedTickTimer = bleedTickTimer + 1
                    end

                else

                end
                bleedTickTimer = bleedTickTimer + 1
            end

            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playerLoaded then
            local ped = PlayerPedId()
            local health = GetEntityHealth(ped)
            local armor = GetPedArmour(ped)

            if not playerHealth then
                playerHealth = health
            end

            if not playerArmor then
                playerArmor = armor
            end

            local armorDamaged = (playerArmor ~= armor and armor < (playerArmor - Config.ArmorDamage) and armor > 0) -- Players armor was damaged
            local healthDamaged = (playerHealth ~= health and health < (playerHealth - Config.HealthDamage)) -- Players health was damaged

            if armorDamaged or healthDamaged then
                local hit, bone = GetPedLastDamageBone(ped)
                local bodypart = Config.Bones[bone]

                if hit and bodypart ~= 'NONE' then
                    local checkDamage = true
                    local weapon = GetDamagingWeapon(ped)
                    if weapon ~= nil then
                        if armorDamaged and (bodypart == 'SPINE' or bodypart == 'LOWER_BODY') and weapon <= Config.WeaponClasses['LIGHT_IMPACT'] and weapon ~= Config.WeaponClasses['NOTHING'] then
                            checkDamage = false -- Don't check damage if the it was a body shot and the weapon class isn't that strong
                        end

                        if checkDamage then
                            CheckDamage(ped, bone, weapon)
                        end
                    end
                end
            end

            playerHealth = health
            playerArmor = armor
            Citizen.Wait(500)

            ProcessDamage(ped)
            Citizen.Wait(500)
        end
    end
end)

--[[ Player Died Events ]]--
RegisterNetEvent('baseevents:onPlayerKilled')
AddEventHandler('baseevents:onPlayerKilled', function(killedBy, data)
    TriggerEvent('pw_skeleton:client:ResetLimbs')
    TriggerEvent('pw_skeleton:client:RemoveBleed')
end)

RegisterNetEvent('baseevents:onPlayerDied')
AddEventHandler('baseevents:onPlayerDied', function(killedBy, pos)
    TriggerEvent('pw_skeleton:client:ResetLimbs')
    TriggerEvent('pw_skeleton:client:RemoveBleed')
end)
--[[
local extremeHunger, supremeHunger, starving, supremeHungerCreated, starvingCreated, extremeHungerCreated = false, false, false, false, false, false
local extremeThirst, supremeThirst, thirsting, supremeThirstCreated, thirstingCreated, extremeThirstCreated = false, false, false, false, false, false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playerLoaded then
            local playerPed = GetPlayerPed(-1)
            if not IsPedFatallyInjured(playerPed) then 
                local currentHunger = exports.pw_needs:getNeedsLevel('hunger')
                local currentThirst = exports.pw_needs:getNeedsLevel('thirst')
                local currentDrug = exports.pw_needs:getNeedsLevel('drugs')
                if currentHunger < 6 then
                    supremeHunger = true
                    if not supremeHungerCreated then
                        Citizen.CreateThread(function()
                            while supremeHunger do
                                if not supremeHunger then
                                    break 
                                end
                                TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You are going to black out soon from starvation.", length = 5000})
                                DoScreenFadeOut(2500)
                                local currentHealth = GetEntityHealth(playerPed)
                                local newHealth = currentHealth - 4
                                SetEntityHealth(playerPed, newHealth)
                                Citizen.Wait(5000)
                                DoScreenFadeIn(2500)
                                Citizen.Wait(60000)
                            end
                        end)
                        supremeHungerCreated = true
                    end
                    extremeHunger = false
                elseif currentHunger < 10 then
                    starving = false
                    extremeHunger = true
                    if not extremeHungerCreated then
                        Citizen.CreateThread(function()
                            while extremeHunger do
                                if not extremeHunger then
                                    break
                                end
                                TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You are extremly hungry, eat something soon!", length = 5000})
                                Citizen.Wait(60000)
                            end
                        end)
                        extremeHungerCreated = true
                    end
                elseif currentHunger < 20 then
                    starving = true
                    if not starvingCreated then
                        Citizen.CreateThread(function()
                            while starving do
                                if not starving then
                                    break
                                end
                                TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You are starting to feel peckish, consider buying some food.", length = 5000})
                                Citizen.Wait(120000)
                            end
                        end)
                        starvingCreated = true
                    end
                else
                    if extremeHunger or supremeHunger or starving then
                        extremeHunger = false
                        supremeHunger = false
                        starving = false
                        supremeHungerCreated = false
                        starvingCreated = false
                        extremeHungerCreated = false
                        DoScreenFadeIn(0)
                    end
                end

                if currentThirst < 6 then
                    supremeThirst = true
                    if not supremeThirstCreated then
                        Citizen.CreateThread(function()
                            while supremeThirst do
                                if not supremeThirst then
                                    break
                                end
                                TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You are going to black out soon from thirst.", length = 5000})
                                DoScreenFadeOut(2500)
                                local currentHealth = GetEntityHealth(playerPed)
                                local newHealth = currentHealth - 4
                                SetEntityHealth(playerPed, newHealth)
                                Citizen.Wait(5000)
                                DoScreenFadeIn(2500)
                                Citizen.Wait(60000)
                            end
                        end)
                        supremeThirstCreated = true
                    end
                    extremeThirst = false
                elseif currentThirst < 10 then
                    thirsting = false
                    extremeThirst = true
                    if not extremeThirstCreated then
                        Citizen.CreateThread(function()
                            while extremeThirst do
                                if not extremeThirst then
                                    break
                                end
                                TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You are extremly thirsty, drink something soon!", length = 5000})
                                Citizen.Wait(60000)
                            end
                        end)
                        extremeThirstCreated = true
                    end
                elseif currentThirst < 20 then
                    thirsting = true
                    if not thirstingCreated then
                        Citizen.CreateThread(function()
                            while thirsting do
                                if not thirsting then
                                    break
                                end
                                TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You are starting to feel peckish, consider buying some water.", length = 5000})
                                Citizen.Wait(120000)
                            end
                        end)
                        thirstingCreated = true
                    end
                else
                    if extremeThirst or supremeThirst or thirsting then
                        extremeThirst = false
                        supremeThirst = false
                        thirsting = false
                        supremeThirstCreated = false
                        thirsting = false
                        extremeThirstCreated = false
                        DoScreenFadeIn(0)
                    end
                end

                if currentDrug >= 100 then
                    SetEntityHealth(playerPed, 80)
                    if not overDoseInformed then
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You have taken an overdose on drugs.", length = 5000})
                        overDoseInformed = true
                    end
                else
                    overDoseInformed = false
                end
            end
            Citizen.Wait(5000)
        end
    end
end)
]]--