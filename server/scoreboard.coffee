HIT_INCREMENT = 2
HURT_DECREMENT = 1

class Scoreboard
  constructor: ->
    @scores = {}

  processHit: (player, target) ->
    console.log("what going on")
    if player not of @scores
      @scores[player] = 0
    if target not of @scores
      @scores[target] = 0
    @scores[player] += HIT_INCREMENT
    @scores[target] -= HURT_DECREMENT
    console.log("processed Hit")
    return @scores

module.exports = Scoreboard
