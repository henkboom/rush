local gl = require 'gl'
local glu = require 'glu'
local memarray = require 'memarray'

local fog_color = memarray('GLfloat', 4)
fog_color[0] = 0
fog_color[1] = 0
fog_color[2] = 0
fog_color[3] = 1

game.actors.new_generic("opengl", function ()
  function draw_setup()
    --gl.glClearColor(0, 0, 0, 0)
    --gl.glClear(gl.GL_COLOR_BUFFER_BIT)

    -- clear
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    gl.glOrtho(-1, 1, -1, 1, 1, -1)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()

    gl.glEnable(gl.GL_BLEND)
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
    gl.glDisable(gl.GL_FOG)
    gl.glColor4d(0, 0, 0, 0.6)
    gl.glBegin(gl.GL_QUADS)
    gl.glVertex2d(-1, -1)
    gl.glVertex2d( 1, -1)
    gl.glVertex2d( 1,  1)
    gl.glVertex2d(-1,  1)
    gl.glEnd()
    gl.glColor3d(1, 1, 1)

    -- prepare for real drawing
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE)
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
