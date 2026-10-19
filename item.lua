--==================================================
 -- items: preserved only for items
--==================================================
 -- waterwheel: technically a hybrid of item and entity
--==================================================

minetest.register_craftitem("machineryandstuff:water_wheel_item", {
    description = "Water Wheel",
    inventory_image = "machineryandstuff_waterwheelicon.png", -- Replace with your item icon texture name later
    stack_max = 99,
})

--==================================================
 -- waterwheel: technically a hybrid of item and entity
--==================================================
 -- gear: another hybrid of item and entity
--==================================================

minetest.register_craftitem("machineryandstuff:gear_item", {
    description = "Gear",
    inventory_image = "machineryandstuff_gearicon.png", -- Replace with your gear icon texture name later
    stack_max = 99,
})

--==================================================
 -- gear: another hybrid of item and entity
--==================================================
 -- handcrank: another hybrid of item and entity
--==================================================

minetest.register_craftitem("machineryandstuff:handcrank_item", {
    description = "Hand Crank",
    inventory_image = "machineryandstuff_handcrankicon.png",
    wield_image = "machineryandstuff_handcrankicon.png",
    stack_max = 99,
})

--==================================================
 -- handcrank: another hybrid of item and entity
--==================================================
 -- informational wrench: create mod style but for my mod
--==================================================

minetest.register_tool("machineryandstuff:informationalwrench", {
    description = "Information Wrench",
    inventory_image = "machineryandstuff_Informationalwrench.png",
    stack_max = 1,
    on_place = function(itemstack, placer, pointed_thing)
        local player_name = placer:get_player_name()

        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local meta = minetest.get_meta(pos)
            local power = meta:get_float("kinetic_power") or 0.0
            minetest.chat_send_player(player_name, "Node Kinetic Power: " .. tostring(power))
            
        elseif pointed_thing.type == "object" then
            local obj = pointed_thing.ref
            if obj and obj:is_player() == false then
                local luaentity = obj:get_luaentity()
                if luaentity then
                    local power = luaentity.kinetic_power or 0.0
                    minetest.chat_send_player(player_name, "Entity Kinetic Power: " .. tostring(power))
                end
            end
        end

        return itemstack
    end,
})

--==================================================
 -- informational wrench: create mod style but for my mod
--==================================================
 -- mechanicalarm: one of the best hybrid by far
--==================================================

minetest.register_craftitem("machineryandstuff:mechanicarm_item", {
    description = "Mechanical Arm",
    inventory_image = "machineryandstuff_mechanicalarmicon.png",
    stack_max = 99,
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local node_pos = pointed_thing.under
        local node = minetest.get_node(node_pos)

        if node.name ~= "machineryandstuff:mechanicalbase" then
            if placer and placer:is_player() then
                minetest.chat_send_player(placer:get_player_name(), "Mechanical Arm can only be placed on a Mechanical Base!")
            end
            return itemstack
        end

        local spawn_pos = {
            x = node_pos.x + 0, 
            y = node_pos.y, 
            z = node_pos.z + 0
        }

        minetest.add_entity(spawn_pos, "machineryandstuff:mechanicarm")
        
        if not (placer and placer:is_player() and minetest.is_creative_enabled(placer:get_player_name())) then
            itemstack:take_item()
        end

        return itemstack
    end,
})

--==================================================
 -- mechanicalarm: one of the best hybrid by far
--==================================================
 -- Hyper Glue: Wonder why it's called Hyper Glue
--==================================================

minetest.register_craftitem("machineryandstuff:glue", {
    description = "Hyper Glue",
    inventory_image = "machineryandstuff_glue.png",
    wield_image = "machineryandstuff_glue.png",
    stack_max = 99,

    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local node = minetest.get_node(pos)

            if node.name ~= "air" and node.name ~= "ignore" and node.name ~= "machineryandstuff:empty" then
                local meta = minetest.get_meta(pos)
                meta:set_int("sticky", 1)

                minetest.sound_play("default_place_node", {
                    pos = pos,
                    max_hear_distance = 10,
                    gain = 0.8,
                }, true)

                minetest.chat_send_player(placer:get_player_name(), "Block glued!")

                local player_name = placer:get_player_name()
                if not (minetest.is_creative_enabled and minetest.is_creative_enabled(player_name)) then
                    itemstack:take_item()
                end

                return itemstack
            end
        end
        return itemstack
    end,
})

--==================================================
 -- Hyper Glue: Wonder why it's called Hyper Glue
--==================================================
 -- Lever: Hybrid
--==================================================

minetest.register_craftitem("machineryandstuff:lever_item", {
    description = "Lever",
    inventory_image = "machineryandstuff_lever.png",
    wield_image = "machineryandstuff_lever.png",
    stack_max = 99,
})

--==================================================
 -- Lever: Hybrid
--==================================================
 -- End
--==================================================
