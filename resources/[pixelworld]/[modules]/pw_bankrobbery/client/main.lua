PW, characterLoaded, playerData = nil, false, nil
local currentBank, currentSpot = 0, 0
local showing, burning = false, false
Banks, CardReaders = {}, {}

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
            PW.TriggerServerCallback('pw_bankrobbery:server:getBanks', function(banks, cardreaders)
                Banks = banks
                CardReaders = cardreaders
                GLOBAL_PED = PlayerPedId()
                GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                characterLoaded = true
            end)
        else
            playerData = data
        end
    else
        for i = 1, #Banks do
            ResetEverything(i)
        end
        characterLoaded = false
        playerData = nil
    end
end)

RegisterNetEvent('pw_bankrobbery:client:usedLockpick')
AddEventHandler('pw_bankrobbery:client:usedLockpick', function(data)
    if currentBank > 0 and currentSpot > 0 and showing then
        local found = false
        local find = { 'vg_spots', 'm_spots' }
        for i = 1, #find do
            if string.find(showing, find[i]) ~= nil and not Banks[currentBank][find[i]][currentSpot].open and not Banks[currentBank][find[i]][currentSpot].opening then
                found = find[i]
                break
            end
        end
        if found then
            Wait(50)
            if not Banks[currentBank][found][currentSpot].opening then
                TriggerServerEvent('pw_bankrobbery:server:syncVaultBoxes', currentBank, found, currentSpot, 'opening', true)
                -- start lockpick stuff
                local openBox = false
                if found == 'm_spots' then
                    TriggerEvent('pw_clicker:client:startGame', 6, function(success)
                        if success then
                            TriggerServerEvent('pw_bankrobbery:server:syncVaultBoxes', currentBank, found, currentSpot, 'open', true)
                            TriggerServerEvent('pw_bankrobbery:server:awardVaultGoods', currentBank)
                        else
                            TriggerServerEvent('pw_bankrobbery:server:removeItem', data)
                            exports.pw_notify:SendAlert('error', 'Your lockpick just broke')
                        end
                        TriggerServerEvent('pw_bankrobbery:server:syncVaultBoxes', currentBank, found, currentSpot, 'opening', false)
                    end)
                else
                    TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'vaultMoney',
                            duration = 10000,
                            label = 'Lockpicking Storage Box',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                math.randomseed(GetGameTimer())
                                local failure = math.random(1,100)
                                if failure <= Config.LockpickBreakChance then
                                    TriggerServerEvent('pw_bankrobbery:server:removeItem', data)
                                    exports.pw_notify:SendAlert('error', 'Your lockpick just broke')
                                else
                                    TriggerServerEvent('pw_bankrobbery:server:syncVaultBoxes', currentBank, found, currentSpot, 'open', true)
                                    TriggerServerEvent('pw_bankrobbery:server:awardVaultMoney', currentBank)
                                end
                                TriggerServerEvent('pw_bankrobbery:server:syncVaultBoxes', currentBank, found, currentSpot, 'opening', false)
                            end
                        end)
                end
            end
        end
    end
end)

RegisterNetEvent('pw_bankrobbery:client:usedScrewdriver')
AddEventHandler('pw_bankrobbery:client:usedScrewdriver', function()
    if currentBank > 0 and showing then
        PW.TriggerServerCallback('pw_bankrobbery:server:getPolice', function(online)
            if online >= Config.NeededPolice[Banks[currentBank].bankType] then
                local found = (string.find(showing, 'cashiercoords') ~= nil and not Banks[currentBank].cashiercoords.open and not Banks[currentBank].cashiercoords.lockpicking and Banks[currentBank].bankOpen)
                if found then
                    Wait(100)
                    if not Banks[currentBank].cashiercoords.lockpicking then
                        TriggerServerEvent('pw_bankrobbery:server:syncCashierDoorOpening', currentBank, true)
                        TriggerEvent('pw_lockpick:client:startGame', function(success)
                            if success then
                                -- TODO: Trigger alarm
                                TriggerServerEvent('pw_bankrobbery:server:syncCashierDoor', currentBank, true)
                                TriggerServerEvent('pw_bankrobbery:server:disableHacking', currentBank, 'cashiercoords', true)
                                TriggerServerEvent('pw_bankrobbery:server:bankLockdown', currentBank, true)
                            end
                            TriggerServerEvent('pw_bankrobbery:server:syncCashierDoorOpening', currentBank, false)
                        end)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('pw_bankrobbery:client:usedUsbHack')
AddEventHandler('pw_bankrobbery:client:usedUsbHack', function(data)
    if currentBank > 0 and showing then
        local found = false
        local bankType = Banks[currentBank].bankType
        local find = {}
        if bankType == 'Small' then
            find = { 'counters', 'vaultgate' }
            for i = 1, #find do
                if string.find(showing, find[i]) ~= nil then
                    found = find[i]
                    break
                end
            end
        elseif bankType == 'Big' then
            if string.find(showing, 'beforevaults') ~= nil then
                found = 'beforevaults'
            end
        end
        
        if found then
            local proceed = false
            if bankType == 'Small' then
                if (found == 'counters' and not Banks[currentBank].cashiercoords.disabled and Banks[currentBank].cashiercoords.open and not Banks[currentBank].cashiercoords.counters[currentSpot].open and not Banks[currentBank].cashiercoords.counters[currentSpot].hacking and currentSpot > 0) then
                    Wait(100)
                    if (found == 'counters' and not Banks[currentBank].cashiercoords.counters[currentSpot].hacking) then
                        TriggerServerEvent('pw_bankrobbery:server:syncCounters', currentBank, currentSpot, 'hacking', true)
                        proceed = true
                    end
                elseif (found == 'vaultgate' and Banks[currentBank].vaults.open and not Banks[currentBank].vaultgate.hacking and not Banks[currentBank].vaultgate.disabled) then
                    Wait(100)
                    if (found == 'vaultgate' and not Banks[currentBank].vaultgate.hacking) then
                        TriggerServerEvent('pw_bankrobbery:server:syncVaultGateHacking', currentBank, 'vaultgate', true)
                        proceed = true
                    end
                end
            elseif bankType == 'Big' then
                if (found == 'beforevaults' and Banks[currentBank].cashiercoords.open and not Banks[currentBank].beforevaults.hacking and not Banks[currentBank].beforevaults.disabled) then
                    Wait(100)
                    if (found == 'beforevaults' and not Banks[currentBank].beforevaults.hacking) then
                        TriggerServerEvent('pw_bankrobbery:server:syncVaultGateHacking', currentBank, 'beforevaults', true)
                        proceed = true
                    end
                end
            end

            if proceed then
                TriggerEvent('pw:progressbar:progress',
                    {
                        name = 'counterHacking',
                        duration = 1500,
                        label = 'Connecting USB stick',
                        useWhileDead = false,
                        canCancel = false,
                        controlDisables = {
                            disableMovement = true,
                            disableCarMovement = false,
                            disableMouse = true,
                            disableCombat = true,
                        },
                    },
                    function(status)
                        if not status then
                            TriggerEvent("mhacking:show")
                            TriggerEvent("mhacking:start", 7, 35, function(success)
                                if success then
                                    if found == 'counters' then
                                        TriggerServerEvent('pw_bankrobbery:server:counterRewards', currentBank)
                                    else
                                        TriggerServerEvent('pw_bankrobbery:server:syncVaults', currentBank, found, true, true)
                                        TriggerServerEvent('pw_bankrobbery:server:disableHacking', currentBank, found, true)
                                    end
                                else
                                    TriggerServerEvent('pw_bankrobbery:server:removeItem', data)
                                end
                                TriggerEvent('mhacking:hide')
                                if found == 'counters' then
                                    TriggerServerEvent('pw_bankrobbery:server:syncCounters', currentBank, currentSpot, 'open', true)
                                    TriggerServerEvent('pw_bankrobbery:server:syncCounters', currentBank, currentSpot, 'hacking', false)
                                else
                                    TriggerServerEvent('pw_bankrobbery:server:syncVaultsDisabled', currentBank, found, true)
                                    TriggerServerEvent('pw_bankrobbery:server:syncVaultGateHacking', currentBank, found, false)
                                    TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31B', Banks[currentBank].name)
                                    TriggerServerEvent('pw_bankrobbery:server:bankLockdown', currentBank, true)
                                end
                            end)
                        end
                    end)
            end
        end
    end
end)

RegisterNetEvent('pw_bankrobbery:client:disableHacking')
AddEventHandler('pw_bankrobbery:client:disableHacking', function(bank, type, state)
    Banks[bank][type].disabled = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:startThermiteFire')
AddEventHandler('pw_bankrobbery:client:startThermiteFire', function(bank, location, requester, obj)
    Citizen.CreateThread(function()
        Citizen.Wait(2000)
        burning = { ['bank'] = bank, ['door'] = location, ['obj'] = obj }
        if requester ~= nil then
            if GetPlayerServerId(PlayerId()) == requester then
                TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31B', Banks[bank].name)
            end
        end
        local dict1 = "pat_heist"
        local name1 = "scr_heist_ornate_thermal_burn_patch"
        local dict2 = "scr_ornate_heist"
        local name2 = "scr_heist_ornate_metal_drip"
        RequestNamedPtfxAsset(dict1)
        RequestNamedPtfxAsset(dict2)
        while not HasNamedPtfxAssetLoaded(dict1) do
            Citizen.Wait(0)
        end
        while not HasNamedPtfxAssetLoaded(dict2) do
            Citizen.Wait(0)
        end
        UseParticleFxAssetNextCall(dict1)
        local objCoords1 = vector3(Banks[bank][location].door.thermite.spark.x, Banks[bank][location].door.thermite.spark.y, Banks[bank][location].door.thermite.spark.z)
        local objCoords2 = vector3(Banks[bank][location].door.thermite.drip.x, Banks[bank][location].door.thermite.drip.y, Banks[bank][location].door.thermite.drip.z)
        local fx1 = StartParticleFxLoopedAtCoord(name1, objCoords1, 1.0, 1.0, 1.0, 1.0, false, false)
        UseParticleFxAssetNextCall(dict2)
        local fx2 = StartParticleFxLoopedAtCoord(name2, objCoords2, 1.0, 1.0, 1.0, 2.0, false, false)
        Citizen.Wait(2000)
        local fireStarted = StartScriptFire(objCoords2.x, objCoords2.y, objCoords2.z-1.0, 0, false)
        local fireStarted2 = StartScriptFire(objCoords2.x, objCoords2.y, objCoords2.z-1.0, 0, false)
        local fireStarted3 = StartScriptFire(objCoords2.x, objCoords2.y, objCoords2.z-1.0, 0, false)
        Citizen.Wait(5000)
        StopParticleFxLooped(fx1)
        StopParticleFxLooped(fx2)
        burning = false
        Citizen.Wait(8000)
        RemoveScriptFire(fireStarted)
        RemoveScriptFire(fireStarted2)
        RemoveScriptFire(fireStarted3)
        if requester ~= nil then
            if GetPlayerServerId(PlayerId()) == requester then
                TriggerServerEvent('pw_bankrobbery:server:syncVaults', bank, location, true, true)
            end
        end
    end)
end)

RegisterNetEvent('pw_bankrobbery:client:thermiteBacklash')
AddEventHandler('pw_bankrobbery:client:thermiteBacklash', function()
    local playerPed = GLOBAL_PED
    local playerPedFire = StartEntityFire(playerPed)
    Citizen.Wait(5000)
    SetEntityHealth(playerPed, 99)
    Citizen.Wait(2000)
    StopEntityFire(playerPed)
    Citizen.Wait(1000)
    SetEntityHealth(playerPed, 99)
end)

RegisterNetEvent('pw_bankrobbery:client:usedThermite')
AddEventHandler('pw_bankrobbery:client:usedThermite', function(data)
    if currentBank > 0 and showing then
        PW.TriggerServerCallback('pw_bankrobbery:server:getPolice', function(online)
            if online >= Config.NeededPolice[Banks[currentBank].bankType] then
                local found, bankType = false, Banks[currentBank].bankType
                if bankType == 'Small' then
                    found = (string.find(showing, 'vaults') ~= nil and not Banks[currentBank].vaults.open)
                else
                    local bigGates
                    if bankType == 'Paleto' then
                        bigGates = { 'vaults', 'vaultgate' }
                    else
                        bigGates = { 'cashiercoords', 'vaultgate', 'finalgate' }
                    end
                    for i = 1, #bigGates do
                        if string.find(showing, bigGates[i]) ~= nil and not Banks[currentBank][bigGates[i]].open then
                            found = bigGates[i]
                            break
                        end
                    end
                end
                if found then
                    local playerCoords = GLOBAL_COORDS
                    local distance

                    if bankType == 'Small' then
                        distance = #(playerCoords - vector3(Banks[currentBank].vaults.coords.x, Banks[currentBank].vaults.coords.y, Banks[currentBank].vaults.coords.z))
                    else
                        distance = #(playerCoords - vector3(Banks[currentBank][found].coords.x, Banks[currentBank][found].coords.y, Banks[currentBank][found].coords.z))
                    end
                    
                    if distance < 1.0 then
                        TriggerEvent('pw_phone:games:startNumberGame', {
                            ['tries'] = 20, 
                            ['failures'] = 5, 
                            ['duration'] = 2000,
                            ['time'] = 1500, 
                        }, function(success)
                            if success then
                                StartThermitePlanting(currentBank, (bankType == 'Small' and 'vaults' or found))
                            else
                                TriggerEvent('pw_bankrobbery:client:thermiteBacklash')
                            end
                            TriggerServerEvent('pw_bankrobbery:server:removeItem', data)
                            TriggerServerEvent('pw_bankrobbery:server:syncVaultsDisabled', currentBank, (bankType == 'Small' and 'vaults' or found), true)
                            TriggerServerEvent('pw_bankrobbery:server:bankLockdown', currentBank, true)
                            TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31B', Banks[currentBank].name)
                        end)
                    end
                end
            end
        end)
    end
end)

function StartThermitePlanting(bank, door)
    local ad = "anim@heists@ornate_bank@thermal_charge_heels"
    local anim = "thermal_charge"
    local thermalObj = -335888452--865563579
    local bagObj = GetHashKey("hei_p_m_bag_var22_arm_s")
    local playerPed = GLOBAL_PED
	
	if ( DoesEntityExist( playerPed ) and not IsEntityDead( playerPed )) then
		while not HasAnimDictLoaded(ad) do
            RequestAnimDict(ad)
            Wait(10)
        end
        
        while not HasModelLoaded(bagObj) do
            RequestModel(bagObj)
            Wait(10)
        end

        while not HasModelLoaded(thermalObj) do
            RequestModel(thermalObj)
            Wait(10)
        end

        FreezeEntityPosition(playerPed, true)
        
        local heading = Banks[bank][door].door.thermite.heading
        local offset = Banks[bank][door].door.thermite.bomb.offset
        local rotation = Banks[bank][door].door.thermite.bomb.rotation
        
        SetEntityHeading(playerPed, heading)
        
        local firstPosition = vector3(Banks[bank][door].door.thermite.drip.x, Banks[bank][door].door.thermite.drip.y, Banks[bank][door].door.thermite.drip.z)

        local tempthermal = CreateObjectNoOffset(thermalObj, firstPosition, 1, 1, 0)
        SetEntityVisible(tempthermal, false, false)
        FreezeEntityPosition(tempthermal, true)
        local rightCoords = GetOffsetFromEntityInWorldCoords(tempthermal, offset.x, offset.y, offset.z)
        DeleteObject(tempthermal)
        
        local targetPosition, targetRotation = rightCoords, vec3(GetEntityRotation(playerPed))
        SetEntityCoords(playerPed, targetPosition, 0.0, 0.0, 0.0, 0)
        Wait(100)
        local netScene = NetworkCreateSynchronisedScene(targetPosition, targetRotation, 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(playerPed, netScene, ad, anim, 1.5, -4.0, 1, 16, 1148846080, 0)
        
        local bag = CreateObject(bagObj, targetPosition, 1, 1, 0)
        NetworkAddEntityToSynchronisedScene(bag, netScene, ad, "bag_thermal_charge", 4.0, -8.0, 1)     

        NetworkStartSynchronisedScene(netScene)

        Citizen.Wait(1000)
        
        local thermal = CreateObject(thermalObj, 0.0, 0.0, 0.0, 1, 1, 0)
        AttachEntityToEntity(thermal, playerPed, GetPedBoneIndex(playerPed, 4090), 0,0,0,0,0,0,true,true,false,true,1,true)
        Citizen.Wait(1500)
        DeleteObject(thermal)

        local thermal1 = CreateObjectNoOffset(thermalObj, rightCoords, 1, 1, 0)
        local thermalNet = ObjToNet(thermal1)
        FreezeEntityPosition(thermal1, true)
        SetEntityRotation(thermal1, rotation.x, rotation.y, rotation.z, 2, 0)
        Citizen.Wait(1800)
        SetEntityVisible(bag, false, false)
        Citizen.CreateThread(function()
            TriggerServerEvent('pw_bankrobbery:server:syncThermite', bank, door, thermalNet)
            Citizen.Wait(9300)
            DeleteObject(thermal1)
        end)
        --Citzen.Wait(2000)
        FreezeEntityPosition(playerPed, false)
        NetworkStopSynchronisedScene(netScene)
        DeleteObject(bag)
	end
end

RegisterNetEvent('pw_bankrobbery:client:usedVaultCard')
AddEventHandler('pw_bankrobbery:client:usedVaultCard', function(data)
    local proceed, found = false, false
    local decodeMeta = data.metaprivate
    local cardHours = { tonumber(decodeMeta.hours[1]), tonumber(decodeMeta.hours[2]) }
    local cardBank = decodeMeta.bank
    local isUniversal = (cardBank == 0)
    PW.TriggerServerCallback('pw_bankrobbery:server:getPolice', function(online)
        if currentBank > 0 and showing then
            if online >= Config.NeededPolice[Banks[currentBank].bankType] then
                found = ((Banks[currentBank].bankType == 'Big' or Banks[currentBank].bankType == 'Small') and (string.find(showing, 'vaults') ~= nil and not Banks[currentBank]['vaults'].open and ((Banks[currentBank].bankType == 'Big' and Banks[currentBank].beforevaults.open) or Banks[currentBank].bankType == 'Small'))) or (Banks[currentBank].bankType == 'Paleto' and (string.find(showing, 'beforevaults') ~= nil and not Banks[currentBank]['beforevaults'].open))
                if found then
                    if cardBank == currentBank or isUniversal then
                        local currentHour = GetClockHours()
                        
                        if ((Banks[currentBank].bankType == 'Small' or Banks[currentBank].bankType == 'Paleto') and Banks[currentBank].bankOpen or 1) and (currentHour == cardHours[1] or isUniversal) then
                            TriggerServerEvent('pw_bankrobbery:server:syncVaults', currentBank, (Banks[currentBank].bankType == 'Paleto' and 'beforevaults' or 'vaults'), true, true)
                            TriggerServerEvent('pw_bankrobbery:server:disableHacking', currentBank, 'vaultgate', true)
                        else
                            TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31B', Banks[currentBank].name)
                            TriggerServerEvent('pw_bankrobbery:server:syncVaults', currentBank, (Banks[currentBank].bankType == 'Paleto' and 'beforevaults' or 'vaults'), false, false)
                        end
                    else
                        TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31B', Banks[currentBank].name)
                    end
                    exports.pw_notify:SendAlert('error', 'This card was reported as stolen. It is now <b><span class="text-danger">BLOCKED</span></b>.', 5000)
                    TriggerServerEvent('pw_bankrobbery:server:removeItem', data)
                    TriggerServerEvent('pw_bankrobbery:server:syncVaultsDisabled', currentBank, (Banks[currentBank].bankType == 'Paleto' and 'beforevaults' or 'vaults'), true)
                    TriggerServerEvent('pw_bankrobbery:server:bankLockdown', currentBank, true)
                end
            end
            proceed = true
        else
            proceed = true
        end
    end)

    repeat Wait(10) until proceed == true

    if not found then
        local pedCoords = GLOBAL_COORDS
        local cardReader = tonumber(decodeMeta.reader)
        
        for k,v in pairs(CardReaders) do
            local dist = #(pedCoords - vector3(v.x, v.y, v.z))
            if dist < 1.5 then
                if k == cardReader then
                    TriggerServerEvent('pw_bankrobbery:server:removeItem', data)
                    TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'accessing_reader',
                            duration = 2000,
                            label = 'Reading Card info',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        },
                        function(status)
                            if not status then
                                TriggerServerEvent('pw_bankrobbery:server:readCard', cardBank, cardHours, isUniversal, data)
                            end
                        end)
                    break
                else
                    exports.pw_notify:SendAlert('error', 'Could not decrypt this card', 4000)
                    break
                end
            end
        end
    end
end)

RegisterNetEvent('pw_bankrobbery:client:syncCashierDoorOpening')
AddEventHandler('pw_bankrobbery:client:syncCashierDoorOpening', function(bank, state)
    Banks[bank].cashiercoords.lockpicking = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncVaultGateHacking')
AddEventHandler('pw_bankrobbery:client:syncVaultGateHacking', function(bank, gate, state)
    Banks[bank][gate].hacking = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncVaultBoxes')
AddEventHandler('pw_bankrobbery:client:syncVaultBoxes', function(bank, boxes, spot, type, state)
    Banks[bank][boxes][spot][type] = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncVaultsDisabled')
AddEventHandler('pw_bankrobbery:client:syncVaultsDisabled', function(bank, vault, state)
    Banks[bank][vault].disabled = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncVaults')
AddEventHandler('pw_bankrobbery:client:syncVaults', function(bank, vault, openDoor, state)
    if state and openDoor and currentBank == bank then
        RotateDoor(bank, vault, 'open')
    end
    Banks[bank][vault].open = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncCounters')
AddEventHandler('pw_bankrobbery:client:syncCounters', function(bank, counter, type, state)
    Banks[bank].cashiercoords.counters[counter][type] = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncSpots')
AddEventHandler('pw_bankrobbery:client:syncSpots', function(bank, type, spot, state)
    Banks[bank][type][spot].open = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:syncCashierDoor')
AddEventHandler('pw_bankrobbery:client:syncCashierDoor', function(bank, state)
    if state and currentBank == bank then
        RotateDoor(bank, 'cashiercoords', 'open')
    end
    Banks[bank].cashiercoords.open = state
    CheckShowing(bank)
end)

RegisterNetEvent('pw_bankrobbery:client:modifyBank')
AddEventHandler('pw_bankrobbery:client:modifyBank', function(bank, type, state)
    Banks[bank][type] = state
    if type == 'bankOpen' and state then
        if currentBank == bank then
            local gates
            if Banks[bank].bankType == 'Small' then
                gates = { 'cashiercoords', 'vaults', 'vaultgate' }
            else
                gates = { 'cashiercoords', 'vaults', 'vaultgate', 'beforevaults', 'finalgate' }
            end
            for i = 1, #gates do
                if Banks[bank][gates[i]].open then
                    RotateDoor(bank, gates[i], 'close')
                end
            end
        end

        ResetEverything(bank)
    end
end)

function ActivateSprinkles(bank)
    --[[ scr_agency3b_sprinkler_off
    scr_agency3b_sprinkler_on ]]

    local dict1 = "core"
    local name1 = "scr_agency3b_sprinkler_on"
        
    RequestNamedPtfxAsset(dict1)
    while not HasNamedPtfxAssetLoaded(dict1) do
        Citizen.Wait(0)
    end

    local dict2 = "core"
    local name2 = "scr_agency3b_sprinkler_off"

    RequestNamedPtfxAsset(dict2)
    while not HasNamedPtfxAssetLoaded(dict2) do
        Citizen.Wait(0)
    end

    UseParticleFxAssetNextCall(dict1)
    local fx1 = StartParticleFxLoopedAtCoord(name1, -103.6958694458, 6469.8618164063, 34.376703262329, 0.0, 0.0, 0.0, 6.0, false, false)
    Citizen.Wait(15000)
    StopParticleFxLooped(fx1)

    UseParticleFxAssetNextCall(dict2)
    local fx2 = StartParticleFxLoopedAtCoord(name2, -103.6958694458, 6469.8618164063, 34.376703262329, 0.0, 0.0, 0.0, 3.0, false, false)
    Citizen.Wait(10000)
    StopParticleFxLooped(fx2)
end

RegisterNetEvent('pw_bankrobbery:client:checkIfExplosionInRadius')
AddEventHandler('pw_bankrobbery:client:checkIfExplosionInRadius', function(x, y, z, planter)
    if GetPlayerServerId(PlayerId()) == planter then
        if currentBank > 0 and (Banks[currentBank].bankType == 'Big' and Banks[currentBank].beforevaults.open and not Banks[currentBank].vaults.open) or (Banks[currentBank].bankType == 'Paleto' and not Banks[currentBank].beforevaults.open) then
            PW.TriggerServerCallback('pw_bankrobbery:server:getPolice', function(online)
                if online >= Config.NeededPolice[Banks[currentBank].bankType] then
                    local use = (Banks[currentBank].bankType == 'Big' and 'vaults' or 'beforevaults')
                    local dist = #(vector3(x, y, z) - vector3(Banks[currentBank][use].door.coords.x, Banks[currentBank][use].door.coords.y, Banks[currentBank][use].door.coords.z))
                    if dist < 15.0 then
                        TriggerServerEvent('pw_bankrobbery:server:syncVaults', currentBank, use, true, true)
                        TriggerServerEvent('pw_bankrobbery:server:bankLockdown', currentBank, true)
                        TriggerEvent('pw_chat:client:DoPoliceDispatch', '10-31B', Banks[currentBank].name)
                        if Banks[currentBank].bankType == 'Paleto' then
                            ActivateSprinkles(currentBank)
                        end
                    end
                end
            end)
        end
    end
end)

function ResetEverything(bank)
    Banks[bank].cashiercoords.open = false
    Banks[bank].cashiercoords.disabled = false
    Banks[bank].vaults.open = false
    Banks[bank].vaults.disabled = false
    Banks[bank].vaultgate.open = false
    Banks[bank].vaultgate.disabled = false
    Banks[bank].vaultgate.hacking = false
    
    if Banks[bank].bankType == 'Small' or Banks[bank].bankType == 'Paleto' then
        for i = 1, #Banks[bank].cashiercoords.counters do
            Banks[bank].cashiercoords.counters[i].open = false
            Banks[bank].cashiercoords.counters[i].hacking = false
        end
    end
    if Banks[bank].bankType ~= 'Small' then
        Banks[bank].beforevaults.open      = false
        Banks[bank].beforevaults.disabled  = false
        if Banks[bank].bankType == 'Big' then
            Banks[bank].finalgate.open         = false
            Banks[bank].finalgate.disabled     = false
        end
    end
    
    for i = 1, #Banks[bank].vg_spots do
        Banks[bank].vg_spots[i].open = false
        Banks[bank].vg_spots[i].opening = false
    end
    
    for i = 1, #Banks[bank].m_spots do
        Banks[bank].m_spots[i].open = false
        Banks[bank].m_spots[i].opening = false
    end
    
    CheckShowing(bank)
end

function RotateDoor(bank, door, direction)
    if not DoesEntityExist(Banks[bank][door].obj) then
        Banks[bank][door].obj = GetDoor(bank, door)
    end

    local timeout = 1000
    while not DoesEntityExist(Banks[bank][door].obj) do
        if timeout <= 0 then
            return false
        else
            timeout = timeout - 50
            Banks[bank][door].obj = GetDoor(bank, door)
        end
        Citizen.Wait(50)
    end

    local oH, cH = Banks[bank][door].door.oh, Banks[bank][door].door.ch
    local reverse = Banks[bank][door].door.reverse

    -- OH 325.0
    -- CH 45.013021469116

    Banks[bank][door].opening = true
    if direction == 'open' then
        Citizen.CreateThread(function()
            if reverse == -1 then
                for i = cH, -179.9, -1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, i)
                end

                SetEntityHeading(Banks[bank][door].obj, 179.9)

                for j = 179.9, oH, -1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, j)
                end
            elseif reverse == 1 then
                for i = cH, 0.0, -1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, i)
                end

                SetEntityHeading(Banks[bank][door].obj, 359.9)

                for j = 359.9, oH, -1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, j)
                end
            else
                for i = cH, oH, (oH > cH and 1 or -1) do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, i)
                end
            end
            Banks[bank][door].opening = false
        end)
    else
        Citizen.CreateThread(function()
            if reverse == -1 then
                for i = oH, 179.9, 1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, i)
                end

                SetEntityHeading(Banks[bank][door].obj, -179.9)

                for j = -179.9, cH, 1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, j)
                end
            elseif reverse == 1 then
                for i = oH, 359.9, 1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, i)
                end

                SetEntityHeading(Banks[bank][door].obj, 0.0)

                for j = 0.0, cH, 1 do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, j)
                end
            else
                for i = oH, cH, (oH > cH and -1 or 1) do
                    Citizen.Wait(5)
                    SetEntityHeading(Banks[bank][door].obj, i)
                end
            end
            
            Banks[bank][door].opening = false
        end)
    end
end

function CheckShowing(bank)
    if currentBank == bank and showing then
        showing = false
        TriggerEvent('pw_drawtext:hideNotification')
    end
end

function HideDraw()
    showing = false
    TriggerEvent('pw_drawtext:hideNotification')
    TriggerServerEvent('pw_keynote:server:triggerShowable', false)
end

function DrawText(bank, type, spot)
    local title, message, icon

    if type == 'cashiercoords' then
        title = 'Cashier Door'
        if not Banks[bank].cashiercoords.open and Banks[bank].bankOpen then
            message = '<span style="font-size:18px">Door <span class="text-danger">LOCKED</span></span>'
            icon = 'fad fa-door-closed'
            TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = (Banks[bank].bankType ~= 'Big' and "screwdriver" or "thermite")}})
        elseif not Banks[bank].bankOpen then
            message = '<span style="font-size:18px">The bank is on a <span class="text-danger">LOCKDOWN</span></span>'
            icon = 'fad fa-door-closed'
        else
            message = '<span style="font-size:18px">This door was recently <span class="text-danger">BROKEN INTO</span></span>'
            icon = 'fad fa-door-open'
        end
    elseif type == 'counters' then
        if spot > 0 then
            title = 'Cashier Counter'
            if Banks[bank].bankType == 'Paleto' then
                if not Banks[bank].cashiercoords.counters[spot].open and not Banks[bank].cashiercoords.disabled then
                    message = '<span style="font-size:18px">Press [ <span class="text-primary">E</span> ] to search counter</span>'
                    icon = 'fad fa-search-dollar'
                end
            elseif not Banks[bank].cashiercoords.counters[spot].open and not Banks[bank].cashiercoords.disabled then
                message = '<span style="font-size:18px">Awaiting <span class="text-primary">AUTHENTICATION</span></span>'
                icon = 'fad fa-laptop-code'
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "usbhack"}})
            elseif Banks[bank].cashiercoords.disabled then
                message = '<span style="font-size:18px">This counter is on <span class="text-danger">LOCKDOWN</span></span>'
                icon = 'fad fa-window-close'
            elseif Banks[bank].bankType ~= 'Paleto' then
                message = '<span style="font-size:18px">This counter was recently <span class="text-danger">HACKED</span></span>'
                icon = 'fad fa-window-close'
            end
        end
    elseif type == 'vaults' then
        title = 'Vault Access'
        if not Banks[bank].vaults.open and not Banks[bank].vaults.disabled and Banks[bank].bankOpen then
            message = '<span style="font-size:18px">Awaiting <span class="text-primary">AUTHENTICATION</span></span>'
            icon = 'fad fa-door-closed'
            if Banks[bank].bankType == 'Small' then
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "vaultcard"},{['type'] = "item", ['item'] = "thermite"}})
            elseif Banks[bank].bankType == 'Big' then
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "vaultcard"},{['type'] = "item", ['item'] = "bombbag"}})
            else
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "thermite"}})
            end
        elseif not Banks[bank].bankOpen then
            message = '<span style="font-size:18px">The scanner is on a <span class="text-danger">LOCKDOWN</span>' .. (Banks[bank].bankType ~= 'Small' and '<br><span style="font-size:14px">Override with <b>Universal Card</b> only</span></span>' or '</span>')
            icon = 'fad fa-door-closed'
            if Banks[bank].bankType == 'Small' then
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "thermite"}})
            elseif Banks[bank].bankType == 'Big' then
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "vaultcard"},{['type'] = "item", ['item'] = "bombbag"}})
            end
        else
            message = '<span style="font-size:18px">This vault was recently <span class="text-danger">ACCESSED</span></span>'
            icon = 'fad fa-door-open'
        end
    elseif type == 'vaultgate' then
        title = 'Vault Gate'
        if not Banks[bank].vaultgate.open and not Banks[bank].vaultgate.disabled then
            if Banks[bank].bankType == 'Small' then
                message = '<span style="font-size:18px">Awaiting <span class="text-primary">AUTHENTICATION</span> decryption</span>'
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "usbhack"}})
            else
                message = '<span style="font-size:18px">Door <span class="text-danger">LOCKED</span></span>'
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "thermite"}})
            end
            icon = 'fad fa-door-closed'
        elseif Banks[currentBank].vaultgate.disabled then
            if Banks[bank].bankType == 'Small' then
                message = '<span style="font-size:18px">The scanner is on a <span class="text-danger">LOCKDOWN</span></span>'
            else
                message = '<span style="font-size:18px">This vault was recently <span class="text-danger">ACCESSED</span></span>'
            end
            icon = 'fad fa-door-closed'
        else
            message = '<span style="font-size:18px">This vault was recently <span class="text-danger">ACCESSED</span></span>'
            icon = 'fad fa-door-open'
        end
    elseif type == 'vg_spots' then
        if spot > 0 then
            title = 'Storage Box'
            if not Banks[bank].vg_spots[spot].open and not Banks[bank].vg_spots[spot].opening then
                message = '<span style="font-size:22px">Storage Box <span class="text-primary">#' .. spot .. '</span></span>'
                icon = 'fad fa-door-closed'
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "lockpick"}})
            else
                message = '<span style="font-size:20px">This storage box was recently <span class="text-danger">ACCESSED</span></span>'
                icon = 'fad fa-door-open'
            end
        end
    elseif type == 'm_spots' then
        if spot > 0 then
            title = 'High Security Storage Box'
            if not Banks[bank].m_spots[spot].open and not Banks[bank].m_spots[spot].opening then
                message = '<span style="font-size:22px">Storage Box <span class="text-primary">#' .. spot .. '</span></span>'
                icon = 'fad fa-door-closed'
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "lockpick"}})
            else
                message = '<span style="font-size:20px">This storage box was recently <span class="text-danger">ACCESSED</span></span>'
                icon = 'fad fa-door-open'
            end
        end
    elseif type == 'beforevaults' then
        title = 'Vault Access'
        if not Banks[bank].beforevaults.open and not Banks[bank].beforevaults.disabled then
            message = '<span style="font-size:18px">Awaiting <span class="text-primary">AUTHENTICATION</span></span>'
            icon = 'fad fa-door-closed'
            if Banks[bank].bankType == 'Big' then
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "usbhack"}})
            else
                TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "vaultcard"},{['type'] = "item", ['item'] = "bombbag"}})
            end
        elseif Banks[bank].beforevaults.disabled then
            message = '<span style="font-size:18px">The scanner is on a <span class="text-danger">LOCKDOWN</span></span>'
            icon = 'fad fa-door-closed'
        else
            message = '<span style="font-size:18px">This vault was recently <span class="text-danger">ACCESSED</span></span>'
            icon = 'fad fa-door-open'
        end
    elseif type == 'finalgate' then
        title = 'Vault Access'
        if not Banks[bank].finalgate.open and not Banks[bank].finalgate.disabled then
            message = '<span style="font-size:18px">Door <span class="text-danger">LOCKED</span></span>'
            icon = 'fad fa-door-closed'
            TriggerServerEvent('pw_keynote:server:triggerShowable', true, {{['type'] = "item", ['item'] = "thermite"}})
        elseif Banks[bank].finalgate.disabled then
            message = '<span style="font-size:18px">Special lock active during <span class="text-danger">LOCKDOWN</span></span>'
            icon = 'fad fa-door-closed'
        else
            message = '<span style="font-size:18px">This vault was recently <span class="text-danger">ACCESSED</span></span>'
            icon = 'fad fa-door-open'
        end
    end

    if title and message and icon then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end
end

function SearchCounter(bank, counter)
    TriggerEvent('pw:progressbar:progress',
        {
            name = 'accessing_counter',
            duration = 15000,
            label = 'Searching Counter',
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = true,
                disableCombat = true,
            },
            animation = {
                animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer",
            },
        },
        function(status)
            if not status then
                TriggerServerEvent('pw_bankrobbery:server:syncCounters', bank, counter, 'open', true)
                TriggerServerEvent('pw_bankrobbery:server:syncCounters', bank, counter, 'hacking', false)
                TriggerServerEvent('pw_bankrobbery:server:counterRewards', bank)
                ClearPedTasks(GLOBAL_PED)
            else
                ClearPedTasks(GLOBAL_PED)
            end
        end)
end

function SearchThread(bank, counter, var)
    Citizen.CreateThread(function()
        while showing == var and characterLoaded do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('pw_bankrobbery:server:syncCounters', bank, counter, 'hacking', true)
                SearchCounter(bank, counter)
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded and playerData then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and playerData and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and playerData then
            local pedCoords = GLOBAL_COORDS
            local dist
            for k, v in pairs(Banks) do
                dist = #(pedCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                if v.bankType == 'Small' and dist < 50.0 or ((v.bankType == 'Big' or v.bankType == 'Paleto') and dist < 100.0) then
                    local curDoorHeading
                    currentBank = k
                    dist = #(pedCoords - vector3(v.cashiercoords.door.outside.x, v.cashiercoords.door.outside.y, v.cashiercoords.door.outside.z))
                    if dist < 1.0 then
                        if not showing and not v.cashiercoords.lockpicking then
                            showing = 'cashiercoords'..k
                            DrawText(k, 'cashiercoords')
                        elseif showing == 'cashiercoords'..k and v.cashiercoords.lockpicking then
                            HideDraw()
                        end
                    elseif showing == 'cashiercoords'..k then
                        HideDraw()
                    end

                    if dist < 20.0 then
                        if v.cashiercoords.obj == nil or v.cashiercoords.obj == 0 or not DoesEntityExist(v.cashiercoords.obj) then
                            Banks[k].cashiercoords.obj = GetDoor(k, 'cashiercoords')
                        end

                        if not v.cashiercoords.opening then
                            curDoorHeading = GetEntityHeading(Banks[k].cashiercoords.obj)
                            if v.cashiercoords.open then
                                if math.abs(curDoorHeading - v.cashiercoords.door.oh) > 2.0 then
                                    SetEntityHeading(Banks[k].cashiercoords.obj, v.cashiercoords.door.oh)
                                end
                            else
                                if math.abs(curDoorHeading - v.cashiercoords.door.ch) > 2.0 then
                                    SetEntityHeading(Banks[k].cashiercoords.obj, v.cashiercoords.door.ch)
                                end
                            end
                            FreezeEntityPosition(Banks[k].cashiercoords.obj, true)
                        end
                    end

                    if v.cashiercoords.open then
                        if v.bankType == 'Small' or v.bankType == 'Paleto' then
                            for i = 1, #v.cashiercoords.counters do
                                dist = #(pedCoords - vector3(v.cashiercoords.counters[i].x, v.cashiercoords.counters[i].y, v.cashiercoords.counters[i].z))
                                if dist < 0.85 then
                                    if not showing and not v.cashiercoords.counters[i].hacking then
                                        showing = 'counters'..i..k
                                        currentSpot = i
                                        DrawText(k, 'counters', i)
                                        if v.bankType == 'Paleto' then
                                            SearchThread(k, i, showing)
                                        end
                                    elseif showing == 'counters'..i..k and v.cashiercoords.counters[i].hacking then
                                        currentSpot = 0
                                        HideDraw()
                                    end
                                elseif showing == 'counters'..i..k or (showing and (string.sub(showing, -1) ~= tostring(currentBank))) then
                                    currentSpot = 0
                                    HideDraw()
                                end
                            end
                        end
                    end

                    if v.bankType == 'Paleto' or (v.bankType == 'Big' and v.cashiercoords.open) then
                        dist = #(pedCoords - vector3(v.beforevaults.coords.x, v.beforevaults.coords.y, v.beforevaults.coords.z))
                        if dist < 1.0 then
                            if not showing and not v.beforevaults.lockpicking then
                                showing = 'beforevaults'..k
                                DrawText(k, 'beforevaults')
                            elseif showing == 'beforevaults'..k and v.beforevaults.lockpicking then
                                HideDraw()
                            end
                        elseif showing == 'beforevaults'..k then
                            HideDraw()
                        end
                    end

                    if v.bankType == 'Big' or v.bankType == 'Paleto' then
                        if dist < 20.0 then
                            if v.beforevaults.obj == nil or v.beforevaults.obj == 0 or not DoesEntityExist(v.beforevaults.obj) then
                                Banks[k].beforevaults.obj = GetDoor(k, 'beforevaults')
                            end

                            if not v.beforevaults.opening then
                                curDoorHeading = GetEntityHeading(Banks[k].beforevaults.obj)
                                if v.beforevaults.open then
                                    if math.abs(curDoorHeading - v.beforevaults.door.oh) > 2.0 then
                                        SetEntityHeading(Banks[k].beforevaults.obj, v.beforevaults.door.oh)
                                    end
                                else
                                    if math.abs(curDoorHeading - v.beforevaults.door.ch) > 2.0 then
                                        SetEntityHeading(Banks[k].beforevaults.obj, v.beforevaults.door.ch)
                                    end
                                end
                                FreezeEntityPosition(Banks[k].beforevaults.obj, true)
                            end
                        end
                    end

                    if ((v.bankType == 'Big' or v.bankType == 'Paleto') and v.beforevaults.open) or v.bankType == 'Small' then
                        dist = #(pedCoords - vector3(v.vaults.coords.x, v.vaults.coords.y, v.vaults.coords.z))
                        if dist < 1.0 then
                            if not showing then
                                showing = 'vaults'..k
                                DrawText(k, 'vaults')
                            end
                        elseif showing == 'vaults'..k then
                            HideDraw()
                        end
                    end

                    if dist < 20.0 then
                        if v.vaults.obj == nil or v.vaults.obj == 0 or not DoesEntityExist(v.vaults.obj) then
                            Banks[k].vaults.obj = GetDoor(k, 'vaults')
                        end

                        if not v.vaults.opening then
                            curDoorHeading = GetEntityHeading(Banks[k].vaults.obj)
                            if v.vaults.open then
                                if math.abs(curDoorHeading - v.vaults.door.oh) > 2.0 then
                                    SetEntityHeading(Banks[k].vaults.obj, v.vaults.door.oh)
                                end
                            else
                                if math.abs(curDoorHeading - v.vaults.door.ch) > 2.0 then
                                    SetEntityHeading(Banks[k].vaults.obj, v.vaults.door.ch)
                                end
                            end
                            FreezeEntityPosition(Banks[k].vaults.obj, true)
                        end
                    end

                    if v.vaults.open then
                        dist = #(pedCoords - vector3(v.vaultgate.coords.x, v.vaultgate.coords.y, v.vaultgate.coords.z))
                        if dist < 1.0 then
                            if not showing then
                                showing = 'vaultgate'..k
                                DrawText(k, 'vaultgate')
                            end
                        elseif showing == 'vaultgate'..k then
                            HideDraw()
                        end
                    end

                    if dist < 20.0 then
                        if v.vaultgate.obj == nil or v.vaultgate.obj == 0 or not DoesEntityExist(v.vaultgate.obj) then
                            Banks[k].vaultgate.obj = GetDoor(k, 'vaultgate')
                        end

                        if not v.vaultgate.opening then
                            curDoorHeading = GetEntityHeading(Banks[k].vaultgate.obj)
                            if v.vaultgate.open then
                                if math.abs(curDoorHeading - v.vaultgate.door.oh) > 2.0 then
                                    SetEntityHeading(Banks[k].vaultgate.obj, v.vaultgate.door.oh)
                                end
                            else
                                if math.abs(curDoorHeading - v.vaultgate.door.ch) > 2.0 then
                                    SetEntityHeading(Banks[k].vaultgate.obj, v.vaultgate.door.ch)
                                end
                            end
                            FreezeEntityPosition(Banks[k].vaultgate.obj, true)
                        end
                    end

                    if (v.bankType == 'Big' and v.vaultgate.open) or ((v.bankType == 'Small' or v.bankType == 'Paleto') and v.vaults.open) then
                        for i = 1, #v.vg_spots do
                            dist = #(pedCoords - vector3(v.vg_spots[i].x, v.vg_spots[i].y, v.vg_spots[i].z))
                            if dist < 0.85 then
                                if not showing and not v.vg_spots[i].opening then
                                    showing = 'vg_spots'..i..k
                                    currentSpot = i
                                    DrawText(k, 'vg_spots', i)
                                elseif showing == 'vg_spots'..i..k and v.vg_spots[i].opening then
                                    currentSpot = 0
                                    HideDraw()
                                end
                            elseif showing == 'vg_spots'..i..k then
                                currentSpot = 0
                                HideDraw()
                            end
                        end
                    end

                    if v.bankType == 'Big' then
                        dist = #(pedCoords - vector3(v.finalgate.coords.x, v.finalgate.coords.y, v.finalgate.coords.z))
                        if dist < 1.0 then
                            if not showing then
                                showing = 'finalgate'..k
                                DrawText(k, 'finalgate')
                            end
                        elseif showing == 'finalgate'..k then
                            HideDraw()
                        end
                    
                        if dist < 20.0 then
                            if v.finalgate.obj == nil or v.finalgate.obj == 0 or not DoesEntityExist(v.finalgate.obj) then
                                Banks[k].finalgate.obj = GetDoor(k, 'finalgate')
                            end
                            
                            if not v.finalgate.opening then
                                curDoorHeading = GetEntityHeading(Banks[k].finalgate.obj)
                                if v.finalgate.open then
                                    if math.abs(curDoorHeading - v.finalgate.door.oh) > 2.0 then
                                        SetEntityHeading(Banks[k].finalgate.obj, v.finalgate.door.oh)
                                    end
                                else
                                    if math.abs(curDoorHeading - v.finalgate.door.ch) > 2.0 then
                                        SetEntityHeading(Banks[k].finalgate.obj, v.finalgate.door.ch)
                                    end
                                end
                                FreezeEntityPosition(Banks[k].finalgate.obj, true)
                            end
                        end
                    end

                    if ((v.bankType == 'Small' or v.bankType == 'Paleto') and v.vaultgate.open) or (v.bankType == 'Big' and v.finalgate.open) then
                        for i = 1, #v.m_spots do
                            dist = #(pedCoords - vector3(v.m_spots[i].x, v.m_spots[i].y, v.m_spots[i].z))
                            if dist < 0.85 then
                                if not showing and not v.m_spots[i].opening then
                                    currentSpot = i
                                    showing = 'm_spots'..i..k
                                    DrawText(k, 'm_spots', i)
                                elseif showing == 'm_spots'..i..k and v.m_spots[i].opening then
                                    currentSpot = 0
                                    HideDraw()
                                end
                            elseif showing == 'm_spots'..i..k then
                                currentSpot = 0
                                HideDraw()
                            end
                        end
                    end
                elseif currentBank == k or (showing and (string.sub(showing, -1) ~= tostring(currentBank))) then
                    currentBank = 0
                    HideDraw()
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded then
            local playerPed = GLOBAL_PED
            local clearAnim = false
            if type(burning) == 'table' then
                if currentBank == burning.bank then
                    local objId = NetToObj(burning.obj)
                    if objId and objId > 0 and DoesEntityExist(objId) then
                        if HasEntityClearLosToEntityInFront(playerPed, objId) then
                            if not IsEntityPlayingAnim(playerPed, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 3) then
                                local ad = "anim@heists@ornate_bank@thermal_charge"
                                local anim = "cover_eyes_loop"
                                while not HasAnimDictLoaded(ad) do
                                    RequestAnimDict(ad)
                                    Wait(10)
                                end
                                TaskPlayAnim(playerPed, ad, anim, 4.0, -8.0, -1, 49, 0, 0, 0, 0)
                            end
                        else
                            clearAnim = true
                        end
                    else
                        clearAnim = true
                    end
                else
                    clearAnim = true
                end
            else
                clearAnim = true
            end

            if clearAnim then
                if IsEntityPlayingAnim(playerPed, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 3) then
                    Wait(500)
                    ClearPedTasks(playerPed)
                end
            end
        end
    end
end)

function GetDoor(bank, door)
    if door == 'cashiercoords' then
        return GetClosestObjectOfType(Banks[bank][door].door.coords.x, Banks[bank][door].door.coords.y, Banks[bank][door].door.coords.z, 4.0, Banks[bank][door].door.hash, false, false, false)
    else
        local rayHandle = StartShapeTestRay(Banks[bank][door].door.coords.x + 5.0, Banks[bank][door].door.coords.y + 5.0, Banks[bank][door].door.coords.z, Banks[bank][door].door.coords.x, Banks[bank][door].door.coords.y, Banks[bank][door].door.coords.z, 16, 0, 0)
        local numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

        if hit and GetEntityModel(entityHit) == Banks[bank][door].door.hash then
            return entityHit
        else
            rayHandle = StartShapeTestRay(Banks[bank][door].door.coords.x - 5.0, Banks[bank][door].door.coords.y + 5.0, Banks[bank][door].door.coords.z, Banks[bank][door].door.coords.x, Banks[bank][door].door.coords.y, Banks[bank][door].door.coords.z, 16, 0, 0)
            numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
            if hit and GetEntityModel(entityHit) == Banks[bank][door].door.hash then
                return entityHit
            else
                rayHandle = StartShapeTestRay(Banks[bank][door].door.coords.x - 5.0, Banks[bank][door].door.coords.y - 5.0, Banks[bank][door].door.coords.z, Banks[bank][door].door.coords.x, Banks[bank][door].door.coords.y, Banks[bank][door].door.coords.z, 16, 0, 0)
                numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
                if hit and GetEntityModel(entityHit) == Banks[bank][door].door.hash then
                    return entityHit
                else
                    rayHandle = StartShapeTestRay(Banks[bank][door].door.coords.x + 5.0, Banks[bank][door].door.coords.y - 5.0, Banks[bank][door].door.coords.z, Banks[bank][door].door.coords.x, Banks[bank][door].door.coords.y, Banks[bank][door].door.coords.z, 16, 0, 0)
                    numRayHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
                    if hit and GetEntityModel(entityHit) == Banks[bank][door].door.hash then
                        return entityHit
                    else
                        return 0
                    end
                end
            end
        end
    end

    return 0
end

---- FOR DEV PURPOSES ONLY
---- DELETE AFTER ALL BANKS ARE ADDED
-- Face the lock of door
-- Get coords and apply those to coords2 -> DRIP - Doesn't need adjustments
-- Use the same coords in coords1 and mess with X and Y. Add 0.10 to Z

--"thermite":{"spark":{"x":,"y":,"z":},"drip":{"x":,"y":,"z":},"bomb":{"rotation":{"x":,"y":,"z":},"offset":{"x":,"y":,"z":}},"heading":}


--[[ function ThermiteTest()
    local coords1 = vector3(-105.8085, 6473.49509, 31.80)
    local coords2 = vector3(-105.49, 6472.29, 31.63)

    local dict1 = "pat_heist"
    local name1 = "scr_heist_ornate_thermal_burn_patch"
    local dict2 = "scr_ornate_heist"
    local name2 = "scr_heist_ornate_metal_drip"
    RequestNamedPtfxAsset(dict1)
    RequestNamedPtfxAsset(dict2)
    while not HasNamedPtfxAssetLoaded(dict1) do
        Citizen.Wait(0)
    end
    while not HasNamedPtfxAssetLoaded(dict2) do
        Citizen.Wait(0)
    end
    UseParticleFxAssetNextCall(dict1)
    local objCoords1 = coords1
    local objCoords2 = coords2
    local fx1 = StartParticleFxLoopedAtCoord(name1, objCoords1.x, objCoords1.y, objCoords1.z, 0.0, 0.0, 0.0, 1.0, false, false)
    UseParticleFxAssetNextCall(dict2)
    local fx2 = StartParticleFxLoopedAtCoord(name2, objCoords2.x, objCoords2.y, objCoords2.z, 0.0, 0.0, 0.0, 2.0, false, false)
    Citizen.Wait(4000)
    StopParticleFxLooped(fx1)
    StopParticleFxLooped(fx2)
end

function AnimationTest()--
    local ad = "anim@heists@ornate_bank@thermal_charge_heels"
    local anim = "thermal_charge"
    local thermalObj = -335888452--865563579
    local bagObj = GetHashKey("hei_p_m_bag_var22_arm_s")
    local playerPed = PlayerPedId()
	
	if ( DoesEntityExist( playerPed ) and not IsEntityDead( playerPed )) then
		while not HasAnimDictLoaded(ad) do
            RequestAnimDict(ad)
            Wait(10)
        end
        
        while not HasModelLoaded(bagObj) do
            RequestModel(bagObj)
            Wait(10)
        end

        while not HasModelLoaded(thermalObj) do
            RequestModel(thermalObj)
            Wait(10)
        end

        
        FreezeEntityPosition(playerPed, true)
        --,"bomb":{"offset":{"x":,"y":,"z":},"rotation":{"x":,"y":,"z":}},"heading":
        

        local heading = 347.79
        local offset = { ['x'] =  0.20, ['y'] = -0.025, ['z'] = 0.15 }
        local rotation = { ['x'] =  0.20, ['y'] = -0.025, ['z'] = 0.15 }
        SetEntityHeading(playerPed, heading)
        
        local firstPosition = vector3(257.27, 219.8, 106.29)

        local tempthermal = CreateObjectNoOffset(thermalObj, firstPosition, 1, 1, 0)
        SetEntityVisible(tempthermal, false, false)
        FreezeEntityPosition(tempthermal, true)
        local rightCoords = GetOffsetFromEntityInWorldCoords(tempthermal, offset.x, offset.y, offset.z)
        DeleteObject(tempthermal)
        
        local targetPosition, targetRotation = rightCoords, vec3(GetEntityRotation(playerPed))
        SetEntityCoords(playerPed, targetPosition, 0.0, 0.0, 0.0, 0)
        Wait(100)
        local netScene = NetworkCreateSynchronisedScene(targetPosition, targetRotation, 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(playerPed, netScene, ad, anim, 1.5, -4.0, 1, 16, 1148846080, 0)
        
        local bag = CreateObject(bagObj, targetPosition, 1, 1, 0)
        NetworkAddEntityToSynchronisedScene(bag, netScene, ad, "bag_thermal_charge", 4.0, -8.0, 1)     

        NetworkStartSynchronisedScene(netScene)

        planting = true
        Wait(1000)
        
        local thermal = CreateObject(thermalObj, 0.0, 0.0, 0.0, 1, 1, 0)
        AttachEntityToEntity(thermal, playerPed, GetPedBoneIndex(playerPed, 4090), 0,0,0,0,0,0,true,true,false,true,1,true)
        Citizen.Wait(1500)
        DeleteObject(thermal)

        local thermal1 = CreateObjectNoOffset(thermalObj, rightCoords, 1, 1, 0)
        FreezeEntityPosition(thermal1, true)
        SetEntityRotation(thermal1, rotation.x, rotation.y, rotation.z, 2, 0)
        Citizen.Wait(1800)
        SetEntityVisible(bag, false, false)
        Citizen.CreateThread(function()
            SetEntityVisible(thermite, false, false)
            ThermiteTest()
            DeleteObject(thermal1)
        end)
        FreezeEntityPosition(playerPed, false)
        Citizen.Wait(5000)
        NetworkStopSynchronisedScene(netScene)
        DeleteObject(bag)
        DeleteObject(thermal)
	end
end

function attach()
    local playerPed = PlayerPedId()

    local thermalObj = -335888452--865563579
    while not HasModelLoaded(thermalObj) do
        RequestModel(thermalObj)
        Wait(10)
    end

    local thermal = CreateObjectNoOffset(thermalObj, -105.49, 6472.29, 31.63, 1, 1, 0)
    SetEntityVisible(thermal, false, false)
    FreezeEntityPosition(thermal, true)
    local rightCoords = GetOffsetFromEntityInWorldCoords(thermal, -0.32795, 0.220195, 0.175)
    DeleteObject(thermal)

    local thermal1 = CreateObjectNoOffset(thermalObj, rightCoords, 1, 1, 0)
    FreezeEntityPosition(thermal1, true)
    SetEntityRotation(thermal1, -90.0, -225.0, 0.0, 2, 0)
    Wait(2000)
    DeleteObject(thermal1)
end ]]

--[[ Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 38) then
            --ThermiteTest()
            --AnimationTest()
            --attach()
        end
    end
end) ]]