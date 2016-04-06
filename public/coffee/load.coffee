config = './config.coffee'

class Load extends Phaser.State
	constructor: -> super

	create: ->
		sprite = @add.sprite @game.word.centerX, @game.world.centerY, 'test'

module.exports = Load