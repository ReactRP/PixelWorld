function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('lex570', '2019 Lexus X570') -- Enter Gamename from vehicles.lua and what you want it to display.
	AddTextEntry('gx460', '2014 Lexus GX460')
end)