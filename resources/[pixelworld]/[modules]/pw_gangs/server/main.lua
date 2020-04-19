PW = nil
local Gangs = {}

TriggerEvent('pw:loadFramework', function(framework) PW = framework end)

AddEventHandler('pw:databaseCachesLoaded', function(caches)
    Gangs = caches.gangs
    if #Gangs > 0 then
        for k,v in pairs(Gangs) do
            Gangs[k].hq = json.decode(v.hq)
        end
    end
end)

PW.RegisterServerCallback('pw_gangs:server:getGangs', function(source, cb)
    cb(Gangs)
end)