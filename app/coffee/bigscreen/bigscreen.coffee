Phaser = require 'Phaser'

config = require '../config.coffee'
Main = require '../states/main.coffee'

# Show loading screen
socket = io()
playerStates = {}
socket.emit('addBigScreen')

# Whenever the server emits 'update', we update our game state
socket.on 'update', (data) ->
  playerStates = data
  console.log playerStates

game = new Phaser.Game config.width, config.height, Phaser.AUTO, config.game_el_id
game.state.add 'Main', Main
game.state.start 'Main'
