config      = require '../../../config/config.coffee'
Main        = require '../states/main.coffee'
Phaser      = require 'Phaser'
Socket      = require '../util/socket.coffee'

# TODO(kpeng94): where is the best place for this?
# TODO(kpeng94): clean up this.
_setupSockets = ->
  # Update scoring table.
  socket.on 'update-score', (data) ->
    playerScores = data.playerScores
    # teamScores = data.teamScores
    $('#scoretable').empty()

    # Add header row
    headerrow = $('<tr />)')
    playerScoreText = $('<th />').addClass('player-score').html('Individual Score')
    # teamScoreText = $('<th />').addClass('team-score').html('Overall Score')
    headerrow.append($('<th />'))
    headerrow.append(playerScoreText)
    # headerrow.append(teamScoreText)
    $('#scoretable').append(headerrow)

    for playerColor, playerScore of playerScores
      row = $('<tr />)')
      styles = {'background-color': playerColor}
      player = $('<td />').addClass('player').css(styles)
      playerScore = $('<td />').addClass('player-score').html(playerScore)
      # teamScore = $('<td />').addClass('team-score').html(teamScores[playerColor])
      row.append(player)
      row.append(playerScore)
      # row.append(teamScore)
      $('#scoretable').append(row)

socket = (new Socket).getSocket()
socket.emit('addBigScreen')
_setupSockets()

game = new Phaser.Game config.width, config.height, Phaser.AUTO, config.gameContainer
game.state.add 'Main', Main
game.state.start 'Main'
