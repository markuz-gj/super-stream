domain = require "domain"
{Promise} = require "es6-promise"

{Transform, Readable} = require "readable-stream"
isObject = require "lodash-node/modern/objects/isObject"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

through = require "../src/through"

describe "exported value:", ->

  it 'should be a function', ->
    expect(through).to.be.an.instanceof Function

  it "should have obj property", ->
    expect(through).to.have.property "obj"

  it "should have ctor property", ->
    expect(through).to.have.property "ctor"

  it "should have factory property", ->
    expect(through).to.have.property "factory"


beforeEachHookA = Object.create null

beforeEachHookA["describing returned function from through.factory():\n"] = ->
  @th = through.factory()
  @stA = @th()
  @stX = @th {objectMode: on}
  @objMode = no

beforeEachHookA["describing returned function from through.factory({objectMode: true}):\n"] = ->
  @th = through.factory {objectMode: true}
  @stA = @th()
  @stX = @th {objectMode: off}
  @objMode = yes

for descA, runFunctionA of beforeEachHookA
  describe descA, ->
    beforeEach runFunctionA

    describe "describing stream from through():", ->

      it "should return an instance of Transform", ->
        expect(through()).to.be.an.instanceof Transform

      it "should return a noop Transform Stream if called without arguments", ->
        ctx = @        
        @stA.pipe @th (c) ->
          #
          # TODO: test for buffer!
          if ctx.objMode
            expect(c).to.be.equal "data"
          else
            expect(c.toString()).to.be.equal "data"
            expect(c).to.not.be.equal "data"

        @stA.write "data"

    beforeEachHookB = Object.create null
    
    beforeEachHookB["describing stream from through(function(c,e,n){}):"] =  ->
      @stB = @th()
      @spyA = sinon.spy()
      @spyB = sinon.spy()
      @dataA = new Buffer "A"
      @dataB = new Buffer "B"

    beforeEachHookB["describing stream from through(function(c,e,n){}, function(c,e,n){}):"] =  ->
      noop = (c,e,n) ->
        @push c; n()

      @stB = @th(noop, noop)
      @spyA = sinon.spy()
      @spyB = sinon.spy()
      @dataA = new Buffer "A"
      @dataB = new Buffer "B"

    for descB, runFunctionB of beforeEachHookB
      describe descB, ->

        beforeEach runFunctionB

        afterEach -> @dataB = @dataA = @stB = @spyA = @spyB = undefined

        it "should pipe through streams to each other and pass data through them", ->
          ctx = @
          data = new Buffer("a")
          async = new Promise (resolve, reject) ->
            
            ctx.stA.pipe ctx.stB 
              .pipe ctx.th (chunk,e,n) ->
                ctx.spyA chunk
                @push chunk; n()

              .pipe ctx.th (chunk,e,n) ->
                ctx.spyB chunk
                @push chunk; n()

              .pipe ctx.th (chunk,e,n) ->
                resolve chunk

            ctx.stA.write data

          async.then (chunk) ->
            expect(ctx.spyA).to.have.been.calledWith data
            expect(ctx.spyB).to.have.been.calledWith data

        it "should use the same 'pipeline' multiple times", ->
          th = through.factory {objectMode: yes}

          spy = sinon.spy()
          s0 = th()
          s0.pipe th (c,e,n) -> n null, ++c
            .pipe th (c,e,n) -> n null, ++c
            .pipe th (c,e,n) -> 
              spy c
              n()

          async = (data) ->
            return new Promise (resolve, reject) ->
              setTimeout resolve, 1
              s0.write data

          async(-1).then ->
            expect(spy).to.have.been.calledWith 1
            return async 1
          .then ->
            expect(spy).to.have.been.calledWith 3
            expect(spy).to.not.have.been.calledWith 5
            return async 3
          .then ->
            expect(spy).to.have.been.calledWith 5

        it "should pass different options to through and have it reflect on the new stream only", ->
          data = "data"
          if @objMode
            # @stX was defined with {objectMode: false}
            @stX.pipe @th {objectMode: off}, (c) ->
              expect(c.toString()).to.be.equal data.toString()
              expect(c).to.not.be.equal data
          else
            # @stX was defined with {objectMode: true}
            @stX.pipe @th {objectMode: on}, (c) ->
              expect(c).to.be.equal data

          @stX.write data


