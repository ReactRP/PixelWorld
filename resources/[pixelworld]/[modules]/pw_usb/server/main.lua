PW = nil
Screens, Door, System = {}, {}, {}
lockdownTimer, hackingTimer = 0, 0

TriggerEvent('pw:loadFramework', function(framework)
	PW = framework
end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
	MySQL.Async.fetchScalar("SELECT `settings` FROM `config` WHERE `resource` = 'usbhack'", {}, function(stuff)
		if stuff then
			local decodeSettings = json.decode(stuff)
			Screens = decodeSettings.screens
			Door = decodeSettings.door
			System = { ['inUse'] = false, ['disabled'] = false, ['currentActive'] = 1 }
		end
	end)
	
	CheckForPolice()
end)

function CheckForPolice()
	PW.SetTimeout(10000, function()
		if #PW.CheckOnlineDuty('police') >= Config.NeededPolice then
			if System.disabled and lockdownTimer == 0 and not System.inUse then
				TriggerEvent('pw_usb:server:updateSystem', 'disabled', false)
				TriggerEvent('pw_usb:server:updateSystem', 'inUse', false)
			end
		else
			if not System.disabled and not System.inUse then
				TriggerEvent('pw_usb:server:updateSystem', 'disabled', true)
			end
		end

		CheckForPolice()
	end)
end

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
	if data.item == 'tablet' then
		TriggerClientEvent('pw_usb:start', _src, data)
	end
end)

RegisterServerEvent('pw_usb:award')
AddEventHandler('pw_usb:award', function(data)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	local charEmail = _char.getEmail()
	local message = 'You proved your hacking skills. Here\'s a powerful tool.<br>Your tablet has been destroyed to clear evidences.'
	TriggerEvent('pw_phone:server:sendEmail', charEmail, 'USB Stick', message)

	_char:Inventory():Add().Default(1, 'usbhack', awardGoods, {}, {}, function(done) end)

	TriggerEvent('pw_usb:server:updateSystem', 'disabled', true)
	if hackingTimer > 0 then PW.ClearTimeout(hackingTimer); end
	PW.SetTimeout(30000, function()
		TriggerEvent('pw_usb:server:updateDoor', false)
		if lockdownTimer > 0 then PW.ClearTimeout(lockdownTimer); end
		StartLockdown()
	end)
end)

RegisterServerEvent('pw_usb:remove')
AddEventHandler('pw_usb:remove', function(data, failed)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)

	_char:Inventory():Remove().Default(data.record_id, 1, function(done) end)
	if failed then
		local charEmail = _char.getEmail()
		local message = 'You are not worthy of my time. Enjoy the virus on your tablet.'
		TriggerEvent('pw_phone:server:sendEmail', charEmail, 'N00B-HAX0R', message)
		
		TriggerEvent('pw_usb:server:updateSystem', 'disabled', true)
		if hackingTimer > 0 then PW.ClearTimeout(hackingTimer); end
		PW.SetTimeout(30000, function()
			TriggerEvent('pw_usb:server:updateDoor', false)
			if lockdownTimer > 0 then PW.ClearTimeout(lockdownTimer); end
			StartLockdown()
		end)
	end
end)

RegisterServerEvent('pw_usb:server:updateDoor')
AddEventHandler('pw_usb:server:updateDoor', function(state)
	Door.open = state
	TriggerClientEvent('pw_usb:client:updateDoor', -1, state)
end)

RegisterServerEvent('pw_usb:server:updateSystem')
AddEventHandler('pw_usb:server:updateSystem', function(key, value)
	System[key] = value
	TriggerClientEvent('pw_usb:client:updateSystem', -1, key, value)
	if key == 'inUse' and value == false then
		System.currentActive = 1
		TriggerClientEvent('pw_usb:client:updateSystem', -1, 'currentActive', 1)
		TriggerEvent('pw_usb:server:updateDoor', false)
	end
end)

RegisterServerEvent('pw_usb:server:startTimer')
AddEventHandler('pw_usb:server:startTimer', function()
	hackingTimer = PW.SetTimeout(Config.HackingTimer * 1000, function()
		TriggerEvent('pw_usb:server:updateSystem', 'disabled', true)
		StartLockdown()
	end)
end)

function StartLockdown()
	lockdownTimer = PW.SetTimeout(Config.SystemLockdown * 1000, function()
		TriggerEvent('pw_usb:server:updateSystem', 'disabled', false)
		TriggerEvent('pw_usb:server:updateSystem', 'inUse', false)
		TriggerEvent('pw_usb:server:updateDoor', false)
		lockdownTimer = 0
	end)
end

PW.RegisterServerCallback('pw_usb:server:getSettings', function(source, cb)
	cb(Screens, Door, System)
end)