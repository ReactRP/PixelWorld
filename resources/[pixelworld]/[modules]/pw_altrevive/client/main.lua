
PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, GLOBAL_ISDEAD, playerData = false, nil, nil, nil, nil

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:loadFramework', function(framework) PW = framework end)
        Citizen.Wait(1)
    end
end)

local showing = false

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

RegisterNetEvent('pw:playerRevived')
AddEventHandler('pw:playerRevived', function()
	GLOBAL_ISDEAD = false
end)

RegisterNetEvent('pw:playerDied')
AddEventHandler('pw:playerDied', function()
    GLOBAL_ISDEAD = true
end)

function MarkerDraw()
    Citizen.CreateThread(function()
        while showingMarker and characterLoaded do
            Citizen.Wait(1)
            DrawMarker(Config.Location.markerType, Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Location.markerSize.x, Config.Location.markerSize.y, Config.Location.markerSize.z, Config.Location.markerColor.r, Config.Location.markerColor.g, Config.Location.markerColor.b, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end

function DrawText(location)
    TriggerEvent('pw_drawtext:showNotification', { title = "Alternative Medical Treatment", message = "<span style='font-size:20px'>Press <b><span class='text-danger'>E</span></b> For Medical Attention</span>", icon = "fad fa-prescription-bottle-alt" })
    TriggerEvent('pw_items:showUsableKeys', true, {{['key'] = "e", ['label'] = "Seek Treatment"}})

    Citizen.CreateThread(function()
        while showing == location and characterLoaded do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                OpenReviveDecideMenu(location)
            end
        end
    end)
end

function SpawnNpc(loc)
    local npcObj = GetHashKey("a_f_o_ktown_01")
    while not HasModelLoaded(npcObj) do
        RequestModel(npcObj)
        Wait(10)
    end 

    if Config.Locations[loc].npcObj ~= nil and DoesEntityExist(NetToPed(Config.Locations[loc].npcObj)) then
        DeleteEntity(NetToPed(Config.Locations[loc].npcObj))
        TriggerServerEvent('pw_altrevive:server:updateNpc', loc, nil)
    end

    local pedObj = CreatePed(2, npcObj, Config.Locations[loc].coords.x, Config.Locations[loc].coords.y, Config.Locations[loc].coords.z, Config.Locations[loc].coords.h, true, true)
    SetEntityAsMissionEntity(pedObj, true, true)
    SetBlockingOfNonTemporaryEvents(pedObj, true)
    SetPedFleeAttributes(pedObj, 0, 0)
    SetPedTalk(pedObj)
    TriggerServerEvent('pw_altrevive:server:updateNpc', loc, PedToNet(pedObj))
    TriggerServerEvent('pw_altrevive:server:updateLocation', loc, 'spawningNpc', false)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then
            for k,v in pairs(Config.Locations) do
                local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dist < 30.0 then
                    if not nearDoc then
                        nearDoc = k
                        if not v.npcSpawned and not v.spawningNpc then
                            TriggerServerEvent('pw_altrevive:server:updateLocation', k, 'spawningNpc', true)
                            SpawnNpc(k)
                        end
                    end
                elseif dist > 30.0 and nearDoc == k then
                    nearDoc = false
                end
                if dist < 1.0 then
                    if not showing or showing ~= k then
                        showing = k
                        DrawText(showing)
                    end
                elseif showing == k then
                    showing = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end
            end
        end
    end
end)


RegisterNetEvent('pw_altrevive:server:updateLocation')
AddEventHandler('pw_altrevive:server:updateLocation', function(location, var, state)
    Config.Locations[location][var] = state
end)

RegisterNetEvent('pw_altrevive:client:updateNpc')
AddEventHandler('pw_altrevive:client:updateNpc', function(location, ped)
    Config.Locations[location].npcObj = ped
end)

function OpenReviveDecideMenu(location)  
    local menu = { 
        { ['label'] = 'Yes, Treat Me ($'.. Config.Cost..')', ['action'] = 'pw_altrevive:client:startRequestRevive', ['value'] = location, ['triggertype'] = 'client', ['color'] = 'success' },
        { ['label'] = 'No, I don\'t need Treatment', ['action'] = 'pw:notification:SendAlert', ['value'] = {type = "error", text = 'You don\'t Want Treatment? Get Out of Here!', length = 5000}, ['triggertype'] = 'client', ['color'] = 'danger' },
    }
    TriggerEvent('pw_interact:generateMenu', menu, "Do You Require Medical Attention?")   
end

RegisterNetEvent('pw_altrevive:client:startRequestRevive')
AddEventHandler('pw_altrevive:client:startRequestRevive', function(location)
    local doctorPed = NetToPed(Config.Locations[location].npcObj)
    TaskTurnPedToFaceEntity(doctorPed, GLOBAL_PED, -1)
    local doctorPedCoords = GetEntityCoords(doctorPed)
    if #(GLOBAL_COORDS - doctorPedCoords) < 4.0 and not IsPedFatallyInjured(doctorPed) then
        if GLOBAL_ISDEAD or IsPedFatallyInjured(GLOBAL_PED) or exports['pw_skeleton']:IsInjuredOrBleeding() then
            TriggerServerEvent('pw_altrevive:server:requestRevive', location)
        else
            exports.pw_notify:SendAlert('error', 'You Don\'t Require Treatment.', 2500)
        end   
    else
        exports.pw_notify:SendAlert('error', 'There is Nobody Here to Treat You.', 2500)
    end
end)


RegisterNetEvent('pw_altrevive:client:startrevive')
AddEventHandler('pw_altrevive:client:startrevive', function(location)
    local doctorPed = NetToPed(Config.Locations[location].npcObj)
    SetEntityCoords(doctorPed, Config.Locations[location].coords.x, Config.Locations[location].coords.y, Config.Locations[location].coords.z)
    SetEntityHeading(GLOBAL_PED, Config.Locations[location].faceDir)
    ClearPedTasks(GLOBAL_PED)
    TaskStartScenarioInPlace(GLOBAL_PED, "WORLD_HUMAN_SUNBATHE_BACK", 0, true)
    TaskStartScenarioInPlace(doctorPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
    TriggerEvent('pw:progressbar:progress', {
        name = 'alt_revival_progress',
        duration = (Config.RevivingTime * 1000),
        label = 'Recieving Medical Treatment',
        useWhileDead = true,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(status)
        if not status then
            local chance = math.random(1, 100)
            if chance > Config.ReviveChance then
                TriggerServerEvent('pw_altrevive:server:completeRevive', location, true)

                ClearPedTasks(doctorPed)
                ClearPedTasks(GLOBAL_PED)
                Citizen.Wait(500)
                TaskTurnPedToFaceEntity(doctorPed, GLOBAL_PED, -1)
            else    
                TriggerServerEvent('pw_altrevive:server:completeRevive', location, false)
                ClearPedTasks(doctorPed)
                ClearPedTasks(GLOBAL_PED)
                Citizen.Wait(500)
                TaskTurnPedToFaceEntity(doctorPed, GLOBAL_PED, -1)
            end    
        else
            ClearPedTasks(GLOBAL_PED) 
        end    
    end)
end)