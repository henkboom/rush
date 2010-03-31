require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

kernel.start_main_loop(game.make_game(
  {'update_setup', 'update', 'collision_check', 'update_cleanup'},
  {'draw_setup', 'draw', '_draw_debug'},
  function (game)
    game.init_component('exit_handler')
    game.exit_handler.trap_esc = true
    game.init_component('keyboard')

    game.init_component('blueprints')
    game.init_component('opengl')
    game.init_component('resources')
    game.init_component('camera')
    game.init_component('collision')
    game.init_component('environment')

    game.actors.new(game.blueprints.terrain)
    game.actors.new(game.blueprints.tubes)

    local player = game.actors.new(game.blueprints.player_ship,
      {'transform', pos=v2(100, 100)})

    game.camera.set_target(player)
  end))
