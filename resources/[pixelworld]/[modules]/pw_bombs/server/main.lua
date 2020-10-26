PW = nil
local armedBombs = {}
local defaultBomb = 30

TriggerEvent('pw:loadFramework', function(framework)
	PW = framework
end)

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
	local _char = exports.pw_core:getCharacter(_src)
	if data.item == 'bomb' then
		_char:Inventory().getItemCount('bag', function(count)
			if count > 0 then
				TriggerClientEvent('abomb:assemble', _src, data)
			end
		end)
	elseif data.item == 'bombbag' then
		TriggerClientEvent('abomb:plant', _src, data)
	end
end)

RegisterServerEvent('abomb:givebomb')
AddEventHandler('abomb:givebomb', function(data)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	_char:Inventory().getItemCount('bag', function(bcount)
		_char:Inventory().getItemCount('bomb', function(bbcount)
			if bcount > 0 and bbcount > 0 then
				_char:Inventory():Remove().Default(data.record_id, 1, function(done) end)
				_char:Inventory():Remove().ByName('bag', 1)
				_char:Inventory():Add().Default(1, 'bombbag', 1, {}, {}, function(done) end)
			end
		end)
	end)
end)

RegisterServerEvent('abomb:bombplanted')
AddEventHandler('abomb:bombplanted', function (bomb, xx, yy, zz, data)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	_char:Inventory().getItemCount('bombbag', function(bcount)
		if bcount > 0 then
			_char:Inventory():Remove().Default(data.record_id, 1, function(done) end)
			table.insert(armedBombs, {id=bomb, x=xx, y=yy, z=zz, timeLeft=defaultBomb, countdownStatus = false, disarmStatus = false, prevTime = 0, planter = _src})
			startCountdown(bomb)
		end
	end)
end)

RegisterServerEvent('abomb:endBomb')
AddEventHandler('abomb:endBomb', function (bomb)
	local src = source
	local bombToEnd = bomb
	for k,v in pairs(armedBombs) do
		if v.id == bombToEnd then
			v.countdownStatus = false
			armedBombs[k] = nil
			break
		end
	end
	TriggerClientEvent('abomb:endOwner', -1, bomb)
end)

RegisterServerEvent('abomb:defusing')
AddEventHandler('abomb:defusing', function (bomb, status)
	local src = source
	local bombToEnd = bomb
	for k,v in pairs(armedBombs) do
		if v.id == bombToEnd then
			v.disarmStatus = status
			break
		end
	end
end)

function startCountdown(bomb)
	for k, v in pairs(armedBombs) do
		if v.id == bomb then
			v.countdownStatus = true
			bombId = k
			break
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(armedBombs) do
			if v.countdownStatus then
				if v.timeLeft >= 0 then 
					if v.timeLeft == 0 then
						TriggerEvent('abomb:endBomb', v.id)
						TriggerClientEvent('abomb:boom', -1, v.id, v.x, v.y, v.z)
						TriggerClientEvent('abomb:closeUi', -1)
						TriggerClientEvent('pw_bankrobbery:client:checkIfExplosionInRadius', -1, v.x, v.y, v.z, v.planter)
					else
						TriggerClientEvent('abomb:beep', -1, v.x, v.y, v.z)
						v.timeLeft = v.timeLeft - 1
						TriggerClientEvent('abomb:updateUi', -1, v.timeLeft)
					end
				end
			end
		end
	end
end)

PW.RegisterServerCallback('abomb:getTime', function(source, cb, bomb)
	for k, v in pairs(armedBombs) do
		if v.id == bomb then
			cb(v.timeLeft)
			break
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		TriggerClientEvent('abomb:updateBombs', -1, armedBombs)
	end
end)


