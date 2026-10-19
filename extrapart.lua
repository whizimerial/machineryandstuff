minetest.register_node("machineryandstuff:empty", {
    description = "unobtainable",
    drawtype = "mesh",
    mesh = "empty.obj",
    tiles = {"machineryandstuff_empty.png"},
    paramtype = "light",
    sunlight_propagates = true,
    use_texture_alpha = "clip",
    diggable = false,
    groups = {not_in_creative_inventory = 1},
})

function get_cube_textures(tiles)
    if not tiles then 
        return {"default_cobble.png", "default_cobble.png", "default_cobble.png", 
                "default_cobble.png", "default_cobble.png", "default_cobble.png"} 
    end
    local texs = {}
    for i = 1, 6 do
        local t = tiles[i] or tiles[1]
        if type(t) == "table" then
            texs[i] = t.name or "default_cobble.png"
        else
            texs[i] = t or "default_cobble.png"
        end
    end
    return texs
end

function get_mesh_textures(tiles)
    if not tiles then return {"default_cobble.png"} end
    local texs = {}
    for i, t in ipairs(tiles) do
        if type(t) == "table" then
            texs[i] = t.name or "default_cobble.png"
        else
            texs[i] = t or "default_cobble.png"
        end
    end
    if #texs == 0 then texs = {"default_cobble.png"} end
    return texs
end

minetest.register_entity("machineryandstuff:pushed_block_entity", {
    physical = true,
    collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
    visual = "cube",
    textures = {"default_cobble.png", "default_cobble.png", "default_cobble.png", "default_cobble.png", "default_cobble.png", "default_cobble.png"},
    
    on_activate = function(self, staticdata)
        self.age = 0
        self.target_pos = nil
        self.start_pos = nil
        self.speed = 4.0
        self.node_name = "default:cobble"
        self.node_param2 = 0
        self.node_meta = nil
    end,

    on_step = function(self, dtime)
        self.age = self.age + dtime
        local pos = self.object:get_pos()
        
        if not self.start_pos or not self.target_pos or not pos then
            self.object:remove()
            return
        end

        local direction = vector.direction(pos, self.target_pos)
        local dist = vector.distance(pos, self.target_pos)
        local step = self.speed * dtime

        local move_vector
        if dist < step then
            move_vector = vector.subtract(self.target_pos, pos)
        else
            move_vector = vector.multiply(direction, step)
        end

        local new_pos = vector.add(pos, move_vector)

        -- Player interaction handling
        local objects = minetest.get_objects_inside_radius(pos, 2.0)
        for _, obj in ipairs(objects) do
            if obj:is_player() then
                local p_pos = obj:get_pos()
                
                -- Check if player is standing on top
                local is_on_top = (p_pos.y >= pos.y + 0.35 and p_pos.y <= pos.y + 0.65) and
                                  (math.abs(p_pos.x - pos.x) <= 0.55) and
                                  (math.abs(p_pos.z - pos.z) <= 0.55)

                if is_on_top then
                    -- Get player controls (works for both PC keys and Mobile touch joystick)
                    local controls = obj:get_player_control()
                    local is_moving_input = controls.up or controls.down or controls.left or controls.right

                    if not is_moving_input then
                        -- Standing still: carry them smoothly along with the block
                        obj:set_pos({
                            x = p_pos.x + move_vector.x,
                            y = p_pos.y,
                            z = p_pos.z + move_vector.z
                        })
                    else
                        -- Walking: simulate speed addition/reduction based on look direction and input
                        local yaw = obj:get_look_horizontal()
                        local walk_dir = {x = 0, z = 0}
                        
                        if controls.up then
                            walk_dir.x = walk_dir.x + math.sin(yaw)
                            walk_dir.z = walk_dir.z + math.cos(yaw)
                        end
                        if controls.down then
                            walk_dir.x = walk_dir.x - math.sin(yaw)
                            walk_dir.z = walk_dir.z - math.cos(yaw)
                        end
                        if controls.left then
                            walk_dir.x = walk_dir.x - math.cos(yaw)
                            walk_dir.z = walk_dir.z + math.sin(yaw)
                        end
                        if controls.right then
                            walk_dir.x = walk_dir.x + math.cos(yaw)
                            walk_dir.z = walk_dir.z - math.sin(yaw)
                        end

                        -- Blend block movement with player walking input (adds or reduces speed)
                        local final_move_x = move_vector.x + (walk_dir.x * 0.05)
                        local final_move_z = move_vector.z + (walk_dir.z * 0.05)

                        obj:set_pos({
                            x = p_pos.x + final_move_x,
                            y = p_pos.y,
                            z = p_pos.z + final_move_z
                        })
                    end
                else
                    -- Retro-style side push collision check (gets stuck inside -> snaps out closest side)
                    local e_min_x, e_max_x = pos.x - 0.5, pos.x + 0.5
                    local e_min_y, e_max_y = pos.y - 0.5, pos.y + 0.5
                    local e_min_z, e_max_z = pos.z - 0.5, pos.z + 0.5

                    local p_min_x, p_max_x = p_pos.x - 0.3, p_pos.x + 0.3
                    local p_min_y, p_max_y = p_pos.y, p_pos.y + 1.7
                    local p_min_z, p_max_z = p_pos.z - 0.3, p_pos.z + 0.3

                    if p_max_x > e_min_x and p_min_x < e_max_x and
                       p_max_y > e_min_y and p_min_y < e_max_y and
                       p_max_z > e_min_z and p_min_z < e_max_z then
                        
                        local push_right = (pos.x + 0.8) - p_pos.x
                        local push_left = p_pos.x - (pos.x - 0.8)
                        local push_back = (pos.z + 0.8) - p_pos.z
                        local push_front = p_pos.z - (pos.z - 0.8)

                        local min_dist = math.min(push_right, push_left, push_back, push_front)
                        local target_p_pos = {x = p_pos.x, y = p_pos.y, z = p_pos.z}

                        if min_dist == push_right then
                            target_p_pos.x = pos.x + 0.8
                        elseif min_dist == push_left then
                            target_p_pos.x = pos.x - 0.8
                        elseif min_dist == push_back then
                            target_p_pos.z = pos.z + 0.8
                        elseif min_dist == push_front then
                            target_p_pos.z = pos.z - 0.8
                        end

                        obj:set_pos(target_p_pos)
                    end
                end
            end
        end

        if dist < step then
            self.object:set_pos(self.target_pos)
            minetest.set_node(self.target_pos, {name = self.node_name, param2 = self.node_param2})
            
            if self.node_meta then
                local target_meta = minetest.get_meta(self.target_pos)
                target_meta:from_table(self.node_meta)
            end

            minetest.sound_play("default_place_node", {
                pos = self.target_pos,
                max_hear_distance = 10,
                gain = 0.5,
            }, true)

            self.object:remove()
        else
            self.object:move_to(new_pos)
        end
    end,
})
