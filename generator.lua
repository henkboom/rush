require 'dokidoki.module' [[ make ]]

local v2 = require 'dokidoki.v2'

function make(game, cell_size)
  local points = { }
  for i = 1, 40 do
    points[i] = {
      pos = v2.random() * 40 * cell_size,
      color={math.random(), math.random(), math.random(), 0.3}
    }
  end

  return function (i, j)
    local actors = {}
    
    local center = v2(i+0.5, j+0.5) * cell_size

    local closest = points[1]
    for _, p in ipairs(points) do
      if v2.sqrmag(p.pos-center) < v2.sqrmag(closest.pos-center) then
        closest = p
      end
    end

    for n = 1, 8 do
      actors[n] = game.actors.new(game.blueprints.fluff,
      {'transform',
        pos=v2((i+math.random())*cell_size, (j+math.random())*cell_size),
        scale_x=math.random()+2,
        scale_y=math.random()+2},
      {'sprite', color=closest.color})
    end
    return function ()
      for _, actor in ipairs(actors) do
        actor.dead = true
      end
    end
  end
end

return get_module_exports()
