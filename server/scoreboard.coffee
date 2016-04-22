HIT_INCREMENT = 2
HURT_DECREMENT = 1
SELF_HIT_DECREMENT = 1

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
      @playerScores[player] -= SELF_HIT_DECREMENT
    else
      @playerScores[player] += HIT_INCREMENT
      @playerScores[target] -= HURT_DECREMENT
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

module.exports = Scoreboard
