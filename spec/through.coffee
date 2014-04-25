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

describe "exported value", ->
  C = {}


  it 'should be a function', ->
    expect(through).to.be.an.instanceof Function

  it "should have `obj` property", ->
    expect(through).to.have.property "obj"

  it "should have `ctor` property", ->
    expect(through).to.have.property "ctor"

  it "should have `factory` property", ->
    expect(through).to.have.property "factory"

# describe "through#factory([, {{objectMode: on}}])", ->

#   it "should return a through function with different defaults", ->
#     throughNew = through.factory {objectMode: on}

#     # default is to pass data as an instance of Buffer
#     stA = throughNew (c,e,n) ->
#       expect(c).to.equal "data 0"

#     stB = through (c,e,n) ->
#       expect(c.toString()).to.equal "data 1"
#       expect(c).to.not.equal "data 1"

#     stA.write "data 0"
#     stB.write "data 1"



  # for desc, runFunction of beforeEachHook  # for desc in ["through.factory()", "through.factory({objectMode: true})"]




describe "returned function from through.factory()", ->

  beforeEach -> 
    @th = through.factory()
    @stA = @th()
  
  beforeEachHook = Object.create null

  describe "through()", ->

    it "should return an instance of Transform", ->
      expect(through()).to.be.an.instanceof Transform

    it "should return a noop Transform Stream if called without arguments", ->
      data = {}

      @stA.pipe @th (c) ->
        #
        # TODO: test for buffer!
        expect(c.toString()).to.equal "data"

      @stA.write "data"

  beforeEachHook["through(function(c,e,n){})"] =  ->
    @stB = through()

    @spyA = sinon.spy()
    @spyB = sinon.spy()

  beforeEachHook["through(function(c,e,n){}, function(c,e,n){})"] =  ->
    noop = (c,e,n) ->
      @push c; n()

    @stB = through(noop, noop)
    @spyA = sinon.spy()
    @spyB = sinon.spy()

  for own desc, runFunction of beforeEachHook
    describe desc, ->

      beforeEach runFunction

      it "should pipe `through streams` to each other and pass data through them", ->
        ctx = @
        data = new Buffer("a")
        pr = new Promise (resolve, reject) ->
          
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

        pr.then (chunk) ->
          expect(ctx.spyA).to.be.calledWith data
          expect(ctx.spyB).to.be.calledWith data

      it "should use the same 'pipeline' twice", ->
        ctx = @
        streamAsync = (data) ->
          return new Promise (resolve, reject) ->
          
            ctx.stA.pipe ctx.stB
              .pipe ctx.th (c,e,n) ->
                ctx.spyA c
                @push c; n()

              .pipe ctx.th (c,e,n) ->
                ctx.spyB c
                @push c; n()

              .pipe ctx.th (c,e,n) ->
                resolve c

            ctx.stA.write data

     
        for i, buf of [new Buffer("A"), new Buffer("B")]

          do (buf) ->
            streamAsync(buf).then (chunk) ->
              expect(ctx.spyA).to.be.calledWith buff
              expect(ctx.spyB).to.be.calledWith buff

describe "returned function from through.factory({objectMode: true})", ->
  
  beforeEach -> 
    @th = through.factory({objectMode: on})
    @stA = @th()

  beforeEachHook = Object.create null

  describe "through()", ->

    beforeEach  ->
      @stB = @th()

    it "should return an instance of Transform", ->
      expect(through()).to.be.an.instanceof Transform

    it "should return a noop Transform Stream if called without arguments", ->
      data = {}
      @stA.pipe @stB
        .pipe @th (c) -> 
          # data should pass through @st unchanged.
          expect(c).to.equal data
          expect(c).to.not.equal {}

      @stA.write data

  beforeEachHook["through({objectMode: true}, function(c,e,n){})"] =  ->
    @stB = through {objectMode: true}
   
    @spyA = sinon.spy()
    @spyB = sinon.spy()

  beforeEachHook["through({objectMode: true}, function(c,e,n){}, function(c,e,n){})"] =  ->
    @stB = through(noop, noop)

    noop = (c,e,n) ->
      @push c; n()

    @spyA = sinon.spy()
    @spyB = sinon.spy()

  for own desc, runFunction of beforeEachHook
    describe desc, ->

      beforeEach runFunction

      it "should pipe `through streams` to each other and pass data through them", ->
        ctx = @
        data = new Buffer("a")
        pr = new Promise (resolve, reject) ->
          
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

        pr.then (chunk) ->
          expect(ctx.spyA).to.be.calledWith data
          expect(ctx.spyB).to.be.calledWith data

      it "should use the same 'pipeline' twice", ->
        ctx = @
        streamAsync = (data) ->
          return new Promise (resolve, reject) ->
          
            ctx.stA.pipe ctx.stB
              .pipe ctx.th (c,e,n) ->
                ctx.spyA c
                @push c; n()

              .pipe ctx.th (c,e,n) ->
                ctx.spyB c
                @push c; n()

              .pipe ctx.th (c,e,n) ->
                resolve c

            ctx.stA.write data

     
        for i, buf of [new Buffer("A"), new Buffer("B")]

          do (buf) ->
            streamAsync(buf).then (chunk) ->
              expect(ctx.spyA).to.be.calledWith buff
              expect(ctx.spyB).to.be.calledWith buff


