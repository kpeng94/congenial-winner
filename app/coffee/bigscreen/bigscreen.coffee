config      = require '../config.coffee'
Main        = require '../states/main.coffee'
Phaser      = require 'Phaser'
Socket      = require '../util/socket.coffee'

# TODO(kpeng94): where is the best place for this?
_setupSockets = ->
  # Update scoring table.
  socket.on 'update-score', (data) ->
    $('#scoretable').empty()
    for playerColor, score of data
      row = $('<tr />)')
      styles = {'background-color': playerColor, 'width': '20px', 'height': '20px'}
      leftcell = $('<td />').css(styles)
      rightcell = $('<td />').html(score)
      row.append(leftcell)
      row.append(rightcell)
      $('#scoretable').append(row)

socket = (new Socket).getSocket()
socket.emit('addBigScreen')
_setupSockets()

game = new Phaser.Game config.width, config.height, Phaser.AUTO, config.gameContainer
game.state.add 'Main', Main
game.state.start 'Main'
