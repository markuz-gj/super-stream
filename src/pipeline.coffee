
{Transform, Duplex} = require "readable-stream"

once = require "lodash-node/modern/functions/once"

Plexer = require "plexer"
isFunction = require "lodash-node/modern/objects/isFunction"
isArray = require "lodash-node/modern/objects/isArray"
defaults = require "lodash-node/modern/objects/defaults"

inherits = require "inherits"

{isReadable, isTransform, isStream, isWritable} = require "./isStream"

# created fake npm package
through = require "super-stream/through"
{Junction} = require "super-stream/junction"

factory = (cfg = {}) ->
  th2 = through.factory cfg

  Pipeline = (opts, jnt, streams) ->
    if not @ instanceof Pipeline
      return new Pipeline opts

    if isArray opts
      streams = opts
      opts = cfg
      jnt = new Junction opts

    else if opts instanceof Junction
      if isArray jnt
        streams = jnt
      else
        streams = [through cfg]
      jnt = opts
      opts = cfg 

    else if !opts
      opts = cfg

    if not jnt instanceof Junction
      jnt = new Junction opts

    if !isArray streams
      streams = [through opts]

    Junction.call @, opts

    @_sections = streams

    for st, i in @_sections
      do (st, i) =>
        stA = st

        stA.on "error", (err) -> jnt.emit "error", err

        if i is 0
          @_writable.pipe stA

        if i is @_sections.length - 1
          return stA.pipe @_readable

        stB = @_sections[i + 1]
        stA.pipe stB

    return @

  inherits Pipeline, Junction

  fn = (opts, streams) ->
    jnt = junction 
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

  fn = (opts, jnt, streams) -> return new Pipeline opts, jnt, streams
  fn.factory = factory
  fn.Pipeline = Pipeline

  return fn

module.exports = factory()
