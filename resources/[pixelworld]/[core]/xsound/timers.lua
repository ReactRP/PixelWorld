PW = nil
characterLoaded, GLOBAL_PED, GLOBAL_COORDS, playerData = false, nil, nil, nil
soundInfo = {}

defaultInfo = {
    ['volume'] = 1.0,
    ['url'] = "",
    ['id'] = "",
    ['position'] = nil,
    ['distance'] = 0,
    ['playing'] = false,
    ['paused'] = false,
    ['loop'] = false,
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
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            characterLoaded = true
            SendNUIMessage({
                status = "load"
            })
        else
            playerData = data
        end
    else
        SendNUIMessage({
            status = "unload"
        })
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

Citizen.CreateThread(function()
    while true do
        if characterLoaded and GLOBAL_COORDS then
            SendNUIMessage({
                status = "position",
                x = GLOBAL_COORDS.x,
                y = GLOBAL_COORDS.y,
                z = GLOBAL_COORDS.z
            })
        end
        Citizen.Wait(Config.RefreshTime)
    end
end)

function distance(name_, distance_)
    SendNUIMessage({
        status = "distance",
        name = name_,
        distance = distance_,
    })

    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].distance = distance_
end

exports('Distance', distance)

function playurl(name_, url_, volume_,loop_)
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = 0,
        y = 0,
        z = 0,
        dynamic = false,
        volume = volume_,
        loop = loop_ or false
    })

    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = volume_
    soundInfo[name_].url = url_
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
end

exports('PlayUrl', playurl)

function playurlpos(name_, url_, volume_, pos,loop_)
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        dynamic = true,
        volume = volume_,
        loop = (loop_ == nil) and false or loop_,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = volume_
    soundInfo[name_].url = url_
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
end

exports('PlayUrlPos', playurlpos)

function playpos(name_, volume_, pos,loop_)
    SendNUIMessage({
        status = "play",
        name = name_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        dynamic = true,
        volume = volume_,
        loop = (loop_ == nil) and false or loop_,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = volume_
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
end

exports('PlayPos', playpos)

function play(name_, volume_,loop_)
    SendNUIMessage({
        status = "play",
        name = name_,
        x = 0,
        y = 0,
        z = 0,
        dynamic = false,
        volume = volume_,
        loop = (loop_ == nil) and false or loop_,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = volume_
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
end

exports('Play', play)

function position(name_, pos)
    SendNUIMessage({
        status = "soundPosition",
        name = name_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
    })

    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
end

exports('Position', position)

function stop(name_)
    SendNUIMessage({
        status = "delete",
        name = name_
    })
    soundInfo[name_] = nil
end

exports('Stop', stop)

function resume(name_)
    SendNUIMessage({
        status = "resume",
        name = name_
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end
    soundInfo[name_].playing = true
    soundInfo[name_].paused = false
end

exports('Resume', resume)

function pause(name_)
    SendNUIMessage({
        status = "pause",
        name = name_
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end
    soundInfo[name_].playing = false
    soundInfo[name_].paused = true
end

exports('Pause', pause)

function volume(name_, vol)
    SendNUIMessage({
        status = "volume",
        volume = vol,
        name = name_,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = vol
end

exports('setVolume', volume)

function volumeMax(name_, vol)
    SendNUIMessage({
        status = "max_volume",
        volume = vol,
        name = name_,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end

    soundInfo[name_].volume = vol
end

exports('setVolumeMax', volumeMax)

function getvolume(name_)
    if soundInfo[name_] == nil then soundInfo[name_] = defaultInfo end
    return soundInfo[name_].volume
end

exports('getVolume', getvolume)

function getInfo(name_)
    if soundInfo[name_] then
        return soundInfo[name_]
    else
        return false
    end
end

exports('getInfo', getInfo)