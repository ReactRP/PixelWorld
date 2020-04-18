-- Do not touch this
CONFIG = {}

-- Radar fast limit locking
-- When enabled, the player will be able to define a fast limit within the radar's menu, when a vehicle 
-- exceeds the fast limit, it will be locked into the fast box. Default setting is disabled to maintain realism
CONFIG.allow_fast_limit = true 

-- In-game first time quick start video
-- When enabled, the player will be asked if they'd like to view the quick start video the first time they 
-- open the remote. 
CONFIG.allow_quick_start_video = false 

-- Sets the defaults of all keybinds
-- These keybinds can be changed by each person in their GTA Settings->Keybinds->FiveM
CONFIG.keyDefaults =
{
	-- Remote control key 
	remote_control = "f5",

	-- Radar key lock key 
	key_lock = "l",

	-- Radar front antenna lock/unlock Key
	front_lock = "numpad8",

	-- Radar rear antenna lock/unlock Key
	rear_lock = "numpad5",

	-- Plate reader front lock/unlock Key
	plate_front_lock = "numpad9",

	-- Plate reader rear lock/unlock Key
	plate_rear_lock = "numpad6"
}

-- Here you can change the default values for the operator menu, do note, if any of these values are not
-- one of the options listed, the script will not work. 
CONFIG.menuDefaults = 
{
	-- Should the system calculate and display faster targets
	-- Options: true or false
	["fastDisplay"] = true, 

	-- Sensitivity for each radar mode, this changes how far the antennas will detect vehicles
	-- Options: 0.2, 0.4, 0.6, 0.8, 1.0
	["same"] = 0.4, 
	["opp"] = 0.4, 

	-- The volume of the audible beep 
	-- Options: 0.0, 0.2, 0.4, 0.6, 0.8, 1.0 
	["beep"] = 0.6,
	
	-- The volume of the verbal lock confirmation 
	-- Options: 0.0, 0.2, 0.4, 0.6, 0.8, 1.0 
	["voice"] = 0.4,
	
	-- The volume of the plate reader audio 
	-- Options: 0.0, 0.2, 0.4, 0.6, 0.8, 1.0 
	["plateAudio"] = 0.6, 

	-- The speed unit used in conversions
	-- Options: mph or kmh 
	["speedType"] = "mph"
}

-- Here you can change the default scale of the UI elements, as well as the safezone size
CONFIG.uiDefaults =
{
	-- The default scale of the UI elements.
	-- Options: 0.25 - 2.5
	scale =
	{
		radar = 0.8, 
		remote = 0.8, 
		plateReader = 0.6
	}, 

	-- The safezone size, must be a multiple of 5.
	-- Options: 0 - 100
	safezone = 20 
}