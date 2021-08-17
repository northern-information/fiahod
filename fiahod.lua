-- k1: exit   e1: bpm
--
--       e2: volume   e3: plants
---
-- "i will show you fear
--     in a handful of dust"
--
-- @tyleretters & @license, MMXXI

Softclock = include("lib/Softclock")
fn = include("lib/functions")
graphics = include("lib/graphics")
state = include("lib/state")

engine.name = 'Fiahod'

-- Called before init to enable pre-init hook
state.init()

function init()
    print(wat or state.test)
  graphics.init()

  plants = {}
  seed_plants()
  init_encs() -- what is encs?
  for e = 1, 3 do fn.reset_counter(e) end
  -- clocks
  my_clock = Softclock:new(state.ppqn, state.meter)
  -- my_clock:add("a", 1, function() print("whole notes") end)
  -- my_clock:add("b", 1/4, function() print("quarter notes") end)
  my_clock.advance_event = advance_event
  my_clock_id = my_clock:run()
  redraw_clock_id = clock.run(redraw_clock)
end

function init_encs()
  encs = {}
  encs.counters = {}
  encs.wait_length_in_seconds = .5
  encs.indicator = metro.init()
  encs.indicator.count = -1
  encs.indicator.play = 1
  encs.indicator.event = fn.update_lengths
  encs.indicator:start()
end

function seed_plants()
  plants = {}
  if plants == 0 then return end
  for i = 1, state.plant_count do
    local plant = {}
    plant.x = math.random(8, 120)
    plant.age = 0
    plant.height = math.random(0, 10)
    plant.max_height = math.random(15, 40)
    plant.branchs = {}
    
    --print('setting stalk...')
    engine.set_stalk(i, plant.x/64 - 1)
    --print('...set stalk.')
    
    for i = 1, math.random(1, 3) do
      local branch = {}
      branch.y = plant.max_height - math.random(1, 15)
      branch.direction = math.random(1, 2) == 1 and -1 or 1
      branch.head_x_rel = 0
      branch.head_x_rel_max = math.random(4, 7)
      branch.head_y_rel = 0
      branch.head_y_rel_max = math.random(3, 15)
      branch.head_r = 0
      branch.head_l = 15
      branch.fallen = false
      branch.fallen_distance = 0
      plant.branchs[i] = branch
    end
    plant.roots = {}
    for i = 1, math.random(3, 5) do
      local root = {}
      root.x = math.random(-12, 12)
      root.length = 0
      plant.roots[i] = root
    end
    plants[i] = plant
  end
end

local t = 0
function time()
  for k, plant in pairs(plants) do
    plant.age = plant.age + 1
    -- stalk growth
    local new_height = state.inc_height(plant.height, plant.max_height)
    -- can't decide which flavor I like better:
    -- if new_height ~= plant.height then -- only when height changes
    if true then -- always on
        plant.height = new_height
        --print('plucking stalk...')
        engine.pluck_stalk(k, new_height)
        --print('...plucked stalk.')
    end
    -- branches
    for kk, branch in pairs(plant.branchs) do
      if math.random(1, 3) == 1 then 
        local l = 0
        if state.season == 1 or state.season == 4 then -- winter and fall
          l = math.random(1, 2) == 1 and 0 or -1
        elseif state.season == 2 then -- spring
          l = math.random(1, 5)
        end
        branch.head_x_rel = util.clamp(branch.head_x_rel + l, 1, branch.head_x_rel_max)
        branch.head_y_rel = util.clamp(branch.head_y_rel + l, 1, branch.head_y_rel_max)
      end
      if state.month > 9 then
        if not branch.fallen then
          branch.fallen = math.random(1, 2) == 1
        end
        if branch.fallen then
          branch.head_l = util.clamp(branch.head_l - 3, 1, 15)
          branch.fallen_distance = branch.fallen_distance + 5
        end
      end
    end
    -- roots
    for kk, root in pairs(plant.roots) do
      if math.random(1, 3) == 1 then 
        local l = 0
        if state.season == 1 or state.season == 4 then -- winter and fall
          l = math.random(1, 2) == 1 and 0 or -1
        elseif state.season == 2 then -- spring
          l = math.random(1, 5)
        end
        root.length = util.clamp(root.length + l, 1, math.random(5, 14))
      end
    end

  end
end

function advance_event()
  graphics:roll(state.month)
  time()
  screen.ping()
  state.advance()
end

function enc(e, d)
  if encs.counters[e]["this_clock"] ~= nil then
    clock.cancel(encs.counters[e]["this_clock"])
    fn.reset_counter(e)
  end
  update_value(e, d)
  state.screen_dirty = true
  if encs.counters[e]["this_clock"] == nil then
    encs.counters[e]["this_clock"] = clock.run(fn.wait, e)
  end
end

function update_value(e, d)
  if e == 1 then
    local tempo = params:get("clock_tempo")
    params:set("clock_tempo", util.clamp(tempo + d, 20, 300))
    state.message = "BPM: " .. params:get("clock_tempo")
  elseif e == 2 then
    state.volume = util.clamp(state.volume + d, 0, 100)
    engine.set_volume(state.volume)
    state.message = "Volume: " .. state.volume
  elseif e == 3 then
    state.plant_count = util.clamp(state.plant_count + d, 0, 6)
    seed_plants()
  end
end

function redraw_clock()
  while true do
    clock.sleep(1/15)
    if screen_dirty then
      redraw()
      state.screen_dirty = false
    end
  end
end

function redraw()
  graphics:setup()
  graphics:draw_text(state)
  graphics:draw_ground()
  graphics:draw_plants()
  graphics:teardown()
end

function cleanup()
  my_clock:cancel()
end

