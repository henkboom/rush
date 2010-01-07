require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

local blueprints = require 'blueprints'

kernel.start_main_loop(game.make_game(
  {'update_setup', 'update', 'collision_check',
   'update_cleanup'},
  {'draw_setup', 'draw_terrain', 'draw', 'draw_minimap_setup',
   'draw_minimap_terrain', 'draw_minimap'},
  function (game)
    game.init_component('exit_handler')
    game.init_component('keyboard')

    game.init_component('opengl')
    game.init_component('resources')

    game.actors.new(blueprints.player_ship)
  end))
