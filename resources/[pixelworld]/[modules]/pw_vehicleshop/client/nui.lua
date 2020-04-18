RegisterNUICallback("NUIFocusOff", function(data, cb)
    SetNuiFocus(false, false)
    inShopCatalogue = false
    SendNUIMessage({
        action = "hide"
    })
end)

RegisterNUICallback("testDriveVehicle", function(data, cb)
    if data then
        TriggerEvent('pw_vehicles:client:testDrive', data.vehicle)
    end
end)

RegisterNUICallback("purchaseVehicle", function(data, cb)
    if data then
        TriggerEvent('pw_vehicles:client:purchaseVehicle', data.vehicle)
    end
end)

RegisterNUICallback("financeVehicle", function(data, cb)
    if data then
        TriggerEvent('pw_vehicles:client:financeVehicle', data.vehicle)
    end
end)

RegisterNetEvent('pw_vehicleshop:openMenu')
AddEventHandler('pw_vehicleshop:openMenu', function()
    exports['pw_notify']:SendAlert('inform', 'The Vehicle Shop Catelogue is loading.', 5000)
    SetNuiFocus(true, true)
    inShopCatalogue = true
    SendNUIMessage({
        action = "showShop"
    })
end)