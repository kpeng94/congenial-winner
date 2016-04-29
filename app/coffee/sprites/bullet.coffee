Phaser = require 'Phaser'
Util = require '../util.coffee'

BULLET_OPACITY = 1
BULLET_RADIUS = 4

util = new Util

class Bullet
  constructor: (game) ->
    @game = game
    @owner = '#FFFFFF'
    @sprite = null

  constructSprite: ->
    graphics = @game.add.graphics 0, 0
    graphics.lineStyle(0)
    graphics.beginFill(util.formatColor(@owner), BULLET_OPACITY)
    graphics.drawCircle(0, 0, BULLET_RADIUS)
    graphics.endFill()

    @sprite = @game.add.sprite 0, 0
    #@game.physics.arcade.enable(@sprite)
    @sprite.width = 2 * BULLET_RADIUS
    @sprite.height = 2 * BULLET_RADIUS
    @sprite.addChild graphics
    @game.physics.p2.enableBody @sprite, true
    #@sprite.body.offset = new Phaser.Point -BULLET_RADIUS, -BULLET_RADIUS
    @sprite.body.setRectangleFromSprite @sprite
    @sprite.body.mass = 100
    @sprite.exists = false
    #@sprite.visible = false
    #@sprite.alive = false
    #@sprite.anchor.x = 0.5
    #@sprite.anchor.y = 0.5
    return @sprite

  getSprite: ->
    return @sprite

  setOwner: ->
    @owner = owner

  getOwner: ->
    return @owner

module.exports = Bullet
