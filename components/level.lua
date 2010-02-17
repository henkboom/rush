local base = require 'dokidoki.base'
local collision = require 'dokidoki.collision'
local v2 = require 'dokidoki.v2'

function load(level)
  local level_handlers =
  {
    obstacle = function (data)
      local points = base.imap(function (p) return v2(unpack(p)) end, data)
      local pos, poly = collision.points_to_polygon(points)
      game.actors.new(game.blueprints.obstacle,
        {'transform', pos=pos},
        {'collider', poly=poly})
    end
  }
  for _, data in ipairs(level) do
    level_handlers[data.type](data)
  end
end
