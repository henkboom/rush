-- some stuff that I never ported. it doesn't run anymore, it's just here as a
-- reminder

---- Controllers --------------------------------------------------------------

function make_dumb_controller(game)
  local self = {}
  local ship

  self.accel = 1
  self.turn = 0
  self.brake = false
  self.boost = false

  function self.set_ship(new_ship)
    ship = new_ship
  end

  function self.pre_update ()
    assert(ship)
    self.turn = math.max(-0.1, math.min(0.1, math.random() * 0.2 - 0.1))
    self.boost = false
    self.brake = false

    local facing = v2.unit(ship.angle)
    local facing_vel = math.max(0, v2.dot(facing, ship.vel)) * facing

    if game.collision_test(ship.pos + 30 * facing_vel + v2.rotate(v2(15, -15), ship.angle)) then
      self.turn = self.turn - 1
    elseif game.collision_test(ship.pos + 30 * facing_vel + v2.rotate(v2(15, 15), ship.angle)) then
      self.turn = self.turn + 1
    end

    if game.collision_test(ship.pos + ship.vel * 30) then
      self.brake = true
    elseif not game.collision_test(ship.pos + facing_vel * 60) then
      self.boost = true
    end
  end

  return self
end

---- Obstacle Collision Grid --------------------------------------------------

local cell_width = 32
local buffer = 3

function make_collision_lookup(objects)
  local cell_object = {
    poly = collision.make_rectangle(cell_width + buffer*2,
                                    cell_width + buffer*2),
    angle = 0
  }

  -- grid[i][j] holds objects relevant for collisions for the cell with lower
  -- coords (i*cell_width, j*cell_width)
  local grid = {}

  for _, o in ipairs(objects) do
    local x1, x2 = o.pos.x, o.pos.x
    local y1, y2 = o.pos.y, o.pos.y

    for _, v in ipairs(o.poly.vertices) do
      x1 = math.min(x1, o.pos.x + v.x)
      x2 = math.max(x2, o.pos.x + v.x)
      y1 = math.min(y1, o.pos.y + v.y)
      y2 = math.max(y2, o.pos.y + v.y)
    end

    for i = math.floor((x1 - buffer) / cell_width),
            math.floor((x2 + buffer) / cell_width) do
      for j = math.floor((y1 - buffer) / cell_width),
              math.floor((y2 + buffer) / cell_width) do
        cell_object.pos = v2((i + 0.5) * cell_width, (j + 0.5) * cell_width)
        if collision.collide(cell_object, o) then
          grid[i] = grid[i] or {}
          grid[i][j] = grid[i][j] or {}
          table.insert(grid[i][j], o)
        end
      end
    end
  end

  local self = {}

  self = {
    lookup = function (pos)
      local i = math.floor(pos.x / cell_width)
      local j = math.floor(pos.y / cell_width)
      return grid[i] and grid[i][j] or {}
    end,
    draw_debug = function (pos)
      local i = math.floor(pos.x / cell_width)
      local j = math.floor(pos.y / cell_width)
      cell_object.pos = v2((i + 0.5) * cell_width, (j + 0.5) * cell_width)
      glBegin(GL_LINE_LOOP)
      for _, v in ipairs(cell_object.poly.vertices) do
        glVertex2d(v.x + cell_object.pos.x, v.y + cell_object.pos.y)
      end
      glEnd()
      for _, o in ipairs(self.lookup(pos)) do
        glPushMatrix()
        glTranslated(o.pos.x, o.pos.y, 0)
        o.draw_debug()
        glPopMatrix()
      end
    end
  }

  return self
end

---- The Game (no not that one) -----------------------------------------------
function init (game)
  game.resources = require 'resources'

  load_level(game, require 'future_track_data')
  local obstacle_lookup =
    make_collision_lookup(game.get_actors_by_tag('obstacle'))

  local query_body = {angle = 0, poly = collision.make_rectangle(4, 4)}

  game.collision_test = function (pos)
    query_body.pos = pos
    for _, o in ipairs(obstacle_lookup.lookup(pos)) do
      local correction = collision.collide(query_body, o)
      if correction then
        return true
      end
    end
    return false
  end

end
