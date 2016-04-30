config      = require '../../../config/config.coffee'
Util        = require '../../../util/util.coffee'

INPUT_REFRESH_RATE = 16  # milliseconds
numBullets = config.PLAYER_INIT_NUM_BULLETS
previousFireTime = 0
previousReloadTime = 0

keyCodeToName = {
  32: 'fire',         # spacebar
  82: 'reload',       # R
  37: 'left',         # left arrow
  65: 'left',         # A
  38: 'up',           # up arrow
  87: 'up',           # W
  39: 'right',        # right arrow
  68: 'right',        # D
  40: 'down',         # down arrow
  83: 'down',         # S
  81: 'turn left',    # Q
  69: 'turn right'    # E
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
  playerCanFire = fireTime - previousFireTime > config.PLAYER_FIRE_CD
  playerIsNotReloading = fireTime - previousReloadTime > config.PLAYER_RELOAD_CD
  hasEnoughBullets = numBullets > 0
  if playerCanFire and playerIsNotReloading and hasEnoughBullets
    numBullets--
    previousFireTime = fireTime
    _updateBulletUI()
    socket.emit('fire')

_updateBulletUI = ->
  $('#num-bullets').html(numBullets)

_resetBulletCount = ->
  numBullets = config.PLAYER_INIT_NUM_BULLETS
  console.log('updated numBullets to be: ' + numBullets)
  _updateBulletUI()

_reload = ->
  reloadTime = new Date()
  # Deny reloading (convenient for player) if the player just reloaded.
  # This is a convenience feature since we are making the CD = time for reload
  if reloadTime - previousReloadTime > config.PLAYER_RELOAD_CD
    console.log('Reloading')
    previousReloadTime = reloadTime
    setTimeout _resetBulletCount, config.PLAYER_RELOAD_CD

_sendInitialPlayerData()
_updateBulletUI()

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

  if keysDown['reload']
    _reload()

  setTimeout sendKeys, 16

setTimeout sendKeys, 16

socket.on 'game start', ->
  _resetBulletCount()

socket.on 'teammates', (teammates) ->
  console.log 'teammates'
  $('#teammates').empty()
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
