domain = require "domain"
{Transform} = require "readable-stream"

{isFunction} = require "core-util-is"

isTransform = ->
  return true

module.exports = (stream, userDomain) ->
  if not (isTransform stream)
    return

  if userDomain instanceof domain.Domain
    dom = userDomain
  else
    dom = domain.create()
    dom.on "error", (e) -> console.log "EE:patch domain", e


  if isTransform stream
    for i, fn of stream
      # checking if is a function and if it has been already patched
      if isFunction(fn) and !stream[i]?._original
        # stream[i] = domain.bind ->
        #   self = @
        #   try
        #     stream[i]._original.apply stream, arguments
        #   catch e
        #     domain.emit "error", e
          
        stream[i] = dom.bind fn
        stream[i]._original = fn

  return stream