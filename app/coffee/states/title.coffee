config          = require '../../../config/config.coffee'
Phaser          = require 'Phaser'

class Title extends Phaser.State
  constructor: ->
    super()
    console.log('Title state constructed')

  preload: ->
    @game.load.image('start_button', 'assets/img/start_button.png')
    @game.load.image('title', 'assets/img/title.png')
    @game.load.image('credits_button', 'assets/img/credits_button.png')

  create: =>
    @game.stage.backgroundColor = config.backgroundColor

    # add title image
    titleText = @game.add.sprite(@game.world.centerX, 200, 'title')
    titleText.anchor.setTo(0.5, 0.5)

    # needed for loading of font beforehand for asynchronous reasons
    style = {font: '45px Orbitron', fill: config.fontColor, align: 'center'}
    text = ' '
    @game.add.text(@game.world.centerX, @game.world.centerY, text, style)

    x = config.width - 300
    y = config.height - 130
    startButton = @game.add.button(x, y, 'start_button', @_goToLevelSelect, @)

    x = 40
    y = config.height - 130
    creditsButton = @game.add.button(x, y, 'credits_button', @_goToCredits, @)

  _goToCredits: ->
    @state.start('Credits', true, false)

  _goToLevelSelect: ->
    @state.start('LevelSelect', true, false)

module.exports = Title
