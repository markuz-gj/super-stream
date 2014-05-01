
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

CFG = null
TH = null
Junction = (opts, entry, exit) ->
  if not @ instanceof Junction
    return new Junction opts, entry, exit

  if isTransform opts
    exit = entry
    entry = opts
    opts = CFG

  else if isObject opts
    opts = defaults opts, CFG

  else if !opts
    opts = CFG

  if !isTransform entry
    if !!entry then throw new Error "entry stream must be an instanceof Transform"
    entry = TH opts

  if !isTransform exit
    if !!exit then throw new Error "exit stream must be an instanceof Transform"
    exit = TH opts

  @entry = entry
  @exit = exit
  @_entry = entry._transform
  @_exit = exit._transform

  @_opts = opts
  Plexer.call @, opts, entry, exit

  ctx = @
  @_writable._transform = -> return ctx?._entry?.apply @, arguments
  @_readable._transform = -> return ctx?._exit?.apply @, arguments

  return @

inherits Junction, Plexer

factory = (cfg = {}) ->
  CFG = cfg
  TH = through.factory cfg

  fn = (opts, entry, exit) -> return new fn.Junction opts, entry, exit  

  fn.factory = factory
  fn.Junction = Junction

  return fn

module.exports = factory()
