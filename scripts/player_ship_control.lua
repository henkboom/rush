local glfw = require 'glfw'

function update()
  self.ship.accel = game.keyboard.key_held(string.byte(' '))
  self.ship.turn = (game.keyboard.key_held(glfw.KEY_LEFT) and 1 or 0) -
                   (game.keyboard.key_held(glfw.KEY_RIGHT) and 1 or 0)
end
