local checking = false

function CreateDriver(veh)
    local model = GetHashKey(Config.Insurance.fuelDeliveryDriver)
    if IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        local ped = CreatePedInsideVehicle(veh, 26, model, -1, true, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetPedDropsWeaponsWhenDead(ped, false)
        SetModelAsNoLongerNeeded(model)

        local blip = AddBlipForEntity(ped)
        SetBlipSprite(blip, 545)
        SetBlipFlashes(blip, true)
        SetBlipFlashTimer(blip, 5000)
        SetBlipColour(blip, 46)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Fuel Delivery")
        EndTextCommandSetBlipName(blip)

        NetworkRegisterEntityAsNetworked(ped)
        local pedNet = PedToNet(ped)
        SetNetworkIdCanMigrate(pedNet, true)
        SetNetworkIdExistsOnAllMachines(pedNet, true)
        SetNetworkIdSyncToPlayer(pedNet, PlayerId(), true)
        return ped
    end
end

function ChangeBlipText(blip, type)
    local default = "Fuel Delivery"
    local text, color = "", 46
    if type == 'goingStation' then
        text = 'Heading to a gas station'
    elseif type == 'picking' then
        text = 'Picking up a jerrycan'
    elseif type == 'destination' then
        text = 'Heading your way'
        color = 2
    elseif type == 'traffic' then
        text = 'Stopped at a traffic light'
        color = 1
    else
        text = 'Stopped'
        color = 1
    end
    local insertText = default .. " - " .. text
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(insertText)
    EndTextCommandSetBlipName(blip)
    SetBlipColour(blip, color)
end

function CreateVeh()
    local Px, Py, Pz = table.unpack(GetEntityCoords(PlayerPedId()))

    local taxiModel = GetHashKey(Config.Insurance.fuelDeliveryVehicle)

    if IsModelValid(taxiModel) then
        if IsThisModelACar(taxiModel) then
            RequestModel(taxiModel)
            while not HasModelLoaded(taxiModel) do
                Wait(1)
            end

            local _, vector, _ = GetRandomVehicleNode(Px, Py, Pz, math.random(150 ,1500) + 0.0, true, true, true)
            local sX, sY, sZ = table.unpack(vector)
            
            local veh = CreateVehicle(taxiModel, sX, sY, sZ, 0, true, false)

            SetEntityAsMissionEntity(veh, true, true)
            SetVehicleEngineOn(veh, true, true, false)

            SetModelAsNoLongerNeeded(taxiModel)
            NetworkRegisterEntityAsNetworked(veh)
            local vehNet = VehToNet(veh)
            SetNetworkIdCanMigrate(vehNet, true)
            SetNetworkIdExistsOnAllMachines(vehNet, true)
            SetNetworkIdSyncToPlayer(vehNet, PlayerId(), true)
            return veh
        end
    end
end

function GetClosestPump(target)
    local closestPumpCoords = exports.pw_fuel:getNearestPump(target)
    local ticks = 0
    repeat 
        if ticks >= 1000 then
            closestPumpCoords = false
        else
            ticks = ticks + 1
            Wait(1) 
        end
    until closestPumpCoords ~= nil

    return closestPumpCoords
end

function GoTo(ped, veh, coords, targetPed, settings)
    if settings == nil then settings = {}; end
    local speed = (settings.speed and settings.speed or 25.0)
    local drivingStyle = (settings.drivingStyle and settings.drivingStyle or 787135) --387 / 1074528293
    local stopRange = (settings.stopRange and settings.stopRange or 4.0)

    LoadAllPathNodes(true)
    while not AreAllNavmeshRegionsLoaded() do
        Wait(1)
    end    
    
    SetDriverAbility(ped, 1.0)
    SetDriverAggressiveness(ped, 0.0)
    if targetPed then
        TaskVehicleMissionPedTarget(ped, veh, PlayerPedId(), 4, speed, drivingStyle, stopRange, stopRange, 1)
    else
        TaskVehicleDriveToCoordLongrange(ped, veh, coords, speed, drivingStyle, stopRange)
    end
    
    SetPedKeepTask(ped, true)
end

function CheckVehStatus(veh)
    local status = true
    
    local blip = GetBlipFromEntity(veh.ped)
    if IsVehicleStoppedAtTrafficLights(veh.veh) then
        ChangeBlipText(blip, 'traffic')
        Citizen.CreateThread(function()
            if not checking then
                checking = true
                while IsVehicleStoppedAtTrafficLights(veh.veh) do
                    Wait(100)
                end
                checking = false
                ChangeBlipText(blip, veh.status)
            end
        end)
    elseif IsVehicleStopped(veh.veh) then
        ChangeBlipText(blip)
        Citizen.CreateThread(function()
            if not checking then
                checking = true
                while IsVehicleStopped(veh.veh) do
                    Wait(100)
                end
                checking = false
                ChangeBlipText(blip, veh.status)
            end
        end)
    end
    if IsVehicleStuckOnRoof(veh.veh) or IsEntityUpsidedown(veh.veh) or IsEntityDead(veh.veh) or IsEntityDead(veh.ped) then
        SendFuelAway()
        status = false
    end

    return status
end

function PlayGivingAnims(player, npc)
    PlayFuelAnim(npc)
    Wait(1000)
    PlayFuelAnim(player)
    Wait(1000)
    RemoveWeaponFromPed(npc, GetHashKey("WEAPON_PETROLCAN"))
    GiveWeaponToPed(player, GetHashKey("WEAPON_PETROLCAN"), 0, true, true)
    Wait(2000)
    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
    Wait(3000)
    RemoveWeaponFromPed(player, GetHashKey("WEAPON_PETROLCAN"))
end

function PlayFuelAnim(ped)
    local anim = 'amb@prop_human_atm@male@idle_a'
    RequestAnimDict(anim)
    while not HasAnimDictLoaded(anim) do
        Citizen.Wait(1)
    end

    if HasAnimDictLoaded(anim) then 
        TaskPlayAnim(ped, anim, "idle_a", 1.0,-1.0, 3000, 1, 1, true, true, true)
    end
end