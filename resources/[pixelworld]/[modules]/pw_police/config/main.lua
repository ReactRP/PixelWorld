Config = {}

Config.Blips = {
    ['scale'] = 1.0,
    ['color'] = 3,
    ['type'] = 60,
    ['crime'] = {
        ['scale'] = 1.5,
        ['color'] = 1,
        ['type'] = 188,
    }
}

Config.CrimeBlipDisplay = 10 -- time in seconds to display dispatch occurrences

Config.DisableDispatch = {1,2,4,6,7,8,9,10,12,13,14}

Config.Stations = {
    [1] = {
        ['name'] = "Mission Row PD",
        ['location'] = { ['x'] = 427.26, ['y'] = -981.08, ['z'] = 30.71, ['h'] = 83.75 },
        ['markers'] = {
            ['duty'] = {
                ['coords'] = { ['x'] = 440.8, ['y'] = -976.04, ['z'] = 30.69, ['h'] = 349.59 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['publicRecords'] = {
                ['coords'] = { ['x'] = 441.01, ['y'] = -981.13, ['z'] = 30.69, ['h'] = 350.75 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = true
            },
            ['evidence'] = {
                ['coords'] = { ['x'] = 441.18, ['y'] = -987.23, ['z'] = 30.69, ['h'] = 175.53 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['evidenceStorage'] = {
                ['coords'] = { ['x'] = 481.16, ['y'] = -985.08, ['z'] = 24.91, ['h'] = 128.64 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['evidenceTrash'] = {
                ['coords'] = { ['x'] = 472.8, ['y'] = -990.33, ['z'] = 24.91, ['h'] = 132.9 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['garage'] = {
                ['coords'] = { ['x'] = 454.26, ['y'] = -1019.72, ['z'] = 28.36, ['h'] = 85.05 },
                ['spawnCoords'] = { ['x'] = 438.14, ['y'] = -1019.51, ['z'] = 28.76, ['h'] = 92.05 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 0,
                ['availableVehicles'] = {
                    [0] = { 'charger', 'crownvic', 'taurus' },
                    [2] = { '2020explorer', 'durango', 'tahoe' },
                    [3] = { 'f250', '2015polstang' },
                }
            },
            ['helipad'] = {
                ['coords'] = { ['x'] = 457.66, ['y'] = -984.06, ['z'] = 43.69, ['h'] = 91.36 },
                ['spawnCoords'] = { ['x'] = 447.55, ['y'] = -982.45, ['z'] = 43.79, ['h'] = 140.67 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 0,
                ['availableVehicles'] = { -- array numbers " [#] " are equivalent to grade_levels, so if your grade is 2, you'll be able to access grade 0, 1 and 2 vehicles
                    [0] = { 'maverick' },
                    [4] = { 'hydra', 'cargobob' }
                }
            },
        }
    },
    [2] = {
        ['name'] = "Popular Street PD",
        ['location'] = { ['x'] = 825.1, ['y'] = -1289.89, ['z'] = 28.24, ['h'] = 92.78 },
        ['markers'] = {
            ['duty'] = {
                ['coords'] = { ['x'] = 852.61, ['y'] = -1317.42, ['z'] = 28.18, ['h'] = 86.88 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['publicRecords'] = {
                ['coords'] = { ['x'] = 830.87, ['y'] = -1289.71, ['z'] = 28.18, ['h'] = 271.84 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = true
            },
            ['evidence'] = {
                ['coords'] = { ['x'] = 832.42, ['y'] = -1301.23, ['z'] = 22.49, ['h'] = 100.94 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['evidenceStorage'] = {
                ['coords'] = { ['x'] = 831.77, ['y'] = -1303.8, ['z'] = 22.49, ['h'] = 86.67 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['evidenceTrash'] = {
                ['coords'] = { ['x'] = 837.43, ['y'] = -1306.99, ['z'] = 22.49, ['h'] = 178.44 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['garage'] = {
                ['coords'] = { ['x'] = 855.42, ['y'] = -1297.49, ['z'] = 26.91, ['h'] = 92.52 },
                ['spawnCoords'] = { ['x'] = 855.48, ['y'] = -1292.8, ['z'] = 26.91, ['h'] = 1.69 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 0,
                ['availableVehicles'] = { -- array numbers " [#] " are equivalent to grade_levels, so if your grade is 2, you'll be able to access grade 0, 1 and 2 vehicles
                    [0] = { 'charger', 'crownvic', 'taurus' },
                    [2] = { '2020explorer', 'durango', 'tahoe' },
                    [3] = { 'f250', '2015polstang' },
                }
            },
        }
    },
    [3] = {
        ['name'] = "Sandy Shores Sheriffs Office",
        ['location'] = { ['x'] = 1856.25, ['y'] = 3681.69, ['z'] = 34.27, ['h'] = 222 },
        ['markers'] = {
            ['duty'] = {
                ['coords'] = { ['x'] = 1850.41, ['y'] = 3696.23, ['z'] = 34.25, ['h'] = 298.74 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['publicRecords'] = {
                ['coords'] = { ['x'] = 1852.27, ['y'] = 3687.59, ['z'] = 34.26, ['h'] = 344.46 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = true
            },
            ['evidence'] = {
                ['coords'] = { ['x'] = 1841.13, ['y'] = 3691.48, ['z'] = 34.26, ['h'] = 92.26 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['evidenceStorage'] = {
                ['coords'] = { ['x'] = 1841.74, ['y'] = 3689.92, ['z'] = 34.26, ['h'] = 131.67 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 1.0,
                ['public'] = false
            },
            ['evidenceTrash'] = {
                ['coords'] = { ['x'] = 1842.58, ['y'] = 3692.4, ['z'] = 34.26, ['h'] = 33.56 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 1.0,
                ['public'] = false
            },
            ['garage'] = {
                ['coords'] = { ['x'] = 1864.52, ['y'] = 3696.73, ['z'] = 33.73, ['h'] = 100.06 },
                ['spawnCoords'] = { ['x'] = 1868.52, ['y'] = 3696.24, ['z'] = 33.56, ['h'] = 211.93 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 1,
                ['availableVehicles'] = {
                    [0] = { 'charger', 'crownvic', 'taurus' },
                    [2] = { '2020explorer', 'durango', 'tahoe' },
                    [3] = { 'f250', '2015polstang' },
                }
            },
            ['helipad'] = {
                ['coords'] = { ['x'] = 1802.84, ['y'] = 3709.23, ['z'] = 34.07, ['h'] = 27.91 },
                ['spawnCoords'] = { ['x'] = 1794.8, ['y'] = 3717.83, ['z'] = 35.58, ['h'] = 103.81 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 1,
                ['availableVehicles'] = { -- array numbers " [#] " are equivalent to grade_levels, so if your grade is 2, you'll be able to access grade 0, 1 and 2 vehicles
                    [0] = { 'maverick' },
                    [4] = { 'hydra', 'cargobob' }
                }
            },
        }
    },
    [4] = {
        ['name'] = "Paleto Sheriffs Office",
        ['location'] = { ['x'] = -439.28, ['y'] = 6020.23, ['z'] = 31.49, ['h'] = 319.25 },
        ['markers'] = {
            ['duty'] = {
                ['coords'] = { ['x'] = -455.51, ['y'] = 6012.71, ['z'] = 31.72, ['h'] = 228.85 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['publicRecords'] = {
                ['coords'] = { ['x'] = -446.31, ['y'] = 6015.96, ['z'] = 31.72, ['h'] = 46.54 },
                ['dutyNeeded'] = false,
                ['drawDistance'] = 2.0,
                ['public'] = true
            },
            ['evidence'] = {
                ['coords'] = { ['x'] = -433.82, ['y'] = 5991.32, ['z'] = 31.72, ['h'] = 41.77 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false
            },
            ['evidenceStorage'] = {
                ['coords'] = { ['x'] = -432.14, ['y'] = 6000.59, ['z'] = 31.72, ['h'] = 97.44 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 1.0,
                ['public'] = false
            },
            ['evidenceTrash'] = {
                ['coords'] = { ['x'] = -429.54, ['y'] = 6003.38, ['z'] = 31.72, ['h'] = 343.09 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 1.0,
                ['public'] = false
            },
            ['garage'] = {
                ['coords'] = { ['x'] = -453.14, ['y'] = 6000.59, ['z'] = 31.34, ['h'] = 128.3 },
                ['spawnCoords'] = { ['x'] = -457.98, ['y'] = 6002.34, ['z'] = 31.34, ['h'] = 45.83 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 1,
                ['availableVehicles'] = {
                    [0] = { 'charger', 'crownvic', 'taurus' },
                    [2] = { '2020explorer', 'durango', 'tahoe' },
                    [3] = { 'f250', '2015polstang' },
                }
            },
            ['helipad'] = {
                ['coords'] = { ['x'] = -465.56, ['y'] = 5995.68, ['z'] = 31.25, ['h'] = 131.61 },
                ['spawnCoords'] = { ['x'] = -465.78, ['y'] = 5981.68, ['z'] = 33.31, ['h'] = 286.42 },
                ['dutyNeeded'] = true,
                ['drawDistance'] = 2.0,
                ['public'] = false,
                ['livery'] = 1,
                ['availableVehicles'] = { -- array numbers " [#] " are equivalent to grade_levels, so if your grade is 2, you'll be able to access grade 0, 1 and 2 vehicles
                    [0] = { 'maverick' },
                    [4] = { 'hydra', 'cargobob' }
                }
            },
        }
    }
}

Config.PhotoShoots = {
    [1] = {
        ['playerCoords'] = { ['x'] = 435.56, ['y'] = -990.12, ['z'] = 26.67, ['h'] = 273.81 },
        ['officerCoords'] = { ['x'] = 438.42, ['y'] = -990.05, ['z'] = 26.67, ['h'] = 82.66 },
        ['officerModel'] = -1320879687,
        ['neededProps'] = { "prop_police_id_board", "prop_police_id_text" }
    },
    [2] = {
        ['playerCoords'] = { ['x'] = 833.76, ['y'] = -1280.51, ['z'] = 20.73, ['h'] = 272.6 },
        ['officerCoords'] = { ['x'] = 836.46, ['y'] = -1280.53, ['z'] = 20.73, ['h'] = 89.7 },
        ['officerModel'] = -1320879687,
        ['neededProps'] = { "prop_police_id_board", "prop_police_id_text" }
    }
}

Config.ClosePedsRadius = 35.0 -- area to check for NPCss to snitch on you
Config.AlertChance = 100 -- chance for NPC to call cops on nearby crimes
Config.PossessionTimer = 5 -- max seconds to hold a weapon before NPC snitches on you

Config.AllowedShootingZones = {
    { ['x'] = 12.98, ['y'] = -1099.11, ['z'] = 29.8, ['h'] = 340.56, ['radius'] = 15.0 },
}

Config.DragRadiusCheck = 2.0
Config.SoftRadiusCheck = 2.0