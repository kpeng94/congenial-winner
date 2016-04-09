Phaser = require 'Phaser'

Util = require '../util.coffee'
config = require '../config.coffee'
MapGenerator = require './map_generator.coffee'

# Total number of bullets in the whole game.
GLOBAL_NUMBER_OF_BULLETS = 10000

socket = io()
playerStates = {}
socket.emit('addBigScreen')
util = new Util
mapGenerator = new MapGenerator

# On player connection,
# we want to add a
class Main extends Phaser.State
  constructor: ->
    @gameSprites = {}

  preload: ->
    @game.stage.disableVisibilityChange = true
    console.log 'Main state done preloading'

  create: ->
    self = @
    @game.stage.backgroundColor = '#EEEEEE'

    # Create the level for the game
    walls = mapGenerator.generateMap1 @game

    # TODO (kpeng94): where is best place to put these?
    '''
    Set up handlers for when players join / leave
    '''
    socket.on 'player joined', (data) ->
      console.log 'player joined'
      console.log data
      playerColor = data.playerData.playerColor
      playerLocation = data.playerData.playerLocation
      if playerColor not of self.gameSprites
        self.addPlayer(playerColor, playerLocation)


    socket.on 'player left', (data) ->
      console.log 'player left'
      console.log data
      playerColor = data.playerData.playerColor
      if playerColor of self.gameSprites
        player = self.gameSprites[playerColor]
        player.destroy()
        delete self.gameSprites[playerColor]
      console.log self.gameSprites

    socket.on 'rotate', (data) ->
      console.log("Rotate")
      console.log(data)
      playerColor = data.playerColor
      playerSprite = self.gameSprites[playerColor]
      input = 3 * data.input
      playerSprite.angle += input #TODO: tweak

    socket.on 'move', (data) ->
      console.log("Move")
      console.log(data)
      playerColor = data.playerColor
      playerSprite = self.gameSprites[playerColor]
      input = 4 * data.input
      playerSprite.x += input * Math.cos(playerSprite.angle * Math.PI / 180)
      playerSprite.y += input * Math.sin(playerSprite.angle * Math.PI / 180)

    socket.on 'update', (data) ->
      playerStates = data
      console.log playerStates

    # Set up bullets
    # bullets = game.add.group()
    # bullets.enableBody = true
    # bullets.physicsBodyType = Phaser.Physics.ARCADE
    # bullets.createMultiple(GLOBAL_NUMBER_OF_BULLETS, 'bullet', 0, false)
    # bullets.setAll('anchor.x', 0.5)
    # bullets.setAll('anchor.y', 0.5)
    # bullets.setAll('outOfBoundsKill', true)
    # bullets.setAll('checkWorldBounds', true

    console.log 'Main state created'

  update: ->
    for playerData in playerStates
      playerColor = playerData.playerColor
      playerLocation = playerData.playerLocation
      playerSprite = @gameSprites[playerColor]
      if playerSprite?
        playerSprite.x = playerLocation.x
        playerSprite.y = playerLocation.y
    #     console.log playerSprite.x
    #     console.log playerSprite.y
    #   console.log playerSprite
    # console.log playerStates

  addPlayer: (playerColor, playerLocation) ->
    # Create the graphics for the player
    graphics = @game.add.graphics 0, 0
    graphics.lineStyle 3, util.formatColor(playerColor)
    #graphics.beginFill util.formatColor(playerColor), 0
    graphics.moveTo 15, 0
    graphics.lineTo -15, -15
    graphics.lineTo -7, 0
    graphics.lineTo -15, 15
    graphics.lineTo 15, 0
    #graphics.endFill
    window.graphics = graphics

    # Make a sprite for the player
    player = @game.add.sprite playerLocation.x, playerLocation.y
    player.addChild graphics
    @gameSprites[playerColor] = player
    console.log @gameSprites



module.exports = Main
