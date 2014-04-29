
{Transform, Duplex} = require "readable-stream"

once = require "lodash-node/modern/functions/once"

Plexer = require "plexer"
isFunction = require "lodash-node/modern/objects/isFunction"
defaults = require "lodash-node/modern/objects/defaults"

inherits = require "inherits"

{isReadable, isTransform, isStream, isWritable} = require "./isStream"

# created fake npm package
through = require "super-stream/through"
junction = require "super-stream/junction"

factory = (cfg = {}) ->
  th2 = through.factory cfg


  Pipeline = (opts = {}, streams = []) ->
    if not @ instanceof Pipeline
      return new Pipeline opts

    entry = th2 opts
    exit = th2 opts
    junction.Junction @, opts, entry, exit


  inherits Pipeline, junction.Junction


  fn = (opts, streams) ->
    console.log "SSSS"
    return new Pipeline opts, streams

  fn.factory = factory
  fn.Pipeline = Pipeline


  # pipeline = (opts, streams) ->
  #   jnt = junction 
  #   jnt._sections = streams

  #   for st, i in jnt._sections
  #     do (st, i) ->
  #       stA = st

  #       stA.on "error", (err) -> jnt.emit "error", err

  #       if i is 0
  #         jnt._writable.pipe stA

  #       if i is jnt._sections.length - 1
  #         return stA.pipe jnt._readable

  #       stB = jnt._sections[i + 1]
  #       stA.pipe stB

  #   return jnt

  return fn

module.exports = factory()
