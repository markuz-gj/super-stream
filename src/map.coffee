
{Transform} = require "readable-stream"

once = require "lodash-node/modern/functions/once"

# created fake npm package
through = require "super-stream/through"
isNoop = require "super-stream/isNoop"

factory = (cfg) ->
  th2 = through.factory cfg
  
  fn = ->
    stream = th2.apply th2, arguments
    if isNoop(arguments) then return stream

    stream._flush = null
    stream._map = stream._transform

    stream._transform = (f,e,n) ->
      next = once n
      stream._flush = null
      stream._map.next = next
      ret = stream._map.call(Object.create(null), f, e)
      next(null, ret)

    return stream

  fn.factory = factory
  return fn

module.exports = factory()
