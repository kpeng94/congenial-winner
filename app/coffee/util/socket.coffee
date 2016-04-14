# We have to put this in a separate class because we need to pass the same
# socket to different states, but Phaser does not let us pass arguments
# into the constructor for states
socket = io()

class Socket
  constructor: ->

  getSocket: ->
    return socket

module.exports = Socket
