PW = nil
characterLoaded, playerData = false, nil
local cameraActive = false
local currentCameraIndex, createdCamera, currentHouse = 0, 0, 0
local camCycle = {
    { ['spot'] = 'entrance',        ['label'] = 'Front Door',               ['notSet'] = false },
    { ['spot'] = 'exitEntrance',    ['label'] = 'Back Door',                ['notSet'] = false }, 
    { ['spot'] = 'exit',            ['label'] = 'Inside Main Entrance',     ['notSet'] = false },
    { ['spot'] = 'exitInside',      ['label'] = 'Inside Back Entrance',     ['notSet'] = false }, 
}

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
            characterLoaded = true
        else
            playerData = data
        end
    else
        if createdCamera ~= 0 then
            CloseSecurityCamera()
            SendNUIMessage({
                type = "disablecam",
            })
        end
        playerData = nil
        characterLoaded = false
    end
end)

function CheckSecondaryCameras(house)
    local check = {'exit', 'exitEntrance', 'exitInside'}

    for i = 1, #check do
        if not house[check[i]] or (house[check[i]].x == 0.0 and house[check[i]].y == 0.0 and house[check[i]].y == 0.0) then
            for j,b in pairs(camCycle) do
                if b.spot == check[i] then
                    camCycle[j].notSet = true
                end
            end
        end
    end    
end

function HeadToRot(val)
    local sendVal
    if val > 180.0 then
        sendVal = -360.0 + val
    else
        sendVal = -180.0 + val
    end
end

function EnableCam(house)
    CheckSecondaryCameras(house)
    local tbl = {
        {['type'] = "key", ['key'] = "w", ['action'] = "Rotate Up"},
        {['type'] = "key", ['key'] = "a", ['action'] = "Rotate Left"},
        {['type'] = "key", ['key'] = "s", ['action'] = "Rotate Down"},
        {['type'] = "key", ['key'] = "d", ['action'] = "Rotate Right"},
        {['type'] = "key", ['key'] = "e", ['action'] = "Next Camera"},
        {['type'] = "key", ['key'] = "c", ['action'] = "Toggle Nightvision"},
        {['type'] = "key", ['key'] = "x", ['action'] = "Turn Off"}
    }

    TriggerServerEvent('pw_keynote:server:triggerShowable', true, tbl)
    local x = house.entrance.x
    local y = house.entrance.y
    local z = house.entrance.z + 1.0
    local h = HeadToRot(house.entrance.h)
    SetFocusArea(x, y, z, x, y, z)
    ChangeSecurityCamera(x, y, z, h)
    SendNUIMessage({
        type = "enablecam",
        label = camCycle[1].label,
        box = house.name,
        q = house.camSettings.label
    })
    currentNV = false
    SetNightvision(false)
    currentCameraIndex = 1
    currentHouse = house
    FreezeEntityPosition(PlayerPedId(), true)
    exports['pw_hud']:toggleHud(false)
end

RegisterNetEvent('pw_cams:client:enableCam')
AddEventHandler('pw_cams:client:enableCam', function(house)
    EnableCam(house)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if createdCamera ~= 0 then
            DisableAllControlActions(0)

            SetTimecycleModifier(currentHouse.camSettings.mod)
            SetTimecycleModifierStrength(2.0)

            -- CLOSE CAMERAS X
            if IsDisabledControlJustPressed(0, 73) then
                CloseSecurityCamera()
                SendNUIMessage({
                    type = "disablecam",
                })
                SetNightvision(false)
                exports['pw_hud']:toggleHud(true)
            end

            local getCameraRot = GetCamRot(createdCamera, 2)

            -- ROTATE UP W
            if IsDisabledControlPressed(0, 32) then
                SetCamRot(createdCamera, getCameraRot.x + Config.DefaultStep, 0.0, getCameraRot.z, 2)
            end

            -- ROTATE DOWN S 
            if IsDisabledControlPressed(0, 33) then
                SetCamRot(createdCamera, getCameraRot.x - Config.DefaultStep, 0.0, getCameraRot.z, 2)
            end

            -- ROTATE LEFT A
            if IsDisabledControlPressed(0, 34) then
                SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z + Config.DefaultStep, 2)
            end

            -- ROTATE RIGHT D
            if IsDisabledControlPressed(0, 35) then
                SetCamRot(createdCamera, getCameraRot.x, 0.0, getCameraRot.z - Config.DefaultStep, 2)
            end

            -- NEXT CAM E
            if IsDisabledControlJustPressed(0, 86) then
                repeat
                    if (currentCameraIndex + 1) <= #camCycle then
                        currentCameraIndex = currentCameraIndex + 1
                    else
                        currentCameraIndex = 1
                    end
                until not camCycle[currentCameraIndex].notSet
                                
                local x = currentHouse[camCycle[currentCameraIndex].spot].x
                local y = currentHouse[camCycle[currentCameraIndex].spot].y
                local z = currentHouse[camCycle[currentCameraIndex].spot].z + 1.0
                local h = HeadToRot(currentHouse[camCycle[currentCameraIndex].spot].h)
                
                SetFocusArea(x, y, z, x, y, z)
                SendNUIMessage({
                    type = "updatecam",
                    label = camCycle[currentCameraIndex].label
                })
                ChangeSecurityCamera(x, y, z, h)
            end

            -- NIGHTVISION C
            if IsDisabledControlJustPressed(0, 26) then
                if currentHouse.camSettings.nightvision then
                    currentNV = not currentNV
                    SetNightvision(currentNV)
                else
                    exports.pw_notify:SendAlert('error', 'Nightvision module is not installed')
                end
            end
        end
        Citizen.Wait(0)
    end
end)

function ChangeSecurityCamera(x, y, z, r)
    if createdCamera ~= 0 then
        DestroyCam(createdCamera, 0)
        createdCamera = 0
    end

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamCoord(cam, x, y, z)
    SetCamRot(cam, 0.0, 0.0, r, 2)
    RenderScriptCams(1, 0, 0, 1, 1)
    createdCamera = cam
end

function CloseSecurityCamera()
    local ped = PlayerPedId()
    TriggerServerEvent('pw_keynote:server:triggerShowable', false)
    TriggerEvent('pw_properties:client:camDisabled')
    DestroyCam(createdCamera, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    createdCamera = 0
    ClearTimecycleModifier(currentHouse.camSettings.mod)
    SetFocusEntity(ped)
    FreezeEntityPosition(ped, false)
end