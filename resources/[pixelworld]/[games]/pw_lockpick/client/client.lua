--[[
    PLEASE LEAVE THIS INTACT
    Lockpicking MiniGame Coded by Chris Rogers for GTAV Use
    Original Javascript was used from CodePen https://codepen.io/anon/pen/ydOeLo
    Copyright 2019 All Rights Reserved
    Please Do not Rename the resource, i use the name to see how many people are using the resource on statistics.
]]

PW = nil
playerData, playerLoaded = nil, false
local guiEnabled = false
local success = false
local action = nil
local trigger = nil
local npins = nil

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
	end
end)

function DisplayNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

RegisterNetEvent('pw_lockpick:client:startGame')
AddEventHandler('pw_lockpick:client:startGame', function(cb)
    PW.TriggerServerCallback('pw_lockpick:server:getBobbyPins', function(pins, screwdriver)
        if screwdriver > 0 then
            if pins > 0 then
                TriggerEvent("pw:progressbar:progress", {
                    name = "accessing_atm",
                    duration = 3000,
                    label = "Preparing the Lockpick",
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
                            pins = pins,
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
                                    exports['pw_notify']:SendAlert('warning','All of your bobby pins have broke', 5000)
                                    cb(false)
                                    ClearPedTasks(PlayerPedId())
                                    break
                                end
                                Citizen.Wait(0)
                            end
                        end)
                    end
                end)
            else
                exports['pw_notify']:SendAlert('warning','You do not have any bobby pins', 5000)
            end
        else
            exports['pw_notify']:SendAlert('warning','You do not have a screwdriver', 5000)
        end
    end, source)
end)


function testGame()
    TriggerEvent('pw_lockpick:client:startGame', function(success)
        if success then
            print('success')
        else
            print('failed')
        end
    end)
end

--[[Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            testGame()
        end
        Citizen.Wait(3)
    end
end)]]

RegisterNUICallback('escape', function(data, cb)
    SetNuiFocus(false)
    guiEnabled = false
    ClearPedTasks(PlayerPedId())
    action = 'failed'
    cb('ok')
end)

RegisterNUICallback('removepin', function(data, cb)
    TriggerServerEvent('pw_lockpick:server:removePin')
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

            --DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate

            DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride

            if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
                SendNUIMessage({
                    type = "click",
                    pins = npins
                })
            end
        end
        Citizen.Wait(0)
    end
end)