RegisterServerEvent('pw_sound:server:PlayOnOne')
AddEventHandler('pw_sound:server:PlayOnOne', function(clientNetId, soundFile, soundVolume)
    TriggerClientEvent('pw_sound:client:PlayOnOne', clientNetId, soundFile, soundVolume)
end)

RegisterServerEvent('pw_sound:server:PlayOnSource')
AddEventHandler('pw_sound:server:PlayOnSource', function(soundFile, soundVolume)
    TriggerClientEvent('pw_sound:client:PlayOnOne', source, soundFile, soundVolume)
end)

RegisterServerEvent('pw_sound:server:PlayOnAll')
AddEventHandler('pw_sound:server:PlayOnAll', function(soundFile, soundVolume)
    TriggerClientEvent('pw_sound:client:PlayOnOne', -1, soundFile, soundVolume)
end)

RegisterServerEvent('pw_sound:server:PlayWithinDistance')
AddEventHandler('pw_sound:server:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    TriggerClientEvent('pw_sound:client:PlayWithinDistance', -1, source, maxDistance, soundFile, soundVolume)
end)

RegisterServerEvent('pw_sound:server:StopWithinDistance')
AddEventHandler('pw_sound:server:StopWithinDistance', function(soundFile)
    TriggerClientEvent('pw_sound:client:StopWithinDistance', -1, source, soundFile)
end)

RegisterServerEvent('pw_sound:server:LoopOnSource')
AddEventHandler('pw_sound:server:LoopOnSource', function(soundFile, soundVolume)
    TriggerClientEvent('pw_sound:client:LoopOnOne', source, soundFile, soundVolume)
end)

RegisterServerEvent('pw_sound:server:LoopWithinDistance')
AddEventHandler('pw_sound:server:LoopWithinDistance', function(maxDistance, soundFile, soundVolume)
    TriggerClientEvent('pw_sound:client:LoopWithinDistance', -1, source, maxDistance, soundFile, soundVolume)
end)

RegisterServerEvent('pw_sound:server:StopLoopingSound')
AddEventHandler('pw_sound:server:StopLoopingSound', function(soundFile)
    TriggerClientEvent('pw_sound:client:StopLoopingSoundWithinDistance', -1, soundFile)
end)