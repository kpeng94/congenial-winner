Util = require '../util.coffee'

util = new Util

# Send initial player information to the server
socket = io()
initialX = util.getRandomInt(100, 300)
initialY = util.getRandomInt(100, 300)
playerLocation = {x: initialX, y: initialY}
playerColor = util.generateRandomColor()
playerData = {playerLocation: playerLocation, playerColor: playerColor}
console.log(playerData)
socket.emit('addPlayer', playerData)

# Render something on the screen for the controller
$('#container').css('background-color', playerColor)

# Send controller input to the server

# input is either -1 or 1 (-1 meaning to rotate counterclockwise and 1 to rotate clockwise)
sendRotationInput = (input) ->
  socket.emit('rotate', input)

# input is either -1 or 1 (-1 meaning to move backwards and 1 to move forwards)
sendMovementInput = (input) ->
  socket.emit('move', input)

$(window).keydown (event) ->
  switch event.which
    when 37
      sendRotationInput -1
    when 38
      sendMovementInput 1
    when 39
      sendRotationInput 1
    when 40
      sendMovementInput -1
    else break
  console.log('KEY DOWN')