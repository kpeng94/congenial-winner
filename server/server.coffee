controllerRoom = "controllerRoom"
bigScreenRoom = "bigScreenRoom"

# Current game state contains each of the players and their player data.
currentGameState = {};

# Prerequisite: inputData is of the form.
# Should check in here to validate / invalidate inputs.
# Return boolean for whether success or not?

computeUpdates = (currentPlayerData, inputData) ->
  switch inputData.input
    when 37
      currentPlayerData.playerLocation.x -= 1
    when 38
      currentPlayerData.playerLocation.y -= 1
    when 39
      currentPlayerData.playerLocation.x += 1
    when 40
      currentPlayerData.playerLocation.y += 1
    #when 32
    #
    else break
  return true

updateBigScreen = (io) ->
  players = (currentGameState[key] for key of currentGameState)
  io.to(bigScreenRoom).emit('update', players)


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
      currentGameState[socket.id] = playerData
      console.log("initialPlayerData")
      console.log(socket.playerData)
      numPlayers++
      io.to(bigScreenRoom).emit('player joined', {playerData: playerData, numPlayers: numPlayers})

    # Have the server relay controller input to the big room
    socket.on 'rotate', (input) ->
      io.to(bigScreenRoom).emit('rotate', { input: input, playerColor: socket.playerData.playerColor })

    socket.on 'move', (input) ->
      io.to(bigScreenRoom).emit('move', { input: input, playerColor: socket.playerData.playerColor })

    socket.on 'updateServer', (inputData) ->
      computeUpdates(socket.playerData, inputData)
      console.log(currentGameState)
      updateBigScreen(io)

    socket.on 'disconnect', () ->
      if isPlayer
        numPlayers--
        currentGameState[socket.id] = null
        delete currentGameState[socket.id]
        io.to(bigScreenRoom).emit('player left',
          {playerData: socket.playerData, numPlayers: numPlayers})

module.exports = server
