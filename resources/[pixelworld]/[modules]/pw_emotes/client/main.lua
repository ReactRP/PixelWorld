PW = nil
characterLoaded, playerData, GLOBAL_PED = false, nil, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(unload, ready, data)
    if not unload then
        if ready then
            characterLoaded = true
            TriggerEvent('pw_emotes:client:fetchEmoteBinds')
            GLOBAL_PED = PlayerPedId()
            StartMainChecks()
            StartRagdollChecks()
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
        DestroyAllProps()
        PtfxStop()
        ClearPedTasks(GLOBAL_PED)
        ClearPedTasksImmediately(GLOBAL_PED)
        ResetPedMovementClipset(GLOBAL_PED)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
        end
    end
end)

local AnimationDuration = -1
local ChosenAnimation = ""
local ChosenDict = ""
local IsInAnimation = false
local MostRecentChosenAnimation = ""
local MostRecentChosenDict = ""
local MovementType = 0
local PlayerHasProp = false
local PlayerProps = {}
local PlayerParticles = {}
local SecondPropEmote = false
local PtfxNotif = false
local PtfxPrompt = false
local PtfxWait = 500
local PtfxNoProp = false
local characterKeyBindedEmotes = { [1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "" }
local isInRagdoll = false
local isRequestAnim = false
local requestedemote = ''


function StartMainChecks()
    Citizen.CreateThread(function()
        while characterLoaded do
            if IsPedShooting(GLOBAL_PED) and IsInAnimation then
                EmoteCancel()
            end

            if PtfxPrompt then
                if not PtfxNotif then
                    exports.pw_notify:SendAlert('info', PtfxInfo, 2500)
                    PtfxNotif = true
                end
                if IsControlPressed(0, 47) then
                    PtfxStart()
                    Wait(PtfxWait)
                    PtfxStop()
                end
            end

            if IsControlPressed(0, Config.MenuKeybind) then 
                TriggerEvent('pw_emotes:client:OpenMainEmoteMenu')
            end 
            if IsControlPressed(0, Config.CancelKeyBind) then 
                EmoteCancel() 
            end

            for k, v in pairs(Config.KeybindKeys) do
                if IsControlJustReleased(0, v.id) then
                    if characterKeyBindedEmotes[k] ~= "" then PlayAnEmote(characterKeyBindedEmotes[k]) end
                end
            end

            if IsControlJustPressed(2, Config.RagdollKeybind) and Config.RagdollEnabled and IsPedOnFoot(GLOBAL_PED) then
                if isInRagdoll then
                    isInRagdoll = false
                else
                    isInRagdoll = true
                    StartRagdollChecks()
                end
            end
            Citizen.Wait(5)
        end
    end)
end

function StartRagdollChecks()

    Citizen.CreateThread(function()
        while characterLoaded do
            Citizen.Wait(20)
            if isInRagdoll then
                SetPedToRagdoll(GLOBAL_PED, 1000, 1000, 0, 0, 0, 0)
            else
                break
            end
        end
    end)
end

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() then
        DestroyAllProps()
        ClearPedTasksImmediately(GLOBAL_PED)
        ResetPedMovementClipset(GLOBAL_PED)
    end
end)


function EmoteCancel()

    if ChosenDict == "MaleScenario" and IsInAnimation then
        ClearPedTasksImmediately(GLOBAL_PED)
        IsInAnimation = false
    elseif ChosenDict == "Scenario" and IsInAnimation then
        ClearPedTasksImmediately(GLOBAL_PED)
        IsInAnimation = false
    end

    PtfxNotif = false
    PtfxPrompt = false

    if IsInAnimation then
        PtfxStop()
        ClearPedTasks(GLOBAL_PED)
        DestroyAllProps()
        IsInAnimation = false
    end
end

function EmoteChatMessage(args)
    if args == display then
        TriggerEvent("chatMessage", "^5Help^0", {0,0,0}, string.format(""))
    else
        TriggerEvent("chatMessage", "^5Help^0", {0,0,0}, string.format(""..args..""))
    end
end

function PtfxStart()
    if PtfxNoProp then
        PtfxAt = GLOBAL_PED
    else
        PtfxAt = prop
    end
    UseParticleFxAssetNextCall(PtfxAsset)
    Ptfx = StartNetworkedParticleFxLoopedOnEntityBone(PtfxName, PtfxAt, Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, GetEntityBoneIndexByName(PtfxName, "VFX"), 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
    SetParticleFxLoopedColour(Ptfx, 1.0, 1.0, 1.0)
    table.insert(PlayerParticles, Ptfx)
end

function PtfxStop()
    for a,b in pairs(PlayerParticles) do
        StopParticleFxLooped(b, false)
        table.remove(PlayerParticles, a)
    end
end

function PlayAnEmote(emote)
    if emote ~= nil then
        local name = string.lower(emote)
        if name == "c" then
            if IsInAnimation then
                EmoteCancel()
            else
                exports.pw_notify:SendAlert('error', 'No Emote to Cancel', 2500)
            end
            return
        elseif name == "help" then
            TriggerEvent('pw_emotes:client:OpenMainEmoteMenu')
            return 
        end

        if AnimList.Emotes[name] ~= nil then
            if OnEmotePlay(AnimList.Emotes[name]) then end return
        elseif AnimList.Dances[name] ~= nil then
            if OnEmotePlay(AnimList.Dances[name]) then end return
        elseif AnimList.PropEmotes[name] ~= nil then
            if OnEmotePlay(AnimList.PropEmotes[name]) then end return
        else
            exports.pw_notify:SendAlert('error', '"' .. name .. '"' .. ' Isn\'t a Valid Emote', 2500)
        end
    end
end

RegisterNetEvent('pw_emotes:client:doAnEmote') -- Add the Above Function to An Event :)
AddEventHandler('pw_emotes:client:doAnEmote', PlayAnEmote)

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

function PtfxThis(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        RequestNamedPtfxAsset(asset)
        Wait(10)
    end
    UseParticleFxAssetNextCall(asset)
end

function DestroyAllProps()
    for _,v in pairs(PlayerProps) do
        DeleteEntity(v)
    end
    PlayerHasProp = false
end

function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = GLOBAL_PED
    local x,y,z = table.unpack(GetEntityCoords(GLOBAL_PED))

    if not HasModelLoaded(prop1) then
        LoadPropDict(prop1)
    end

    prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(PlayerProps, prop)
    PlayerHasProp = true
    SetModelAsNoLongerNeeded(prop1)
end

function OnEmotePlay(EmoteName)

    InVehicle = IsPedInAnyVehicle(GLOBAL_PED, true)

    if not DoesEntityExist(GLOBAL_PED) then
        return false
    end

    if Config.DisarmPlayer then
        if IsPedArmed(GLOBAL_PED, 7) then
            SetCurrentPedWeapon(GLOBAL_PED, GetHashKey('WEAPON_UNARMED'), true)
        end
    end

    ChosenDict,ChosenAnimation,ename = table.unpack(EmoteName)
    AnimationDuration = -1

    if PlayerHasProp then
        DestroyAllProps()
    end

    if ChosenDict == "MaleScenario" or "Scenario" then 
        if ChosenDict == "MaleScenario" then if InVehicle then return end
            ClearPedTasks(GLOBAL_PED)
            TaskStartScenarioInPlace(GLOBAL_PED, ChosenAnimation, 0, true)
            IsInAnimation = true
            return
        elseif ChosenDict == "ScenarioObject" then if InVehicle then return end
            BehindPlayer = GetOffsetFromEntityInWorldCoords(GLOBAL_PED, 0.0, 0 - 0.5, -0.5);
            ClearPedTasks(GLOBAL_PED)
            TaskStartScenarioAtPosition(GLOBAL_PED, ChosenAnimation, BehindPlayer['x'], BehindPlayer['y'], BehindPlayer['z'], GetEntityHeading(GLOBAL_PED), 0, 1, false)
            IsInAnimation = true
            return
        elseif ChosenDict == "Scenario" then if InVehicle then return end
            ClearPedTasks(GLOBAL_PED)
            TaskStartScenarioInPlace(GLOBAL_PED, ChosenAnimation, 0, true)
            IsInAnimation = true
        return end 
    end

    LoadAnim(ChosenDict)

    if EmoteName.AnimationOptions then
        if EmoteName.AnimationOptions.EmoteLoop then
            MovementType = 1
        if EmoteName.AnimationOptions.EmoteMoving then
            MovementType = 51
        end

    elseif EmoteName.AnimationOptions.EmoteMoving then
        MovementType = 51
    elseif EmoteName.AnimationOptions.EmoteMoving == false then
        MovementType = 0
    elseif EmoteName.AnimationOptions.EmoteStuck then
        MovementType = 50
    end

    else
        MovementType = 0
    end

    if InVehicle == 1 then
        MovementType = 51
    end

    if EmoteName.AnimationOptions then
        if EmoteName.AnimationOptions.EmoteDuration == nil then 
            EmoteName.AnimationOptions.EmoteDuration = -1
            AttachWait = 0
        else
            AnimationDuration = EmoteName.AnimationOptions.EmoteDuration
            AttachWait = EmoteName.AnimationOptions.EmoteDuration
        end

        if EmoteName.AnimationOptions.PtfxAsset then
                PtfxAsset = EmoteName.AnimationOptions.PtfxAsset
                PtfxName = EmoteName.AnimationOptions.PtfxName
            if EmoteName.AnimationOptions.PtfxNoProp then
                PtfxNoProp = EmoteName.AnimationOptions.PtfxNoProp
            else
                PtfxNoProp = false
            end
            Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, PtfxScale = table.unpack(EmoteName.AnimationOptions.PtfxPlacement)
            PtfxInfo = EmoteName.AnimationOptions.PtfxInfo
            PtfxWait = EmoteName.AnimationOptions.PtfxWait
            PtfxNotif = false
            PtfxPrompt = true
            PtfxThis(PtfxAsset)
            else
                PtfxPrompt = false
            end
        end

    TaskPlayAnim(GLOBAL_PED, ChosenDict, ChosenAnimation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
    RemoveAnimDict(ChosenDict)
    IsInAnimation = true
    MostRecentDict = ChosenDict
    MostRecentAnimation = ChosenAnimation

    if EmoteName.AnimationOptions then
        if EmoteName.AnimationOptions.Prop then
            PropName = EmoteName.AnimationOptions.Prop
            PropBone = EmoteName.AnimationOptions.PropBone
            PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(EmoteName.AnimationOptions.PropPlacement)
            if EmoteName.AnimationOptions.SecondProp then
                SecondPropName = EmoteName.AnimationOptions.SecondProp
                SecondPropBone = EmoteName.AnimationOptions.SecondPropBone
                SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(EmoteName.AnimationOptions.SecondPropPlacement)
                SecondPropEmote = true
            else
                SecondPropEmote = false
            end
            Wait(AttachWait)
            AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
            if SecondPropEmote then
                AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6)
            end
        end
    end
    return true
end

-- Menu Stuff

RegisterNetEvent('pw_emotes:client:OpenMainEmoteMenu')
AddEventHandler('pw_emotes:client:OpenMainEmoteMenu', function()
    local mainEmoteMenu = {
        { ['label'] = 'Cancel Current Emote', ['action'] = 'pw_emotes:client:cancelCurrentEmote', ['value'] = 1, ['triggertype'] = 'client', ['color'] = 'danger'},
        { ['label'] = 'Emotes', ['action'] = 'pw_emotes:client:OpenEmoteMenu', ['value'] = '', ['triggertype'] = 'client', ['color'] = 'info'},
        { ['label'] = 'Dances', ['action'] = 'pw_emotes:client:OpenDanceEmoteMenu', ['value'] = 'f', ['triggertype'] = 'client', ['color'] = 'info'},
        { ['label'] = 'Prop Emotes', ['action'] = 'pw_emotes:client:OpenEmotePropMenu', ['value'] = 'f', ['triggertype'] = 'client', ['color'] = 'info'},
        { ['label'] = 'Shared Emotes', ['action'] = 'pw_emotes:client:OpenSharedEmoteMenu', ['value'] = '', ['triggertype'] = 'client', ['color'] = 'info'},
        { ['label'] = 'Shared Dances', ['action'] = 'pw_emotes:client:OpenSharedDanceMenu', ['value'] = 'f', ['triggertype'] = 'client', ['color'] = 'info'},
    }
    TriggerEvent('pw_interact:generateMenu', mainEmoteMenu, 'Emote Menu')
end)


RegisterNetEvent('pw_emotes:client:cancelCurrentEmote')
AddEventHandler('pw_emotes:client:cancelCurrentEmote', EmoteCancel)


RegisterNetEvent('pw_emotes:client:OpenEmoteMenu')
AddEventHandler('pw_emotes:client:OpenEmoteMenu', function()
    local emotesMenu = {}
    for k,v in pairs(AnimList.Emotes) do
        if v[3] ~= nil then
            table.insert(emotesMenu, { ['label'] = v[3] .. ' ('.. k .. ')', ['action'] = 'pw_emotes:client:DoEmoteFromMenu', ['value'] = { ['type'] = 'emote', ['name'] = k}, ['triggertype'] = 'client', ['color'] = 'info'})
        end
    end
    table.sort(emotesMenu, function(a,b) return a.label < b.label end)
    TriggerEvent('pw_interact:generateMenu', emotesMenu, "Prop Emotes")
end)

RegisterNetEvent('pw_emotes:client:DoEmoteFromMenu')
AddEventHandler('pw_emotes:client:DoEmoteFromMenu', function(info)
    print(info[1], info[2])
    if info.type == 'emote' then
        OnEmotePlay(AnimList.Emotes[info.name])
        TriggerEvent('pw_emotes:client:OpenEmoteMenu')
    elseif info.type == 'propEmote' then
        OnEmotePlay(AnimList.PropEmotes[info.name])
    elseif info.type == 'dance' then
        OnEmotePlay(AnimList.Dances[info.name])
        TriggerEvent('pw_emotes:client:OpenDanceEmoteMenu')
    end
end)

RegisterNetEvent('pw_emotes:client:OpenEmotePropMenu')
AddEventHandler('pw_emotes:client:OpenEmotePropMenu', function()
    local emotesPropMenu = {}
    for k,v in pairs(AnimList.PropEmotes) do
        if v[3] ~= nil then
            table.insert(emotesPropMenu, { ['label'] = v[3] .. ' ('.. k .. ')', ['action'] = 'pw_emotes:client:DoEmoteFromMenu', ['value'] = { ['type'] = 'propEmote', ['name'] = k}, ['triggertype'] = 'client', ['color'] = 'info'})
        end
    end
    table.sort(emotesPropMenu, function(a,b) return a.label < b.label end)
    TriggerEvent('pw_interact:generateMenu', emotesPropMenu, "Prop Emotes")
end)

RegisterNetEvent('pw_emotes:client:OpenDanceEmoteMenu')
AddEventHandler('pw_emotes:client:OpenDanceEmoteMenu', function()
    local emotesDanceMenu = {}
    for k,v in pairs(AnimList.Dances) do
        if v[3] ~= nil then
            table.insert(emotesDanceMenu, { ['label'] = v[3] .. ' ('.. k .. ')', ['action'] = 'pw_emotes:client:DoEmoteFromMenu', ['value'] = { ['type'] = 'dance', ['name'] = k}, ['triggertype'] = 'client', ['color'] = 'info'})
        end
    end
    table.sort(emotesDanceMenu, function(a,b) return a.label < b.label end)
    TriggerEvent('pw_interact:generateMenu', emotesDanceMenu, "Prop Emotes")
end)

RegisterNetEvent('pw_emotes:client:OpenSharedEmoteMenu')
AddEventHandler('pw_emotes:client:OpenSharedEmoteMenu', function()
    local emotesSharedMenu = {}
    for k,v in pairs(AnimList.Shared) do
        if v[3] ~= nil then
            table.insert(emotesSharedMenu, { ['label'] = v[3] .. ' ('.. k .. ')', ['action'] = 'pw_emotes:client:startSharedEmote', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'info'})
        end
    end
    table.sort(emotesSharedMenu, function(a,b) return a.label < b.label end)
    TriggerEvent('pw_interact:generateMenu', emotesSharedMenu, "Shared Emotes")
end)

RegisterNetEvent('pw_emotes:client:OpenSharedDanceMenu')
AddEventHandler('pw_emotes:client:OpenSharedDanceMenu', function()
    local emotesSharedDancesMenu = {}
    for k,v in pairs(AnimList.Dances) do
        if v[3] ~= nil then
            table.insert(emotesSharedDancesMenu, { ['label'] = v[3] .. ' ('.. k .. ')', ['action'] = 'pw_emotes:client:startSharedEmote', ['value'] = k, ['triggertype'] = 'client', ['color'] = 'info'})
        end
    end
    table.sort(emotesSharedDancesMenu, function(a,b) return a.label < b.label end)
    TriggerEvent('pw_interact:generateMenu', emotesSharedDancesMenu, "Shared Dances")
end)

-- Emote Binds

RegisterNetEvent('pw_emotes:client:fetchEmoteBinds')
AddEventHandler('pw_emotes:client:fetchEmoteBinds', function()
    PW.TriggerServerCallback('pw_emotes:server:getCharacterEmoteBinds', function(keybinds)
        print(keybinds)
        if keybinds ~= nil then
            PW.Print(keybinds)
            characterKeyBindedEmotes = keybinds
        else
            characterKeyBindedEmotes = { [1] = "", [2] = "", [3] = "", [4] = "", [5] = "", [6] = "" }
        end
    end)
end)

RegisterNetEvent('pw_emotes:client:updateBindedEmotes')
AddEventHandler('pw_emotes:client:updateBindedEmotes', function(key, emote)
    if key ~= nil and emote ~= nil then 
        local bindKey = tonumber(key)
        local emoteName = string.lower(emote)
        if (Config.KeybindKeys[bindKey]) ~= nil then
            if AnimList.Emotes[emoteName] ~= nil or AnimList.Dances[emoteName] ~= nil or AnimList.PropEmotes[emoteName] ~= nil then
                characterKeyBindedEmotes[bindKey] = emoteName
                PW.TriggerServerCallback('pw_emotes:server:updateCharacterEmoteBinds', function(success)
                    if success then
                        exports.pw_notify:SendAlert('success', 'Character Emote Bind: '.. bindKey .. ' (' .. Config.KeybindKeys[bindKey].keyName .. ') has been updated to the "'.. emoteName .. '" emote')
                    else
                        exports.pw_notify:SendAlert('error', 'Error Updating Your Character Emote Keybinds', 2500)
                    end
                end, characterKeyBindedEmotes)
            else
                print('Invalid Emote to Bind')
            end
        else
            exports.pw_notify:SendAlert('error', 'Error Updating Your Character Emote Keybinds', 2500)
        end
    end
end)

-- Shared Emotes

RegisterNetEvent('pw_emotes:client:startSharedEmote')
AddEventHandler('pw_emotes:client:startSharedEmote', function(emote)
    local emotename = string.lower(emote)
    target, distance = GetClosestPlayer()
    if(distance ~= -1 and distance < 3) then
        if AnimList.Shared[emotename] ~= nil then
            dict, anim, ename = table.unpack(AnimList.Shared[emotename])
            TriggerServerEvent("pw_emotes:server:ServerEmoteRequest", GetPlayerServerId(target), emotename)
            exports.pw_notify:SendAlert('info', 'Shared Emote Request Sent - Awaiting to Be Accepted', 4500)
        elseif AnimList.Dances[emotename] ~= nil then
            dict, anim, ename = table.unpack(AnimList.Dances[emotename])
            TriggerServerEvent("pw_emotes:server:ServerEmoteRequest", GetPlayerServerId(target), emotename, 'Dances')
            exports.pw_notify:SendAlert('info', 'Shared Dance Request Sent - Awaiting to Be Accepted', 4500)
        else
            exports.pw_notify:SendAlert('error', 'Invalid Shared Emote', 2500)
        end
    else
        exports.pw_notify:SendAlert('error', 'Nobody Near to Share Emote With', 2500)
    end
end)

RegisterNetEvent('pw_emotes:client:SyncPlayEmote')
AddEventHandler('pw_emotes:client:SyncPlayEmote', function(emote, player)
    EmoteCancel()
    Wait(300)
    if AnimList.Shared[emote] ~= nil then
        if OnEmotePlay(AnimList.Shared[emote]) then end return
    elseif AnimList.Dances[emote] ~= nil then
        if OnEmotePlay(AnimList.Dances[emote]) then end return
    end
end)

RegisterNetEvent('pw_emotes:client:SyncPlayEmoteSource')
AddEventHandler('pw_emotes:client:SyncPlayEmoteSource', function(emote, player)
    local pedInFront = GetPlayerPed(GetClosestPlayer())
    local heading = GetEntityHeading(pedInFront)
    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)
    if (AnimList.Shared[emote]) and (AnimList.Shared[emote].AnimationOptions) then
        local SyncOffsetFront = AnimList.Shared[emote].AnimationOptions.SyncOffsetFront
        if SyncOffsetFront then
            coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
        end
    end
    SetEntityHeading(PlayerPedId(), heading - 180.1)
    SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, 0)
    EmoteCancel()
    Wait(300)
    if AnimList.Shared[emote] ~= nil then
        if OnEmotePlay(AnimList.Shared[emote]) then end return
    elseif AnimList.Dances[emote] ~= nil then
        if OnEmotePlay(AnimList.Dances[emote]) then end return
    end
end)

RegisterNetEvent('pw_emotes:client:ClientEmoteRequestReceive')
AddEventHandler('pw_emotes:client:ClientEmoteRequestReceive', function(emotename, etype)
    isRequestAnim = true
    requestedemote = emotename
    StartWaitingForEmoteAcceptKeyPress()
    if etype == 'Dances' then
        _,_,remote = table.unpack(AnimList.Dances[requestedemote])
    else
        _,_,remote = table.unpack(AnimList.Shared[requestedemote])
    end
    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)
    exports.pw_notify:SendAlert('info', 'You Recieved a Shared Emote Request. Press Y to Accept or N to Refuse ('.. remote .. ')', 6500)
end)

function StartWaitingForEmoteAcceptKeyPress()
    Citizen.CreateThread(function()
        while isRequestAnim do
            Citizen.Wait(5)
            if IsControlJustPressed(1, 246) and isRequestAnim then
                target, distance = GetClosestPlayer()
                if(distance ~= -1 and distance < 3) then
                    if AnimList.Shared[requestedemote] ~= nil then
                        _,_,_,otheremote = table.unpack(AnimList.Shared[requestedemote])
                    elseif AnimList.Dances[requestedemote] ~= nil then
                        _,_,_,otheremote = table.unpack(AnimList.Dances[requestedemote])
                    end
                    if otheremote == nil then otheremote = requestedemote end
                    TriggerServerEvent('pw_emotes:server:ServerValidEmote', GetPlayerServerId(target), requestedemote, otheremote)
                    isRequestAnim = false
                else
                    exports.pw_notify:SendAlert('error', 'Person Who Requested The Shared Emote is Too Far Away', 2500)
                end
            elseif IsControlJustPressed(1, 182) and isRequestAnim then
                exports.pw_notify:SendAlert('error', 'You Refused The Shared Emote Request', 2500)
                isRequestAnim = false
            end
        end
    end)
end


function GetPlayerFromPed(ped)
    for _,player in ipairs(GetActivePlayers()) do
        if GetPlayerPed(player) == ped then
            return player
        end
    end
    return -1
end

function GetPedInFront()
    local player = PlayerId()
    local plyPed = GetPlayerPed(player)
    local plyPos = GetEntityCoords(plyPed, false)
    local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
    local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 10.0, 12, plyPed, 7)
    local _, _, _, _, ped2 = GetShapeTestResult(rayHandle)
    return ped2
end


function GetClosestPlayer()
    local players = PW.Game.GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end