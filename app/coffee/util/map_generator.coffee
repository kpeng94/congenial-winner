Phaser = require 'Phaser'
config = require '../../../config/config.coffee'

BORDER_WALL_SIZE = 4

LEVELS = {
  '1': {
    xList: [ 40, 280, 530, 1060, 930, 530, 800, 270 ],
    yList: [ 400, 400, 530, 70, 530, 280, 200, 100 ],
    widthList: [ 10, 10, 20, 70, 300, 100, 20, 200 ],
    heightList: [ 100, 300, 150, 20, 20, 10, 250, 30 ],
  }
}

class MapGenerator
  generateMap: (game, level) ->
    walls = game.add.group()
    walls.enableBody = true

    if LEVELS[level]?
      xList = LEVELS[level].xList
      yList = LEVELS[level].yList
      widthList = LEVELS[level].widthList
      heightList = LEVELS[level].heightList

      end = xList.length - 1
      for i in [end..0]
        walls.add( @_create_wall_sprite(game, xList[i], yList[i], widthList[i], heightList[i]))

    @_addBorderWalls(game, walls)
    return walls

  _create_wall_sprite: (game, x, y, width, height) ->
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
    game.physics.enable(sprite, Phaser.Physics.ARCADE)
    sprite.addChild(graphics)
    sprite.body.immovable = true
    sprite.body.setSize(width, height, left, top)
    sprite.enableBody = true

    return sprite

  _addBorderWalls: (game, walls) ->
    # Walls for the border: top, left, bottom, right
    borderXList = [config.width / 2, BORDER_WALL_SIZE / 2,
                   config.width / 2, config.width - BORDER_WALL_SIZE / 2]
    borderYList = [BORDER_WALL_SIZE / 2, config.height / 2,
                   config.height - BORDER_WALL_SIZE / 2, config.height / 2]
    borderWidthList = [config.width, BORDER_WALL_SIZE, config.width, BORDER_WALL_SIZE]
    borderHeightList = [BORDER_WALL_SIZE, config.height, BORDER_WALL_SIZE, config.height]

    for i in [0...borderXList.length]
      walls.add(@_create_wall_sprite(game, borderXList[i], borderYList[i],
                                    borderWidthList[i], borderHeightList[i]))

module.exports = MapGenerator
