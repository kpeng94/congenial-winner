var controllerRoom = "controllerRoom";
var bigScreenRoom = "bigScreenRoom";
// Current game state contains each of the players and their player data.
var currentGameState = {};

/**
 * Prerequisite: inputData is of the form.
 * Should check in here to validate / invalidate inputs.
 * Return boolean for whether success or not?
 */
function computeUpdates(currentPlayerData, inputData) {
  switch(inputData.input) {
    case 37:
      currentPlayerData.playerLocation.x -= 1;
      break;
    case 38:
      currentPlayerData.playerLocation.y -= 1;
      break;
    case 39:
      currentPlayerData.playerLocation.x += 1;
      break;
    case 40:
      currentPlayerData.playerLocation.y += 1;
      break;
    default:
      break;
  }
  return true;
}

function updateBigScreen(io) {
  var currentGameStateValues = [];
  for (var key in currentGameState) {
    currentGameStateValues.push(currentGameState[key]);
  }
  io.to(bigScreenRoom).emit('update', currentGameStateValues);
}

function server(io) {
  var numPlayers = 0;

  io.on('connection', function(socket) {
    var isPlayer = false; // All controllers represent players, but big screen does not.
    console.log('connection detected');

    socket.on('addBigScreen', function() {
      socket.join(bigScreenRoom);
    });

    /**
     * Corresponding handlers depending on the type of message that was sent by the client.
     * These clients will only be controllers in our case because the big screen just needs to
     * update.
     */
    socket.on('addPlayer', function(playerData) {
      isPlayer = true;
      socket.playerData = playerData;
      currentGameState[socket.id] = playerData;
      console.log("initialPlayerData");
      console.log(socket.playerData);
      numPlayers++;
      socket.broadcast.to(bigScreenRoom).emit('player joined', {playerData: playerData, numPlayers: numPlayers});
    });

    socket.on('updateServer', function(inputData) {
      computeUpdates(socket.playerData, inputData);
      console.log(currentGameState);

      updateBigScreen(io);
    });

    socket.on('disconnect', function() {
      if (isPlayer) {
        numPlayers--;
        currentGameState[socket.id] = null;
        delete currentGameState[socket.id];
        socket.broadcast.to(bigScreenRoom).emit('player left',
          {playerData: socket.playerData, numPlayers: numPlayers});
      }
    });
  });
}

module.exports = server;
