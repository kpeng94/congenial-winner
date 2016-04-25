config          = require '../../../config/config.coffee'
Bullet          = require '../sprites/bullet.coffee'
MapGenerator    = require '../util/map_generator.coffee'
Phaser          = require 'Phaser'
Player          = require '../sprites/player.coffee'
Socket          = require '../util/socket.coffee'
Util            = require '../../../util/util.coffee'

# Total number of bullets in the whole game.
GLOBAL_NUMBER_OF_BULLETS = 100
BULLET_LIFESPAN = 3000 # number of milliseconds
BULLET_VELOCITY = 200

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
    @gameStarted = false

  init: (startData) ->
    console.log(startData)
    @level = startData.level

  preload: ->
    @game.stage.disableVisibilityChange = true

  create: ->
    @timer = @game.time.create()
    @game.stage.backgroundColor = config.backgroundColor
    @game.physics.startSystem(Phaser.Physics.ARCADE)

    # Create the level for the game
    @walls = mapGenerator.generateMap(@game, @level)
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

    if @timerStarted?
      $('#timerText').text(@timer.duration.toFixed(0))

  render: ->
    # for wall in @walls.children
    #   @game.debug.body(wall)
    # @game.debug.body(@playersGroup)
    # for player in @playersGroup.children
    #   @game.debug.body(player)
    # for bullet in @bullets.children
      # @game.debug.body(bullet)

  _setupSockets: ->
    '''
    Set up handlers for when players join / leave
    '''
    @socket.on 'player joined', (playerColor) =>
      console.log 'Player with color ' + playerColor + ' joined'
      if playerColor not of @players
        player = new Player(@game, playerColor)
        @_resetSpriteToRandomValidLocation player
        @players[playerColor] = player
        @playersGroup.add(player)
        if util.getDictLength(@players) is config.numPlayers
          @_startGame()

    @socket.on 'player left', (playerColor) =>
      console.log 'Player with color ' + playerColor + ' left'
      if playerColor of @players
        player = @players[playerColor]
        player.destroy()
        @playersGroup.remove(player)
        delete @players[playerColor]

    @socket.on 'rotate', (data) =>
      playerColor = data.playerColor
      @_logIfPlayerColorDoesNotExist playerColor
      player = @players[playerColor]
      input = config.PLAYER_ROTATION_DELTA * data.input
      player.angle += input #TODO(denisli): tweak

    @socket.on 'move', (data) =>
      playerColor = data.playerColor
      @_logIfPlayerColorDoesNotExist playerColor
      player = @players[playerColor]
      xInput = config.PLAYER_MOVEMENT_DELTA * data.xInput
      yInput = config.PLAYER_MOVEMENT_DELTA * data.yInput

      player.body.velocity.x = -1 * yInput * Math.cos(player.rotation)
      player.body.velocity.y = -1 * yInput * Math.sin(player.rotation)
      player.body.velocity.y += xInput * Math.cos(player.rotation)
      player.body.velocity.x += -1 * xinput * Math.sin(player.rotation)

    @socket.on 'moveStop', (data) ->
      playerColor = data.playerColor
      player = @players[playerColor]
      player.body.velocity.x = 0
      player.body.velocity.y = 0

    @socket.on 'fire', (data) =>
      playerColor = data.playerColor
      @_logIfPlayerColorDoesNotExist playerColor
      player = @players[playerColor]
      @_fire(player)

    # Set up players initially
    @socket.on 'setup-player-scores', (data) ->
      players = data.players
      $('#scoretable').empty()

      # Add header row
      headerrow = $('<tr />)')
      emptyCell = $('<th />')
      playerScoreText = $('<th />').addClass('player-score').html('Individual Score')
      headerrow.append(emptyCell)
      headerrow.append(playerScoreText)
      $('#scoretable').append(headerrow)

      for playerColor in players
        row = $('<tr />)')
        styles = {'background-color': playerColor}
        player = $('<td />').addClass('player').css(styles)
        playerScore = $('<td id=' + playerColor.slice(1) + ' />').addClass('player-score').html(0)
        row.append(player)
        row.append(playerScore)
        $('#scoretable').append(row)

    # Update scoring table.
    @socket.on 'update-player-score', (data) ->
      console.log(data)
      playerScores = data.playerScores
      for playerColor, playerScore of playerScores
        $(playerColor).html(playerScore)

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
      @_resetSpriteToRandomValidLocation player
      if @gameStarted
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

  _resetSpriteToRandomValidLocation: (sprite) ->
    console.log('Setting player to a random location not lying within walls')

    @_resetSpriteToRandomLocation(sprite)
    while @_spriteOverlapsWithWalls(sprite) or @_spriteOverlapsWithOtherPlayers(sprite)
      console.log('Player is overlapping with the walls, reset location')
      @_resetSpriteToRandomLocation(sprite)

  _resetSpriteToRandomLocation: (sprite) ->
    sprite.reset( util.getRandomInt(0, config.width), util.getRandomInt(0, config.height) )

  _spriteOverlapsWithWalls: (sprite) ->
    spriteBodyBound = new Phaser.Rectangle(sprite.body.x, sprite.body.y, sprite.body.width, sprite.body.height)
    for wall in @walls.children
      wallBodyBound = new Phaser.Rectangle(wall.body.x, wall.body.y, wall.body.width, wall.body.height)
      if Phaser.Rectangle.intersects(spriteBodyBound, wallBodyBound)
        return true
    return false

  _spriteOverlapsWithOtherPlayers: (sprite) ->
    spriteBodyBound = new Phaser.Rectangle(sprite.body.x, sprite.body.y, sprite.body.width, sprite.body.height)
    for player in @playersGroup.children
      if sprite is player # skip checking if the player is the sprite
        continue
      playerBodyBound = new Phaser.Rectangle(player.body.x, player.body.y, player.body.width, player.body.height)
      if Phaser.Rectangle.intersects(spriteBodyBound, playerBodyBound)
        return true
    return false

    # TODO (kpeng94): add this in later for better visual indicators
    # _addPendingTextOverlay: =>
    #   style = {font: config.fontStyle, fill: config.fontColor, align: 'center'}
    #   text = 'Waiting for additional players to join...'
    #   @pendingText = @game.add.text(@game.world.centerX, @game.world.centerY, text, style)

  _setGameOver: =>
    @gameStarted = false
    style = {font: config.fontStyle, fill: config.fontColor, align: 'center'}
    text = 'Game over... check the scores'
    @gameOverText = @game.add.text(@game.world.centerX, @game.world.centerY, text, style)
    @gameOverText.anchor.setTo(0.5, 0.5)

  # TODO (kpeng94): clean up
  _startGame: =>
    @gameStarted = true
    @socket.emit('startGame')
    offsetX = 20
    offsetY = 8
    style = {font: '12px Arial', fill: '#000000', align: 'center'}
    @timer.add(Phaser.Timer.SECOND * config.gameLength, @_setGameOver)
    @timerStarted = true
    @timer.start()

  _logIfPlayerColorDoesNotExist: (playerColor) ->
    if playerColor is null
      console.log('Player color is null.')
    else if not playerColor in @players
      console.log('The player color ' + playerColor + ' does not exist.')
      console.log('Available color-player mappings are ' + @players)

module.exports = Main
