function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('Kart3', 'Gocart 3') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('Kart26', 'Gocart 26')
    AddTextEntry('Kart65', 'Gocart 65')
    AddTextEntry('Kart73', 'Gocart 73')
end)