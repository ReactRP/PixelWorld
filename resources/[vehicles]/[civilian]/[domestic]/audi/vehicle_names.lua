function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('A8AUDI', '2006 Audi A8 W12') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('r8ppi', '2014 Audi R8 V10')
    AddTextEntry('Rs4avant', '2014 Audi RS4')
    AddTextEntry('s5', '2017 Audi S5')
    AddTextEntry('RS5C', '2011 Audi RS5 Coupe')
    AddTextEntry('SQ72016', '2016 Audi SQ7')
    AddTextEntry('rs3', '2018 Audi RS3 Sportback')
    AddTextEntry('r820', '2020 Audi R8')
    AddTextEntry('rs6', '2016 Audi RS6')
end)