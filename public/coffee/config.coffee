class Config 
	constructor: -> 
		@width = 720
		@height = 1080

window['phaser'] = window['phaser'] or {}
window['phaser'].Config = Config