# General utilities that there are not enough of to belong elsewhere

class Util
  getRandomInt: (min, max) ->
    Math.floor(Math.random() * (max - min)) + min

  generateRandomColor: ->
    letters = '0123456789ABCDEF'.split('')
    color = '#'
    for i in [0...6]
      color += letters[Math.floor(Math.random() * 16)]
    return color

  # Strip off the "#" and use parseInt().
  formatColor: (color) ->
    hex = parseInt(color.replace(/^#/, ''), 16)

  removeFromArray: (array, element) ->
    elementIndex = array.indexOf(element)
    if elementIndex > -1
      array.splice(elementIndex, 1)

module.exports = Util