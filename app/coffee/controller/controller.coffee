config      = require '../../../config/config.coffee'
Util        = require '../../../util/util.coffee'

INPUT_REFRESH_RATE = 16  # milliseconds
previousFireTime = 0
RELOAD_TIME = 340
keyCodeToName = {32: 'fire', 37: 'left', 38: 'up', 39: 'right', 40: 'down'}
keysDown = [] # List of key down presses.
socket = io()
util = new Util

_sendInitialPlayerData = ->
  socket.emit('addPlayer')
  # Receive the player's color and render it onto the controller's screen
  socket.on 'playerColor', (input) ->
    playerColor = input
    $('#container').css('background-color', playerColor)

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

sendKeys = ->
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

  setTimeout sendKeys, 16

setTimeout sendKeys, 16

socket.on 'teammates', (teammates) ->
  console.log 'teammates'
  for playerColor in teammates
    styles = {'background-color': playerColor}
    player = $('<td />').addClass('player').css(styles)
    $('#teammates').append(player)
  console.log teammates

socket.on 'update-my-score', (score) ->
  console.debug 'score'
  console.debug score
  $('#my-score').text(score)

socket.on 'update-team-score', (score) ->
  console.debug 'team-score'
  console.debug score
  $('#team-score').text(score)

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

$(window).keyup (event) ->
  code = event.keyCode
  if keyCodeToName[code] isnt null and code of keyCodeToName
    keyName = keyCodeToName[code]
    keysDown[keyName] = false
