graphics = {}

function graphics:draw_date()
  self:text(0, self.baseline_y, fn.get_month(month) .. ", " .. year, 1)
  self:text_right(128, self.baseline_y, fn.get_season(season), 1)
end

function graphics:draw_ground()
  for i = 1, math.random(12, 24) do
    self:mlrs(math.random(0, 128), self.ground_y, math.random(1, 8), 0, 15)
  end
end

function graphics:draw_plants()
  for k, plant in pairs(plants) do
    local head_x, head_y = 0, 0
    if plant.height < plant.neck then
      head_x = plant.x
      head_y = self.ground_y - plant.height
      self:mlrs(plant.x, self.ground_y, 0, - plant.height, 15) -- stalk
    else
      local delta = plant.height - plant.neck
      local direction = plant.neck_direction == 1 and -1 or 1
      head_x = plant.x + (direction * delta)
      head_y = self.ground_y - plant.height
      self:mlrs(plant.x, self.ground_y, 0, - plant.neck, 15) -- stalk
      self:mlrs(plant.x, self.ground_y - plant.neck, direction * delta, -4, 15) -- neck
    end
    if month > 3 and month < 11 then
      if month < 8 then
        self:circle(head_x, head_y, math.random(2, 5), 15)
      else
        self:circle(head_x, head_y, math.random(1, 3), 15)
      end
    end
  end
end

function graphics.init()
  screen.aa(0)
  screen.font_face(0)
  screen.font_size(8)
  graphics.ground_y = 45
  graphics.baseline_y = 62
end

function graphics:setup()
  screen.clear()
end

function graphics:teardown()
  screen.update()
end

function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_right(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_right(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end

return graphics