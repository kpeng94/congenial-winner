#Runs when window loads
window.onload = -> 
	ns = window['phaser'];
	config = ns.Config

	#Creates the Phaser game instance
	game = new Phaser.Game config.width, config.height, Phaser.AUTO
	game.state.add("Preload",ns.Preload)
	game.state.add("Setup",ns.Setup)
	game.state.add("Game",ns.Game)
	game.state.start("Preload")
