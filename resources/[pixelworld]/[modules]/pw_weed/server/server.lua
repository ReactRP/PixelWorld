RegisterNetEvent('pw_weed:SyncPlant')
RegisterNetEvent('pw_weed:RemovePlant')

local MFD = MF_DopePlant

PW = nil

TriggerEvent('pw:loadFramework', function(framework) PW = framework end)

function MFD:Awake(...)
    while not PW do Citizen.Wait(0); end

    self:DSP(true);
    self.dS = true
    self:Start()
end

function MFD:DoLogin(src) self:DSP(true); end

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
        if pJob.name ~= self.PoliceJobLabel or
            (pJob.name == self.PoliceJobLabel and
                not pJob.duty) then
            self:RewardPlayer(_src, plant)
        end
    end
    self:PlantCheck(identifier, plant, delete)
    TriggerClientEvent('pw_weed:SyncPlant', -1, plant, delete)
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
                                         math.floor(plant.Quality * 1.5)) / 10)
            if qty > 0 then
                table.insert(items, {['name'] = "hgmseed", ['qty'] = qty})
            end
        elseif plant.Quality > 80 then
            qty = math.floor(math.random(math.floor(plant.Quality / 2),
                                         math.floor(plant.Quality * 1.5)) / 20)
            if qty > 0 then
                table.insert(items, {['name'] = "hgmseed", ['qty'] = qty})
            end
        else
            qty = math.floor(math.random(math.floor(plant.Quality / 2),
                                         math.floor(plant.Quality)) / 20)
            if qty > 0 then
                table.insert(items, {['name'] = "lgmseed", ['qty'] = qty})
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
                table.insert(items, {['name'] = "lgfseed", ['qty'] = qty})
            end
        end
    else
        if plant and plant.Quality and plant.Quality > 80 then
            qty = math.floor(math.random(math.floor(plant.Quality),
                                         math.floor(plant.Quality * 2)))
            if qty > 0 then
                table.insert(items, {['name'] = "trimmedweed", ['qty'] = qty})
            end
        elseif plant.Quality then
            qty = math.floor(math.random(math.floor(plant.Quality / 2),
                                         math.floor(plant.Quality)))
            if qty > 0 then
                table.insert(items, {['name'] = "trimmedweed", ['qty'] = qty})
            end
        end
    end
	for k, v in pairs(items) do
		char:Inventory():Add().Default(1, v.name, v.qty, {}, {}, function(item) end)
    end
end

function MFD:PlantCheck(identifier, plant, delete)
    if not plant or not identifier then return; end
    local data = MySQL.Sync.fetchAll(
                     'SELECT * FROM dopeplants WHERE plantid=@plantid',
                     {['@plantid'] = plant.PlantID})
    if not delete then
        if not data or not data[1] then
            MySQL.Async.execute(
                'INSERT INTO dopeplants (owner, plantid, plant) VALUES (@owner, @id, @plant)',
                {
                    ['@owner'] = identifier,
                    ['@id'] = plant.PlantID,
                    ['@plant'] = json.encode(plant)
                })
        else
            MySQL.Sync.execute(
                'UPDATE dopeplants SET plant=@plant WHERE plantid=@plantid',
                {['@plant'] = json.encode(plant), ['@plantid'] = plant.PlantID})
        end
    else
        if data and data[1] then
            MySQL.Async.execute('DELETE FROM dopeplants WHERE plantid=@plantid',
                                {['@plantid'] = plant.PlantID})
        end
    end
end

function MFD:GetLoginData(source)
    local _src = source
    local _char = exports.pw_core:getCharacter(_src)
    local data = MySQL.Sync.fetchAll(
                     'SELECT * FROM dopeplants WHERE owner=@owner',
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

function MFD:ItemTemplate() return {["Type"] = "Water", ["Quality"] = 0.0} end

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

RegisterServerEvent('pw_core:itemUsed')
AddEventHandler('pw_core:itemUsed', function(_src, data)
    if data.item == "hgfcokeseed" or data.item == "lgfcokeseed" or data.item ==
        "hgmcokeseed" or data.item == "lgmcokeseed" then
        TriggerClientEvent('pw_coke:Use' .. data.item, _src, data)
    elseif data.item == "hgfseed" or data.item == "lgfseed" or data.item ==
        "hgmseed" or data.item == "lgmseed" or data.item == "dopebag" or
        data.item == "rollingpapers" then
        TriggerClientEvent('pw_weed:Use' .. data.item, _src, data)
    elseif data.item == "wateringcan" or data.item == "purifiedwater" or
        data.item == "lgfert" or data.item == "hgfert" then
        TriggerClientEvent('pw_coke:HandleThisShit', _src, data)
    end
end)

PW.RegisterServerCallback('pw_weed:GetLoginData', function(source, cb)
    cb(MFD:GetLoginData(source));
end)
PW.RegisterServerCallback('pw_weed:GetStartData', function(source, cb)
    while not MFD.dS do Citizen.Wait(0); end
    cb(MFD.cS);
end)
AddEventHandler('pw_weed:SyncPlant', function(plant, delete) MFD:SyncPlant(plant, delete); end)
AddEventHandler('playerConnected', function(...) MFD:DoLogin(source); end)
Citizen.CreateThread(function(...) MFD:Awake(...); end)
