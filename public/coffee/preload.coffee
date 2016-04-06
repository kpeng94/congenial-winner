#Preloads all the assets of the game
config = window['phaser'].Config

class Preload extends Phaser.State
	constructor: -> super

	preload: ->
		@game.load.image 'test','assets/images/sprites/Test.png'
		return

	create: ->
		@state.start 'Setup'
		return
		
window['phaser'] = window['phaser'] or {}
window['phaser'].Preload = Preload