Phaser = require 'Phaser'
jsonfile = require 'jsonfile'
Wall = require '../level_editor/wall.coffee'
Util = require '../util.coffee'
config = require '../config.coffee'

util = new Util
isRecording = false
startingX = 0
startingY = 0
enableMouse = true
newWallButtonPressed = false
levelEditor = null
keyCodeToState = {
  68: 'delete',
  78: 'new',
  82: 'rotate',
  77: 'move'
}
keyCodeToMove = {
  81: 'rotate left',
  69: 'rotate right',
  37: 'left',
  38: 'up',
  39: 'right',
  40: 'down',
}
JSONCode = 74
keysOn = []
state = ''
$(window).keydown (event) ->
  #Gets the keyCode
  code = event.keyCode
  #Only if key maps to a state change
  if code is JSONCode
    levelEditor.writeToJSON()
  if keyCodeToState[code] isnt undefined
    state = keyCodeToState[code]
    isRecording = false
  #Only if key maps to a movement change
  if keyCodeToMove[code] isnt undefined
    key = keyCodeToMove[code]
    keysOn[key] = true

$(window).keyup (event) ->
  code = event.keyCode
  if keyCodeToMove[code] isnt undefined
    keyName = keyCodeToMove[code]
    keysOn[keyName] = false
class LevelMain extends Phaser.State
  constructor: ->
    super()
    levelEditor = @
    @walls = null
    @createWallButton = null
    @wallData = ''
    @wallOn = null
    @stateText = null
  preload: ->
    @walls = @game.add.group()
  create: ->
    @game.stage.backgroundColor = '#CCCCCC'
    #Creates the black border
    graphics = @game.add.graphics 0, 0
    graphics.beginFill 0x000000
    graphics.drawRect 0, config.height, config.width, 10
    graphics.endFill
    text = @game.add.text 0, 730, 'Controls: Press keys to enter an editing state\nN - create new wall, D - delete wall, M - move wall, R - rotate wall, J - create JSON in console', {fontSize: '16px', fill: '00FF00', align: 'left'}
    @stateText = @game.add.text 0, 790, 'Currently not editing.', {fontSize: '16px', fill: '00FF00', align: 'left'}
  update: ->
    #console.log 'here'
    @updateText()
    if state is 'new'
      if isRecording
        #console.log 'recording'
        if @game.input.mousePointer.isUp
          endingX = Math.min @game.input.x, config.width
          endingY = Math.min @game.input.y, config.height
          width = Math.abs endingX - startingX
          height = Math.abs endingY - startingY
          left = Math.min endingX, startingX
          top = Math.min endingY, startingY
          if width > 0 and height > 0
            console.log 'making new wall'
            wall = new Wall @game, left, top, width, height
            @walls.add wall
            wall.inputEnabled = true
            wall.events.onInputDown.add(@updateWall, @, wall)
          isRecording = false
          newWallButtonPressed = false
      if @game.input.mousePointer.isDown and isRecording isnt true
        startingX = Math.min @game.input.x, config.width
        startingY = Math.min @game.input.y, config.height
        isRecording = true
    if state is 'rotate'
      angle = 0
      if keysOn['rotate left'] is true
        angle += 5
      if keysOn['rotate right'] is true
        angle -= 5
      if @wallOn isnt null and angle isnt 0
        @wallOn.rotate angle
    if state is 'move'
      x = 0
      y = 0
      if keysOn['left'] is true
        x -= 1
      if keysOn['right'] is true
        x += 1
      if keysOn['up'] is true
        y -= 1
      if keysOn['down'] is true
        y += 1
      if @wallOn isnt null and (x isnt 0 or y isnt 0) is true
        @wallOn.move x, y
    return
  updateText: ->
    if state is 'delete'
      @stateText.text = 'Currently deleting. Click on a wall to delete it.'
    else if state is 'rotate'
      @stateText.text = 'Currently rotating. Use Q or W to rotate along top-left corner Counter-Clockwise or Clockwise.'
    else if state is 'move'
      @stateText.text = 'Currently rotating. Use arrow key to move wall.'
    else if state is 'new'
      if isRecording isnt true
        @stateText.text = 'Currently making new wall. Click and hold on canvas above line to start drawing.'
      if isRecording is true
        @stateText.text = 'Currently making new wall. Release mouse to make wall.'
    else
      @stateText.text = 'Currently not editing.'
  updateWall: (wall) ->
    if state is 'delete'
      if @wallOn is wall
        @wallOn = null
      wall.delete()
    if state is 'rotate' or state is 'move'
      @wallOn = wall
  writeToJSON: ->
    @wallData = '{ "walls" : ['
    @walls.forEachAlive @getWallData, @
    if @wallData.length > 13
      @wallData = @wallData.slice(0, @wallData.length - 2)
    @wallData += ']}'
    console.log @wallData
    localStorage.setItem 'wall', JSON.stringify(@wallData)
  getWallData: (wall) ->
    @wallData += '{
      "x": ' + wall.x + ',
      "y": ' + wall.y + ',
      "width": ' + wall.width + ',
      "height": ' + wall.height + '
    }, '
module.exports = LevelMain
