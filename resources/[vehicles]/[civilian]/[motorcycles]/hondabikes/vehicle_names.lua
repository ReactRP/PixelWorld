function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('GOLDWING', '2018 Honda Goldwing GL1800') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('CB500X', '2019 Honda CB 500X')
    AddTextEntry('HCBR17', '2017 Honda CBR1000R')
    AddTextEntry('biz25', '2013 Honda Biz 125')
end)