Phaser = require 'Phaser'

Bullet = require '../sprites/bullet.coffee'
Player = require '../sprites/player.coffee'
Util = require '../util.coffee'
config = require '../config.coffee'
MapGenerator = require './map_generator.coffee'

# Total number of bullets in the whole game.
GLOBAL_NUMBER_OF_BULLETS = 10
DISTANCE_OFFSET = 5
BULLET_VELOCITY = 200
TRIANGLE_HALF_WIDTH = 15

socket = io()
playerStates = {}
socket.emit('addBigScreen')
util = new Util
mapGenerator = new MapGenerator

# On player connection,
# we want to add a
class Main extends Phaser.State
  constructor: ->
    super()
    @players = {}
    @playersGroup = null
    @bullets = null
    @walls = null

  preload: ->
    @game.stage.disableVisibilityChange = true
    socket.on 'update-score', (data) ->
      $('#scoretable').empty()
      for playerColor, score of data
        row = $('<tr />)')
        styles = {'background-color': playerColor, 'width': '20px', 'height': '20px'}
        leftcell = $('<td />').css(styles)
        rightcell = $('<td />').html(score)
        row.append(leftcell)
        row.append(rightcell)
        $('#scoretable').append(row)

    console.log 'Main state done preloading'

  create: ->
    self = @
    @game.stage.backgroundColor = '#EEEEEE'
    @game.physics.startSystem(Phaser.Physics.ARCADE)

    # Create the level for the game
    @walls = mapGenerator.generateMap1 @game
    @walls.enableBody = true

    # TODO (kpeng94): where is best place to put these?
    '''
    Set up handlers for when players join / leave
    '''
    socket.on 'player joined', (data) ->
      console.log 'player joined'
      console.log data
      playerColor = data.playerData.playerColor
      playerLocation = data.playerData.playerLocation
      if playerColor not of self.players
        player = new Player(self.game, playerColor)
        playerSprite = player.constructSprite(playerLocation)
        self.players[playerColor] = player
        self.playersGroup.add(playerSprite)

    socket.on 'player left', (data) ->
      console.log 'player left'
      console.log data
      playerColor = data.playerData.playerColor
      if playerColor of self.players
        player = self.players[playerColor]
        playerSprite = player.getSprite()
        playerSprite.destroy()
        self.playersGroup.remove(playerSprite)
        delete self.players[playerColor]
      console.log self.players

    socket.on 'rotate', (data) ->
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      input = 8 * data.input
      playerSprite.angle += input #TODO: tweak

    socket.on 'move', (data) ->
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      input = 100 * data.input
      playerSprite.body.velocity.x = input * Math.cos(playerSprite.rotation)
      playerSprite.body.velocity.y = input * Math.sin(playerSprite.rotation)
      playerSprite.body.acceleration.x = -playerSprite.body.velocity.x * 0.25
      playerSprite.body.acceleration.y = -playerSprite.body.velocity.y * 0.25

    socket.on 'fire', (data) ->
      console.log('Fire')
      console.log(data)
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      self.fire(player)

    socket.on 'update', (data) ->
      playerStates = data
      console.log playerStates

    @playersGroup = @game.add.group()
    @playersGroup.enableBody = true
    @playersGroup.physicsBodyType = Phaser.Physics.ARCADE
    @game.physics.enable(@playersGroup)

    # Set up bullets
    @bullets = @game.add.group()
    @bullets.enableBody = true
    @bullets.physicsBodyType = Phaser.Physics.ARCADE

    for i in [0...GLOBAL_NUMBER_OF_BULLETS]
      bullet = new Bullet(@game)
      @bullets.add(bullet.constructSprite())
    @bullets.setAll('anchor.x', 0.5)
    @bullets.setAll('anchor.y', 0.5)
    @bullets.setAll('outOfBoundsKill', true)
    @bullets.setAll('checkWorldBounds', true)


    console.log 'Main state created'

  update: ->
    # Draw player sprites
    for playerData in playerStates
      playerColor = playerData.playerColor
      playerLocation = playerData.playerLocation
      player = @players[playerColor]
      if player?
        playerSprite = player.getSprite()
        playerSprite.x = playerLocation.x
        playerSprite.y = playerLocation.y

    @game.physics.arcade.overlap(@playersGroup, @bullets, @hitPlayer, null, @)
    @game.physics.arcade.collide(@playersGroup, @walls)
    @game.physics.arcade.collide(@playersGroup)

  render: ->
    #for wall in @walls.children
    #  @game.debug.body(wall)
    # @game.debug.body(@playersGroup)
    #for player in @playersGroup.children
    #  @game.debug.body(player)
    #for bullet in @bullets.children
    #  @game.debug.body(bullet)

  # Player = playerSprite
  hitPlayer: (player, bullet) ->
    console.log('Shooter color: ' + bullet.tint + 'Hit color: ' + player.tint)
    collisionData = {shooter: bullet.tint.toString(16), target: player.tint.toString(16)}
    if not bullet.tint is player.tint
      bullet.kill()
      player.reset(util.getRandomInt(0, config.width), util.getRandomInt(0, config.height))
    socket.emit('hit-player', collisionData)

  fire: (player) ->
    playerSprite = player.getSprite()
    bullet = @bullets.getFirstExists(false)
    offsetX = Math.cos(playerSprite.rotation) * (3 * TRIANGLE_HALF_WIDTH + DISTANCE_OFFSET)
    offsetY = Math.sin(playerSprite.rotation) * (3 * TRIANGLE_HALF_WIDTH + DISTANCE_OFFSET)
    bullet.reset(playerSprite.x + offsetX, playerSprite.y + offsetY)
    bullet.tint = playerSprite.tint
    # bullet.body.width = TRIANGLE_HALF_WIDTH * 2
    # bullet.body.height = TRIANGLE_HALF_WIDTH * 2

    @game.physics.arcade.velocityFromRotation(playerSprite.rotation,
        BULLET_VELOCITY, bullet.body.velocity)



module.exports = Main
