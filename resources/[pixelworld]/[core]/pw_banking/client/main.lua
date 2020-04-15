PW = nil
playerLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
currentBanks, bankBlips = {}, {}
local currentBank = false
bankOpen = false

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
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerLoaded = true
            Citizen.CreateThread(function()
                while playerLoaded do
                    GLOBAL_PED = PlayerPedId()
                    Citizen.Wait(500)
                end
            end)

            Citizen.CreateThread(function()
                while playerLoaded do
                    if GLOBAL_PED ~= nil then
                        GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
                    end
                    Citizen.Wait(100)
                end
            end)
            doBankBlips()
            startBankTick()
        else
            PW.TriggerServerCallback('pw_banking:server:requestBanks', function(banks)
                currentBanks = banks
                playerData = data
            end)
        end
    else
        playerData = nil
        playerLoaded = false
        removeBlips()
        currentBank = false
        currentBanks = {}
    end
end)

RegisterNetEvent('pw:characters:cashAdjustment')
AddEventHandler('pw:characters:cashAdjustment', function(amount)
    if playerLoaded and playerData then
        playerData.cash = tonumber(amount)
        TriggerEvent('pw_banking:client:updatePlayerData')
    end
end)

RegisterNetEvent('pw_banking:client:updatePlayerData')
AddEventHandler('pw_banking:client:updatePlayerData', function()
    if bankOpen then
        SendNUIMessage({
            action = "updatePlayerData",
            playerData = playerData,
        })
    end
end) 

RegisterNetEvent('pw_banking:client:sendUpdate')
AddEventHandler('pw_banking:client:sendUpdate', function(data)
    if bankOpen then
        SendNUIMessage({
            action = "updateBanking",
            data = data,
        })
    end
end)

RegisterNetEvent('pw_banking:client:savingsOpened')
AddEventHandler('pw_banking:client:savingsOpened', function()
    SendNUIMessage({
        action = "savingsOpened",
    })
end)

function doBankBlips()
    for k, v in pairs(currentBanks) do
        bankBlips[k] = AddBlipForCoord(tonumber(v.coords.x), tonumber(v.coords.y), tonumber(v.coords.z))
        SetBlipSprite(bankBlips[k], Config.Blip.blipType)
        SetBlipDisplay(bankBlips[k], 4)
        SetBlipScale  (bankBlips[k], Config.Blip.blipScale)
        SetBlipColour (bankBlips[k], Config.Blip.blipColor)
        SetBlipAsShortRange(bankBlips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(tostring("Bank"))
        EndTextCommandSetBlipName(bankBlips[k])
    end
end

function removeBlips()
    for k, v in pairs(bankBlips) do
        RemoveBlip(v)
    end
    bankBlips = {}
end

function openMainBanking(v)
    PW.ExecuteServerCallback('pw_banking:server:requestBankingInformation', function(information)
        if information ~= nil then
            bankOpen = true
            SetNuiFocus(true, true)
            PW.Print(information)
            TriggerEvent('pw_voip:client:onlyAllowPTTOn')
            SendNUIMessage({
                action = "openBankingTerminal",
                playerData = playerData,
                data = information,
                bank = v,
            })
        else
            exports['pw_notify']:SendAlert('error', 'There was an error retreiving your banking information.', 5000)
        end
    end)
end

function startKeyTick(k, v)
    Citizen.CreateThread(function()
        while currentBank and playerLoaded do
            if currentBank == k then
                if IsControlJustPressed(0, 38) then 
                    openMainBanking(v)
                end
            end
            Citizen.Wait(5)
        end
    end)
end

function startBankTick()
    Citizen.CreateThread(function()
        while playerLoaded do
            for k, v in pairs(currentBanks) do
                local distance = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z))
                if distance < 10.0 then
                    if v.bankOpen then
                        DrawMarker(25, v.coords.x, v.coords.y, v.coords.z - 0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 56, 165, 61, 250, false, false, 2, false, false, false, false)
                    else
                        DrawMarker(25, v.coords.x, v.coords.y, v.coords.z - 0.98, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 178, 19, 51, 250, false, false, 2, false, false, false, false)
                    end
                end

                if distance < 1.2 then
                    if not currentBank then
                        currentBank = k
                        startKeyTick(k, v)
                    end
                else
                    if currentBank == k then
                        currentBank = false
                    end
                end
            end
            Citizen.Wait(1)
        end
    end)
end