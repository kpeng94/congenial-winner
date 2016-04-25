Phaser = require 'Phaser'

config = require '../config.coffee'
Main = require '../level_editor/level_main.coffee'

game = new Phaser.Game config.width, config.height + 100, Phaser.AUTO, config.gameContainer
game.state.add 'Main', Main
game.state.start 'Main'
