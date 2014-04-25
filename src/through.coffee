{Transform} = require "readable-stream"

through2 = require "through2"
isFunction = require "lodash-node/modern/objects/isFunction"
defaults = require "lodash-node/modern/objects/defaults"

factory = (cfg = {}) ->
  iterator = (opts, transform, flush) ->
    if isFunction opts
      flush = transform
      transform = opts
      opts = cfg
    else
      opts = defaults opts, cfg

    if arguments.length is 0
      opts = cfg


    return through2 opts, transform, flush

  iterator.factory = factory
  for own k, v of through2
    iterator[k] = v

  return iterator

module.exports = factory()
