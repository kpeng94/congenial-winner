Phaser = require 'Phaser'

Bullet = require '../sprites/bullet.coffee'
Player = require '../sprites/player.coffee'
Util = require '../util.coffee'
config = require '../config.coffee'
MapGenerator = require './map_generator.coffee'
MapLoader = require '../level_editor/map_loader.coffee'

# Total number of bullets in the whole game.
GLOBAL_NUMBER_OF_BULLETS = 100
BULLET_LIFESPAN = 3000 # number of milliseconds
BULLET_VELOCITY = 200
TRIANGLE_HALF_WIDTH = 15
PLAYER_SPEED = 100

socket = io()
playerStates = {}
socket.emit('addBigScreen')
util = new Util
mapLoader = new MapLoader

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

    @game.load.json 'map', 'assets/maps/exampleMap.JSON'
    console.log 'Main state done preloading'

  create: ->
    self = @
    @game.stage.backgroundColor = '#EEEEEE'
    @game.physics.startSystem(Phaser.Physics.ARCADE)
    jsonWalls = @game.cache.getJSON('map')

    # Create the level for the game
    @walls = (new MapLoader).generateMap1 @game, jsonWalls
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
      console.log playerSprite.rotation

    socket.on 'moveVertically', (data) ->
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      input = PLAYER_SPEED * data.input
      playerSprite.body.velocity.x = -1 * input * Math.cos(playerSprite.rotation)
      playerSprite.body.velocity.y = -1 * input * Math.sin(playerSprite.rotation)
    socket.on 'moveHorizontally', (data) ->
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      input = PLAYER_SPEED * data.input
      #playerSprite.body.velocity.x = input
      playerSprite.body.velocity.y = input * Math.cos(playerSprite.rotation)
      playerSprite.body.velocity.x = -1 * input * Math.sin(playerSprite.rotation)

    socket.on 'moveStop', (data) ->
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      playerSprite.body.velocity.x = 0
      playerSprite.body.velocity.y = 0

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
    for player in @playersGroup.children
      player.body.acceleration.x = -player.body.velocity.x * 0.25
      player.body.acceleration.y = -player.body.velocity.y * 0.25

    @game.physics.arcade.overlap(@playersGroup, @bullets, @hitPlayer, null, @)
    @game.physics.arcade.collide(@playersGroup, @walls)
    @game.physics.arcade.collide(@playersGroup)
    @game.physics.arcade.collide(@walls, @bullets, @bulletWallCollision)

  render: ->
    #for wall in @walls.children
    #  @game.debug.body(wall)
    # @game.debug.body(@playersGroup)
    #for player in @playersGroup.children
    #  @game.debug.body(player)
    # for bullet in @bullets.children
      # @game.debug.body(bullet)

  bulletWallCollision: (wall, bullet) ->
    if bullet.bounces?
      bullet.bounces += 1
    else
      bullet.bounces = 1

  # Player = playerSprite
  hitPlayer: (player, bullet) ->
    collisionData = {shooter: bullet.tint.toString(16), target: player.tint.toString(16)}

    bulletHasHitWall = bullet.bounces? and bullet.bounces >= 1
    bulletNotOwnedByPlayer = bullet.tint isnt player.tint

    # If the bullet bounced off some wall, the bullet should be able to kill any player
    # Otherwise, the bullet should only be able to hit other players
    if bulletHasHitWall or bulletNotOwnedByPlayer
      bullet.kill()
      player.reset(util.getRandomInt(0, config.width), util.getRandomInt(0, config.height))
      socket.emit('hit-player', collisionData)

  fire: (player) ->
    playerSprite = player.getSprite()
    bullet = @bullets.getFirstExists(false)
    # bullet.children[0] contains the graphic for the bullet
    bullet.children[0].tint = util.formatColor(player.getColor())
    bullet.tint = player.getColor()
    bullet.reset(playerSprite.x, playerSprite.y)
    bullet.body.bounce.x = 1
    bullet.body.bounce.y = 1
    bullet.lifespan = BULLET_LIFESPAN
    bullet.bounces = 0

    @game.physics.arcade.velocityFromRotation(playerSprite.rotation,
        BULLET_VELOCITY, bullet.body.velocity)

    @game.physics.arcade.velocityFromRotation(playerSprite.rotation,
        BULLET_VELOCITY, bullet.body.velocity)



module.exports = Main
