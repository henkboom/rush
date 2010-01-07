local glfw = require 'glfw'

function update()
  self.ship.accel = (game.keyboard.key_held(glfw.KEY_UP) and 1 or 0) -
                    (game.keyboard.key_held(glfw.KEY_DOWN) and 1 or 0)
  self.ship.turn = (game.keyboard.key_held(glfw.KEY_LEFT) and 1 or 0) -
                   (game.keyboard.key_held(glfw.KEY_RIGHT) and 1 or 0)
  self.ship.brake = game.keyboard.key_held(string.byte('Z'))
  self.ship.boost = game.keyboard.key_held(string.byte('X'))
end
