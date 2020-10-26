Config = {}

Config.WaitTime = { -- in seconds | Time between fish bites
    ['min'] = 10,
    ['max'] = 20
}

Config.CatchTime = { -- in seconds | Time to catch a fish
    ['min'] = 1,
    ['max'] = 5
}

Config.Points = {
    ['fishSales'] = {
        ['coords'] = { ['x'] = -1424.63, ['y'] = -665.58, ['z'] = 28.67, ['h'] = 222.75 }, -- Fish Restaurant, Del Perro
        ['drawDistance'] = 2.0,
    },
}

Config.Blips = {
    ['type'] = 371,
    ['name'] = "Fish Selling",
    ['scale'] = 1.0,
    ['color'] = 3
}

Config.Marker = {
	['markerType'] = 2,
	['markerSize']  = { ['x'] = 0.4, ['y'] = 0.4, ['z'] = 0.4 },
	['markerColor'] = { ['r'] = 0, ['g'] = 128, ['b'] = 255 }	
}


Config.FishSales = {
    { ['item'] = 'fishKelp', ['label'] = 'Kelp Greenling', ['price_min'] = 60, ['price_max'] = 90  },
    { ['item'] = 'fishBass', ['label'] = 'White Seabass', ['price_min'] = 100, ['price_max'] = 150  },
    { ['item'] = 'fishYellow', ['label'] = 'Yellowtail', ['price_min'] = 180, ['price_max'] = 240 },
}