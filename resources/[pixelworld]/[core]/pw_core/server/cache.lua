PW.Cache = PW.Cache or {}
local _cache = {}

function PW.Cache.Set(self, key, data, cb)
    _cache[key] = {
        data = data,
        callback = cb
    }
end

function PW.Cache.Get(self, key)
    if _cache[key] ~= nil then
        return _cache[key].data
    else
        return nil
    end
end

PW.Cache.Add = {
    Default = function(self, key, data)
        if _cache[key] ~= nil then
            table.insert(_cache[key].data, data)
        end
    end,
    Index = function(self, key, index, data)
        if _cache[key] ~= nil then
            _cache[key].data[index] = data
        end
    end
}

PW.Cache.Update = {
    Default = function(self, key, data)
        if _cache[key] ~= nil and _cache[key].data ~= nil then
            _cache[key].data = data
        end
    end,
    Index = function(self, key, index, data)
        if _cache[key] ~= nil and _cache[key].data ~= nil then
            _cache[key].data[index] = data
        end
    end,
    Callback = function(self, key, cb)
        if _cache[key] ~= nil then
            _cache[key].callback = cb
        end
    end
}

PW.Cache.Remove = {
    Default = function(self, key)
        if _cache[key] ~= nil then
            _cache[key] = nil
        end
    end,
    Index = function(self, key, index)
        if _cache[key] ~= nil and _cache[key].data ~= nil then
            _cache[key].data[index] = nil
        end
    end
}

--[[ Calling The Callbacks To Store Cached Data In Perma Storage ]]
PW.Cache.Store = {
    Index = {
        Default = function(self, key)
            if _cache[key] ~= nil then
                _cache[key].callback(_cache[key].data)
            end
        end,
        SecondaryKey = function(self, key, sKey)
            if _cache[key] ~= nil then
                _cache[key].callback({ _cache[key].data[sKey] })
            end
        end,
    },
    All = function(self)
        for k, v in pairs(_cache) do
            v.callback(v.data)
        end
    end
}