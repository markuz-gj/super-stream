isFunction = require "lodash-node/modern/objects/isFunction"

module.exports = (args) ->
  if args.length is 0 then return true
  if (args.length is 1) and !isFunction(args[0]) then return true
  return false