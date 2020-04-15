function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('nc1', '2016 Honda NSX') -- Enter Gamename from vehicles.lua and what you want it to display.
    AddTextEntry('TypeR17', '2018 Honda Civic Type R')
    AddTextEntry('cu2', '2018 Honda CU2')
    AddTextEntry('ody18', '2018 Honda Odyssey')

end)