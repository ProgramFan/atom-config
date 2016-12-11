engine    = null
eioClient = null
minimatch = null
log       = null
configHelper = require './imdone-config'

# DONE: implement socket server to handle opening files in configured client issue:48 id:18
module.exports =
  clients: {}
  init: (port) ->
    return @ unless @getConfig().openIn.enable
    return @ if @isListening
    engine    = require 'engine.io'
    eioClient = require 'engine.io-client'
    minimatch = require 'minimatch'
    log       = require './log'
    # DONE: Check if something else is listening on port issue:51 id:19
    http = require('http').createServer()
    http.on 'error', (err) =>
      if (err.code == 'EADDRINUSE')
        #console.log 'port in use'
        @tryProxy port
      log err
    http.listen port, =>
      @server = engine.attach(http);
      @server.on 'connection', (socket) =>
        socket.send JSON.stringify(imdone: 'ready')
        socket.on 'message', (msg) =>
          @onMessage socket, msg
        socket.on 'close', () =>
          editor = (key for key, value of @clients when value == socket)
          delete @clients[editor] if editor
      @isListening = true
      @proxy = undefined
    @

  tryProxy: (port) ->
    # DONE: First check if it's imdone listening on the port issue:52 id:20
    # DONE: if imdone is listening we should connect as a client and use the server as a proxy issue:52 id:21
    # BACKLOG: if imdone is not listening we should ask for another port issue:52 id:22
    log 'Trying proxy'
    socket = eioClient('ws://localhost:' + port)
    socket.on 'open', =>
      socket.send JSON.stringify(hello: 'imdone')
    socket.on 'message', (json) =>
      msg = JSON.parse json
      log 'Proxy success'
      @proxy = socket if msg.imdone
    socket.on 'close', =>
      log 'Proxy server closed connection.  Trying to start server'
      @init port

  onMessage: (socket, json) ->
    try
      msg = JSON.parse json
      if (msg.hello)
        @clients[msg.hello] = socket
      if (msg.isProxied)
        @openFile msg.project, msg.path, msg.line, () ->
      log 'message received:', msg
    catch error
      #console.log 'Error receiving message:', json

  openFile: (project, path, line, cb) ->
    return cb() unless @getConfig().openIn.enable
    editor = @getEditor path
    # DONE: only send open request to editors who deserve them issue:48 id:23
    socket = @getSocket editor
    return cb() unless socket
    isProxied = if @proxy then true else false
    socket.send JSON.stringify({project, path, line, isProxied}), () ->
      cb(true)

  getEditor: (path) ->
    openIn = @getConfig().openIn
    for editor, pattern of openIn
      if pattern
        return editor if minimatch(path, pattern, {matchBase: true})
    "atom"

  getSocket: (editor) ->
    return @proxy if @proxy && editor != 'atom'
    socket = @clients[editor]
    return null unless socket && @server.clients[socket.id] == socket
    socket

  getConfig: () -> configHelper.getSettings()
