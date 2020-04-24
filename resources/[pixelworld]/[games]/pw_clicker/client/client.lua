local guiEnabled = false
local success = false
local action = nil
local trigger = nil

function DisplayNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function testGame()
    TriggerEvent('pw_clicker:client:startGame', 5, function(success)
        if success then
            print('success')
        else
            print('failed')
        end
    end)
end

--[[
Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            testGame()
        end
        Citizen.Wait(1)
    end
end)]]

RegisterNetEvent('pw_clicker:client:startGame')
AddEventHandler('pw_clicker:client:startGame', function(n, cb)

    TriggerEvent("pw:progressbar:progress", {
        name = "accessing_atm",
        duration = 5000,
        label = "Preparing the Tools",
        useWhileDead = false,
            canCancel = false,
            controlDisables = {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = false,
            },
            animation = {
                animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer",
            }
    }, function(status)
        if not status then
            SetNuiFocus(true)
            guiEnabled = true
            SendNUIMessage({
                type = "enableui",
                tries = n,
                enable = true,
            })
            Citizen.CreateThread(function()
                while true do
                    if action == 'success' then
                        action = nil
                        cb(true)
                        ClearPedTasks(PlayerPedId())
                        break
                    elseif action == 'failed' then
                        action = nil
                        cb(false)
                        ClearPedTasks(PlayerPedId())
                        break
                    end
                    Citizen.Wait(0)
                end
            end)
        end
    end)
end)

RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false)
    guiEnabled = false
    ClearPedTasks(PlayerPedId())
    cb('ok')
end)

RegisterNUICallback('process', function(data, cb)
    SetNuiFocus(false)
    guiEnabled = false
    if data.state then
        action = 'success'
    else
        action = 'failed'
    end
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        if guiEnabled then
            DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
            DisableControlAction(0, 2, guiEnabled) -- LookUpDown

            DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate

            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click"
                })
            end
        end
        Citizen.Wait(0)
    end
end)