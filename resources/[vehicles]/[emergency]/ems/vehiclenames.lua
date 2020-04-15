function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end
Citizen.CreateThread(function()
    AddTextEntry('BCTAHOE', '2020 EMS Chevy Tahoe')
    AddTextEntry('FORDAMBO', '2019 EMS Chevy 5500')
    AddTextEntry('CHEVYAMBO', '2018 EMS Ford F350')
end)