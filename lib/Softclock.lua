--  module for creating collections of soft-timers based on a single fast "superclock"
--
-- @module Softclock
-- @dev v1.0.1
-- @author ezra & tyleretters

local Softclock = {}

--- instantiate a new softclock
-- @tparam[opt] number ppqn the number of pulses per quarter note of this superclock
-- @tparam[opt] number meter number of quarter notes per measure
function Softclock:new(ppqn, meter)
  local s = setmetatable({}, { __index = Softclock })
  s.ppqn = ppqn ~= nil and ppqn or 128
  s.meter = meter ~= nil and meter or 4
  s.clock_id = nil
  s.clocks = {}
  s.transport = 0
  s.is_playing = true
  s.advance_event = nil -- advance callback
  s.pulse_event = nil -- pulse callback
  return s
end

--- start running the softclock
-- @return integer clock id
function Softclock:run()
  self.clock_id = clock.run(self.pulse, self)
  return self.clock_id
end

--- advance all subclocks in this softclock one by pulse
-- @tparam table s this softclock
function Softclock.pulse(s)
  while true do
    clock.sync(1/s.ppqn)
    -- really wish there was a continue statment...
    if s.is_playing then
      s.transport = s.transport + 1
      if s.advance_event ~= nil and s.transport % (s.ppqn * s.meter) == 1 then
        s.advance_event(s.transport)
      end
      for id, clock in pairs(s.clocks) do
        if clock.is_playing then
          -- print might need to check if not nil for race conditions with remove()
          clock.phase = clock.phase + 1
          if clock.phase > (clock.division * s.ppqn * s.meter) then
              clock.phase = clock.phase - (clock.division * s.ppqn * s.meter)
              clock.event(clock.phase)
          end
        end
      end
      if s.pulse_event then
        s.pulse_event()
      end
    end
  end
end 

--- add a "subclock" to this softclock
-- @tparam string id unique identifier for this subclock
-- @tparam number division the division of the subclock
-- @tparam function event callback event
-- @tparam[opt] boolean is the subclock playing?
function Softclock:add(id, division, event, playing)
    local c = {} -- new subclock table
    c.division = division
    c.event = event
    c.is_playing = (playing == nil) and true or playing
    c.phase = 0
    self.clocks[id] = c
end

--- remove a subclock from this softclock
-- @tparam string unique identifier for this subclock
function Softclock:remove(id)
  self.clocks[id] = nil
end

--- change the ppqn of the softclock while running
-- @tparam number ppqn the ppqn of the superclock
function Softclock:change_ppqn(ppqn)
  self.ppqn = ppqn
end

--- cancel the softclock
function Softclock:cancel()
  clock.cancel(self.clock_id)
end

--- start the softclock
function Softclock:start()
  self.is_playing = true
end

--- stop the softclock
function Softclock:stop()
  self.is_playing = false
end

--- toggle the softclock
function Softclock:toggle()
  self.is_playing = not self.is_playing
end

--- start a subclock
-- @tparam string id unique identifier for this subclock
function Softclock:start_subclock(id)
  self.clocks[id].is_playing = true
end

--- stop a subclock
-- @tparam string id unique identifier for this subclock
function Softclock:stop_subclock(id)
  self.clocks[id].is_playing = false
end

--- toggle a subclock
-- @tparam string id unique identifier for this subclock
function Softclock:toggle_subclock(id)
  self.clocks[id].is_playing = not self.clocks[id].is_playing
end

return Softclock