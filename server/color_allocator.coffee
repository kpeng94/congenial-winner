visuallyDistinguishableColors = require('./colors.coffee')

class ColorAllocator
  '''
  A color allocator. An instance of this class is responsible for managing
  colors. It tries to guarantee that the colors it allocates are visually
  distinguishable from each other.

  All colors are expressed as string values.
  '''
  constructor: ->
    @colorUsageMap = {}
    visuallyDistinguishableColors.forEach (color) => @colorUsageMap[color] = false

  allocateColor: ->
    '''Allocates a color for use.

    Returns:
      str: a color that is visually distinguishable from other colors that
        might be allocated by this allocator

      If there are no more colors left to allocate, then the color black is
      returned
    '''
    for color in visuallyDistinguishableColors
      if not @colorUsageMap[color]
        @colorUsageMap[color] = true
        return color
    return '#000000' # by default return black when no more colors left


  retrieveColor: (color) ->
    '''Receives back a color that the allocator may allocate out again.

    Args:
      color (str): a previously allocated color that is no longer used
    '''
    @colorUsageMap[color] = false

module.exports = ColorAllocator
