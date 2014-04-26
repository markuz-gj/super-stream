domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

each = require "../src/each"

describe "exported value:", ->

  it 'should be a function', ->
    expect(each).to.be.an.instanceof Function

  it "should have `factory` property", ->
    expect(each).to.have.property "factory"


beforeEachHook = Object.create null

beforeEachHook["describing returned function from each.factory():\n"] =  ->
  @each = each.factory()
  @objMode = no


beforeEachHook["describing returned function from each.factory({objectMode: true}):\n"] =  ->
  @each = each.factory {objectMode: true}
  @objMode = yes


for desc, runFunction of beforeEachHook

  describe desc, ->

    beforeEach runFunction
    
    afterEach -> @each = @objMode = undefined

    describe "describing stream from each():", ->

      it "should be an instanceof `Transform`", ->
        expect(@each()).to.be.an.instanceof Transform

      it "should not have a `#_each` property", ->
        expect(@each()).to.not.have.property "_each"

    describe "describing stream from each(function(c){}):", ->

      beforeEach ->
        @noop = @each()
        @stA = @each (c) -> 
          if c.toString() is "skip"
            return null
          @push c
        @stB = @each (c,e,n) -> @push c; n(); n(); n()

        @chunk0 = new Buffer "data 0"
        @chunk1 = new Buffer "data 2"
        @chunk2 = new Buffer "data 1"

      afterEach -> @test = @each = @noop = @chunk0 = @chunk1 = @chunk2 = undefined

      it "should have a `#_each` property", ->
        expect(@stA).to.have.property "_each"

      it "should pass the right kind of data through", ->
        ctx = @
        @stA.pipe @each (c) ->
          if ctx.objMode
            expect(c).to.be.equal "L"
          else
            expect(c.toString()).to.be.equal "L"

        @stA.write "L"
        # NOTE: is the "skip" message had passed, the expect would have failed!
        @stA.write "skip"

      it "should have a `stream#_each.next` property only after being used once", ->
        ctx = @
        expect(@stA._each).to.not.have.property "next"
        @stA.pipe @each (f) ->
          expect(ctx.stA._each).to.have.property "next"

        @stA.write "A"

      it "should execute `#next()` only once even if called multiple times", ->
        ctx = @
        # st = each (c,e,n) -> return @push c; n();n();n()

        @stB.pipe @each (f) -> expect(f).to.equal ctx.chunk0
        @stB.write @chunk0

      it "should execute `#next()` automatically and work on multiple `stream#write(chunk)`", ->
        ctx = @
        spy = sinon.spy()

        async = new Promise (resolve, reject) ->
          ctx.noop
            .pipe ctx.each (f) -> 
              spy()
              resolve(spy)

          ctx.noop.write ctx.chunk0

        async.then (spy) -> 
            ctx.noop.write ctx.chunk1
            return spy 
          .then (spy) -> 
            ctx.noop.write ctx.chunk2
            return spy 
          .then (spy) ->
            expect(spy).to.have.been.calledThrice
            return spy































