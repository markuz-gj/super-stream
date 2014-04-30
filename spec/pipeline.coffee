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

  @plnArray = [@pln(), @pln(), @pln()]

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

describe "exported value:", ->

  it 'must be a function', -> 
    expect(pipeline).to.be.an.instanceof Function

  it "must have #factory be an instanceof Function", ->
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
      
        it "must #_sections length > 0 and its items must be an instanceof Transform", ->
          for pln in @plnArray
            expect(pln._sections).to.have.length.above 0
            for st in pln._sections
              expect(st).to.be.an.instanceof Transform

      describe "pipeline's behaviour:", ->

        beforeEach run.before
        afterEach  ->
         run.after.call @
         # lets re-use the agents
         for agent in spies.used
            spies.free.push spies.used.pop()

        it "must let data passthrough", (done) ->
          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data1

          @resolve done

        it "must transform it at the #_entry and let data passthrough", (done) ->
          data2 = @data2
          transform = (c) -> @push data2

          for pln in @plnArray
            do (pln) =>
              addToTestContext2.call @
              pln._entry = transform

              @stX.pipe pln
                .pipe @stZ

              @promise =>
                expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
                expect(@spyZ).to.have.been.calledOnce.and.calledWith @data2

          @resolve done

          # beforeEachHook = Object.create null

# beforeEachHook["describing returned function from pipeline.factory():\n"] =  ->
#   @pln = pipeline.factory()
#   @ea = each.factory()
#   @objMode = no
#   @data = new Buffer "data"
#   @data2 = new Buffer "data2"
#   @data3 = new Buffer "data3"

# beforeEachHook["describing returned function from pipeline.factory({objectMode: true}):\n"] =  ->
#   @pln = pipeline.factory {objectMode: yes}
#   @ea = each.factory {objectMode: yes}
#   @objMode = yes
#   @data = "data"
#   @data2 = "data2"
#   @data3 = "data3"

# for desc, runFunction of beforeEachHook

#   describe desc, ->

#     beforeEach runFunction
    
#     afterEach -> @pln = @objMode = @data = @data2 = undefined

#     describe "describing pipeline from pipeline():", ->
#       it "must be an instanceof Pipeline", ->



#         pl = pipeline()

#         stA = each (c) -> 
#           console.` 'a', c.toString()
#           @push c

#         stB = each (c) ->
#           console.log 'b', c.toString()
#           @push c

#         # stA.pipe pl
#         #   .pipe stB

#         # stA.write "A"

#         pl2 = pipeline [stA, pl, stB]

#         stC = each (c) ->
#           console.log 'c', c.toString()
#           @push c

#         stD = each (c) ->
#           console.log "d", c.toString()
#           @push c


#         stE = each (c) ->
#           console.log "e", c.toString()
#           @push c

#         stF = each (c) ->
#           console.log "f", c.toString()
#           @push c

#         pl3 = pipeline [stC, pl2, stD]


#         stE.pipe pl3
#           .pipe stF

#         stE.write "p"
#         # stC.pipe pl2
#         #   .pipe stD

#         # stC.write 'p'





#         # for k,i of pl
#         #   console.log k
#         # @pln()
#       #   expect(@pln()).to.be.an.instanceof @pln.Pipeline




