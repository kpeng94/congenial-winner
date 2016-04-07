#!/usr/bin/env node

express = require 'express'
app = express()
path = require 'path'
port = process.env.PORT or '3001'
app.set 'port', port
app.use express.static(path.join(__dirname, '../dist'))

http = require 'http';
server = http.createServer(app);
socketio = require 'socket.io'
io = socketio(server)
runGameServer = require './server.coffee'
runGameServer(io)

server.listen(port, '0.0.0.0')