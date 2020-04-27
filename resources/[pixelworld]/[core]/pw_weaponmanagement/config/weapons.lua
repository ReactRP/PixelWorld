Config.Weapons = {

	{
		name = 'WEAPON_KNIFE',
		label = 'Knife',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_NIGHTSTICK',
		label = 'Nightstick',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_HAMMER',
		label = 'Hammer',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_BAT',
		label = 'Bat',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_GOLFCLUB',
		label = 'Golfclub',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_CROWBAR',
		label = 'Crowbar',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_PISTOL',
		label = 'Glock 17',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_PISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_PISTOL_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_PI_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_PISTOL_VARMOD_LUXE'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_COMBATPISTOL',
		label = 'H&K P2000',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_COMBATPISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_COMBATPISTOL_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_PI_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_APPISTOL',
		label = 'Colt Scamp',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_APPISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_APPISTOL_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_PI_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_APPISTOL_VARMOD_LUXE'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_PISTOL50',
		label = 'Desert Eagle',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_PISTOL50_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_PISTOL50_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_PI_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_PISTOL50_VARMOD_LUXE'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_REVOLVER',
		label = 'MKII 380',
		components = {},
		type = 'normal'
	},

	{
		name = 'WEAPON_SNSPISTOL',
		label = 'H&K P7M10',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_SNSPISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_SNSPISTOL_CLIP_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_SNSPISTOL_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_HEAVYPISTOL',
		label = 'Springfield 1911',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_HEAVYPISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_HEAVYPISTOL_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_PI_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_HEAVYPISTOL_VARMOD_LUXE'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_VINTAGEPISTOL',
		label = 'FN Model 1922',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_VINTAGEPISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_VINTAGEPISTOL_CLIP_02'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP'), enabled = false }
		},
		type = 'normal'
	},

	{
		name = 'WEAPON_MICROSMG',
		label = 'MAC-10',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_MICROSMG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_MICROSMG_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_PI_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_MICROSMG_VARMOD_LUXE'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_SMG',
		label = 'MP5',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_SMG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_SMG_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_SMG_CLIP_03'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO_02'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_SMG_VARMOD_LUXE'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_ASSAULTSMG',
		label = 'FN P90',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_ASSAULTSMG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_ASSAULTSMG_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_MINISMG',
		label = 'Skorpion',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_MINISMG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_MINISMG_CLIP_02'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_MACHINEPISTOL',
		label = 'TEC-9',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_MACHINEPISTOL_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_MACHINEPISTOL_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_MACHINEPISTOL_CLIP_03'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_PI_SUPP'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_COMBATPDW',
		label = 'H&K MP5',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_COMBATPDW_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_COMBATPDW_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_COMBATPDW_CLIP_03'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL'), enabled = false }
		},
		type = 'automatic'
	},
	
	{
		name = 'WEAPON_PUMPSHOTGUN',
		label = 'Remington 870',
		components = {
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_SR_SUPP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_SAWNOFFSHOTGUN',
		label = 'Sawed Off Shotgun',
		components = {
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE'), enabled = false }
		},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_ASSAULTSHOTGUN',
		label = '12 Guage Mosseburg',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false }
		},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_BULLPUPSHOTGUN',
		label = 'Kel-Tel KSG',
		components = {
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false }
		},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_HEAVYSHOTGUN',
		label = 'Saiga 12 Guage',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_HEAVYSHOTGUN_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_HEAVYSHOTGUN_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_HEAVYSHOTGUN_CLIP_03'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false }
		},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_ASSAULTRIFLE',
		label = 'AK-47',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_03'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MACRO'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_ASSAULTRIFLE_VARMOD_LUXE'), enabled = false }
		},
		type = 'rifle'
	},

	{
		name = 'WEAPON_CARBINERIFLE',
		label = 'AR-15 .556',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_CARBINERIFLE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_CARBINERIFLE_CLIP_02'), enabled = false },
			{ name = 'clip_box', label = 'High Capacity Magazine', hash = GetHashKey('COMPONENT_CARBINERIFLE_CLIP_03'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP') },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_CARBINERIFLE_VARMOD_LUXE'), enabled = false }
		},
		type = 'rifle'
	},

	{
		name = 'WEAPON_ADVANCEDRIFLE',
		label = 'Kel-Tec RFB',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE'), enabled = false }
		},
		type = 'rifle'
	},

	{
		name = 'WEAPON_SPECIALCARBINE',
		label = 'H&K G36C',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_SPECIALCARBINE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_SPECIALCARBINE_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_SPECIALCARBINE_CLIP_03'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_BULLPUPRIFLE',
		label = 'Bullpup .223',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_BULLPUPRIFLE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_BULLPUPRIFLE_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_BULLPUPRIFLE_VARMOD_LOW'), enabled = false }
		},
		type = 'rifle'
	},

	{
		name = 'WEAPON_COMPACTRIFLE',
		label = 'Draco AK Pistol',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_COMPACTRIFLE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_COMPACTRIFLE_CLIP_02'), enabled = false },
			{ name = 'clip_drum', label = 'Drum Magazine', hash = GetHashKey('COMPONENT_COMPACTRIFLE_CLIP_03'), enabled = false }
		},
		type = 'rifle'
	},

	{
		name = 'WEAPON_MG',
		label = 'PKM Drum Fed',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_MG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_MG_CLIP_02'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_SMALL_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_MG_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_COMBATMG',
		label = 'M249',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_COMBATMG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_COMBATMG_CLIP_02'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_COMBATMG_VARMOD_LOWRIDER'), enabled = false }
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_GUSENBERG',
		label = 'Tommy Gun',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_GUSENBERG_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_GUSENBERG_CLIP_02'), enabled = false },
		},
		type = 'automatic'
	},

	{
		name = 'WEAPON_SNIPERRIFLE',
		label = 'Remington Model 700',
		components = {
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_LARGE'), enabled = false },
			{ name = 'scope_advanced', label = 'Advanced Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MAX'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP_02'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_SNIPERRIFLE_VARMOD_LUXE'), enabled = false }
		},
		type = 'sniper'
	},

	{
		name = 'WEAPON_HEAVYSNIPER',
		label = 'Barrett M82',
		components = {
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_LARGE'), enabled = false },
			{ name = 'scope_advanced', label = 'Advanced Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_MAX'), enabled = false }
		},
		type = 'sniper'
	},

	{
		name = 'WEAPON_MARKSMANRIFLE',
		label = 'M59 SKS',
		components = {
			{ name = 'clip_default', label = 'Standard Clip', hash = GetHashKey('COMPONENT_MARKSMANRIFLE_CLIP_01'), enabled = false },
			{ name = 'clip_extended', label = 'Extended Clip', hash = GetHashKey('COMPONENT_MARKSMANRIFLE_CLIP_02'), enabled = false },
			{ name = 'flashlight', label = 'Flashlight Attachment', hash = GetHashKey('COMPONENT_AT_AR_FLSH'), enabled = false },
			{ name = 'scope', label = 'Scope', hash = GetHashKey('COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM'), enabled = false },
			{ name = 'suppressor', label = 'Supressor', hash = GetHashKey('COMPONENT_AT_AR_SUPP'), enabled = false },
			{ name = 'grip', label = 'Grip', hash = GetHashKey('COMPONENT_AT_AR_AFGRIP'), enabled = false },
			{ name = 'luxary_finish', label = 'Luxary Finish', hash = GetHashKey('COMPONENT_MARKSMANRIFLE_VARMOD_LUXE'), enabled = false }
		},
		type = 'rifle'
	},

	{
		name = 'WEAPON_GRENADELAUNCHER',
		label = 'Grenade Launcher',
		components = {},
		type = 'bannedc'
	},

	{
		name = 'WEAPON_RPG',
		label = 'Rocket Launcher',
		components = {},
		type = 'banned'
	},

	{
		name = 'WEAPON_STINGER',
		label = 'FIM-92 Stinger',
		components = {}
	},

	{
		name = 'WEAPON_MINIGUN',
		label = 'Minigun',
		components = {},
		type = 'automatic'
	},

	{
		name = 'WEAPON_GRENADE',
		label = 'Grenade',
		components = {},
		type = 'explosive'
	},

	{
		name = 'WEAPON_STICKYBOMB',
		label = 'Sticky Bomb',
		components = {},
		type = 'explosive'
	},

	{
		name = 'WEAPON_SMOKEGRENADE',
		label = 'Smoke Grenade',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_BZGAS',
		label = 'Gas Grenade',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_MOLOTOV',
		label = 'Molotov Cocktail',
		components = {},
		type = 'explosive'
	},

	{
		name = 'WEAPON_FIREEXTINGUISHER',
		label = 'Fire Extinguisher',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_PETROLCAN',
		label = 'Jerry Can',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_DIGISCANNER',
		label = 'Digi Scanner',
		components = {}
	},

	{
		name = 'WEAPON_BALL',
		label = 'Ball',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_BOTTLE',
		label = 'Bottle',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_DAGGER',
		label = 'Dagger',
		components = {},
		type = 'knife'
	},

	{
		name = 'WEAPON_FIREWORK',
		label = 'Firework',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_MUSKET',
		label = 'Musket',
		components = {},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_STUNGUN',
		label = 'Tazer',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_HOMINGLAUNCHER',
		label = 'Homing Launcher',
		components = {},
		type = 'banned'
	},

	{
		name = 'WEAPON_PROXMINE',
		label = 'Proximity Mine',
		components = {},
		type = 'explosive'
	},

	{
		name = 'WEAPON_SNOWBALL',
		label = 'Snowball',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_FLAREGUN',
		label = 'Flaregun',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_GARBAGEBAG',
		label = 'Garbage Bag',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_HANDCUFFS',
		label = 'Handcuffs',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_MARKSMANPISTOL',
		label = 'Marksman Pistol',
		components = {},
		type = 'normal'
	},

	{
		name = 'WEAPON_KNUCKLE',
		label = 'Knuckle Dusters',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_HATCHET',
		label = 'Hatchet',
		components = {},
		type = 'knife'
	},

	{
		name = 'WEAPON_RAILGUN',
		label = 'Railgun',
		components = {}
	},

	{
		name = 'WEAPON_MACHETE',
		label = 'Machete',
		components = {},
		type = 'knife'
	},

	{
		name = 'WEAPON_SWITCHBLADE',
		label = 'Switchblade',
		components = {},
		type = 'knife'
	},

	{
		name = 'WEAPON_DBSHOTGUN',
		label = 'Double Barrel Shotgun',
		components = {},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_AUTOSHOTGUN',
		label = 'SWD Street Sweeper',
		components = {},
		type = 'shotgun'
	},

	{
		name = 'WEAPON_BATTLEAXE',
		label = 'Battel Axe',
		components = {},
		type = 'knife'
	},

	{
		name = 'WEAPON_COMPACTLAUNCHER',
		label = 'Compact Launcher',
		components = {},
		type = 'explosive'
	},

	{
		name = 'WEAPON_PIPEBOMB',
		label = 'Pipe Bomb',
		components = {},
		type = 'explosive'
	},

	{
		name = 'WEAPON_POOLCUE',
		label = 'Pool Cue',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_WRENCH',
		label = 'Wrench',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_FLASHLIGHT',
		label = 'Flashlight',
		components = {},
		type = 'hand'
	},

	{
		name = 'GADGET_NIGHTVISION',
		label = 'Nightvision Goggles',
		components = {},
		type = 'hand'
	},

	{
		name = 'GADGET_PARACHUTE',
		label = 'Parachute',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_FLARE',
		label = 'Flare',
		components = {},
		type = 'hand'
	},

	{
		name = 'WEAPON_DOUBLEACTION',
		label = 'Colt M1892',
		components = {},
		type = 'normal'
	}

}

Config.WeaponStress = {
	['hand'] = 0,
	['automatic'] = 500,
	['rifle'] = 250,
	['sniper'] = 800,
	['banned'] = 1000000,
	['explosive'] = 5000,
	['knife'] = 50,
	['shotgun'] = 280,
	['normal'] = 120,
}

function retreiveWeapon(name)
    for k, v in pairs(Config.Weapons) do
        if v.name == name then
            return v
        end
    end
end

function retreiveWeaponByHash(hash)
	for k, v in pairs(Config.Weapons) do
		if GetHashKey(v.name) == tonumber(hash) then
            return v
        end
	end
	
	return { ['label'] = "Unknown" }
end