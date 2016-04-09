Phaser = require 'Phaser'
Util = require '../util.coffee'

BULLET_OPACITY = 0.5
BULLET_RADIUS = 4

util = new Util

class Bullet
  constructor: (game) ->
    @game = game
    @owner = '#000000'
    @sprite = null

  constructSprite: ->
    graphics = @game.add.graphics 0, 0
    graphics.lineStyle(0)
    graphics.beginFill(util.formatColor(@owner), BULLET_OPACITY)
    graphics.drawCircle(0, 0, BULLET_RADIUS)
    graphics.endFill()

    @sprite = @game.add.sprite 0, 0
    @game.physics.arcade.enable(@sprite)
    @sprite.body.setSize(2 * BULLET_RADIUS, 2 * BULLET_RADIUS, -BULLET_RADIUS, -BULLET_RADIUS)
    @sprite.addChild graphics
    @sprite.exists = false
    @sprite.visible = false
    @sprite.alive = false
    @sprite.anchor.x = 0.5
    @sprite.anchor.y = 0.5
    return @sprite

  getSprite: ->
    return @sprite

  setOwner: ->
    @owner = owner

  getOwner: ->
    return @owner

module.exports = Bullet
