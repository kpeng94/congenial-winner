# Assignments
socket = io();
playerStates = {};
socket.emit('addBigScreen');

# Set Up Phaser
config = './config.coffee'
preload = new Preload
Load = './load.coffee'

game = new Phaser.Game config.width, config.height, Phaser.AUTO, 'game-stage'
game.state.add 'Preload', preload
game.state.add 'Load', Load
game.state.start 'Preload'

# Whenever the server emits 'update', we update our game state
socket.on 'update', (data) ->
  playerStates = data
  console.log("Updated player states")
  console.log(playerStates)
