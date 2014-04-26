{Transform} = require "readable-stream"

through2 = require "through2"
isFunction = require "lodash-node/modern/objects/isFunction"
defaults = require "lodash-node/modern/objects/defaults"

factory = (cfg = {}) ->
  fn = (opts, transform, flush) ->
    if isFunction opts
      flush = transform
      transform = opts
      opts = cfg
    else
      opts = defaults opts, cfg

    if arguments.length is 0
      opts = cfg

    return through2 opts, transform, flush

  fn.factory = factory
  for own k, v of through2
    fn[k] = v

  return fn

module.exports = factory()
