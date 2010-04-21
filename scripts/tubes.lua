local gl = require 'gl'
local v2 = require 'dokidoki.v2'

local tube_distance = 1536
local segment_length = 512
local base_tube_height = 48
local transport_size = 10
local transport_vel = 10
local transport_period = 300
local transport_distance = transport_period * transport_vel

local time = 0

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

function make_tube_set(direction, height, color)
  local tube_set = {}

  local normal = v2.rotate90(direction)

  local function closest()
    local player_pos = game.actors.get('player_ship')[1].transform.pos
    local i = math.floor(v2.dot(normal, player_pos)/tube_distance + 0.5) * tube_distance
    local pos
    if hash(i) < 0.5 then
      local origin = i * normal
      local rel_pos = math.floor(
        (v2.dot(direction, player_pos)-(time%transport_period)*transport_vel)/transport_distance+0.5)*transport_distance
      pos = origin + (rel_pos+transport_vel*(time%transport_period)) * direction
    end
    return pos
  end

  local function draw_transport(pos)
    gl.glBlendFunc(gl.GL_ONE, gl.GL_ZERO)
    local size = transport_size * (1/4+math.random()*1.5)
    local pos1 = pos - normal * size / 2
    local pos2 = pos + normal * size / 2
    game.opengl.set_color(color[1], color[2], color[3], 1)
    gl.glBegin(gl.GL_QUADS)
    gl.glVertex3d(pos1.x, pos1.y, height)
    gl.glVertex3d(pos2.x, pos2.y, height)
    gl.glVertex3d(pos2.x, pos2.y, height+size)
    gl.glVertex3d(pos1.x, pos1.y, height+size)
    gl.glEnd()

    local player_pos = game.actors.get('player_ship')[1].transform.pos
    local distance = v2.mag(pos - player_pos)
    local closeness = math.max(((768 - distance) / 768), 0)^2

    local pos1 = player_pos - normal * size * closeness / 2
    local pos2 = player_pos + normal * size * closeness / 2
    gl.glBegin(gl.GL_QUADS)
    gl.glVertex3d(pos1.x, pos1.y, 0)
    gl.glVertex3d(pos2.x, pos2.y, 0)
    gl.glVertex3d(pos2.x, pos2.y, size * closeness)
    gl.glVertex3d(pos1.x, pos1.y, size * closeness)
    gl.glEnd()

    local a = 1 - v2.mag(player_pos - pos) / (transport_distance/2)
    game.opengl.set_color(a*color[1], a*color[2], a*color[3], 1)
    gl.glBegin(gl.GL_LINES)
    gl.glVertex3d(pos.x, pos.y, height)
    gl.glVertex3d(player_pos.x, player_pos.y, 0)
    gl.glEnd()

    -- running sounds from the draw function >_>
    if closeness > 0 then
      if math.random() < 1 then
        game.resources.sfx:play(closeness)
      end
    end

    game.opengl.reset_color()
    gl.glBlendFunc(gl.GL_ONE, gl.GL_ONE)
  end

  function tube_set.draw()
    local draw_rect = game.environment.tube_draw_rect
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

          game.opengl.set_color(0.1)
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
          game.opengl.reset_color()
        end
      end
    end

    local transport = closest()
    if transport then
      draw_transport(transport)
    end
  end

  return tube_set
end

tubes = {
  make_tube_set(v2.unit(0), base_tube_height, {1, 0, 0}),
  make_tube_set(v2.unit(math.pi*2/3), base_tube_height*2, {0, 1, 0}),
  make_tube_set(v2.unit(math.pi*4/3), base_tube_height*3, {0, 0, 1})
}

function update()
  time = time + 1
end

function draw()
  for _, t in ipairs(tubes) do
    t.draw()
  end
end
