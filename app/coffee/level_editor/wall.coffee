Phaser = require 'Phaser'
config = require '../config.coffee'

class Wall
  constructor: (game, x, y, width, height) ->
    @angle = 0
    @graphics = game.add.graphics 0, 0
    # Create the sprite and add the graphic to it
    @sprite = game.add.sprite(0, 0)
    @sprite.x = x
    @sprite.y = y
    @sprite.width = width
    @sprite.height = height
    @sprite.addChild(@graphics)
    # Create the graphics for the sprite
    # Creates the aspect ratio for the graphic
    aspectRatio = height / width
    aspectRatio = height / (width * aspectRatio)
    @graphics.lineStyle 0
    @graphics.beginFill 0x000000
    @graphics.moveTo 0, 0
    @graphics.lineTo 32 * aspectRatio, 0
    @graphics.lineTo 32 * aspectRatio, 32 / aspectRatio
    @graphics.lineTo 0, 32 / aspectRatio
    @graphics.lineTo 0, 0
    @graphics.endFill

  kill: ->
    @sprite.kill()
    @graphics.destroy()
  move: (x, y) ->
    @sprite.x = Math.max 0, Math.min x, @sprite.game.width
    @sprite.y = Math.max 0, Math.min y, @sprite.game.height
    console.log @sprite.x, @sprite.y
module.exports = Wall
