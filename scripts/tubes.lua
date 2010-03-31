local gl = require 'gl'
local v2 = require 'dokidoki.v2'

local tube_distance = 1536
local segment_length = 512
local base_tube_height = 48

local hash_A = 0.5 * (math.sqrt(5)-1)
local function hash(k)
  -- multiplication method
  -- this hash sucks
  return (k * hash_A) % 1
end

local function minmaxdot(direction, points)
  local mindot = 1/0
  local maxdot = -1/0
  for _, v in ipairs(points) do
    local i = v2.dot(v, direction)
    mindot = math.min(i, mindot)
    maxdot = math.max(i, maxdot)
  end
  return mindot, maxdot
end

function make_tube_set(direction, height)
  local tube_set = {}

  local normal = v2.rotate90(direction)

  function tube_set.draw(draw_rect)
    local draw_rect = game.environment.draw_rect
    local points = {
      v2(draw_rect[1], draw_rect[2]),
      v2(draw_rect[1], draw_rect[4]),
      v2(draw_rect[3], draw_rect[2]),
      v2(draw_rect[3], draw_rect[4])
    }

    -- i from tube to tube, j is along them
    local min_i, max_i = minmaxdot(normal, points)
    min_i = math.floor(min_i/tube_distance)*tube_distance
    max_i = math.ceil(max_i/tube_distance)*tube_distance

    local min_j, max_j = minmaxdot(direction, points)
    min_j = math.floor(min_j/segment_length)*segment_length
    max_j = math.ceil(max_j/segment_length)*segment_length

    -- now that we know what do draw... draw it
    for i = min_i, max_i, tube_distance do
      if hash(i) < 0.5 then
        for j = min_j, max_j-1, segment_length do
          local p1a = i*normal + j*direction
          local p2a = (i+5)*normal + j*direction
          local p3a = (i-5)*normal + j*direction
          local p1b = p1a + segment_length * direction
          local p2b = p2a + segment_length* direction
          local p3b = p3a + segment_length * direction

          gl.glBegin(gl.GL_LINES)
          gl.glVertex3d(p1a.x, p1a.y, height-5)
          gl.glVertex3d(p1b.x, p1b.y, height-5)

          gl.glVertex3d(p2a.x, p2a.y, height)
          gl.glVertex3d(p2b.x, p2b.y, height)

          gl.glVertex3d(p3a.x, p3a.y, height)
          gl.glVertex3d(p3b.x, p3b.y, height)
          gl.glEnd()

          gl.glColor4d(1, 1, 1, 0.1)
          gl.glBegin(gl.GL_QUAD_STRIP)
          gl.glVertex3d(p1a.x, p1a.y, height-5)
          gl.glVertex3d(p1b.x, p1b.y, height-5)

          gl.glVertex3d(p2a.x, p2a.y, height)
          gl.glVertex3d(p2b.x, p2b.y, height)

          gl.glVertex3d(p3a.x, p3a.y, height)
          gl.glVertex3d(p3b.x, p3b.y, height)

          gl.glVertex3d(p1a.x, p1a.y, height-5)
          gl.glVertex3d(p1b.x, p1b.y, height-5)
          gl.glEnd()
          gl.glColor3d(1, 1, 1)
        end
      end
    end
  end

  return tube_set
end

tubes = {
  make_tube_set(v2.unit(0), base_tube_height),
  make_tube_set(v2.unit(math.pi*2/3), base_tube_height*2),
  make_tube_set(v2.unit(math.pi*4/3), base_tube_height*3)
}

function draw()
  for _, t in ipairs(tubes) do
    t.draw()
  end
end
