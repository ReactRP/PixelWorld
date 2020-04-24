PW = nil
PWBase = PWBase or {}
PWBase.Inventory = PWBase.Inventory or {}
GLOBAL_PED, GLOBAL_COORDS = nil, nil
isLoggedIn = false
local trunkData = nil
local trunkOpen = false
local isInInventory = false
local openCooldown = false
local myInventory = nil
local secondaryInventory = nil
thirdInventory = nil
inThirdInventory = false
thirdOpenAllowed = false

PlayerVeh = nil

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
	end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            GLOBAL_PED = PlayerPedId()
        end
        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn and GLOBAL_PED ~= nil then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
        Citizen.Wait(100)
    end
end)

RegisterNetEvent('pw_inventory:client:setupThird')
AddEventHandler('pw_inventory:client:setupThird', function(inv, owner, name)
    if inv and owner then
        thirdInventory = { type = inv, owner = owner, req = name }
        thirdOpenAllowed = true
    end
end)

RegisterNetEvent('pw_inventory:client:removeThird')
AddEventHandler('pw_inventory:client:removeThird', function(name)
    if name then
        if thirdInventory ~= nil and type(thirdInventory) == "table" and thirdInventory.req == "name" then
            thirdInventory = nil
            inThirdInventory = false
            thirdOpenAllowed = false
        end
    end
end)

PWBase.Inventory.Setup = {
    Startup = function(self)
        Citizen.CreateThread(function()
            while isLoggedIn do
                BlockWeaponWheelThisFrame()
                Citizen.Wait(1)
            end
        end)
    
        Citizen.CreateThread(function()
            Citizen.Wait(100)
            while isLoggedIn do
                Citizen.Wait(0)
                if not PWBase.Inventory.Locked then
                    if IsControlJustReleased(0, 289) then
                        if not openCooldown and not inThirdInventory then
                            if IsPedInAnyVehicle(PlayerPedId(), true) then
                                local veh = GetVehiclePedIsIn(PlayerPedId())
                                local plate = GetVehicleNumberPlateText(veh)
    
                                if DecorExistOn(veh, 'vehicle_fakeplate') then 
                                    plate = exports['pw_vehiclemanagement']:tracePlate(plate)
                                end
    
                                if DecorExistOn(veh, 'player_owned_veh') and DecorGetBool(veh, "player_owned_veh") then
                                    if plate ~= nil then
                                        secondaryInventory = { type = 5, owner = plate }
                                    end
                                else
                                    if plate ~= nil then
                                        secondaryInventory = { type = 4, owner = plate }
                                    end
                                end
    
                                if plate ~= nil then
                                    PWBase.Inventory.Load:Secondary()
                                end
                            else
                                local veh = PWBase.Inventory.Checks:Vehicle()
    
                                if veh and IsEntityAVehicle(veh) then
                                    local plate = GetVehicleNumberPlateText(veh)
    
                                    if DecorExistOn(veh, 'vehicle_fakeplate') then 
                                        plate = exports['pw_vehiclemanagement']:tracePlate(plate)
                                    end

                                    if GetVehicleDoorLockStatus(veh) == 1 then
                                        
                                        if DecorExistOn(veh, 'player_owned_veh') and DecorGetBool(veh, "player_owned_veh") then
                                            secondaryInventory = { type = 7, owner = plate }
                                        else
                                            secondaryInventory = { type = 6, owner = plate }
                                        end
                                        
                                        TriggerEvent("pw:progressbar:progress", {
                                            name = "accessing_atm",
                                            duration = 500,
                                            label = "Opening Trunk",
                                            useWhileDead = false,
                                            canCancel = false,
                                            controlDisables = {
                                                disableMovement = false,
                                                disableCarMovement = false,
                                                disableMouse = false,
                                                disableCombat = false,
                                            },
                                            animation = {
                                                animDict = "veh@low@front_dsfps@base",
                                                anim = "horn_intro",
                                                flags = 49,
                                            },
                                        }, function(status)
                                            trunkOpen = true
                                            SetVehicleDoorOpen(veh, 5, true, false)
                                            PWBase.Inventory.Load:Secondary()
                                            PWBase.Inventory.Checks:TrunkDistance(veh)
                                        end)
                                    else
                                        exports['mythic_notify']:SendAlert('error', 'Vehicle Is Locked')
                                        if bagId ~= nil then
                                            openDrop()
                                        else
                                            local container = ScanContainer()
                                            if container then
                                                openContainer()
                                            else
                                                PWBase.Inventory.Open:Personal()
                                            end
                                        end
                                    end
                                else
                                    if bagId ~= nil then
                                        openDrop()
                                    else
                                        local container = ScanContainer()
                                        if container then
                                            openContainer()
                                        else
                                            PWBase.Inventory.Open:Personal()
                                        end
                                    end
                                end
                            end
                        end
                    elseif IsControlJustReleased(0, 38) then -- e
                        if thirdInventory ~= nil and thirdOpenAllowed then
                            PWBase.Inventory.Open:Third()
                        end
                    elseif IsDisabledControlJustReleased(2, 157) then -- 1
                        PWBase.Inventory:Hotkey(1)
                    elseif IsDisabledControlJustReleased(2, 158) then -- 2
                        PWBase.Inventory:Hotkey(2)
                    elseif IsDisabledControlJustReleased(2, 160) then -- 3
                        PWBase.Inventory:Hotkey(3)
                    elseif IsDisabledControlJustReleased(2, 164) then -- 4
                        PWBase.Inventory:Hotkey(4)
                    elseif IsDisabledControlJustReleased(2, 165) then -- 5
                        PWBase.Inventory:Hotkey(5)
                    elseif IsDisabledControlJustReleased(2, 159) or IsControlJustReleased(2, 159) then
                        PW.ExecuteServerCallback('pw_inventory:server:GetHotkeys', function(items) 
                            SendNUIMessage({
                                action = 'showActionBar',
                                items = items
                            })
                        end, {})
                    end
                end
            end
        end)
    end,
    Primary = function(self, data)
        items = {}
        inventory = data.inventory
    
        SendNUIMessage( { action = "setItems", itemList = inventory, invOwner = data.invId, invTier = data.invTier } )
    end,
    Secondary = function(self, data)
        items = {}
        inventory = data.inventory
    
        if #inventory == 0 and data.invId.type == 2 then
            MYTY.Inventory.Close:Secondary()
        else
            secondaryInventory = data.invId
            SendNUIMessage( { action = "setSecondInventoryItems", itemList = inventory, invOwner = data.invId, invTier = data.invTier } )
            PWBase.Inventory.Open:Secondary()
        end
    end
}

RegisterNetEvent('pw_inventory:client:LockInventory')
AddEventHandler('pw_inventory:client:LockInventory', function(state)
    PWBase.Inventory:LockInventory(state)
end)

function PWBase.Inventory.LockInventory(self, state)
    PWBase.Inventory.Locked = not PWBase.Inventory.Locked
end

local cooldown = false

function PWBase.Inventory.Hotkey(self, index)
    print(index)
    if not cooldown and not PWBase.Inventory.Locked then
        --TriggerServerEvent('pw_inventory:server:UseItemFromSlot', index)
        PW.TriggerServerCallback('pw_inventory:server:UseHotkey', function(success)
            cooldown = true

            print('Success: ', tostring(success))

            Citizen.CreateThread(function()
                Citizen.Wait(1000)
                cooldown = false
            end)
            
            PW.TriggerServerCallback('pw_inventory:server:GetHotkeys', function(items)
                print('this?')
                SendNUIMessage({
                    action = 'showActionBar',
                    items = items,
                    timer = 500,
                    index = success
                })
            end)
        end, { ['slot'] = index })
    end
end

function PWBase.Inventory.ItemUsed(self, alerts)
    SendNUIMessage({
        action = 'itemUsed',
        alerts = alerts
    })
end

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local pos = GetEntityCoords(player)
        local dist = #(vector3(-1045.3142089844, -2731.0183105469, 20.169298171997) - pos)

        if dist < 20 then
            DrawMarker(25, -1045.3142089844, -2731.0183105469, 20.169298171997 - 0.99, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 139, 16, 20, 250, false, false, 2, false, false, false, false)

            if dist < 2 then
                if IsControlJustReleased(0, 51) then
                    TriggerServerEvent('pw_inventory:server:GetSecondaryInventory', GetPlayerServerId(PlayerId()), { type = 18, owner = '1' })
                end
            end
        end

        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw_inventory:client:ShowItemUse')
AddEventHandler('pw_inventory:client:ShowItemUse', function(alerts)
    PWBase.Inventory:ItemUsed(alerts)
end)

PWBase.Inventory.Checks = {
    Vehicle = function(self)
        local player = PlayerPedId()
        local startPos = GetOffsetFromEntityInWorldCoords(player, 0, 0.5, 0)
        local endPos = GetOffsetFromEntityInWorldCoords(player, 0, 5.0, 0)
    
        local rayHandle = StartShapeTestRay(startPos['x'], startPos['y'], startPos['z'], endPos['x'], endPos['y'], endPos['z'], 10, player, 0)
        local a, b, c, d, veh = GetShapeTestResult(rayHandle)
    
        if veh ~= 2 then
            local plyCoords = GetEntityCoords(player)
            local offCoords = GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 1.0)
            local dist = #(vector3(offCoords.x, offCoords.y, offCoords.z) - plyCoords)
    
            if dist < 2.5 then
                return veh
            end
        else
            return nil
        end
    end,
    Trunk = function(self)
        
    end,
    TrunkDistance = function(self, veh)
        Citizen.CreateThread(function()
            while trunkOpen do
                Citizen.Wait(1)
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(vector3(pos.x, pos.y, pos.z) - GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 1.0))
                if dist > 1 and trunkOpen then
                    PWBase.Inventory.Close:Instant()
                else
                    Citizen.Wait(500)
                end
            end
        end)
    end,
    HasItem = function(self, items, cb)
        PW.ExecuteServerCallback('pw_inventory:server:HasItem', function(status)
            cb(status)
        end, items)
    end
}

PWBase.Inventory.Load = {
    Personal = function(self)
        TriggerServerEvent("pw_inventory:server:GetPlayerInventory")
    end,
    Secondary = function(self, secondary)
        if secondary ~= nil then
            secondaryInventory = secondary
        end

        TriggerServerEvent('pw_inventory:server:GetSecondaryInventory', GetPlayerServerId(PlayerId()), secondaryInventory)
    end,
    Third = function(self, third)
        if third ~= nil then
            thirdInventory = third
        end

        TriggerServerEvent('pw_inventory:server:GetSecondaryInventory', GetPlayerServerId(PlayerId()), thirdInventory)
    end
}

PWBase.Inventory.Open = {
    Personal = function(self)
        PWBase.Inventory.Load:Personal()
        isInInventory = true
        SendNUIMessage({
            action = "display",
            type = "normal"
        })

        TransitionToBlurred(1000)

        SetNuiFocus(true, true)
    end,
    Secondary = function(self)
        PWBase.Inventory.Load:Personal()
        isInInventory = true

        TransitionToBlurred(1000)
    
        SendNUIMessage({
            action = "display",
            type = "secondary",
            third = false
        })
    
        SetNuiFocus(true, true)
    end,
    Third = function(self)
        PWBase.Inventory.Load:Third()
        PWBase.Inventory.Load:Personal()
        TriggerEvent('pw_inventory:client:updateClientCash', playerData.cash)
        isInInventory = true
        inThirdInventory = true
        
        TransitionToBlurred(1000)
        
        SendNUIMessage({
            action = "display",
            type = "secondary",
            third = true
        })

        SetNuiFocus(true, true)
    end
}

PWBase.Inventory.Close = {
    Third = function(self)
        inThirdInventory = false
        thirdInventory = nil
        SendNUIMessage({ action = "closeSecondary" })
        TransitionFromBlurred(1000)
        SendNUIMessage({ action = "hide" })
        SetNuiFocus(false, false)
        Citizen.Wait(1200)
        openCooldown = false
    end,
    Normal = function(self)
        openCooldown = true
        isInInventory = false
        inThirdInventory = false
        secondaryInventory = nil

        TransitionFromBlurred(1000)

        SendNUIMessage({ action = "hide" })
        SetNuiFocus(false, false)
    
        if trunkOpen then
            local coords = GetEntityCoords(PlayerPedId())
            local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    
            TriggerEvent("pw:progressbar:progress", {
                name = "accessing_atm",
                duration = 500,
                label = "Closing Trunk",
                useWhileDead = false,
                canCancel = false,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                },
                animation = {
                    animDict = "veh@low@front_dsfps@base",
                    anim = "horn_outro",
                    flags = 49,
                },
            }, function(status)
                SetVehicleDoorShut(veh, 5, false)
                trunkOpen = false
            end)

        end
    
        Citizen.Wait(1200)
        openCooldown = false
    end,
    Instant = function(self)
        secondaryInventory = nil
        openCooldown = true
        isInInventory = false
        SendNUIMessage({ action = "hide" })
        SetNuiFocus(false, false)
    
        if trunkOpen then
            trunkOpen = false
        end
    
        openCooldown = false
    end,
    Secondary = function(self)
        secondaryInventory = nil

        SendNUIMessage({ action = "closeSecondary" })
    
        if trunkOpen then
            trunkOpen = false
        end
    
        TriggerEvent('pw_inventory:client:RefreshInventory')
    end
}



RegisterNetEvent("pw_inventory:client:RemoveWeapon")
AddEventHandler("pw_inventory:client:RemoveWeapon", function(weapon)
    PWBase.Inventory.Weapons:Remove(weapon)
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

RegisterNetEvent("pw_inventory:client:AddWeapon")
AddEventHandler("pw_inventory:client:AddWeapon", function(weapon)
    local player = PlayerPedId()
    local pos = GetEntityCoords(player, true)
    local rot = GetEntityHeading(player)
    local currWeapon = GetSelectedPedWeapon(player)

    loadAnimDict( "reaction@intimidation@1h" )

    print(currWeapon, GetHashKey(weapon), currWeapon == GetHashKey(weapon))
    if currWeapon == GetHashKey(weapon) then
        PWBase.Inventory.Weapons:DisableFire()
        TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "outro", GetEntityCoords(player, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
        Citizen.Wait(1600)
        PWBase.Inventory.Weapons:RemoveAll()
        ClearPedTasks(player)
        PWBase.Inventory.Weapons:EnableFire()
    else
        if currWeapon == `WEAPON_UNARMED` then
            PWBase.Inventory.Weapons:DisableFire()
            TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "intro", GetEntityCoords(player, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
            Citizen.Wait(1000)
            PWBase.Inventory.Weapons:Add(weapon)
            Citizen.Wait(2000)
            ClearPedTasks(player)
            PWBase.Inventory.Weapons:EnableFire()
        else
            PWBase.Inventory.Weapons:DisableFire()
            TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "outro", GetEntityCoords(player, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
            Citizen.Wait(1500)
            PWBase.Inventory.Weapons:RemoveAll()
            --ClearPedTasks(player)
            TaskPlayAnimAdvanced(player, "reaction@intimidation@1h", "intro", GetEntityCoords(player, true), 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
            Citizen.Wait(1000)
            PWBase.Inventory.Weapons:Add(weapon)
            Citizen.Wait(2000)
            ClearPedTasks(player)
            PWBase.Inventory.Weapons:EnableFire()
        end
    end
end)

local canFire = true
PWBase.Inventory.Weapons = {
    Add = function(self, weapon)
        GiveWeaponToPed(PlayerPedId(), weapon, 0, false, true)
    end,
    Remove = function(self, weapon)
        RemoveWeaponFromPed(PlayerPedId(), weapon)
    end,
    RemoveAll = function(self)
        RemoveAllPedWeapons(PlayerPedId(), false)
    end,
    DisableFire = function(self)
        if canFire then
            Citizen.CreateThread(function()
                canFire = false
                while not canFire do
                    Citizen.Wait(0)
                    if not canFire then
                        DisableControlAction(0, 25, true)
                        DisablePlayerFiring(player, true)
                    end
                end
            end)
        end
    end,
    EnableFire = function(self)
        canFire = true
    end
}

RegisterNetEvent('mythic_base:client:CharacterDataChanged')
AddEventHandler('mythic_base:client:CharacterDataChanged', function(charData)
    if charData ~= nil then
        if charData:GetData('id') ~= nil then
            myInventory = { type = 1, owner = charData:GetData('id') }
        else
            myInventory = nil
        end
    else
        myInventory = nil
    end
end)

RegisterNetEvent('pw_inventory:client:RobPlayer')
AddEventHandler('pw_inventory:client:RobPlayer', function()
    local ped = exports['mythic_base']:GetPedInFront()

    if ped ~= 0 then
        local pedPlayer = exports['mythic_base']:GetPlayerFromPed(ped)
        if pedPlayer ~= -1 then
            TriggerServerEvent('pw_inventory:server:RobPlayer', GetPlayerServerId(pedPlayer))
        end
    end
end)


RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            playerLoaded = true
            isLoggedIn = true
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            PWBase.Inventory.Setup:Startup()
        else
            playerData = data
        end
    else
        playerData = nil
        playerLoaded = false
        isLoggedIn = false
    end
end)

RegisterNetEvent("pw_inventory:client:SetupUI")
AddEventHandler("pw_inventory:client:SetupUI", function(data)
    PWBase.Inventory.Setup:Primary(data)
end)

RegisterNetEvent("pw_inventory:client:SetupSecondUI")
AddEventHandler("pw_inventory:client:SetupSecondUI", function(data)
    PWBase.Inventory.Setup:Secondary(data)
end)

RegisterNetEvent("pw_inventory:client:RefreshInventory")
AddEventHandler("pw_inventory:client:RefreshInventory", function()
    PWBase.Inventory.Load:Personal()
    
    if trunkOpen then
        local veh = PWBase.Inventory.Checks:Vehicle()
        if veh and IsEntityAVehicle(veh) then
            local plate = GetVehicleNumberPlateText(veh)
            if GetVehicleDoorLockStatus(veh) == 1 then
                SetVehicleDoorOpen(veh, 5, true, false)
                PWBase.Inventory.Load:Secondary()
            end
        end
    elseif secondaryInventory ~= nil then
        PWBase.Inventory.Load:Secondary()
    end
end)

RegisterNetEvent("pw_inventory:client:RefreshInventory2")
AddEventHandler("pw_inventory:client:RefreshInventory2", function(origin, destination)
    if (myInventory ~= nil and origin ~= nil and myInventory.type == origin.type and myInventory.owner == origin.owner) or
    (myInventory ~= nil and myInventory.type == destination.type and myInventory.owner == destination.owner) or
    (secondaryInventory ~= nil and origin ~= nil and secondaryInventory.type == origin.type and secondaryInventory.owner == origin.owner) or
    (secondaryInventory ~= nil and secondaryInventory.type == destination.type and secondaryInventory.owner == destination.owner) then
        PWBase.Inventory.Load:Personal()
        
        if trunkOpen then
            local veh = PWBase.Inventory:Vehicle()
            if veh and IsEntityAVehicle(veh) then
                local plate = GetVehicleNumberPlateText(veh)
                if GetVehicleDoorLockStatus(veh) == 1 then
                    SetVehicleDoorOpen(veh, 5, true, false)
                    PWBase.Inventory.Load:Secondary()
                end
            end
        elseif secondaryInventory ~= nil then
            PWBase.Inventory.Load:Secondary()
        end
    end
end)

RegisterNetEvent("pw_inventory:client:CloseUI")
AddEventHandler("pw_inventory:client:CloseUI", function()
    PWBase.Inventory.Close:Instantly()
end)

RegisterNetEvent("pw_inventory:client:CloseUI2")
AddEventHandler("pw_inventory:client:CloseUI2", function(owner)
    if secondaryInventory.type == owner.type and secondaryInventory.owner == owner.owner then
    PWBase.Inventory.Close:Instantly()
    end
end)

RegisterNetEvent("pw_inventory:client:CloseSecondary")
AddEventHandler("pw_inventory:client:CloseSecondary", function(owner)
    if secondaryInventory == nil or (secondaryInventory.type == owner.type and secondaryInventory.owner == owner.owner) then
        PWBase.Inventory.Close:Secondary()
    end
end)

RegisterNUICallback("NUIFocusOff",function()
    PWBase.Inventory.Close:Normal()
end)

RegisterNUICallback("GetSurroundingPlayers", function(data, cb)
    local coords = GetEntityCoords(PlayerPedId(), true)
    local players = {}

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local ped = GetPlayerPed(player) 
            local targetCoords = GetEntityCoords(ped)
            local distance = #(vector3(targetCoords.x, targetCoords.y, targetCoords.z) - coords)

            if distance <= 3.0 then
                table.insert(players, {
                    name = GetPlayerName(player),
                    id = GetPlayerServerId(player)
                })
            end
        end
	end

    SendNUIMessage({
        action = "nearPlayers",
        players = players
    })

    cb("ok")
end)

RegisterNUICallback("MoveToEmpty", function(data, cb)
    TriggerServerEvent('pw_inventory:server:MoveToEmpty', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("SplitStack", function(data, cb)
    TriggerServerEvent('pw_inventory:server:SplitStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem, data.moveQty)
    cb("ok")
end)

RegisterNUICallback("CombineStack", function(data, cb)
    TriggerServerEvent('pw_inventory:server:CombineStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("MoveQuantity", function(data, cb)
    TriggerServerEvent('pw_inventory:server:CombineStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem, data.moveQty)
    cb("ok")
end)

RegisterNUICallback("TopoffStack", function(data, cb)
    TriggerServerEvent('pw_inventory:server:TopoffStack', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("SwapItems", function(data, cb)
    TriggerServerEvent('pw_inventory:server:SwapItems', data.originOwner, data.originItem, data.destinationOwner, data.destinationItem)
    cb("ok")
end)

RegisterNUICallback("UseItem", function(data, cb)
    TriggerServerEvent("pw_inventory:useItem", data.item)
    cb(data.item.closeUi)
end)

RegisterNUICallback("DropItem", function(data, cb)
    if IsPedSittingInAnyVehicle(PlayerPedId()) then
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('pw_inventory:server:Drop', data.item, data.qty, coords)

    PWBase.Inventory:ItemUsed({ item = data.item, qty = data.qty, message = 'Item Dropped' })

    cb("ok")
end)

RegisterNUICallback("GiveItem", function(data, cb)
    TriggerServerEvent('pw_inventory:server:GiveItem', data.target, data.item, data.count)
    cb("ok")
end)

AddEventHandler('mythic_base:shared:ComponentRegisterReady', function()
    exports['mythic_base']:CreateComponent('Inventory', PWBase.Inventory)
end)