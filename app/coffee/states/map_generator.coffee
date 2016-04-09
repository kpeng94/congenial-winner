Phaser = require 'Phaser'

class MapGenerator

  generateMap1: (game) ->
    console.log 'Map 1 generated'
    walls = game.add.group()
    walls.enableBody = true

    xList = [ 30, 200, 400, 800, 700, 400, 600, 200 ]
    yList = [ 300, 300, 400, 50, 400, 200, 150, 80 ]
    widthList = [ 10, 10, 20, 70, 300, 100, 20, 200 ]
    heightList = [ 100, 300, 150, 20, 20, 10, 250, 30 ]

    end = xList.length - 1
    for i in [end..0]
      walls.add( @create_wall_sprite(game, xList[i], yList[i], widthList[i], heightList[i]) )

    return walls

  create_wall_sprite: (game, x, y, width, height) ->
    # Compute that left, right, top and bottom coordinates
    # relative to the center of our wall (which is a rectangle
    # centered at (x, y)).
    left = -width / 2
    right = width / 2
    top = -height / 2
    bottom = height / 2

    # Create the graphics for the sprite
    graphics = game.add.graphics 0, 0
    graphics.lineStyle 0
    graphics.beginFill 0x000000
    graphics.moveTo left, top
    graphics.lineTo right, top
    graphics.lineTo right, bottom
    graphics.lineTo left, bottom
    graphics.lineTo left, top
    graphics.endFill
    window.graphics = graphics

    # Create the sprite and add the graphic to it
    sprite = game.add.sprite(x, y)
    sprite.addChild(graphics)
    sprite.enableBody = true

    return sprite

module.exports = MapGenerator