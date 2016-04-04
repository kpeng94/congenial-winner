function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}

function generateRandomColor() {
    var letters = '0123456789ABCDEF'.split('');
    var color = '#';
    for (var i = 0; i < 6; i++ ) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

$(function() {
  var socket = io();
  var initialX = getRandomInt(100, 300);
  var initialY = getRandomInt(100, 300);
  var playerLocation = {x: initialX, y: initialY};
  var playerColor = generateRandomColor();
  var playerData = {playerLocation: playerLocation, playerColor: playerColor};
  console.log(playerData);
  socket.emit('addPlayer', playerData);

  $('#container').css('background-color', playerColor);

  // Send input
  function sendInput (inputData) {
    socket.emit('updateServer', inputData);
  }

  $(window).keydown(function (event) {
    if (event.which >= 37 && event.which <= 40) {
      sendInput({input: event.which});
      console.log("SENDING INPUT");
    }
    console.log("KEY DOWN");
  });

});