Config = {}

Config.AllLicenses = {
    'VEHICLE',
    'FIREARM',
}

Config.LicenseLabels = {
    ['FIREARM'] = 'Firearms License',
    ['VEHICLE'] = 'Vehicle License'
}

Config.Points = {
	['roadTest'] = {
        [1] = { ['coords'] = { ['x'] = 233.69, ['y'] = 367.76, ['z'] = 106.14, ['h'] = 343.0 }},
    },
    ['licenseCheck'] = { -- License Checks Courthouse
        [1] = { ['coords'] = { ['x'] = 237.967, ['y'] = -414.145, ['z'] = 47.948, ['h'] = 243.306 }},
        [2] = { ['coords'] = { ['x'] = -551.449, ['y'] = -190.431, ['z'] = 38.22, ['h'] = 33.469 }},
    }
}

Config.Blips = {   
    ['roadTest'] = {
        ['type'] = 525,
        ['name'] = "DMV",
        ['scale'] = 1.0,
        ['color'] = 3,
    },
}

Config.TestVehicle = 'asea'

Config.TestCost = 500

Config.DriversQuestions = {}

Config.DrivingTestSpawnPoints = {  -- Just so if everyone and their dog does a driving test at once
    [1] = { ['x'] = 221.79, ['y'] = 380.55, ['z'] = 106.51, ['h'] = 162.73 },
    [2] = { ['x'] = 230.32, ['y'] = 385.71, ['z'] = 106.50, ['h'] = 75.11  },
    [3] = { ['x'] = 213.88, ['y'] = 390.06, ['z'] = 106.84, ['h'] = 165.14 },
    [4] = { ['x'] = 209.03, ['y'] = 390.23, ['z'] = 107.01, ['h'] = 180.43 },
    [5] = { ['x'] = 204.96, ['y'] = 390.85, ['z'] = 107.20, ['h'] = 170.52 },
    [6] = { ['x'] = 200.67, ['y'] = 391.55, ['z'] = 107.46, ['h'] = 170.81 },
    [7] = { ['x'] = 208.63, ['y'] = 375.37, ['z'] = 107.04, ['h'] = 338.26 },
    [8] = { ['x'] = 205.02, ['y'] = 376.21, ['z'] = 107.22, ['h'] = 346.89 },
    [9] = { ['x'] = 199.58, ['y'] = 377.48, ['z'] = 107.59, ['h'] = 336.59 },
    [10] = {['x'] = 195.21, ['y'] = 379.33, ['z'] = 107.95, ['h'] = 345.31 },
    [11] = {['x'] = 190.22, ['y'] = 379.63, ['z'] = 108.29, ['h'] = 346.52 },
}

Config.DrivingTestReturn = { 
    ['coords'] = { ['x'] = 214.129, ['y'] = 380.738, ['z'] = 106.761, ['h'] = 40.184 },
}

Config.DrivingTestPoint = {
    [1] = {
        [1] = { 
            ['coords'] = { ['x'] = 215.692, ['y'] = 368.461, ['z'] = 105.862, ['h'] = 161.544 },
            ['message'] = 'Be careful when pulling out at a junction, take a right turn here.',
            ['max_speed'] = 40,
        },
        [2] = { 
            ['coords'] =  { ['x'] = 97.587, ['y'] = 341.596, ['z'] = 112.18, ['h'] = 123.093 }, 
            ['message'] = 'Continue Straight and keep left, making sure to yield for pedestrians and stop at the stop sign.',
            ['max_speed'] = 40,
        },
        [3] = { 
            ['coords'] = { ['x'] = -40.82, ['y'] = 52.045, ['z'] = 71.854, ['h'] = 163.461 },
            ['message'] = 'Turn left, make sure that the light is green.',
            ['max_speed'] = 40,
        }, 
        [4] = { 
            ['coords'] = { ['x'] = 105.335, ['y'] = -23.595, ['z'] = 67.447, ['h'] = 250.185 }, 
            ['message'] = 'Turn right here.',
            ['max_speed'] = 40,
        }, 
        [5] = { 
            ['coords'] = { ['x'] = 33.768, ['y'] = -258.549, ['z'] = 47.229, ['h'] = 160.948 }, 
            ['message'] = 'Continue on straight - make sure that the traffic light is green.',
            ['max_speed'] = 40,
        },
        [6] = { 
            ['coords'] = { ['x'] = -57.646, ['y'] = -528.206, ['z'] = 39.93, ['h'] = 161.733 }, 
            ['message'] = 'Turn Left.',
            ['max_speed'] = 40,
        },
        [7] = { 
            ['coords'] = { ['x'] = 422.109, ['y'] = -557.643, ['z'] = 28.324, ['h'] = 323.79 },
            ['message'] = 'You are entering the Los Santos Freeway - You should now be driving at highway speeds.',
            ['max_speed'] = 75,
        },
        [8] = { 
            ['coords'] = { ['x'] = 1125.63, ['y'] = 372.636, ['z'] = 91.009, ['h'] = 316.801 },
            ['message'] = 'Turn Left - Keep an eye on your speed, the limit has lowered now you are off the freeway.',
            ['max_speed'] = 40,
        },
        [9] = { 
            ['coords'] = { ['x'] = 774.549, ['y'] = 185.492, ['z'] = 81.193, ['h'] = 93.449 },
            ['message'] = 'Well Done - You Have Nearly Passed.',
            ['max_speed'] = 40,
        },
        [10] = { 
            ['coords'] = { ['x'] = 439.269, ['y'] = 292.546, ['z'] = 102.549, ['h'] = 71.983 }, 
            ['message'] = 'Remember to check the traffic lights when driving.',
            ['max_speed'] = 40,
        }, 
    },  
    [2] = {
        [1] = { 
            ['coords'] = { ['x'] = 215.692, ['y'] = 368.461, ['z'] = 105.862, ['h'] = 161.544 },
            ['message'] = 'Be careful when pulling out at a junction, take a left turn here.',
            ['max_speed'] = 40,
        },
        [2] = { 
            ['coords'] = { ['x'] = 236.604, ['y'] = 346.763, ['z'] = 105.123, ['h'] = 247.078 },
            ['message'] = 'Turn Right.',
            ['max_speed'] = 40,
        },
        [3] = { 
            ['coords'] = { ['x'] = 204.042, ['y'] = 222.987, ['z'] = 105.133, ['h'] = 158.852 },
            ['message'] = 'Turn right again, make sure no pedestrians are crossing.',
            ['max_speed'] = 40,
        }, 
        [4] = { 
            ['coords'] = { ['x'] = -201.05, ['y'] = 267.91, ['z'] = 91.627, ['h'] = 85.64 }, 
            ['message'] = 'Continue on straight here.',
            ['max_speed'] = 40,
        }, 
        [5] = { 
            ['coords'] = { ['x'] = -522.068, ['y'] = 258.768, ['z'] = 82.637, ['h'] = 84.089 },
            ['message'] = 'Continue on straight - make sure that the traffic light is green.',
            ['max_speed'] = 40,
        },
        [6] = { 
            ['coords'] = { ['x'] = -641.206, ['y'] = 278.222, ['z'] = 80.859, ['h'] = 84.044 },
            ['message'] = 'Keep Right Here.',
            ['max_speed'] = 40,
        },
        [7] = { 
            ['coords'] = { ['x'] = -854.193, ['y'] = 425.719, ['z'] = 86.609, ['h'] = 1.685 }, 
            ['message'] = 'Turn right, make sure to stop at the stop sign.',
            ['max_speed'] = 40,
        },
        [8] = { 
            ['coords'] = { ['x'] = -476.667, ['y'] = 662.334, ['z'] = 144.674, ['h'] = 281.308 },
            ['message'] = 'Be careful of pedestrians.',
            ['max_speed'] = 40,
        },
    },  
    [2] = {
        [1] = { 
            ['coords'] = { ['x'] = 215.692, ['y'] = 368.461, ['z'] = 105.862, ['h'] = 161.544 },
            ['message'] = 'Be careful when pulling out at a junction, take a left turn here.',
            ['max_speed'] = 40,
        },
        [2] = { 
            ['coords'] = { ['x'] = 236.604, ['y'] = 346.763, ['z'] = 105.123, ['h'] = 247.078 }, 
            ['message'] = 'Turn Right.',
            ['max_speed'] = 40,
        },
        [3] = { 
            ['coords'] = { ['x'] = 213.374, ['y'] = 219.196, ['z'] = 105.172, ['h'] = 162.079 }, 
            ['message'] = 'Turn left, make sure no pedestrians are crossing.',
            ['max_speed'] = 40,
        }, 
        [4] = { 
            ['coords'] = { ['x'] = 488.014, ['y'] = 86.353, ['z'] = 96.201, ['h'] = 254.759 }, 
            ['message'] = 'Continue on straight here.',
            ['max_speed'] = 40,
        }, 
        [5] = { 
            ['coords'] = { ['x'] = 775.969, ['y'] = -48.401, ['z'] = 80.223, ['h'] = 238.008 }, 
            ['message'] = 'Continue on straight - make sure that the traffic light is green.',
            ['max_speed'] = 40,
        },
        [6] = { 
            ['coords'] = { ['x'] = 1205.791, ['y'] = -352.762, ['z'] = 68.621, ['h'] = 168.326 }, 
            ['message'] = 'Turn Right Here.',
            ['max_speed'] = 40,
        },
        [7] = { 
            ['coords'] = { ['x'] = 673.767, ['y'] = -386.897, ['z'] = 41.201, ['h'] = 140.228 },
            ['message'] = 'Turn right, make sure to stop at the traffic light. Make sure to continue to follow all traffic laws.',
            ['max_speed'] = 40,
        },
        [8] = { 
            ['coords'] = { ['x'] = 250.561, ['y'] = -217.917, ['z'] = 53.565, ['h'] = 66.516 },
            ['message'] = 'Turn Right.',
            ['max_speed'] = 40,
        },
        [8] = { 
            ['coords'] = { ['x'] = 409.31, ['y'] = 269.407, ['z'] = 102.648, ['h'] = 342.316 }, 
            ['message'] = 'Turn Left Here - Head Back to the DMV.',
            ['max_speed'] = 40,
        },
    },  
}


