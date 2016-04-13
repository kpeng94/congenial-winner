Phaser = require 'Phaser'
Util = require '../util.coffee'

TRIANGLE_HALF_WIDTH = 15

util = new Util

class Player
  constructor: (@game, @color) ->
    console.log 'Constructing player'
    @sprite = null

  constructSprite: (playerLocation) ->
    # Create the graphics for the player
    graphics = @game.add.graphics 0, 0
    graphics.lineStyle 3, util.formatColor(@color)
    graphics.moveTo TRIANGLE_HALF_WIDTH, 0
    graphics.lineTo -TRIANGLE_HALF_WIDTH, -TRIANGLE_HALF_WIDTH
    graphics.lineTo -7, 0
    graphics.lineTo -TRIANGLE_HALF_WIDTH, TRIANGLE_HALF_WIDTH
    graphics.lineTo TRIANGLE_HALF_WIDTH, 0
    window.graphics = graphics

    # Make a sprite for the player
    @sprite = @game.add.sprite playerLocation.x, playerLocation.y
    @sprite.addChild graphics
    @sprite.anchor.x = 0.5
    @sprite.anchor.y = 0.5
    @game.physics.enable(@sprite)
    @sprite.body.collideWorldBounds = true
    @sprite.tint = @color
    return @sprite

  getSprite: ->
    return @sprite

  getColor: ->
    return @color

module.exports = Player
