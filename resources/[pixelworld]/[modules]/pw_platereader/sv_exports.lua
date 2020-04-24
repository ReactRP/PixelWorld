--[[---------------------------------------------------------------------------------------
	Locks the designated plate reader camera for the given client. 

	Parameters:
		clientId:
			The id of the client
		cam:
			The camera to lock, either "front" or "rear"
		beepAudio:
			Play an audible beep, either true or false
		boloAudio:
			Play the bolo lock sound, either true or false
---------------------------------------------------------------------------------------]]--
function TogglePlateLock( clientId, cam, beepAudio, boloAudio )
	TriggerClientEvent( "wk:togglePlateLock", clientId, cam, beepAudio, boloAudio )
end 