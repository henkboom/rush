--dokidoki_disable_debug = true
require 'dokidoki.module' [[]]

import(require 'gl')
import(require 'glu')
import(require 'dokidoki.base')

local actor_scene = require 'dokidoki.actor_scene'
local kernel = require 'dokidoki.kernel'
local v2 = require 'dokidoki.v2'

local collision = require 'collision'

---- Utility ------------------------------------------------------------------

function load_level(game, level)
  local level_handlers =
  {
    obstacle = function (data)
      local points = imap(function (p) return v2(unpack(p)) end, data)
      local pos, poly = collision.points_to_polygon(points)
      game.add_actor(make_obstacle(game, pos, 0, poly))
    end
  }
  for _, data in ipairs(level) do
    level_handlers[data.type](data)
  end
end

function damp(value, scalar, multiplier)
  local sign = value > 0 and 1 or -1
  return math.max(value * sign - scalar, 0) * multiplier * sign
end

function damp_v2(vect, scalar, multiplier)
  local mag = v2.mag(vect)
  if mag > 0 then
    return vect * damp(v2.mag(vect), scalar, multiplier) / mag
  else
    return vect
  end
end

---- Player -------------------------------------------------------------------
function make_ship(game, controller)
  local self = {}

  self.poly = collision.make_rectangle(
    game.resources.player_sprite.size[1] / 5,
    game.resources.player_sprite.size[2] / 5)
  self.tags = {'ship'}

  function self.draw_object()
    if controller.brake then glColor3d(1, 0, 0)
    elseif controller.boost then glColor3d(0.6, 0.6, 1)
    else glColor3d(0.2, 0.2, 1) end

    glRotated(self.angle * 180 / math.pi, 0, 0, 1)
    glScaled(1/4, 1/4, 1/4)
    game.resources.player_sprite:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_minimap ()
    glColor3d(0, 0, 1)
    glPointSize(8)
    glBegin(GL_POINTS)
    glVertex2d(0, 0)
    glEnd()
    glColor3d(1, 1, 1)
  end

  function self.handle_collision(normal)
    local normal_vel = v2.project(self.vel, normal)
    local tangent_vel = self.vel - normal_vel
    if v2.dot(normal_vel, normal) < 0 then
      self.vel = -0.2 * normal_vel + damp_v2(tangent_vel, v2.mag(normal_vel)*0.75, 1)
    end
  end

  return self
end

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

  game.add_actor{
    collision_check = function ()
      local ships = game.get_actors_by_tag('ship')
      for _, p in ipairs(ships) do
        for _, o in ipairs(obstacle_lookup.lookup(p.pos)) do
          local correction = collision.collide(p, o)
          if correction then
            p.pos = p.pos + correction
            p.handle_collision(v2.norm(correction))
          end
        end
      end
    end
  }

  local player_controller = make_player_controller(game)
  local player = make_ship(game, player_controller)
  game.add_actor(player_controller)
  game.add_actor(player)

  for i = 1, 50 do
    local ai_controller = make_dumb_controller(game)
    local ai = make_ship(game, ai_controller)
    ai_controller.set_ship(ai)

    game.add_actor(ai_controller)
    game.add_actor(ai)
  end

  -- debug
  game.add_actor{
    draw_object = function ()
      --obstacle_lookup.draw_debug(player.pos)
    end
  }
end

function wasd_to_direction (w, a, s, d)
  local direction = v2((d and 1 or 0) - (a and 1 or 0),
                       (w and 1 or 0) - (s and 1 or 0))
  return direction == v2.zero and direction or v2.norm(direction)
end

---- Init ---------------------------------------------------------------------

local width = 640
local height = 480

kernel.set_video_mode(width, height)
kernel.set_ratio(width/height)
kernel.start_main_loop(actor_scene.make_actor_scene(
  {'pre_update', 'update', 'collision_check', 'post_update'},
  {'draw_setup', 'draw_terrain', 'draw_object', 'draw_minimap_setup',
   'draw_minimap_terrain', 'draw_minimap'},
  init))
