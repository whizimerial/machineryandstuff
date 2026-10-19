-- machineryandstuff/init.lua
dofile(minetest.get_modpath("machineryandstuff") .."/entityfunction.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/extrapart.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/mixed.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/function.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/creation.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/item.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/entity.lua")
dofile(minetest.get_modpath("machineryandstuff") .."/itemfunction.lua")

minetest.log("action", "[machineryandstuff] Loaded successfully!")
