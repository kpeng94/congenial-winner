Phaser = require 'Phaser'

class RespawnAnimation
  constructor: (player) ->
    @player = player
    # All time in milliseconds
    # All fields with the word duration refer to an upper bound
    # in time.
    @isPlaying = false
    @duration = 3000
    @timePlayed = 0
    @isVisible = true
    @invisibilityDuration = 200
    @invisibilityTime = 0
    @visibilityDuration = 200
    @visibilityTime = 0

  restart: ->
    @isPlaying = true
    @timePlayed = 0
    @isVisible = true
    @invisibilityTime = 0
    @visibilityTime = 0

  update: (dt) ->
    '''
    Updates the animation by a given time elapsed dt.
    '''
    @timePlayed += dt

    # When should be invisible, increment the time spent being
    # invisible and quit out of it if invisible for enough time
    if not @isVisible
      @invisibilityTime += dt
      if @invisibilityTime >= @invisibilityDuration
        @invisibilityTime = 0
        @isVisible = true
    # When visible, do something similar
    else
      @visibilityTime += dt
      if @visibilityTime >= @visibilityDuration
        @visibilityTime = 0
        @isVisible = false

    # Update sprite visibility accordingly
    if @isVisible
      @player.visible = true
    else
      @player.visible = false

    if @timePlayed >= @duration
      @isPlaying = false
      @player.visible = true

module.exports = RespawnAnimation