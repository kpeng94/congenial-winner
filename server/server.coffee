config = require '../config/config.coffee'
Scoreboard = require './scoreboard.coffee'
TeamGenerator = require './team_generator.coffee'
ColorAllocator = require './color_allocator.coffee'

scoreboard = new Scoreboard
teamGenerator = new TeamGenerator
colorAllocator = new ColorAllocator()

controllerRoom = 'controllerRoom'
bigScreenRoom = 'bigScreenRoom'

players = []
playerToSocket = {}

server = (io) ->
  io.on 'connection', (socket) ->
    isPlayer = false # All controllers represent players, but big screen does not.
    console.log('connection detected')
    socket.on 'addBigScreen', ->
      socket.join(bigScreenRoom)

    socket.on 'addPlayer', ->
      isPlayer = true
      playerColor = colorAllocator.allocateColor()
      socket.playerColor = playerColor
      players.push(playerColor)
      socket.emit('playerColor', playerColor)
      io.to(bigScreenRoom).emit('player joined', playerColor)
      playerToSocket[playerColor] = socket
      console.log('Added new player with color ' + playerColor)

    socket.on 'startGame', ->
      teams = teamGenerator.constructRandomTeams(players, config.numTeammates)
      scoreboard.setTeams(teams)
      for player, teammates of teams
        playerToSocket[player].emit('teammates', teammates)

    # Have the server relay controller input to the big room
    socket.on 'rotate', (input) ->
      io.to(bigScreenRoom).emit('rotate', {input: input, playerColor: socket.playerColor})

    socket.on 'move', (input) ->
      io.to(bigScreenRoom).emit('move', {input: input, playerColor: socket.playerColor})

    socket.on 'fire', ->
      io.to(bigScreenRoom).emit('fire', {playerColor: socket.playerColor})

    socket.on 'disconnect', ->
      if isPlayer
        colorAllocator.retrieveColor socket.playerColor
        io.to(bigScreenRoom).emit('player left', socket.playerColor)

    socket.on 'hit-player', (data) ->
      player = data.shooter
      target = data.target
      playerScores = scoreboard.processHit(player, target)
      teamScores = scoreboard.updateTeamScores()
      io.to(bigScreenRoom).emit('update-score', {playerScores: playerScores, teamScores: teamScores})

module.exports = server
