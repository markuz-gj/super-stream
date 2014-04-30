
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
{Junction} = require "super-stream/junction"

factory = (cfg = {}) ->
  th2 = through.factory cfg

  fn = (opts, jnt, streams) -> 
    if isArray opts
      streams = opts
      opts = cfg
      jnt = new Junction opts

    else if isJunction opts
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

    jnt._sections = streams

    for st, i in jnt._sections
      do (st, i) =>
        stA = st

        stA.on "error", (err) -> jnt.emit "error", err

        if i is 0
          jnt._writable.pipe stA

        if i is jnt._sections.length - 1
          return stA.pipe jnt._readable

        stB = jnt._sections[i + 1]
        stA.pipe stB

    return jnt

  fn.factory = factory

  return fn

module.exports = factory()
