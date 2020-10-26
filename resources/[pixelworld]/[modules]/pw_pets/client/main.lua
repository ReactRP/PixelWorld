local Pets, blips, bowls = {}, {}, {}
local showMarker, waitingKey, drawingText = false, false, false
local menuName, checkingGuarding, searchingBowls = false, false, false
local petNotification, recordedData = nil, nil
local selectedPet = 0
local ownerHash, dogHash, thievesHash, civHash

PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil

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
            for k,v in pairs(Config.Pets) do
                DoRequestModel(v.hash)
            end
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            _, ownerHash = AddRelationshipGroup('OWNER')
            _, dogHash = AddRelationshipGroup('DOG')
            _, thievesHash = AddRelationshipGroup('THIEVES')
            CreateBlips()
            characterLoaded = true
        else
            playerData = data
        end
    else
        RemoveBlips()
        playerData = nil
        characterLoaded = false
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()

            for k,v in pairs(Pets) do
                if v.ped ~= nil and v.ped ~= 0 then
                    if IsPedDeadOrDying(v.ped, 1) or IsPedFatallyInjured(v.ped) or GetEntityHealth(v.ped) <= 100 then
                        DeletePed(v.ped)
                        Pets[k].ped = 0
                        TriggerServerEvent('pw_pets:server:createPed', v.id, 0)
                        ToggleChip(k, false)
                        if selectedPet == v.id then
                            showNotificationNui(false)
                        end
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() == res then
        for k,v in pairs(Pets) do
            DeletePed(v.ped)
        end
        RemoveBlips()
    end
end)

AddEventHandler('pw_interact:closeMenu', function()
    Wait(200)
    if menuName then
        TriggerEvent('pw_pets:client:setName', menuName)
    end
end)

RegisterNetEvent('pw_pets:client:getPets')
AddEventHandler('pw_pets:client:getPets', function(table)
    Pets = table
end)

RegisterNetEvent('pw_pets:client:newPet')
AddEventHandler('pw_pets:client:newPet', function(pet)
    table.insert(Pets, pet)
end)

RegisterNetEvent('pw_pets:client:updateNeeds')
AddEventHandler('pw_pets:client:updateNeeds', function(id, need)
    local petPos = GetPet(id)
    Pets[petPos].needs = need
end)

RegisterNetEvent('pw_pets:client:updateName')
AddEventHandler('pw_pets:client:updateName', function(id, name)
    menuName = false
    local petPos = GetPet(id)
    Pets[petPos].name = name
    OpenOwnerMenu()
end)

RegisterNetEvent('pw_pets:client:ownerMenu')
AddEventHandler('pw_pets:client:ownerMenu', function()
    if #Pets > 0 then
        OpenOwnerMenu()
    else
        exports.pw_notify:SendAlert('error', 'You don\'t have any pets')
    end
end)

RegisterNetEvent('pw_pets:client:setName')
AddEventHandler('pw_pets:client:setName', function(pet, item)
    local petPos = GetPet(pet)
    local deleteItem = item or false
    local form = {
        { ['type'] = "text", ['label'] = 'Choose a name for your pet', ['name'] = 'newName'},
        { ['type'] = "hidden", ['name'] = "petId", ['value'] = pet },
        { ['type'] = "hidden", ['name'] = "deleteItem", ['data'] = deleteItem },
    }

    TriggerEvent('pw_interact:generateForm', 'pw_pets:server:setName', 'server', form, "Choose a name for your pet | "..Pets[petPos].name)
    menuName = pet
end)

RegisterNetEvent('pw_pets:client:useAction')
AddEventHandler('pw_pets:client:useAction', function(data)
    if data.type == 'call' then
        if Pets[data.pet].ped == 0 or Pets[data.pet].ped == nil then
            SpawnPet(data.pet, true)
        else
            CallPet(data.pet)
        end
    elseif data.type == 'sendAway' then
        if Pets[data.pet].ped then
            SendAway(data.pet)
        end
    elseif data.type == 'stay' then
        Stay(data.pet)    
    elseif data.type == 'guard' then
        GuardHouse(data.pet)
    elseif data.type == 'fetch' then
        Fetch(data.pet)
    else
        Tricks(data.pet, data.type)
    end
    TriggerEvent('pw_pets:client:actionsMenu', data.pet)
end)

RegisterNetEvent('pw_pets:client:actionsMenu')
AddEventHandler('pw_pets:client:actionsMenu', function(pet)
    local menu = {}
    if Pets[pet].ped == nil or Pets[pet].ped == 0 then
        table.insert(menu, { ['label'] = 'Call close', ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'call'}, ['triggertype'] = 'client', ['color'] = 'primary' })
    else
        local tricksSub = {}
        table.insert(tricksSub, { ['label'] = (Pets[pet].stay and 'Stay: Staying' or 'Stay: Following you'), ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'stay'}, ['triggertype'] = 'client', ['color'] = 'primary' })

        if Config.Pets[GetPetByHash(Pets[pet].hash)].actions.sit then
            table.insert(tricksSub, { ['label'] = (Pets[pet].sit and 'Sit: Sitting' or 'Sit: Not sitting'), ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'sit'}, ['triggertype'] = 'client', ['color'] = 'primary'})
        end
        if Config.Pets[GetPetByHash(Pets[pet].hash)].actions.lay then
            table.insert(tricksSub, { ['label'] = (Pets[pet].lay and 'Lay: Laying down' or 'Lay: Standing'), ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'lay'}, ['triggertype'] = 'client', ['color'] = 'primary'})
        end
        if Config.Pets[GetPetByHash(Pets[pet].hash)].actions.beg then
            table.insert(tricksSub, { ['label'] = (Pets[pet].beg and 'Beg: Begging' or 'Beg: Not begging'), ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'beg'}, ['triggertype'] = 'client', ['color'] = 'primary'})
        end
        if Config.Pets[GetPetByHash(Pets[pet].hash)].actions.paw then
            table.insert(tricksSub, { ['label'] = (Pets[pet].paw and 'Paw: Giving paw' or 'Paw: Not giving paw'), ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'paw'}, ['triggertype'] = 'client', ['color'] = 'primary'})
        end
        table.insert(tricksSub, { ['label'] = 'Fetch ball', ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'fetch'}, ['triggertype'] = 'client', ['color'] = 'primary'})

        table.insert(menu, { ['label'] = 'Call close', ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'call'}, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Send away', ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'sendAway'}, ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = 'Guard near Owned Property', ['action'] = 'pw_pets:client:useAction', ['value'] = {pet = pet, type = 'guard'}, ['triggertype'] = 'client', ['color'] = 'primary'})
        table.insert(menu, { ['label'] = 'Tricks', ['action'] = '', ['value'] = '', ['triggertype'] = 'client', ['color'] = 'primary', ['subMenu'] = tricksSub })
        if Pets[pet].ped ~= 0 and Pets[pet].ped ~= nil then
            table.insert(menu, { ['label'] = (Pets[pet].chipStatus and 'GPS: Enabled' or 'GPS: Disabled'), ['action'] = 'pw_pets:client:toggleChip', ['value'] = pet, ['triggertype'] = 'client', ['color'] = (not Pets[pet].chip and "danger disabled" or (Pets[pet].chipStatus and 'success' or 'danger')) })
        end
    end
    
    TriggerEvent('pw_interact:generateMenu', menu, 'Actions | '..Pets[pet].name)
end)

function ToggleChip(pet, status)
    if status then
        Pets[pet].blip = AddBlipForEntity(Pets[pet].ped)
        SetBlipSprite(Pets[pet].blip, 273)
        ShowHeadingIndicatorOnBlip(Pets[pet].blip, true) 
        SetBlipRotation(Pets[pet].blip, math.ceil(GetEntityHeading(Pets[pet].ped)))
        SetBlipScale(Pets[pet].blip, 0.85) 
        SetBlipAsShortRange(Pets[pet].blip, true)
        SetBlipColour(Pets[pet].blip, 6)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("~b~[Pet Tracker] ~s~"..Pets[pet].name) -- set blip's "name"
        EndTextCommandSetBlipName(Pets[pet].blip)
    else
        RemoveBlip(Pets[pet].blip)
        Pets[pet].blip = 0
    end
    TriggerEvent('pw_pets:client:actionsMenu', pet)
end

RegisterNetEvent('pw_pets:client:toggleChip')
AddEventHandler('pw_pets:client:toggleChip', function(pet)
    Pets[pet].chipStatus = not Pets[pet].chipStatus
    ToggleChip(pet, Pets[pet].chipStatus)
end)

function GetPet(rec)
    for k,v in pairs(Pets) do
        if v.id == rec then
            return k
        end
    end

    return 1
end

function Fetch(pet)
    if not Pets[pet].fetch then
        local ped = Pets[pet].ped
        local pedCoords = GetEntityCoords(ped)
        Pets[pet].ballObject = GetClosestObjectOfType(pedCoords, 190.0, GetHashKey('w_am_baseball'))

        if DoesEntityExist(Pets[pet].ballObject) then
            Pets[pet].objCoords = GetEntityCoords(Pets[pet].ballObject)
            TaskGoToCoordAnyMeans(ped, Pets[pet].objCoords, 5.0, 0, 0, 786603, 0xbf800000)
            local atCoords = false
            while not atCoords do
                Wait(500)
                local dogCoords = GetEntityCoords(ped)
                local dist = #(dogCoords - Pets[pet].objCoords)
                if dist < 1.0 then atCoords = true; end
            end
            Wait(50)

            local GroupHandle = GetPlayerGroup(PlayerId())
            SetGroupSeparationRange(GroupHandle, 1.9)
            SetPedNeverLeavesGroup(ped, false)
            Pets[pet].grab = true
            Pets[pet].fetch = true
            TriggerFetch(pet)
        end
    end
end

function TriggerFetch(pet)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30)
            if characterLoaded and Pets[pet].fetch then
                if Pets[pet].grab then
                    local coords1 = GLOBAL_COORDS
                    local coords2 = GetEntityCoords(Pets[pet].ped)
                    local distance  = #(Pets[pet].objCoords - coords2)
                    if distance < 0.5 then
                        local boneIndex = GetPedBoneIndex(Pets[pet].ped, 17188)
                        AttachEntityToEntity(Pets[pet].ballObject, Pets[pet].ped, boneIndex, 0.120, 0.010, 0.010, 5.0, 150.0, 0.0, true, true, false, true, 1, true)
                        TaskGoToCoordAnyMeans(Pets[pet].ped, coords1, 5.0, 0, 0, 786603, 0xbf800000)
                        Pets[pet].grab = false
                        Pets[pet].bring = true
                    end
                end

                if Pets[pet].bring then
                    local coords1 = GLOBAL_COORDS
                    local coords2 = GetEntityCoords(Pets[pet].ped)
                    local distance2 = #(coords1 - coords2)

                    if distance2 < 1.5 then
                        DetachEntity(Pets[pet].ballObject,false,false)
                        Citizen.Wait(50)
                        SetEntityAsMissionEntity(Pets[pet].ballObject)
                        DeleteEntity(Pets[pet].ballObject)
                        Pets[pet].ballObject = 0
                        GiveWeaponToPed(GLOBAL_PED, GetHashKey("WEAPON_BALL"), 1, false, true)
                        local GroupHandle = GetPlayerGroup(PlayerId())
                        SetGroupSeparationRange(GroupHandle, 999999.9)
                        SetPedNeverLeavesGroup(Pets[pet].ped, true)
                        SetPedAsGroupMember(Pets[pet].ped, GroupHandle)
                        Pets[pet].bring = false
                        Pets[pet].fetch = false
                    end
                end
            end
        end
    end)
end

function Tricks(pet, type)

    local animDict, anim, flags

    if Pets[pet].hash == 351016938 then -- rott
        if type == 'sit' then
            animDict = 'creatures@rottweiler@amb@world_dog_sitting@enter'
            anim = 'enter'
            flags = 2
        elseif type == 'beg' then
            animDict = 'creatures@rottweiler@tricks@'
            anim = 'beg_loop'
            flags = 01
        elseif type == 'lay' then
            animDict = 'creatures@rottweiler@amb@sleep_in_kennel@'
            anim = 'sleep_in_kennel'
            flags = 2
        elseif type == 'paw' then
            animDict = 'creatures@rottweiler@tricks@'
            anim = 'paw_right_loop_right'
            flags = 01
        end
    elseif Pets[pet].hash == 1832265812 then -- pug
        if type == 'sit' then
            animDict = 'creatures@pug@amb@world_dog_sitting@enter'
            anim = 'enter'
            flags = 2
        elseif type == 'lay' then
            animDict = 'creatures@pug@move'
            anim = 'dying'
            flags = 2
        end
    else
        if type == 'sit' then
            animDict = 'creatures@dog@move'
            anim = 'sit_loop'
            flags = 2
        elseif type == 'beg' then
            animDict = 'creatures@dog@move'
            anim = 'beg_loop'
            flags = 01
        elseif type == 'lay' then
            animDict = 'creatures@dog@move'
            anim = 'dying'
            flags = 2
        elseif type == 'paw' then
            animDict = 'creatures@rottweiler@tricks@'
            anim = 'paw_right_loop_right'
            flags = 01
        end
    end

    if Pets[pet].trick == type or not Pets[pet].trick then
        if not Pets[pet][type] then
            Pets[pet][type] = true
            Pets[pet].trick = type
            DoRequestAnimSet(animDict)
            TaskPlayAnim(Pets[pet].ped, animDict, anim, 1.0, 1.0, -1, flags, 1.0, 0, 0, 0)
            Citizen.CreateThread(function()
                while true do
                    Citizen.Wait(500)
                    if characterLoaded then
                        if Pets[pet][type] then
                            if not IsEntityPlayingAnim(Pets[pet].ped, animDict, anim, 2) then
                                TaskPlayAnim(Pets[pet].ped, animDict, anim, 1.0, 1.0, -1, flags, 1.0, 0, 0, 0)
                            end
                        end
                    end
                end
            end)
        else
            Pets[pet][type] = false
            Pets[pet].trick = false
            ClearPedTasks(Pets[pet].ped)
        end
    else
        exports.pw_notify:SendAlert('error', 'This pet is already performing a trick')
    end
end

RegisterNetEvent('pw_pets:client:guardHouse')
AddEventHandler('pw_pets:client:guardHouse', function(data)
    StartGuarding(data.pet, data.house)
end)

RegisterNetEvent('pw_pets:useItem')
AddEventHandler('pw_pets:useItem', function(data)
    local ped = GLOBAL_PED

    if not IsPedInAnyVehicle(ped) then
        if data.item == "dogbowl" then
            if selectedPet ~= 0 then
                local usePet = selectedPet
                local hasWater = PW.Game.CheckInventory('water')
                if hasWater > 0 then
                    local bowlEmpty = GetHashKey('pw-prop-dog-bowl-empty')
                    local bowlFull = GetHashKey('pw-prop-dog-bowl-full')
                    local bowlEmptyObj, bowlFullObj, emptyCoords, frontBowl
                    while (not HasModelLoaded(bowlEmpty)) do
                        RequestModel(bowlEmpty)
                        Wait(1)
                    end

                    while (not HasModelLoaded(bowlFull)) do
                        RequestModel(bowlFull)
                        Wait(1)
                    end

                    Citizen.CreateThread(function()
                        if DoesEntityExist(ped) then
                            bowlEmptyObj = CreateObject(bowlEmpty, 0, 0, 0, true, true, true)
                            AttachEntityToEntity(bowlEmptyObj, ped, GetPedBoneIndex(ped, 57005), 0.22, 0, -0.075, 20.0, 359.9, 90.0, true, true, false, true, 1, true)
                            Citizen.Wait(1000)
                            DeleteEntity(bowlEmptyObj)
                            local frontPed = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.85, 0.0)
                            frontBowl = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.35, 0.0)
                            local _, frontPedZ = GetGroundZFor_3dCoord(frontPed.x, frontPed.y, frontPed.z, 0)
                            DetachEntity(bowlEmptyObj, true, true)
                            bowlEmptyObj = CreateObjectNoOffset(bowlEmpty, frontPed.x, frontPed.y, frontPedZ, true, true, true) 		
                            SetEntityCoords(bowlEmptyObj, frontPed.x, frontPed.y, frontPedZ, 0.0, 0.0, 0.0, false)
                            SetEntityAsMissionEntity(bowlEmptyObj, true, true)
                            FreezeEntityPosition(bowlEmptyObj, true)
                            emptyCoords = GetEntityCoords(bowlEmptyObj)
                            Citizen.Wait(3000)
                        end
                    end)
                    TriggerEvent('pw:progressbar:progress',
                        {
                            name = 'preparing_bowl',
                            duration = 2500,
                            label = 'Preparing bowl',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = false,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "weapons@projectile@sticky_bomb",
                                anim = "plant_floor",
                                flags = 0,
                            }
                        },
                        function(status)
                            if not status then
                                while not DoesEntityExist(bowlEmptyObj) do Wait(0); end
                                ClearPedTasks(ped)
                                TaskGoToCoordAnyMeans(ped, frontBowl.x, frontBowl.y, frontBowl.z, 5.0, 0, 0, 786603, 0xbf800000)
                                Wait(500)
                                TaskTurnPedToFaceEntity(ped, bowlEmptyObj, -1)
                                TriggerEvent('pw:progressbar:progress',
                                    {
                                        name = 'filling_bowl',
                                        duration = 5000,
                                        label = 'Filling bowl with water',
                                        useWhileDead = false,
                                        canCancel = false,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = false,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = 'amb@medic@standing@kneel@idle_a',
                                            anim = 'idle_a',
                                            flags = 01,
                                        }
                                    },
                                    function(status)
                                        if not status then
                                            ClearPedTasks(ped)
                                            DeleteEntity(bowlEmptyObj)

                                            local bowlFullObj = CreateObjectNoOffset(bowlFull, emptyCoords.x, emptyCoords.y, emptyCoords.z, true, true, true) 		
                                            DetachEntity(bowlFullObj, true, true)
                                            SetEntityAsMissionEntity(bowlFullObj, true, true)
                                            FreezeEntityPosition(bowlFullObj, true)

                                            -- make pet drink it
                                            Wait(1000)
                                            local petId = GetPet(usePet)
                                            TaskGoToCoordAnyMeans(Pets[petId].ped, emptyCoords.x, emptyCoords.y, emptyCoords.z, 3.0, 0, 0, 786603, 0xbf800000)
                                            local walking = true
                                            while walking do
                                                Citizen.Wait(100)
                                                local dogCoords = GetEntityCoords(Pets[petId].ped)
                                                local distToBowl = #(dogCoords - emptyCoords)
                                                if distToBowl <= 0.6 then
                                                    walking = false
                                                end
                                            end
                                            TaskStandStill(Pets[petId].ped, 5000)
                                            Wait(5000)
                                            DeleteEntity(bowlFullObj)
                                            bowlEmptyObj = CreateObjectNoOffset(bowlEmpty, emptyCoords.x, emptyCoords.y, emptyCoords.z, true, true, true) 		
                                            SetEntityAsMissionEntity(bowlEmptyObj, true, true)
                                            FreezeEntityPosition(bowlEmptyObj, true)
                                            table.insert(bowls, { ['obj'] = bowlEmptyObj, ['coords'] = emptyCoords })
                                            if not searchingBowls then
                                                searchingBowls = true
                                                SearchBowls()
                                            end
                                            recordedData = nil
                                            TriggerServerEvent('pw_pets:server:useItem', usePet, data)
                                        end
                                    end)
                            end
                        end)
                else
                    exports.pw_notify:SendAlert('error', 'You don\'t have bottled water to fill the bowl', 5000)
                end
            end
        elseif data.item == "cheapdogfood" or data.item == "premiumdogfood" then
            recordedData = nil
            TriggerServerEvent('pw_pets:server:useItem', selectedPet, data)
        elseif data.item == 'dogtracker' then
            TriggerEvent('pw_pets:client:addChip', data)
        elseif data.item == 'dogcollar' then
            if selectedPet ~= 0 then
                TriggerEvent('pw_pets:client:setName', selectedPet, data)
            else
                exports.pw_notify:SendAlert('error', 'No pet nearby', 5000)
            end
        end
    end
end)

function SearchBowls()
    Citizen.CreateThread(function()
        while searchingBowls and #bowls > 0 do
            Citizen.Wait(200)

            for k,v in pairs(bowls) do
                local playerCoords = GLOBAL_COORDS
                local dist = #(playerCoords - v.coords)
                if dist < 1.2 then
                    if not drawingText and selectedPet == 0 then
                        drawingText = k
                        DrawText()
                    elseif drawingText == k and selectedPet ~= 0 then
                        drawingText = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                    if not nearBowl or nearBowl ~= k then
                        nearBowl = k
                        WaitingBowl(nearBowl)
                    end
                else
                    if nearBowl == k then
                        nearBowl = false
                    end
                    if drawingText == k then
                        drawingText = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                end
            end
        end
        searchingBowls = false
        nearBowl = false
    end)
end

function DrawText()
    local title, message, icon

    title = 'Dog Bowl'
    message = '<b><span style="font-size:18px">[ <span class="text-danger">E</span> ] <span class="text-primary">PICK UP EMPTY BOWL</span></span></b>'
    icon = 'fad fa-bone'
    
    TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
end

function WaitingBowl(k)
    Citizen.CreateThread(function()
        while nearBowl == k do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                PickupBowl(k)
            end
        end
    end)
end

function PickupBowl(k)    
    if DoesEntityExist(bowls[k].obj) then
        TriggerEvent('pw:progressbar:progress',
            {
                name = 'pickup_bowl',
                duration = 1000,
                label = 'Picking up empty bowl',
                useWhileDead = false,
                canCancel = false,
                controlDisables = {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = false,
                },
                animation = {
                    animDict = "weapons@projectile@sticky_bomb",
                    anim = "plant_floor",
                    flags = 0,
                },
            },
            function(status)
                if not status then
                    DeleteEntity(bowls[k].obj)
                    TriggerServerEvent('pw_pets:server:returnEmptyBowl')
                    bowls[k] = nil
                    nearBowl = false
                    if drawingText == k then
                        drawingText = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end                    
                end
            end)
    end
    
end

RegisterNetEvent('pw_pets:client:setPetAlert')
AddEventHandler('pw_pets:client:setPetAlert', function(house, coords, thief)
    for k,v in pairs(Pets) do
        if DoesEntityExist(v.ped) then
            if v.guarding == house then
                local thiefPed = GetPlayerPed(GetPlayerFromServerId(thief))
                SetPedRelationshipGroupHash(thiefPed, thievesHash)
                TaskCombatPed(v.ped, thiefPed, 0, 16)
                break
            end
        end
    end
end)

RegisterNetEvent('pw_pets:client:setRelationship')
AddEventHandler('pw_pets:client:setRelationship', function(group, ped)
    SetPedRelationshipGroupHash(GLOBAL_PED, group)
    SetPedRelationshipGroupHash(NetToPed(ped), group)
end)

function StartGuarding(pet, house)
    local GroupHandle = GetPlayerGroup(PlayerId())
    local pedCoords = GLOBAL_COORDS
    local entrance = json.decode(house.location)
    TaskGoToCoordAnyMeans(Pets[pet].ped, entrance.x, entrance.y, entrance.z, 5.0, 0, 0, 786603, 0xbf800000)
    
    local atCoords = false
    local lastDist = 0
    local times = 0
    while not atCoords do
        Wait(500)
        local dogCoords = GetEntityCoords(Pets[pet].ped)
        local dist = #(dogCoords - vector3(entrance.x, entrance.y, entrance.z))
        if dist == lastDist then
            if times == 5 then
                atCoords = true
            else
                times = times + 1 
            end
        else
            lastDist = dist
        end
        if dist < 3.0 then atCoords = true; end
    end
    Pets[pet].guarding = house.property_id
    Wait(50)
    ClearPedTasks(Pets[pet].ped)
    Wait(150)
    TaskWanderInArea(Pets[pet].ped, entrance.x, entrance.y, entrance.z, 3.0, 3.0, 3.0)
    RemovePedFromGroup(Pets[pet].ped)
    SetPedCombatAbility(Pets[pet].ped, 2)
    SetPedCombatAttributes(Pets[pet].ped, 46)
    SetPedAlertness(Pets[pet].ped, 3)
    SetPedSeeingRange(Pets[pet].ped, 30.0)
    SetPedVisualFieldPeripheralRange(Pets[pet].ped, 15.0)
    SetPedFleeAttributes(Pets[pet].ped, 0, 0)

    if not checkingGuarding and characterLoaded then
        checkingGuarding = true            
        Citizen.CreateThread(function()
            while Pets[pet].guarding do
                Citizen.Wait(5000)
                local dCoords = GetEntityCoords(Pets[pet].ped)
                local dDist = #(dCoords - vector3(entrance.x, entrance.y, entrance.z))
                if dDist > 30.0 then
                    StartGuarding(pet, house)
                end
            end
        end)
    end
end

function GuardHouse(pet)
    local Houses = {}
    PW.TriggerServerCallback('pw_pets:server:getOwnedProperties', function(props)
        Houses = props    

        if Houses[1] ~= nil then
            local pedCoords = GLOBAL_COORDS
            local menu = {}
            for k,v in pairs(Houses) do
                local entranceCoords = json.decode(v.location)
                local dist = #(pedCoords - vector3(entranceCoords.x, entranceCoords.y, entranceCoords.z))

                if dist < Config.GuardHouseMaxDistance then
                    table.insert(menu, { ['label'] = v.name, ['action'] = 'pw_pets:client:guardHouse', ['value'] = {pet = pet, house = Houses[k]}, ['triggertype'] = 'client', ['color'] = 'primary' })
                end
            end
            
            if #menu > 0 then
                TriggerEvent('pw_interact:generateMenu', menu, 'Pet Menu | '..Pets[pet].name)
            else
                exports.pw_notify:SendAlert('error', 'Couldn\'t find any owned properties nearby')
            end
        else
            exports.pw_notify:SendAlert('error', 'You don\'t own any property')
        end
    end)
end

function Stay(pet)
    local GroupHandle = GetPlayerGroup(PlayerId())
    if Pets[pet].stay then
        Pets[pet].stay = false
        ClearPedTasks(Pets[pet].ped)
    else
        Pets[pet].stay = true
        TaskStandStill(Pets[pet].ped, -1)
    end
    TriggerEvent('pw_pets:client:actionsMenu', pet)
end

function SendAway(pet)
    local playerPed = GLOBAL_PED
    local pedToDelete = Pets[pet].ped
    Pets[pet].ped = 0
    showNotificationNui(false)
    TriggerServerEvent('pw_pets:server:createPed', Pets[pet].id, 0)
    Wait(150)
    TaskSmartFleePed(pedToDelete, playerPed, 1000.0, -1, true, true)
    Citizen.SetTimeout(15000, function()
        DeletePed(pedToDelete)
    end)
end

function SpawnPet(pet, create)
    local playerPed = GLOBAL_PED
    local coords = GLOBAL_COORDS

    DoRequestAnimSet('rcmnigel1c')
	TaskPlayAnim(playerPed, 'rcmnigel1c', 'hailing_whistle_waive_a', 8.0, -8, -1, 120, 0, false, false, false)

    if create then
        local ped = CreatePed(28, Pets[pet].hash, coords.x + (math.random(0,40) + 0.0), coords.y + (math.random(0,40) + 0.0), coords.z - 0.984, 1, 1)
        SetPedComponentVariation(ped, 4, 0, Pets[pet].color, 0) -- Pug
        Pets[pet].ped = ped
        TriggerServerEvent('pw_pets:server:createPed', Pets[pet].id, ped)
        SetEntityHealth(Pets[pet].ped, Pets[pet].health)
    else
        local dogCoords = GetEntityCoords(Pets[pet].ped)
        local dist = #(coords - dogCoords)
        if dist > 100.0 then
            SetEntityCoords(Pets[pet].ped, coords.x + (math.random(0,40) + 0.0), coords.y + (math.random(0,40) + 0.0), coords.z - 0.984, 1, 0, 0, 1)
        end
        
        FreezeEntityPosition(Pets[pet].ped, false)
        TaskGoToEntity(Pets[pet].ped, playerPed, -1, 5.0, 5.0, 1073741824, 0)
    end

    SetPedPathCanDropFromHeight(Pets[pet].ped, true)
    SetPedPathPreferToAvoidWater(Pets[pet].ped, true)
    Pets[pet].guarding = false
    Pets[pet].stay = false
    Pets[pet].sit = false

    Wait(150)
        
    SetPedRelationshipGroupHash(GLOBAL_PED, ownerHash)
    SetPedRelationshipGroupHash(Pets[pet].ped, dogHash)
	SetRelationshipBetweenGroups(0, ownerHash, dogHash)
    SetRelationshipBetweenGroups(5, ownerHash, thievesHash)
    --SetRelationshipBetweenGroups(3, ownerHash, civHash)
    SetRelationshipBetweenGroups(0, dogHash, ownerHash)
    SetRelationshipBetweenGroups(5, dogHash, thievesHash)
    --SetRelationshipBetweenGroups(3, dogHash, civHash)
    SetRelationshipBetweenGroups(5, thievesHash, dogHash)
    SetRelationshipBetweenGroups(5, thievesHash, ownerHash)
    --SetRelationshipBetweenGroups(3, thievesHash, civHash)
    --SetRelationshipBetweenGroups(3, civHash, ownerHash)
    --SetRelationshipBetweenGroups(3, civHash, dogHash)
    --SetRelationshipBetweenGroups(3, civHash, thievesHash)
    
    local GroupHandle = GetPlayerGroup(PlayerId())
    SetPedAsGroupLeader(playerPed, GroupHandle)
    SetPedAsGroupMember(Pets[pet].ped, GroupHandle)
    SetPedNeverLeavesGroup(Pets[pet].ped, true)
    SetPedCanBeTargetted(Pets[pet].ped, false)
    SetEntityAsMissionEntity(Pets[pet].ped, true,true)
end

function CallPet(pet)
    if DoesEntityExist(Pets[pet].ped) and not IsPedDeadOrDying(Pets[pet].ped, 1) then
        SpawnPet(pet)
    else
        SpawnPet(pet, true)
    end
end

RegisterNetEvent('pw_pets:client:updateChip')
AddEventHandler('pw_pets:client:updateChip', function(id, state)
    local petPos = GetPet(id)
    Pets[petPos].chip = state
end)

RegisterNetEvent('pw_pets:client:addChip')
AddEventHandler('pw_pets:client:addChip', function(data)
    if selectedPet ~= 0 then
        local usePet = selectedPet
        local petId = GetPet(usePet)

        if not Pets[petId].chip then
            TaskStandStill(Pets[petId].ped, 5000)
            TriggerEvent('pw:progressbar:progress',
                {
                    name = 'apply_gps',
                    duration = 5000,
                    label = 'Applying GPS tracker',
                    useWhileDead = false,
                    canCancel = false,
                    controlDisables = {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = false,
                    },
                    animation = {

                    },
                },
                function(status)
                    if not status then
                        TriggerServerEvent('pw_pets:server:addChip', usePet)
                        TriggerServerEvent('pw_pets:server:removeThis', data)
                        exports.pw_notify:SendAlert('success', 'GPS Tracker applied on '..Pets[petId].name, 5000)
                    end
                end)
        else
            exports.pw_notify:SendAlert('error', 'This pet already has a GPS tracker', 5000)
        end
    else
        exports.pw_notify:SendAlert('error', 'No pet nearby', 5000)
    end
end)

function OpenOwnerMenu()
    local menu = {}
    for k,v in pairs(Pets) do
        table.insert(menu, { ['label'] = v.name .. ' ('..GetPetByHash(v.hash)..')', ['action'] = 'pw_pets:client:actionsMenu', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'primary' })
    end

    TriggerEvent('pw_interact:generateMenu', menu, 'My Pets')
end

RegisterNetEvent('pw_pets:client:checkBreed')
AddEventHandler('pw_pets:client:checkBreed', function(dog)

end)

function OpenPetMenu()
    local menu = {}
    for k,v in pairs(Config.Pets) do
        local subMenu = {}
        if k == 'Pug' then
            for j,b in pairs(Config.PugColors) do
                table.insert(subMenu, { ['label'] = b.label, ['action'] = 'pw_pets:server:buyPet', ['value'] = { ['breed'] = k, ['color'] = b.id }, ['triggertype'] = 'server', ['color'] = 'primary' })
            end
        elseif k == 'Westie' then
            for j,b in pairs(Config.WestieColors) do
                table.insert(subMenu, { ['label'] = b.label, ['action'] = 'pw_pets:server:buyPet', ['value'] = { ['breed'] = k, ['color'] = b.id }, ['triggertype'] = 'server', ['color'] = 'primary' })
            end
        end
        table.insert(menu, { ['label'] = k .. ' ($'..v.price..')', ['action'] = 'pw_pets:server:buyPet', ['value'] = k, ['triggertype'] = 'server', ['color'] = 'primary' })
        if k == 'Pug' or k == 'Westie' then menu[#menu]['subMenu'] = subMenu; end
    end
    
    TriggerEvent('pw_interact:generateMenu', menu, 'Pets')
end

function GetPetByHash(hash)
    local found = false
    for k,v in pairs(Config.Pets) do
        if v.hash == hash then
            return k
        end
    end
    return 0
end

function ShowMarker(type)
    Citizen.CreateThread(function()
        while showMarker == type do
            Citizen.Wait(1)
            DrawMarker(Config.Markers[type].markerType, Config.Locations[type], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Markers[type].markerSize.x, Config.Markers[type].markerSize.y, Config.Markers[type].markerSize.z, Config.Markers[type].markerColor.r, Config.Markers[type].markerColor.g, Config.Markers[type].markerColor.b, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end

function WaitingKeys(type)
    Citizen.CreateThread(function()
        while waitingKey == type do
            Citizen.Wait(0)
            if IsControlJustPressed(0,38) then
                if type == 'shop' then
                    OpenPetMenu()
                end
            end
        end
    end)
end

function DeleteBowls()
    if bowls[1] ~= nil then
        for k,v in pairs(bowls) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
            end
        end
    end

    bowls = {}
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded then
            local pedCoords = GLOBAL_COORDS
            local dist
            for k,v in pairs(Config.Locations) do
                dist = #(pedCoords - v)
                if dist < Config.Markers[k].markerDraw then
                    if not showMarker then
                        showMarker = k
                        ShowMarker(k)
                    end
                    if dist < Config.KeyTrigger then
                        if not waitingKey then
                            waitingKey = k
                            WaitingKeys(k)
                        end
                    else
                        waitingKey = false
                    end
                else
                    showMarker = false
                end
            end
        end
    end
end)

function showNotificationNui(toggle, v)
    if toggle then
        currentHunger =    v.needs.hunger / Config.PetTickRates.maxValue.hunger * 100
        currentThirst =    v.needs.thirst / Config.PetTickRates.maxValue.thirst * 100
        currentExcercise = v.needs.excercise / Config.PetTickRates.maxValue.excercise * 100
        local sendInfo = {
            ['needs'] = { ['hunger'] = currentHunger, ['thirst'] = currentThirst, ['excercise'] = currentExcercise},
            ['health'] = GetEntityHealth(v.ped) - 100
        }
        SendNUIMessage({
            action = "showPet",
            info = sendInfo
        })
        selectedPet = v.id
    else
        SendNUIMessage({
            action = "hidePet",
        })
        selectedPet = 0
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and playerData then
            local playerCoords = GLOBAL_COORDS
            for k, v in pairs(Pets) do
                if v.ped ~= nil and v.ped ~= 0 then
                    local currentHealth = GetEntityHealth(v.ped)
                    if v.health ~= currentHealth then
                        v.health = currentHealth
                        TriggerServerEvent('pw_pets:server:updateHealth', v.id, v.health)
                    end

                    local petCoords = GetEntityCoords(v.ped)
                    local petDist = #(playerCoords - petCoords)
                    if petDist < 1.7 then
                        petNotification = k
                        if v.needs.hunger ~= recordedData then
                            recordedData = v.needs.hunger
                            showNotificationNui(true, v)
                        elseif v.needs.thirst ~= recordedData then
                            recordedData = v.needs.thirst
                            showNotificationNui(true, v)
                        end
                    else
                        if petNotification and petNotification == k then
                            showNotificationNui(false)
                            petNotification = nil
                            recordedData = nil
                        end
                    end
                end
            end
        end
    end
end)

function CreateBlips()
    for k,v in pairs(Config.Locations) do
        DrawBlips(k)
    end
end

function DrawBlips(type)
    if blips[type] ~= nil then
        RemoveBlip(blips[type])
        blips[type] = nil
    end

    local blip = AddBlipForCoord(Config.Locations[type].x, Config.Locations[type].y, Config.Locations[type].z)

    SetBlipSprite(blip, Config.Blips[type].blipSprite)
    SetBlipScale(blip, Config.Blips[type].blipScale)
    SetBlipColour(blip, Config.Blips[type].blipColor)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blips[type].text)
    EndTextCommandSetBlipName(blip)

    blips[type] = blip
end

function RemoveBlips()
    if blips ~= nil and #blips > 0 then
        for k,v in pairs(blips) do
            RemoveBlip(v)
            blips[k] = nil
        end
    end
    blips = {}
end

function DoRequestModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end
end

function DoRequestAnimSet(anim)
	RequestAnimDict(anim)
	while not HasAnimDictLoaded(anim) do
		Citizen.Wait(1)
	end
end