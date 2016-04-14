Phaser = require 'Phaser'
Util = require '../../../util/util.coffee'

BULLET_OPACITY = 0.5
BULLET_RADIUS = 4
DEFAULT_BULLET_COLOR = '#FFFFFF'

util = new Util

class Bullet extends Phaser.Sprite
  constructor: (@game) ->
    super(@game)
    # Make the owner a default dummy color at initialization
    # When a bullet is claimed from the pool, we will change this color.
    @owner = DEFAULT_BULLET_COLOR
    @_constructSprite()

  _constructSprite: ->
    graphics = @game.add.graphics 0, 0
    graphics.lineStyle(0)
    graphics.beginFill(util.formatColor(@owner), BULLET_OPACITY)
    graphics.drawCircle(0, 0, BULLET_RADIUS)
    graphics.endFill()
    @.addChild graphics
    @.anchor.x = 0.5
    @.anchor.y = 0.5
    @.outOfBoundsKill = true # Doesn't apply right now since there are walls around
    @.checkWorldBounds = true

    @game.physics.arcade.enable(@)
    @.body.setSize(2 * BULLET_RADIUS, 2 * BULLET_RADIUS, -BULLET_RADIUS, -BULLET_RADIUS)
    @.body.collideWorldBounds = true
    @.body.bounce.x = 1
    @.body.bounce.y = 1
    @.exists = false
    @.visible = false
    @.alive = false
    return @

module.exports = Bullet
