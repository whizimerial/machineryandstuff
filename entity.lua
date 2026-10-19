--==================================================
 -- entity.lua: where all unique semi soloing entity registers
--==================================================
 -- Waterwheel: Generates power with the power of water 
--==================================================

minetest.register_entity("machineryandstuff:water_wheel_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "machineryandstuff_waterwheel.obj",
        textures = {"default_wood.png"},
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        selectionbox = {-0.4375, -0.4375, -0.4375, -0.4250, -0.4250, -0.4250},
        physical = true,
        static_save = true,
    },

    on_step = function(self, dtime)
        local raw_pos = self.object:get_pos()
        if not raw_pos then return end
        
        local pos = vector.round(raw_pos)

        local node_at_pos = minetest.get_node(pos)
        if node_at_pos.name ~= "machineryandstuff:shaft" then
            local drop_item = true
            for _, player in ipairs(minetest.get_connected_players()) do
                if vector.distance(player:get_pos(), pos) < 3 then
                    if minetest.is_creative_enabled(player:get_player_name()) then
                        drop_item = false
                    end
                end
            end

            if drop_item then
                minetest.add_item(pos, "machineryandstuff:water_wheel_item")
            end
            
            self.object:remove()
            return
        end

        local check_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
        local node_under = minetest.get_node(check_pos)

        local meta = minetest.get_meta(pos)

        if node_under.name == "default:water_source" or node_under.name == "default:water_flowing" then
            local rot = self.object:get_rotation()
            rot.z = rot.z + (dtime * 1.5)
            self.object:set_rotation(rot)

            meta:set_int("kinetic_power", 32)
        else
            meta:set_int("kinetic_power", 0)
        end
    end,
})

--==================================================
 -- Waterwheel: Generates power
--==================================================
 -- Gear: Hey look it passes Energy via the teeth 
--==================================================

minetest.register_entity("machineryandstuff:gear_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "machineryandstuff_gear.obj",
        textures = {"machineryandstuff_gear.png"},
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        selectionbox = {-0.5, -0.5, -0.5, -0.5, -0.5, -0.5},
        physical = true,
        static_save = true,
    },

    on_step = function(self, dtime)
        local raw_pos = self.object:get_pos()
        if not raw_pos then return end
        
        local pos = vector.round(raw_pos)

        local node_at_pos = minetest.get_node(pos)
        local meta = minetest.get_meta(pos)
        
        if node_at_pos.name ~= "machineryandstuff:shaft" then
            local drop_item = true
            for _, player in ipairs(minetest.get_connected_players()) do
                if vector.distance(player:get_pos(), pos) < 3 then
                    if minetest.is_creative_enabled(player:get_player_name()) then
                        drop_item = false
                    end
                end
            end

            if drop_item then
                minetest.add_item(pos, "machineryandstuff:gear_item")
            end
            
            self.object:remove()
            return
        end

        local current_power = meta:get_float("kinetic_power") or 0.0
        local shaft_power = meta:get_float("kinetic_power") or 0.0
        local max_incoming_power = shaft_power
        local connection_count = 0

        local side_offsets = {
            {x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0},
            {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0},
            {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1},
        }

        for _, offset in ipairs(side_offsets) do
            local neighbor_pos = vector.add(pos, offset)
            local objects = minetest.get_objects_inside_radius(neighbor_pos, 0.8)
            for _, obj in ipairs(objects) do
                local ent = obj:get_luaentity()
                if ent and ent.name == "machineryandstuff:gear_entity" then
                    connection_count = connection_count + 0.5
                    local neighbor_node_pos = vector.round(obj:get_pos())
                    local neighbor_meta = minetest.get_meta(neighbor_node_pos)
                    local neighbor_power = neighbor_meta:get_float("kinetic_power") or 0.0
                    
                    if neighbor_power - 1.0 > max_incoming_power then
                        max_incoming_power = neighbor_power - 1.0
                    end
                end
            end
        end

        local load_penalty = connection_count * 0.1
        local target_power = math.max(0, max_incoming_power - load_penalty)

        if target_power > 32.0 or (max_incoming_power > 0 and target_power < 0.5) then
            target_power = 0.0
        end

        local transition_rate = 88.0
        if current_power < target_power then
            current_power = math.min(target_power, current_power + (transition_rate * dtime))
        elseif current_power > target_power then
            current_power = math.max(target_power, current_power - (transition_rate * dtime))
        end

        meta:set_float("kinetic_power", current_power)

        local parity = (pos.x + pos.y + pos.z) % 2
        local direction_multiplier = (parity == 0) and 1 or -1

        if current_power > 0.0 then
            local rot = self.object:get_rotation()
            rot.z = rot.z + (dtime * current_power * 0.1 * direction_multiplier)
            self.object:set_rotation(rot)
        end
    end,
})

--==================================================
 -- Gear: Hey look it passes Energy via the teeth 
--==================================================
 -- handcrank: dont spin it too much otherwise itll hurt your wrist 
--==================================================

minetest.register_entity("machineryandstuff:handcrank_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "machineryandstuff_handcrank.obj",
        textures = {"machineryandstuff_handcrank.png"},
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        selectionbox = {-0.4375, -0.4375, -0.4375, -0.4250, -0.4250, -0.4250},
        physical = false,
        static_save = true,
    },

    on_activate = function(self, staticdata)
        local raw_pos = self.object:get_pos()
        if raw_pos then
            local pos = vector.round(raw_pos)
            local node = minetest.get_node(pos)
            if node.name == "machineryandstuff:wallmount" and node.param2 then
                local dir = minetest.facedir_to_dir(node.param2)
                if dir then
                    self.object:set_yaw(minetest.dir_to_yaw(dir))
                end
            end
        end
    end,

    on_step = function(self, dtime)
        local raw_pos = self.object:get_pos()
        if not raw_pos then return end
        
        local pos = vector.round(raw_pos)
        local node_at_pos = minetest.get_node(pos)

        if node_at_pos.name ~= "machineryandstuff:wallmount" then
            local drop_item = true
            for _, player in ipairs(minetest.get_connected_players()) do
                if vector.distance(player:get_pos(), pos) < 3 and minetest.is_creative_enabled(player:get_player_name()) then
                    drop_item = false
                end
            end
            if drop_item then
                minetest.add_item(pos, "machineryandstuff:handcrank_item")
            end
            self.object:remove()
            return
        end

        local meta = minetest.get_meta(pos)
        local current_power = meta:get_float("kinetic_power") or 0.0

        current_power = math.max(0, current_power - (5.0 * dtime))
        meta:set_float("kinetic_power", current_power)

        if current_power > 0 then
            local rot = self.object:get_rotation()
            rot.z = rot.z + (dtime * current_power * 0.3)
            self.object:set_rotation(rot)
        end
    end,
})

--==================================================
 -- handcrank: dont spin it too much otherwise itll hurt your wrist 
--==================================================
 -- mechanical arm: Recreation of Create mod Mechanical Arm
--==================================================

minetest.register_entity("machineryandstuff:mechanicarm", {
    initial_properties = {
        visual = "mesh",
        mesh = "machineryandstuff_mechanicarm.glb",
        textures = {"machineryandstuff_mechanicalarm.png"},
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        selectable = true,
        physical = true,
    },

    on_activate = function(self, staticdata)
        self.state = "idle"
        self.target_item = nil
        self.target_pos = nil
        self.ignore_item = nil
        self.ignore_timer = 0
        self.anim_timer = 0
        self.target_yaw = 0
        self.is_turning = false
        self.is_locked = false
    end,

    on_rightclick = function(self, clicker)
        if not clicker then return end
        local player_pos = clicker:get_pos()
        local entity_pos = self.object:get_pos()
        local wielded = clicker:get_wielded_item()
        local item_name = wielded:get_name()

        local is_wrench = string.find(item_name, "wrench") or string.find(item_name, "screwdriver") or string.find(item_name, "handcrank")

        if is_wrench then
            self.is_locked = false
            if vector.distance(player_pos, entity_pos) <= 2.5 then
                self.target_pos = vector.round(player_pos)
                minetest.chat_send_player(clicker:get_player_name(), "Mechanical Arm: State unlocked & Destination set!")
            end
            return
        end

        if not self.is_locked then
            self.is_locked = true
            minetest.chat_send_player(clicker:get_player_name(), "Mechanical Arm: State LOCKED for debugging.")
        else
            if not self.test_anim_index then
                self.test_anim_index = 1
                self.anim_keys = {
                    "idle", "detected", "pickup_under", "pickup_high", "pickup_top",
                    "pickup_center", "pickup_centerfar", "throw_ready", "throwing", "closed", "opening", "death"
                }
            else
                self.test_anim_index = self.test_anim_index % #self.anim_keys + 1
            end

            local current_anim_name = self.anim_keys[self.test_anim_index]
            set_custom_animation(self, current_anim_name)
            minetest.chat_send_player(clicker:get_player_name(), "Debugging Animation: " .. current_anim_name)
        end
    end,

        on_step = function(self, dtime)
        if self.is_locked then return end 

        local entity_pos = self.object:get_pos()
        if not entity_pos then return end

        local base_pos = vector.round(entity_pos)
        local base_node = minetest.get_node(base_pos)
        local has_power = false

        if base_node.name == "machineryandstuff:mechanicalbase" then
            local meta = minetest.get_meta(base_pos)
            local power = meta:get_float("kinetic_power") or 0.0
            if power > 0.0 then
                has_power = true
            end
        end

        -- If unpowered, force drop any held item right where it is and go idle
        if not has_power then
            if self.target_item and self.target_item:get_pos() then
                if self.target_item.set_velocity then
                    self.target_item:set_velocity({x = 0, y = 0, z = 0})
                end
            end
            self.target_item = nil
            self.state = "idle"
            set_custom_animation(self, "idle")
            return
        end
        
        if self.ignore_item then
            self.ignore_timer = self.ignore_timer + dtime
            if self.ignore_timer > 3.0 then
                self.ignore_item = nil
                self.ignore_timer = 0
            end
        end

        if self.is_turning then
            local current_yaw = self.object:get_yaw()
            local diff = self.target_yaw - current_yaw
            diff = math.atan2(math.sin(diff), math.cos(diff))
            
            if math.abs(diff) < 0.05 then
                self.object:set_yaw(self.target_yaw)
                self.is_turning = false
            else
                self.object:set_yaw(current_yaw + diff * (dtime * 10))
            end
        end

        if self.state == "idle" then
            set_custom_animation(self, "idle")
            if not self.target_pos then return end
            for _, obj in ipairs(minetest.get_objects_inside_radius(entity_pos, 2.5)) do
                local luaentity = obj:get_luaentity()
                if luaentity and luaentity.name == "__builtin:item" and obj ~= self.ignore_item then
                    local item_pos = obj:get_pos()
                    local vel = obj.get_velocity and obj:get_velocity() or {x=0, y=0, z=0}
                    local speed = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z)
                    local is_at_target = false
                    if self.target_pos then
                        if vector.distance(vector.round(item_pos), self.target_pos) < 1.0 then
                            is_at_target = true
                        end
                    end

                    if speed < 0.1 and not is_at_target then
                        local dx = math.abs(item_pos.x - entity_pos.x)
                        local dz = math.abs(item_pos.z - entity_pos.z)
                        local h_dist = math.sqrt(dx*dx + dz*dz)
                        local is_center_base = (dx < 0.5 and dz < 0.5)
                        if not is_center_base then
                            local height_diff = item_pos.y - entity_pos.y
                            local valid = false
                            if height_diff < 0.5 then
                                if h_dist <= 1.4 then
                                    self.chosen_pickup_anim = "pickup_under"
                                    valid = true
                                end
                            elseif height_diff >= 0.5 and height_diff < 1.5 then
                                if h_dist <= 1.8 then
                                    self.chosen_pickup_anim = "pickup_center"
                                    valid = true
                                else
                                    self.chosen_pickup_anim = "pickup_centerfar"
                                    valid = true
                                end
                            else
                                if h_dist <= 1.5 then
                                    self.chosen_pickup_anim = "pickup_high"
                                    valid = true
                                end
                            end

                            if valid then
                                self.target_item = obj
                                self.target_yaw = minetest.dir_to_yaw(vector.direction(entity_pos, item_pos))
                                self.is_turning = true
                                self.anim_timer = 0
                                self.state = "turning_to_item"
                                break
                            end
                        end
                    end
                end
            end
        elseif self.state == "turning_to_item" then
            if not self.target_item or not self.target_item:get_pos() then
                self.state = "idle"
                return
            end
            set_custom_animation(self, "detected")
            if not self.is_turning then
                self.anim_timer = 0
                self.state = "picking_up"
            end
        elseif self.state == "picking_up" then
            self.anim_timer = self.anim_timer + dtime
            if not self.target_item or not self.target_item:get_pos() then
                self.state = "idle"
                return
            end
            local item_pos = self.target_item:get_pos()
            local height_diff = item_pos.y - entity_pos.y
            local dx = math.abs(item_pos.x - entity_pos.x)
            local dz = math.abs(item_pos.z - entity_pos.z)
            local h_dist = math.sqrt(dx*dx + dz*dz)
            if height_diff < 0.5 then
                self.chosen_pickup_anim = "pickup_under"
            elseif height_diff >= 0.5 and height_diff < 1.5 then
                if h_dist <= 1.8 then
                    self.chosen_pickup_anim = "pickup_center"
                else
                    self.chosen_pickup_anim = "pickup_centerfar"
                end
            else
                self.chosen_pickup_anim = "pickup_high"
            end
            set_custom_animation(self, self.chosen_pickup_anim)
            if self.anim_timer >= 2.0 then
                self.state = "holding"
            end
        elseif self.state == "holding" then
            if self.target_item and self.target_item:get_pos() then
                local yaw = self.object:get_yaw()
                local offset_pos = {
                    x = entity_pos.x - math.sin(yaw) * 0.8,
                    y = entity_pos.y + 1.2,
                    z = entity_pos.z + math.cos(yaw) * 0.8
                }

                self.target_item:set_pos(offset_pos)
                if self.target_item.set_velocity then
                    self.target_item:set_velocity({x=0, y=0, z=0})
                end

                set_custom_animation(self, "closed")

                if self.target_pos then
                    self.target_yaw = minetest.dir_to_yaw(vector.direction(entity_pos, self.target_pos))
                    self.is_turning = true
                    self.state = "turning_to_drop"
                end
            else
                self.state = "idle"
            end

        elseif self.state == "turning_to_drop" then
            if not self.target_item or not self.target_item:get_pos() then
                self.state = "idle"
                return
            end

            local yaw = self.object:get_yaw()
            self.target_item:set_pos({
                x = entity_pos.x - math.sin(yaw) * 0.8,
                y = entity_pos.y + 1.2,
                z = entity_pos.z + math.cos(yaw) * 0.8
            })

            if not self.is_turning then
                self.state = "delivering"
            end

        elseif self.state == "delivering" then
            if self.target_pos and self.target_item and self.target_item:get_pos() then
                set_custom_animation(self, "opening")

                local dist_to_target = vector.distance(entity_pos, self.target_pos)
                
                if dist_to_target <= 2.5 then
                    self.target_item:set_pos(self.target_pos)
                    if self.target_item.set_velocity then
                        self.target_item:set_velocity({x=0, y=0, z=0})
                    end
                else
                    set_custom_animation(self, "throwing")
                    local dir = vector.direction(entity_pos, self.target_pos)
                    local throw_velocity = {
                        x = dir.x * 6,
                        y = math.clamp(dir.y * 6 + 3, 2, 8),
                        z = dir.z * 6
                    }
                    if self.target_item.set_velocity then
                        self.target_item:set_velocity(throw_velocity)
                    end
                end
                
                self.ignore_item = self.target_item
                self.target_item = nil
                self.ignore_timer = 0
            end

            self.state = "idle"
        end
    end,
})

--==================================================
 -- mechanical arm: Recreation of Create mod Mechanical Arm
--==================================================
 -- Lever: On, Off as its illogically can generate power
--==================================================

minetest.register_entity("machineryandstuff:lever_entity", {
    initial_properties = {
        visual = "mesh",
        mesh = "machineryandstuff_lever.glb",
        textures = {"machineryandstuff_lever.png"},
        visual_size = {x = 10, y = 10, z = 10},
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        selectionbox = {0, 0, 0, 0, 0, 0},
        physical = false,
        static_save = true,
    },

    on_activate = function(self, staticdata)
        self.state = "leveroff"
        
        -- Ensure yaw sets properly after a brief tick to allow node data to load
        minetest.after(0.05, function()
            if self.object and self.object:get_pos() then
                local raw_pos = self.object:get_pos()
                local pos = vector.round(raw_pos)
                local node = minetest.get_node(pos)
                if node.name == "machineryandstuff:wallmount" and node.param2 then
                    local dir = minetest.facedir_to_dir(node.param2)
                    if dir then
                        self.object:set_yaw(minetest.dir_to_yaw(vector.multiply(dir, -1)))
                    end
                end
            end
        end)
    end,

    on_step = function(self, dtime)
        local raw_pos = self.object:get_pos()
        if not raw_pos then return end
        
        local pos = vector.round(raw_pos)
        local node_at_pos = minetest.get_node(pos)

        if node_at_pos.name ~= "machineryandstuff:wallmount" then
            -- Clean up global skatoosh state when removed
            _G.machinery_skatoosh = _G.machinery_skatoosh or {}
            _G.machinery_skatoosh[minetest.pos_to_string(pos)] = nil

            local drop_item = true
            for _, player in ipairs(minetest.get_connected_players()) do
                if vector.distance(player:get_pos(), pos) < 3 and minetest.is_creative_enabled(player:get_player_name()) then
                    drop_item = false
                end
            end
            if drop_item then
                minetest.add_item(pos, "machineryandstuff:lever_item")
            end
            self.object:remove()
            return
        end

        -- Continually ensure yaw matches wallmount direction
        if node_at_pos.param2 then
            local dir = minetest.facedir_to_dir(node_at_pos.param2)
            if dir then
                self.object:set_yaw(minetest.dir_to_yaw(vector.multiply(dir, -1)))
            end
        end

        local meta = minetest.get_meta(pos)
        local is_on = meta:get_int("lever_on") == 1
        self.state = is_on and "leveron" or "leveroff"

        -- Share state via global "skatoosh" data table
        _G.machinery_skatoosh = _G.machinery_skatoosh or {}
        if is_on then
            _G.machinery_skatoosh[minetest.pos_to_string(pos)] = true
        else
            _G.machinery_skatoosh[minetest.pos_to_string(pos)] = nil
        end

        if _G.set_custom_animation then
            _G.set_custom_animation(self, self.state)
        end
    end,
})