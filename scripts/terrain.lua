local gl = require 'gl'

local cell_size = 64
local line_width = 1.00
local segment_length = 256
local glow_height = 2

local function draw_x_line(min_x, max_x, y)
  local distance = max_x - min_x
  local segments = distance / segment_length
  gl.glBegin(gl.GL_LINE_STRIP)
  for i = 0, segments do
    local x = min_x + i * segment_length
    gl.glVertex2d(x, y)
  end
  gl.glEnd()

  gl.glBegin(gl.GL_QUAD_STRIP)
  for i = 0, segments do
    local x = min_x + i * segment_length
    gl.glVertex2d(x, y - line_width/2)
    gl.glVertex2d(x, y + line_width/2)
  end
  gl.glEnd()

  gl.glBegin(gl.GL_QUAD_STRIP)
  gl.glColor4d(1, 1, 1, 0.15)
  for i = 0, segments do
    local x = min_x + i * segment_length
    gl.glVertex3d(x, y, 0)
    gl.glVertex3d(x, y, glow_height)
  end
  gl.glColor3d(1, 1, 1)
  gl.glEnd()
end

local function draw_y_line(x, min_y, max_y)
  local distance = max_y - min_y
  local segments = distance / segment_length
  gl.glBegin(gl.GL_LINE_STRIP)
  for i = 0, segments do
    local y = min_y + i * segment_length
    gl.glVertex2d(x, y)
  end
  gl.glEnd()

  gl.glBegin(gl.GL_QUAD_STRIP)
  for i = 0, segments do
    local y = min_y + i * segment_length
    gl.glVertex2d(x - line_width/2, y)
    gl.glVertex2d(x + line_width/2, y)
  end
  gl.glEnd()

  gl.glBegin(gl.GL_QUAD_STRIP)
  gl.glColor4d(1, 1, 1, 0.15)
  for i = 0, segments do
    local y = min_y + i * segment_length
    gl.glVertex3d(x, y, 0)
    gl.glVertex3d(x, y, glow_height)
  end
  gl.glColor3d(1, 1, 1)
  gl.glEnd()
end

function draw()
  local draw_rect = game.environment.draw_rect;

  min_x = math.floor(draw_rect[1]/cell_size)*cell_size
  min_y = math.floor(draw_rect[2]/cell_size)*cell_size
  max_x = math.ceil(draw_rect[3]/cell_size)*cell_size
  max_y = math.ceil(draw_rect[4]/cell_size)*cell_size

  for y = min_y, max_y, cell_size do
    draw_x_line(min_x, max_x, y)
  end
  for x = min_x, max_x, cell_size do
    draw_y_line(x, min_y, max_y)
  end
end
