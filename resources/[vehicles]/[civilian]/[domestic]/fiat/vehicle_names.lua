function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('PUNTO', '2009 Fiat Punto') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('ottov53', '1953 Fiat Ottov')
    AddTextEntry('124spider', '2017 Fiat 124 Spider')
    AddTextEntry('fiat175', '1997 Fiat Coupe')
end)