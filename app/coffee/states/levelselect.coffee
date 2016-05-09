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
    @buttons = new Array config.numLevels
    @selected

  preload: ->
    # TODO(kpeng94): cleanup so that this uses config.pack instead
    # @load.pack('main', config.pack)
    @game.load.image('credits_button', 'assets/img/credits_button.png')
    @game.load.image('button', 'assets/img/button.png')
    @game.load.image('start_button',  'assets/img/start_button.png')

  create: =>
    @game.stage.backgroundColor = config.backgroundColor
    # TODO(kpeng94): will have to fiddle with the locations and may have to move
    # text
    for i in [1...config.numLevels + 1]
      text = i
      x = 110 + 300 * (i - 1)
      y = 110 

      button = @game.add.button(x, y, 'button', @_highlight_level, @)
      @game.add.text(x, y, text, {fill: '#000000'})
      button.level = i
      @buttons[i - 1] = button

    # TODO (kpeng94): change this as well
    x = 40
    y = config.height - 130
    creditsButton = @game.add.button(x, y, 'credits_button', @_goToCredits, @)

    x = config.width - 330
    y = config.height - 130
    startButton = @game.add.button(x, y, 'start_button', @_startGame, @)
  _startGame: (button) ->
    startData = {level: @selected}
    @state.start('Main', true, false, startData)

  _highlight_level: (button) ->
    if @selected 
      @buttons[@selected - 1].tint = '0xFFFFFF'
    @selected = button.level
    @buttons[@selected - 1].tint = '0x00FF00'

  _goToCredits: ->
    @state.start('Credits', true, false)

module.exports = LevelSelect
