Util = require '../util.coffee'
config = require '../config.coffee'
util = new Util

eventKeys = [32, 37, 38, 39, 40]
keyCodeToName = {
  32: 'fire',
  37: 'left',
  65: 'left',
  38: 'up',
  87: 'up',
  39: 'right',
  68: 'right',
  40: 'down',
  83: 'down',
  81: 'turn left',
  69: 'turn right'

}
keys = []
MOMENTUM_ENABLED = false

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

# input is either -1 or 1 (-1 meaning to move up and 1 to move down)
sendVerticalMovementInput = (input) ->
  socket.emit('moveVertically', input)

# input is either -1 or 1 (-1 meaning to move left and 1 to move right)
sendHorizontalMovementInput = (input) ->
  socket.emit('moveHorizontally', input)

# stops movement
sendStopMovementInput = (input) ->
  socket.emit('moveStop', input)

sendFireInput = ->
  console.log 'hello'
  fireTime = new Date()
  if (fireTime - previousFireTime > RELOAD_TIME)
    previousFireTime = fireTime
    socket.emit('fire')

$(window).keydown (event) ->
  #Gets the keyCode
  code = event.keyCode
  #Only processes if event key code
  if keyCodeToName[code] isnt null
    #Gets key code name
    keyName = keyCodeToName[code]
    keys[keyName] = true
    #Fire keypress
    if keys['fire']
      sendFireInput()
    #Turning keypresses
    if keys['turn left']
      sendRotationInput -1
    else if keys['turn right']
      sendRotationInput 1
    #Movement keypresses
    if keys['left']
      sendHorizontalMovementInput -1
    else if keys['right']
      sendHorizontalMovementInput 1
    if keys['up']
      sendVerticalMovementInput -1
    else if keys['down']
      sendVerticalMovementInput 1

$(window).keyup (event) ->
  code = event.keyCode
  if keyCodeToName[code] isnt null
    keyName = keyCodeToName[code]
    keys[keyName] = false
    if MOMENTUM_ENABLED isnt true and keyName isnt 'fire'
      sendStopMovementInput 0
