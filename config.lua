Config = {}

Config.TypeUFO = 'small' -- 'big' / 'small'

Config.Items = {
    { name = 'ufoitem', amount = 1}
    -- { name= 'example', amount = 1}
}

Config.Controls = {
    goUp = 0xDE794E3E, -- Q
    goDown = 0x26E9DC00, -- Z
    turnLeft = 0x7065027D, -- A
    turnRight = 0xB4E465B4, -- D
    goForward = 0x8FD015D8, -- W
    goBackward = 0xD27782E3, -- S
    changeSpeed = 0x8FFC75D6, -- L-Shift
}

Config.Offsets = {
    y = 0.5, -- Forward and backward movement speed multiplier
    z = 0.9, -- Upward and downward movement speed multiplier
    h = 1.5, -- Rotation movement speed multiplier
}

Config.Speeds = {
    -- You can add or edit existing speeds with relative label
    { label = 'Very Slow', speed = 0 },
    { label = 'Slow', speed = 0.5 },
    { label = 'Normal', speed = 2 },
    { label = 'Fast', speed = 10 },
    { label = 'Very Fast', speed = 15 },
    -- { label = 'Max', speed = 29 },
}