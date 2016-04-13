HIT_INCREMENT = 2
HURT_DECREMENT = 1
SELF_HIT_DECREMENT = 1

class Scoreboard
  constructor: ->
    @scores = {}

  processHit: (player, target) ->
    if player not of @scores
      @scores[player] = 0
    if target not of @scores
      @scores[target] = 0
    if player is target
      @scores[player] -= SELF_HIT_DECREMENT
    else
      @scores[player] += HIT_INCREMENT
      @scores[target] -= HURT_DECREMENT

    return @scores

module.exports = Scoreboard
