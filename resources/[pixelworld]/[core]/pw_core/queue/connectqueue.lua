Queue = {}
Queue.Ready = false
Queue.Exports = nil
Queue.ReadyCbs = {}
Queue.CurResource = GetCurrentResourceName()
whiteListReady = false

--if Queue.CurResource == "pw_core" then return end

function Queue.OnReady(cb)
    if not cb then return end
    if Queue.IsReady() then cb() return end
    table.insert(Queue.ReadyCbs, cb)
end

function Queue.OnJoin(cb)
    if not cb then return end
    Queue.Exports:OnJoin(cb, Queue.CurResource)
end

function Queue.AddPriority(id, power, temp)
    if not Queue.IsReady() then return end
    Queue.Exports:AddPriority(id, power, temp)
end

function Queue.RemovePriority(id)
    if not Queue.IsReady() then return end
    Queue.Exports:RemovePriority(id)
end

function Queue.IsReady()
    return Queue.Ready
end

function Queue.LoadExports()
    Queue.Exports = exports.pw_core:GetQueueExports()
    Queue.Ready = true
    Queue.ReadyCallbacks()
end

function Queue.ReadyCallbacks()
    if not Queue.IsReady() then return end
    for _, cb in ipairs(Queue.ReadyCbs) do
        cb()
    end
end

function Queue.Loaded()
    return whiteListReady
end

function Queue.refreshQueue()
    local added = false
    local done = false
    local totalAdded = 0
    MySQL.Async.fetchAll("SELECT * FROM `whitelist`", {}, function(users)
        for k, v in pairs(users) do
            if v.steam ~= nil then
                Queue.AddPriority(v.steam, tonumber(v.prio))
                added = true
            end

            if added then
                totalAdded = totalAdded + 1
            end
        end
        done = true
        print('^1 [PixelWorld Core]', '^7Whitelist Loaded', '^4', totalAdded, ' ^7Users Added')
        whiteListReady = true
        SetTimeout(1800000, function() Queue.refreshQueue() end)
    end)
    repeat Wait(0) until done == true
    return done
end

AddEventHandler("onResourceStart", function(resource)
    if resource == "pw_core" then
        while GetResourceState(resource) ~= "started" do Citizen.Wait(0) end
        Citizen.Wait(1)
        Queue.LoadExports()
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == "pw_core" then
        Queue.Ready = false
        Queue.Exports = nil
    end
end)

SetTimeout(1, function() Queue.LoadExports() end)

exports.pw_chat:AddAdminChatCommand('refreshwl', function(source, args, rawCommand)
    Queue.refreshQueue()
    if source > 0 then
        TriggerClientEvent('pw:notification:SendAlert', source, {type = "info", text = "The Server Whitelist has been successfully refreshed, newly whitelisted users should now be able to connect", length = 7500})
    end
end, {
    help = 'Refresh the Current Whitelist State',
}, -1)