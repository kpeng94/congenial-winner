Phaser = require 'Phaser'

config = require '../config.coffee'

class Main extends Phaser.State
  constructor: -> super

  preload: ->
    console.log 'main state preloading'

  create: ->
    console.log 'main state created'

module.exports = Main
