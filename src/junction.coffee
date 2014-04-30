
{Transform, Duplex} = require "readable-stream"

once = require "lodash-node/modern/functions/once"

# created fake npm package
through = require "super-stream/through"
isNoop = require "super-stream/isNoop"

Plexer = require "plexer"
isFunction = require "lodash-node/modern/objects/isFunction"
isObject = require "lodash-node/modern/objects/isObject"
defaults = require "lodash-node/modern/objects/defaults"

inherits = require "inherits"

{isReadable, isTransform, isStream, isWritable} = require "./isStream"

factory = (cfg = {}) ->
  th2 = through.factory cfg

  Junction = (opts, entry, exit) ->
    if not @ instanceof Junction
      return new Junction opts, entry, exit

    if isTransform opts
      exit = entry
      entry = opts
      opts = cfg

    else if isObject opts
      opts = defaults opts, cfg

    else if !opts
      opts = cfg

    if !isTransform entry
      if !!entry then throw new Error "entry stream must be an instanceof Transform"
      entry = th2 opts

    if !isTransform exit
      if !!exit then throw new Error "exit stream must be an instanceof Transform"
      exit = th2 opts

    @entry = entry
    @exit = exit
    @_entry = entry._transform
    @_exit = exit._transform

    @_opts = opts
    Plexer.call @, opts, entry, exit

    ctx = @
    @_writable._transform = -> return ctx._entry.apply @, arguments
    @_readable._transform = -> return ctx._exit.apply @, arguments

    return @

  inherits Junction, Plexer

  fn = (opts, entry, exit) -> return new Junction opts, entry, exit  

  fn.factory = factory
  fn.Junction = Junction

  return fn

module.exports = factory()
