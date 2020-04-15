containers = {}

RegisterServerEvent('pw_inventory:server:GetActiveContainers')
AddEventHandler('pw_inventory:server:GetActiveContainers', function()
    TriggerClientEvent('pw_inventory:client:RecieveActiveContainers', source, containers)
end)