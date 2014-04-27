
{Transform} = require "readable-stream"

once = require "lodash-node/modern/functions/once"

# created fake npm package
through = require "super-stream/through"
isNoop = require "super-stream/isNoop"

factory = (cfg) ->
  th2 = through.factory cfg
  
  fn = ->
    scope = {}
    scope.stream = Object.create(null)
    stream = th2.apply th2, arguments

    if isNoop(arguments) then return stream

    stream._reduce = stream._transform


    stream._transform = (chunk,e,n) ->
      next = once n
      stream._flush = null
      stream._transform.next = next
      push = @push
      scope.stream.flush = (data) ->
        scope.stream = Object.create null
        next null, data

      stream._reduce.call(scope.stream, chunk, e)
      next()
      
    return stream

  fn.factory = factory
  return fn

module.exports = factory()
