local enable_smoke = minetest.settings:get_bool("nssm_server.fire_smoke") ~= false

local function add_particles(pos, multiplier)
    multiplier = multiplier or 1

    minetest.add_particlespawner({
        amount = 100*multiplier,
        time = 1,
        minpos = {x=pos.x-2, y=pos.y-1, z=pos.z-2},
        maxpos = {x=pos.x+2, y=pos.y+4, z=pos.z+2},
        minvel = {x=0, y=0, z=0},
        maxvel = {x=1, y=2, z=1},
        minacc = {x=-0.5,y=0.6,z=-0.5},
        maxacc = {x=0.5,y=0.7,z=0.5},
        minexptime = 2,
        maxexptime = 3,
        minsize = 3,
        maxsize = 5,
        collisiondetection = false,
        vertical = true,
        texture = "default_item_smoke.png",
    })
end

minetest.register_abm({
    label = "Dampen flame",
    nodenames = {"fire:basic_flame"},
    interval = 3,
    chance = 6,
    catch_up = false,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name = "air"})
        if enable_smoke then
            add_particles(pos, 0.1)
        end
    end,
})
