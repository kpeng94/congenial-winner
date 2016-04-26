config      = require '../../../config/config.coffee'
Util        = require '../../../util/util.coffee'

INPUT_REFRESH_RATE = 16  # milliseconds
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
_sendMoveInput = (xInput, yInput) ->
  socket.emit('move', xInput, yInput)

_sendFireInput = ->
  fireTime = new Date()
  if (fireTime - previousFireTime > RELOAD_TIME)
    previousFireTime = fireTime
    socket.emit('fire')

_sendInitialPlayerData()

sendKeys = ->
  if keysDown['fire']
    _sendFireInput()
  xInput = 0
  yInput = 0
  if keysDown['turn left']
    _sendRotationInput -1
  else if keysDown['turn right']
    _sendRotationInput 1
  if keysDown['left']
    xInput = -1
  else if keysDown['right']
    xInput = 1
  if keysDown['up']
    yInput = -1
  else if keysDown['down']
    yInput = 1
  # TODO(kpeng94): Is there a better way to send start / stop signals besides this?
  _sendMoveInput(xInput, yInput)

  setTimeout sendKeys, 16

setTimeout sendKeys, 16

socket.on 'teammates', (teammates) ->
  console.log 'teammates'
  $('#teammates').html('')
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
