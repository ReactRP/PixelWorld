RegisterNetEvent('pw_coke:SyncPlant')
RegisterNetEvent('pw_coke:RemovePlant')

local MFD = MF_CokePlant

PW = nil

TriggerEvent('pw:loadFramework', function(framework) PW = framework end)

function MFD:Awake(...)
	while not PW do Citizen.Wait(0); end

	self:DSP(true);
	self.dS = true
	self:Start()
end

function MFD:DoLogin(src)
    self:DSP(true)
end

function MFD:DSP(val) self.cS = val; end
function MFD:Start(...) self:Update(); end

function MFD:Update(...) end

function MFD:SyncPlant(plant, delete)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)

	local identifier = _char.getCID()
	plant["Owner"] = identifier
	if delete then
		local pJob = _char:Job().getJob()
		if pJob.name ~= self.PoliceJobLabel or (pJob.name == self.PoliceJobLabel and not pJob.duty) then
			self:RewardPlayer(_src, plant)
		end
	end
	self:PlantCheck(identifier, plant, delete)
	TriggerClientEvent('pw_coke:SyncPlant', -1, plant, delete)
end

function MFD:RewardPlayer(source, plant)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	local items = {}
	if not _src or not plant then return; end
	local qty = 0
	if plant.Gender == "Male" then
		if plant.Quality > 95 then
			qty = math.floor(math.random(math.floor(plant.Quality / 2),
											math.floor(plant.Quality * 1.5)) /
									10)
			if qty > 0 then
				table.insert(items,
								{['name'] = "hgmcokeseed", ['qty'] = qty})
			end
		elseif plant.Quality > 80 then
			qty = math.floor(math.random(math.floor(plant.Quality / 2),
											math.floor(plant.Quality * 1.5)) /
									20)
			if qty > 0 then
				table.insert(items,
								{['name'] = "hgmcokeseed", ['qty'] = qty})
			end
		else
			qty = math.floor(math.random(math.floor(plant.Quality / 2),
											math.floor(plant.Quality)) / 20)
			if qty > 0 then
				table.insert(items,
								{['name'] = "lgmcokeseed", ['qty'] = qty})
			end
		end
		math.random();
		math.random();
		math.random();
		local r = math.random(1000, 5000)
		if r > 2999 then
			qty = math.floor(math.random(math.floor(plant.Quality / 2),
											math.floor(plant.Quality)) / 20)
			if qty > 0 then
				table.insert(items,
								{['name'] = "lgfcokeseed", ['qty'] = qty})
			end
		end
	else
		if plant and plant.Quality and plant.Quality > 80 then
			qty = math.floor(math.random(math.floor(plant.Quality),
											math.floor(plant.Quality * 2)))
			if qty > 0 then
				table.insert(items, {['name'] = "cocaleaves", ['qty'] = qty})
			end
		elseif plant.Quality then
			qty = math.floor(math.random(math.floor(plant.Quality / 2),
											math.floor(plant.Quality)))
			if qty > 0 then
				table.insert(items, {['name'] = "cocaleaves", ['qty'] = qty})
			end
		end
	end
	for k, v in pairs(items) do
		_char:Inventory():Add().Default(1, v.name, v.qty, {}, {}, function(item) end)
	end
end

function MFD:PlantCheck(identifier, plant, delete)
	if not plant or not identifier then return; end
	local data = MySQL.Sync.fetchAll(
						'SELECT * FROM cokeplants WHERE plantid=@plantid',
						{['@plantid'] = plant.PlantID})
	if not delete then
		if not data or not data[1] then
			MySQL.Async.execute(
				'INSERT INTO cokeplants (owner, plantid, plant) VALUES (@owner, @id, @plant)',
				{
					['@owner'] = identifier,
					['@id'] = plant.PlantID,
					['@plant'] = json.encode(plant)
				})
		else
			MySQL.Sync.execute(
				'UPDATE cokeplants SET plant=@plant WHERE plantid=@plantid',
				{
					['@plant'] = json.encode(plant),
					['@plantid'] = plant.PlantID
				})
		end
	else
		if data and data[1] then
			MySQL.Async.execute(
				'DELETE FROM cokeplants WHERE plantid=@plantid',
				{['@plantid'] = plant.PlantID})
		end
	end
end

function MFD:GetLoginData(source)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	local data = MySQL.Sync.fetchAll(
						'SELECT * FROM cokeplants WHERE owner=@owner',
						{['@owner'] = _char.getCID()})
	if not data or not data[1] then return false; end
	local aTab = {}
	for k = 1, #data, 1 do
		local v = data[k]
		if v and v.plant then
			local data = json.decode(v.plant)
			table.insert(aTab, data)
		end
	end
	return aTab
end

function MFD:ItemTemplate()
	return {["Type"] = "Water", ["Quality"] = 0.0}
end

function MFD:PlantTemplate()
	return {
		["Gender"] = "Female",
		["Quality"] = 0.0,
		["Growth"] = 0.0,
		["Water"] = 20.0,
		["Food"] = 20.0,
		["Stage"] = 1,
		["PlantID"] = math.random(math.random(999999, 9999999),
									math.random(99999999, 999999999))
	}
end

RegisterServerEvent('pw_coke:GiveThisShit')
AddEventHandler('pw_coke:GiveThisShit', function(data)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	_char:Inventory():Add().Default(1, data.item, 1, {}, {}, function(item) end)
end)

RegisterServerEvent('pw_coke:GiveThisShits')
AddEventHandler('pw_coke:GiveThisShits', function(items)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)

	for k, v in pairs(items) do
		_char:Inventory():Add().Default(1, v.name, v.qty, {}, {}, function(item) end)
	end
end)

RegisterServerEvent('pw_coke:RemoveThisShit')
AddEventHandler('pw_coke:RemoveThisShit', function(items)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)

	for k, v in pairs(items) do
		_char:Inventory():Remove().ByName(v.name, v.qty)
	end
end)

RegisterServerEvent('pw_coke:RemoveThisSpecificShit')
AddEventHandler('pw_coke:RemoveThisSpecificShit', function(data)
	local _src = source
	local _char = exports.pw_core:getCharacter(_src)
	_char:Inventory():Remove().Default(data.record_id, 1)
end)

PW.RegisterServerCallback('pw_coke:GetLoginData', function(source, cb)
    cb(MFD:GetLoginData(source))
end)

PW.RegisterServerCallback('pw_coke:GetStartData', function(source, cb)
	while not MFD.dS do Citizen.Wait(0); end
	cb(MFD.cS);
end)

AddEventHandler('pw_coke:SyncPlant', function(plant, delete)
	MFD:SyncPlant(plant, delete);
end)

AddEventHandler('playerConnected', function(...)
	MFD:DoLogin(source);
end)

Citizen.CreateThread(function(...)
    MFD:Awake(...)
end)
