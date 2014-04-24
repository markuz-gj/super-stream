domain = require "domain"

{Transform, Readable} = require "readable-stream"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

patch = require "../src/patch"

C = {}
class MyDomain
  constructor: ->
    dom = domain.create()
    dom.userDefined = yes
    return dom


descObj = Object.create null

descObj['patch(stream)'] = (done) ->
  ctx = @
  @errSpy = sinon.spy()
  @stream = new Transform()
  @patchedStream = patch new Transform()
  @patchedStream.on "error", (e) -> ctx.errSpy "EE:stream"
  done()

descObj['patch(stream, userDomain)'] = (done) ->
  ctx = @
  @errSpy = sinon.spy()
  @dom = new MyDomain()
  @dom.on "error", (e) ->ctx.errSpy "EE:domain"

  @stream = new Transform()
  @patchedStream = patch(new Transform(), @dom)
  done()

describe "exported value", ->
  it 'should be a function', ->
    expect(patch).to.be.an.instanceof Function


for desc, runFunction of descObj
  describe desc, ->


    beforeEach runFunction

    it "should accept only a Transform stream as 1st argument", ->
      expect(patch new Readable()).not.exit
      return

    it 'should return an instance of Transform', ->
      expect(@patchedStream).be.an.instanceof Transform
      return

    it "should have patched the stream's methods", ->
      for i, fn of @stream
        if fn instanceof Function
          expect(@patchedStream[i]).to.be.an.instanceof Function
      return

    it 'should have attached a Domain object on the patched method', ->
      for i, fn of @patchedStream
        if fn instanceof Function
          expect(fn.domain).to.be.an.instanceof domain.Domain
      return

    it 'should append #_original to the domain bounded method', ->
      for i, fn of @stream
        if fn instanceof Function
          expect(@patchedStream[i]._original).to.be.instanceof Function
      return

    it 'should have #_original deep equal to the original method' , ->
      for i, fn of @stream
        if fn instanceof Function
          expect(@patchedStream[i]._original).to.be.deep.equal fn
      return

    it 'should not replace #_original if there is already one', ->
      for i, fn of @patchedStream
        if fn instanceof Function
          # re-assigning a truthy value but NOT a function to #_original!
          fn._original = true

      repatchedStream = patch @patchedStream
      for i, fn of repatchedStream
        if fn instanceof Function
          expect(fn._original).to.not.be.instanceof Function
      return

    it "should use the user's domain if one is passed as 2nd argument", ->
      if @dom
        for i, fn of @patchedStream
          if fn instanceof Function
            expect(fn.domain.userDefined).to.be.true
      else
        for i, fn of @patchedStream
          if fn instanceof Function
            expect(fn.domain).to.not.have.property 'userDefined'
      return

    it 'should stream data to another Transform stream', ->
      unpachedStream = @stream
      patchedStream = @patchedStream
      patchedStream2 = patch(new Transform(), @dom)

      unpachedStream._transform = (f,e,n) ->
        @push f; n()

      patchedStream._transform = (f,e,n) ->
        @push f; n()

      patchedStream2._transform = (f,e,n) ->
        @push f; n()
        expect(f).to.equal chunk

      patchedStream
        .pipe unpachedStream
        .pipe patchedStream2
      
      chunk = new Buffer "same data"
      patchedStream.write(chunk)
      return

    it 'should throw error and it should be caught', ->
      for i, fn of @patchedStream
        if fn instanceof Function
          # calling all methods with a wrong argument
          @patchedStream[i](Math.random())

      if @dom
        expect(@errSpy).to.have.been.calledWith "EE:domain"
      else
        expect(@errSpy).to.have.been.calledWith "EE:stream"
      return

return





