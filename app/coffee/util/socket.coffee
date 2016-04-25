# We have to put this in a separate class because we need to pass the same
# socket to different states, but Phaser does not let us pass arguments
# into the constructor for states
socket = io()

class Socket
  constructor: ->

  getSocket: ->
    return socket

  # Turn off "bigscreen responses" to these sockets
  # TODO(kpeng94): check if this is actually necessary; currently unused.
  turnOffBigscreenSockets: ->
    socket.off('player joined')
    socket.off('player left')
    socket.off('main')
    socket.off('rotate')
    socket.off('fire')
    socket.off('setup-player-scores')
    socket.off('update-player-score')

module.exports = Socket
