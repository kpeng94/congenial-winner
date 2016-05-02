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

  getDictLength: (dict) ->
    return Object.keys(dict).length

  sortDictionaryByValue: (dictionary) ->
    array = []
    for key, value of dictionary
      array.push([key, value])
    # sorts by greatest to least
    array.sort (a, b) ->
      return b[1] - a[1]

    keys_array = []
    for item in array
      keys_array.push(item[0])
    return keys_array

  # Convert minute seconds to seconds
  getMinSecFromSec: (seconds) ->
    min = Math.floor(seconds / 60)
    sec = seconds % 60
    return [min, sec]

  getSecFromMillsec: (milliseconds) ->
    return Math.floor(milliseconds / 1000)

  getMinSecFromMillisec: (milliseconds) ->
    seconds = @getSecFromMillsec(milliseconds)
    return @getMinSecFromSec(seconds)


module.exports = Util
