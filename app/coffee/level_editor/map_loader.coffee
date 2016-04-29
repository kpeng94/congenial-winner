Phaser = require 'Phaser'
config = require '../config.coffee'
Wall = require './wall.coffee'
BORDER_WALL_SIZE = 10

class MapLoader

  generateMap1: (game, jsonObject) ->
    console.log 'Map 1 generated'
    walls = game.add.group()
    #walls.enableBody = true
    for wall in jsonObject.walls
      console.log wall
      wallSprite = @create_wall_sprite(game, wall.x, wall.y, wall.width, wall.height, wall.angle)
      walls.add wallSprite
    @addBorderWalls(game, walls)
    return walls

  create_wall_sprite: (game, x, y, width, height, angle) ->

    # Create the wall object
    wall = new Wall game, x, y, width, height
    # Enables p2 physics
    game.physics.p2.enableBody wall, false
    wall.body.x = Math.round wall.x
    wall.body.y = Math.round wall.y
    wall.body.angle = angle
    # Offsets the Collision box
    sin = Math.sin wall.body.rotation
    cos = Math.cos wall.body.rotation
    widthOffset = wall.width * cos - wall.height * sin
    heightOffset = wall.height * cos + wall.width * sin
    wall.body.offset = new Phaser.Point -widthOffset / 2, -heightOffset / 2
    #Nullifies any movement
    wall.body.setZeroDamping()
    wall.body.fixedRotation = false
    wall.body.static = true
    return wall

  addBorderWalls: (game, walls) ->
    # Walls for the border: top, left, bottom, right
    borderXList = [0, BORDER_WALL_SIZE, 0, config.width - BORDER_WALL_SIZE]
    borderYList = [BORDER_WALL_SIZE, 0, config.height - BORDER_WALL_SIZE, 0]
    borderWidthList = [config.width, BORDER_WALL_SIZE, config.width, BORDER_WALL_SIZE]
    borderHeightList = [BORDER_WALL_SIZE, config.height, BORDER_WALL_SIZE, config.height]

    for i in [0...borderXList.length]
      console.log borderXList[i], borderYList[i], borderWidthList[i], borderHeightList[i], 0
      walls.add(@create_wall_sprite(game, borderXList[i], borderYList[i],
                                    2 * borderWidthList[i], 2 * borderHeightList[i], 0))

module.exports = MapLoader
