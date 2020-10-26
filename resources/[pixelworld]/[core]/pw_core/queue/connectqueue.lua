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
    whiteListReady = true
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