local fn = {}

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

function rerun()
  norns.script.load(norns.state.script)
end

return fn