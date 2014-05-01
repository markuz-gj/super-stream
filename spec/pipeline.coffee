domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

pipeline = require "../src/pipeline"


# created fake npm package
each = require "super-stream/each"
junction = require "super-stream/junction"
{Junction} = junction


addToTestContext = ->
  ctx = @
  @ea = each.factory @opts
  @jnt = junction.factory @opts
  @pln = pipeline.factory @opts


  @streams = -> [@ea(), @ea(), @ea()]

  @plnA00 = @pln()
  @plnA01 = @pln @streams()
  @plnA02 = @pln @jnt()
  @plnA03 = @pln @jnt(), @streams()

  @plnB00 = @pln @opts
  @plnB01 = @pln @opts, @jnt()
  @plnB02 = @pln @opts, @streams()
  @plnB03 = @pln @opts, @jnt(), @streams()

  @plnC00 = @pln null
  @plnC01 = @pln null, @jnt()
  @plnC02 = @pln null, @streams()
  @plnC03 = @pln null, @jnt(), @streams()

  @plnArray = [
    @plnA00
    @plnA01
    @plnA02
    @plnA03

    @plnB00
    @plnB01
    @plnB02
    @plnB03

    @plnC00
    @plnC01
    @plnC02
    @plnC03
  ]


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
    @tests.push async(@data1, @stX).then fn

  @resolve = (done) =>
    Promise.all(@tests).then -> done()
      .catch done

hooks = Object.create null

hooks["junctions from `var pln = pipeline.factory();`\n"] =
  before: ->
    @opts = {}
    addToTestContext.call @
    @data1 = new Buffer "data1"
    @data2 = new Buffer "data2"
    @data3 = new Buffer "data3"
    @data4 = new Buffer "data4"

  after: ->

hooks["junctions from `var pln = pipeline.factory({objectMode: true});`\n"] =
  before: ->
    @opts = {objectMode: yes}
    addToTestContext.call @
    @data1 = "data1"
    @data2 = "data2"
    @data3 = "data3"
    @data4 = "data4"

  after: ->

async = (data, stream) ->
  new Promise (res, rej) ->
    stream.write data
    setImmediate res

spies =
  free: []
  used: []

spy = (stream) ->
  if spies.free.length is 0
    agent = sinon.spy()
  else
    agent = spies.free.pop()
    agent.reset()

  spies.used.push agent
  iterator = stream._transform
  stream._spy = agent

  stream._transform = (c) ->
    agent c
    iterator.apply @, arguments

  return agent


describe "exported value:", ->

  it 'must be a function', -> 
    expect(pipeline).to.be.an.instanceof Function

  it "must have #factory and be an instanceof Function", ->
    expect(pipeline).to.have.property "factory"
    expect(pipeline.factory).to.be.an.instanceof Function

for desc, run of hooks
  do (desc, run) ->

    describe desc, ->

      describe "returned pipeline:", ->

        beforeEach run.before
        afterEach run.after

        it "must be an instanceof Junction", ->
          for pln in @plnArray
            expect(pln).to.be.an.instanceof Junction

        it "must have #_sections property and be an instanceof Array", ->
          for pln in @plnArray
            expect(pln).to.have.property "_sections"
            expect(pln._sections).to.be.an.instanceof Array
      
        it "must #_sections[0] length > 0 and its items must be an instanceof Transform", ->
          for pln in @plnArray
            expect(pln._sections[0]).to.have.length.above 0
            for st in pln._sections[0]
              expect(st).to.be.an.instanceof Transform

      describe "pipeline's behaviour:", ->

        beforeEach run.before
        afterEach  ->
         run.after.call @
         # lets re-use the agents
         for agent in spies.used
            spies.free.push spies.used.pop()

        it "must always let data passthrough", (done) ->
          for pln, i in @plnArray
            do (pln, i) =>
              addToTestContext2.call @

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data1

          @resolve done

        it "must transform data at the entry point if #_entry isn't noop", (done) ->
          data2 = @data2
          transform = (c) -> @push data2

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @
              pln._entry = transform

              spyEntry = spy pln.entry
              spyExit = spy pln.exit

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyEntry).to.have.been.calledOnce.and.calledWith @data1
                expect(spyExit).to.have.been.calledOnce.and.calledWith @data2
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data2

          @resolve done

        it "must transform data at the exit point if #_exit isn't noop", (done) ->
          data2 = @data2
          transform = (c) -> @push data2

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @
              pln._exit = transform

              spyEntry = spy pln.entry
              spyExit = spy pln.exit

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyEntry).to.have.been.calledOnce.and.calledWith @data1
                expect(spyExit).to.have.been.calledOnce.and.calledWith @data1
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data2

          @resolve done

        # this two test are actually done on the following specs
        # it "must be able two reset the entry and exit streams of a pipeline", ->

        it "must transform at both points if #_entry and #_exit aren't noop", (done) ->
          data2 = @data2
          transformEntry = (c) -> @push data2

          data3 = @data3
          transformExit = (c) -> @push data3

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @

              pln._entry = transformEntry
              pln._exit = transformExit

              spyEntry = spy pln.entry
              spyExit = spy pln.exit

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyEntry).to.have.been.calledOnce.and.calledWith @data1
                expect(spyExit).to.have.been.calledOnce.and.calledWith @data2
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data3

          @resolve done

        # this two test are actually done on the following specs
        # it "must be able to reset a stream's transform once it is within a pipeline", ->

        it "must transform data only within the pipeline's entry and exit points", (done) ->
          data2 = @data2
          transform = (c) -> @push data2

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @

              # hacking into first stream of the first section of the pipeline
              stream = pln._sections[0][0]
              oldT = stream._transform
              stream._transform = (c,e,n) ->
                oldT.call @, data2, e, n

              spyS = spy stream

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyS).to.have.been.calledOnce.and.calledWith @data1
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data2

          @resolve done

        it "must not let pass data get out of pipeline if #_exit === null", (done) ->

          data2 = @data2
          transform = (c) -> @push data2

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @

              pln._exit = null
              spyS = spy pln._sections[0][0]

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyS).to.have.been.calledOnce.and.calledWith @data1
                expect(@spyZ).to.not.have.been.called

          @resolve done

        it "must not let data get in of pipeline if #_entry === null", (done) ->
          data2 = @data2
          transform = (c) -> @push data2

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @

              pln._entry = null

              spyEntry = spy pln.entry
              spyExit = spy pln.exit
              spyS = spy pln._sections[0][0]

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyEntry).to.have.been.calledOnce.and.calledWith @data1
                expect(spyS).to.not.have.been.called
                expect(spyExit).to.not.have.been.called
                expect(@spyZ).to.not.have.been.called

          @resolve done

        it "must re-use same pipeline junction", (done) ->
          data2 = @data2
          transform = (c) -> @push data2

          data3 = @data3
          transform = (c) -> @push data3

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @

              @pln pln, @streams()

              spyEntry = spy pln.entry
              spyExit = spy pln.exit

              # spying on 1st stream of the 1st section
              streamA = pln._sections[0][0]
              oldA = streamA._transform
              streamA._transform = (c,e,n) ->
                oldA.call @, data2, e, n

              # spying on 1st stream of the 2nd section
              streamB = pln._sections[1][0]
              oldB = streamB._transform
              streamB._transform = (c,e,n) ->
                oldB.call @, data3, e, n

              # spying on the 2nd stream of the 2nd section 
              spyA = spy pln._sections[1][1]

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(spyEntry).to.have.been.calledOnce.and.calledWith @data1
                expect(spyExit).to.have.been.calledTwice
                expect(spyExit).to.have.been.calledWith @data2
                expect(spyExit).to.have.been.calledWith @data3

                expect(spyA).to.have.been.calledOnce.and.calledWith @data3
                expect(@spyZ).to.have.been.calledTwice
                expect(@spyZ).to.have.been.calledWith @data2
                expect(@spyZ).to.have.been.calledWith @data3

          @resolve done





