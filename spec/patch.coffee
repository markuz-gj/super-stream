domain = require "domain"

{Transform, Readable} = require "readable-stream"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
should = chai.should()

patch = require "../src/patch"

C = {}
class MyDomain
  constructor: ->
    dom = domain.create()
    dom.userDefined = yes
    return dom

describe "exported value", ->
  it 'should be a function', ->
    patch.should.be.an.instanceof Function

descObj = Object.create null

descObj['patch(stream)'] = (done) ->
  C.errSpy = sinon.spy()
  C.stream = new Transform()
  C.patchedStream = patch new Transform()
  C.patchedStream.on "error", (e) -> C.errSpy "EE:stream"
  done()

descObj['patch(stream, userDomain)'] = (done) ->
  C.errSpy = sinon.spy()
  C.dom = new MyDomain()
  C.dom.on "error", (e) ->C.errSpy "EE:domain"

  C.stream = new Transform()
  C.patchedStream = patch(new Transform(), C.dom)
  done()

for desc, runFunction of descObj
  describe desc, ->

    beforeEach runFunction

    it "should accept only a Transform stream as 1st argument", ->
      should.not.exist patch new Readable()
      return

    it 'should return an instance of Transform', ->
      C.patchedStream.should.be.an.instanceof Transform
      return

    it "should have patched the stream's methods", ->
      for i, fn of C.stream
        if fn instanceof Function
          C.patchedStream[i].should.be.an.instanceof Function
      return

    it 'should have attached a Domain object on the patched method', ->
      for i, fn of C.patchedStream
        if fn instanceof Function
          fn.domain.should.be.an.instanceof domain.Domain
      return

    it 'should append #_original to the domain bounded method', ->
      for i, fn of C.stream
        if fn instanceof Function
          C.patchedStream[i]._original.should.be.instanceof Function
      return

    it 'should have #_original deep equal to the original method' , ->
      for i, fn of C.stream
        if fn instanceof Function
          C.patchedStream[i]._original.should.be.deep.equal fn
      return

    it 'should not replace #_original if there is already one', ->
      for i, fn of C.patchedStream
        if fn instanceof Function
          # re-assigning a truthy value but NOT a function to #_original!
          fn._original = true

      repatchedStream = patch C.patchedStream
      for i, fn of repatchedStream
        if fn instanceof Function
          fn._original.should.not.be.instanceof Function
      return

    it "should use the user's domain if one is passed as 2nd argument", ->
      if C.dom
        for i, fn of C.patchedStream
          if fn instanceof Function
            fn.domain.userDefined.should.be.true
      else
        for i, fn of C.patchedStream
          if fn instanceof Function
            fn.domain.should.not.have.property 'userDefined'
      return

    it 'should stream data to another Transform stream', ->
      unpachedStream = C.stream
      patchedStream = C.patchedStream
      patchedStream2 = patch(new Transform(), C.dom)

      unpachedStream._transform = (f,e,n) ->
        @push f
        n()

      patchedStream._transform = (f,e,n) ->
        @push f
        n()

      patchedStream2._transform = (f,e,n) ->
        should.equal f, chunk
        @push f
        n()

      patchedStream
        .pipe unpachedStream
        .pipe patchedStream2
      
      chunk = new Buffer "same data"
      patchedStream.write(chunk)
      return

    it 'should throw error and it should be caught', ->
      for i, fn of C.patchedStream
        if fn instanceof Function
          # calling all methods with a wrong argument
          C.patchedStream[i](Math.random())

      if C.dom
        C.errSpy.should.have.been.calledWith "EE:domain"
      else
        C.errSpy.should.have.been.calledWith "EE:stream"
      return

return





