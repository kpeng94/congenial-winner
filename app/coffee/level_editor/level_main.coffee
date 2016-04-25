Phaser = require 'Phaser'
jsonfile = require 'jsonfile'
Wall = require '../level_editor/wall.coffee'
Util = require '../util.coffee'
config = require '../config.coffee'

util = new Util
isRecording = false
startingX = 0
startingY = 0
enableMouse = false
newWallButtonPressed = false
keyCodeToName = {
  68: 'delete',
  78: 'drawing',
  82: 'rotate'
}
state = ''
$(window).keydown (event) ->
  #Gets the keyCode
  code = event.keyCode
  #Only processes if event key code
  if keyCodeToName[code] isnt null
    state = keyCodeToName[code]
    console.log state

class LevelMain extends Phaser.State
  constructor: ->
    super()
    @walls = null
    @createWallButton = null
    @wallData = ''

  preload: ->
    @game.load.spritesheet 'button', 'assets/images/sprite_sheets/button.png', 186, 52
    @walls = @game.add.group()
  create: ->
    @game.stage.backgroundColor = '#CCCCCC'
    #Creates the black border
    graphics = @game.add.graphics 0, 0
    graphics.beginFill 0x000000
    graphics.drawRect 0, config.height, config.width, @game.height - config.height
    graphics.endFill
    #Creates the create a new wall button
    button = @game.add.button 0, config.height, 'button', @newWallButton, @, 2, 1, 0

    #writeButton = @game.add.button 0, config.height, 'button', @writeToJSON, @, 2, 1, 0
  update: ->
    #console.log 'here'
    if newWallButtonPressed
      if isRecording
        #console.log 'recording'
        if @game.input.mousePointer.isUp
          endingX = Math.min @game.input.x, config.width
          endingY = Math.min @game.input.y, config.height
          console.log 'out', endingX, endingY
          width = Math.abs endingX - startingX
          height = Math.abs endingY - startingY
          console.log 'dimensions', width, height
          left = Math.min endingX, startingX
          top = Math.min endingY, startingY
          console.log 'coord', left, ',', top
          if width > 0 and height > 0
            console.log 'making new wall'
            wall = new Wall @game, left, top, width, height
            @walls.add wall.sprite
            wall.sprite.inputEnabled = true
            wall.sprite.events.onInputDown.add(wall.kill, wall)
            @writeToJSON()
          isRecording = false
          newWallButtonPressed = false
          enableMouse = true
      if @game.input.mousePointer.isDown and enableMouse
        console.log 'mouse down'
        startingX = Math.min @game.input.x, config.width
        startingY = Math.min @game.input.y, config.height
        console.log 'in', startingX, startingY
        isRecording = true
        enableMouse = false
    return
  createWall: ->
    @walls = new Wall @game, 50, 50, 10, 10
  mouseToggle: ->
    enableMouse = true
  newWallButton: ->
    newWallButtonPressed = true
    console.log 'pressed'
    @game.time.events.add Phaser.Timer.SECOND, @mouseToggle, @
  writeToJSON: ->
    @wallData = '{ "walls" : ['
    @walls.forEachAlive @getWallData, @
    @wallData = @wallData.slice(0, @wallData.length - 2)
    @wallData += ']}'
    console.log @wallData
    localStorage.setItem 'wall', JSON.stringify(@wallData)
  getWallData: (wall) ->
    @wallData += '{
      x: ' + wall.x + ',
      y: ' + wall.y + ',
      width: ' + wall.width + ',
      height: ' + wall.height + ',
      angle: ' + wall.angle + '
    }, '
module.exports = LevelMain
