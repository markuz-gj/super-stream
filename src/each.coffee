{Transform} = require "readable-stream"


isNull = require "lodash-node/modern/objects/isNull"
once = require "lodash-node/modern/functions/once"
defaults = require "lodash-node/modern/objects/defaults"

# created fake npm package
through = require "super-stream/through"

factory = (cfg) ->
  th2 = through.factory cfg

  return ->
    stream = th2.apply th2, arguments
    if arguments.length is 0 then return stream

    stream._each = stream._transform
    stream._transform = (f,e,n) ->
      next = once n
      stream?._each?.next = next
      if !isNull stream._each(f, e, next)
        next()

    return stream

module.exports = factory()
module.exports.factory = factory


