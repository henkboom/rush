local gl = require 'gl'
local glu = require 'glu'
local memarray = require 'memarray'

local fog_color = memarray('GLfloat', 4)
fog_color[0] = 0
fog_color[1] = 0
fog_color[2] = 0
fog_color[3] = 1

local awesome_level = 0
function set_awesome_level(a)
  awesome_level = math.max(a, a * 0.01 + awesome_level * 0.99)
end

function set_color(r, g, b, a)
  gl.glColor4d(r, g or r, b or r, a or awesome_level * 0.4)
end

function reset_color(r, g, b, a)
  set_color(0.5)
end

game.actors.new_generic("opengl", function ()
  function draw_setup()
    local w, h = 32, 24
    -- clear
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    gl.glOrtho(0, w, 0, h, 1, -1)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()

    gl.glDisable(gl.GL_FOG)
    gl.glEnable(gl.GL_BLEND)

    gl.glBlendFunc(gl.GL_ZERO, gl.GL_DST_ALPHA)
    gl.glBegin(gl.GL_QUADS)
    gl.glVertex2d(0, 0)
    gl.glVertex2d(w, 0)
    gl.glVertex2d(w, h)
    gl.glVertex2d(0, h)
    gl.glEnd()

    --if math.random() < 0.5 then
      gl.glBlendFunc(gl.GL_ZERO, gl.GL_ONE_MINUS_SRC_ALPHA)
      gl.glColor4d(1, 1, 1, 1/256)
      gl.glTranslated(
        math.floor(-math.random() * 32),
        math.floor(-math.random() * 24),
        0)
      game.resources.noise_sprite:draw()
      gl.glLoadIdentity()
    --end
    --gl.glBegin(gl.GL_QUADS)
    --gl.glVertex2d(0, 0)
    --gl.glVertex2d(w, 0)
    --gl.glVertex2d(w, h)
    --gl.glVertex2d(0, h)
    --gl.glEnd()

    reset_color()

    -- prepare for real drawing
    gl.glBlendFunc(gl.GL_ONE, gl.GL_ONE)
    --gl.glEnable(gl.GL_POLYGON_SMOOTH)

    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    glu.gluPerspective(100, 4/3, 1, 2048)
    gl.glMatrixMode(gl.GL_MODELVIEW)

    gl.glFogi(gl.GL_FOG_MODE, gl.GL_LINEAR)
    gl.glFogfv(gl.GL_FOG_COLOR, fog_color:ptr())
    gl.glFogf(gl.GL_FOG_DENSITY, 0.01)
    gl.glFogf(gl.GL_FOG_START, 512)
    gl.glFogf(gl.GL_FOG_END, 2048)
    gl.glHint(gl.GL_FOG_HINT, gl.GL_NICEST)
    gl.glEnable(gl.GL_FOG)

  end

  function draw_minimap_setup()
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    gl.glOrtho(0, 640, 0, 480, 1, -1)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
    gl.glScaled(0.1, 0.1, 0.1)
  end
end)
