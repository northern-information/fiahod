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
  screen_dirty = false
  times_arrow = 1
  year = 1970
  month = 3
  season = 2
  volume = 100
  plant_count = 6
  plants = {}
  seed_plants()
  my_clock = Softclock:new(8)
  -- my_clock:add("a", 1, function() print("whole notes") end)
  -- my_clock:add("b", 1/4, function() print("quarter notes") end)
  my_clock.advance_event = function() advance_event() end
  my_clock_id = my_clock:run()
  redraw_clock_id = clock.run(redraw_clock)
end

function seed_plants()
  plants = {}
  if plants == 0 then return end
  for i = 1, plant_count do
    local plant = {}
    plant.x = math.random(8, 120)
    plant.age = 0
    plant.height = math.random(0, 10)
    plant.neck = math.random(20, 30)
    plant.neck_direction = math.random(1, 2)
    plant.root_depth = math.random(3, 9)
    plant.root_node_count = math.random(3, 5)
    plant.root_nodes = {}
    for n = 1, plant.root_node_count do
      local root_node = {}
      root_node.y = math.random(2, 10)
      root_node.direction = math.random(1, 2)
      plant.root_nodes[i] = root_node
    end
    plants[i] = plant
  end
end

function time()
  for k, plant in pairs(plants) do
    plant.age = plant.age + 1
    if season == 1 then -- winter
      plant.height = util.clamp(plant.height - math.random(1, 5), 1, 30)
    elseif season == 2 then -- spring
      plant.height = util.clamp(plant.height + math.random(1, 5), 1, 30)
    else -- summer & fall
      plant.height = util.clamp(plant.height + math.random(-3, 3), 1, 30)
    end
  end
end

function advance_event()
  times_arrow = times_arrow + 1
  time()
  if times_arrow % 4 == 1 then
    month = fn.wrap(month + 1, 1, 12)
    season = math.ceil((fn.wrap(month + 1, 1, 12) / 12) * 4)
    if month == 1 then
      year = year + 1
    end
  end
  screen.ping()
  screen_dirty = true
end

function enc(e, d)
  if e == 1 then
    local tempo = params:get("clock_tempo")
    params:set("clock_tempo", util.clamp(tempo + d, 20, 300))
  elseif e == 2 then
    volume = util.clamp(volume + d, 0, 100)
  elseif e == 3 then
    plant_count = util.clamp(plants + d, 0, 6)
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
  graphics:draw_date()
  graphics:draw_ground()
  graphics:draw_plants()
  graphics:teardown()
end

function cleanup()
  my_clock:cancel()
end