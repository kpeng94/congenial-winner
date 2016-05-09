config          = require '../../../config/config.coffee'
Phaser          = require 'Phaser'
Socket          = require '../util/socket.coffee'
Util            = require '../../../util/util.coffee'

util = new Util()

class Credits extends Phaser.State
  constructor: ->
    super()
    @socket = (new Socket).getSocket()
    console.log('Credits state constructed')

  preload: ->
    # TODO(kpeng94): cleanup so that this uses config.pack instead
    # @load.pack('main', config.pack)
    @game.load.image('button', 'assets/img/button.png')

  create: =>
    @game.stage.backgroundColor = config.backgroundColor

    style = {font: config.fontStyle, fill: config.fontColor, align: 'center'}
    text = 'Credits go here'
    @creditsText = @game.add.text(@game.world.centerX, @game.world.centerY, text, style)
    @creditsText.anchor.setTo(0.5, 0.5)

    x = config.width - 200
    y = config.height - 75
    text = 'Back To Menu'
    menuButton = @game.add.button(x, y, 'button', @_goToLevelSelect, @)
    @game.add.text(x, y, text, {fill: '#000000'})

  _goToLevelSelect: ->
    @state.start('LevelSelect', true, false)

module.exports = Credits
