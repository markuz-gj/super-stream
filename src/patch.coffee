domain = require "domain"
{Transform} = require "readable-stream"

isFunction = require "lodash-node/modern/objects/isFunction"
isObject = require "lodash-node/modern/objects/isObject"
cloneDeep = require "lodash-node/modern/objects/cloneDeep"

bindDomain = (stream, dom) ->
  for i, fn of stream
    do (i, fn) ->
      # checking if is a function and if it has been already patched
      if isFunction(fn) and !stream[i]._original
        stream[i] = dom.bind ->
          try
            stream[i]._original.apply stream, arguments   
          catch error
            dom.emit "error", error
          
        stream[i]._original = fn

  return stream

patch = (stream, userDomain) ->
  if not (stream instanceof Transform)
     return

  if userDomain instanceof domain.Domain
    dom = userDomain
  else
    dom = domain.create()
    dom.on "error", (e) -> stream.emit "error", e
    stream._domain = dom

  bindDomain stream, dom
  return stream

module.exports = exports = patch