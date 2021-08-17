local state = {}

state.init = function ()
    -- graphics / world
    state.message = ""
    state.year = 1970
    state.month = 4
    state.season = 2
    state.plant_count = 6

    -- audio 
    state.volume = 100
    state.ppqn = 96
    state.meter = 4 

    -- plumbing
    state.screen_dirty = true
    state.times_arrow = 1
end

state.inc_height = function (plant_height, plant_max_height)
    -- winter
    if state.season == 1 then 
        return util.clamp(plant_height - math.random(1, 5), 1, plant_max_height)
    end

    -- spring
    if state.season == 2 then 
        return util.clamp(plant_height + math.random(1, 5), 1, plant_max_height)
    end

    -- summer & fall
    return util.clamp(plant_height + math.random(1, 3), 1, plant_max_height)
end

state.advance = function ()
    state.times_arrow = state.times_arrow + 1
    if state.times_arrow % 4 == 1 then
        state.month = fn.wrap(state.month + 1, 1, 12)
        state.season = math.ceil((fn.wrap(state.month + 1, 1, 12) / 12) * 4)
        if state.month == 1 then
            state.year = state.year + 1
        end
        if state.month == 3 then
            seed_plants()
        end
    end
    state.screen_dirty = true
end

return state
