--==================================================
 -- Function: This is the base of all function
--==================================================
 -- Information: Blank
--==================================================

machineryandstuff = {}

function machineryandstuff.spawn_water_wheel(pos, node, placer)
    local entity = minetest.add_entity(pos, "machineryandstuff:water_wheel_entity")
    
    if entity then
        local param2 = node.param2 or 0
        local yaw_table = {
            [0] = 0,
            [1] = math.pi / 2,
            [2] = math.pi,
            [3] = math.pi * 1.5,
        }
        
        if yaw_table[param2] then
            entity:set_yaw(yaw_table[param2])
        end
    end
end

machineryandstuff.spawn_gear = function(pos, node, clicker)
    local entity_pos = vector.new(pos)
    local obj = minetest.add_entity(entity_pos, "machineryandstuff:gear_entity")
    if obj then
        obj:set_yaw(minetest.dir_to_yaw(minetest.facedir_to_dir(node.param2)) or 0)
    end
end

