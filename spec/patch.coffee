domain = require "domain"

{Transform} = require "readable-stream"

chai = require "chai"
chai.should()

patch = require "../patch"

C = {}
class MyDomain
  constructor: ->
    dom = domain.create()
    dom.userDefined = yes
    return dom

descObj = Object.create null

descObj['patch(stream)'] = (done) ->
  C.stream = new Transform()
  C.patchedStream = patch new Transform()
  done()

descObj['patch(stream, userDomain)'] = (done) ->
  C.dom = new MyDomain()
  C.stream = new Transform()
  C.patchedStream = patch(new Transform(), C.dom)
  done()

for desc, fn of descObj
  describe desc, ->

    beforeEach fn

    it 'should be a function', ->
      patch.should.be.an.instanceof Function

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






