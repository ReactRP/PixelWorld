local gamePlaying = false
local gameResult = false

--[[
Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            TriggerEvent('pw_lockpick2:client:startGame', 0000, function(success)
                if success then
                    print('test')
                else
                    print('failed')
                end
            end)
        end
        Citizen.Wait(1)
    end
end)]]

RegisterNUICallback('gameOver', function(data, cb)
    gameResult = data.result
    gamePlaying = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "endGame",
    })
end)

RegisterNetEvent('pw_lockpick2:client:startGame')
AddEventHandler('pw_lockpick2:client:startGame', function(code, cb)
    if code == 0000 then
        randomCode = math.random(1000,9999)
    else
        randomCode = code
    end
    startGame(randomCode)
    Citizen.CreateThread(function()
        while true do
            repeat Wait(0) until gamePlaying == false
            cb(gameResult)
            break
            Citizen.Wait(0)
        end
    end)
end)

function startGame(randomCode)
    gamePlaying = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "startGame",
        code = tostring(randomCode),
    })
end
