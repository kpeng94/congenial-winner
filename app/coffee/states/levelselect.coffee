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
    @game.load.image('button', 'assets/img/button.png')
    @game.load.image('start_button',  'assets/img/start_button.png')


  create: =>
    @click_sfx = @game.add.audio('click-sfx')
    @game.stage.backgroundColor = config.backgroundColor
    # TODO(kpeng94): will have to fiddle with the locations and may have to move
    style = {font: '65px Orbitron', fill: config.fontColor, align: 'center'}
    text = 'Select a Level'
    titleText = @game.add.text(@game.world.centerX, 40, text, style)
    titleText.anchor.setTo(0.5, 0.5)

    for i in [1...config.numLevels + 1]
      text = i
      x = 50 + 400 * (i - 1)
      y = 150

      button = @game.add.button(x, y, 'button', @_highlight_level, @)
      @game.add.text(x, y, text, {fill: '#000000'})
      button.level = i
      @buttons[i - 1] = button

    # TODO (kpeng94): change this as well

    x = config.width - 300
    y = config.height - 130
    startButton = @game.add.button(x, y, 'start_button', @_startGame, @)
  _startGame: (button) ->
    if @selected
      levelNumber = @selected
    else
      levelNumber = Math.ceil(Math.random() * 3)
    startData = {level: levelNumber}
    @game.sound.stopAll()
    @click_sfx.play('', 0, 1, false, false)
    @state.start('Main', true, false, startData)

  _highlight_level: (button) ->
    if @selected
      @buttons[@selected - 1].tint = '0xFFFFFF'
    @selected = button.level
    @buttons[@selected - 1].tint = '0x00FF00'

module.exports = LevelSelect
