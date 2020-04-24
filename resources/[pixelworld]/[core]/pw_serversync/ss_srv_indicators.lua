PW = nil

TriggerEvent('pw:loadFramework', function(obj)
    PW = obj
end)

if ss_enable_turn_signal_sync then
	RegisterServerEvent( "pw_serversync:SetVehicleIndicator" )
	AddEventHandler( "pw_serversync:SetVehicleIndicator", function( dir, state )
		TriggerClientEvent( "pw_serversync:VehicleIndicator", -1, source, dir, state )
	end)
end
