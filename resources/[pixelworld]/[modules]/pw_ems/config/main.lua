Config = {}

Config.Blip = {
    ['blipType'] = 61,
    ['blipScale'] = 1.0,
    ['blipColor'] = 3,
    ['blipName'] = "Hospital"
}

Config.Marker = {
    ['markerType'] = 27,
    ['markerDraw']  = 10.0,
    ['markerSize']  = { ['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0 }  
}

Config.Hospitals = {
    -- Central Los Santos
    [1] = {   
        ['location'] = { 
            ['coords'] = { ['x'] = 355.08, ['y'] = -1416.19, ['z'] = 32.51 },
            ['marker'] = false, ['duty'] = false, ['public'] = false
        },
        ['dutySignon'] = { 
            ['coords'] = { ['x'] = 366.52, ['y'] = -1420.03, ['z'] = 32.51 },
            ['marker'] = true, ['duty'] = false, ['public'] = false
        },
        ['changingRoom'] = { 
            ['coords'] = { ['x'] = 360.27, ['y'] = -1425.63, ['z'] = 32.51 },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['vehicleGarage'] = {
            ['coords'] = { ['x'] = 301.24, ['y'] = -1429.79, ['z'] = 29.8 },
            ['spawnCoords'] = { ['x'] = 298.94, ['y'] = -1433.84, ['z'] = 29.8, ['h'] = 232.27 },
            ['availableVehicles'] = {
                [0] = { "ambulance" },
                [4] = { "t20" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['helipadGarage'] = {
            ['coords'] = { ['x'] = 393.88, ['y'] = -1434.49, ['z'] = 29.45, ['h'] = 233.78 },
            ['spawnCoords'] = { ['x'] = 399.42, ['y'] = -1438.99, ['z'] = 29.52, ['h'] = 315.99 },
            ['availableVehicles'] = {
                [0] = { "maverick" },
                [4] = { "hydra" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
    },
    
    -- Paleto
    [2] =  {   
        ['location'] = { 
            ['coords'] = { ['x'] = -247.63, ['y'] = 6332.45, ['z'] = 32.43 }, 
            ['marker'] = false, ['duty'] = false, ['public'] = false
        },
        ['dutySignon'] = {
            ['coords'] = { ['x'] = -263.24, ['y'] = 6312.16, ['z'] = 32.43 },
            ['marker'] = true, ['duty'] = false, ['public'] = false
        },
        ['changingRoom'] = { 
            ['coords'] = { ['x'] = -264.73, ['y'] = 6325.01, ['z'] = 32.43 },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['vehicleGarage'] = {
            ['coords'] = { ['x'] = -245.7, ['y'] = 6333.43, ['z'] = 32.49 },
            ['spawnCoords'] = { ['x'] = -242.11, ['y'] = 6336.43, ['z'] = 32.19, ['h'] = 225.24 },
            ['availableVehicles'] = {
                [0] = { "ambulance" },
                [4] = { "t20" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
    },

    -- Sandy
    [3] = {   
        ['location'] = {
            ['coords'] = { ['x'] = 1839.34, ['y'] = 3671.84, ['z'] = 34.28 },
            ['marker'] = false, ['duty'] = false, ['public'] = false,
        },
        ['dutySignon'] = { 
            ['coords'] = { ['x'] = 1829.32, ['y'] = 3681.7, ['z'] = 34.27 },
            ['marker'] = true, ['duty'] = false, ['public'] = false, 
        },
        ['changingRoom'] = { 
            ['coords'] = { ['x'] = 1839.17, ['y'] = 3689.32, ['z'] = 34.27 },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['vehicleGarage'] = { 
            ['coords'] = { ['x'] = 1839.53, ['y'] = 3700.58, ['z'] = 33.97, ['h'] = 305.51 },
            ['spawnCoords'] = { ['x'] = 1839.53, ['y'] = 3700.58, ['z'] = 33.97, ['h'] = 305.51 },
            ['availableVehicles'] = {
                [0] = { "ambulance" },
                [4] = { "t20" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['helipadGarage'] = { 
            ['coords'] = { ['x'] = 1802.84, ['y'] = 3709.23, ['z'] = 34.07, ['h'] = 27.91 },
            ['spawnCoords'] = { ['x'] = 1794.8, ['y'] = 3717.83, ['z'] = 35.58, ['h'] = 103.81 },
            ['availableVehicles'] = {
                [0] = { "maverick" },
                [4] = { "hydra" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
    },

    -- Pillbox 
    [4] = {   
        ['location'] = {
            ['coords'] = { ['x'] = 359.76, ['y'] = -590.29, ['z'] = 28.65 },
            ['marker'] = false, ['duty'] = false, ['public'] = false
        },
        ['dutySignon'] = {
            ['coords'] = { ['x'] = 339.66, ['y'] = -582.06, ['z'] = 28.79 },
            ['marker'] = true, ['duty'] = false, ['public'] = false
        },
        ['changingRoom'] = {
            ['coords'] = { ['x'] = 336.08, ['y'] = -580.68, ['z'] = 28.79 },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['vehicleGarage'] = {
            ['coords'] = { ['x'] = 316.08, ['y'] = -556.45, ['z'] = 28.74, ['h'] = 263.12 },
            ['spawnCoords'] = { ['x'] = 316.32, ['y'] = -553.51, ['z'] = 28.74, ['h'] = 273.89 },
            ['availableVehicles'] = {
                [0] = { "ambulance" },
                [4] = { "t20" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
        ['helipadGarage'] = {
            ['coords'] = { ['x'] = 340.4, ['y'] = -585.79, ['z'] = 74.17, ['h'] = 264.96 },
            ['spawnCoords'] = { ['x'] = 352.78, ['y'] = -587.76, ['z'] = 74.27, ['h'] = 347.28 },
            ['availableVehicles'] = {
                [0] = { "maverick" },
                [4] = { "hydra" }
            },
            ['marker'] = true, ['duty'] = true, ['public'] = false
        },
    },

}