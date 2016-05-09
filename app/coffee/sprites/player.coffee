Phaser = require 'Phaser'
Util = require '../../../util/util.coffee'
RespawnAnimation = require './animation/respawn_animation.coffee'

TRIANGLE_HALF_WIDTH = 15

util = new Util

class Player extends Phaser.Sprite
  constructor: (@game, color) ->
    super(@game)
    @playerColor = color
    @respawnAnimation = new RespawnAnimation(@)
    @isInvincible = false
    @_constructSprite()

  _constructSprite: ->
    # Create the graphics for the player
    # graphics = @game.add.graphics 0, 0
    # graphics.lineStyle 3, util.formatColor(@color)
    # graphics.moveTo TRIANGLE_HALF_WIDTH, 0
    # graphics.lineTo -TRIANGLE_HALF_WIDTH, -TRIANGLE_HALF_WIDTH
    # graphics.lineTo -7, 0
    # graphics.lineTo -TRIANGLE_HALF_WIDTH, TRIANGLE_HALF_WIDTH
    # graphics.lineTo TRIANGLE_HALF_WIDTH, 0
    # window.graphics = graphics

    # Make a sprite for the player
    Phaser.Sprite.call @, @game, 0, 0, 'ship'
    @.tint = parseInt(@playerColor.replace('#', ''), 16)
    console.log @.tint
    @.anchor.x = 0.5
    @.anchor.y = 0.5
    @game.physics.enable(@)
    @.body.collideWorldBounds = true
    return @

  getColor: ->
    return @playerColor

module.exports = Player
