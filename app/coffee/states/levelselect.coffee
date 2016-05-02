config          = require '../../../config/config.coffee'
MapGenerator    = require '../util/map_generator.coffee'
Phaser          = require 'Phaser'
Socket          = require '../util/socket.coffee'
Util            = require '../../../util/util.coffee'

util = new Util()
mapGenerator = new MapGenerator()

class LevelSelect extends Phaser.State
  constructor: ->
    super()
    @socket = (new Socket).getSocket()
    console.log('Level select state constructed')

  preload: ->
    # TODO(kpeng94): cleanup so that this uses config.pack instead
    # @load.pack('main', config.pack)
    @game.load.image('button', 'assets/img/button.png')

  create: =>
    @game.stage.backgroundColor = config.backgroundColor
    # TODO(kpeng94): will have to fiddle with the locations and may have to move
    # text
    for i in [1...config.numLevels + 1]
      text = i
      x = 400
      y = 100 + i * 75

      button = @game.add.button(x, y, 'button', @_startGame, @)
      @game.add.text(x, y, text, {fill: '#000000'})
      button.level = i

    # TODO (kpeng94): change this as well
    x = config.width - 200
    y = config.height - 75
    text = 'Credits'
    creditsButton = @game.add.button(x, y, 'button', @_goToCredits, @)
    @game.add.text(x, y, text, {fill: '#000000'})

  _startGame: (button) ->
    startData = {level: button.level}
    @state.start('Main', true, false, startData)

  _goToCredits: ->
    @state.start('Credits', true, false)

module.exports = LevelSelect
