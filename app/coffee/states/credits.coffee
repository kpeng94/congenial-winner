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
    @game.load.image('back_button', 'assets/img/back_button.png')

  create: =>
    @game.stage.backgroundColor = config.backgroundColor

    style = {font: '45px Orbitron', fill: config.fontColor, align: 'center'}
    text = 'Game By: \nDamon Doucet, Ethan Kim,\n Eric LaCava, Doms Li, Kevin Peng,\n Kevin Rodriguez, and Dirk Stahlecker\n\n\nLobby BGM: BossLevel VGM by Joe Baxter-Webb\nMain BGM: System Shock by neocrey'
    @creditsText = @game.add.text(@game.world.centerX, @game.world.centerY - 60, text, style)
    @creditsText.anchor.setTo(0.5, 0.5)

    x = 40
    y = config.height - 130
    text = 'Back To Menu'
    menuButton = @game.add.button(x, y, 'back_button', @_goToLevelSelect, @)

  _goToLevelSelect: ->
    @state.start('Title', true, false)

module.exports = Credits
