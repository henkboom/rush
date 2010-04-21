local collision = require 'dokidoki.collision'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

player_ship = game.make_blueprint('player_ship',
  {'transform', scale_x=1/4, scale_y=1/4},
  {'sprite', resource='ship_sprite'},
  {'player_ship_control'},
  {'ship'})

terrain = game.make_blueprint('terrain',
  {'terrain'})

tubes = game.make_blueprint('tubes',
  {'tubes'})

fluff = game.make_blueprint('fluff',
  {'transform'},
  {'sprite', resource='fluff_sprite', color={0.7, 0.7, 1, 0.3}})
