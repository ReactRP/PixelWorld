function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('MODELS', '2015 Tesla Model S') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('MODEL3', '2019 Tesla Model 3')
    AddTextEntry('teslax', '2017 Tesla Model X')
end)