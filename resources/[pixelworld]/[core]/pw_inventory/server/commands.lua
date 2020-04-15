AddEventHandler('mythic_base:shared:ComponentsReady', function()
    exports['mythic_base']:FetchComponent('Chat'):RegisterCommand('rob', function(source, args, rawCommand)
        TriggerClientEvent('mythic_inventory:client:RobPlayer', source)         
    end, {
        help = "Rob Nearest Player - Taking Their Cash & View Their Inventory"
    }, -1)
end)