PW = nil

TriggerEvent('pw:loadFramework', function(framework)
    PW = framework
end)

local sInfo = {}
local defaultInfo = {
    ['volume'] = 1.0,
    ['url'] = "",
    ['id'] = "",
    ['title'] = "",
    ['position'] = nil,
    ['distance'] = 0,
    ['playing'] = false,
    ['paused'] = false,
    ['loop'] = false,
}

PW.RegisterServerCallback('xsound:server:sendInfo', function(source, cb)
    cb(sInfo)
end)

RegisterServerEvent('xsound:server:updateTitle')
AddEventHandler('xsound:server:updateTitle', function(id, title)
    if sInfo[id].title == "" and title then
        sInfo[id].title = title
        TriggerClientEvent('xsound:client:updateTitle', -1, id, title)
    end
end)

RegisterServerEvent('xsound:server:updateDistance')
AddEventHandler('xsound:server:updateDistance', function(name_, distance_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].distance = distance_

    TriggerClientEvent('xsound:client:updateDistance', -1, name_, distance_)
end)

RegisterServerEvent('xsound:server:playUrl')
AddEventHandler('xsound:server:playUrl', function(name_, url_, volume_,loop_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].volume = volume_
    sInfo[name_].url = url_
    sInfo[name_].id = name_
    sInfo[name_].playing = true
    sInfo[name_].loop = loop_ or false

    TriggerClientEvent('xsound:client:playUrl', -1, name_, url_, volume_,loop_)

    Citizen.CreateThread(function()
        while sInfo[name_] do
            if sInfo[name_].playing then
                sInfo[name_].seconds = (sInfo[name_].seconds or 0) + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterServerEvent('xsound:server:playUrlPos')
AddEventHandler('xsound:server:playUrlPos', function(name_, url_, volume_, pos, loop_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].volume = volume_
    sInfo[name_].url = url_
    sInfo[name_].position = pos
    sInfo[name_].id = name_
    sInfo[name_].playing = true
    sInfo[name_].loop = loop_ or false

    TriggerClientEvent('xsound:client:playUrlPos', -1, name_, url_, volume_, pos, loop_)

    Citizen.CreateThread(function()
        while sInfo[name_] do
            if sInfo[name_].playing then
                sInfo[name_].seconds = (sInfo[name_].seconds or 0) + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterServerEvent('xsound:server:playPos')
AddEventHandler('xsound:server:playPos', function(name_, volume_, pos, loop_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].volume = volume_
    sInfo[name_].position = pos
    sInfo[name_].id = name_
    sInfo[name_].playing = true
    sInfo[name_].loop = loop_ or false

    TriggerClientEvent('xsound:client:playPos', -1, name_, volume_, pos, loop_)

    Citizen.CreateThread(function()
        while sInfo[name_] do
            if sInfo[name_].playing then
                sInfo[name_].seconds = (sInfo[name_].seconds or 0) + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterServerEvent('xsound:server:play')
AddEventHandler('xsound:server:play', function(name_, volume_,loop_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].volume = volume_
    sInfo[name_].id = name_
    sInfo[name_].playing = true
    sInfo[name_].loop = loop_ or false
    
    TriggerClientEvent('xsound:client:play', -1, name_, volume_, loop_)

    Citizen.CreateThread(function()
        while sInfo[name_] do
            if sInfo[name_].playing then
                sInfo[name_].seconds = (sInfo[name_].seconds or 0) + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterServerEvent('xsound:server:soundPosition')
AddEventHandler('xsound:server:soundPosition', function(name_, pos)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].position = pos
    sInfo[name_].id = name_

    TriggerClientEvent('xsound:client:soundPosition', -1, name_, pos)
end)

RegisterServerEvent('xsound:server:stop')
AddEventHandler('xsound:server:stop', function(name_, ended)
    if sInfo[name_] then
        sInfo[name_] = nil
        TriggerClientEvent('xsound:client:stop', -1, name_, ended)
    end
end)

RegisterServerEvent('xsound:server:resume')
AddEventHandler('xsound:server:resume', function(name_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].playing = true
    sInfo[name_].paused = false

    TriggerClientEvent('xsound:client:resume', -1, name_)
end)

RegisterServerEvent('xsound:server:pause')
AddEventHandler('xsound:server:pause', function(name_)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].playing = false
    sInfo[name_].paused = true

    TriggerClientEvent('xsound:client:pause', -1, name_)
end)

RegisterServerEvent('xsound:server:volume')
AddEventHandler('xsound:server:volume', function(name_, vol)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].volume = vol

    TriggerClientEvent('xsound:client:volume', -1, name_, vol)
end)

RegisterServerEvent('xsound:server:maxVol')
AddEventHandler('xsound:server:maxVol', function(name_, vol)
    if sInfo[name_] == nil then sInfo[name_] = defaultInfo end
    sInfo[name_].volume = vol

    TriggerClientEvent('xsound:client:maxVol', -1, name_, vol)
end)