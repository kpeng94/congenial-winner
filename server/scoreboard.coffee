config = require '../config/config.coffee'

class Scoreboard
  constructor: ->
    @playerScores = {}
    @teamScores = {}

  setTeams: (teams) ->
    @teams = teams

  processHit: (player, target) ->
    if player not of @playerScores
      @playerScores[player] = 0
    if target not of @playerScores
      @playerScores[target] = 0
    if player is target
      @playerScores[player] -= config.SELF_HIT_DECREMENT
    else
      @playerScores[player] += config.HIT_INCREMENT
      @playerScores[target] -= config.HURT_DECREMENT
    return @playerScores

  updateTeamScores: ->
    if @teams?
      for player of @playerScores
        teammates = @teams[player]
        @teamScores[player] = @playerScores[player]
        for teammate in teammates
          if @playerScores[teammate]?
            @teamScores[player] += @playerScores[teammate]
    return @teamScores

  resetScores: (players) ->
    for player in players
      @playerScores[player] = 0
      @teamScores[player] = 0

module.exports = Scoreboard
