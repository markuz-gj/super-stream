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

describe "exported value", ->
  it 'should be a function', ->
    patch.should.be.an.instanceof Function

for desc, runBefore of descObj
  describe desc, ->

    beforeEach runBefore

    it "should accept only a Transform stream as 1st argument", ->
      should.not.exist patch new Readable()

    it 'should return an instance of Transform', ->
      C.patchedStream.should.be.an.instanceof Transform

    it "should have patched the stream's methods", ->
      for i, fn of C.stream
        if fn instanceof Function
          C.patchedStream[i].should.be.an.instanceof Function

    it 'should have attached a Domain object on the patched method', ->
      for i, fn of C.patchedStream
        if fn instanceof Function
          fn.domain.should.be.an.instanceof domain.Domain

    it 'should append #_original to the domain bounded method', ->
      for i, fn of C.stream
        if fn instanceof Function
          C.patchedStream[i]._original.should.be.instanceof Function

    it 'should have #_original deep equal to the original method' , ->
      for i, fn of C.stream
        if fn instanceof Function
          C.patchedStream[i]._original.should.be.deep.equal fn

    it 'should not replace #_original if there is already one', ->
      for i, fn of C.patchedStream
        if fn instanceof Function
          # re-assigning a truthy value but NOT a function to #_original!
          fn._original = true

      repatchedStream = patch C.patchedStream
      for i, fn of repatchedStream
        if fn instanceof Function
          fn._original.should.not.be.instanceof Function

    it 'should use the user domain if one is passed as 2nd argument', ->
      if C.dom
        for i, fn of C.patchedStream
          if fn instanceof Function
            fn.domain.userDefined.should.be.true
      else
        for i, fn of C.patchedStream
          if fn instanceof Function
            fn.domain.should.not.have.property 'userDefined'

    it 'should stream data to another Transform stream', ->
      patchedStream = C.patchedStream
      patchedStream2 = patch(new Transform(), C.dom)
      chunk = new Buffer "same data"

      patchedStream._transform = (f,e,n) ->
        @push f
        n()

      patchedStream2._transform = (f,e,n) ->
        should.equal f, chunk
        @push f
        n()

      patchedStream.pipe patchedStream2
      patchedStream.write(chunk)

    it 'should err', ->
      for i, fn of C.patchedStream
        if fn instanceof Function
          # calling all methods with a wrong argument
          C.patchedStream[i](Math.random())

      if C.dom
        C.errSpy.should.have.been.calledWith "EE:domain"
      else
        C.errSpy.should.have.been.calledWith "EE:stream"

return





