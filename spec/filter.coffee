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

      it "should not have a `#_each` property", ->
        expect(@filter()).to.not.have.property "_each"

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

      it "should not have a `#_filter.next` property if stream has been used", ->
        @stA.write "data"
        expect(@stA._filter).to.have.property "next"

      it "should let data pass if returned truthy", ->
        ctx = @

        asyncA = new Promise (resolve, reject) ->
          setTimeout -> 
            resolve()
          , 20

          ctx.stA.pipe ctx.filter (c) -> ctx.spyC c
          ctx.stA.write ctx.data

        asyncB = new Promise (resolve, reject) ->
          setTimeout -> 
            resolve()
          , 20

          ctx.stB.pipe ctx.filter (c) -> ctx.spyB c
          ctx.stB.write ctx.data

        asyncA.then (spy) ->
          expect(ctx.spyA).to.been.calledWith ctx.data
        
        asyncB.then (spy) ->
          expect(ctx.spyB).to.been.calledWith ctx.data
        
      it "should not let data pass if returned falsy", ->
        ctx = @
  
        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout -> 
              resolve()
            , 20

            ctx.stC.pipe ctx.filter (c) ->
              ctx.spyC c.toString()
            ctx.stC.write data

        async(ctx.data).then ->
            expect(ctx.spyC).to.not.been.calledWith ctx.data.toString()
        
        async(ctx.data2).then ->
            expect(ctx.spyC).to.been.calledWith ctx.data2.toString()


# describe "exported value:", ->

#   it 'should be a function', ->
#     expect(filter).to.be.an.instanceof Function

#   it "should have `factory` property", ->
#     expect(filter).to.have.property "factory"


# beforeEachHook = Object.create null

# beforeEachHook["describing returned function from filter.factory():\n"] =  ->
#   @each = each.factory()
#   @objMode = no


# beforeEachHook["describingreturned function from filter.factory({objectMode: true}):\n"] =  ->
#   @each = each.factory {objectMode: true}
#   @objMode = yes


# # for desc, runFunction of beforeEachHook


# describe "stream returned by #filter", ->
#   beforeEach ->
#     @noop = filter()
#     @stA = filter (f) -> return yes
#     @stB = filter (f) -> return no

#   it "should be an instanceof `Transform`", ->
#     expect(@noop).to.be.an.instanceof Transform
#     expect(@stA).to.be.an.instanceof Transform

#   describe "#filter() called without arguments", ->

#     it "should return a noop Transform", ->



#   describe "#filter() called with function arguments", ->
#     # NOTE: use some promise to test this next two specs
      
#     it "should have a `#_filter` property", ->
#       expect(@stA).to.have.property "_filter"

#     it "should not have a `#_filter.next` property if stream hasn't been used", ->
#       expect(@stA._filter).to.not.have.property "next"
    
#     it "should have a `#_filter.next` property if stream has been used", ->
#       ctx = @
#       @stA.pipe each ->
#         expect(ctx.stA._filter).to.have.property "next"

#       @stA.write "a"

#     it "should let chunk pass", ->
#       @stA.pipe each (f) ->
#         # console.log f.toString()
#       @stA.write "data"

#     it "should not let chunk pass", ->
#       # @stB.pipe each (f) ->
#       #   console.log f.toString()
#       @stB.write "data"




