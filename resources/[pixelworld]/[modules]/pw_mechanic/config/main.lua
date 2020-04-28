Config = {}

Config.Blips = {
    ['blipSprite'] = 446,
    ['blipScale'] = 1.0,
    ['blipColor'] = 46
}

Config.Locations = {
    [1] = { -- los Santos
        ['customize'] = 		{ ['x'] = -338.52, ['y'] = -137.73, ['z'] = 39.01, ['h'] = 79.08, 	['dutyNeeded'] = true 	},
        ['bossactions'] = 		{ ['x'] = -350.56, ['y'] = -128.37, ['z'] = 39.01, ['h'] = 242.42 , ['dutyNeeded'] = true 	},
        ['mechanicactions'] = 	{ ['x'] = -347.93, ['y'] = -122.19, ['z'] = 39.01, ['h'] = 258.12 , ['dutyNeeded'] = false 	},
        ['storage'] = 			{ ['x'] = -344.26, ['y'] = -128.06, ['z'] = 39.01, ['h'] = 81.15, 	['dutyNeeded'] = true 	},
        ['garage'] = {
            ['dutyNeeded'] = true,
            ['enter'] = { ['x'] = -365.68, ['y'] = -142.84, ['z'] = 38.68, ['h'] = 75.9 	},
            ['spawn'] = { ['x'] = -370.32, ['y'] = -107.62, ['z'] = 38.68, ['h'] = 68.89 	}
        }
	},
	[2] = { -- Sandy Shores
        ['customize'] = 		{ ['x'] = 1174.82, ['y'] = 2640.29, ['z'] = 37.75, 	['h'] = 356.19,	['dutyNeeded'] = true 	},
        ['bossactions'] = 		{ ['x'] = 1186.82, ['y'] = 2637.4, 	['z'] = 38.4, 	['h'] = 5.45,	['dutyNeeded'] = true 	},
        ['mechanicactions'] = 	{ ['x'] = 1171.34, ['y'] = 2637.67, ['z'] = 37.97, 	['h'] = 92.14, 	['dutyNeeded'] = false 	},
        ['storage'] = 			{ ['x'] = 1177.29, ['y'] = 2636.25, ['z'] = 37.75, 	['h'] = 199.57,	['dutyNeeded'] = true 	},
        ['garage'] = {
            ['dutyNeeded'] = true,
            ['enter'] = { ['x'] = 1186.22, ['y'] = 2649.9, 	['z'] = 37.85, ['h'] = 43.73 	},
            ['spawn'] = { ['x'] = 1185.06, ['y'] = 2654.69, ['z'] = 37.82, ['h'] = 310.15 	}
        }
	}
}

Config.AllowedTows = {"flatbed"}

Config.DefaultPrice = 50000 -- Price to set if vehicle is not in our vehicles DB
Config.DrawDistance = 3.0

Config.LimitRates = {
	['hourRate'] = {
		['min'] = 1,
		['max'] = 300,
	},
}

Config.MySQL = {}

Config.Defaults = {
	['hourRate'] = 50,
}

Config.Menu = {
    ['main'] = { -- done
        ['label'] = 'Vehicle Upgrades and Cosmetics',
        ['parent'] = nil,
        ['options'] = {
			['repairs'] = 			{ ['label'] = 'Repairs',				['target'] = 'repair',			['parent'] = 'main' },
            ['interiorUpgrades'] =  { ['label'] = 'Performance',    		['target'] = 'performance',     ['parent'] = 'main' },
			['tuningUpgrades'] =    { ['label'] = 'Cosmetics',      		['target'] = 'cosmetics',       ['parent'] = 'main' },
			['shopCart'] = 			{ ['label'] = 'Shopping Cart',			['target'] = nil,				['parent'] = 'main' }
        }
	},
	['repair'] = {
        ['label'] = 'Body and Mechanical Repairs',
        ['parent'] = 'main',
        ['options'] = {
			['repairBody'] =		{ ['label'] = 'Body',		['parent'] = 'repair',     ['target'] = 'bodyRepair'		},
			['repairEngine'] =		{ ['label'] = 'Mechanical',	['parent'] = 'repair',     ['target'] = 'mechRepair'		},
		}
	},
	['bodyRepair'] = {
		['label'] = 'Body Repairs',
		['parent'] = 'repair',
		['options'] = {
			['bodyhealth'] =		{ ['label'] = 'bodydmg',			['parent'] = 'bodyRepair',     ['target'] = nil				},
			['clean'] =				{ ['label'] = 'Clean Dirt',			['parent'] = 'bodyRepair',     ['part'] = 'clean'			},
			['defRepair'] =			{ ['label'] = 'Fix Deformations',	['parent'] = 'bodyRepair',     ['part'] = 'defRepair'		},
			['repairAll'] =			{ ['label'] = 'Full Body Repair',	['parent'] = 'bodyRepair',	   ['part'] = 'repairAll'		},
		}
	},
	['mechRepair'] = {
		['label'] = 'Mechanical Repairs',
		['parent'] = 'repair',
		['options'] = {
			['enginehealth'] =		{ ['label'] = 'enginedmg',	['parent'] = 'bodyRepair',     ['target'] = nil				},
			['engineRepair'] =		{ ['label'] = 'Fix Engine',	['parent'] = 'bodyRepair',     ['part'] = 'windowRepair'	},
		}
	},
	
    ['performance'] = { -- done
        ['label'] = 'Performance Upgrades',
        ['parent'] = 'main',
        ['options'] = {
            ['modEngine'] =        { ['label'] = 'Engine',         ['parent'] = 'performance',     ['part'] = 11,	},
            ['modTurbo'] =         { ['label'] = 'Turbo',          ['parent'] = 'performance',     ['part'] = 17,	},
            ['modTransmission'] =  { ['label'] = 'Transmission',   ['parent'] = 'performance',     ['part'] = 13,	},
            ['modBrakes'] =        { ['label'] = 'Brakes',         ['parent'] = 'performance',     ['part'] = 12,	},
            ['modSuspension'] =    { ['label'] = 'Suspension',     ['parent'] = 'performance',     ['part'] = 15,	},
            ['modArmor'] =         { ['label'] = 'Armor',          ['parent'] = 'performance',     ['part'] = 16,	},
		}
    },
    ['cosmetics'] = { -- done
        ['label'] = 'Cosmetics',
        ['parent'] = 'main',
        ['options'] = {
            ['paint'] =             { ['label'] = 'Paint',              ['target'] = 'colors',          ['parent'] = 'cosmetics'            					},
            ['bodyParts'] =         { ['label'] = 'Body Parts',         ['target'] = 'bodyParts',       ['parent'] = 'cosmetics'            					},
            ['windowTint'] =        { ['label'] = 'Window Tint',        ['part'] = 'windowTint',        ['parent'] = 'cosmetics'            					},
            ['neons'] =             { ['label'] = 'Neons',              ['target'] = 'neons',         	['parent'] = 'cosmetics'            					},
            ['xenon'] =             { ['label'] = 'Xenon Headlights',   ['target'] = 'xenonHeadlights', ['parent'] = 'cosmetics'            					},
            ['plates'] =            { ['label'] = 'Plates',             ['target'] = 'plates',          ['parent'] = 'cosmetics'            					},
            ['wheels'] =            { ['label'] = 'Wheels',             ['target'] = 'wheels',          ['parent'] = 'cosmetics'            					},
            ['speaker'] =           { ['label'] = 'Speakers',           ['target'] = 'speakers',        ['parent'] = 'cosmetics'            					},
            ['modHorns'] =          { ['label'] = 'Horns',              ['part'] = 14,                  ['parent'] = 'cosmetics'            					},
            ['modTrimA'] =          { ['label'] = 'Trim',               ['part'] = 27,                  ['parent'] = 'cosmetics'            					},
            ['modOrnaments'] =      { ['label'] = 'Ornaments',          ['part'] = 28,                  ['parent'] = 'cosmetics'            					},
            ['modDashboard'] =      { ['label'] = 'Dashboard',          ['part'] = 29,                  ['parent'] = 'cosmetics'            					},
            ['modDial'] =           { ['label'] = 'Speedometer',        ['part'] = 30,                  ['parent'] = 'cosmetics'            					},
            ['modSeats'] =          { ['label'] = 'Seats',              ['part'] = 32,                  ['parent'] = 'cosmetics'            					},
            ['modSteeringWheel'] =  { ['label'] = 'Steering Wheel',     ['part'] = 33,                  ['parent'] = 'cosmetics'            					},
            ['modShifterLeavers'] = { ['label'] = 'Shifter',            ['part'] = 34,                  ['parent'] = 'cosmetics'            					},
            ['modTrunk'] =          { ['label'] = 'Trunk',              ['part'] = 37,                  ['parent'] = 'cosmetics', ['open'] = {4, 5}            	},
            ['modHydrolic'] =       { ['label'] = 'Hydraulics',         ['part'] = 38,                  ['parent'] = 'cosmetics', ['open'] = {4, 5}            	},
            ['modEngineBlock'] =    { ['label'] = 'Engine Block',       ['part'] = 39,                  ['parent'] = 'cosmetics', ['open'] = {4, 5}            	},
            ['modAirFilter'] =      { ['label'] = 'Air Filter',         ['part'] = 40,                  ['parent'] = 'cosmetics', ['open'] = {4, 5}            	},
            ['modStruts'] =         { ['label'] = 'Struts',             ['part'] = 41,                  ['parent'] = 'cosmetics', ['open'] = {4, 5}            	},
            ['modArchCover'] =      { ['label'] = 'Arch Cover',         ['part'] = 42,                  ['parent'] = 'cosmetics'            					},
            ['modAerials'] =        { ['label'] = 'Aerials',            ['part'] = 43,                  ['parent'] = 'cosmetics'            					},
            ['modTrimB'] =          { ['label'] = 'Wings',              ['part'] = 44,                  ['parent'] = 'cosmetics'            					},
            ['modTank'] =           { ['label'] = 'Fuel Tank',          ['part'] = 45,                  ['parent'] = 'cosmetics', ['open'] = {4, 5}            	},
            ['modWindows'] =        { ['label'] = 'Windows',            ['part'] = 46,                  ['parent'] = 'cosmetics'            					},
        }
    },
    ['colors'] = { -- done
        ['label'] = 'Paint',
        ['parent'] = 'cosmetics',
        ['options'] = {
            ['bodyPrimaryColor'] =      { ['label'] = 'Primary Color',      ['parent'] = 'colors',  ['part'] = 'color1'             },
            ['bodySecondaryColor'] =    { ['label'] = 'Secondary Color',    ['parent'] = 'colors',  ['part'] = 'color2'             },
            ['pearlescentColor'] =      { ['label'] = 'Pearlescent Color',  ['parent'] = 'colors',  ['part'] = 'pearlescentColor'   },
            ['wheelColor'] =            { ['label'] = 'Wheel Color',        ['parent'] = 'colors',  ['part'] = 'wheelColor'         },
            ['modLivery'] =             { ['label'] = 'Livery',             ['parent'] = 'colors',  ['part'] = 'modLivery'          },
        }
    },
    ['bodyParts'] = { -- done
        ['label'] = 'Body Parts',
        ['parent'] = 'cosmetics',
        ['options'] = {
            ['modLeftFender'] =     { ['label'] = 'Left Fender',    ['parent'] = 'bodyParts',   ['part'] = 8    },
            ['modRightFender'] =    { ['label'] = 'Right Fender',   ['parent'] = 'bodyParts',   ['part'] = 9    },
            ['modSpoilers'] =       { ['label'] = 'Spoiler',        ['parent'] = 'bodyParts',   ['part'] = 0    },
            ['modSideSkirt'] =      { ['label'] = 'Side Skirt',    	['parent'] = 'bodyParts',   ['part'] = 3    },
            ['modFrame'] =          { ['label'] = 'Frame',          ['parent'] = 'bodyParts',   ['part'] = 5    },
            ['modHood'] =           { ['label'] = 'Hood',           ['parent'] = 'bodyParts',   ['part'] = 7    },
            ['modGrille'] =         { ['label'] = 'Grille',         ['parent'] = 'bodyParts',   ['part'] = 6    },
            ['modRearBumper'] =     { ['label'] = 'Rear Bumper',    ['parent'] = 'bodyParts',   ['part'] = 2    },
            ['modFrontBumper'] =    { ['label'] = 'Front Bumper',   ['parent'] = 'bodyParts',   ['part'] = 1,	},
            ['modExhaust'] =        { ['label'] = 'Exhaust',        ['parent'] = 'bodyParts',   ['part'] = 4    },
            ['modRoof'] =           { ['label'] = 'Roof',           ['parent'] = 'bodyParts',   ['part'] = 10   },
        }
	},
	['neons'] = { -- done
		['label'] = 'Neons',
		['parent'] = 'cosmetics',
		['options'] = {
			['neonColor'] =     	{ ['label'] = 'Neon Color',		['parent'] = 'neons',  		['part'] = 'neonColor' 		},
			['neonEnabled'] =      	{ ['label'] = 'Neon Layout',    ['parent'] = 'neons',  		['part'] = 'neonEnabled' 	},
		}
	},
    ['xenonHeadlights'] = { -- done
        ['label'] = 'Xenon Headlights',
        ['parent'] = 'cosmetics',
        ['options'] = {
            ['modXenon'] =      	{ ['label'] = 'Xenon Headlights',   ['parent'] = 'xenonHeadlights',  ['part'] = 'modXenon'      },
            ['modXenonColor'] =    	{ ['label'] = 'Xenon Color',        ['parent'] = 'xenonHeadlights',  ['part'] = 'modXenonColor' },
        }
    },
    ['plates'] = { -- done
        ['label'] = 'Plates',
        ['parent'] = 'cosmetics',
        ['options'] = {
            ['plateIndex'] =        { ['label'] = 'Plate Style',    ['parent'] = 'plates',  ['part'] = 'plateIndex'     },
            ['modPlateHolder'] =    { ['label'] = 'Plate Holder',   ['parent'] = 'plates',  ['part'] = 25               },
            ['modVanityPlate'] =    { ['label'] = 'Vanity Plate',   ['parent'] = 'plates',  ['part'] = 26               },
            ['modAPlate'] =         { ['label'] = 'Plate A',       	['parent'] = 'plates',  ['part'] = 35               },
        }
    },
    ['wheels'] = { -- done
        ['label'] = 'Wheels',
        ['parent'] = 'cosmetics',
        ['options'] = {
            ['wheelTypes'] =        { ['label'] = 'Wheel Type',      ['parent'] = 'wheels',  ['target'] = 'wheelTypes'      },
            ['tyreSmokeColor'] =    { ['label'] = 'Tire Smoke',      ['parent'] = 'wheels',  ['part'] = 'tyreSmokeColor'    },
        }
    },
    ['wheelTypes'] = { -- done
        ['label'] = 'Wheel Types',
        ['parent'] = 'wheels',
        ['options'] = {
            ['sport'] =         { ['label'] = 'Sports',         ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 0 },
            ['muscle'] =        { ['label'] = 'Muscle',         ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 1 },
            ['lowrider'] =      { ['label'] = 'Lowrider',       ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 2 },
            ['suv'] =           { ['label'] = 'SUV',            ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 3 },
            ['offroad'] =       { ['label'] = 'Off-Road',       ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 4 },
            ['tuning'] =        { ['label'] = 'Tuning',         ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 5 },
			['motorcycles'] =   { ['label'] = 'Motorcycles',    ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 6 },
			['highend'] =       { ['label'] = 'High-End',       ['parent'] = 'wheelTypes',  ['part'] = 23,  ['type'] = 7 },
        }
    },
    ['speakers'] = { -- done
        ['label'] = 'Speakers',
        ['parent'] = 'cosmetics',
        ['options'] = {
            ['modDoorSpeaker'] =   { ['label'] = 'Door Speakers',  ['part'] = 31,      ['parent'] = 'speakers', ['open'] = {0, 1, 2, 3}   },
            ['modSpeakers'] =      { ['label'] = 'Speakers',       ['part'] = 36,      ['parent'] = 'speakers', ['open'] = {4, 5}         },
        }
    },
}

Config.Prices = { -- flat rate hours to install said parts to multiply for the hourly cost set by the boss
    ['Audi'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Buick'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

	['Cadillac'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Chevy'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Dodge'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Fiat'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Ford'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Honda'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Infiniti'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Jeep'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},
	
	['Kia'] = {			['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Lexus'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Mazda'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Mercedes'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Mercury'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Mitsubishi'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Nissan'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Pontiac'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['RangeRover'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Subaru'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Tesla'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Toyota'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Volvo'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Bentley'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['BMW'] = {			['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Bugatti'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Ferrari'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Jaguar'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Lancia'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Lamborghini'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Landrover'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['McLaren'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Mini'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Peugeot'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Porsche'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Twizy'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Vapid'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Volkswagen'] = {	['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Zil'] = {			['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['GTAV'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Admin'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Fun'] = {			['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Tow'] = {			['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},

    ['Stock'] = {		['performance'] = 10, ['bodyParts'] = 5, ['cosmetics'] = 3, ['colors'] = 5, ['neons'] = 1, 
						['xenonHeadlights'] = 2, ['plates'] = 1, ['wheelTypes'] = 1, ['speakers'] = 4, ['wheels'] = 1
	},
}

Config.AvgMakes = {
	[1] = 	{ ['maxValue'] = 30000, 	['cost'] = 1 	},	
	[2] =	{ ['maxValue'] = 60000, 	['cost'] = 2 	},
	[3] =	{ ['maxValue'] = 90000, 	['cost'] = 3 	},
	[4] =	{ ['maxValue'] = 120000, 	['cost'] = 5 	},
	[5] =	{ ['maxValue'] = 200000, 	['cost'] = 8 	},
	[6] =	{ ['maxValue'] = 300000, 	['cost'] = 13 	},
	[7] =	{ ['maxValue'] = 600000, 	['cost'] = 19	},
	[8] =	{ ['maxValue'] = 3500000, 	['cost'] = 25 	},
}

Config.PaintTypes = {
	{ ['label'] = "Normal", 	['index'] = 0 },
	{ ['label'] = "Metallic", 	['index'] = 1 },
	{ ['label'] = "Pearl", 		['index'] = 2 },
	{ ['label'] = "Matte", 		['index'] = 3 },
	{ ['label'] = "Metal", 		['index'] = 4 },
	{ ['label'] = "Chrome", 	['index'] = 5 },
}

Config.PlateIndex = {
	{ ['label'] = "Blue on White 1", 	['index'] = 0 },
	{ ['label'] = "Yellow on Black", 	['index'] = 1 },
	{ ['label'] = "Yellow on Blue", 	['index'] = 2 },
	{ ['label'] = "Blue on White 2", 	['index'] = 3 },
	{ ['label'] = "Blue on White 3", 	['index'] = 4 },
}

function GetPlatesName(index)
	for k,v in pairs(Config.PlateIndex) do
		if v.index == index then
			return v.label
		end
	end
end

Config.XenonColors = {
    { ['label'] = "Default", 		['color'] = -1 },
    { ['label'] = "White", 			['color'] = 0 },
    { ['label'] = "Blue", 			['color'] = 1 },
    { ['label'] = "Electric Blue", 	['color'] = 2 },
    { ['label'] = "Mint Green", 	['color'] = 3 },
    { ['label'] = "Lime Green", 	['color'] = 4 },
    { ['label'] = "Yellow", 		['color'] = 5 },
    { ['label'] = "Golden Shower", 	['color'] = 6 },
    { ['label'] = "Orange", 		['color'] = 7 },
    { ['label'] = "Red", 			['color'] = 8 },
    { ['label'] = "Pony Pink", 		['color'] = 9 },
    { ['label'] = "Hot Pink", 		['color'] = 10 },
    { ['label'] = "Purple", 		['color'] = 11 },
    { ['label'] = "Blacklight", 	['color'] = 12 }
}

function GetXenonColor(color)
    for k,v in pairs(Config.XenonColors) do
        if color == v.color then
            return v
        end
    end
end

Config.WindowName = {
	{ ['label'] = "None", 			['index'] = 0 },
	{ ['label'] = "Pure Black", 	['index'] = 1 },
	{ ['label'] = "Dark Smoke", 	['index'] = 2 },
	{ ['label'] = "Light Smoke",	['index'] = 3 },
	{ ['label'] = "Stock", 			['index'] = 4 },
	{ ['label'] = "Limo", 			['index'] = 5 },
	{ ['label'] = "Green", 			['index'] = 6 },
}

function GetHornName(index)
	if (index == 0) then
		return "Truck Horn"
	elseif (index == 1) then
		return "Cop Horn"
	elseif (index == 2) then
		return "Clown Horn"
	elseif (index == 3) then
		return "Musical Horn 1"
	elseif (index == 4) then
		return "Musical Horn 2"
	elseif (index == 5) then
		return "Musical Horn 3"
	elseif (index == 6) then
		return "Musical Horn 4"
	elseif (index == 7) then
		return "Musical Horn 5"
	elseif (index == 8) then
		return "Sad Trombone"
	elseif (index == 9) then
		return "Classical Horn 1"
	elseif (index == 10) then
		return "Classical Horn 2"
	elseif (index == 11) then
		return "Classical Horn 3"
	elseif (index == 12) then
		return "Classical Horn 4"
	elseif (index == 13) then
		return "Classical Horn 5"
	elseif (index == 14) then
		return "Classical Horn 6"
	elseif (index == 15) then
		return "Classical Horn 7"
	elseif (index == 16) then
		return "Scale - Do"
	elseif (index == 17) then
		return "Scale - Re"
	elseif (index == 18) then
		return "Scale - Mi"
	elseif (index == 19) then
		return "Scale - Fa"
	elseif (index == 20) then
		return "Scale - Sol"
	elseif (index == 21) then
		return "Scale - La"
	elseif (index == 22) then
		return "Scale - Ti"
	elseif (index == 23) then
		return "Scale - Do"
	elseif (index == 24) then
		return "Jazz Horn 1"
	elseif (index == 25) then
		return "Jazz Horn 2"
	elseif (index == 26) then
		return "Jazz Horn 3"
	elseif (index == 27) then
		return "Jazz Horn Loop"
	elseif (index == 28) then
		return "Star Spangled Banner 1"
	elseif (index == 29) then
		return "Star Spangled Banner 2"
	elseif (index == 30) then
		return "Star Spangled Banner 3"
	elseif (index == 31) then
		return "Star Spangled Banner 4"
	elseif (index == 32) then
		return "Classical Horn 8 Loop"
	elseif (index == 33) then
		return "Classical Horn 9 Loop"
	elseif (index == 34) then
		return "Classical Horn 10 Loop"
	elseif (index == 35) then
		return "Classical Horn 8"
	elseif (index == 36) then
		return "Classical Horn 9"
	elseif (index == 37) then
		return "Classical Horn 10"
	elseif (index == 38) then
		return "Funeral Loop"
	elseif (index == 39) then
		return "Funeral"
	elseif (index == 40) then
		return "Spooky Loop"
	elseif (index == 41) then
		return "Spooky"
	elseif (index == 42) then
		return "San Andreas Loop"
	elseif (index == 43) then
		return "San Andreas"
	elseif (index == 44) then
		return "Liberty City Loop"
	elseif (index == 45) then
		return "Liberty City"
	elseif (index == 46) then
		return "Festive 1 Loop"
	elseif (index == 47) then
		return "Festive 1"
	elseif (index == 48) then
		return "Festive 2 Loop"
	elseif (index == 49) then
		return "Festive 2"
	elseif (index == 50) then
		return "Festive 3 Loop"
	elseif (index == 51) then
		return "Festive 3"
	else
		return "Unknown Horn"
	end
end

Config.Colors = {
	{ label = 'Black', value = 'black'},
	{ label = 'White', value = 'white'},
	{ label = 'Grey', value = 'grey'},
	{ label = 'Red', value = 'red'},
	{ label = 'Pink', value = 'pink'},
	{ label = 'Blue', value = 'blue'},
	{ label = 'Yellow', value = 'yellow'},
	{ label = 'Green', value = 'green'},
	{ label = 'Orange', value = 'orange'},
	{ label = 'Brown', value = 'brown'},
	{ label = 'Purple', value = 'purple'},
	{ label = 'Chrome', value = 'chrome'},
	{ label = 'Gold', value = 'gold'}
}

function GetColors(color)
	local colors = {}
	if color == 'black' then
		colors = {
			{ index = 0 },
			{ index = 1 },
			{ index = 2 },
			{ index = 3 },
			{ index = 1 },
			{ index = 12 },
			{ index = 15 },
			{ index = 16 },
			{ index = 21 },
			{ index = 147 }
		}
	elseif color == 'white' then
		colors = {
			{ index = 106 },
			{ index = 107 },
			{ index = 111 },
			{ index = 112 },
			{ index = 113 },
			{ index = 121 },
			{ index = 122 },
			{ index = 131 },
			{ index = 132 },
			{ index = 134 }
		}
	elseif color == 'grey' then
		colors = {
			{ index = 4 },
			{ index = 5 },
			{ index = 6 },
			{ index = 7 },
			{ index = 8 },
			{ index = 9 },
			{ index = 10 },
			{ index = 13 },
			{ index = 14 },
			{ index = 17 },
			{ index = 18 },
			{ index = 19 },
			{ index = 20 },
			{ index = 22 },
			{ index = 23 },
			{ index = 24 },
			{ index = 25 },
			{ index = 26 },
			{ index = 66 },
			{ index = 93 },
			{ index = 144 },
			{ index = 156 }
		}
	elseif color == 'red' then
		colors = {
			{ index = 27 },
			{ index = 28 },
			{ index = 29 },
			{ index = 30 },
			{ index = 31 },
			{ index = 32 },
			{ index = 33 },
			{ index = 34 },
			{ index = 35 },
			{ index = 39 },
			{ index = 40 },
			{ index = 43 },
			{ index = 44 },
			{ index = 46 },
			{ index = 143 },
			{ index = 150 }
		}
	elseif color == 'pink' then
		colors = {
			{ index = 135 },
			{ index = 136 },
			{ index = 137 }
		}
	elseif color == 'blue' then
		colors = {
			{ index = 54 },
			{ index = 60 },
			{ index = 61 },
			{ index = 62 },
			{ index = 63 },
			{ index = 64 },
			{ index = 65 },
			{ index = 67 },
			{ index = 68 },
			{ index = 69 },
			{ index = 70 },
			{ index = 73 },
			{ index = 74 },
			{ index = 75 },
			{ index = 77 },
			{ index = 78 },
			{ index = 79 },
			{ index = 80 },
			{ index = 82 },
			{ index = 83 },
			{ index = 84 },
			{ index = 85 },
			{ index = 86 },
			{ index = 87 },
			{ index = 127 },
			{ index = 140 },
			{ index = 141 },
			{ index = 146 },
			{ index = 157 }
		}
	elseif color == 'yellow' then
		colors = {
			{ index = 42 },
			{ index = 88 },
			{ index = 89 },
			{ index = 91 },
			{ index = 126 }
		}
	elseif color == 'green' then
		colors = {
			{ index = 49 },
			{ index = 50 },
			{ index = 51 },
			{ index = 52 },
			{ index = 53 },
			{ index = 55 },
			{ index = 56 },
			{ index = 57 },
			{ index = 58 },
			{ index = 59 },
			{ index = 92 },
			{ index = 125 },
			{ index = 128 },
			{ index = 133 },
			{ index = 151 },
			{ index = 152 },
			{ index = 155 }
		}
	elseif color == 'orange' then
		colors = {
			{ index = 36 },
			{ index = 38 },
			{ index = 41 },
			{ index = 123 },
			{ index = 124 },
			{ index = 130 },
			{ index = 138 }
		}
	elseif color == 'brown' then
		colors = {
			{ index = 45 },
			{ index = 47 },
			{ index = 48 },
			{ index = 90 },
			{ index = 94 },
			{ index = 95 },
			{ index = 96 },
			{ index = 97 },
			{ index = 98 },
			{ index = 99 },
			{ index = 100 },
			{ index = 101 },
			{ index = 102 },
			{ index = 103 },
			{ index = 104 },
			{ index = 105 },
			{ index = 108 },
			{ index = 109 },
			{ index = 110 },
			{ index = 114 },
			{ index = 115 },
			{ index = 116 },
			{ index = 129 },
			{ index = 153 },
			{ index = 154 }
		}
	elseif color == 'purple' then
		colors = {
			{ index = 71 },
			{ index = 72 },
			{ index = 76 },
			{ index = 81 },
			{ index = 142 },
			{ index = 145 },
			{ index = 148 },
			{ index = 149 }
		}
	elseif color == 'chrome' then
		colors = {
			{ index = 117 },
			{ index = 118 },
			{ index = 119 },
			{ index = 120 }
		}
	elseif color == 'gold' then
		colors = {
            { index = 37 }, 
            { index = 15 },
			{ index = 15 },
			{ index = 16 },
		}
	end
	return colors
end