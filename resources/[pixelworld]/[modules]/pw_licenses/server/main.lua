PW = nil

TriggerEvent('pw:loadFramework', function(framework)
	PW = framework
end)

-- Questions

local vehquestions = {}
MySQL.ready(function()
	MySQL.Async.fetchScalar("SELECT `settings` FROM `config` WHERE `resource` = 'licensetheory'", {}, function(results)
		if results ~= nil then
			vehquestions = json.decode(results)
		end
	end)
end)

PW.RegisterServerCallback('pw_license:server:getTheoryQuestions', function(source, cb)
	cb(vehquestions)
end)

-- License Core Functions

function GetPlayerLicenses(cid)
	if cid ~= nil then
		local _ownedlicenses = MySQL.Sync.fetchScalar("SELECT `licenses` FROM `characters` WHERE `cid` = @cid", {['@cid'] = cid})
		if _ownedlicenses ~= nil then
			local ownedlicenses = json.decode(_ownedlicenses)
			return ownedlicenses
		end
	end	
	return false	
end

function DoesCIDExist(cid)
	local valid = MySQL.Sync.fetchScalar("SELECT `cid` FROM `characters` WHERE `cid` = @cid", {['@cid'] = cid})
	if valid ~= nil then
		return true
	else
		return false
	end	
end

function DoesPlayerHaveLicense(cid, type)
	if cid ~= nil and DoesCIDExist(cid) then
		local doeshave = false
		local _ownedlicenses = MySQL.Sync.fetchScalar("SELECT `licenses` FROM `characters` WHERE `cid` = @cid", {['@cid'] = cid})
		if _ownedlicenses ~= nil then
			local ownedlicenses = json.decode(_ownedlicenses)
			for i = 1, #ownedlicenses do
				if ownedlicenses[i] == type then
					doeshave = true
				end
			end
			return doeshave
		end
	end	
	return false		
end

function AddLicenseToCharacter(cid, type)
	if cid ~= nil and not DoesPlayerHaveLicense(cid, type) then
		local charLicenses = GetPlayerLicenses(cid)
		local processed = false
		local success = false
		if charLicenses then
			table.insert(charLicenses, type)
			MySQL.Async.execute("UPDATE `characters` SET `licenses` = @licenses WHERE `cid` = @cid", {['@licenses'] = json.encode(charLicenses), ['@cid'] = cid}, function(updated)
				if updated > 0 then
					success = true
				end
				processed = true
			end)
		else
			local charLicenses = {}
			table.insert(charLicenses, type)
			MySQL.Async.execute("UPDATE `characters` SET `licenses` = @licenses WHERE `cid` = @cid", {['@licenses'] = json.encode(charLicenses), ['@cid'] = cid}, function(updated)
				if updated > 0 then
					success = true
				end
				processed = true
			end)
		end
		repeat Wait(0) until processed == true	
		return success
	else
		return false
	end	
end

function RemoveLicenseFromCharacter(cid, type)
	if cid ~= nil and DoesPlayerHaveLicense(cid, type) then
		local charLicenses = GetPlayerLicenses(cid)
		local processed = false
		local success = false
		if charLicenses then
			for i = 1, #charLicenses do
				if charLicenses[i] == type then
					table.remove(charLicenses, i)
					MySQL.Async.execute("UPDATE `characters` SET `licenses` = @licenses WHERE `cid` = @cid", {['@licenses'] = json.encode(charLicenses), ['@cid'] = cid}, function(updated)
						if updated > 0 then
							success = true
						end
						processed = true
					end)
				end
			end
		end
		repeat Wait(0) until processed == true	
		return success
	else
		return false
	end
end

PW.RegisterServerCallback('pw_licenses:server:doesPlayerHaveDrivingLicense', function(source, cb)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	local hasDrivingLicense = DoesPlayerHaveLicense(_cid, 'VEHICLE')
	cb(hasDrivingLicense)
end)

exports('doesCharHaveDrivingLicense', function(cid)
    return DoesPlayerHaveLicense(cid, 'VEHICLE')
end)

PW.RegisterServerCallback('pw_license:server:isPlayerElegibleForVehicleLicense', function(source, cb)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	local vehicleLicense = DoesPlayerHaveLicense(_cid, 'VEHICLE')
	local licensePoints = MySQL.Sync.fetchScalar("SELECT `licensePoints` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
	print('License Points', licensePoints)
	if not vehicleLicense and licensePoints < 15 then
		cb(true, licensePoints)
	else
		cb(false, licensePoints)
	end
end)

RegisterNetEvent('pw_license:server:payRoadVehicleTest')
AddEventHandler('pw_license:server:payRoadVehicleTest', function(data)
    local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local cost = Config.TestCost
	if cost ~= nil then
		local _balance = _char:Cash().getBalance()
		if _balance >= cost then
			_char:Cash().removeCash(cost)
			TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Paid the $" .. cost .. " Licensing Fee.", length = 5000}) 
			TriggerClientEvent('pw_license:client:vehtestresults', _src, data)
		else
			TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You can\'t afford this license, please try again when you have the correct amount of cash!", length = 10000}) 
		end 	
	else
		TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "There was an error with your license, please try again.", length = 7000})  
	end		
end)

RegisterNetEvent('pw_license:server:completeRoadVehicleTest')
AddEventHandler('pw_license:server:completeRoadVehicleTest', function()
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	if AddLicenseToCharacter(_cid, 'VEHICLE') then
		TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Congratulations - You Passed the Driving Test and Recieved Your Vehicle License!", length = 8000})  
	end
end)

RegisterNetEvent('pw_licenses:server:checkOwnLicenses')
AddEventHandler('pw_licenses:server:checkOwnLicenses', function()
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _charCID = _char.getCID()
	local targetLicenses = GetPlayerLicenses(_charCID)
	local licensePoints = MySQL.Sync.fetchScalar("SELECT `licensePoints` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _charCID})
	local menu, licenses, vehicleLicense = {}, false, false
	for k,v in pairs(targetLicenses) do
		if v == 'VEHICLE' then
			table.insert(menu, { ['label'] = Config.LicenseLabels[v] .. ' <i>( '.. licensePoints .. (licensePoints == 1 and ' Point ' or ' Points ') .. ')</i>', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'primary disabled' })
			licenses, vehicleLicense = true, true
		else
			licenses = true
			table.insert(menu, { ['label'] = Config.LicenseLabels[v], ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'primary disabled' })
		end
	end
	if not licenses then
		table.insert(menu, { ['label'] = 'No Valid Licences', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'danger disabled' })
	end
	if not vehicleLicense and licensePoints > 0 then
		table.insert(menu, { ['label'] =  'Revoked Vehicle License' .. ' <i>( '.. licensePoints .. (licensePoints == 1 and ' Point ' or ' Points ') .. ')</i>', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'danger disabled' })
	end
	TriggerClientEvent('pw_interact:generateMenu', _src, menu, "Your Licenses")
end)	

-- ADDING AND REMOVING LICENSE POINTS 
function AddLicensePoints(cid, points)
	local processed, returnVal = false, false
	local curLicensePoints = MySQL.Sync.fetchScalar("SELECT `licensePoints` FROM `characters` WHERE `cid` = @cid", {['@cid'] = cid})
	local licensePoints = curLicensePoints + points
	if licensePoints > 15 then
		licensePoints = 15 
	end
	MySQL.Async.execute("UPDATE `characters` SET `licensePoints` = @licensePoints WHERE `cid` = @cid", {['@licensePoints'] = licensePoints, ['@cid'] = cid}, function(updated)
		if updated > 0 then
			if licensePoints == 15 then
				RemoveLicenseFromCharacter(cid, 'VEHICLE')
			end
			returnVal = licensePoints
		else
			returnVal = false
		end
		processed = true
	end)
	repeat Wait(0) until processed == true	
	return returnVal
end

function RemoveLicensePoints(cid, points)
	local processed, returnVal = false, false
	local curLicensePoints = MySQL.Sync.fetchScalar("SELECT `licensePoints` FROM `characters` WHERE `cid` = @cid", {['@cid'] = cid})
	local licensePoints = curLicensePoints - points
	if licensePoints < 0 then 
		licensePoints = 0
	end
	MySQL.Async.execute("UPDATE `characters` SET `licensePoints` = @licensePoints WHERE `cid` = @cid", {['@licensePoints'] = licensePoints, ['@cid'] = cid}, function(updated)
		if updated > 0 then
			returnVal = licensePoints
		else
			returnVal = false
		end
		processed = true
	end)
	repeat Wait(0) until processed == true	
	return returnVal
end

function getCIDFromTarget(targetID) -- Get CID From Server ID or CID
	if targetID ~= nil then
		if targetID > 100000 then
			targetCID = target
		else
			local targetChar = exports['pw_core']:getCharacter(targetID)
			if targetChar ~= nil then
				targetCID = targetChar.getCID()
			else
				targetCID = nil
			end
		end
		if targetCID ~= nil and DoesCIDExist(targetCID) then
			return targetCID
		end
	end
	return nil
end

-- FIREARMS LICENSES
exports.pw_chat:AddChatCommand('grantarmslicense', function(source, args, rawCommand)
	local _src = source
	local target = tonumber(args[1])
	local targetCID = getCIDFromTarget(target)
	if targetCID ~= nil then
		if AddLicenseToCharacter(targetCID, 'FIREARM') then
			local isOnline = exports['pw_core']:checkOnline(targetCID)
			local targetName = exports['pw_core']:getOffline(targetCID).getFullName()
			TriggerEvent('pw:chat:server:Server', _src, 'Successfully granted firearms license to ' .. targetName .. ' (CID: ' .. targetCID .. ').')
			if isOnline then
				TriggerEvent('pw:chat:server:Server', _src, 'A Firearms License Was Granted to You')
			end
		end
	else
		TriggerEvent('pw:chat:server:Server', _src, 'Invalid CID')
	end
end, {
	help = 'Grant Someone a Firearms License',
	params = {
		{
			name = 'CID/PayPal ID',
			help = 'The Persons CID or Paypal ID',
		},
	}
}, -1, { 'judge' })

exports.pw_chat:AddChatCommand('revokearmslicense', function(source, args, rawCommand)
	local _src = source
	local target = tonumber(args[1])
	local targetCID = getCIDFromTarget(target)
	if targetCID ~= nil then
		if RemoveLicenseFromCharacter(targetCID, 'FIREARM') then
			local isOnline = exports['pw_core']:checkOnline(targetCID)
			local targetName = exports['pw_core']:getOffline(targetCID).getFullName()
			TriggerEvent('pw:chat:server:Server', _src, 'Successfully revoked a firearms license from ' .. targetName .. '( CID: ' .. targetCID .. ' ).')
			if isOnline then
				TriggerEvent('pw:chat:server:Server', _src, 'Your Firearms License Was Revoked.')
			end
		end
	else
		TriggerEvent('pw:chat:server:Server', _src, 'Invalid CID')
	end

end, {
	help = 'Revoke a Firearms License From Someone',
	params = {
		{
			name = 'CID/Server ID',
			help = 'The Persons CID or Server ID',
		},
	}
}, -1, { 'judge', 'police' })

exports.pw_chat:AddChatCommand('addlicensepoints', function(source, args, rawCommand)
	local _src = source
	local target = tonumber(args[1])
	local addPoints = tonumber(args[2])
	local targetCID = getCIDFromTarget(target)
	if targetCID ~= nil and addPoints ~= nil then
		local isOnline = exports['pw_core']:checkOnline(targetCID)
		local targetName = exports['pw_core']:getOffline(targetCID).getFullName()
		local success = AddLicensePoints(targetCID, addPoints)
		print(success)
		if success then
			TriggerEvent('pw:chat:server:Server', _src, 'Added ' .. addPoints .. ' license points to ' .. targetName .. ' ( CID: ' .. targetCID .. ').' .. (success == 15 and ' Their license was revoked for reaching 15 points' or ' The total is now '.. success))
			if isOnline then
				TriggerEvent('pw:chat:server:Server', _src, addPoints .. ' points were added to your license.'.. (success == 15 and ' Your license was revoked for it reaching 15 points' or ' The total is now '.. success))
			end
		end
	else
		TriggerEvent('pw:chat:server:Server', _src, 'Invalid CID')
	end
end, {
	help = 'Add Vehicle License Points to a Player',
	params = {
		{
			name = 'CID/Server ID',
			help = 'The Persons CID or Server ID',
		},
		{
			name = 'Points',
			help = 'Amount of Points to Add',
		}
	}
}, -1, { 'judge', 'police' })

exports.pw_chat:AddChatCommand('removelicensepoints', function(source, args, rawCommand)
	local _src = source
	local target = tonumber(args[1])
	local removePoints = tonumber(args[2])
	local targetCID = getCIDFromTarget(target)
	if targetCID ~= nil and removePoints ~= nil then
		local success = RemoveLicensePoints(targetCID, removePoints)
		local online = exports['pw_core']:checkOnline(targetCID)
		local targetName = exports['pw_core']:getOffline(targetCID).getFullName()
		if success then 
			TriggerEvent('pw:chat:server:Server', _src, 'Removed ' .. removePoints .. 'license points from ' .. targetName .. '( CID: '.. targetCID ..' ) - the total is now '.. success .. ' points.')
			if online then
				TriggerEvent('pw:chat:server:Server', _src, removePoints .. ' points were removed from your license. The total is now '.. success .. ' points.')
			end
		end
	else
		TriggerEvent('pw:chat:server:Server', _src, 'Invalid CID')
	end
end, {
	help = 'Remove Vehicle License Points from a Player',
	params = {
		{
			name = 'CID/Server ID',
			help = 'The Persons CID or Server ID',
		},
		{
			name = 'Points',
			help = 'The Amount of Points to Remove',
		}
	}
}, -1, { 'judge', 'police' })

exports.pw_chat:AddChatCommand('licenses', function(source, args, rawCommand)
	local _src = source
	local target = tonumber(args[1])
	local targetCID = getCIDFromTarget(target)
	if targetCID ~= nil then
		local targetName = exports['pw_core']:getOffline(targetCID).getFullName()
		local targetLicenses = GetPlayerLicenses(targetCID)
		local licensePoints = MySQL.Sync.fetchScalar("SELECT `licensePoints` FROM `characters` WHERE `cid` = @cid", {['@cid'] = targetCID})
		local menu, licenses, vehicleLicense = {}, false, false
		for k,v in pairs(targetLicenses) do
			if v == 'VEHICLE' then
				table.insert(menu, { ['label'] = Config.LicenseLabels[v] .. ' <i>( '.. licensePoints .. (licensePoints == 1 and ' Point ' or ' Points ') .. ')</i>', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'primary disabled' })
				licenses, vehicleLicense = true, true
			else
				licenses = true
				table.insert(menu, { ['label'] = Config.LicenseLabels[v], ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'primary disabled' })
			end
		end
		if not licenses then
			table.insert(menu, { ['label'] = 'No Valid Licences', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'danger disabled' })
		end
		if not vehicleLicense and licensePoints > 0 then
			table.insert(menu, { ['label'] =  'Revoked Vehicle License' .. ' <i>( '.. licensePoints .. (licensePoints == 1 and ' Point ' or ' Points ') .. ')</i>', ['action'] = '', ['value'] = {}, ['triggertype'] = 'client', ['color'] = 'danger disabled' })
		end
		TriggerClientEvent('pw_interact:generateMenu', _src, menu, "<strong>" .. targetName .. "</strong> Licenses" .. " (CID: " .. targetCID .. ") ")
	else
		TriggerEvent('pw:chat:server:Server', _src, 'Invalid CID or ID')
	end
end, {
	help = 'View All License Information of a Person',
	params = {
		{
			name = 'CID/Server ID',
			help = 'The Persons CID or Server ID',
		},
	}
}, -1, { 'judge', 'police' })

exports.pw_chat:AddAdminChatCommand('addlicense', function(source, args, rawCommand)
	local _src = source
	local target = tonumber(args[1])
	local license = args[2]
	if (target ~= nil and license ~= nil) and (license == 'FIREARM' or license == 'VEHICLE') then
		local targetChar = exports['pw_core']:getCharacter(target)
		if targetChar ~= nil then
			local name = targetChar.getFullName()
			local cid = targetChar.getCID()
			if AddLicenseToCharacter(cid, license) then
				TriggerEvent('pw:chat:server:Server', _src, 'Force Added License: '.. license .. ' to '.. name .. ' (CID: '.. cid .. ')')
			end
		else
			TriggerEvent('pw:chat:server:Server', _src, 'Error adding license')
		end
	else
		TriggerEvent('pw:chat:server:Server', _src, 'Error, Make sure that the license type is valid')
	end
end, {
	help = '[ADMIN] - Force Add a License to Someone',
	params = {
		{
			name = 'Server ID',
			help = 'The Server ID of the Player',
		},
		{
			name = 'License',
			help = 'The Type of License to Add, FIREARM or VEHICLE',
		}
	}
}, -1)
