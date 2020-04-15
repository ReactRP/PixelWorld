function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('Stinger', '2019 Kia Stinger ') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('SPORTAGE', '2017 Kia Sportage')
end)