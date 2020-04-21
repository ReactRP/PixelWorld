Config = {}

Config.Points = {
	['roadTest'] = {
		['coords'] = { ['x'] = -925.9, ['y'] = -2036.85, ['z'] = 9.4 },
    },
    ['weaponCert'] = {
		['coords'] = { ['x'] = -932.32, ['y'] = -2041.11, ['z'] = 9.44 },
    },
}

Config.Marker = {
	['markerType'] = 2,
	['markerSize']  = { ['x'] = 0.4, ['y'] = 0.4, ['z'] = 0.4 },
	['markerColor'] = { ['r'] = 255, ['g'] = 153, ['b'] = 51 }	
}

Config.Blip = {   
    ['type'] = 525,
    ['name'] = "Licensing Center",
    ['scale'] = 1.0,
    ['color'] = 2,
} 

Config.AvailableVehicleTests = {
    { ['test'] = 'CAR', ['name'] = 'Car License'},
    { ['test'] = 'CDL', ['name'] = 'CDL License'},
}

Config.WeaponsTest = { ['test'] = 'FIREARM', ['name'] = 'Firearms License'}

Config.TestVehicle = {
    ['CAR'] = 'prius',
    ['CDL'] = 'pounder',
}

Config.TestCost = {
    ['CAR'] = 500,
    ['CDL'] = 800,
    ['FIREARM'] = 1000,
}

Config.DriversQuestions = {}

Config.WeaponsQuestions = {}

Config.DrivingTestSpawnPoint = { 
    ['coords'] = { ['x'] = -915.5, ['y'] = -2056.17, ['z'] = 9.3, ['h'] = 170.89 },
}

Config.DrivingTestReturn = { 
    ['coords'] = { ['x'] = -965.26, ['y'] = -2115.72, ['z'] = 8.78, ['h'] = 42.91 },
}

Config.DrivingTestPoint = {
    ['CAR'] = {
        [1] = {
            [1] = { 
                ['coords'] =  { ['x'] = -943.28, ['y'] = -2124.24, ['z'] = 8.83, ['h'] = 226.89 }, -- Car Park Exit Junction
                ['message'] = 'Be careful when pulling out at a junction, turn right here.',
                ['max_speed'] = 40,
            }, -- Then Turn Right
            [2] = { 
                ['coords'] =  { ['x'] = -952.65, ['y'] = -2141.27, ['z'] = 8.45, ['h'] = 137.53 }, -- Stop Sign Junction
                ['message'] = 'Turn left and continue down the road, be careful not to break the speed limit.',
                ['max_speed'] = 40,
            }, -- Then Turn Left
            [3] = { 
                ['coords'] =  { ['x'] = -729.2, ['y'] = -2386.17, ['z'] = 14.21, ['h'] = 228.19 }, -- Next Junction
                ['message'] = 'Turn left, remember to always be careful of other road users.',
                ['max_speed'] = 40,
            }, -- turn left
            [4] = { 
                ['coords'] =  { ['x'] = -506.2, ['y'] = -2148.47, ['z'] = 8.53, ['h'] = 321.44 }, -- Next Junction
                ['message'] = 'Turn right, and follow the road.',
                ['max_speed'] = 40,
            }, -- turn right
            [5] = { 
                ['coords'] = { ['x'] = -239.79, ['y'] = -1843.76, ['z'] = 28.66, ['h'] = 21.18 }, -- Next Junction - Traffic Light, Maze Bank Arena
                ['message'] = 'Turn right - make sure that the traffic light is green.',
                ['max_speed'] = 40,
            }, -- turn right
            [6] = { 
                ['coords'] = { ['x'] = -145.16, ['y'] = -1750.27, ['z'] = 29.63, ['h'] = 318.65 }, -- Next Junction - Traffic Light, Maze Bank Arena
                ['message'] = 'Continue on straight.',
                ['max_speed'] = 40,
            }, -- turn right
            [7] = { 
                ['coords'] = { ['x'] = -40.62, ['y'] = -1626.66, ['z'] = 28.88, ['h'] = 318.23 }, -- Next Junction - Traffic Light Straight Ahead From Last
                ['message'] = 'Always keep check of the vehicles around you.',
                ['max_speed'] = 40,
            }, -- straight
            [8] = { 
                ['coords'] = { ['x'] = 58.12, ['y'] = -1524.54, ['z'] = 28.78, ['h'] = 321.96 }, -- Next Junction - Traffic Light Straight Ahead From Last
                ['message'] = 'Continue on and make sure to get in the left turning lane and the next junction.',
                ['max_speed'] = 40,
            }, -- straight 
            [9] = { 
                ['coords'] = { ['x'] = 136.65, ['y'] = -1414.96, ['z'] = 28.84, ['h'] = 324.67 }, -- Next Junction - Traffic Light Straight Ahead From Last
                ['message'] = 'Turn left, and keep in the right lane once you complete the turn.',
                ['max_speed'] = 40,
            }, -- turn left
            [10] = { 
                ['coords'] = { ['x'] = 116.05, ['y'] = -1355.99, ['z'] = 28.79, ['h'] = 45.11 }, -- Next Junction Short Away From Last
                ['message'] = 'Remember to check the traffic lights when driving.',
                ['max_speed'] = 40,
            }, -- carry on
            [11] = { 
                ['coords'] = { ['x'] = 66.9, ['y'] = -1182.42, ['z'] = 28.85, ['h'] = 3.73 }, -- Next Junction Short Away From Last
                ['message'] = 'Remember to stay at high alert when driving at high speeds, you will need to move to the left when you join the highway to complete the left turn.',
                ['max_speed'] = 75,
            }, -- left onto highway
            [12] = { 
                ['coords'] = { ['x'] = -257.57, ['y'] = -1198.56, ['z'] = 36.7, ['h'] = 87.95 }, -- Highway turn
                ['message'] = 'Get in the leftmost lane, also remember to keep with the flow of traffic.',
                ['max_speed'] = 75,
            }, -- continu
            [13] = { 
                ['coords'] = { ['x'] = -736.82, ['y'] = -1703.06, ['z'] = 28.93, ['h'] = 93.1 }, -- Highway offramp then junction
                ['message'] = 'Turn Right, remember to keep to the speed limit as you are not on the highway anymore.',
                ['max_speed'] = 40,
            }, -- right
            [14] = { 
                ['coords'] = { ['x'] = -650.23, ['y'] = -1487.89, ['z'] = 10.25, ['h'] = 359.68 }, -- next junction (train tunnel behind)
                ['message'] = 'Turn Left, this is the final GPS point until you become a fully certified driver!',
                ['max_speed'] = 40, 
            }, -- left
            [15] = { 
                ['coords'] = { ['x'] = -972.97, ['y'] = -2143.72, ['z'] = 8.48, ['h'] = 224.88 },
            },
        },   
        [2] = {
            [1] = { 
                ['coords'] =  { ['x'] = -943.28, ['y'] = -2124.24, ['z'] = 8.83, ['h'] = 226.89 }, -- Car Park Exit Junction
                ['message'] = 'Be careful when pulling out at a junction, turn right here.',
                ['max_speed'] = 40,
            },-- Turn Right
            [2] = { 
                ['coords'] =  { ['x'] = -952.65, ['y'] = -2141.27, ['z'] = 8.45, ['h'] = 137.53 }, -- Stop Sign Junction
                ['message'] = 'Turn right and continue down the road, be careful not to break the speed limit.',
                ['max_speed'] = 40,
            }, -- Then Turn Right
            [3] = { 
                ['coords'] = { ['x'] = -673.65, ['y'] = -1470.28, ['z'] = 10.04, ['h'] = 302.15 }, 
                ['message'] = 'Turn Left, make sure the light is green.',
                ['max_speed'] = 40,
            }, 
            [4] = { 
                ['coords'] =  { ['x'] = -634.44, ['y'] = -1319.95, ['z'] = 10.17, ['h'] = 339.36 }, 
                ['message'] = 'Keep left, be aware of traffic here.',
                ['max_speed'] = 40,
            }, 
            [5] = { 
                ['coords'] = { ['x'] = -756.3, ['y'] = -1130.15, ['z'] = 10.19, ['h'] = 30.3 }, 
                ['message'] = 'Continue Straight.',
                ['max_speed'] = 40,
            }, 
            [6] = { 
                ['coords'] = { ['x'] = -977.96, ['y'] = -823.36, ['z'] = 15.16, ['h'] = 57.97 }, 
                ['message'] = 'Always be careful of other road users.',
                ['max_speed'] = 40,
            }, 
            [7] = { 
                ['coords'] = { ['x'] = -1115.24, ['y'] = -706.22, ['z'] = 20.26, ['h'] = 41.17 }, 
                ['message'] = 'You are now entering the highway, always stay alert when driving at high speeds.',
                ['max_speed'] = 75,
            }, 
            [8] = { 
                ['coords'] = { ['x'] = -555.83, ['y'] = -546.86, ['z'] = 26.38, ['h'] = 269.06 }, 
                ['message'] = 'Continue on. Keep right.',
                ['max_speed'] = 75,
            }, 
            [9] = { 
                ['coords'] = { ['x'] = -425.81, ['y'] = -1215.84, ['z'] = 20.22, ['h'] = 178.18 }, 
                ['message'] = 'Continue Straight. Keep right.',
                ['max_speed'] = 75,
            }, 
            [10] = { 
                ['coords'] = { ['x'] = -738.32, ['y'] = -1704.11, ['z'] = 28.83, ['h'] = 96.01 }, 
                ['message'] = 'Turn Right.',
                ['max_speed'] = 40,
            }, 
            [11] = { 
                ['coords'] = { ['x'] = -651.21, ['y'] = -1487.64, ['z'] = 10.25, ['h'] = 2.69 }, 
                ['message'] = 'Turn Left.',
                ['max_speed'] = 40,
            }, 
            [12] = { 
                ['coords'] = { ['x'] = -971.68, ['y'] = -2143.42, ['z'] = 8.48, ['h'] = 226.94 },
            },
        },  
        [3] = {
            [1] = { 
                ['coords'] =  { ['x'] = -943.28, ['y'] = -2124.24, ['z'] = 8.83, ['h'] = 226.89 }, -- Car Park Exit Junction
                ['message'] = 'Be careful when pulling out at a junction, turn right here.',
                ['max_speed'] = 40,
            }, -- Then Turn Right
            [2] = { 
                ['coords'] =  { ['x'] = -952.65, ['y'] = -2141.27, ['z'] = 8.45, ['h'] = 137.53 }, -- Stop Sign Junction
                ['message'] = 'Turn left and continue down the road, be careful not to break the speed limit.',
                ['max_speed'] = 40,
            }, -- Then Turn Left
            [3] = { 
                ['coords'] =  { ['x'] = -729.2, ['y'] = -2386.17, ['z'] = 14.21, ['h'] = 228.19 }, -- Next Junction
                ['message'] = 'Turn right, remember to always be careful of other road users.',
                ['max_speed'] = 40,
            }, -- turn right
            [4] = { 
                ['coords'] = { ['x'] = -793.05, ['y'] = -2485.59, ['z'] = 13.1, ['h'] = 88.93 }, 
                ['message'] = 'Turn right onto the Highway, always stay alert when driving at high speeds.',
                ['max_speed'] = 75,
            }, 
            [5] = { 
                ['coords'] = { ['x'] = -670.35, ['y'] = -2092.27, ['z'] = 14.27, ['h'] = 315.35 }, 
                ['message'] = 'Continue Straight.',
                ['max_speed'] = 75,
            }, 
            [6] = { 
                ['coords'] = { ['x'] = -442.15, ['y'] = -1872.39, ['z'] = 18.16, ['h'] = 303.9 }, 
                ['message'] = 'Begin to slow down. Get in the left turning lane.',
                ['max_speed'] = 50,
            }, 
            [7] = { 
                ['coords'] = { ['x'] = -406.72, ['y'] = -1845.98, ['z'] = 20.14, ['h'] = 303.28 }, 
                ['message'] = 'Turn Left. Make sure the light is green!',
                ['max_speed'] = 40,
            }, 
            [8] = { 
                ['coords'] = { ['x'] = -265.06, ['y'] = -1453.89, ['z'] = 30.73, ['h'] = 2.01 }, 
                ['message'] = 'Continue on straight.',
                ['max_speed'] = 40,
            }, 
            [9] = { 
                ['coords'] = { ['x'] = -274.98, ['y'] = -1168.7, ['z'] = 22.6, ['h'] = 3.5 }, 
                ['message'] = 'Turn right.',
                ['max_speed'] = 40,
            }, 
            [10] = { 
                ['coords'] = { ['x'] = -513.48, ['y'] = -1078.37, ['z'] = 22.3, ['h'] = 62.5 }, 
                ['message'] = 'Turn Left. Make sure that the light is green.',
                ['max_speed'] = 40,
            }, 
            [11] = { 
                ['coords'] = { ['x'] = -621.39, ['y'] = -1279.21, ['z'] = 10.26, ['h'] = 147.81 }, 
                ['message'] = 'Keep Straight then turn right.',
                ['max_speed'] = 40,
            }, 
            [12] = { 
                ['coords'] = { ['x'] = -971.68, ['y'] = -2143.42, ['z'] = 8.48, ['h'] = 226.94 },
            },
        },  
    },   
    ['CDL'] = {
        [1] = {
            [1] = { 
                ['coords'] = { ['x'] = -943.28, ['y'] = -2124.24, ['z'] = 8.83, ['h'] = 226.89 }, -- Car Park Exit Junction
                ['message'] = '',
                ['max_speed'] = 40,
            }, -- turn left
            [2] = { 
                ['coords'] = { ['x'] = -511.56, ['y'] = -2127.23, ['z'] = 9.14, ['h'] = 223.27 }, -- NExt Junction
                ['message'] = '',
                ['max_speed'] = 40,
            }, -- straight
            [3] = { 
                ['coords'] = { ['x'] = -237.49, ['y'] = -2166.49, ['z'] = 12.01, ['h'] = 270.49 }, -- NExt Junction
                ['message'] = 'Slow Down in the Carpark!',
                ['max_speed'] = 20,
            }, -- straight
            [4] = { 
                ['coords'] = { ['x'] = -88.48, ['y'] = -2098.57, ['z'] = 16.96, ['h'] = 19.36 }, -- Car Park Before Bridge
                ['message'] = 'Always be mindful of the height of your truck when going under bridges!',
                ['max_speed'] = 20,
            }, -- straight
            [5] = { 
                ['coords'] = { ['x'] = -144.16, ['y'] = -2009.64, ['z'] = 22.24, ['h'] = 77.7 },
                ['message'] = 'Remember, the Truck is heavy - be careful when pulling away from a hill',
                ['max_speed'] = 40,
            }, -- left
            [6] = { 
                ['coords'] = { ['x'] = -166.06, ['y'] = -2073.55, ['z'] = 25.71, ['h'] = 195.46 },
                ['message'] = 'Turn Right, Continue Straight on the Highway.',
                ['max_speed'] = 40,
            }, -- right
            [7] = { 
                ['coords'] = { ['x'] = -299.32, ['y'] = -2107.93, ['z'] = 22.52, ['h'] = 63.61 },
                ['message'] = 'Continue on the Highway.',
                ['max_speed'] = 75,
            }, -- right
            [8] = { 
                ['coords'] = { ['x'] = -748.01, ['y'] = -1775.19, ['z'] = 29.38, ['h'] = 7.39 },
                ['message'] = 'Be careful of the vehicles around you, truck\'s can be dangerous.',
                ['max_speed'] = 40,
            }, -- right
            [9] = { 
                ['coords'] = { ['x'] = -539.86, ['y'] = -984.44, ['z'] = 23.44, ['h'] = 359.51 },
                ['message'] = 'Turn Left',
                ['max_speed'] = 40,
            }, -- right
            [10] = { 
                ['coords'] = { ['x'] = -635.13, ['y'] = -860.35, ['z'] = 24.95, ['h'] = 0.69 },
                ['message'] = 'Be Careful',
                ['max_speed'] = 40,
            }, -- right
            [11] = { 
                ['coords'] = { ['x'] = -624.96, ['y'] = -575.19, ['z'] = 34.92, ['h'] = 358.51 },
                ['message'] = 'Truck\'s require lots of room to be able to accelerate up to speed.',
                ['max_speed'] = 75,
            }, -- right
            [12] = { 
                ['coords'] = { ['x'] = -417.69, ['y'] = -1116.54, ['z'] = 20.82, ['h'] = 182.31 },
                ['message'] = '',
                ['max_speed'] = 75,
            }, -- right
            [13] = { 
                ['coords'] = { ['x'] = -734.22, ['y'] = -1704.3, ['z'] = 29.65, ['h'] = 96.83 },
                ['message'] = 'Turn Right',
                ['max_speed'] = 40,
            }, -- right
            [14] = { 
                ['coords'] = { ['x'] = -650.76, ['y'] = -1496.68, ['z'] = 11.02, ['h'] = 354.31 },
                ['message'] = 'Turn Left',
                ['max_speed'] = 40,
            }, -- right
            [15] = { 
                ['coords'] = { ['x'] = -1027.91, ['y'] = -2088.71, ['z'] = 13.69, ['h'] = 224.6 },
                ['message'] = 'Well Done',
                ['max_speed'] = 40,
            }, -- right
        },
        [2] = {
            [1] = { 
                ['coords'] =  { ['x'] = -943.28, ['y'] = -2124.24, ['z'] = 8.83, ['h'] = 226.89 }, -- Car Park Exit Junction
                ['message'] = 'Be careful when pulling out at a junction, turn right here.',
                ['max_speed'] = 40,
            },-- Turn Right
            [2] = { 
                ['coords'] =  { ['x'] = -952.65, ['y'] = -2141.27, ['z'] = 8.45, ['h'] = 137.53 }, -- Stop Sign Junction
                ['message'] = 'Turn right and continue down the road, be careful not to break the speed limit.',
                ['max_speed'] = 40,
            }, -- Then Turn Right
            [3] = { 
                ['coords'] = { ['x'] = -673.65, ['y'] = -1470.28, ['z'] = 10.04, ['h'] = 302.15 }, 
                ['message'] = 'Turn Left, make sure the light is green.',
                ['max_speed'] = 40,
            }, 
            [4] = { 
                ['coords'] =  { ['x'] = -634.44, ['y'] = -1319.95, ['z'] = 10.17, ['h'] = 339.36 }, 
                ['message'] = 'Keep left, be aware of traffic here.',
                ['max_speed'] = 40,
            }, 
            [5] = { 
                ['coords'] = { ['x'] = -756.3, ['y'] = -1130.15, ['z'] = 10.19, ['h'] = 30.3 }, 
                ['message'] = 'Continue Straight.',
                ['max_speed'] = 40,
            }, 
            [6] = { 
                ['coords'] = { ['x'] = -977.96, ['y'] = -823.36, ['z'] = 15.16, ['h'] = 57.97 }, 
                ['message'] = 'Always be careful of other road users.',
                ['max_speed'] = 40,
            }, 
            [7] = { 
                ['coords'] = { ['x'] = -1115.24, ['y'] = -706.22, ['z'] = 20.26, ['h'] = 41.17 }, 
                ['message'] = 'You need to be aware when entering a highway with a truck since they take time to get up to speed.',
                ['max_speed'] = 75,
            }, 
            [8] = { 
                ['coords'] = { ['x'] = -555.83, ['y'] = -546.86, ['z'] = 26.38, ['h'] = 269.06 }, 
                ['message'] = 'Continue on. Keep right.',
                ['max_speed'] = 75,
            }, 
            [9] = { 
                ['coords'] = { ['x'] = -425.81, ['y'] = -1215.84, ['z'] = 20.22, ['h'] = 178.18 }, 
                ['message'] = 'Continue Straight. Keep right.',
                ['max_speed'] = 75,
            }, 
            [10] = { 
                ['coords'] = { ['x'] = -738.32, ['y'] = -1704.11, ['z'] = 28.83, ['h'] = 96.01 }, 
                ['message'] = 'Turn Right.',
                ['max_speed'] = 40,
            }, 
            [11] = { 
                ['coords'] = { ['x'] = -651.21, ['y'] = -1487.64, ['z'] = 10.25, ['h'] = 2.69 }, 
                ['message'] = 'Turn Left.',
                ['max_speed'] = 40,
            }, 
            [12] = { 
                ['coords'] = { ['x'] = -971.68, ['y'] = -2143.42, ['z'] = 8.48, ['h'] = 226.94 },
            },
        }, 
    }, 
}


