Phaser = require 'Phaser'

Util = require '../util.coffee'
config = require '../config.coffee'

class Main extends Phaser.State

  constructor: -> super
    player : null

  preload: ->
    console.log 'main state preloading'
    return

  create: ->
    console.log 'main state created'
    return

  update: ->
    console.log 'main state updated'
    return

  addPlayer: (x, y) ->
    # Create the graphics for the player
    util = new Util
    color = util.getRandomInt 0, 16777216
    graphics = @game.add.graphics 0, 0
    graphics.lineStyle 0
    graphics.beginFill color, 0.5
    graphics.moveTo 0, 40
    graphics.lineTo -15, -20
    graphics.lineTo 15, -20
    graphics.lineTo 0, 40
    graphics.endFill
    window.graphics = graphics

    # Make a sprite for the player
    @player = @game.add.sprite x, y
    @player.addChild graphics
    return

module.exports = Main
