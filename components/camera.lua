local glu = require 'glu'
local v2 = require 'dokidoki.v2'

local target
local pos
local vel

function set_target(new_target)
  target = new_target
  if target then
    pos = target.transform.pos
    vel = v2(0, 0)
  end
end

game.actors.new_generic('camera', function ()
  function update_cleanup()
    if target and target.dead then
      target = nil
    end

    local new_pos = target and target.transform.pos or pos

    if new_pos then
      local new_vel = new_pos - pos
      vel = vel * 0.93 + new_vel * 0.07
      pos = new_pos
    end
  end
  function draw_setup()
    if pos then
      local source = pos - vel * 3
      local subject = pos + vel * 6
      local height = math.max(40 - v2.mag(vel) * 7.5, 10)

      glu.gluLookAt(source.x, source.y, height,
                    subject.x, subject.y, 0,
                    0, 1, 0)
    end
  end
end)
