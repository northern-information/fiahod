-- fear in a handful of dust

Softclock = include("lib/Softclock")
fn = include("lib/functions")
graphics = include("lib/graphics")

function init()
  graphics.init()
  screen_dirty = true
  times_arrow = 0
  season = 0
  my_clock = Softclock:new(8)
  my_clock:add("a", 1, function() print("whole notes") end)
  my_clock:add("b", 1/4, function() print("quarter notes") end)
  my_clock.advance_event = function() advance_event() end
  my_clock_id = my_clock:run()
  redraw_clock_id = clock.run(redraw_clock)
end

function advance_event()
  times_arrow = times_arrow + 1
  if times_arrow % 4 == 1 then
    season = fn.wrap(season + 1, 1, 4)
  end
end

function key(k, z)
  if z == 0 then return end
  if k == 2 then
    times_arrow = 0
    season = 0
  elseif k == 3 then
    times_arrow = 0
    season = 0
  end
end

function enc(e, d)
  params:set("clock_tempo", params:get("clock_tempo") + d)
  screen_dirty = true
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
  screen.move(1, 8)
  screen.text("fear in a handful of dust...")
  graphics:teardown()
end

function cleanup()
  my_clock:cancel()
end