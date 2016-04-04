socket = io();
playerStates = {};
socket.emit('addBigScreen');

# Whenever the server emits 'update', we update our game state
socket.on 'update', (data) ->
  playerStates = data
  console.log("Updated player states")
  console.log(playerStates)
