local mixer = require 'mixer'
local graphics = require 'dokidoki.graphics'

ship_sprite = graphics.sprite_from_image('sprites/ship.png', nil, 'center')
fluff_sprite = graphics.sprite_from_image('sprites/fluff.png', nil, 'center')
noise_sprite = graphics.sprite_from_image('sprites/noise.png')

sfx = mixer.load_wav('sounds/crackle.wav')
