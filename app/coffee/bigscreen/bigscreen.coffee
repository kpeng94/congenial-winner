Phaser = require 'Phaser'

config = require '../config.coffee'
Main = require '../states/main.coffee'

game = new Phaser.Game config.width, config.height, Phaser.AUTO, config.game_el_id
game.state.add 'Main', Main
game.state.start 'Main'
