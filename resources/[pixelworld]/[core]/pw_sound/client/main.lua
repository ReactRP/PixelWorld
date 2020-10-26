local standardVolumeOutput = 1.0
local PlayingSounds = {}

RegisterNetEvent('pw_sound:client:PlayOnOne')
AddEventHandler('pw_sound:client:PlayOnOne', function(soundFile, soundVolume)
    SendNUIMessage({
        action = 'playSound',
        source = GetPlayerServerId(PlayerId()),
        file = soundFile,
        volume = soundVolume
    })
    PlayingSounds[GetPlayerServerId(PlayerId())] = soundFile
end)

RegisterNetEvent('pw_sound:client:LoopOnOne')
AddEventHandler('pw_sound:client:LoopOnOne', function(soundFile, soundVolume)
    PlayingSounds[GetPlayerServerId(PlayerId())] = soundFile
    SendNUIMessage({
        action = 'loopSound',
        source = GetPlayerServerId(PlayerId()),
        file = soundFile,
        volume = soundVolume
    })
end)

RegisterNetEvent('pw_sound:client:StopOnOne')
AddEventHandler('pw_sound:client:StopOnOne', function(soundFile)
    if PlayingSounds[GetPlayerServerId(PlayerId())] == soundFile then
        SendNUIMessage({
            action = 'stopSound',
            source = GetPlayerServerId(PlayerId())
        })
    end
end)

RegisterNetEvent('pw_sound:client:PlayWithinDistance')
AddEventHandler('pw_sound:client:PlayWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = #(vector3(lCoords.x, lCoords.y, lCoords.z) - vector3(eCoords.x, eCoords.y, eCoords.z))
    if(distIs <= maxDistance) then
        PlayingSounds[playerNetId] = soundFile
        SendNUIMessage({
            action = 'playSound',
            source = playerNetId,
            file = soundFile,
            volume = soundVolume * (1.0 - (distIs / 100))
        })
    end
end)

RegisterNetEvent('pw_sound:client:StopWithinDistance')
AddEventHandler('pw_sound:client:StopWithinDistance', function(playerNetId, soundFile, soundVolume)
    if PlayingSounds[playerNetId] == soundFile then
        PlayingSounds[playerNetId] = nil
        SendNUIMessage({
            action = 'stopSound',
            source = playerNetId
        })
    end
end)

RegisterNetEvent('pw_sound:client:LoopWithinDistance')
AddEventHandler('pw_sound:client:LoopWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = #(vector3(lCoords.x, lCoords.y, lCoords.z) - vector3(eCoords.x, eCoords.y, eCoords.z))
    if(distIs <= maxDistance) then
        SendNUIMessage({
            action = 'loopSound',
            source = playerNetId,
            file = soundFile,
            volume = soundVolume * (1.0 - (distIs / 100))
        })
        PlayingSounds[playerNetId] = soundFile
    else
        TriggerEvent('pw_sound:client:StopLoopingSoundWithinDistance', playerNetId, soundFile)
    end

    Citizen.CreateThread(function()
        while PlayingSounds[playerNetId] ~= nil do
            local lCoords = GetEntityCoords(GetPlayerPed(-1))
            local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
            local distIs  = #(vectory3(lCoords.x, lCoords.y, lCoords.z) - vector3(eCoords.x, eCoords.y, eCoords.z))
            SendNUIMessage({
                action = 'changeVol',
                source = playerNetId,
                volume = soundVolume * (1.0 - (distIs / 100))
            })
            Citizen.Wait(100)
        end
    end)
end)

RegisterNetEvent('pw_sound:client:StopLoopingSoundWithinDistance')
AddEventHandler('pw_sound:client:StopLoopingSoundWithinDistance', function(playerNetId, soundFile)
    if soundsPlaying == soundFile then
        SendNUIMessage({
            action = 'stopSound',
            source = playerNetId
        })
    end
end)

RegisterNUICallback('SoundEnd', function(data, cb)
    if PlayingSounds[data.source] ~= nil then
        PlayingSounds[data.source] = nil
    end
end)