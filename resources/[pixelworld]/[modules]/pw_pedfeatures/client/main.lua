PW = nil
characterLoaded, playerData = false, nil
local isCrouching = false
local myFeatures = {}

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
            PW.TriggerServerCallback('pw_pedfeatures:server:getFeatures', function(settings)
                myFeatures = settings
                LoadFeatures(myFeatures)
            end)
        else
            playerData = data
        end
    else
        playerData = nil
        characterLoaded = false
    end
end)


RegisterNetEvent('pw_pedfeatures:client:walkMenu')
AddEventHandler('pw_pedfeatures:client:walkMenu', function()
    local menu, tempMenu = {}, {}

    table.insert(menu, { ['label'] = "Reset", ['action'] = 'pw_pedfeatures:client:setWalk', ['value'] = { ['style'] = 'reset'}, ['triggertype'] = 'client', ['color'] = 'danger' })
    for k,v in pairs(Config.Walks) do
        table.insert(tempMenu, { ['label'] = k, ['action'] = 'pw_pedfeatures:client:setWalk', ['value'] = { ['label'] = k, ['style'] = v }, ['triggertype'] = 'client', ['color'] = 'primary' })
    end

    table.sort(tempMenu, function(a,b) return a.label < b.label end)
    for k,v in pairs(tempMenu) do
        table.insert(menu, v)
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Walking Styles")
end)

RegisterNetEvent('pw_pedfeatures:client:moodMenu')
AddEventHandler('pw_pedfeatures:client:moodMenu', function()
    local menu, tempMenu = {}, {}

    table.insert(menu, { ['label'] = "Reset", ['action'] = 'pw_pedfeatures:client:setMood', ['value'] = { ['style'] = 'reset' }, ['triggertype'] = 'client', ['color'] = 'danger' })
    for k,v in pairs(Config.Moods) do
        table.insert(tempMenu, { ['label'] = k, ['action'] = 'pw_pedfeatures:client:setMood', ['value'] = { ['label'] = k, ['style'] = v }, ['triggertype'] = 'client', ['color'] = 'primary' })
    end

    table.sort(tempMenu, function(a,b) return a.label < b.label end)
    for k,v in pairs(tempMenu) do
        table.insert(menu, v)
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Mood")
end)

RegisterNetEvent('pw_pedfeatures:client:setWalk')
AddEventHandler('pw_pedfeatures:client:setWalk', function(data)
    local ped = PlayerPedId()
    if data.style == 'reset' then
        ResetPedMovementClipset(ped, 0.0)
        SaveFeature('walk', 'default')
        exports.pw_notify:SendAlert('inform', 'Walking style set to default', 4000)
    else
        ReqAnimSet(data.style)
        SetPedMovementClipset(ped, data.style, 0.2)
        SaveFeature('walk', data.style)
        TriggerEvent('pw_pedfeatures:client:walkMenu')
        exports.pw_notify:SendAlert('inform', 'Walking style set to ' .. data.label, 4000)
    end
end)

RegisterNetEvent('pw_pedfeatures:client:setMood')
AddEventHandler('pw_pedfeatures:client:setMood', function(data)
    local ped = PlayerPedId()
    if data.style == 'reset' then
        ClearFacialIdleAnimOverride(ped)
        SaveFeature('mood', 'default')
        exports.pw_notify:SendAlert('inform', 'Mood set to default', 4000)
    else
        SetFacialIdleAnimOverride(ped, data.style, 0)
        SaveFeature('mood', data.style)
        TriggerEvent('pw_pedfeatures:client:moodMenu')
        exports.pw_notify:SendAlert('inform', 'Mood set to ' .. data.label, 4000)
    end
end)

RegisterNetEvent('pw_pedfeatures:client:crouching')
AddEventHandler('pw_pedfeatures:client:crouching', function(state)
    isCrouching = state
end)

function SaveFeature(type, style)
    myFeatures[type] = style
    TriggerServerEvent('pw_pedfeatures:server:saveFeatures', myFeatures)
end

function LoadFeatures(feats)
    local ped = PlayerPedId()

    if feats['walk'] ~= 'default' then
        ReqAnimSet(feats['walk'])
        SetPedMovementClipset(ped, feats['walk'], 0.2)
    end

    if feats['mood'] ~= 'default' then
        SetFacialIdleAnimOverride(ped, feats['mood'], 0)
    end
end

function ReqAnimSet(anim)
    while not HasAnimSetLoaded(anim) do
        RequestAnimSet(anim)
        Wait(10)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded then
            local checkLimp = exports.pw_skeleton:IsInjuryCausingLimp()
            if not checkLimp and not isCrouching and myFeatures['walk'] ~= nil and myFeatures['mood'] ~= nil then
                LoadFeatures(myFeatures)
            elseif isCrouching then
                local ped = PlayerPedId()
                SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
            elseif checkLimp then
                exports.pw_skeleton:runStuff()
            end
        end
    end
end)
