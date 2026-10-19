--==================================================
 -- Creation: All non Hybrid note is registered here
--==================================================
 -- Storage: Hopper + Dropper!
--==================================================

minetest.register_node("machineryandstuff:storage", {
    description = "Mechanical Storage",
    drawtype = "mesh",
    mesh = "machineryandstuff_storage.obj",
    tiles = {"machineryandstuff_storage.png"},
    use_texture_alpha = true,
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)
        if meta then
            local inv = meta:get_inventory()
            if inv then
                inv:set_size("main", 32)
            end
            
            meta:set_string("formspec", "size[8,9]" ..
                "list[context;main;0,0;8,4;]" ..
                "list[current_player;main;0,5;8,4;]" ..
                "listring[context;main]" ..
                "listring[current_player;main]")
        end

        minetest.get_node_timer(pos):start(1.0)
    end,
    
    on_load = function(pos)
        minetest.get_node_timer(pos):start(1.0)
    end,

    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        if not meta then return true end
        local inv = meta:get_inventory()
        if not inv then return true end
        return inv:is_empty("main")
    end,

    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        if not meta then return true end
        
        local inv = meta:get_inventory()
        if not inv then return true end
        
        if inv:get_size("main") == 0 then
            inv:set_size("main", 32)
        end

        local node = minetest.get_node(pos)
        if not node or not node.param2 then return true end
        
        local forward_dir = minetest.facedir_to_dir(node.param2)
        if not forward_dir then return true end
        
        local top_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
        for _, object in ipairs(minetest.get_objects_inside_radius(top_pos, 0.6)) do
            if object and not object:is_player() then
                local luaentity = object:get_luaentity()
                if luaentity and luaentity.name == "__builtin:item" then
                    local stack = ItemStack(luaentity.itemstring)
                    if not stack:is_empty() and inv:room_for_item("main", stack) then
                        local leftover = inv:add_item("main", stack)
                        if leftover:is_empty() then
                            object:remove()
                        else
                            luaentity.itemstring = leftover:to_string()
                        end
                        
                        minetest.sound_play("default_place_node", {
                            pos = pos,
                            max_hear_distance = 5,
                            gain = 0.5,
                        }, true)
                    end
                end
            end
        end

        local power_pos = vector.add(pos, forward_dir)
        local power_meta = minetest.get_meta(power_pos)
        local power = power_meta and power_meta:get_float("kinetic_power") or 0.0

        if power <= 0.0 then
            local list = inv:get_list("main")
            for i, stack in ipairs(list) do
                if not stack:is_empty() then
                    local taken = stack:take_item(1)
                    inv:set_stack("main", i, stack)

                    local back_pos = vector.subtract(pos, forward_dir)
                    minetest.add_item(back_pos, taken)

                    minetest.sound_play("default_place_node", {
                        pos = pos,
                        max_hear_distance = 10,
                        gain = 1.0,
                    }, true)
                    break
                end
            end
        end
        
        return true
    end,
})

--==================================================
 -- Storage: Hopper + Dropper!
--==================================================
 -- Conveyorbelt: move things around as im too lazy to make it hybrid
--==================================================

minetest.register_node("machineryandstuff:conveyor_belt", {
    description = "Conveyor Belt",
    drawtype = "mesh",
    mesh = "machineryandstuff_belt.obj",
    use_texture_alpha = true,
    tiles = {
    {
        name = "machineryandstuff_conveyorbelt.png",
        animation = {type = "vertical_frames", aspect_w = 64, aspect_h = 16, length = 1.0},
    },
    "machineryandstuff_conveyorbelt.png",
},
    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
    groups = {cracky = 3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)
        meta:set_int("kinetic_power", 0)
        minetest.get_node_timer(pos):start(0.2)
    end,
    
    on_load = function(pos)
        minetest.get_node_timer(pos):start(0.2)
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        if not node.param2 then return true end

        local dir = minetest.facedir_to_dir(node.param2)
        if not dir then return true end

        local max_power = 0

        local orthogonal_offsets = {
            {x = 1, y = 0, z = 0},
            {x = -1, y = 0, z = 0},
            {x = 0, y = 0, z = 1},
            {x = 0, y = 0, z = -1}
        }

        for _, offset in ipairs(orthogonal_offsets) do
            local neighbor_pos = vector.add(pos, offset)
            local neighbor_node = minetest.get_node(neighbor_pos)
            if neighbor_node.name == "machineryandstuff:conveyor_belt" and neighbor_node.param2 == node.param2 then
                local meta_neighbor = minetest.get_meta(neighbor_pos)
                if meta_neighbor then
                    max_power = math.max(max_power, meta_neighbor:get_int("kinetic_power") or 0)
                end
            elseif neighbor_node.name == "machineryandstuff:shaft" and neighbor_node.param2 then
                local p2 = neighbor_node.param2
                local is_connected = false
                if (p2 == 0 or p2 == 2) and offset.z ~= 0 and offset.x == 0 then
                    is_connected = true
                elseif (p2 == 1 or p2 == 3) and offset.x ~= 0 and offset.z == 0 then
                    is_connected = true
                end

                if is_connected then
                    local meta_neighbor = minetest.get_meta(neighbor_pos)
                    if meta_neighbor then
                        max_power = math.max(max_power, meta_neighbor:get_int("kinetic_power") or 0)
                    end
                end
            end
        end

        local current_power = 0
        if max_power > 1 then
            current_power = max_power - 1
        end

        local meta = minetest.get_meta(pos)
        meta:set_int("kinetic_power", current_power)
        if current_power > 0 then
            meta:set_string("infotext", "Conveyor Power: " .. tostring(current_power))
        else
            meta:set_string("infotext", "Conveyor Power: 0")
        end

        if current_power > 0 then
            local speed = math.min(current_power * 0.25, 2.0)
            local top_pos = {x = pos.x, y = pos.y + 0.5, z = pos.z}

            for _, object in ipairs(minetest.get_objects_inside_radius(top_pos, 0.6)) do
                if object then
                    local vel = object:get_velocity()
                    if vel then
                        object:set_velocity({
                            x = dir.x * speed,
                            y = vel.y,
                            z = dir.z * speed
                        })
                    end
                end
            end
        end

        return true
    end,
})

--==================================================
 -- Conveyorbelt: move things around as im too lazy to make it hybrid
--==================================================
 -- Wall mount: It's not a charger it's for the Well
--==================================================

minetest.register_node("machineryandstuff:wallmount", {
    description = "Wall Mount",
    drawtype = "mesh",
    mesh = "machineryandstuff_wallmount.obj",
    tiles = {"machineryandstuff_wallmount.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    collision_box = {
        type = "fixed",
        fixed = {
            {-0.5000, -0.5000, 0.3125, 0.5000, 0.5000, 0.5000}
        }
    },
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5000, -0.5000, 0.3125, 0.5000, 0.5000, 0.5000}
        }
    },
    groups = {cracky = 3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)
        meta:set_int("lever_on", 0)
        
        local timer = minetest.get_node_timer(pos)
        if timer then
            timer:start(0.5)
        end
    end,

    on_destruct = function(pos)
        -- Clean up global skatoosh state
        if _G.machinery_skatoosh then
            _G.machinery_skatoosh[minetest.pos_to_string(pos)] = nil
        end

        -- Immediately remove any attached entity when the node is destroyed
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
            local ent = obj:get_luaentity()
            if ent and (ent.name == "machineryandstuff:handcrank_entity" or ent.name == "machineryandstuff:lever_entity") then
                obj:remove()
            end
        end
    end,

    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local is_creative = digger and digger:is_player() and minetest.is_creative_enabled(digger:get_player_name())
        
        -- Drop the corresponding item only if creative mode is disabled
        if not is_creative and oldmetadata and oldmetadata.fields then
            if oldmetadata.fields.lever_on ~= nil then
                minetest.add_item(pos, "machineryandstuff:lever_item")
            else
                minetest.add_item(pos, "machineryandstuff:handcrank_item")
            end
        end
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        if not node.param2 then return true end

        local meta = minetest.get_meta(pos)
        local lever_on = (meta:get_int("lever_on") == 1)

        -- Check what entity is currently attached
        local has_lever = false
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "machineryandstuff:lever_entity" then
                has_lever = true
                break
            end
        end

        local current_power = meta:get_float("kinetic_power") or 0.0

        if has_lever then
            if lever_on then
                current_power = 32
            else
                current_power = 0.0
            end
            meta:set_float("kinetic_power", current_power)
        else
            local decay_rate = 0.5
            current_power = math.max(0, current_power - (decay_rate * elapsed))
            meta:set_float("kinetic_power", current_power)
        end

        local forward_dir = minetest.facedir_to_dir(node.param2)
        if forward_dir and current_power > 0 then
            local target_pos = vector.add(pos, forward_dir) 
            local target_meta = minetest.get_meta(target_pos)
            if target_meta then
                local target_power = target_meta:get_float("kinetic_power") or 0.0
                if current_power > target_power then
                    target_meta:set_float("kinetic_power", current_power)
                end
            end
        end

        return true
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local item_name = itemstack:get_name()
        local meta = minetest.get_meta(pos)
        
        local existing_ent = nil
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
            local ent = obj:get_luaentity()
            if ent and (ent.name == "machineryandstuff:handcrank_entity" or ent.name == "machineryandstuff:lever_entity") then
                existing_ent = ent
                break
            end
        end

        -- Placing items if slot is empty
        if not existing_ent then
            if item_name == "machineryandstuff:handcrank_item" then
                minetest.add_entity(pos, "machineryandstuff:handcrank_entity")
                if not (clicker and clicker:is_player() and minetest.is_creative_enabled(clicker:get_player_name())) then
                    itemstack:take_item()
                end
                return itemstack
            elseif item_name == "machineryandstuff:lever_item" then
                local new_obj = minetest.add_entity(pos, "machineryandstuff:lever_entity")
                meta:set_int("lever_on", 0)
                if new_obj and _G.set_custom_animation then
                    _G.set_custom_animation(new_obj:get_luaentity(), "leveroff")
                end
                if not (clicker and clicker:is_player() and minetest.is_creative_enabled(clicker:get_player_name())) then
                    itemstack:take_item()
                end
                return itemstack
            end
        else
            -- Interacting with already placed attachments
            if existing_ent.name == "machineryandstuff:handcrank_entity" then
                meta:set_float("kinetic_power", 500)
                minetest.sound_play("default_wood_footstep", {
                    pos = pos,
                    max_hear_distance = 5,
                    gain = 0.7,
                }, true)
            elseif existing_ent.name == "machineryandstuff:lever_entity" then
                local current_state = meta:get_int("lever_on")
                local new_state = (current_state == 1) and 0 or 1
                meta:set_int("lever_on", new_state)

                if _G.set_custom_animation then
                    _G.set_custom_animation(existing_ent, new_state == 1 and "leveron" or "leveroff")
                end

                minetest.sound_play("default_wood_footstep", {
                    pos = pos,
                    max_hear_distance = 5,
                    gain = 0.7,
                }, true)
            end
        end

        return itemstack
    end,
})


--==================================================
 -- Wall mount: It's not a charger it's for the Well
--==================================================
 -- Mechanical Base: Ooh a flowerpot but for machine
--==================================================

minetest.register_node("machineryandstuff:mechanicalbase", {
    description = "Mechanical Base",
    drawtype = "mesh",
    use_texture_alpha = true,
    mesh = "machineryandstuff_mechanicalbase.obj",
    tiles = {"machineryandstuff_mechanicalbase.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    groups = {cracky = 3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)
        
        local timer = minetest.get_node_timer(pos)
        if timer then
            timer:start(0.5)
        end
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        if not node.param2 then return true end

        local meta = minetest.get_meta(pos)
        local current_power = meta:get_float("kinetic_power") or 0.0

        local decay_rate = 0.5
        current_power = math.max(0, current_power - (decay_rate * elapsed))
        meta:set_float("kinetic_power", current_power)

        local forward_dir = minetest.facedir_to_dir(node.param2)
        if forward_dir and current_power > 0 then
            local target_pos = vector.add(pos, forward_dir)
            local target_meta = minetest.get_meta(target_pos)
            if target_meta then
                local target_power = target_meta:get_float("kinetic_power") or 0.0
                if current_power > target_power then
                    target_meta:set_float("kinetic_power", current_power)
                end
            end
        end

        return true
    end,
})

--==================================================
 -- Mechanical Base: Ooh a flowerpot but for machine
--==================================================
 -- Foresaken: JK it's not for'e'saken it's a Creative Motor
--==================================================

minetest.register_node("machineryandstuff:generator", {
    description = "Generator",
    drawtype = "mesh",
    mesh = "machineryandstuff_generator.obj",
    tiles = {
        {
            name = "machineryandstuff_generator.png",
            animation = {
                type = "vertical_frames",
                aspect_w = 64,
                aspect_h = 32,
                length = 1.0,
            },
        },
    },
    paramtype = "light",
    paramtype2 = "facedir",
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    groups = {cracky = 3},
    
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 32.0)
        meta:set_string("infotext", "Generator Power: 32.0")
        
        local timer = minetest.get_node_timer(pos)
        if timer then
            timer:start(0.5)
        end
    end,

    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 64.5)

        return true 
    end,
})

--==================================================
 -- Foresaken: JK it's not for'e'saken it's a Creative Motor
--==================================================
 -- Reverser: UNO REVERSE!
--==================================================

minetest.register_node("machineryandstuff:Gearshift", {
    description = "Gearshift",
    tiles = {
        "default_stone.png", "default_stone.png", "default_stone.png", 
        "default_stone.png", "default_stone.png", "default_stone.png"
    },
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_speed", 0.0)
        meta:set_int("reversed", 0) -- 0 = normal, 1 = reversed
        minetest.get_node_timer(pos):start(0.5)
    end,
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local item = itemstack:get_name()
        
        -- Check if player is holding a stick to toggle state
        if item == "default:stick" then
            local is_reversed = meta:get_int("reversed") == 1
            if is_reversed then
                meta:set_int("reversed", 0)
                minetest.chat_send_player(clicker:get_player_name(), "Gearshift: Normal Mode")
            else
                meta:set_int("reversed", 1)
                minetest.chat_send_player(clicker:get_player_name(), "Gearshift: Reversed Mode")
            end
        end
    end,

    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        local node = minetest.get_node(pos)
        if not meta then return true end

        -- Determine input and output directions based on facedir/orientation
        -- For simplicity, let's look at front/back axes based on node rotation
        local dir = minetest.facedir_to_dir(node.param2)
        local input_pos = vector.subtract(pos, dir)   -- Coming from the back
        local output_pos = vector.add(pos, dir)      -- Going out the front

        local input_meta = minetest.get_meta(input_pos)
        local incoming_speed = 0.0

        if input_meta then
            incoming_speed = input_meta:get_float("kinetic_speed") or 0.0
        end

        -- Apply reversal if toggled on
        local is_reversed = meta:get_int("reversed") == 1
        local final_speed = incoming_speed
        
        if incoming_speed ~= 0.0 and is_reversed then
            final_speed = -incoming_speed
        end

        meta:set_float("kinetic_speed", final_speed)

        -- Push the modified speed to the output neighbor
        local output_meta = minetest.get_meta(output_pos)
        if output_meta then
            output_meta:set_float("kinetic_speed", final_speed)
            output_meta:set_string("powered_by", minetest.pos_to_string(pos))
        end

        return true
    end,
})
