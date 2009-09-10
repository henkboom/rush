require 'dokidoki.module'
[[ points_to_polygon, make_polygon, make_rectangle,
   polygon_halfwidth_in_direction, collide ]]

local v2 = require 'dokidoki.v2'

function points_to_polygon(points)
  local sum = v2(0, 0)
  for _, p in ipairs(points) do
    sum = sum + p
  end
  local pos = sum / #points
  local vertices = {}
  for _, p in ipairs(points) do
    table.insert(vertices, p - pos)
  end
  return pos, make_polygon(vertices)
end

function make_polygon (verts)
  local p = {vertices = {}, halfwidths = {}, bounding_radius = 0}

  for i, v in ipairs(verts) do
    p.vertices[i] = v

    local v_next = verts[i % #verts + 1]
    p.halfwidths[i] = v2.project(v, v2.rotate90(v_next - v))

    p.bounding_radius = math.max(p.bounding_radius, v2.mag(v))
  end

  return p
end

function make_rectangle(w, h)
  return make_polygon{
    v2(-w/2, -h/2),
    v2(w/2, -h/2),
    v2(w/2, h/2),
    v2(-w/2, h/2)}
end

function polygon_halfwidth_in_direction(p, dir)
  local max_hw = -math.huge
  for _, v in ipairs(p.vertices) do
    max_hw = math.max(max_hw, v2.dot(v, dir))
  end
  return max_hw
end

function collide(body1, body2)
  do -- broad phase
    local distance_sqr = v2.sqrmag(body1.pos - body2.pos)
    local collision_distance =
      body1.poly.bounding_radius + body2.poly.bounding_radius
    if distance_sqr > collision_distance * collision_distance then
      return false
    end
  end

  local min_depth = math.huge
  local min_correction = false

  for b1, b2 in pairs{[body1]=body2, [body2]=body1} do
    for _, rel_hw in ipairs(b1.poly.halfwidths) do
      local hw = v2.rotate(rel_hw, b1.angle)
      local hw_direction = v2.norm(hw)
      local hw2_mag = polygon_halfwidth_in_direction(
        b2.poly,
        v2.rotate(-hw_direction, -b2.angle))

      local distance = v2.dot(b2.pos - b1.pos, hw_direction)
      local depth =
        v2.dot(hw, hw_direction) + hw2_mag - distance

      if depth < min_depth then
        min_depth = depth
        min_correction = hw_direction * depth * (b1 == body1 and -1 or 1)
      end
      if min_depth <= 0 then
        return false
      end
    end
  end
  return min_correction
end

return get_module_exports()
