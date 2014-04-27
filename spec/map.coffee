domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

map = require "../src/map"

# created fake npm package
each = require "super-stream/each"

describe "exported value:", ->

  it 'should be a function', -> 
    expect(map).to.be.an.instanceof Function

  it "should have #factory property", -> 
    expect(map).to.have.property "factory"

beforeEachHook = Object.create null

beforeEachHook["describing returned function from map.factory():\n"] =  ->
  @map = map.factory()
  @objMode = no
  @data = new Buffer "data"
  @data2 = new Buffer "data2"
  @data3 = new Buffer "data3"

beforeEachHook["describing returned function from map.factory({objectMode: true}):\n"] =  ->
  @map = map.factory {objectMode: true}
  @objMode = yes
  @data = "data"
  @data2 = "data2"
  @data3 = "data3"

for desc, runFunction of beforeEachHook

  describe desc, ->

    beforeEach runFunction
    
    afterEach -> @map = @objMode = @data = @data2 = undefined

    describe "describing stream from map():", ->

      it "should be an instanceof Transform", -> expect(@map()).to.be.an.instanceof Transform
      it "should not have a #_map property", -> expect(@map()).to.not.have.property "_map"

    describe "describing stream from map(function(c){}):", ->

      beforeEach ->
        ctx = @
        @stA = @map (c) -> return c
        @stB = @map (c) ->
          if c.toString() is ctx.data2.toString()
            return c
          return 

      afterEach -> @stA = @stB = undefined

      it "should have a #_map property", -> 
        expect(@stA).to.have.property "_map"

      it "should not have a #_transform.next property if stream hasn't been used", ->
        expect(@stA._transform).to.not.have.property "next"

      it "should have a #_transform.next property if stream has been used", ->
        @stA.write "data"
        expect(@stA._transform).to.have.property "next"

      it "should have the map function context set to a clean hash", ->
        ctx = @
        @stA.pipe @map (c) ->
          expect(@).to.not.be.an.instanceof Object
          expect(@).to.be.deep.equal Object.create null
          return

        @stA.write @data

      it "should call map transform with two arguments only", ->
        @stA.pipe @map ->
          expect(arguments.length).to.be.equal 2
          return
        @stA.write @data

      it "should selectively pass data down stream", ->
        ctx = @
        spy = sinon.spy()
        @stB.pipe @map (c) -> 
          spy c.toString()

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 1
            ctx.stB.write data

        async(@data).then ->
          expect(spy).to.not.been.calledWith ctx.data.toString()
          return async(ctx.data2)
        .then ->
          expect(spy).to.been.calledWith ctx.data2.toString()

      it "should stream -1, and have it be incremented twice", ->
        m = @map.factory {objectMode: yes}
        spy = sinon.spy()
        s0 = m()

        s0.pipe m (value) -> return ++value
          .pipe m (value) -> return ++value
          .pipe m (value) -> spy value; return

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 1
            s0.write data

        async(-1).then (value) ->
          expect(spy).to.be.calledWith 1

      it "should pass data down stream multiple times in the same pipeline", ->
        m = @map.factory {objectMode: yes}

        spy = sinon.spy()
        s0 = m()
        s0.pipe m (c) -> return ++c
          .pipe m (c) -> return ++c
          .pipe m (c) -> spy c; return

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 1
            s0.write data

        async(-1).then ->
          expect(spy).to.be.calledWith 1
          return async 1
        .then ->
          expect(spy).to.have.been.calledWith 3
          expect(spy).to.not.have.been.calledWith 5
          return async 3
        .then ->
          return expect(spy).to.have.been.calledWith 5





