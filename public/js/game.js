$(function() {
  var socket = io();

  var playerStates = {};

  socket.emit('addBigScreen');

  // Whenever the server emits 'update', we update our game state
  socket.on('update', function (data) {
    playerStates = data;
    console.log("Updated player states");
    console.log(playerStates);
  });
});

