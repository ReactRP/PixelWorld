function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('CLA45SB', '2016 Mercedes-AMG') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('G65', '2013 Mercedes G65 AMG')
    AddTextEntry('AMGGT', '2016 Mercedes AMG-GT')
	AddTextEntry('300SL', '1955 Mercedes-Benz 300SL')
	AddTextEntry('V250', '2017 Mercedes V250')
	AddTextEntry('600sel', '1992 Mercedes 600 SEL')
	AddTextEntry('E63AMG', '2016 Mercedes E63 AMG')
	AddTextEntry('amga45', '2019 MERCEDES CLASSE A45 AMG')
	AddTextEntry('rmodgt63', '2019 MERCEDES AMG GT63S Coupe')

end)