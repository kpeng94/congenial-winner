config = './config.coffee'

class Preload extends Phaser.State
	constructor: -> super

	preload: ->
		@load.pack 'preload', config.pack
		return

	create: ->
		@state.start 'Load'
		return

module.exports = Preload