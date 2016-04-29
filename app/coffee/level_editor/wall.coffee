wPhaser = require 'Phaser'
config = require '../config.coffee'

class Wall extends Phaser.Sprite
  constructor: (game, x, y, width, height) ->
    super game, x, y
    @angle = 0
    @graphics = game.add.graphics 0, 0
    # Create the sprite and add the graphic to it
    @width = width
    @height = height
    @addChild(@graphics)
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

  delete: ->
    @graphics.destroy()
    @kill()
  move: (x, y) ->
    @x += x#Math.max 0, Math.min x, (@game.width - @width)
    @y += y#Math.max 0, Math.min y, (@game.height - @height)
    console.log @x, @y
    return
  rotate: (angle) ->
    #@sprite.angle += angle
    angle = angle * Math.PI / 180
    @angle += angle
module.exports = Wall
