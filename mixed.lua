--==================================================
 -- lua so entity with nodes that is arent standalone are hera
--==================================================
 -- shaft: visual entity + normal node
--==================================================

local function get_rotation_from_facedir(facedir)
    local yaw_map = {
        [0] = {x = 0, y = 0, z = 0},
        [1] = {x = 0, y = math.pi/2, z = 0},
        [2] = {x = 0, y = math.pi, z = 0},
        [3] = {x = 0, y = math.pi*1.5, z = 0},
    }
    return yaw_map[facedir % 4] or {x = 0, y = 0, z = 0}
end

minetest.register_entity("machineryandstuff:shaft_visual", {
    initial_properties = {
        visual = "mesh",
        mesh = "machineryandstuff_shaftvisualentity.obj",
        textures = {"machineryandstuff_shaftvisualentity.png"},
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {0, 0, 0, 0, 0, 0},
        selectionbox = {0, 0, 0, 0, 0, 0},
        physical = false,
        pointable = false,
        static_save = false,
    },

    on_activate = function(self, staticdata)
        local pos = self.object:get_pos()
        if pos then
            local node = minetest.get_node(pos)
            if node.param2 then
                self.object:set_rotation(get_rotation_from_facedir(node.param2))
            end
        end
    end,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then return end

        local node = minetest.get_node(pos)
        if node.name ~= "machineryandstuff:shaft" then
            self.object:remove()
            return
        end

        local meta = minetest.get_meta(pos)
        local current_power = meta:get_float("kinetic_power") or 0.0

        if current_power > 0.0 then
            local rot = self.object:get_rotation()
            rot.z = rot.z + (dtime * current_power * 0.1)
            self.object:set_rotation(rot)
        end
    end,
})

minetest.register_node("machineryandstuff:shaft", {
    description = "Mechanical Shaft",
    drawtype = "mesh",
    mesh = "machineryandstuff_shaft.obj", 
    tiles = {"machineryandstuff_shaft.png"},
    use_texture_alpha = true,
    
    inventory_image = "machineryandstuff_shaftvisualentity.png",
    wield_image = "machineryandstuff_shaftvisualentity.png",

    paramtype = "light",
    paramtype2 = "facedir",
    sunlight_propagates = true,
    collision_box = {
	type = "fixed",
	fixed = {
		{-0.1250, -0.1250, -0.5000, 0.1250, 0.1250, 0.5000}
	}},
    selection_box = {
	type = "fixed",
	fixed = {
		{-0.1250, -0.1250, -0.5000, 0.1250, 0.1250, 0.5000}
	}},
    groups = {cracky = 3},

    on_place = minetest.rotate_node,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)

        local node = minetest.get_node(pos)
        local ent = minetest.add_entity(pos, "machineryandstuff:shaft_visual")
        if ent and node.param2 then
            ent:set_rotation(get_rotation_from_facedir(node.param2))
        end

        minetest.get_node_timer(pos):start(0.5)
    end,

    on_load = function(pos)
        local found_entity = false
        local node = minetest.get_node(pos)
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.3)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "machineryandstuff:shaft_visual" then
                found_entity = true
                obj:set_rotation(get_rotation_from_facedir(node.param2))
                break
            end
        end
        if not found_entity then
            local ent = minetest.add_entity(pos, "machineryandstuff:shaft_visual")
            if ent and node.param2 then
                ent:set_rotation(get_rotation_from_facedir(node.param2))
            end
        end

        minetest.get_node_timer(pos):start(0.5)
    end,

    on_destruct = function(pos)
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.3)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "machineryandstuff:shaft_visual" then
            obj:remove()
            end
        end
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        local meta = minetest.get_meta(pos)

        local found_entity = false
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.3)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "machineryandstuff:shaft_visual" then
                found_entity = true
                break
            end
        end
        if not found_entity then
            local ent = minetest.add_entity(pos, "machineryandstuff:shaft_visual")
            if ent and node.param2 then
                ent:set_rotation(get_rotation_from_facedir(node.param2))
            end
        end

        local current_power = meta:get_float("kinetic_power") or 0.0

        if current_power < 32.0 then
            local shaft_dir = minetest.facedir_to_dir(node and node.param2 or 0)
            if shaft_dir then
                local pos_forward = vector.add(pos, shaft_dir)
                local pos_backward = vector.subtract(pos, shaft_dir)
                local max_pwr = 0.0

                for _, p in ipairs({pos_forward, pos_backward}) do
                    local n_meta = minetest.get_meta(p)
                    if n_meta then
                        local pwr = n_meta:get_float("kinetic_power") or 0.0
                        if pwr > max_pwr then max_pwr = pwr end
                    end
                end

                current_power = math.max(0, max_pwr - 0.1)
                meta:set_float("kinetic_power", current_power)
            end
        end

        minetest.get_node_timer(pos):start(0.5)
        return true
    end,

    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local item_name = itemstack:get_name()
        
        if item_name == "machineryandstuff:water_wheel_item" then
            if machineryandstuff and machineryandstuff.spawn_water_wheel then
                machineryandstuff.spawn_water_wheel(pos, node, clicker)
                if not (clicker and clicker:is_player() and minetest.is_creative_enabled(clicker:get_player_name())) then
                    itemstack:take_item()
                end
            end
            return itemstack
        elseif item_name == "machineryandstuff:gear_item" then
            if machineryandstuff and machineryandstuff.spawn_gear then
                machineryandstuff.spawn_gear(pos, node, clicker)
                if not (clicker and clicker:is_player() and minetest.is_creative_enabled(clicker:get_player_name())) then
                    itemstack:take_item()
                end
            end
            return itemstack
        end
        
        return nil
    end,
})

--==================================================
 -- shaft: visual entity + normal node
--==================================================
 -- piston: visual entity + normal node
--==================================================

minetest.register_entity("machineryandstuff:piston_entity", {
    physical = false,
    collisionbox = {0, 0, 0, 0, 0, 0},
    visual = "mesh",
    visual_size = {x = 10, y = 10, z = 10},
    mesh = "machineryandstuff_piston.glb",
    textures = {"machineryandstuff_piston.png"},
    
    on_activate = function(self, staticdata)
        self.state = "retracted"
        self.animation_timer = 0
        self.anim_duration = 0.4
        self.is_sticky = false
    end,

    on_step = function(self, dtime)
        local pos = self.object:get_pos()
        if not pos then return end

        local forward_dir = minetest.facedir_to_dir(math.floor(self.object:get_yaw() / (math.pi / 2) + 0.5) % 4)
        local node = minetest.get_node(pos)
        if node and node.param2 then
            forward_dir = minetest.facedir_to_dir(node.param2)
        end

        if not forward_dir then return end

        -- ==========================================
        -- POWER & SKATOOSH EVALUATION
        -- ==========================================
        _G.machinery_skatoosh = _G.machinery_skatoosh or {}
        local back_pos = vector.subtract(pos, forward_dir)
        local back_meta = minetest.get_meta(back_pos)
        local has_default_power = (back_meta:get_float("kinetic_power") or 0.0) > 0.001
        local has_skatoosh = false
        if _G.machinery_skatoosh[minetest.pos_to_string(back_pos)] then
            has_skatoosh = true
        else
            local input_dirs = {
                {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
                {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0},
                {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1}
            }
            for _, d in ipairs(input_dirs) do
                local check_pos = vector.add(pos, d)
                if _G.machinery_skatoosh[minetest.pos_to_string(check_pos)] then
                    has_skatoosh = true
                    break
                end
            end
        end

        self.powered = has_default_power or has_skatoosh

        local unpushable = {"default:obsidian", "default:obsidianbrick", "default:obsidian_block"}
        local breakable = {"default:torch", "bed:bed", "bed:fancy_bed", "default:grass_1", "default:fire"}

        local function is_in_list(name, list)
            for _, item in ipairs(list) do
                if name == item or string.find(name, item) then
                    return true
                end
            end
            return false
        end

        local function can_interact_node(node_name, node_pos)
            if node_name == "air" or node_name == "ignore" or node_name == "machineryandstuff:empty" then
                return false, false
            end
            if is_in_list(node_name, unpushable) then
                return false, false
            end
            if is_in_list(node_name, breakable) then
                return true, true
            end

            local def = minetest.registered_nodes[node_name]
            local meta = minetest.get_meta(node_pos)
            local pushable_meta = meta:get_string("pushable")
            local has_pushable_meta = (pushable_meta ~= "" and pushable_meta ~= "false" and pushable_meta ~= "0")

            if def and def.diggable == false and not has_pushable_meta then
                return false, false
            end

            return true, false
        end

        local orthogonal_offsets = {
            {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
            {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0},
            {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1}
        }

        local front_pos = vector.add(pos, forward_dir)

        -- ==========================================
        -- STATE MACHINE LOGIC
        -- ==========================================

        if self.state == "retracted" then
            if front_pos then
                local front_node = minetest.get_node(front_pos)
                if front_node.name == "machineryandstuff:empty" then
                    minetest.remove_node(front_pos)
                end
            end

            if self.powered then
                local max_push_limit = self.max_push or 14
                local chain_map = {}
                local chain = {}
                local can_push = true
                local node_to_break = nil

                local queue = {}
                for i = 1, max_push_limit do
                    local check_pos = vector.add(pos, vector.multiply(forward_dir, i))
                    local n = minetest.get_node(check_pos)
                    
                    if n.name == "air" or n.name == "ignore" or n.name == "machineryandstuff:empty" then
                        break
                    end

                    local pushable_ok, is_breakable = can_interact_node(n.name, check_pos)
                    if is_breakable then
                        node_to_break = check_pos
                        break
                    elseif not pushable_ok then
                        can_push = false
                        break
                    else
                        local pos_hash = minetest.hash_node_position(check_pos)
                        if not chain_map[pos_hash] then
                            chain_map[pos_hash] = true
                            table.insert(chain, {pos = check_pos, name = n.name, param2 = n.param2})
                            table.insert(queue, check_pos)
                        end
                    end
                end

                local head = 1
                while head <= #queue and can_push do
                    local curr_pos = queue[head]
                    head = head + 1

                    local meta = minetest.get_meta(curr_pos)
                    if meta:get_int("sticky") == 1 then
                        for _, offset in ipairs(orthogonal_offsets) do
                            local adj_pos = vector.add(curr_pos, offset)
                            local pos_hash = minetest.hash_node_position(adj_pos)
                            
                            if not chain_map[pos_hash] and not vector.equals(adj_pos, pos) and not vector.equals(adj_pos, front_pos) then
                                local n = minetest.get_node(adj_pos)
                                if n.name ~= "air" and n.name ~= "ignore" and n.name ~= "machineryandstuff:empty" then
                                    local adj_meta = minetest.get_meta(adj_pos)
                                    if adj_meta:get_int("sticky") == 1 then
                                        local pushable_ok, is_breakable = can_interact_node(n.name, adj_pos)
                                        if is_breakable then
                                            node_to_break = adj_pos
                                            break
                                        elseif pushable_ok then
                                            chain_map[pos_hash] = true
                                            table.insert(chain, {pos = adj_pos, name = n.name, param2 = n.param2})
                                            table.insert(queue, adj_pos)
                                        else
                                            can_push = false
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if can_push then
                    self.state = "extending"
                    self.animation_timer = 0

                    if node_to_break then
                        minetest.remove_node(node_to_break)
                        minetest.sound_play("default_dig_node", { pos = node_to_break, max_hear_distance = 10, gain = 0.5 }, true)
                    end

                    if #chain > 0 then
                        local block_speed = 1.0 / self.anim_duration
                        table.sort(chain, function(a, b)
                            return vector.dot(vector.subtract(a.pos, pos), forward_dir) > vector.dot(vector.subtract(b.pos, pos), forward_dir)
                        end)

                        for _, block in ipairs(chain) do
                            local target_pos = vector.add(block.pos, forward_dir)
                            local target_node = minetest.get_node(target_pos)
                            local _, target_breakable = can_interact_node(target_node.name, target_pos)

                            if target_node.name == "air" or target_node.name == "machineryandstuff:empty" or target_breakable then
                                if target_breakable or target_node.name == "machineryandstuff:empty" then
                                    minetest.remove_node(target_pos)
                                end

                                local meta = minetest.get_meta(block.pos)
                                local meta_table = meta:to_table()

                                minetest.remove_node(block.pos)
                                local obj = minetest.add_entity(block.pos, "machineryandstuff:pushed_block_entity")
                                if obj then
                                    local ent = obj:get_luaentity()
                                    if ent then
                                        ent.node_name = block.name
                                        ent.node_param2 = block.param2
                                        ent.node_meta = meta_table
                                        ent.start_pos = block.pos
                                        ent.target_pos = target_pos
                                        ent.speed = block_speed

                                        local def = minetest.registered_nodes[block.name]
                                        if def then
                                            if def.drawtype == "mesh" and def.mesh then
                                                obj:set_properties({ visual = "mesh", mesh = def.mesh, textures = get_mesh_textures(def.tiles) })
                                            else
                                                obj:set_properties({ visual = "cube", textures = get_cube_textures(def.tiles) })
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        minetest.sound_play("default_wood_footstep", { pos = pos, max_hear_distance = 10, gain = 1.0 }, true)
                    end
                end
            end

        elseif self.state == "extending" then
            self.animation_timer = self.animation_timer + dtime
            if self.animation_timer >= self.anim_duration then
                self.state = "extended"
            end

        elseif self.state == "extended" then
            if front_pos then
                local front_node = minetest.get_node(front_pos)
                if front_node.name == "air" then
                    minetest.set_node(front_pos, {name = "machineryandstuff:empty"})
                end
            end
            
            if not self.powered then
                local pull_node_pos = vector.add(pos, vector.multiply(forward_dir, 2))
                local pull_node = minetest.get_node(pull_node_pos)
                local pushable_ok, _ = can_interact_node(pull_node.name, pull_node_pos)

                local can_pull = false
                local pull_nodes = {}

                if pushable_ok then
                    local pull_meta = minetest.get_meta(pull_node_pos)
                    local is_glued = pull_meta:get_int("sticky") == 1

                    -- Sticky pistons always pull the front block. Normal pistons only pull if the front block is glued.
                    if self.is_sticky or is_glued then
                        can_pull = true
                    end

                    if can_pull then
                        local pull_nodes_map = {}
                        local pos_hash = minetest.hash_node_position(pull_node_pos)
                        pull_nodes_map[pos_hash] = true
                        table.insert(pull_nodes, {pos = pull_node_pos, name = pull_node.name, param2 = pull_node.param2})

                        -- If the front block is glued, pull adjacent glued nodes as a group
                        if is_glued then
                            local queue = {pull_node_pos}
                            local head = 1

                            while head <= #queue do
                                local curr_pos = queue[head]
                                head = head + 1

                                local curr_meta = minetest.get_meta(curr_pos)
                                if curr_meta:get_int("sticky") == 1 then
                                    for _, offset in ipairs(orthogonal_offsets) do
                                        local adj_pos = vector.add(curr_pos, offset)
                                        local adj_hash = minetest.hash_node_position(adj_pos)

                                        if not pull_nodes_map[adj_hash] and not vector.equals(adj_pos, pos) and not vector.equals(adj_pos, front_pos) then
                                            local adj_node = minetest.get_node(adj_pos)
                                            if adj_node.name ~= "air" and adj_node.name ~= "ignore" and adj_node.name ~= "machineryandstuff:empty" then
                                                local adj_meta = minetest.get_meta(adj_pos)
                                                if adj_meta:get_int("sticky") == 1 then
                                                    local adj_pushable, _ = can_interact_node(adj_node.name, adj_pos)
                                                    if adj_pushable then
                                                        pull_nodes_map[adj_hash] = true
                                                        table.insert(pull_nodes, {pos = adj_pos, name = adj_node.name, param2 = adj_node.param2})
                                                        table.insert(queue, adj_pos)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                -- Always transition to retracting when unpowered, whether we pulled a block or left it behind
                self.state = "retracting"
                self.animation_timer = 0

                if can_pull and #pull_nodes > 0 then
                    local block_speed = 1.0 / self.anim_duration
                    table.sort(pull_nodes, function(a, b)
                        return vector.dot(vector.subtract(a.pos, pos), forward_dir) < vector.dot(vector.subtract(b.pos, pos), forward_dir)
                    end)

                    for _, block in ipairs(pull_nodes) do
                        local target_pos = vector.subtract(block.pos, forward_dir)
                        local target_node = minetest.get_node(target_pos)

                        if target_node.name == "air" or target_node.name == "machineryandstuff:empty" then
                            if target_node.name == "machineryandstuff:empty" then
                                minetest.remove_node(target_pos)
                            end

                            local val_meta = minetest.get_meta(block.pos)
                            local meta_table = val_meta:to_table()

                            minetest.remove_node(block.pos)
                            local obj = minetest.add_entity(block.pos, "machineryandstuff:pushed_block_entity")
                            if obj then
                                local ent = obj:get_luaentity()
                                if ent then
                                    ent.node_name = block.name
                                    ent.node_param2 = block.param2
                                    ent.node_meta = meta_table
                                    ent.start_pos = block.pos
                                    ent.target_pos = target_pos
                                    ent.speed = block_speed

                                    local def = minetest.registered_nodes[block.name]
                                    if def then
                                        if def.drawtype == "mesh" and def.mesh then
                                            obj:set_properties({ visual = "mesh", mesh = def.mesh, textures = get_mesh_textures(def.tiles) })
                                        else
                                            obj:set_properties({ visual = "cube", textures = get_cube_textures(def.tiles) })
                                        end
                                    end
                                end
                            end
                        end
                    end
                    minetest.sound_play("default_wood_footstep", { pos = pos, max_hear_distance = 10, gain = 1.0 }, true)
                end
            end

        elseif self.state == "retracting" then
            self.animation_timer = self.animation_timer + dtime
            if self.animation_timer >= self.anim_duration then
                self.state = "retracted"
            end
        end

        local target_anim = self.state
        if _G.set_custom_animation then
            _G.set_custom_animation(self, target_anim)
        end
    end,
})

local function update_piston_entity(pos, node, is_sticky)
    local forward_dir = minetest.facedir_to_dir(node.param2)
    if not forward_dir then return end

    local found_entity = nil
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
        local ent = obj:get_luaentity()
        if ent and ent.name == "machineryandstuff:piston_entity" then
            found_entity = obj
            break
        end
    end

    if not found_entity then
        found_entity = minetest.add_entity(pos, "machineryandstuff:piston_entity")
        if found_entity then
            found_entity:set_yaw(minetest.dir_to_yaw(forward_dir))
        end
    end

    if found_entity then
        local ent = found_entity:get_luaentity()
        ent.is_sticky = is_sticky
        
        ent.max_push = 64
        ent.max_drag = 64
        ent.check_sticky_nodes = true
        
        if is_sticky then
            found_entity:set_properties({
                textures = {"machineryandstuff_stickypiston.png"}
            })
        else
            found_entity:set_properties({
                textures = {"machineryandstuff_piston.png"}
            })
        end
    end

    return found_entity
end

local function check_piston_power(pos, node)
    local forward_dir = minetest.facedir_to_dir(node.param2)
    if not forward_dir then return false end
    
    local back_pos = vector.subtract(pos, forward_dir)
    local front_pos = vector.add(pos, forward_dir)
    
    local all_dirs = {
        {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
        {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0},
        {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1}
    }
    
    local side_positions = {back_pos}
    for _, d in ipairs(all_dirs) do
        if (d.x * forward_dir.x + d.y * forward_dir.y + d.z * forward_dir.z) == 0 then
            table.insert(side_positions, vector.add(pos, d))
        end
    end
    
    local powered = false

    for _, check_pos in ipairs(side_positions) do
        local meta = minetest.get_meta(check_pos)
        if meta then
            local power = meta:get_float("kinetic_power") or 0.0
            if power > 0.001 then
                local neighbor_node = minetest.get_node(check_pos)
                
                if string.find(neighbor_node.name, "generator") then
                    powered = true
                    break
                elseif neighbor_node.param2 then
                    local neighbor_dir = minetest.facedir_to_dir(neighbor_node.param2)
                    if neighbor_dir then
                        local dir_to_piston = vector.direction(check_pos, pos)
                        if vector.equals(neighbor_dir, dir_to_piston) then
                            powered = true
                            break
                        end
                    end
                end
            end
        end
    end

    local front_meta = minetest.get_meta(front_pos)
    if front_meta then
        local front_power = front_meta:get_float("kinetic_power") or 0.0
        if front_power > 0.001 then
            local front_node = minetest.get_node(front_pos)
            if front_node.param2 then
                local front_dir = minetest.facedir_to_dir(front_node.param2)
                if front_dir and vector.equals(front_dir, vector.multiply(forward_dir, -1)) then
                    powered = false
                end
            end
        end
    end

    return powered
end

local function is_node_glued(pos)
    local meta = minetest.get_meta(pos)
    return meta and meta:get_int("sticky") == 1
end

-- ==========================================
-- STANDARD PISTON NODE
-- ==========================================

minetest.register_node("machineryandstuff:piston", {
    description = "Mechanical Piston",
    drawtype = "mesh",
    mesh = "empty.obj",
    tiles = {"machineryandstuff_piston.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 3},
    
    inventory_image = "machineryandstuff_pistonicon.png",
    wield_image = "machineryandstuff_pistonicon.png",

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)
        meta:set_float("stored_power", 0.0)
        minetest.get_node_timer(pos):start(0.2)
    end,
    
    on_load = function(pos)
        local node = minetest.get_node(pos)
        update_piston_entity(pos, node, false)
        minetest.get_node_timer(pos):start(0.2)
    end,

    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local node = minetest.get_node(pos)
        update_piston_entity(pos, node, false)
    end,

    on_destruct = function(pos)
        local node = minetest.get_node(pos)
        if node and node.param2 then
            local forward_dir = minetest.facedir_to_dir(node.param2)
            if forward_dir then
                local front_pos = vector.add(pos, forward_dir)
                local front_node = minetest.get_node(front_pos)
                if front_node.name == "machineryandstuff:empty" then
                    minetest.remove_node(front_pos)
                end
            end
        end

        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "machineryandstuff:piston_entity" then
                obj:remove()
                break
            end
        end
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        if not node or not node.param2 then return true end
        
        local meta = minetest.get_meta(pos)
        local has_power = check_piston_power(pos, node)
        local stored_power = meta:get_float("stored_power") or 0.0

        if has_power then
            -- Quickly charge or maintain full power when supplied
            stored_power = 1.0
        else
            -- Slowly decay power instead of dropping to zero instantly
            stored_power = math.max(0.0, stored_power - (elapsed * 1.5))
        end
        meta:set_float("stored_power", stored_power)

        -- Consider powered if stored power is above a stable threshold (e.g., 0.1)
        local powered = stored_power > 0.1

        local piston_obj = update_piston_entity(pos, node, false)
        if piston_obj then
            local piston_ent = piston_obj:get_luaentity()
            piston_ent.powered = powered
            piston_ent.max_push = 64
            piston_ent.max_drag = 64
        end
        
        return true
    end,
})

-- ==========================================
-- STICKY PISTON NODE
-- ==========================================

minetest.register_node("machineryandstuff:sticky_piston", {
    description = "Sticky Mechanical Piston",
    drawtype = "mesh",
    mesh = "empty.obj",
    tiles = {"machineryandstuff_stickypiston.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    groups = {cracky = 3},
    
    inventory_image = "machineryandstuff_stickypistonicon.png",
    wield_image = "machineryandstuff_stickypistonicon.png",

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_float("kinetic_power", 0.0)
        meta:set_float("stored_power", 0.0)
        minetest.get_node_timer(pos):start(0.2)
    end,
    
    on_load = function(pos)
        local node = minetest.get_node(pos)
        update_piston_entity(pos, node, true)
        minetest.get_node_timer(pos):start(0.2)
    end,

    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local node = minetest.get_node(pos)
        update_piston_entity(pos, node, true)
    end,

    on_destruct = function(pos)
        local node = minetest.get_node(pos)
        if node and node.param2 then
            local forward_dir = minetest.facedir_to_dir(node.param2)
            if forward_dir then
                local front_pos = vector.add(pos, forward_dir)
                local front_node = minetest.get_node(front_pos)
                if front_node.name == "machineryandstuff:empty" then
                    minetest.remove_node(front_pos)
                end
            end
        end

        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
            local ent = obj:get_luaentity()
            if ent and ent.name == "machineryandstuff:piston_entity" then
                obj:remove()
                break
            end
        end
    end,

    on_timer = function(pos, elapsed)
        local node = minetest.get_node(pos)
        if not node or not node.param2 then return true end
        
        local forward_dir = minetest.facedir_to_dir(node.param2)
        if not forward_dir then return true end

        local meta = minetest.get_meta(pos)
        local has_power = check_piston_power(pos, node)
        local stored_power = meta:get_float("stored_power") or 0.0

        if has_power then
            stored_power = 1.0
        else
            stored_power = math.max(0.0, stored_power - (elapsed * 1.5))
        end
        meta:set_float("stored_power", stored_power)

        local powered = stored_power > 0.1

        local piston_obj = update_piston_entity(pos, node, true)
        if piston_obj then
            local piston_ent = piston_obj:get_luaentity()
            piston_ent.powered = powered
            piston_ent.max_push = 64
            piston_ent.max_drag = 64
            
            if piston_ent.is_sticky then
                local front_pos = vector.add(pos, forward_dir)
                if is_node_glued(front_pos) then
                    piston_ent.force_glue = true
                end
            end
        end
        
        return true
    end,
})
