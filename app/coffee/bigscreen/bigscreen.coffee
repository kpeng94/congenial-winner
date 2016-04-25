config      = require '../../../config/config.coffee'
Main        = require '../states/main.coffee'
Phaser      = require 'Phaser'
Socket      = require '../util/socket.coffee'

# TODO(kpeng94): where is the best place for this?
# TODO(kpeng94): clean up this.
_setupSockets = ->
  # Set up players initially
  socket.on 'setup-player-scores', (data) ->
    players = data.players
    $('#scoretable').empty()

    # Add header row
    headerrow = $('<tr />)')
    emptyCell = $('<th />')
    playerScoreText = $('<th />').addClass('player-score').html('Individual Score')
    headerrow.append(emptyCell)
    headerrow.append(playerScoreText)
    $('#scoretable').append(headerrow)

    console.log('players')

    console.log(players)
    for playerColor in players
      row = $('<tr />)')
      console.log(playerColor)
      styles = {'background-color': playerColor}
      player = $('<td />').addClass('player').css(styles)
      playerScore = $('<td id=' + playerColor.slice(1) + ' />').addClass('player-score').html(0)
      row.append(player)
      row.append(playerScore)
      $('#scoretable').append(row)

  # Update scoring table.
  socket.on 'update-player-score', (data) ->
    console.log(data)
    playerScores = data.playerScores
    for playerColor, playerScore of playerScores
      $(playerColor).html(playerScore)

socket = (new Socket).getSocket()
socket.emit('addBigScreen')
_setupSockets()

game = new Phaser.Game config.width, config.height, Phaser.AUTO, config.gameContainer
game.state.add 'Main', Main
game.state.start 'Main'
