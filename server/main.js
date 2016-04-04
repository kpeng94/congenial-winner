#!/usr/bin/env node

var express = require('express');
var app = express();
var path = require('path');
var port = process.env.PORT || '3001';
app.set('port', port);
app.use(express.static(path.join(__dirname, '../public')));

var http = require('http');
var server = http.createServer(app);
var io = require('socket.io')(server);
var gameServer = require('./server.js')(io);

server.listen(port, '0.0.0.0');
