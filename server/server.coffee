Scoreboard = require('./scoreboard.coffee')
ColorAllocator = require('./color_allocator.coffee')

colorAllocator = new ColorAllocator()
controllerRoom = "controllerRoom"
bigScreenRoom = "bigScreenRoom"

# Current game state contains each of the players and their player data.
currentGameState = {};
scoreboard = new Scoreboard

server = (io) ->
  numPlayers = 0
  io.on 'connection', (socket) ->
    isPlayer = false # All controllers represent players, but big screen does not.
    console.log('connection detected')
    socket.on 'addBigScreen', () ->
      socket.join(bigScreenRoom)

    socket.on 'addPlayer', (playerData) ->
      isPlayer = true
      socket.playerData = playerData
      playerColor = colorAllocator.allocateColor()
      playerData.playerColor = playerColor
      socket.playerColor = playerColor
      currentGameState[socket.id] = playerData
      console.log("initialPlayerData")
      console.log(playerData)
      numPlayers++
      socket.emit('playerColor', playerColor)
      io.to(bigScreenRoom).emit('player joined', {playerData: playerData, numPlayers: numPlayers})

    # Have the server relay controller input to the big room
    socket.on 'rotate', (input) ->
      io.to(bigScreenRoom).emit('rotate', { input: input, playerColor: socket.playerColor })

    socket.on 'move', (input) ->
      io.to(bigScreenRoom).emit('move', { input: input, playerColor: socket.playerColor })

    socket.on 'fire', () ->
      io.to(bigScreenRoom).emit('fire', { playerColor: socket.playerColor })

    socket.on 'disconnect', () ->
      if isPlayer
        numPlayers--
        colorAllocator.retrieveColor socket.playerColor
        currentGameState[socket.id] = null
        delete currentGameState[socket.id]
        io.to(bigScreenRoom).emit('player left',
          {playerData: socket.playerData, numPlayers: numPlayers})

    socket.on 'hit-player', (data) ->
      player = data.shooter
      target = data.target
      scores = scoreboard.processHit(player, target)
      io.to(bigScreenRoom).emit('update-score', scores)

module.exports = server
