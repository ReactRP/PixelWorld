RegisterNetEvent("pw_hack:playSound")
AddEventHandler("pw_hack:playSound", function(name)
    local t = {transactionType = name}

    SendNuiMessage(json.encode(t))
end)