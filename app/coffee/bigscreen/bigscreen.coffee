config      = require '../../../config/config.coffee'
LevelSelect = require '../states/levelselect.coffee'
Main        = require '../states/main.coffee'
Phaser      = require 'Phaser'
Socket      = require '../util/socket.coffee'

socket = (new Socket).getSocket()
socket.emit('addBigScreen')

game = new Phaser.Game config.width, config.height, Phaser.AUTO, config.gameContainer
game.state.add 'LevelSelect', LevelSelect
game.state.add 'Main', Main
game.state.start 'LevelSelect'
