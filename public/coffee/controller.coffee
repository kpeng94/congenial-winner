getRandomInt = (min, max) ->
  Math.floor(Math.random() * (max - min)) + min

generateRandomColor = () ->
  letters = '0123456789ABCDEF'.split('');
  color = '#';
  for i in [0...6]
      color += letters[Math.floor(Math.random() * 16)];
  return color;

socket = io();
initialX = getRandomInt(100, 300);
initialY = getRandomInt(100, 300);
playerLocation = {x: initialX, y: initialY};
playerColor = generateRandomColor();
playerData = {playerLocation: playerLocation, playerColor: playerColor};
console.log(playerData);
socket.emit('addPlayer', playerData);

$('#container').css('background-color', playerColor);

sendInput = (inputData) ->
  socket.emit('updateServer', inputData);

$(window).keydown (event) ->
  if event.which >= 37 and event.which <= 40
    sendInput({input: event.which})
    console.log("SENDING INPUT")
  console.log("KEY DOWN")
