function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('L37', '1983 Lancia 037 Stradale') -- Enter Gamename from vehicles.lua and what you want it to display.
end)