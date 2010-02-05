local gl = require 'gl'
local collision = require 'dokidoki.collision'
local v2 = require 'dokidoki.v2'

-- TODO: remove dead stuff

local ships = {}
local obstacles = {}

function add_collider(actor)
  if actor.collider.class == 'ship' then
    table.insert(ships, actor)
  elseif actor.collider.class == 'obstacle' then
    table.insert(obstacles, actor)
    -- todo: index
  else
    error('unknown collision type: ' .. actor.collider.class)
  end
end

game.actors.new_generic('collision', function ()
  function update()
    local function set_body(body, actor)
      body.pos = actor.transform.pos
      body.facing = actor.transform.facing
      body.poly = actor.collider.poly
    end

    local body1 = {}
    local body2 = {}
    for _, s in ipairs(ships) do
      set_body(body1, s)
      for _, o in ipairs(obstacles) do
        set_body(body2, o)
        local correction = collision.collide(body1, body2)
        if correction then
          s.transform.pos = s.transform.pos + correction
          s.collider.on_collide(v2.norm(correction))
          set_body(body1, s)
        end
      end
    end
  end
  function draw_debug()
    for _, o in ipairs(obstacles) do
      gl.glPushMatrix()
      gl.glTranslated(o.transform.pos.x, o.transform.pos.y, 0)
      gl.glColor3d(0.5, 0, 1)
      gl.glBegin(gl.GL_LINE_LOOP)
      for _, v in ipairs(o.collider.poly.vertices) do
        gl.glVertex2d(v.x, v.y)
      end
      gl.glEnd()
      gl.glColor3d(1, 1, 1)
      gl.glPopMatrix()
    end
  end
end)
