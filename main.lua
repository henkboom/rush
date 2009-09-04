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
      local pos, poly =
        collision.points_to_polygon(
          imap(function (p) return v2(unpack(p)) end, data))
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
function make_player(game)
  local self = {}

  self.pos = v2(100, 100)
  self.angle = 0
  self.poly = collision.make_rectangle(
    game.resources.player_sprite.size[1] / 5,
    game.resources.player_sprite.size[2] / 5)
  self.tags = {'player'}

  local vel = v2(0, 0)
  local control_direction = v2(0, 0)
  local braking = false
  local boosting = false

  function self.update()
    local new_direction = wasd_to_direction(
        game.is_key_down(glfw.KEY_UP), game.is_key_down(glfw.KEY_LEFT),
        game.is_key_down(glfw.KEY_DOWN), game.is_key_down(glfw.KEY_RIGHT))

    control_direction =
      control_direction * 0.85 + new_direction * 0.15
    self.angle = self.angle - control_direction.x * 0.1
    braking = game.is_key_down(string.byte('Z'))
    boosting = game.is_key_down(string.byte('X'))

    local accel = control_direction.y * 0.02
    if boosting then accel = accel + 0.02 end

    -- acceleration
    local direction = v2.unit(self.angle)
    vel = vel + direction * accel
    -- general damping
    vel = damp_v2(vel, 0.005, 0.995)
    -- braking damping
    if braking then
      vel = v2.project(vel, direction)  * 0.99 +
            damp_v2(v2.project(vel, v2.rotate90(direction)), 0.005, 0.97)
    end

    self.pos = self.pos + vel
  end

  function self.draw_object()
    if braking then glColor3d(1, 0, 0)
    elseif boosting then glColor3d(0.6, 0.6, 1)
    else glColor3d(0.2, 0.2, 1) end

    glRotated(self.angle * 180 / math.pi, 0, 0, 1)
    glScaled(1/4, 1/4, 1/4)
    game.resources.player_sprite:draw()
    glColor3d(1, 1, 1)
  end

  function self.draw_minimap ()
    glColor3d(1, 0, 0)
    glPointSize(10)
    glBegin(GL_POINTS)
    glVertex2d(0, 0)
    glEnd()
    glColor3d(1, 1, 1)
  end

  function self.handle_collision(normal)
    local normal_vel = v2.project(vel, normal)
    local tangent_vel = vel - normal_vel
    if v2.dot(normal_vel, normal) < 0 then
      vel = -0.2 * normal_vel + damp_v2(tangent_vel, v2.mag(normal_vel)*0.75, 1)
    end
  end

  return self
end

---- Obstacles ----------------------------------------------------------------
function make_obstacle (game, pos, angle, poly)
  local self = {}
  self.pos = pos
  self.angle = angle
  self.poly = poly
  self.tags = {'obstacle'}

  local function draw()
    --glColor3d(0, 0, 0)
    --glBegin(GL_POLYGON)
    --for _, v in ipairs(self.poly.vertices) do
    --  glVertex2d(v.x, v.y)
    --end
    --glEnd()
    --glColor3d(1, 1, 1)
  end

  self.draw_terrain = draw
  self.draw_minimap_terrain = draw

  return self
end

---- Terrain ------------------------------------------------------------------
function make_terrain (game)
  local self = {}

  self.pos = v2(0, 0)

  local function draw ()
    game.resources.level_sprite:draw()
  end

  self.draw_terrain = draw
  self.draw_minimap_terrain = draw

  return self
end

---- Camera -------------------------------------------------------------------
function make_follow_camera (game, actor)
  local self = {}
  local last_pos = actor.pos
  local vel = v2(0, 0)

  function self.post_update ()
    local new_vel =  actor.pos - last_pos
    vel = vel * 0.93 + new_vel * 0.07
    last_pos = actor.pos
  end

  function self.draw_setup ()
    local source = actor.pos - vel * 3
    local target = actor.pos + vel * 6

    local height = math.max(40 - v2.mag(vel) * 7.5, 10)

    gluLookAt(source.x, source.y, height,
              target.x, target.y, 0,
              0, 1, 0)
  end

  return self
end

---- The Game (no not that one) -----------------------------------------------
function init (game)
  game.resources = require 'resources'

  local player = make_player(game)

  game.add_actor{
    collision_check = function ()
      local players = game.get_actors_by_tag('player')
      local obstacles = game.get_actors_by_tag('obstacle')
      for _, p in ipairs(players) do
        for _, o in ipairs(obstacles) do
          local correction = collision.collide(p, o)
          if correction then
            p.pos = p.pos + correction
            p.handle_collision(v2.norm(correction))
          end
        end
      end
    end,

    draw_setup = function ()
      glClearColor(0, 0, 0, 0)
      glClear(GL_COLOR_BUFFER_BIT)
      glEnable(GL_BLEND)
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity()
      gluPerspective(100, 4/3, 1, 10000)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity()
    end,
    draw_minimap_setup = function ()
      glMatrixMode(GL_PROJECTION)
      glLoadIdentity()
      glOrtho(0, 640, 0, 480, 1, -1)
      glMatrixMode(GL_MODELVIEW)
      glLoadIdentity()
      glScaled(0.1, 0.1, 0.1)
    end,
  }

  game.add_actor(make_follow_camera(game, player))
  game.add_actor(player)
  game.add_actor(make_terrain(game))
  load_level(game, require 'future_track_data')
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

