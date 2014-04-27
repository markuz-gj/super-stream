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

  it "should have #factory property", ->
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

      it "should be an instanceof Transform", ->
        expect(@each()).to.be.an.instanceof Transform

      it "should not have a #_each property", ->
        expect(@each()).to.not.have.property "_each"

    describe "describing stream from each(function(c){}):", ->

      beforeEach ->
        @noop = @each()
        @stA = @each (c) -> 
          if c.toString() is "skip"
            return null
          @push c

        @stB = @each (c,e,n) -> @push c; n(); n(); n()

        @chunk = new Buffer "data 0"

      afterEach -> @test = @noop = @chunk = @chunk1 = @chunk2 = undefined

      it "should have a #_each property", ->
        expect(@stA).to.have.property "_each"

      it "should pass the right kind of data through", ->
        ctx = @
        @stA.pipe @each (c) ->
          expect(c.toString()).to.be.equal "data"

        # NOTE: if the "skip" message had passed, 
        #  the expect statement would have failed!
        @stA.write "data"
        @stA.write "skip"

      it "should have a #next property only after being used at least once", ->
        ctx = @
        expect(@stA).to.not.have.property "next"
        @stA.pipe @each (c) ->
          expect(ctx.stA).to.have.property "next"

        @stA.write "A"

      it "should execute #next only once even if called multiple times", ->
        ctx = @
        @stB.pipe @each (c) -> expect(c).to.equal ctx.chunk
        @stB.write @chunk

      it "should call each transform with three arguments only", ->
        @stA.pipe @each ->
          expect(arguments.length).to.be.equal 3
          return
        @stA.write 'data'

      it "should stream `-1` and have it be incremented twice", ->
        ea = @each.factory {objectMode: yes}
        s0 = ea()

        s0.pipe ea (c) ->
          @next null, ++c
        .pipe ea (c) ->
          @next null, ++c
        .pipe ea (c) ->
          expect(c).to.be.equal 1

        s0.write -1

      it "should pass data down stream multiple times always", ->
        ea = @each.factory {objectMode: yes}
        spy = sinon.spy()
        s0 = ea()

        s0.pipe ea (c) -> @next null, ++c
          .pipe ea (c) -> @next null, ++c
          .pipe ea (c) -> spy c

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 1
            s0.write data

        async(-1).then ->
          expect(spy).to.be.calledWith 1
          async 1
        .then ->
          expect(spy).to.be.calledWith 3
          expect(spy).to.not.be.calledWith 5
          async 3
        .then ->
          expect(spy).to.be.calledWith 5

  

