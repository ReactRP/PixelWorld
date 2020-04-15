function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('CadCTSV', '2016 Cadillac CTS-V') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('GMT900ESCALADE', '2014 Cadillac Escalade')
    AddTextEntry('ROYALE', '2014 Cadillac XTS Limo')
    AddTextEntry('CATS', '2016 Cadillac ATS-V')
    AddTextEntry('sixtyone41', '1941 Cadillac Series 61')
end)