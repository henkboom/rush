require 'dokidoki.module' [[]]

local g = require 'dokidoki.graphics'

return
{
  level_sprite = g.sprite_from_image('future_track.png'),
  player_sprite = g.sprite_from_image('player_sprite.png', nil, 'center'),
}
