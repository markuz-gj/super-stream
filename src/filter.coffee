
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
    stream._filter = stream._transform

    stream._transform = (c,e,n) ->
      next = once n
      stream._flush = null
      stream._filter.next = next

      if !!stream._filter.call(Object.create(null), c, e) 
        return next(null, c)
      
      return next()

    return stream

  fn.factory = factory
  return fn

module.exports = factory()
