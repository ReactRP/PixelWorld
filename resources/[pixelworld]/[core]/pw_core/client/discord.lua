local WaitTime = 1500
local overRide = false
local overRideText = nil

RegisterNetEvent('pw_discord:client:overRide')
AddEventHandler('pw_discord:client:overRide', function(text)
    overRideText = text
    overRide = true
    Citizen.CreateThread(function()
        Citizen.Wait(6000)
        overRide = false
        overRideText = nil
    end)
end)

Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent('getItemTest')
        end
        Citizen.Wait(2)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(WaitTime)
        local playerPed = PlayerPedId()
        local playerId = GetPlayerServerId(PlayerId())
        N_0xf4f2c0d4ee209e20() 
		N_0x9e4cfff989258472()
        SetDiscordAppId(Config.Discord.AppID)
        SetDiscordRichPresenceAssetSmall(Config.Discord.AssetSm)
        SetDiscordRichPresenceAsset(Config.Discord.AssetLg)
        SetDiscordRichPresenceAssetText(Config.Discord.LargeTxt)
        SetDiscordRichPresenceAssetSmallText(Config.Discord.SmallTxt)
        if playerLoaded then
            if overRide then
                SetRichPresence("["..playerId.."] "..overRideText)
            else
                local x,y,z = table.unpack(GetEntityCoords(playerPed,true))
                local StreetHash = GetStreetNameAtCoord(x, y, z)
                Citizen.Wait(WaitTime)
                if StreetHash ~= nil then
                    StreetName = GetStreetNameFromHashKey(StreetHash)
                    if IsPedOnFoot(playerPed) and not IsEntityInWater(playerPed) then
                        if IsPedSprinting(playerPed) then
                            SetRichPresence("["..playerId.."] Sprinting down "..StreetName)
                        elseif IsPedRunning(playerPed) then
                            SetRichPresence("["..playerId.."] Running down "..StreetName)
                        elseif IsPedWalking(playerPed) then
                            SetRichPresence("["..playerId.."] Walking down "..StreetName)
                        elseif IsPedStill(playerPed) then
                            SetRichPresence("["..playerId.."] Standing on "..StreetName)
                        end
                    elseif GetVehiclePedIsUsing(playerPed) ~= nil and not IsPedInAnyHeli(playerPed) and not IsPedInAnyPlane(playerPed) and not IsPedOnFoot(playerPed) and not IsPedInAnySub(playerPed) and not IsPedInAnyBoat(playerPed) then
                        local MPH = math.ceil(GetEntitySpeed(GetVehiclePedIsUsing(playerPed)) * 2.236936)
                        if MPH > 70 then
                            SetRichPresence("["..playerId.."] Speeding down "..StreetName)
                        elseif MPH <= 70 and MPH > 0 then
                            SetRichPresence("["..playerId.."] Cruising down "..StreetName)
                        elseif MPH == 0 then
                            SetRichPresence("["..playerId.."] Parked on "..StreetName)
                        end
                    elseif IsPedInAnyHeli(playerPed) or IsPedInAnyPlane(playerPed) then
                        if IsEntityInAir(GetVehiclePedIsUsing(playerPed)) or GetEntityHeightAboveGround(GetVehiclePedIsUsing(playerPed)) > 5.0 then
                            SetRichPresence("["..playerId.."] Flying over "..StreetName)
                        else
                            SetRichPresence("["..playerId.."] Landed at "..StreetName)
                        end
                    elseif IsEntityInWater(playerPed) then
                        SetRichPresence("["..playerId.."] Swimming around")
                    elseif IsPedInAnyBoat(playerPed) and IsEntityInWater(GetVehiclePedIsUsing(playerPed)) then
                        SetRichPresence("["..playerId.."] Sailing around in a Boat")
                    elseif IsPedInAnySub(playerPed) and IsEntityInWater(GetVehiclePedIsUsing(playerPed)) then
                        SetRichPresence("["..playerId.."] In a yellow submarine")
                    end
                else
                    SetRichPresence("["..playerId.."] Playing as: "..playerData.name)
                end
            end
        else
            SetRichPresence("["..playerId.."] Character Selection")
        end
	end
end)