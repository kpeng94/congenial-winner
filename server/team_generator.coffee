Util = require '../util/util.coffee'
util = new Util

class TeamGenerator
  constructor: ->

  # Team restrictions:
  # 1. Each player has N distinct teammates, none of which are herself / himself.
  # 2. Each player is the teammate of N players.
  # 3. Team relationships are asymmetrical: If A is a teammate of B, B cannot be
  #      a teammate of A
  constructRandomTeams: (players, numTeammates) ->
    failed = false # Whether random generation failed or not
    numPlayers = players.length
    numTeammateOf = {} # Map from A to # of players who have A as a teammate
    potentialTeammates = [] # List of all players that don't already have N teammates
    invalidTeammates = {} # Map from A to players who can't be teammates of A (due to asymmetry)
    teamGraph = {}

    # Initialization
    for playerColor in players
      potentialTeammates.push(playerColor)
      numTeammateOf[playerColor] = 0

    for playerColor in players
      # potential teammates for this player (make a copy)
      myPotentialTeammates = potentialTeammates.slice()

      # remove self
      util.removeFromArray(myPotentialTeammates, playerColor)
      if invalidTeammates[playerColor]?
        for invalidTeammate in invalidTeammates[playerColor]
          util.removeFromArray(myPotentialTeammates, invalidTeammate)

      if myPotentialTeammates.length < numTeammates
        failed = true
        break

      # Select first teammate
      for i in [0...numTeammates]
        index = util.getRandomInt(0, myPotentialTeammates.length)
        teammateColor = myPotentialTeammates[index]
        numTeammateOf[teammateColor]++
        if numTeammateOf[teammateColor] is numTeammates
          util.removeFromArray(potentialTeammates, teammateColor)
        util.removeFromArray(myPotentialTeammates, teammateColor)
        if teamGraph[playerColor]?
          teamGraph[playerColor].push(teammateColor)
        else
          teamGraph[playerColor] = [teammateColor]
        if invalidTeammates[teammateColor]?
          invalidTeammates[teammateColor].push(playerColor)
        else
          invalidTeammates[teammateColor] = [playerColor]

    if failed
      # If graph did not satisfy conditions, do it again
      teamGraph = @constructRandomTeams(players, numTeammates)
    else
      console.log 'Teams: ' + JSON.stringify(teamGraph)
      return teamGraph

module.exports = TeamGenerator
