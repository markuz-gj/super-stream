domain = require "domain"

{Transform, Readable, Duplex} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
# chai.use require "chai-as-promised"
expect = chai.expect
chai.config.showDiff = false

junction = require "../src/junction"
each = require "super-stream/each"
through = require "super-stream/through"

    # all possible junctions
    # Transform only junctions being tested now.

    # @jntA01 = @jnt @readableStream
    # @jntA02 = @jnt @writableStream
    # @jntA04 = @jnt @readableStream, @writableStream 
    # @jntA05 = @jnt @writableStream, @readableStream

    # @jntA06 = @jnt @readableStream, @transfromStream
    # @jntA07 = @jnt @transfromStream, @readableStream 
    # @jntA08 = @jnt @writableStream, @transformStream
    # @jntA09 = @jnt @transformStream, @writableStream

    # @jntB01 = @jnt @opts, @readableStream
    # @jntB02 = @jnt @opts, @writableStream
    # @jntB04 = @jnt @opts, @readableStream, @writableStream 
    # @jntB05 = @jnt @opts, @writableStream, @readableStream

    # @jntB06 = @jnt @opts, @readableStream, @transfromStream
    # @jntB07 = @jnt @opts, @transfromStream, @readableStream 
    # @jntB08 = @jnt @opts, @writableStream, @transformStream
    # @jntB09 = @jnt @opts, @transformStream, @writableStream

    # @jntB11 = @jnt null, @readableStream
    # @jntB12 = @jnt null, @writableStream
    # @jntB14 = @jnt null, @readableStream, @writableStream 
    # @jntB15 = @jnt null, @writableStream, @readableStream

    # @jntB16 = @jnt null, @readableStream, @transfromStream
    # @jntB17 = @jnt null, @transfromStream, @readableStream 
    # @jntB18 = @jnt null, @writableStream, @transformStream
    # @jntB19 = @jnt null, @transformStream, @writableStream

describe "exported value:", ->

  it 'must be a function', -> 
    expect(junction).to.be.an.instanceof Function

  it "must have #factory be an instanceof Function", ->
    expect(junction).to.have.property "factory"
    expect(junction.factory).to.be.an.instanceof Function

  it "must have #Junction be an instanceof Function", ->
    expect(junction).to.have.property "Junction"
    expect(junction.Junction).to.be.an.instanceof Function

hooks = Object.create null

addToTestContext = ->
  ctx = @
  @ea = each.factory @opts
  @jnt = junction.factory @opts

  # @opts2 = {objectMode: !@opts.objectMode}
  # @ea2 = each.factory @opts2
  # @jnt2 = junction.factory @opts2

  @jntA00 = @jnt()
  @jntA03 = @jnt @ea()
  @jntA10 = @jnt @ea(), @ea()
  
  @jntB00 = @jnt @opts
  @jntB03 = @jnt @opts, @ea()
  @jntB10 = @jnt @opts, @ea(), @ea()
  @jntB13 = @jnt  null, @ea()
  @jntB20 = @jnt  null, @ea(), @ea()

  @jntArray = [
    @jntA00
    @jntA03
    @jntA10
    @jntB00
    @jntB03
    @jntB10
    @jntB13
    @jntB20
  ]

hooks["junctions from `var jnt = junction.factory();`\n"] =  {
  before: ->
    @opts = {}
    @data = new Buffer "data"
    addToTestContext.call @

  after: ->

}

hooks["junctions from `var jnt = junction.factory({objectMode: true});`\n"] =  {
  before: ->
    @opts = {objectMode: yes}
    @data = "data"
    addToTestContext.call @

  after: ->

}

for desc, run of hooks
  do (desc, run) ->

    describe desc, ->

      describe "returned junction:", ->

        beforeEach run.before
        afterEach run.after

        it "must be an instanceof Junction", ->
          for jnt, i in @jntArray
            expect(jnt).to.be.an.instanceof @jnt.Junction

        it "must be an instanceof Duplex Stream only", ->
          for jnt in @jntArray
            expect(jnt).to.be.an.instanceof Duplex
            expect(jnt).to.not.be.an.instanceof Transform

        it "must have #_entry and be an instanceof Function", ->
          for jnt in @jntArray
            expect(jnt).to.have.property "_entry"
            expect(jnt._entry).to.be.an.instanceof Function

        it "must have #entry and be an instanceof Transform", ->
          for jnt in @jntArray
            expect(jnt).to.have.property "entry"
            expect(jnt.entry).to.be.an.instanceof Transform

        it "must have #_exit and be an instanceof Function", ->
          for jnt in @jntArray
            expect(jnt).to.have.property "_exit"
            expect(jnt._exit).to.be.an.instanceof Function

        it "must have #exit and be an instanceof Transform\n", ->
          for jnt in @jntArray
            expect(jnt).to.have.property "exit"
            expect(jnt.exit).to.be.an.instanceof Transform

      describe "junction's behaviour:", ->

        beforeEach run.before
        afterEach run.after

        async = (data, stream) ->
          new Promise (res, rej) ->
            stream.write data
            setImmediate res

        spy = (stream) ->
          agent = sinon.spy()
          iterator = stream._transform
          stream._spy = agent
          stream._transform = (c) ->
            agent c
            iterator.apply @, arguments
          return agent

        addToTestContext2 = ->
          @stA = @ea (c) -> @push c
          @stB = @ea (c) -> @push c
          @stX = @ea (c) -> @push c
          @stZ = @ea (c) -> @push c

          @spyA = spy @stA
          @spyB = spy @stB
          @spyX = spy @stX
          @spyZ = spy @stZ
          @tests = []

          @promise = (fn) =>
            @tests.push async(@data, @stX).then fn

          @resolve = (done) =>
            Promise.all(@tests).then -> done()
              .catch done

        it "must let data pass only through the junction's entry stream",  (done)->

          for jnt, i in @jntArray
            do (jnt, i) =>
              addToTestContext2.call @

              jnt.entry.pipe @stA
              jnt.exit.pipe @stB

              @stX.pipe jnt

              @promise =>
                expect(@spyA).to.have.been.calledOnce.and.calledWith @data
                expect(@spyB).to.not.have.been.called

          @resolve done

        it "must let data pass only through the junction's exit stream", (done)->
          tests = []

          for jnt, i in @jntArray
            do (jnt, i) =>
              addToTestContext2.call @

              jnt.entry.pipe @stA
              jnt.exit.pipe @stB

              @stX.pipe jnt.exit

              @promise =>
                expect(@spyA).to.not.have.been.called
                expect(@spyB).to.have.been.calledOnce.and.calledWith @data

          @resolve done

        it "must let data pass through the junction's entry and exit stream", (done) ->
          tests = []

          for jnt, i in @jntArray
            do (jnt, i) =>
              addToTestContext2.call @

              # creating a pipeline here
              jnt.entry.pipe @stA
              @stA.pipe @stB
              @stB.pipe jnt.exit

              # piping into and out of junction
              @stX.pipe jnt
                .pipe @stZ

              @promise =>
                expect(@spyA).to.have.been.calledOnce.and.calledWith @data
                expect(@spyB).to.have.been.calledOnce.and.calledWith @data
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data
          
          @resolve done


