Config = {}

Config.DisqualifyTime = 5 -- in minutes | Time people have to reach the next checkpoint before they are set as DNF (Did not finish)
Config.DistanceToSign = 50.0 -- distance somebody has to be from a race to be able to sign up for it
Config.RaceTypes = {
    [1] = { ['type'] = 'Circuit', ['min'] = 2, ['max'] = 8 },
    [2] = { ['type'] = 'Sprint', ['min'] = 2, ['max'] = 8 },
    [3] = { ['type'] = 'Drag', ['min'] = 2, ['max'] = 2 },
    [4] = { ['type'] = 'Running', ['min'] = 2, ['max'] = 32 }
}

Config.Blips = {
    ['start'] = {
        ['sprite'] = 127,
        ['color'] = 43,
        ['scale'] = 1.0,
    },

    ['finish'] = {
        ['sprite'] = 358,
        ['color'] = 35,
        ['scale'] = 1.0,
    },

    ['checkpoints'] = {
        ['sprite'] = 570,
        ['color'] = 32,
        ['active'] = 33,
        ['scale'] = 1.0,
    }
}
