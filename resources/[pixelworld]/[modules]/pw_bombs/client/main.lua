PW, characterLoaded, playerData = nil, false, nil
local armedBombsT = {}
local hasPlanted, showingText = 0, false

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
		else
			playerData = data
		end
	else
		playerData = nil
		characterLoaded = false
	end
end)

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(500)
		if characterLoaded then
			local playerPed = PlayerPedId()
			if playerPed ~= GLOBAL_PED then
				GLOBAL_PED = playerPed
			end
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

RegisterNetEvent('pw:updateJob')
AddEventHandler('pw:updateJob', function(job)
	playerData.job = job
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
	playerData.job.duty = toggle
end)

RegisterNetEvent('abomb:updateBombs')
AddEventHandler('abomb:updateBombs', function(bombTable)
	armedBombsT = bombTable
end)

RegisterNetEvent('abomb:assemble')
AddEventHandler('abomb:assemble', function(data)
	-- coloca saco no chao
	local ped = PlayerPedId()
	local pedCoords = GetEntityCoords(ped)
	local fwVec = GetEntityForwardVector(ped)
	local x, y, z = table.unpack(pedCoords + fwVec * 0.7 + 0.15)
	x = x - 0.705
	y = y - 0.05
	
	local bag = 'prop_cs_heist_bag_02'
	RequestModel(GetHashKey(bag))
	while (not HasModelLoaded(bag)) do
		Wait(1)
	end
	
	Citizen.CreateThread(function()
		if DoesEntityExist(ped) then
			local ad = "weapons@projectile@sticky_bomb"
			local anim = "plant_floor"
			loadAnimDict(ad)
			TaskPlayAnim( ped, ad, anim, 1.0, -5.0, -1, 0, 0, 0, 0, 0 )
			local c4 = nil
			if c4 == nil then
				c4 = CreateObject(GetHashKey(bag), 0, 0, 0, true, true, true) 
			end			
			AttachEntityToEntity(c4, ped, GetPedBoneIndex(ped, 57005), 0.356, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) 
			Citizen.Wait(1000)
			if c4 ~= nil then
				DeleteEntity(c4) 
				c4 = nil
				bagProp = CreateObject(GetHashKey(bag), x, y, z, true, false, true)
				PlaceObjectOnGroundProperly(bagProp)
				SetModelAsNoLongerNeeded(bag)
				SetEntityAsMissionEntity(bagProp)
			end
		end
	end)

	TriggerEvent('pw:progressbar:progress',
		{
			name = 'assemble_bomb',
			duration = 1500,
			label = 'Preparing the bag',
			useWhileDead = false,
			canCancel = false,
			controlDisables = {
				disableMovement = true,
				disableCarMovement = false,
				disableMouse = true,
				disableCombat = true,
			},
		},
		function(status)
			if not status then
				ClearPedTasks(ped)
				FreezeEntityPosition(ped, true)
				Citizen.Wait(1000)
				FreezeEntityPosition(ped, false)
				Citizen.CreateThread(function()
					if DoesEntityExist(ped) then
						local ad = "weapons@projectile@sticky_bomb"
						local anim = "plant_floor" 
						loadAnimDict(ad)
						TaskPlayAnim( ped, ad, anim, 1.0, -5.0, -1, 0, 0, 0, 0, 0 )
						local c4 = nil
						if c4 == nil then
							c4 = CreateObject(GetHashKey("prop_ld_bomb"), 0, 0, 0, true, true, true) 
						end			
						AttachEntityToEntity(c4, ped, GetPedBoneIndex(ped, 57005), 0.356, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) 
						Citizen.Wait(1000)
						if c4 ~= nil then
							DeleteEntity(c4) 
							c4 = nil
						end
					end
				end)

				TriggerEvent('pw:progressbar:progress',
					{
						name = 'assemble_bomb',
						duration = 1500,
						label = 'Placing explosives inside the bag',
						useWhileDead = false,
						canCancel = false,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = false,
							disableMouse = true,
							disableCombat = true,
						},
					},
					function(status)
						if not status then
							ClearPedTasks(ped)
							DeleteObject(bagProp)
							TriggerServerEvent('abomb:givebomb', data)
						end
					end)
			end
		end)
end)

RegisterNetEvent('abomb:plant')
AddEventHandler('abomb:plant', function(data)
	if hasPlanted == 0 then
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)
		local fwVec = GetEntityForwardVector(ped)
		local x, y, z = table.unpack(pedCoords + fwVec * 0.7 + 0.15)
		x = x - 0.705
		y = y - 0.05
		
		local bag = 'prop_cs_heist_bag_02'
		RequestModel(GetHashKey(bag))
		while (not HasModelLoaded(bag)) do
			Wait(1)
		end
		
		Citizen.CreateThread(function()
			if DoesEntityExist(ped) then
				local ad = "weapons@projectile@sticky_bomb"
				local anim = "plant_floor"
				loadAnimDict(ad)
				TaskPlayAnim( ped, ad, anim, 1.0, -5.0, -1, 0, 0, 0, 0, 0 )
				local c4 = nil
				if c4 == nil then
					c4 = CreateObject(GetHashKey(bag), 0, 0, 0, true, true, true) 
				end			
				AttachEntityToEntity(c4, ped, GetPedBoneIndex(ped, 57005), 0.356, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true) 
				Citizen.Wait(1000)
				if c4 ~= nil then
					DeleteEntity(c4) 
					c4 = nil
					bagProp = CreateObject(GetHashKey(bag), x, y, z, true, false, true)
					PlaceObjectOnGroundProperly(bagProp)
					SetModelAsNoLongerNeeded(bag)
					SetEntityAsMissionEntity(bagProp)
				end
			end
		end)

		TriggerEvent('pw:progressbar:progress',
			{
				name = 'assemble_bomb',
				duration = 1500,
				label = 'Preparing the bag',
				useWhileDead = false,
				canCancel = false,
				controlDisables = {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = true,
					disableCombat = true,
				},
			},
			function(status)
				if not status then
					ClearPedTasks(ped)
					FreezeEntityPosition(ped, true)
					Citizen.Wait(1000)
					FreezeEntityPosition(ped, false)
					Citizen.CreateThread(function()
						if DoesEntityExist(ped) then
							local ad = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"--"misstrevor2ig_7"
							local anim = "machinic_loop_mechandplayer"--"plant_bomb" 
							
							loadAnimDict(ad)
							TaskPlayAnim( ped, ad, anim, 5.0, -5.0, -1, 0, 0, 0, 0, 0 )
						end
					end)

					TriggerEvent('pw:progressbar:progress',
						{
							name = 'assemble_bomb',
							duration = 5500,
							label = 'Activating explosives',
							useWhileDead = false,
							canCancel = false,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = false,
								disableMouse = true,
								disableCombat = true,
							},
						},
						function(status)
							if not status then
								ClearPedTasks(ped)
								hasPlanted = bagProp
								TriggerServerEvent('abomb:bombplanted', bagProp, x, y, z, data)
							end
						end)
				end
			end)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if armedBombsT ~= nil then
			for k, v in pairs(armedBombsT) do
				local ped = GLOBAL_PED
				local currentCoords = GLOBAL_COORDS
				local distance = #(currentCoords - vector3(v.x, v.y, v.z))
				if distance < 5.0 and v.countdownStatus and v.timeLeft > 0 then
					if playerData.job ~= nil and playerData.job.name == "police" and playerData.job.duty then
						if not showingText or v.prevTime ~= v.timeLeft then
							showingText = v.id
							armedBombsT[k].prevTime = v.timeLeft
							TriggerEvent('pw_drawtext:showNotification', { title = "Bomb Status", message = "<b><span style='font-size:20px'>Timeleft: <span class='text-danger'>" .. v.timeLeft .. "</span> seconds<br>Press <span class='text-primary'>[E]</span> to disarm</span></b>", icon = "fad fa-bomb" })
						end
						if not v.disarmStatus then
							DrawMarker(25, v.x, v.y, v.z-1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, true, false, false, false)
							if IsControlJustPressed(0, 38) then
								TriggerServerEvent('abomb:defusing', v.id, true)
								v.disarmStatus = true

								TriggerEvent('pw:progressbar:progress',
									{
										name = 'preparing_lockpick',
										duration = 5000,
										label = 'Preparing disarming tools',
										useWhileDead = false,
										canCancel = false,
										controlDisables = {
											disableMovement = true,
											disableCarMovement = false,
											disableMouse = true,
											disableCombat = true,
										},
										animation = {
											animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
											anim = "machinic_loop_mechandplayer",
										}
									},
									function(status)
										if not status then
											TriggerEvent('adefuse:StartDefuse', v.timeLeft, v.id, function(outcome)
												if outcome then
													ClearPedTasks(ped)
													exports.pw_notify:SendAlert('success', 'Bomb successfuly disarmed')
													TriggerServerEvent('abomb:endBomb', v.id)
													DeleteObject(v.id)
													if showingText == v.id then
														TriggerEvent('pw_drawtext:hideNotification')
														showingText = false
													end
													armedBombsT[k].timeLeft = 0
												else
													ClearPedTasks(ped)
													TriggerServerEvent('abomb:endBomb', v.id)
													TriggerEvent('abomb:boom', v.id, v.x, v.y, v.z)
													if showingText == v.id then
														showingText = false
														TriggerEvent('pw_drawtext:hideNotification')
													end
												end
											end)
										end
									end)
							end
						end
					else
						if not showingText or v.prevTime ~= v.timeLeft then
							showingText = v.id
							armedBombsT[k].prevTime = v.timeLeft
							TriggerEvent('pw_drawtext:showNotification', { title = "Bomb Status", message = "<b><span style='font-size:20px'>Timeleft: <span class='text-danger'>" .. v.timeLeft .. "</span> seconds</span></b>", icon = "fad fa-bomb" })
						end
					end
				else
					showingText = false
					TriggerEvent('pw_drawtext:hideNotification')
				end
			end
		end
	end
end)

RegisterNetEvent('abomb:boom')
AddEventHandler('abomb:boom', function (bomb, x, y, z)
	if hasPlanted == bomb then
		hasPlanted = 0
	end
	AddExplosion(x, y, z, 16, 200.0, true, false, true, false)
	DeleteObject(bomb)
end)

RegisterNetEvent('abomb:endOwner')
AddEventHandler('abomb:endOwner', function (bomb)
	if showingText == bomb then
		showingText = false
		TriggerEvent('pw_drawtext:hideNotification')
	end
	if hasPlanted == bomb then
		hasPlanted = 0
	end
	DeleteObject(bomb)
end)

RegisterNetEvent('abomb:beep')
AddEventHandler('abomb:beep', function(x, y, z)
	TriggerServerEvent("InteractSound_SV:PlayWithinDistanceCoords", x, y, z, 10, "beep", 0.5)
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end