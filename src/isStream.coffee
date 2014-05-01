PlatformStream = require('stream')
Stream = require('readable-stream')

junction = require "super-stream/junction"

# {Junction} = junction
# {JunctionB} = junction.factory({objectMode: yes})

isJunction = (stream) ->
  if stream instanceof junction.Junction
    return true
  return false

isTransform = (stream) ->
  if stream instanceof Stream.Transform 
    return yes
  return no

isDuplex = (stream) ->
  if stream instanceof Stream.Duplex
    return yes
  return no

isDuplexOnly = (stream) ->
  if isDuplex(stream) and !isTransform(stream)
    return yes
  return no

isReadable = (stream) ->
  if stream instanceof Stream.Readable
    return yes
    
  if stream instanceof PlatformStream.Readable
    return yes
  
  return no 

isReadableOnly = (stream) ->
  if isReadable stream 
    if !isDuplex(stream) and !isTransform(stream)
      return yes
  return no

isWritable = (stream) ->
  if stream instanceof Stream.Writable
    return yes
    
  if stream instanceof PlatformStream.Writable
    return yes

  if isDuplex stream 
    return yes

  return no 

isStream = (stream) ->
  if stream instanceof Stream
    return yes
    
  if stream instanceof PlatformStream
    return yes

  return no

isStream.isStream = isStream

isStream.isJunction = isJunction
isStream.isReadable = isReadable
isStream.isReadableOnly = isReadableOnly

isStream.isWritable = isWritable
isStream.isTransform = isTransform

isStream.isDuplex = isDuplex
isStream.isDuplexOnly = isDuplexOnly

module.exports = isStream
