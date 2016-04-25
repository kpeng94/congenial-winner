Phaser = require 'Phaser'
config = require '../config.coffee'
Wall = require './wall.coffee'
BORDER_WALL_SIZE = 4

class MapLoader

  generateMap1: (game, jsonObject) ->
    console.log 'Map 1 generated'
    walls = game.add.group()
    walls.enableBody = true
    for wall in jsonObject.walls
      console.log wall
      walls.add( @create_wall_sprite(game, wall.x, wall.y, wall.width, wall.height, wall.angle) )
    @addBorderWalls(game, walls)
    return walls

  create_wall_sprite: (game, x, y, width, height, angle) ->

    # Create the sprite and add the graphic to it
    wall = new Wall game, x, y, width, height
    game.physics.p2.enable wall
    wall.body.static = true
    wall.body.angle = angle
    #wall.body.rotation = angle
    console.log wall
    return wall

  addBorderWalls: (game, walls) ->
    # Walls for the border: top, left, bottom, right
    borderXList = [0, 0, 0, config.width - BORDER_WALL_SIZE]
    borderYList = [0, 0, config.height - BORDER_WALL_SIZE, 0]
    borderWidthList = [config.width, BORDER_WALL_SIZE, config.width, BORDER_WALL_SIZE]
    borderHeightList = [BORDER_WALL_SIZE, config.height, BORDER_WALL_SIZE, config.height]

    for i in [0...borderXList.length]
      walls.add(@create_wall_sprite(game, borderXList[i], borderYList[i],
                                    borderWidthList[i], borderHeightList[i], 0))

module.exports = MapLoader
