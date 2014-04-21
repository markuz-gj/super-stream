
platformStream = require "stream"
domain = require "domain"

{Transform} = require "readable-stream"
Plexer = require "plexer"
{isFunction, isArray, isNull, isObject} = require "core-util-is"

util = require "util"

##

noopTransform = (c, e, n) ->
  @push c
  n()

class Domain
  constructor: ->
    return domain.create()

isTransform = (stream) ->
  # place holder for now
  return !!stream

isReadable = (stream) ->
  # place holder for now
  return !!stream

isWritable = (stream) ->
  # place holder for now
  return !!stream

isDuplex = (stream) ->
  # place holder for now
  return !!stream

isJunction = (stream) ->
  # place holder for now
  return !!stream

isPipeline = (stream) ->
  # place holder for now
  return !!stream

patch = (stream, domain) ->
  if not (isTransform stream)
    return

  if not domain
    exportDomain = yes
    domain = new Domain()
    domain.on "error", (e) -> console.log "EE:patch domain", e

  if isTransform stream
    for i, fn of stream
      do (i, fn) ->
        if isFunction(fn) and !stream[i]?._patched
          stream[i] = domain.bind ->
            self = @
            try
              stream[i]._original.apply stream, arguments
            catch e
              domain.emit "error", e
            
          stream[i]._original = fn

  if exportDomain then stream._domain = domain

  return stream

cloneStream = (stream) ->
  console.log "cloning stream ...."

cloneJunction = (jnt) ->

clonePipeline = (jnt) ->

s  constructor: (opts = {}) ->
    if not @ instanceof BaseTransform
      return new BaseTransform opts

    Transform.call @, opts
    @_transform = noopTransform
    return @

class CloneStream extends BaseTransform
  constructor: (opts, stream) ->
    if not @ instanceof CloneStream
      return new CloneStream opts, stream

    self = @
    console.log "CloneStream ....."
    BaseTransform.call self, opts

    for i, fn of stream
      do (i, fn) ->
        if isFunction(fn)
          self[i] = fn.bind self 

    return self

class Clone 
  constructor: (opts = {}) ->
    return (stream) ->
      if isTransform stream
        st = new CloneStream opts, stream
        # console.log st



class Each
  constructor: (opts) ->
    return (transform) ->
      stream = new BaseTransform opts

      stream._each = transform
      stream._transform = (file, enc, next) ->
        @_each.next = do ->
          counter = 0
          ->
            if counter isnt 0
              return

            counter++
            next.apply next, arguments

        retFn = @_each.call @, file, enc, @_each.next

        if !isNull retFn then @_each.next()
        return retFn
      return stream

class Batch
  constructor: (opts) ->

class Map
  constructor: (opts) ->

class Reduce
  constructor: (opts) ->
    createCtx = ->
      ctx = Object.create null

      ctx._stack = []
      ctx.pushR = (chunk) -> return @_stack.push chunk
      ctx.pushL = (chunk) -> return @_stack.unshift chunk

      return ctx
    
    return (transform) ->
      stream = new BaseTransform opts
      ctx = createCtx()

      stream._reduce = transform

      stream._transform = (chunk, enc, next) ->
        oldPush = @push
        self = @
        @push = ->
          oldPush.call @, @_stack
          self = createCtx()

        retValue = @_reduce.call ctx, chunk

        # if isNull retValue
          # @push ctx._stack
        
        next()
        return retValue

class Filter
  constructor: (opts) ->

class BaseDuplex
  constructor: (opts = {}, writable, readable) ->
    if not @ instanceof BaseDuplex
      return new BaseDuplex opts

    writable ?= new BaseTransform opts
    readable ?= new BaseTransform opts
    return new Plexer opts, writable, readable

class Junction
  constructor: (opts, domain) ->
    if not @ instanceof Junction
      return new Junction opts
    
    domain ?= new Domain()
    domain.on "error", (err) -> console.log "EE: junction domain", err

    writable = new BaseTransform opts
    readable = new BaseTransform opts
    proto = new BaseDuplex(opts, writable, readable)

    Jnt = ->
    Jnt:: = proto
    jnt = new Jnt()

    jnt._entry = (c, e, n) ->
      console.log "entry...", c
      @push c
      n()

    jnt._exit = (c, e, n) ->
      console.log "exit...", c
      @push c
      n()

    jnt._writable._transform = domain.bind -> return jnt._entry.apply @, arguments
    jnt._readable._transform = domain.bind -> return jnt._exit.apply @, arguments

    patch proto, domain
    patch writable, domain
    patch readable, domain

    jnt._domain = domain

    return jnt

class Pipeline
  constructor: (opts) ->
    if not @ instanceof Pipeline
      return new Pipeline opts

    return (jnt, streams) ->
      if !streams
        streams = jnt
        jnt = new Junction opts

      jnt._sections = streams

      for st, i in jnt._sections
        do (st, i) ->
          stA = st

          stA.on "error", (err) -> jnt.emit "error", err

          if i is 0
            jnt._writable.pipe stA

          if i is jnt._sections.length - 1
            return stA.pipe jnt._readable

          stB = jnt._sections[i + 1]
          stA.pipe stB

      return jnt

class SuperStream
  constructor: (opts) ->

    return {
      SuperStream: SuperStream #
      Duplexer: BaseDuplex #

      patch: patch #
      clone: new Clone opts

      each: new Each opts #
      batch: new Batch opts

      map: new Map opts
      reduce: new Reduce opts
      filter: new Filter opts

      pipeline: new Pipeline opts #
      junction: new Junction opts #

      isTransform: isTransform
      isReadable: isReadable
      isWritable: isWritable
      isDuplex: isDuplex

      isJunction: isJunction
      isPipeline: isPipeline
    }


module.exports = exports = new SuperStream()