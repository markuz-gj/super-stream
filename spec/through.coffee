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

addToTestContext = ->
  ctx = @
  @thr = through.factory @opts
  @thrArray = [@thr(), @thr(), @thr()]

addToTestContext2 = ->
  @stA = @thr (c,e,n) -> @push c, n()
  @stB = @thr (c,e,n) -> @push c, n()
  @stX = @thr (c,e,n) -> @push c, n()
  @stZ = @thr (c,e,n) -> @push c, n()

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

hooks["streams from `var thr = through.factory();`"] =
  before: ->
    @opts = {}
    addToTestContext.call @
    @data1 = new Buffer "data1"
    @data2 = new Buffer "data2"
    @data3 = new Buffer "data3"
    @data4 = new Buffer "data4"

  after: ->

hooks["streams from `var thr = through.factory({objectMode: true});`"] =
  before: ->
    @opts = {objectMode: yes}
    addToTestContext.call @
    @data1 = "data1"
    @data2 = "data2"
    @data3 = "data3"
    @data4 = "data4"

  after: ->

describe "exported value:", ->

  it 'should be a function', ->
    expect(through).to.be.an.instanceof Function

  it "should have obj property", ->
    expect(through).to.have.property "obj"

  it "should have ctor property", ->
    expect(through).to.have.property "ctor"

  it "should have factory property", ->
    expect(through).to.have.property "factory"
    expect(through.factory).to.be.an.instanceof Function

for desc, run of hooks
  do (desc, run) ->

    describe desc, ->
      beforeEach run.before
      afterEach ->
       run.after.call @
       # lets re-use the agents
       for agent in spies.used
          spies.free.push spies.used.pop()

      it "must return an instanceof Transform", ->
        for thr in @thrArray
          expect(thr).to.be.an.instanceof Transform

      it "must pass data through stream unchanged", (done) ->
        for thr in @thrArray
          do (thr) =>
            addToTestContext2.call @

            @stX.pipe @stA
              .pipe @stZ

            @promise =>
              expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
              expect(@spyA).to.have.been.calledOnce.and.calledWith @data1
              expect(@spyZ).to.have.been.calledOnce.and.calledWith @data1

        @resolve done

      it "must be able to re-use the same 'pipeline' multiple times", (done) ->
        for thr in @thrArray
          do (thr) =>
            addToTestContext2.call @

            @stX.pipe @stA
              .pipe @stZ

            @promise =>
              expect(@spyX).to.have.been.calledOnce.and.calledWith @data1
              expect(@spyA).to.have.been.calledOnce.and.calledWith @data1
              expect(@spyZ).to.have.been.calledOnce.and.calledWith @data1

        @resolve done

#         it "should use the same 'pipeline' multiple times", ->
#           th = through.factory {objectMode: yes}

#           spy = sinon.spy()
#           s0 = th()
#           s0.pipe th (c,e,n) -> n null, ++c
#             .pipe th (c,e,n) -> n null, ++c
#             .pipe th (c,e,n) -> 
#               spy c
#               n()

#           async = (data) ->
#             return new Promise (resolve, reject) ->
#               setTimeout resolve, 1
#               s0.write data

#           async(-1).then ->
#             expect(spy).to.have.been.calledWith 1
#             return async 1
#           .then ->
#             expect(spy).to.have.been.calledWith 3
#             expect(spy).to.not.have.been.calledWith 5
#             return async 3
#           .then ->
#             expect(spy).to.have.been.calledWith 5

#         it "should pass different options to through and have it reflect on the new stream only", ->
#           data = "data"
#           if @objMode
#             # @stX was defined with {objectMode: false}
#             @stX.pipe @th {objectMode: off}, (c) ->
#               expect(c.toString()).to.be.equal data.toString()
#               expect(c).to.not.be.equal data
#           else
#             # @stX was defined with {objectMode: true}
#             @stX.pipe @th {objectMode: on}, (c) ->
#               expect(c).to.be.equal data

#           @stX.write data


