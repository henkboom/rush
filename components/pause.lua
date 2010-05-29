--function insert_all(dst, src)
--  local dst_len = #dst
--  for i, v in ipairs(src) do
--    dst[dst_len+i] = v
--  end
--end
--
--local pausable_tags = { }
--
--local function get_pausable_actors()
--  local actors = {}
--  for _, t in ipairs(pausable_tags) do
--    insert_all(actors, game.actors.get(t))
--  end
--  return actors
--end
--
--local paused = false
--
--function pause()
--  paused = true
--  for _, a in ipairs(get_pausable_actors()) do
--    a.paused = true
--  end
--end
--
--function unpause()
--  paused = false
--  for _, a in ipairs(get_pausable_actors()) do
--    a.paused = false
--  end
--end

game.actors.new_generic('pause', function ()
  function update()
    if game.keyboard.key_pressed(string.byte('P')) then
      local glfw = require 'glfw'
      glfw.Sleep(2)
    end
  end
end)
