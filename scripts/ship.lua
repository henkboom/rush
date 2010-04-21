local v2 = require 'dokidoki.v2'

self.tags.ship = true

-- controls access
accel = false
turn = 0
brake = false

-- read only please
vel = v2(0, 0)

local buffered_turn = 0
local buffered_accel = 0

local function damp(value, scalar, multiplier)
  local sign = value > 0 and 1 or -1
  return math.max(value * sign - scalar, 0) * multiplier * sign
end

local function damp_v2(vect, scalar, multiplier)
  local mag = v2.mag(vect)
  if mag > 0 then
    return vect * damp(v2.mag(vect), scalar, multiplier) / mag
  else
    return vect
  end
end

local assumed_max_vel = 17.5

function update()
  local brake = v2.dot(self.transform.facing, vel)/v2.mag(vel) <= 0.75

  buffered_accel = buffered_accel * 0.85 + (accel and 0.15 or 0)
  buffered_turn = buffered_turn * 0.85 + turn * 0.15
  self.transform.facing =
    v2.norm(v2.rotate(self.transform.facing, buffered_turn / 10))

  local current_accel = buffered_accel * 0.04

  -- acceleration
  vel = vel + self.transform.facing * current_accel
  -- general damping
  vel = damp_v2(vel, 0.005, 0.998)
  -- braking damping
  if brake then
    vel =
      v2.project(vel, self.transform.facing)  * 0.99 +
      damp_v2(v2.project(vel, v2.rotate90(self.transform.facing)), 0.005, 0.97)
  end

  self.transform.pos = self.transform.pos + vel
  game.opengl.set_awesome_level(v2.mag(vel)^3 / assumed_max_vel^3)
end
