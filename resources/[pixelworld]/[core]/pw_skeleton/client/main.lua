PW = nil 
local bedOccupying, bedObject, bedOccupyingData, cam = nil, nil, nil, nil
local checkingIn = false

local inBedDict = "anim@gangops@morgue@table@"
local inBedAnim = "ko_front"
local getOutDict = 'switch@franklin@bed'
local getOutAnim = 'sleep_getup_rubeyes'

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
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerLoaded = true
        else
            playerData = data
        end
    else
        playerData = nil
        playerLoaded = false
    end
end)

function PrintHelpText(message)
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function LeaveBed()
    RequestAnimDict(getOutDict)
    while not HasAnimDictLoaded(getOutDict) do
        Citizen.Wait(1)
    end

    RenderScriptCams(0, true, 200, true, true)
    DestroyCam(cam, false)

    SetEntityInvincible(GLOBAL_PED, false)

    SetEntityHeading(GLOBAL_PED, bedOccupyingData.h - 90)
    TaskPlayAnim(GLOBAL_PED, getOutDict , getOutAnim ,8.0, -8.0, -1, 0, 0, false, false, false )
    Citizen.Wait(5000)
    ClearPedTasks(GLOBAL_PED)
    FreezeEntityPosition(GLOBAL_PED, false)
    TriggerServerEvent('pw_skeleton:server:LeaveBed', bedOccupying)

    FreezeEntityPosition(bedObject, false)

    bedOccupying = nil
    bedObject = nil
    bedOccupyingData = nil
end

RegisterNetEvent('pw_skeleton:client:RPCheckPos')
AddEventHandler('pw_skeleton:client:RPCheckPos', function()
    TriggerServerEvent('pw_skeleton:server:RPRequestBed', GLOBAL_COORDS)
end)

RegisterNetEvent('pw_skeleton:client:RPSendToBed')
AddEventHandler('pw_skeleton:client:RPSendToBed', function(id, data)
    bedOccupying = id
    bedOccupyingData = data

    bedObject = GetClosestObjectOfType(data.x, data.y, data.z, 1.0, data.model, false, false, false)
    FreezeEntityPosition(bedObject, true)

    SetEntityCoords(GLOBAL_PED, data.x, data.y, data.z)

    RequestAnimDict(inBedDict)
    while not HasAnimDictLoaded(inBedDict) do
        Citizen.Wait(1)
    end

    TaskPlayAnim(GLOBAL_PED, inBedDict , inBedAnim ,8.0, -8.0, -1, 1, 0, false, false, false )
    SetEntityHeading(GLOBAL_PED, data.h + 180)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    AttachCamToPedBone(cam, GLOBAL_PED, 31085, 0, 0, 1.0 , true)
    SetCamFov(cam, 90.0)
    SetCamRot(cam, -90.0, 0.0, GetEntityHeading(GLOBAL_PED) + 180, true)

    SetEntityInvincible(GLOBAL_PED, true)


    Citizen.CreateThread(function()
        while bedOccupyingData ~= nil do
            Citizen.Wait(1)
            PrintHelpText('Press ~INPUT_VEH_DUCK~ to get up')
            if IsControlJustReleased(0, 73) then
                LeaveBed()
            end
        end
    end)
end)

RegisterNetEvent('pw_skeleton:client:SendToBed')
AddEventHandler('pw_skeleton:client:SendToBed', function(id, data)
    bedOccupying = id
    bedOccupyingData = data

    bedObject = GetClosestObjectOfType(data.x, data.y, data.z, 1.0, data.model, false, false, false)
    FreezeEntityPosition(bedObject, true)

    SetEntityCoords(GLOBAL_PED, data.x, data.y, data.z)
    RequestAnimDict(inBedDict)
    while not HasAnimDictLoaded(inBedDict) do
        Citizen.Wait(1)
    end
    TaskPlayAnim(GLOBAL_PED, inBedDict , inBedAnim ,8.0, -8.0, -1, 1, 0, false, false, false )
    SetEntityHeading(GLOBAL_PED, data.h + 180)
    SetEntityInvincible(GLOBAL_PED, true)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    AttachCamToPedBone(cam, GLOBAL_PED, 31085, 0, 0, 1.0 , true)
    SetCamFov(cam, 90.0)
    SetCamRot(cam, -90.0, 0.0, GetEntityHeading(GLOBAL_PED) + 180, true)

    Citizen.CreateThread(function ()
        Citizen.Wait(5)
        local player = GLOBAL_PED

        exports['pw_notify']:SendAlert('inform', 'Doctors Are Treating You')
        Citizen.Wait(Config.AIHealTimer * 1000)
        TriggerServerEvent('pw_skeleton:server:EnteredBed')
    end)
end)

RegisterNetEvent('pw_skeleton:client:FinishServices')
AddEventHandler('pw_skeleton:client:FinishServices', function()
    local player = GLOBAL_PED
	
	if IsPedFatallyInjured(player) then
		local playerPos = GLOBAL_COORDS
		NetworkResurrectLocalPlayer(playerPos, true, true, false)
	end
	
    SetEntityHealth(player, GetEntityMaxHealth(player))
    ClearPedBloodDamage(player)
    SetPlayerSprint(PlayerId(), true)
    TriggerEvent('pw_skeleton:client:RemoveBleed')
    TriggerEvent('pw_skeleton:client:ResetLimbs')
    exports['pw_notify']:SendAlert('success', 'You\'ve been treated and billed')
    LeaveBed()
end)

RegisterNetEvent('pw_skeleton:client:ForceLeaveBed')
AddEventHandler('pw_skeleton:client:ForceLeaveBed', function()
    LeaveBed()
end)

RegisterNetEvent('pw_skeleton:client:BedRespawn')
AddEventHandler('pw_skeleton:client:BedRespawn', function()
    local randomZone = math.random(1,#Config.CheckIns)

    checkingIn = true
    TriggerServerEvent('pw_skeleton:server:RemoveInventory')
    TriggerServerEvent('pw_skeleton:server:RequestBed', randomZone)
    checkingIn = false
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if playerLoaded then
            GLOBAL_PED = GLOBAL_PED
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

function DrawText(type, k, var)
    local message, title, icon
    if type == 'checkin' then
        title = "Medical Attention"
        message = "<b>[ <span class='text-danger'>E</span> ] Check in</b>"
        icon = "fad fa-laptop-medical"
    end

    if title and message and icon then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = "<span style='font-size:18px'>" .. message .. "<span>", icon = icon })
    end

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) and not checkingIn then
                if (GetEntityHealth(GLOBAL_PED) < 200) or (IsInjuredOrBleeding()) then
                    PW.TriggerServerCallback('pw_skeleton:getOnline', function(count)
                        if count > 0 then   
                            exports['pw_notify']:SendAlert('error', 'There is someone from the EMS team on duty')
                        else  
                            checkingIn = true
                            TriggerEvent('pw:progressbar:progress',
                                {
                                    name = "hospital_action",
                                    duration = 10500,
                                    label = "Checking In",
                                    useWhileDead = true,
                                    canCancel = true,
                                    controlDisables = {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    },
                                    animation = {
                                        animDict = "missheistdockssetup1clipboard@base",
                                        anim = "base",
                                        flags = 49,
                                    },
                                    prop = {
                                        model = "p_amb_clipboard_01",
                                        bone = 18905,
                                        coords = { x = 0.10, y = 0.02, z = 0.08 },
                                        rotation = { x = -80.0, y = 0.0, z = 0.0 },
                                    },
                                    propTwo = {
                                        model = "prop_pencil_01",
                                        bone = 58866,
                                        coords = { x = 0.12, y = 0.0, z = 0.001 },
                                        rotation = { x = -150.0, y = 0.0, z = 0.0 },
                                    },
                                }, function(status)
                                    if not status then
                                        TriggerServerEvent('pw_skeleton:server:RequestBed', k)
                                        checkingIn = false
                                    else
                                        checkingIn = false
                                    end
                                end)                        
                        end
                    end)
                else
                    exports['pw_notify']:SendAlert('error', 'You do not need medical attention')
                end
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if playerLoaded then
            for k,v in pairs (Config.CheckIns) do
                local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))                
                if distance < 3.0 then
                    if not showing then
                        if not IsPedInAnyVehicle(GLOBAL_PED, true) then
                            showing = 'checkin' .. k
                            DrawText('checkin', k, showing)
                        end
                    end
                elseif showing == 'checkin' .. k then
                    showing = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        local playerHealth = GetEntityHealth(GLOBAL_PED)
        if playerHealth < 99 then
            SetEntityHealth(GLOBAL_PED, 99)
        end
    end
end)