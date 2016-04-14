config      = require '../config.coffee'
Util        = require '../util/util.coffee'

previousFireTime = 0
RELOAD_TIME = 340
keyCodeToName = {32: 'fire', 37: 'left', 38: 'up', 39: 'right', 40: 'down'}
keysDown = [] # List of key down presses.
socket = io()
util = new Util
playerColor = util.generateRandomColor()

_sendInitialPlayerData = ->
  initialX = util.getRandomInt(0, config.width)
  initialY = util.getRandomInt(0, config.height)
  initialLocation = {x: initialX, y: initialY}
  playerData = {playerLocation: initialLocation, playerColor: playerColor}
  console.log(playerData)
  socket.emit('addPlayer', playerData)

'''
Send controller input to the server
'''
# input is either -1 or 1 (-1 meaning to rotate counterclockwise and 1 to rotate clockwise)
_sendRotationInput = (input) ->
  socket.emit('rotate', input)

# input is either -1 or 1 (-1 meaning to move backwards and 1 to move forwards)
_sendMovementInput = (input) ->
  socket.emit('move', input)

_sendFireInput = ->
  fireTime = new Date()
  if (fireTime - previousFireTime > RELOAD_TIME)
    previousFireTime = fireTime
    socket.emit('fire')

_sendInitialPlayerData()

# Render something on the screen for the controller
$('#container').css('background-color', playerColor)

'''
Respond to key events
'''
$(window).keydown (event) ->
  #Gets the keyCode
  code = event.keyCode
  #Only processes if event key code
  if keyCodeToName[code] isnt null and code of keyCodeToName
    #Gets key code name
    keyName = keyCodeToName[code]
    keysDown[keyName] = true
    console.log keysDown
    if keysDown['fire']
      _sendFireInput()
    if keysDown['left']
      _sendRotationInput -1
    else if keysDown['right']
      _sendRotationInput 1
    if keysDown['up']
      _sendMovementInput 1
    else if keysDown['down']
      _sendMovementInput -1

$(window).keyup (event) ->
  code = event.keyCode
  if keyCodeToName[code] isnt null and code of keyCodeToName
    keyName = keyCodeToName[code]
    keysDown[keyName] = false
