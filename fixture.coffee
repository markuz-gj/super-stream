through = require "super-stream.through"
sinon = require "sinon"
{Promise} = require "es6-promise"


### istanbul ignore next ###
spy = (stream) ->
  if spy.free.length is 0
    agent = sinon.spy()
  else
    agent = spy.free.pop()
    agent.reset()

  spy.used.push agent
  fn = stream._transform
  stream.spy = agent

  stream._transform = (c) ->
    agent c
    fn.apply @, arguments

  return agent

spy.free = []
spy.used = []

### istanbul ignore next ###
extendCtx = (fn) ->
  @thr = fn.factory @optA
  @thrX = fn.factory @optB

  @noop = @thr()

  @stA = @thr()
  @stB = @thr @optA

  spy @stA
  spy @stB

  @streamsArray = [@stA, @stB, @stX, @stY, @stZ]
  @dataArray = [@data1, @data2]
  
bufferMode = 
  desc: 'streams in buffer mode:'
  ### istanbul ignore next ###
  before: (fn) ->
    ->
      @optA = {}
      @optB = {objectMode: yes}
      @data1 = new Buffer "data1"
      @data2 = new Buffer "data2"

      @stX = fn.buf()
      spy @stX

      @stY = fn.buf (c,e,n) -> n(null, c)
      spy @stY

      ctor = fn.ctor @optA, (c,e,n) -> n(null, c)
      @stZ = ctor()  
      spy @stZ    

      extendCtx.call @, fn
      return @

  ### istanbul ignore next ###
  after: ->
    for agent in spy.used
      spy.free.push spy.used.pop()

objectMode = 
  desc: 'streams in object mode:'
  ### istanbul ignore next ###
  before: (fn) ->
    ->
      @optA = {objectMode: yes}
      @optB = {}
      @data1 = "data1"
      @data2 = "data2"

      @stX = fn.obj()
      spy @stX

      @stY = fn.obj (c,e,n) -> n(null, c)
      spy @stY

      ctor = fn.ctor @optA, (c,e,n) -> n(null, c)
      @stZ = ctor()  
      spy @stZ    

      extendCtx.call @, fn
      return @
    
  ### istanbul ignore next ###
  after: ->
    for agent in spy.used
      spy.free.push spy.used.pop()

### istanbul ignore next ###
Deferred = () ->
  @promise = new Promise (resolve, reject) =>
    @resolve_ = resolve
    @reject_ = reject

  return @

### istanbul ignore next ###
Deferred::resolve = -> @resolve_.apply @promise, arguments

### istanbul ignore next ###
Deferred::reject = -> @reject_.apply @promise, arguments

### istanbul ignore next ###
Deferred::then = -> @promise.then.apply @promise, arguments

### istanbul ignore next ###
Deferred::catch = -> @promise.catch.apply @promise, arguments

module.exports =
  bufferMode: bufferMode
  objectMode: objectMode
  Deferred: Deferred
