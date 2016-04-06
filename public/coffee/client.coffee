#The main game loop
class Client extends Phaser.State
	constructor: -> super

	preload: ->
		# Assignments
		@socket = io();
		@playerLocation = {};		
		@game.add.sprite 100,100,'test'
		@socket.emit('addBigScreen');
		return

	create: ->
		# Whenever the server emits 'update', we update our game state
		@socket.on 'update', (data) ->
			console.log(data)
			for key, value of data
				console.log(key)
				console.log(value)
				location = value['playerLocation']
				console.log(location)
				@playerLocation[key] = location
				#addPlayer key, location['x'], location['y']
			
			console.log("Updated player states")
			console.log(@playerLocation)
			return
		return

	update: ->
		return 

	addPlayer: (hash, x, y) ->
		console.log(hash+" "+x+" "+y)
		#@playerSprites[hash] = @game.add.sprite x,y,'test'
		console.log("added")

#@playerSprites[key] = game.add.sprite value.playerLocation.x,value.playerLocation.y,'test' 
window['phaser'] = window['phaser'] or {}
window['phaser'].Game = Game