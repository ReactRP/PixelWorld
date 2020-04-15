function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('LP700R', '2013 Lamborghini Aventador') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('18PERFORMAN', '2018 Lamborghini Performante')
	AddTextEntry('CENTENARIO', '2016 Lamborghini Centenario')
	AddTextEntry('COUNTACH', '1980 Lamborghini Countach')
	AddTextEntry('Murc2005', '2005 Lamborghini Murcielago')
	AddTextEntry('LP670', '2010 Lamborghini Murcielago 670P')
	AddTextEntry('lwlp670', '2010 Lamborghini Murcielago 670L')
end)