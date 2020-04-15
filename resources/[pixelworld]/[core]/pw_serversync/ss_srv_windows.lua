if ss_enable_door_window_sync then
  RegisterServerEvent( "pw_serversync:SetVehicleWindow" )
  AddEventHandler( "pw_serversync:SetVehicleWindow", function( windowsDown )
  	TriggerClientEvent( "VehicleWindow", -1, source, windowsDown )
  end)
end