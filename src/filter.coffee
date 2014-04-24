
{Transform} = require "readable-stream"

through = require "./through"
isNull = require "lodash-node/modern/objects/isNull"
once = require "lodash-node/modern/functions/once"
{Promise} = require "es6-promise"

filter = {}
filter.factory = factory = (cfg) ->

  return ->
    stream = through.apply through, arguments
    stream._filter = stream._transform

    if arguments.length is 0 then return stream
    
    stream._flush = null

    # async = new Promise (revolve, reject) ->


    stream._transform = (f,e,n) ->
      next = once n
      stream._filter.next = next

      retValue = stream._filter.call(Object.create(null), f, e)

      if !!retValue then @push f
      next()

    return stream

module.exports = filter.factory()