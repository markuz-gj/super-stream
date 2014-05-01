
{Transform, Duplex} = require "readable-stream"

once = require "lodash-node/modern/functions/once"

Plexer = require "plexer"
isFunction = require "lodash-node/modern/objects/isFunction"
isArray = require "lodash-node/modern/objects/isArray"
defaults = require "lodash-node/modern/objects/defaults"

inherits = require "inherits"

{isReadable, isTransform, isStream, isWritable, isJunction} = require "./isStream"

# created fake npm package
through = require "super-stream/through"
junction = require "super-stream/junction"

{Junction} = junction

factory = (cfg = {}) ->
  th2 = through.factory cfg

  fn = (opts, jnt, streams) -> 
    if isArray opts
      streams = opts
      opts = cfg
      jnt = new Junction opts

    else if isJunction(opts)
      if isArray jnt
        streams = jnt
      else
        streams = [through cfg]
      jnt = opts
      opts = cfg 

    else if !opts
      opts = cfg

    if !isJunction jnt
      jnt = new Junction opts

    if !isArray streams
      streams = [through opts]

    jnt._sections ?= []
    jnt._sections.push streams

    for st, i in streams
      do (st, i) =>
        stA = st

        stA.on "error", (err) -> jnt.emit "error", err

        if i is 0
          jnt._writable.pipe stA

        if i is streams.length - 1
          return stA.pipe jnt._readable

        stB = streams[i + 1]
        stA.pipe stB

    return jnt

  fn.factory = factory
  return fn

module.exports = factory()
