local startCamera = { ['x'] = -1355.93, ['y'] = -1487.78, ['z'] = 520.75, ['point'] = { ['x'] = 195.55, ['y'] = -933.36, ['z'] = 29.90, ['zx'] = 300 }}

Citizen.CreateThread(function()
    while true do
        if NetworkIsSessionStarted() then
            Citizen.Wait(100)
            PWBase.StartUp.ClientConnection()
            return
        end
        Citizen.Wait(0)
    end
end)

PWBase['StartUp'] = {
    ClientConnection = function()
        TriggerServerEvent('pw_core:server:startClientConnection')
        PWBase.StartUp.SetupLoadCamera()
    end,
    SetupLoadCamera = function()
        DestroyAllCams( false )
        DisplayAreaName( false )
        DisplayHud( false )
        DisplayCash( false )
        DisplayRadar(false)
        SetDrawOrigin(0.0, 0.0, 0.0, 0)
        flyCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", startCamera.x, startCamera.y, startCamera.z, (startCamera.point.zx + 0.0),0.00,0.00, 100.00, false, 0)
        PointCamAtCoord(flyCam, startCamera.point.x, startCamera.point.y, startCamera.point.z + startCamera.point.zx)
        SetCamActive(flyCam, true)
        SetTimecycleModifier('hud_def_blur')
        PWBase.StartUp.RegisterDecors()
        RenderScriptCams(true, true, 500, true, true)
    end,
    RegisterDecors = function()
        for k, v in pairs(Config.DecorRegisters) do
            if not DecorIsRegisteredAsType(v.name, tonumber(v.type)) then
                DecorRegister(v.name, tonumber(v.type))
            end
        end
    end,
}

PWBase['Characters'] = {
    SetSkin = function(skindata)

    end,
    TransitionCamera = function(x,y,z)

    end,
    JoinServer = function(x,y,z)

    end,
    SwitchStart = function()

    end,
    LeaveServer = function()

    end,
}

RegisterNetEvent('pw_core:client:sendToWorld')
AddEventHandler('pw_core:client:sendToWorld', function(loc)
    local playerCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", tonumber(loc.x),tonumber(loc.y),tonumber(loc.z)+200, 300.00,0.00,0.00, 100.00, false, 0)
    local playerCam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", tonumber(loc.x),tonumber(loc.y),tonumber(loc.z)+2, 300.00,0.00,0.00, 100.00, false, 0)
    PointCamAtCoord(playerCam, tonumber(loc.x),tonumber(loc.y),tonumber(loc.z)+2)
    PointCamAtCoord(playerCam2, tonumber(loc.x),tonumber(loc.y),tonumber(loc.z)+2)
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed, tonumber(loc.x), tonumber(loc.y), tonumber(loc.z), 0, 0, 0, 0)
    SetEntityHeading(playerPed, tonumber(loc.h))
    if exports['pw_character']:spawnCharacterSkin() then
        PWBase['NUI'].CloseAllScreens()
        SetCamActiveWithInterp(playerCam, flyCam, 3700, true, true)
        Citizen.Wait(3700)
        SetCamActiveWithInterp(playerCam2, playerCam, 3500, true, true)
        Citizen.Wait(2000)
        DoScreenFadeOut(500)
        Citizen.Wait(501)
        RenderScriptCams(false, false, 500, false, false)
        Citizen.Wait(500)
        DoScreenFadeIn(500)
        DestroyCam(flyCam, false)
        DestroyCam(playerCam, false)
        DestroyCam(playerCam2, false)
        flyCam = nil
        playerCam = nil
        playerCam2 = nil
        TriggerServerEvent('pw_core:server:playerReady')
        TriggerEvent('pw_core:client:playerReady')
    end
end)