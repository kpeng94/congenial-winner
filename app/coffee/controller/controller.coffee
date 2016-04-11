Util = require '../util.coffee'
config = require '../config.coffee'
util = new Util

eventKeys = [32, 37, 38, 39, 40]

# Send initial player information to the server
socket = io()
initialX = util.getRandomInt(0, config.width)
initialY = util.getRandomInt(0, config.height)
playerLocation = {x: initialX, y: initialY}
playerColor = util.generateRandomColor()
playerData = {playerLocation: playerLocation, playerColor: playerColor}
console.log(playerData)
socket.emit('addPlayer', playerData)

previousFireTime = 0
RELOAD_TIME = 340

# Render something on the screen for the controller
$('#container').css('background-color', playerColor)

# Send controller input to the server

# input is either -1 or 1 (-1 meaning to rotate counterclockwise and 1 to rotate clockwise)
sendRotationInput = (input) ->
  socket.emit('rotate', input)

# input is either -1 or 1 (-1 meaning to move backwards and 1 to move forwards)
sendMovementInput = (input) ->
  socket.emit('move', input)

sendFireInput = ->
  console.log 'hello'
  fireTime = new Date()
  if (fireTime - previousFireTime > RELOAD_TIME)
    previousFireTime = fireTime
    socket.emit('fire')

$(window).keydown (event) ->
  console.log event.which
  switch event.which
    when 32
      sendFireInput()
    when 37
      sendRotationInput -1
    when 38
      sendMovementInput 1
    when 39
      sendRotationInput 1
    when 40
      sendMovementInput -1
    else break
