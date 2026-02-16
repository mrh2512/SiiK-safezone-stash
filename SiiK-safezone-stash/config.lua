Config = {}

-- Stash config (per-player, private)
Config.Stash = {
    label = 'Safezone Stash',
    slots = 40,
    maxweight = 200000, -- grams (200kg)
}

-- Prop setup (wooden crate)
Config.Prop = {
    model = `prop_container_03mb`,
    freeze = true,
    invincible = true,
}

-- qb-target interaction
Config.Target = {
    icon = 'fas fa-box-open',
    label = 'Open Safezone Stash',
    distance = 2.0,
}

-- Safezones with a stash prop location + safezone radius
-- center = safezone center point
-- stashProp.coords = where the crate sits
Config.Safezones = {
    {
        name = 'Little Soul',
        center = vector3(-496.51, -1003.68, 23.5),
        radius = 65.0,

        stashProp = {
            coords = vector3(-496.53, -1002.84, 23.55),
            heading = 179.65,
        }
    },
    {
        name = 'Paleto',
        center = vector3(-716.26, 5770.02, 17.57),
        radius = 65.0,

        stashProp = {
            coords = vector3(-716.26, 5770.02, 17.57),
            heading = 156.06,
        }
    },
    {
        name = 'Sandy',
        center = vector3(2371.62, 3103.32, 48.0),
        radius = 60.0,

        stashProp = {
            coords = vector3(2371.62, 3103.32, 48.0),
            heading = 154.39,
        }
    },
}
