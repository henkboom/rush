local gl = require 'gl'
local v2 = require 'dokidoki.v2'

local generator = require 'generator'

local CELL_SIZE = 128
local CELL_DISTANCE = 16

-- the current draw area {x1, y1, x2, y2}
-- initialize to something sane
draw_rect = {0, 0, CELL_SIZE, CELL_SIZE}

local cells = {}

-- for now don't add anything
local load_cell = function () return function () end end

game.actors.new_generic('environment', function ()
  function update()
    local player = game.actors.get('player_ship')[1]
    if player then
      local player_direction = v2.sqrmag(player.ship.vel) ~= 0
        and v2.norm(player.ship.vel) or player.transform.facing
      local center = player.transform.pos +
                     player_direction * CELL_SIZE * (CELL_DISTANCE-1)
      local x = math.floor(center.x/CELL_SIZE)
      local y = math.floor(center.y/CELL_SIZE)
      local min_x = x - CELL_DISTANCE
      local max_x = x + CELL_DISTANCE
      local min_y = y - CELL_DISTANCE
      local max_y = y + CELL_DISTANCE
  
      game.environment.draw_rect = {
        min_x * CELL_SIZE,
        min_y * CELL_SIZE,
        (max_x + 1) * CELL_SIZE,
        (max_y + 1) * CELL_SIZE
      }
  
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
end)
