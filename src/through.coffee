{Transform} = require "readable-stream"

through2 = require "through2"
isFunction = require "lodash-node/modern/objects/isFunction"

through = through2
through.factory = through2.ctor

module.exports = through
