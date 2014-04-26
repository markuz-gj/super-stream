
{Transform} = require "readable-stream"


isNull = require "lodash-node/modern/objects/isNull"
once = require "lodash-node/modern/functions/once"

# created fake npm package
through = require "super-stream/through"

factory = (cfg) ->
  th2 = through.factory cfg
  
  return ->
    stream = th2.apply th2, arguments
    if arguments.length is 0 then return stream

    stream._flush = null
    stream._filter = stream._transform

    stream._transform = (f,e,n) ->
      next = once n
      stream._flush = null
      stream._filter.next = next

      if !!stream._filter.call(null, f, e) then @push f
      next()

    return stream

module.exports = factory()
module.exports.factory = factory
