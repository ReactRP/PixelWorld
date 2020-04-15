function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('PG205t', 'Peugeot 205T') -- Enter Gamename from vehicles.lua and what you want it to display.
end)