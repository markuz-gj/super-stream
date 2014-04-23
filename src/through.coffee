{Transform} = require "readable-stream"

through2 = require "through2"
isFunction = require "lodash-node/modern/objects/isFunction"

# factory = (cfg = {}) -> 
#   return (opts, transform, flush) ->
#     if isFunction opts
#       flush = transform
#       transform = opts
#       opts = cfg

#     if !isFunction transform
#       transform = noopTransform

#     if !isFunction flush
#       flush = null

#     return through2 opts, transform, flush


through = through2
through.factory = through2.ctor

module.exports = through
