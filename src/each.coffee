{Transform} = require "readable-stream"

isNull = require "lodash-node/modern/objects/isNull"
once = require "lodash-node/modern/functions/once"

# created fake npm package
through = require "super-stream/through"
isNoop = require "super-stream/isNoop"

factory = (cfg) ->
  th2 = through.factory cfg

  fn = ->
    stream = th2.apply th2, arguments
    if isNoop(arguments) then return stream

    stream._each = stream._transform
    stream._ = Object.create null

    stream._transform = (chunk,e,n) ->
      next = once n
      stream.next = next
      if not isNull stream._each(chunk, e, next)
        return next()

    return stream

  fn.factory = factory
  return fn

module.exports = factory()


