Phaser = require 'Phaser'

Bullet = require '../sprites/bullet.coffee'
Player = require '../sprites/player.coffee'
Util = require '../util.coffee'
config = require '../config.coffee'
MapGenerator = require './map_generator.coffee'

# TODO IMPORTANT
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
    @playerCollisionGroup = null
    @bulletCollisionGroup = null
    @wallCollisionGroup = null

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
    #Starts the physics!
    @game.physics.startSystem(Phaser.Physics.P2JS)
    jsonWalls = @game.cache.getJSON('map')

    #Sets up players
    @playersGroup = @game.add.group()
    @playersGroup.enableBody = true
    @game.physics.p2.enableBody @playersGroup, false
    @playerCollisionGroup = @game.physics.p2.createCollisionGroup @playersGroup

    # Set up bullets
    @bullets = @game.add.group()
    @bullets.enableBody = true
    @game.physics.p2.enableBody @bullets, false
    @bulletCollisionGroup = @game.physics.p2.createCollisionGroup @bullets

    for i in [0...GLOBAL_NUMBER_OF_BULLETS]
      bullet = new Bullet(@game)
      bulletSprite = bullet.constructSprite()
      @bullets.add bulletSprite
    #@bullets.setAll('anchor.x', 0.5)
    #@bullets.setAll('anchor.y', 0.5)
    @bullets.setAll('outOfBoundsKill', true)
    @bullets.setAll('checkWorldBounds', true)

    # Create the level for the game
    @walls = (new MapLoader).generateMap1 @game, jsonWalls
    @walls.enableBody = true
    #@game.physics.p2.enableBody @walls, false
    @wallCollisionGroup = @game.physics.p2.createCollisionGroup  @walls

    # Handles the collision groups
    @game.physics.p2.setImpactEvents true
    @game.physics.p2.restitution = 1
    @game.physics.p2.updateBoundsCollisionGroup()

    for wall in @walls.children#NOTE collisions must be two sided
      wall.body.collides  [@playerCollisionGroup, @bulletCollisionGroup]
      #wall.body.collides  @bulletCollisionGroup, @bulletWallCollision, @
    for bullet in @bullets.children
      bullet.body.collides @playerCollisionGroup
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
        #Sets the collisions for the player
        playerSprite.body.setCollisionGroup self.playerCollisionGroup
        playerSprite.body.collides [self.playerCollisionGroup, self.wallCollisionGroup]
        playerSprite.body.collides self.bulletCollisionGroup,  self.hitPlayer, self

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
      input = Math.PI / 12 * data.input
      playerSprite.body.rotation += input #TODO: tweak
      playerSprite.rotation = playerSprite.body.rotation
      #console.log playerSprite.body.rotation

    socket.on 'move', (data) ->
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      xInput = PLAYER_SPEED * data.xInput
      yInput = PLAYER_SPEED * data.yInput
      playerSprite.body.setZeroVelocity()
      xVelocity = -1 * yInput * Math.cos(playerSprite.rotation) - xInput * Math.sin(playerSprite.rotation)
      yVelocity = -1 * yInput * Math.sin(playerSprite.rotation) + xInput * Math.cos(playerSprite.rotation)
      playerSprite.body.velocity.x = xVelocity
      playerSprite.body.velocity.y = yVelocity
    socket.on 'fire', (data) ->
      console.log('Fire')
      playerColor = data.playerColor
      player = self.players[playerColor]
      playerSprite = player.getSprite()
      self.fire(player)

    socket.on 'update', (data) ->
      playerStates = data
      console.log playerStates

    console.log 'Main state created'

  update: ->
    for player in @playersGroup.children
      #Damping factor of 0.25 for the player's veloctiy
      player.body.damping = 0
      player.body.setZeroForce()

    #@game.physics.arcade.overlap(@playersGroup, @bullets, @hitPlayer, null, @)
    #@game.physics.arcade.collide(@playersGroup, @walls)
    #@game.physics.arcade.collide(@playersGroup)
    #@game.physics.arcade.collide(@walls, @bullets, @bulletWallCollision)
  render: ->
    #for wall in @walls.children
    #  @game.debug.body(wall)
    # @game.debug.body(@playersGroup)
    #for player in @playersGroup.children
    #  @game.debug.body(player)
    # for bullet in @bullets.children
      # @game.debug.body(bullet)

  bulletWallCollision: (bullet, wall) ->
    console.log 'bounce'
    bullet.bounces = true
    console.log bullet.bounces
    #if bullet.bounces?
      #bullet.bounces += 1
    #else
      #bullet.bounces = 1

  # Player = playerSprite
  hitPlayer: (playerBody, bulletBody) ->
    player = playerBody.sprite
    bullet = bulletBody.sprite
    collisionData = {shooter: bullet.tint.toString(16), target: player.tint.toString(16)}

    bulletHasHitWall = bulletBody.bounces#bullet.bounces? and bullet.bounces >= 1
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
    rotation = playerSprite.rotation
    sin = Math.sin rotation
    cos = Math.cos rotation
    console.log sin, cos, playerSprite.height, playerSprite.width
    offsetX = playerSprite.width / 2 * cos
    offsetY = playerSprite.width / 2 * sin
    console.log offsetX, offsetY, rotation
    frontX = playerSprite.x + offsetX
    frontY = playerSprite.y + offsetY
    console.log frontX, frontY

    bullet.reset(frontX, frontY)
    console.log bullet
    bullet.exists = true
    #Can't do bounce!
    #bullet.body.bounce.x = 1
    #bullet.body.bounce.y = 1
    bullet.lifespan = BULLET_LIFESPAN
    bullet.bounces = 0
    bullet.body.setCollisionGroup @bulletCollisionGroup
    bullet.body.collides  @wallCollisionGroup, @bulletWallCollision, @

    xVelocity = BULLET_VELOCITY * cos
    yVelocity = BULLET_VELOCITY * sin
    bullet.body.velocity.x = xVelocity
    bullet.body.velocity.y = yVelocity
    console.log bullet
    #@game.physics.arcade.velocityFromRotation(playerSprite.rotation,
    #    BULLET_VELOCITY, bullet.body.velocity)

    #@game.physics.arcade.velocityFromRotation(playerSprite.rotation,
    #    BULLET_VELOCITY, bullet.body.velocity)



module.exports = Main