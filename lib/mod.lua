local mod = require 'core/mods'

local override_behaviors = function ()
    -- Kind of cheesy, but afaik fiahod is the only app 
    -- using this engine. So it's probably safe.
    -- Anyway, bail here if this isn't fiahod.
    if engine.name ~= "Fiahod" then 
        --print("this isn't fiahod; bye!")
        return 
    end

    -- Now, on with the show!
    -- These are just example values, you can put whatever you want here
    state.year = 1765
    state.ppqn = 96 -- "pulses per quarter note"
    state.meter = 1/4 -- "meter"
end

-- "script_pre_init" is important; this is a norns-specific name
-- "change fiahod state" can be whatever you like
-- set_state just needs to match the name above (before the `= function()`)
mod.hook.register("script_pre_init", "modify fiahod", override_behaviors)
