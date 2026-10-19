--================
 -- -- Poses  Per -- --
--================
 -- -- Mech Arm -- --
--================
local anim_presets = {
    idle = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -31, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -29.5, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45}, interpolation = 0.35 }, -- Claws open
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45}, interpolation = 0.35 },
        },
    },
    detected = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 20, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -30, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 44.5}, interpolation = 0.35 }, -- Claws wide open
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -44.5}, interpolation = 0.35 },
        },
    },
    pickup_under = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.6, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 19.5, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -30.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.1, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.1, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    pickup_high = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -31, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    pickup_top = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -31, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    closed = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 20, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -30, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    opening = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 20, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -30, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 44.5}, interpolation = 0.35 }, -- Claws wide open
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -44.5}, interpolation = 0.35 },
        },
    },
    death = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 90, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 90, y = 0, z = 0}, interpolation = 0.35 },
        },
    },
    pickup_center = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.2, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 19.5, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    pickup_centerfar = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.2, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 19, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.4, y = 0, z = 0}, interpolation = 0.2 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    throw_ready = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -31, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -29.5, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45.2}, interpolation = 0.35 }, -- Claws closed
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45.2}, interpolation = 0.35 },
        },
    },
    throwing = {
        part = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.4, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -31, y = 0, z = 0}, interpolation = 0.35 },
        },
        part2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0.3, y = 0, z = 0}, interpolation = 0.35 },
        },
        joint2 = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = -29.5, y = 0, z = 0}, interpolation = 0.35 },
        },
        fingerE = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = 45}, interpolation = 0.35 },
        },
        fingerW = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.35 },
            rotation = { vec = {x = 0, y = 0, z = -45}, interpolation = 0.35 },
        },
     },

--================
 -- -- Mech Arm -- --
--================
 -- -- Piston SPS -- --
--================

    retracted = {
        pistonextender = {
            position = { vec = {x = 0, y = 0, z = -0.39}, interpolation = 0.45 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
        },
        pistonhead = {
            position = { vec = {x = 0, y = -0.048, z = 0}, interpolation = 0.545 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
        },
    },
    extended = {
        pistonextender = {
            position = { vec = {x = 0, y = 0, z = 0.6}, interpolation = 0.545 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
        },
        pistonhead = {
            position = { vec = {x = 0, y = -0.028, z = 0}, interpolation = 0.345 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.345 },
        },
    },
        extending = {
        pistonextender = {
            position = { vec = {x = 0, y = 0, z = 0.3}, interpolation = 0.345 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.345 },
        },
        pistonhead = {
            position = { vec = {x = 0, y = -0.014, z = 0}, interpolation = 0.345 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.345 },
        },
    },
    retracting = {
        pistonextender = {
            position = { vec = {x = 0, y = 0, z = -0.2}, interpolation = 0.345 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.345 },
        },
        pistonhead = {
            position = { vec = {x = 0, y = -0.024, z = 0}, interpolation = 0.345 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.345 },
        },
    },

--================
 -- -- Piston SPS -- --
--================
 -- -- Lever Mec -- --
--================

leveron = {
        leverbase = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.45 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
        },
        levertrigger = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
            rotation = { vec = {x = -1, y = 0, z = 0}, interpolation = 0.545 },
        },
    },
leveroff = {
        leverbase = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.45 },
            rotation = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
        },
        levertrigger = {
            position = { vec = {x = 0, y = 0, z = 0}, interpolation = 0.545 },
            rotation = { vec = {x = 1, y = 0, z = 0}, interpolation = 0.545 },
        },
    },
}

--================
 -- -- Lever Mech -- --
--================
 -- -- Function A -- --
--================

function _G.set_custom_animation(self, anim_name)
    local pose = anim_presets[anim_name]
    if not pose then return end

    for bone_name, data in pairs(pose) do
        local override = {}
        if data.position then
            override.position = data.position
        end
        if data.rotation then
            override.rotation = data.rotation
        end
        self.object:set_bone_override(bone_name, override)
    end
end
