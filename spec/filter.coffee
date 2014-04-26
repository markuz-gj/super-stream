domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

filter = require "../src/filter"

# created fake npm package
each = require "super-stream/each"

describe "exported value:", ->

  it 'should be a function', ->
    
    expect(filter).to.be.an.instanceof Function

  it "should have `factory` property", ->
    
    expect(filter).to.have.property "factory"

beforeEachHook = Object.create null

beforeEachHook["describing returned function from filter.factory():\n"] =  ->
  @filter = filter.factory()
  @objMode = no
  @data = new Buffer "data"
  @data2 = new Buffer "data2"

beforeEachHook["describing returned function from filter.factory({objectMode: true}):\n"] =  ->
  @filter = filter.factory {objectMode: true}
  @objMode = yes
  @data = "data"
  @data2 = "data2"

for desc, runFunction of beforeEachHook

  describe desc, ->

    beforeEach runFunction
    
    afterEach -> @filter = @objMode = undefined

    describe "describing stream from filter():", ->

      it "should be an instanceof `Transform`", ->

        expect(@filter()).to.be.an.instanceof Transform

      it "should not have a `#_filter` property", ->
        
        expect(@filter()).to.not.have.property "_filter"

    describe "describing stream from filter(function(c){}):", ->

      beforeEach ->
        ctx = @
        @noop = @filter()
        # thruthy streams
        @stA = @filter (c) -> return !!c
        @stB = @filter (c) -> return c
        
        # falsy streams
        @stC = @filter (c) -> 
          if c.toString() is ctx.data2.toString()
            return c
          return !c 

        @spyA = sinon.spy()
        @spyB = sinon.spy()
        @spyC = sinon.spy()
        @spyD = sinon.spy()

        @chunk0 = new Buffer "data 0"
        @chunk1 = new Buffer "data 2"
        @chunk2 = new Buffer "data 1"

      afterEach -> @filter = @noop = @chunk0 = @chunk1 = @chunk2 = undefined

      it "should have a `#_filter` property", ->

        expect(@stA).to.have.property "_filter"

      it "should not have a `#_filter.next` property if stream hasn't been used", ->

        expect(@stA._filter).to.not.have.property "next"

      it "should have a `#_filter.next` property if stream has been used", ->
        @stA.write "data"
        expect(@stA._filter).to.have.property "next"

      it "should have the map function context set to Object.create(null)", ->
        ctx = @
        @stA.pipe @filter (c) ->
          expect(@).to.not.be.an.instanceof Object
          expect(@).to.be.deep.equal Object.create null
          return

        @stA.write @data

      it "should let data pass if returned truthy", ->
        ctx = @
        @stB.pipe @filter (c) -> ctx.spyB c

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout -> 
              resolve()
            , 20

            ctx.stB.write data
 
        async(@data).then (spy) ->
          expect(ctx.spyB).to.been.calledWith ctx.data

        async(@data2).then (spy) ->
          expect(ctx.spyB).to.been.calledWith ctx.data2
        
      it "should not let data pass if returned falsy", ->
        ctx = @
        @stC.pipe @filter (c) ->
          ctx.spyC c.toString()

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout -> 
              resolve()
            , 20

            ctx.stC.write data

        async(ctx.data).then ->
          expect(ctx.spyC).to.not.been.calledWith ctx.data.toString()
        
        async(ctx.data2).then ->
          expect(ctx.spyC).to.been.calledWith ctx.data2.toString()

      it "should call `filter` transform with two arguments only", ->
        @stA.pipe @filter ->
          expect(arguments.length).to.be.equal 2
          return

        @stA.write @data



