
{Transform} = require "readable-stream"


isNull = require "lodash-node/modern/objects/isNull"
once = require "lodash-node/modern/functions/once"
{Promise} = require "es6-promise"

# created fake npm package
through = require "through"

factory = (cfg) ->
  return ->
    stream = through.apply through, arguments
    stream._filter = stream._transform

    if arguments.length is 0 then return stream

    stream._flush = null

    stream._transform = (f,e,n) ->
      next = once n
      stream._filter.next = next

      retValue = stream._filter.call(Object.create(null), f, e)

      if !!retValue then @push f
      next()

    return stream

module.exports = factory()
module.exports.factory = factory
