apiKey = GetConvar("PWAPIKEY", "invalid")
apiKeyResp = GetConvar("PWAPIRESPONSE", "invalid")
PW = {}
PW.Players              = {}
PW.ServerCallbacks      = {}
PW.TimeoutCount         = -1
PW.CancelledTimeouts    = {}
PW.UsableItemsCallbacks = {}
PWBase = {}
PWBase.Database = {}
Characters = {}
Users = {}

PWBase.Storage = {
    ['itemStore'] = {},
    ['characters'] = {},
    ['users'] = {},
    ['weapons'] = {},
    ['vehicles'] = {},
    ['properties'] = {},
    ['motels'] = {},
    ['entities'] = {},
    ['shopItemSets'] = {},
}

function checkOnline(cid)
    for k, v in pairs(Characters) do
        if v.getCID() == cid then
            return v.getSource()
        end
    end
    return false
end

exports('checkOnline', function(cid)
    return checkOnline(cid)
end)

function getOnlineCharacters()
	local onlineChars = {}
	for k, v in pairs(Characters) do
		table.insert(onlineChars, {['cid'] = v.getCID(), ['source'] = v.getSource() } )
	end
	return onlineChars
end

exports('getOnlineCharacters', function()
    return getOnlineCharacters()
end)

PW.CheckOnlineDuty = function(job)
    local online = {}
    for k, v in pairs(Characters) do
        if Characters[k] then
            if Characters[k]:Job().getJob().name == job and Characters[k]:Job().getJob().duty then
                table.insert(online, {['cid'] = Characters[k].getCID(), ['job'] = Characters[k]:Job().getJob(), ['source'] = Characters[k].getSource() })
            end
        end
    end
	return online
end

exports('getCache', function(req)
    if req ~= nil then
        if PWBase.Storage[req] then
            return PWBase.Storage[req]
        end
    else
        return PWBase.Storage
    end
end)

PW.CountTable = function(tbl)
    local count = 0
        for k, v in pairs(tbl) do
        count = count + 1
        end
    return count
end

PW.RegisterServerCallback = function(name, cb)
	PW.ServerCallbacks[name] = cb
end

PW.doAdminLog = function(src, action, meta, screen)
    if src ~= nil and src > 0 then
        local _src = src
        local _server = GetConvar("sv_hostname", "Unknown Server")
        if(Users[src])then
            local _user = Users[src]
            local _name = _user.getName()
            local _access = { ['loggedin'] = _user.getLoginState(), ['developerAccess'] = _user.getDeveloperState(), ['forumAccount'] = _user.getEmailAddress(), ['steam'] = _user.getSteam(), ['allIdentifiers'] = _user.getIdentifiers() }
            if(Characters[_src])then
                _access['character'] = { ['characterName'] = Characters[_src].getFullName(), ['characterId'] = Characters[_src].getCID() }
            end

            MySQL.Async.insert("INSERT INTO `admin_logs` (`action`,`currentSource`,`playerName`,`accessMeta`,`logMeta`,`server`) VALUES (@action, @src, @name, @ameta, @lmeta, @server)", {
                ['@action'] = action,
                ['@src'] = _src,
                ['@name'] = _name,
                ['@ameta'] = json.encode(_access),
                ['@lmeta'] = json.encode(meta) or "No Data",
                ['@server'] = _server
            }, function(inserted)
                if inserted > 0 then
                    if screen then
                        print(' ^1[PixelWorld Core] ^7- Admin Action Logged - "^4'.._name..' ^7| ^4'..action..' ^7| Developer:^4 '..tostring(_user.getDeveloperState())..'^7 | Logged In: ^4'..tostring(_user.getLoginState())..'"^7')
                        if meta ~= nil then
                            print(' ^2=============================================================^7')
                            PW.Print(meta)
                            print(' ^2=============================================================^7')
                        end
                    end
                end
            end)

            PWMySQL.Async.insert("INSERT INTO `admin_logs` (`action`,`currentSource`,`playerName`,`accessMeta`,`logMeta`,`server`) VALUES (@action, @src, @name, @ameta, @lmeta, @server)", {
                ['@action'] = action,
                ['@src'] = _src,
                ['@name'] = _name,
                ['@ameta'] = json.encode(_access),
                ['@lmeta'] = json.encode(meta) or "No Data",
                ['@server'] = _server
            }, function(inserted)
            end)
        end
    end
end

PW.ExecuteServerCallback = function(name, requestId, source, cb, ...)
	if PW.ServerCallbacks[name] ~= nil then
		PW.ServerCallbacks[name](source, cb, ...)
	else
		print('^1[PixelWorld]:^7 ExecuteServerCallback => [^2' .. name .. '^7] does not exist')
	end
end

PW.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if PW.ServerCallbacks[name] ~= nil then
		PW.ServerCallbacks[name](source, cb, ...)
	else
		print('^1[PixelWorld]:^7 ExecuteServerCallback => [^2' .. name .. '^7] does not exist')
	end
end

exports('GetActivePlayers', function()
    return Characters
end)

RegisterServerEvent('pw:serverCallback')
AddEventHandler('pw:serverCallback', function(name, requestId, ...)
	local _source = source

	PW.ExecuteServerCallback(name, requestID, _source, function(...)
		TriggerClientEvent('pw:serverCallback', _source, requestId, ...)
	end, ...)
end)

PW.GenerateCharCreLoc = function(src)
    for k, v in pairs(characterCreatorLocations) do
        if not v.inuse and v.user == 0 then
            v.inuse = true
            v.user = src
            return k
        end
    end
end

PW.CloseCharCreLoc = function(src)
    for k, v in pairs(characterCreatorLocations) do
        if v.inuse and v.user == src then
            v.inuse = false
            v.user = 0
            break;
        end
    end
end

PW.Print = function(t, s)
    if t then
        if type(t) ~= 'table' then 
            print("^1 [^3debug^1] ["..type(t).."] ^7", t)
            return
        else
            for k, v in pairs(t) do
                local kfmt = '["' .. tostring(k) ..'"]'
                if type(k) ~= 'string' then
                    kfmt = '[' .. k .. ']'
                end
                local vfmt = '"'.. tostring(v) ..'"'
                if type(v) == 'table' then
                    PW.Print(v, (s or '')..kfmt)
                else
                    if type(v) ~= 'string' then
                        vfmt = tostring(v)
                    end
					print(" ^1[^3debug^1] ["..type(t).."]^7", (s or '')..kfmt, '=', vfmt)
                end
            end
        end
    else
        print("^1Error Printing Request - The Passed through variable seems to be nil^7")
    end
end

PW.LoadSteamIdent = function(src)
    local id
	for k,v in ipairs(GetPlayerIdentifiers(src))do
        if string.sub(v, 1, string.len("steam:")) == ("steam:") then
            id = v
			break
		end
    end
    
    if id then
        return id
    else
        return false
    end
end

PW.RandomString = function(length)
    local charset = {}
    for i = 48,  57 do table.insert(charset, string.char(i)) end
    for i = 65,  90 do table.insert(charset, string.char(i)) end
    for i = 97, 122 do table.insert(charset, string.char(i)) end

    local function randomstr(length)
        math.randomseed(os.time())
        if length > 0 then
            return randomstr(length - 1) .. charset[math.random(1, #charset)]
        else
            return ""
        end
    end

    return randomstr(length)
end

exports('getCharacter', function(source)
    if Characters[source] then
        return Characters[source]
    end
end)

PW.SetTimeout = function(msec, cb)
	local id = PW.TimeoutCount + 1

	SetTimeout(msec, function()
		if PW.CancelledTimeouts[id] then
			PW.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	PW.TimeoutCount = id

	return id
end

PW.ClearTimeout = function(id)
	PW.CancelledTimeouts[id] = true
end

function multiInsert(times)
    local initialQuery = "(@id, @item, @count, @metapub, @metapri, @type, @slot)"
    local newQuery
    for i = 1, times do
        if i == 1 then
            newQuery = initialQuery
        else
            initialQuery = "(@id, @item, @count, @metapub, @metapri, @type, @slot)"
            newQuery = newQuery .. ',' .. initialQuery
        end
    end
    Citizen.Wait(50)
    return newQuery
end

function split(s, sep)
    local fields = {}

    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

    return fields
end

exports('getConfig', function(req)
    if Config[req] then
        return Config[req]
    end
end)

AddEventHandler('pw:loadFramework', function(cb)
	cb(PW)
end)

function loadFramework()
	return PW
end

exports('loadFramework', function()
    return loadFramework()
end)

PW.RegisterServerCallback('pw_base:functions:getAvaliableJobs', function(source, cb)
	MySQL.Async.fetchAll("SELECT * FROM `avaliable_jobs`", {}, function(jobs)
		cb(jobs)
	end)
end)

PW.RegisterServerCallback('pw_base:functions:getAvailiableGrades', function(source, cb, job)
	MySQL.Async.fetchAll("SELECT * FROM `job_grades` WHERE `job` = @job", { ['@job'] = job }, function(grades)
		cb(grades)
	end)
end)