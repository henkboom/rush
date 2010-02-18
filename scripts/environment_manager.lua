local gl = require 'gl'
local v2 = require 'dokidoki.v2'

local CELL_SIZE = 128
local CELL_DISTANCE = 3

local cells = {}

local function load_cell(i, j)
  print('loading ' .. i .. ',' .. j)
  local actors = {}
  for n = 1, 8 do
    actors[n] = game.actors.new(game.blueprints.fluff,
      {'transform',
       pos=v2((i+math.random())*CELL_SIZE, (j+math.random())*CELL_SIZE)})
    print(actors[n].transform.pos)
  end
  return function ()
    print('deleting ' .. i .. ',' .. j)
    for _, actor in ipairs(actors) do
      actor.dead = true
    end
  end
end

function update()
  local player = game.actors.get('player_ship')[1]
  if player then
    local center = player.transform.pos
    local x = math.floor(center.x/CELL_SIZE)
    local y = math.floor(center.y/CELL_SIZE)
    local min_x = x - CELL_DISTANCE
    local max_x = x + CELL_DISTANCE
    local min_y = y - CELL_DISTANCE
    local max_y = y + CELL_DISTANCE

    -- cull old stuff
    for i, col in pairs(cells) do
      for j, delete_func in pairs(col) do
        if i < min_x or max_x < i or j < min_y or max_y < j then
          delete_func()
          col[j] = nil
        end
      end
      if next(col) == nil then
        cells[i] = nil
      end
    end

    -- add new stuff
    for i = min_x, max_x do
      cells[i] = cells[i] or {}
      for j = min_y, max_y do
        if not cells[i][j] then
          cells[i][j] = load_cell(i, j)
        end
      end
    end
  end
end

function _draw()
  for i, col in pairs(cells) do
    for j, _ in pairs(col) do
      local x = i * CELL_SIZE
      local y = j * CELL_SIZE
      gl.glBegin(gl.GL_LINE_LOOP)
      gl.glVertex2d(x, y)
      gl.glVertex2d(x + CELL_SIZE, y)
      gl.glVertex2d(x + CELL_SIZE, y + CELL_SIZE)
      gl.glVertex2d(x, y + CELL_SIZE)
      gl.glEnd()
    end
  end
end
