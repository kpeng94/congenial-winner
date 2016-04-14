config          = require '../config.coffee'
Bullet          = require '../sprites/bullet.coffee'
MapGenerator    = require '../util/map_generator.coffee'
Phaser          = require 'Phaser'
Player          = require '../sprites/player.coffee'
Socket          = require '../util/socket.coffee'
Util            = require '../util/util.coffee'

# Total number of bullets in the whole game.
GLOBAL_NUMBER_OF_BULLETS = 100
BULLET_LIFESPAN = 3000 # number of milliseconds
BULLET_VELOCITY = 200
PLAYER_SPEED = 100

util = new Util()
mapGenerator = new MapGenerator()

class Main extends Phaser.State
  constructor: ->
    super()
    @players = {}
    @playersGroup = null
    @bullets = null
    @walls = null
    @socket = (new Socket).getSocket()

  preload: ->
    @game.stage.disableVisibilityChange = true

  create: ->
    @game.stage.backgroundColor = config.backgroundColor
    @game.physics.startSystem(Phaser.Physics.ARCADE)

    # Create the level for the game
    @walls = mapGenerator.generateMap1 @game
    @walls.enableBody = true

    # Set up sockets
    @_setupSockets()

    # Set up player groups
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
      @bullets.add(bullet)

    console.log 'Main state created'

  update: ->
    for player in @playersGroup.children
      player.body.acceleration.x = -player.body.velocity.x * 0.25
      player.body.acceleration.y = -player.body.velocity.y * 0.25

    @game.physics.arcade.overlap(@playersGroup, @bullets, @_playerBulletCollision, null, @)
    @game.physics.arcade.collide(@playersGroup, @walls)
    @game.physics.arcade.collide(@playersGroup)
    @game.physics.arcade.collide(@walls, @bullets, @_bulletWallCollision)

  render: ->
    #for wall in @walls.children
    #  @game.debug.body(wall)
    # @game.debug.body(@playersGroup)
    #for player in @playersGroup.children
    #  @game.debug.body(player)
    # for bullet in @bullets.children
      # @game.debug.body(bullet)

  _setupSockets: ->
    '''
    Set up handlers for when players join / leave
    '''
    @socket.on 'player joined', (data) =>
      console.log 'player joined'
      console.log data
      playerColor = data.playerData.playerColor
      playerLocation = data.playerData.playerLocation
      if playerColor not of @players
        player = new Player(@game, playerColor, playerLocation)
        @players[playerColor] = player
        @playersGroup.add(player)

    @socket.on 'player left', (data) =>
      console.log 'player left'
      console.log data
      playerColor = data.playerData.playerColor
      if playerColor of @players
        player = @players[playerColor]
        player.destroy()
        @playersGroup.remove(player)
        delete @players[playerColor]

    @socket.on 'rotate', (data) =>
      playerColor = data.playerColor
      player = @players[playerColor]
      input = 8 * data.input
      player.angle += input #TODO(denisli): tweak

    @socket.on 'moveVertically', (data) =>
      playerColor = data.playerColor
      player = @players[playerColor]
      input = PLAYER_SPEED * data.input
      player.body.velocity.y = input

    @socket.on 'moveHorizontally', (data) =>
      playerColor = data.playerColor
      player = @players[playerColor]
      input = PLAYER_SPEED * data.input
      player.body.velocity.x = input

    @socket.on 'moveStop', (data) =>
      playerColor = data.playerColor
      player = @players[playerColor]
      player.body.velocity.x = 0
      player.body.velocity.y = 0

    @socket.on 'fire', (data) =>
      playerColor = data.playerColor
      player = @players[playerColor]
      @_fire(player)

  _bulletWallCollision: (wall, bullet) ->
    if bullet.bounces?
      bullet.bounces++
    else
      bullet.bounces = 1

  _playerBulletCollision: (player, bullet) =>
    collisionData = {shooter: bullet.owner.toString(16), target: player.color.toString(16)}

    bulletHasHitWall = bullet.bounces? and bullet.bounces >= 1
    bulletNotOwnedByPlayer = bullet.owner isnt player.color

    # If the bullet bounced off some wall, the bullet should be able to kill any player
    # Otherwise, the bullet should only be able to hit OTHER players
    if bulletHasHitWall or bulletNotOwnedByPlayer
      bullet.kill()
      player.reset(util.getRandomInt(0, config.width), util.getRandomInt(0, config.height))
      @socket.emit('hit-player', collisionData)

  _fire: (player) ->
    bullet = @bullets.getFirstExists(false)
    # bullet.children[0] contains the graphic for the bullet
    bullet.children[0].tint = util.formatColor(player.color)
    bullet.owner = player.color
    bullet.reset(player.x, player.y)
    bullet.lifespan = BULLET_LIFESPAN
    bullet.bounces = 0

    @game.physics.arcade.velocityFromRotation(player.rotation,
        BULLET_VELOCITY, bullet.body.velocity)

module.exports = Main
