PW = nil

TriggerEvent('pw:loadFramework', function(framework)
	PW = framework
end)

licenses = {}
vehquestions = {}
MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM `licenses`", {}, function(results)
        if results and results[1] ~= nil then
            licenses = results
        end
	end)
	MySQL.Async.fetchScalar("SELECT `settings` FROM `config` WHERE `resource` = 'licensetheory'", {}, function(results)
		if results ~= nil then
			vehquestions = json.decode(results)
		end
	end)
end)


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

function DoesLicenseExist(type)
	local found = false
	for i = 1, #licenses do
		if licenses[i].type == type then
			found = true
		end	
	end	
	return found
end

function GetLicenseLabel(type)
	if DoesLicenseExist(type) then
		local label
		for i = 1, #licenses do
			if licenses[i].type == type then
				return licenses[i].label
			end	
		end	
	end	
end

function DoesCIDExist(cid)
	local valid = MySQL.Sync.fetchScalar("SELECT `cid` FROM `characters` WHERE `cid` = @cid", {['@cid'] = cid})
	print(valid)
	if valid ~= nil then
		return true
	else
		return false
	end	
end

function DoesPlayerHaveLicense(cid, type)
	if DoesLicenseExist(type) and cid ~= nil and DoesCIDExist(cid) then
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
		else
			return false
		end
	else
		return false
	end			
end

function AddLicenseToCharacter(cid, type)
	if DoesLicenseExist(type) and cid ~= nil and DoesCIDExist(cid) and not DoesPlayerHaveLicense(cid, type) then
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
	if DoesLicenseExist(type) and cid ~= nil and DoesCIDExist(cid) and DoesPlayerHaveLicense(cid, type) then
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

PW.RegisterServerCallback('pw_license:server:getLicensesList', function(source, cb)
	cb(licenses)
end)

PW.RegisterServerCallback('pw_license:server:getPlayerLicenses', function(source, cb)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	local licenses = GetPlayerLicenses(_cid)
	print(licenses)
	cb(licenses)
end)

PW.RegisterServerCallback('pw_license:server:doesPlayerHaveLicense', function(source, cb, license)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	local hasLicense = DoesPlayerHaveLicense(_cid, license)
	print(hasLicense)
	cb(hasLicense)
end)

exports('DoesPlayerHaveLicense', DoesPlayerHaveLicense)
exports('AddLicenseToCharacter', AddLicenseToCharacter)
exports('GetPlayerLicenses', GetPlayerLicenses)
exports('GetLicenseLabel', GetLicenseLabel)
exports('AddLicenseToCharacter', AddLicenseToCharacter)
exports('RemoveLicenseFromCharacter', RemoveLicenseFromCharacter)


exports['pw_chat']:AddAdminChatCommand('addlicense', function(source, args, rawCommand)
	local _src = source
	local targetSource = tonumber(args[1])
	if targetSource ~= nil then
		local _targetChar = exports['pw_core']:getCharacter(targetSource)
		if _targetChar then
			local _targetcid = _targetChar.getCID()
			local isAdded = AddLicenseToCharacter(_targetcid, args[2])
			if isAdded then
				PW.doAdminLog(_src, "Added License to Player", {['license'] = args[2], ['target'] = _targetcid}, true)
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'Successfully Added License to Player<br>License Type: ' .. args[2] .. '<br>Added to ID: ' .. targetSource, length = 5000 })
			else
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Failed to Add License to ID: '.. targetSource, length = 3000 })
			end
		end
	end
end, {
    help = "Add a License to Player",
    params = {
		{
        name = "ServerID",
        help = "ID of the Player"
		},
		{
			name = "License Type",
			help = "Type of License (e.g CAR or CDL)"
		},
	}
}, -1)

exports['pw_chat']:AddAdminChatCommand('removelicense', function(source, args, rawCommand)
	local _src = source
	local targetSource = tonumber(args[1])
	if targetSource ~= nil then
		local _targetChar = exports['pw_core']:getCharacter(targetSource)
		if _targetChar then
			local _targetcid = _targetChar.getCID()
			local isRemoved = RemoveLicenseFromCharacter(_targetcid, args[2])
			if isRemoved then
				PW.doAdminLog(_src, "Removed License From Player", {['license'] = args[2], ['target'] = _targetcid}, true)
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'Successfully Removed License From Player<br>License Type: ' .. args[2] .. '<br>Removed From ID: ' .. targetSource, length = 5000 })
			else
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'Failed to Remove License from ID: '.. targetSource, length = 3000 })
			end
		end
	end
end, {
    help = "Remove a License from a Player",
    params = {
		{
        name = "Server ID",
        help = "ID of the Player"
		},
		{
			name = "License Type",
			help = "Type of License (e.g CAR or CDL)"
		},
	}
}, -1)


PW.RegisterServerCallback('pw_license:server:getTheoryQuestions', function(source, cb)
	cb(vehquestions)
end)

RegisterNetEvent('pw_license:server:payRoadVehicleTest')
AddEventHandler('pw_license:server:payRoadVehicleTest', function(data)
    local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local cost = Config.TestCost[data.testtype.value]
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
AddEventHandler('pw_license:server:completeRoadVehicleTest', function(type)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	if type == 'CAR' then
		if AddLicenseToCharacter(_cid, 'CAR') then
			TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Congratulations - You Passed the Driving Test and Recieved Your Car License!", length = 8000})  
		end
	elseif type == 'CDL' then
		if AddLicenseToCharacter(_cid, 'CDL') then
			TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Congratulations - You Passed the CDL Test and Recieved the License!", length = 8000}) 
		end 	
	end
end)

RegisterNetEvent('pw_license:server:confirmWeaponCert')
AddEventHandler('pw_license:server:confirmWeaponCert', function(data)
    local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local cost = Config.TestCost['FIREARM']
	if cost ~= nil then
		local _balance = _char:Cash().getBalance()
		if _balance >= cost then
			_char:Cash().removeCash(cost)
			TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "Paid the $" .. cost .. " Firearms Licensing Fee.", length = 5000}) 
			TriggerClientEvent('pw_license:client:sendWeaponCertResults', _src, data)
		else
			TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You can\'t afford a firearms, please try again when you have the correct amount of cash!", length = 10000}) 
		end 	
	else
		TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "There was an error processing your license, try submitting it again.", length = 2500})  
	end		
end)

PW.RegisterServerCallback('pw_license:server:doesCharacterHaveWeaponCertApproval', function(source, cb)
	local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	local weaponTheoryStatus = MySQL.Sync.fetchScalar("SELECT `weaponCert` FROM `characters` WHERE `cid` = @cid", {['@cid'] = _cid})
	cb(weaponTheoryStatus)
end)

RegisterNetEvent('pw_license:server:completedWeaponTheoryTestSuccess')
AddEventHandler('pw_license:server:completedWeaponTheoryTestSuccess', function(AmountCorrect)
    local _src = source
	local _char = exports['pw_core']:getCharacter(_src)
	local _cid = _char.getCID()
	if AmountCorrect > 7 then
		MySQL.Async.execute("UPDATE `characters` SET `weaponCert` = @weaponCert WHERE `cid` = @cid", {['@weaponCert'] = 1, ['@cid'] = _cid}, function(updated)
			if updated > 0 then
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'You Got ' .. AmountCorrect .. ' out of 10 and Now Have a Firearms Certification - To Get a Complete Firearms License, You will need to contact a Judge and Apply for One.', length = 10000 })
			else
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'There was an error and you didn\'t recieve the certifications.', length = 2500 })
			end
		end)
	end
end)

exports.pw_chat:AddChatCommand('givefirearmslicense', function(source, args, rawCommand)
	local _src = source
	local targetCID = tonumber(args[1])
	if DoesCIDExist(targetCID) then
		local weaponTheoryStatus = MySQL.Sync.fetchScalar("SELECT `weaponCert` FROM `characters` WHERE `cid` = @cid", {['@cid'] = targetCID})
		if weaponTheoryStatus then
			if AddLicenseToCharacter(targetCID, 'FIREARM') then
				TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'Added Firearms License to CID: ' .. targetCID, length = 2500 })
			end
		else
			TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'That Person Doesn\'t Have a Firearm Certification', length = 2500 })
		end
	else
		TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'That CID doesn\'t Exist', length = 2500 })
	end
end, {
	help = 'Give Someone a Firearms License - They Must Have a Certification',
	params = {
		{
			name = 'CID',
			help = 'The Persons CID',
		},
	}
}, -1, { 'judge' })

exports.pw_chat:AddChatCommand('revokelicense', function(source, args, rawCommand)
	local _src = source
	local targetCID = tonumber(args[1])
	if DoesCIDExist(targetCID) and DoesLicenseExist(args[2]) then
		if RemoveLicenseFromCharacter(targetCID, args[2]) then
			TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'success', text = 'Successfully Revoked a License', length = 2500 })
		end
	else
		TriggerClientEvent('pw:notification:SendAlert', _src, { type = 'error', text = 'That CID doesn\'t Exist or License Doesn\'t Exist', length = 3500 })
	end
end, {
	help = 'Revoke a License From Someone',
	params = {
		{
			name = 'CID',
			help = 'The Persons CID',
		},
		{
			name = 'License',
			help = 'E.G FIREARM, CAR, CDL',
		},
	}
}, -1, { 'judge', 'police' })


--[[

Answers
---------------------------------------------------
	WEAPONS
---------------------------------------------------
	1)   A
	2)   D
	3)   D
	4)   C
	5)   A
	6)   B
	7)   A
	8)   D
	9)   A
	10)  A
--------------------------------------------------
	CAR
--------------------------------------------------
	1)  B
	2)  B
	3)  C
	4)  A
	5)  C
	6)  B
	7)  C
	8)  A
	9)  C
	10) B
--------------------------------------------------
	CDL
--------------------------------------------------
	1)  B
	2)  B
	3)  D
	4)  C
	5)  C
	6)  B
	7)  A
	8)  B
	9)  D
	10) C
-------------------------------------------------
]]