local collision = require 'dokidoki.collision'

assert(class, 'missing class argument')
assert(poly, 'missing poly argument')
on_collide = on_collide or function () end

game.collision.add_collider(self)
