require 'dokidoki.module' [[ player_ship ]]

local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

player_ship = game.make_blueprint('player_ship',
  {'transform', scale_x=1/4, scale_y=1/4},
  {'sprite', resource='ship_sprite'},
  {'player_ship_control'},
  {'ship'})

return get_module_exports()
