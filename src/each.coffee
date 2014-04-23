{Transform} = require "readable-stream"


class Each
  constructor: (cfg = {}) ->
    return (opts, transform, flush) ->
      console.log opts

module.exports = Each