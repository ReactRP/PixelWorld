Config = {}

Config.Marker = {
    ['Cars'] = {
        ['blipScale'] = 1.0,
        ['blipSprite'] = 227,
        ['blipColor'] = 15,
        ['markerSize'] = {['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0 },
        ['markerColor'] = { ['r'] = 180, ['g'] = 233, ['b'] = 123 },
    },
    ['Bikes'] = {
        ['blipScale'] = 1.0,
        ['blipSprite'] = 226,
        ['blipColor'] = 16,
        ['markerSize'] = {['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0 },
        ['markerColor'] = { ['r'] = 180, ['g'] = 233, ['b'] = 123 },
    },
    ['Imports'] = {
        ['blipScale'] = 1.0,
        ['blipSprite'] = 523,
        ['blipColor'] = 13,
        ['markerSize'] = {['x'] = 1.0, ['y'] = 1.0, ['z'] = 1.0 },
        ['markerColor'] = { ['r'] = 180, ['g'] = 233, ['b'] = 123 },
    }
}

Config.AvailableColors = {
    { label = 'Black', index = {0, 0, 0}, buttonColor = 'dark' },
    { label = 'White', index = {255, 255, 255}, buttonColor = 'light' },
    { label = 'Silver', index = {192, 192, 192}, buttonColor = 'white-50' },
    { label = 'Red', index = {255, 0, 0}, buttonColor = 'danger' },
    { label = 'Green', index = {0, 255, 0}, buttonColor = 'success' },
    { label = 'Blue', index = {0, 0, 255}, buttonColor = 'primary' },
    { label = 'Yellow', index = {255, 255, 0}, buttonColor = 'warning' }
}