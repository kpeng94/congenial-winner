#Sets up initial game objects
class Setup extends Phaser.State
	constructor: -> super

	create: ->
		@state.start 'Game'
		return

window['phaser'] = window['phaser'] or {}
window['phaser'].Setup = Setup