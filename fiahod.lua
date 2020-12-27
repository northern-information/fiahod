-- k1: exit   e1: bpm
--
--       e2: volume   e3: plants
---
-- "i will show you fear
--     in a handful of dust"
--
-- @tyleretters & @license, 2020

Softclock = include("lib/Softclock")
fn = include("lib/functions")
graphics = include("lib/graphics")

function init()
  graphics.init()
  message = ""
  screen_dirty = false
  times_arrow = 1
  year = 1970
  month = 3
  season = 2
  fall = 0
  volume = 100
  plant_count = 6
  plants = {}
  seed_plants()
  -- encs
  encs = {}
  encs.counters = {}
  encs.wait_length_in_seconds = .5
  for e = 1, 3 do fn.reset_counter(e) end
  encs.indicator = metro.init()
  encs.indicator.count = -1
  encs.indicator.play = 1
  encs.indicator.event = fn.update_lengths
  encs.indicator:start()
  -- clocks
  my_clock = Softclock:new(8)
  -- my_clock:add("a", 1, function() print("whole notes") end)
  -- my_clock:add("b", 1/4, function() print("quarter notes") end)
  my_clock.advance_event = function() advance_event() end
  my_clock_id = my_clock:run()
  redraw_clock_id = clock.run(redraw_clock)
end

function seed_plants()
  plants = {}
  fall = 0
  if plants == 0 then return end
  for i = 1, plant_count do
    local plant = {}
    plant.x = math.random(8, 120)
    plant.age = 0
    plant.height = math.random(0, 10)
    plant.max_height = math.random(15, 40)
    plant.necks = {}
    for i = 1, math.random(1, 3) do
      local neck = {}
      neck.y = plant.max_height - math.random(1, 15)
      neck.direction = math.random(1, 2)
      neck.fallen = false
      neck.head_x = 0
      neck.head_y = graphics.ground_y - plant.height
      neck.head_r = 0
      neck.head_l = 15
      plant.necks[i] = neck
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

function time()
  for k, plant in pairs(plants) do
    plant.age = plant.age + 1
    -- stalk growth
    if season == 1 then -- winter
      plant.height = util.clamp(plant.height - math.random(1, 5), 1, 30)
    elseif season == 2 then -- spring
      plant.height = util.clamp(plant.height + math.random(1, 5), 1, 30)
    else -- summer & fall
      plant.height = util.clamp(plant.height + math.random(-3, 3), 1, 30)
    end
    for kk, neck in pairs(plant.necks) do
      if month < 10 then
        neck.head_y = graphics.ground_y - plant.height
      end
    end
    -- roots
    for kk, root in pairs(plant.roots) do
      if math.random(1, 3) == 1 then 
        local l = 0
        if season == 1 or season == 4 then -- winter and fall
          l = math.random(1, 2) == 1 and 0 or -1
        elseif season == 2 then -- spring
          l = math.random(1, 5)
        end
        root.length = util.clamp(root.length + l, 1, math.random(5, 14))
      end
    end
  end
end

function advance_event()
  times_arrow = times_arrow + 1
  graphics:roll()
  time()
  if times_arrow % 4 == 1 then
    month = fn.wrap(month + 1, 1, 12)
    season = math.ceil((fn.wrap(month + 1, 1, 12) / 12) * 4)
    if month == 1 then
      year = year + 1
    end
    if month == 3 then
      seed_plants()
    end
  end
  screen.ping()
  screen_dirty = true
end

function enc(e, d)
  if encs.counters[e]["this_clock"] ~= nil then
    clock.cancel(encs.counters[e]["this_clock"])
    fn.reset_counter(e)
  end
  update_value(e, d)
  screen_dirty = true
  if encs.counters[e]["this_clock"] == nil then
    encs.counters[e]["this_clock"] = clock.run(fn.wait, e)
  end
end

function update_value(e, d)
  if e == 1 then
    local tempo = params:get("clock_tempo")
    params:set("clock_tempo", util.clamp(tempo + d, 20, 300))
    message = "BPM: " .. params:get("clock_tempo")
  elseif e == 2 then
    volume = util.clamp(volume + d, 0, 100)
    message = "Volume: " .. volume
  elseif e == 3 then
    plant_count = util.clamp(plant_count + d, 0, 6)
    message = "Plants: " .. plant_count
    seed_plants()
  end
end

function redraw_clock()
  while true do
    clock.sleep(1/15)
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
end

function redraw()
  graphics:setup()
  graphics:draw_text()
  graphics:draw_ground()
  graphics:draw_plants()
  graphics:teardown()
end

function cleanup()
  my_clock:cancel()
end