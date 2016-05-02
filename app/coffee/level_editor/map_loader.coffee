Phaser = require 'Phaser'
config = require '../config.coffee'
Wall = require './wall.coffee'
BORDER_WALL_SIZE = 4

class MapLoader

  generateMap1: (game, jsonObject) ->
    console.log 'Map 1 generated'
    walls = game.add.group()
    #walls.enableBody = true
    for wall in jsonObject.walls
      wallSprite = @create_wall_sprite(game, wall.x, wall.y, wall.width, wall.height)
      walls.add wallSprite
    @addBorderWalls(game, walls)
    return walls

  create_wall_sprite: (game, x, y, width, height) ->

    # Create the wall object
    wall = new Wall game, x, y, width, height
    # Enables p2 physics
    game.physics.arcade.enable wall
    #wall.body.x = Math.round wall.x
    #wall.body.y = Math.round wall.y
    widthOffset = wall.width
    heightOffset = wall.height
    #wall.body.offset = new Phaser.Point -widthOffset / 2, -heightOffset / 2
    wall.body.immovable = true
    console.log wall
    return wall

  addBorderWalls: (game, walls) ->
    # Walls for the border: top, left, bottom, right
    borderXList = [0, 0, 0, config.width - BORDER_WALL_SIZE * 2]
    borderYList = [0, 0, config.height - BORDER_WALL_SIZE * 2, 0]
    borderWidthList = [config.width, BORDER_WALL_SIZE, config.width, BORDER_WALL_SIZE]
    borderHeightList = [BORDER_WALL_SIZE, config.height, BORDER_WALL_SIZE, config.height]

    for i in [0...borderXList.length]
      console.log borderXList[i], borderYList[i], borderWidthList[i], borderHeightList[i], 0
      walls.add(@create_wall_sprite(game, borderXList[i], borderYList[i],
                                    2 * borderWidthList[i], 2 * borderHeightList[i]))

module.exports = MapLoader
