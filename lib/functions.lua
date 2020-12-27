local fn = {}


function fn.reset_counter(e)
  encs.counters[e] = {
    this_clock = nil,
    length = 0,
    waiting = false
  }
end

function fn.update_lengths()
  for e = 1, 3 do
    if encs.counters[e]["waiting"] then
      encs.counters[e]["length"] = encs.counters[e]["length"] - 1
      screen_dirty = true
    end
  end
end

function fn.wait(e)
  encs.counters[e]["waiting"] = true
  clock.sleep(encs.wait_length_in_seconds)
  encs.counters[e]["waiting"] = false
  encs.counters[e]["this_clock"] = nil
  message = ""
  screen_dirty = true
end

function fn.wrap(n, min, max)
  local y = n
  local d = max - min + 1
  while y > max do
    y = y - d
  end
  while y < min do
    y = y + d
  end
  return y
end

function fn.get_month(n)
  local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
  return months[n]
end

function fn.get_season(n)
  local seasons = { "Winter", "Spring", "Summer", "Fall" }
  return seasons[n]
end

function r()
  norns.script.load(norns.state.script)
end

return fn