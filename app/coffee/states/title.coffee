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
    @game.load.audio('lobby-bgm', 'assets/audio/bgm/Lobby_Music.wav')
    @game.load.audio('main-bgm', 'assets/audio/bgm/Game_Music.wav')
    @game.load.audio('click-sfx', 'assets/audio/sfx/Click.wav')
    @game.load.audio('ready-sfx', 'assets/audio/sfx/Ready_Up.mp3')
    @game.load.audio('attack-sfx', 'assets/audio/sfx/Attack.wav')
    @game.load.audio('destroy-sfx', 'assets/audio/sfx/Destroyed.wav')

  create: =>
    @bgm = @game.add.audio('lobby-bgm')
    @bgm.play('', 0, 0.10, true, false)
    @click_sfx = @game.add.audio('click-sfx')
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
    @click_sfx.play('', 0, 1, false, false)
    @state.start('Credits', true, false)

  _goToLevelSelect: ->
    @click_sfx.play('', 0, 1, false, false)
    @state.start('LevelSelect', true, false)

module.exports = Title
