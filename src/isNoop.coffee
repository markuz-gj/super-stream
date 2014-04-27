isFunction = require "lodash-node/modern/objects/isFunction"

module.exports = (args = []) ->
  if isFunction(args[0]) or isFunction(args[1]) then return false

  return true