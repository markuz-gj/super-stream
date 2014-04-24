{Transform} = require "readable-stream"


isNull = require "lodash-node/modern/objects/isNull"
once = require "lodash-node/modern/functions/once"

# created fake npm package
through = require "through"

factory = (cfg) ->
  return ->
    stream = through.apply through, arguments
    stream._each = stream._transform

    if arguments.length is 0 then return stream

    stream._transform = (f,e,n) ->
      next = once n
      stream._each.next = next
      if !isNull stream._each(f, e, next)
        next()

    return stream

module.exports = factory()
module.exports.factory = factory


