function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('CX75', '2014 Jaguar CX75') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('EAGLE', '1984 Jaguar Eagle')
	AddTextEntry('project7', '2017 Jaguar Project 7')
end)