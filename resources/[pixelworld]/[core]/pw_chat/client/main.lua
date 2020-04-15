PW = nil

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:loadFramework', function(obj) PW = obj end)
        Citizen.Wait(1)
	end
end)

RegisterNetEvent('pw:chat:client:ReceiveMe')
AddEventHandler('pw:chat:client:ReceiveMe', function(sender, message)
  local me = PlayerId()
  local senderClient = GetPlayerFromServerId(sender)
  if senderClient == me then
    Citizen.CreateThread(function()
      local timer = 1

      while timer <= 500 do
        local senderPos = GetEntityCoords(GetPlayerPed(senderClient))
        PW.Game.DrawText3D(senderPos.x, senderPos.y, senderPos.z, message)
        timer = timer + 1

        Citizen.Wait(1)
      end
    end)
  elseif GetDistanceBetweenCoords(senderPos, GetEntityCoords(GetPlayerPed(me)), true) < 20.0 then
    if HasEntityClearLosToEntity(GetPlayerPed(me), GetPlayerPed(senderClient), 17 ) then
      Citizen.CreateThread(function()
        local timer = 1

        while timer <= 500 do
          local senderPos = GetEntityCoords(GetPlayerPed(senderClient))
          PW.Game.DrawText3D(senderPos.x, senderPos.y, senderPos.z, message)
          timer = timer + 1

          Citizen.Wait(1)
        end
      end)
    end
  end
end)

RegisterNetEvent('sendProximityMessage')
AddEventHandler('sendProximityMessage', function(id, name, message)
  local myId = PlayerId()
  local pid = GetPlayerFromServerId(id)
  if pid == myId then
    TriggerEvent('chatMessage', "^4" .. name .. "", {0, 153, 204}, "^7 " .. message)
  elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myId)), GetEntityCoords(GetPlayerPed(pid)), true) < 19.999 then
    TriggerEvent('chatMessage', "^4" .. name .. "", {0, 153, 204}, "^7 " .. message)
  end
end)

RegisterNetEvent('sendProximityMessageMe')
AddEventHandler('sendProximityMessageMe', function(id, name, message)
  local myId = PlayerId()
  local pid = GetPlayerFromServerId(id)
  if pid == myId then
    TriggerEvent('chatMessage', "", {255, 0, 0}, " ^6 " .. name .." ".."^6 " .. message)
  elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myId)), GetEntityCoords(GetPlayerPed(pid)), true) < 19.999 then
    TriggerEvent('chatMessage', "", {255, 0, 0}, " ^6 " .. name .." ".."^6 " .. message)
  end
end)

RegisterNetEvent('sendProximityMessageDo')
AddEventHandler('sendProximityMessageDo', function(id, name, message)
  local myId = PlayerId()
  local pid = GetPlayerFromServerId(id)
  if pid == myId then
    TriggerEvent('chatMessage', "", {255, 0, 0}, " ^0* " .. name .."  ".."^0  " .. message)
  elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myId)), GetEntityCoords(GetPlayerPed(pid)), true) < 19.999 then
    TriggerEvent('chatMessage', "", {255, 0, 0}, " ^0* " .. name .."  ".."^0  " .. message)
  end
end)

RegisterNetEvent("pw_chat:client:Do311Alert")
AddEventHandler("pw_chat:client:Do311Alert", function(name, message)
	local locale = ""
	
	local pos = GetEntityCoords(PlayerPedId())
	local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
	local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

	if GetStreetNameFromHashKey(var2) == "" then
		locale = GetStreetNameFromHashKey(var1) .. ' ' .. current_zone
	else
		locale = GetStreetNameFromHashKey(var1) .. ' ' ..GetStreetNameFromHashKey(var2) .. ' ' .. GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
	end

	TriggerServerEvent('pw:chat:server:311Alert', name, locale, message)
end)

RegisterNetEvent("pw_chat:client:Do911Alert")
AddEventHandler("pw_chat:client:Do911Alert", function(name, message)
  local locale = ""
  
	
	local pos = GetEntityCoords(PlayerPedId())
	local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
	local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

	if GetStreetNameFromHashKey(var2) == "" then
		locale = GetStreetNameFromHashKey(var1) .. ' ' .. current_zone
	else
		locale = GetStreetNameFromHashKey(var1) .. ' ' ..GetStreetNameFromHashKey(var2) .. ' ' .. GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
	end

	TriggerServerEvent('pw:chat:server:911Alert', name, locale, message)
end)

RegisterNetEvent("pw_chat:client:DoPoliceDispatch")
AddEventHandler("pw_chat:client:DoPoliceDispatch", function(code, message, gender)
  local locale = ""
	local pos = GetEntityCoords(PlayerPedId())
	local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
	local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

	if GetStreetNameFromHashKey(var2) == "" then
		locale = GetStreetNameFromHashKey(var1) .. ' ' .. current_zone
	else
		locale = GetStreetNameFromHashKey(var1) .. ' ' ..GetStreetNameFromHashKey(var2) .. ' ' .. GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
  end
  
	TriggerServerEvent('pw:chat:server:policeDispatch', code, locale, message, pos, gender)
end)