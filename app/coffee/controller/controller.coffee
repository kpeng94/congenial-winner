config = require '../config.coffee'
Util = require '../util/util.coffee'

previousFireTime = 0
RELOAD_TIME = 340
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
keysDown = [] # List of key down presses.
MOMENTUM_ENABLED = false
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

# input is either -1 or 1 (-1 meaning to move up and 1 to move down)
_sendVerticalMovementInput = (input) ->
  socket.emit('moveVertically', input)

# input is either -1 or 1 (-1 meaning to move left and 1 to move right)
_sendHorizontalMovementInput = (input) ->
  socket.emit('moveHorizontally', input)

# stops movement
_sendStopMovementInput = (input) ->
  socket.emit('moveStop', input)

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
    #Fire keypress
    if keysDown['fire']
      _sendFireInput()

    #Turning keypresses
    if keysDown['turn left']
      _sendRotationInput -1
    else if keysDown['turn right']
      _sendRotationInput 1

    #Movement keypresses
    if keysDown['left']
      _sendHorizontalMovementInput -1
    else if keysDown['right']
      _sendHorizontalMovementInput 1
    if keysDown['up']
      _sendVerticalMovementInput -1
    else if keysDown['down']
      _sendVerticalMovementInput 1

$(window).keyup (event) ->
  code = event.keyCode
  if keyCodeToName[code] isnt null and code of keyCodeToName
    console.log code
    keyName = keyCodeToName[code]
    console.log keyName
    keysDown[keyName] = false
    if MOMENTUM_ENABLED isnt true and keyName isnt 'fire'
      _sendStopMovementInput 0
