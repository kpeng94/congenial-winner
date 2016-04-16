Scoreboard = require './scoreboard.coffee'
TeamGenerator = require './team_generator.coffee'
ColorAllocator = require './color_allocator.coffee'

scoreboard = new Scoreboard
teamGenerator = new TeamGenerator
colorAllocator = new ColorAllocator()

controllerRoom = 'controllerRoom'
bigScreenRoom = 'bigScreenRoom'

# Current game state contains each of the players and their player data.
currentGameState = {}

server = (io) ->
  numPlayers = 0
  io.on 'connection', (socket) ->
    isPlayer = false # All controllers represent players, but big screen does not.
    console.log('connection detected')
    socket.on 'addBigScreen', ->
      socket.join(bigScreenRoom)

    socket.on 'addPlayer', ->
      isPlayer = true
      playerColor = colorAllocator.allocateColor()
      socket.playerColor = playerColor
      numPlayers++
      socket.emit('playerColor', playerColor)
      io.to(bigScreenRoom).emit('player joined', playerColor)
      console.log('Added new player with color ' + playerColor)

    # Have the server relay controller input to the big room
    socket.on 'rotate', (input) ->
      io.to(bigScreenRoom).emit('rotate', {input: input, playerColor: socket.playerColor})

    socket.on 'move', (input) ->
      io.to(bigScreenRoom).emit('move', {input: input, playerColor: socket.playerColor})

    socket.on 'fire', ->
      io.to(bigScreenRoom).emit('fire', {playerColor: socket.playerColor})

    socket.on 'disconnect', ->
      if isPlayer
        numPlayers--
        colorAllocator.retrieveColor socket.playerColor
        io.to(bigScreenRoom).emit('player left', socket.playerColor)

    socket.on 'hit-player', (data) ->
      player = data.shooter
      target = data.target
      scores = scoreboard.processHit(player, target)
      io.to(bigScreenRoom).emit('update-score', scores)

module.exports = server
