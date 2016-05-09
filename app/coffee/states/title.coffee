config          = require '../../../config/config.coffee'
Phaser          = require 'Phaser'

class Title extends Phaser.State
  constructor: ->
    super()
    console.log('Title state constructed')

  preload: ->
    # add start button
    @game.load.image('start_button', 'assets/img/start_button.png')
    # @game.load.image('title_image', 'assets/img/title_image.png')

  create: =>
    @game.stage.backgroundColor = config.backgroundColor

    # add title image

    # needed for loading of font beforehand for asynchronous reasons
    style = {font: '45px Orbitron', fill: config.fontColor, align: 'center'}
    text = ' '
    @game.add.text(@game.world.centerX, @game.world.centerY, text, style)

    x = @game.world.centerX
    y = 500
    startButton = @game.add.button(x, y, 'start_button', @_goToLevelSelect, @)
    startButton.anchor.setTo(0.5, 0.5)

  _goToLevelSelect: ->
    @state.start('LevelSelect', true, false)

module.exports = Title
