--[[

Obliterate NSSM monsters that approach Mob Inhibitor nodes

By default, an admin-only inhibitor node is provided.

Optionally, other nodes can benefit from the inhibition effect.

--]]

nssm_server = {}

local inhibition_radius = tonumber(minetest.settings:get("nssm.inhibition_radius")) or 8

-- Recommended --->   protector:protect,protector:protect2,cityblock:cityblock
local inhibition_nodes = minetest.settings:get("nssm.inhibition_nodes") or ""

inhibition_nodes = inhibition_nodes:split(",")

-- Always include the inhibitor node
inhibition_nodes[#inhibition_nodes+1] = "nssm:mob_inhibitor"

minetest.register_privilege("mob_inhibitor", {description="Allows placing mob inhibitor blocks"})

minetest.register_node("nssm_server:mob_inhibitor", {
    description = "NSSM Monster Ward",
    tiles = {
        "default_obsidian.png^proud_soul_fragment.png", -- top
        "default_obsidian.png^greedy_soul_fragment.png", --under
        "default_obsidian.png^phoenix_fire_bomb.png", -- back
        "default_obsidian.png^phoenix_fire_bomb.png", -- side
        "default_obsidian.png^phoenix_fire_bomb.png", --side
        "default_obsidian.png^phoenix_fire_bomb.png", --front
    },
    groups = {cracky = 1, level = 4, not_in_creative_inventory = 1},
    sounds = default.node_sound_stone_defaults(),
    drop = "",
    on_place = function(itemstack, placer, pointed_thing)
        local playername = placer:get_player_name()
        local privs = minetest.get_player_privs(playername)

        if privs.mob_inhibitor then
            return minetest.item_place(itemstack, placer, pointed_thing)
        else
            minetest.log("action", playername.." prevented from using nssm_server:mob_inhibitor")
            return
        end
    end
})

-- Remove from main NSSM
minetest.register_alias("nssm:mob_inhibitor", "nssm_server:mob_inhibitor")

function nssm_server:inhibit_effect(pos,radius)
    radius = radius or 1

    minetest.add_particlespawner({
            amount = 80,
            time = 1,
            minpos = {x=pos.x-radius/2, y=pos.y-radius/2, z=pos.z-radius/2}, 
            maxpos = {x=pos.x+radius/2, y=pos.y+radius/2, z=pos.z+radius/2}, 
            minlevel = {x=-0, y=-0, z=-0}, 
            maxlevel = {x=1, y=1, z=1}, 
            minacc = {x=-0.5,y=5,z=-0.5}, 
            maxacc = {x=0.5,y=5,z=0.5}, 
            minexptime = 0.1, 
            maxexptime = 1, 
            minsieze = 3,
            maxsieze = 4,
            collisiondetection = false,
            texture = "morparticle.png^[colorize:yellow:200^[colorize:white:100"
    })

    minetest.sound_play("nssm_inhibit", {
            pos = pos,
            max_hear_distance = inhibition_radius*2,
    })
end

-- Inhibition block - place in spawn buildings on servers
minetest.register_abm({
    label = "Monster Inhibition Block",
    nodenames = inhibition_nodes,
    interval = 1,
    chance = 1,
    catch_up = false,
    action = function(pos, node, active_object_count, active_object_count_wider)
        local obj, istring, lua_entity

        for _,obj in pairs(minetest.get_objects_inside_radius(pos , inhibition_radius)) do
            if not obj:is_player() and obj:get_luaentity() then
                lua_entity = obj:get_luaentity()
                istring = lua_entity["name"]

                -- We got a name, it's nssm and it is monster mob
                if istring and istring:sub(1,5) == "nssm:" and lua_entity.type == "monster" then
                    nssm_server:inhibit_effect(obj:get_pos())
                    obj:remove()
                end
            end
        end
    end,
})
