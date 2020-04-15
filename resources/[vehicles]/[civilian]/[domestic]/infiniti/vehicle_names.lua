function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('qx56', '2012 Infiniti QX56') -- Enter Gamename from vehicles.lua and what you want it to display.
end)