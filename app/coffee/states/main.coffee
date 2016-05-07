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
DEATH_DURATION = 3000 # number of milliseconds

util = new Util()
mapGenerator = new MapGenerator()

class Main extends Phaser.State
  constructor: ->
    super()
    @players = {}
    @playerToTimeDead = {}
    @playersGroup = null
    @bullets = null
    @walls = null
    @socket = (new Socket).getSocket()
    @gameStarted = false
    @playerScores = {}
    @teamScores = {}
    @playersReadyStatus = {}

  init: (startData) ->
    console.log(startData)
    @level = startData.level

  preload: ->
    @game.stage.disableVisibilityChange = true
    @game.load.image 'blue', 'assets/images/blue.png'

    console.log 'Main state done preloading'

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
      timeElapsed = @timer.elapsed
      player.isInvincible = false
      # Update the death timer on every dead player
      if player.playerColor of @playerToTimeDead
        player.isInvincible = true
        @playerToTimeDead[player.playerColor] += timeElapsed
        if @playerToTimeDead[player.playerColor] >= DEATH_DURATION
          delete @playerToTimeDead[player.playerColor]
          @_resetSpriteToRandomValidLocation player
          player.respawnAnimation.restart()
      # If the player just respawned, play the animation
      if player.respawnAnimation.isPlaying
        player.isInvincible = true
        player.respawnAnimation.update(timeElapsed)
        # If respawning is done, then the player is back to not invincible
        if not player.respawnAnimation.isPlaying
          invincibilityData = {isInvincible: false, playerColor: player.playerColor}
          @socket.emit('invincibility', invincibilityData)

    @game.physics.arcade.overlap(@playersGroup, @bullets, @_playerBulletCollision, null, @)
    @game.physics.arcade.collide(@playersGroup, @walls)
    @game.physics.arcade.collide(@playersGroup)
    @game.physics.arcade.collide(@walls, @bullets, @_bulletWallCollision)

    if @timerStarted?
      [min, sec] = util.getMinSecFromMillisec(@timer.duration.toFixed(0))
      $('#timerText').text(util.formatMinSec(min, sec))

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
        @playersReadyStatus[playerColor] = false
        @playersGroup.add(player)
        @_updateReadyTable()

    @socket.on 'player left', (playerColor) =>
      console.log 'Player with color ' + playerColor + ' left'
      if playerColor of @players
        player = @players[playerColor]
        player.destroy()
        @playersGroup.remove(player)
        delete @players[playerColor]
        delete @playersReadyStatus[playerColor]

    @socket.on 'rotate', (data) =>
      playerColor = data.playerColor
      @_logIfPlayerColorDoesNotExist playerColor
      if @players[playerColor]?
        player = @players[playerColor]
        input = config.PLAYER_ROTATION_DELTA * data.input
        player.angle += input

    @socket.on 'move', (data) =>
      playerColor = data.playerColor
      @_logIfPlayerColorDoesNotExist playerColor
      if @players[playerColor]?
        player = @players[playerColor]
        xInput = config.PLAYER_MOVEMENT_DELTA * data.xInput
        yInput = config.PLAYER_MOVEMENT_DELTA * data.yInput

        player.body.velocity.x = -1 * yInput * Math.cos(player.rotation)
        player.body.velocity.y = -1 * yInput * Math.sin(player.rotation)
        player.body.velocity.y += xInput * Math.cos(player.rotation)
        player.body.velocity.x += -1 * xInput * Math.sin(player.rotation)

    @socket.on 'fire', (data) =>
      playerColor = data.playerColor
      @_logIfPlayerColorDoesNotExist playerColor
      if @players[playerColor]?
        player = @players[playerColor]
        @_fire(player)

    @socket.on 'update player scores', (data) =>
      @playerScores = data.playerScores
      @teamScores = data.teamScores
      @_updateScoreTable(@playerScores, null, false)

    @socket.on 'player ready', (playerColor) =>
      @playersReadyStatus[playerColor] = true
      @_updateReadyTable()

      correctNumPlayers = util.getDictLength(@players) is config.numPlayers
      everyoneIsReady = true
      for playerColor of @playersReadyStatus
        if not @playersReadyStatus[playerColor]
          everyoneIsReady = false

      if correctNumPlayers and everyoneIsReady
        $('#readytable').remove()
        @_startGame()


  _updateReadyTable: ->
    $('#readytable').empty()

    # Add header row
    headerRow = $('<tr />)')
    playerText = $('<th />').html('Player')
    readyText = $('<th />').addClass('ready-status').html('Ready?')
    headerRow.append(playerText)
    headerRow.append(readyText)
    $('#readytable').append(headerRow)

    for playerColor of @playersReadyStatus
      row = $('<tr />)')
      styles = {'background-color': playerColor}
      playerData = $('<td />').addClass('player').css(styles)
      if @playersReadyStatus[playerColor]
        playerReadyText = $('<td />').html('READY')
      else
        playerReadyText = $('<td />').html('NOT READY')
      row.append(playerData)
      row.append(playerReadyText)
      $('#readytable').append(row)

  _updateScoreTable: (playerScores, teamScores, sortByTeamScores) ->
    $('#scoretable').empty()

    # Add header row
    headerRow = $('<tr />)')
    playerText = $('<th />').html('Player')
    playerScoreText = $('<th />').addClass('player-score').html('Individual Score')
    headerRow.append(playerText)
    headerRow.append(playerScoreText)
    if teamScores?
      teamScoreText = $('<th />').addClass('team-score').html('Overall Score')
      headerRow.append(teamScoreText)
    $('#scoretable').append(headerRow)

    if teamScores? and sortByTeamScores
      playersOrder = util.sortDictionaryByValue(teamScores)
    else
      playersOrder = util.sortDictionaryByValue(playerScores)

    for playerColor in playersOrder
      row = $('<tr />)')
      styles = {'background-color': playerColor}
      player = $('<td />').addClass('player').css(styles)
      playerScore = $('<td id=' + playerColor.slice(1) + ' />').addClass('player-score').html(playerScores[playerColor])
      row.append(player)
      row.append(playerScore)
      if teamScores?
        teamScore = $('<td />').addClass('team-score').html(teamScores[playerColor])
        row.append(teamScore)
      $('#scoretable').append(row)

  _bulletWallCollision: (wall, bullet) ->
    if bullet.bounces?
      bullet.bounces++
    else
      bullet.bounces = 1

  _playerBulletCollision: (player, bullet) =>
    collisionData = {shooter: bullet.owner.toString(16), target: player.playerColor.toString(16)}

    bulletHasHitWall = bullet.bounces? and bullet.bounces >= 1
    bulletNotOwnedByPlayer = bullet.owner isnt player.playerColor

    # If the bullet bounced off some wall, the bullet should be able to kill any player
    # Otherwise, the bullet should only be able to hit OTHER players
    if (bulletHasHitWall or bulletNotOwnedByPlayer) and (not player.isInvincible)
      bullet.kill()
      @playerToTimeDead[player.playerColor] = 0
      # Hack where we reset sprite out of the screen to avoid it blocking
      player.reset( -100, -100 )
      player.visible = false
      player.isInvincible = true
      invincibilityData = {isInvincible: true, playerColor: player.playerColor}
      @socket.emit('invincibility', invincibilityData)
      if @gameStarted
        @socket.emit('hit player', collisionData)

  _fire: (player) ->
    bullet = @bullets.getFirstExists(false)
    # bullet.children[0] contains the graphic for the bullet
    bullet.children[0].tint = util.formatColor(player.playerColor)
    bullet.owner = player.playerColor
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
    @_updateScoreTable(@playerScores, @teamScores, true)

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
