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

function rerun()
  norns.script.load(norns.state.script)
end

return fn