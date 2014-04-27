domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

reduce = require "../src/reduce"

# created fake npm package
each = require "super-stream/each"

describe "exported value:", ->

  it 'should be a function', ->
    expect(reduce).to.be.an.instanceof Function

  it "should have #factory property", ->
    expect(reduce).to.have.property "factory"

beforeEachHook = Object.create null

beforeEachHook["describing returned function from reduce.factory():\n"] =  ->
  @reduce = reduce.factory()
  @objMode = no
  @data = new Buffer "data"
  @data2 = new Buffer "data2"
  @data3 = new Buffer "data3"

beforeEachHook["describing returned function from reduce.factory({objectMode: true}):\n"] =  ->
  @reduce = reduce.factory {objectMode: true}
  @objMode = yes
  @data = "data"
  @data2 = "data2"
  @data3 = "data3"

for desc, runFunction of beforeEachHook

  describe desc, ->

    beforeEach runFunction
    afterEach -> @reduce = @objMode = @data = @data2 = undefined

    describe "describing stream from reduce():", ->

      it "should be an instanceof Transform", ->
        expect(@reduce()).to.be.an.instanceof Transform

      it "should not have a #_reduce property", ->
        expect(@reduce()).to.not.have.property "_reduce"

    describe "describing stream from reduce(function(c){}):", ->

      beforeEach ->
        ctx = @
        @stA = @reduce (c) -> @flush c
        @stB = @reduce (c) ->
          if c.toString() is ctx.data2.toString()
            @flush c
          @flush()

      afterEach -> @stA = @stB = undefined

      it "should have a #_reduce property", ->
        expect(@stA).to.have.property "_reduce"

      it "should not have a #_transform.next property if stream hasn't been used", ->
        expect(@stA._transform).to.not.have.property "next"

      it "should have a #_transform.next property if stream has been used", ->
        @stA.write "data"
        expect(@stA._transform).to.have.property "next"

      it "should have the reduce function context set to a hash with flush key", ->
        ctx = @
        @stA.pipe @reduce (c) ->
          expect(@).to.not.be.an.instanceof Object
          counter = 0
          for k, v of @
            counter++
            expect(counter).to.be.equal 1
            expect(k).to.be.equal "flush"
          return

        @stA.write @data

      it "should call reduce transform with two arguments only", ->
        @stA.pipe @reduce ->
          expect(arguments.length).to.be.equal 2
          return
        @stA.write @data

      it "should stream -1 and have it be incremented twice", ->
        r = @reduce.factory {objectMode: yes}
        spy = sinon.spy()
        s0 = r()

        s0.pipe r (value) -> @flush ++value
          .pipe r (value) -> @flush ++value
          .pipe r (value) -> spy value

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 10
            s0.write data

        async(-1).then (value) ->
          expect(spy).to.be.calledWith 1

      it "should selectively pass data down stream", ->
        ctx = @
        spy = sinon.spy()
        @stB.pipe @reduce (c) -> 
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
       
      it "should pass data down stream multiple times", ->
        r = @reduce.factory {objectMode: yes}

        spy = sinon.spy()
        s0 = r()
        s0.pipe r (c) -> @flush ++c
          .pipe r (c) -> @flush ++c
          .pipe r (c) -> spy c

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 10
            s0.write data

        async(-1).then ->
          expect(spy).to.be.calledWith 1
          return async 1
        .then ->
          expect(spy).to.be.calledWith 3
          expect(spy).to.not.be.calledWith 5
          return async 3
        .then ->
          expect(spy).to.be.calledWith 5

      it "should keep data at the reduce's context", ->
        r = @reduce.factory {objectMode: yes}

        spy = sinon.spy()
        s0 = r()
        s0.pipe r (c) -> @flush ++c
          .pipe r (c) -> 
            ++c
            @stack ?= []
            @stack.push c 
            if c > 3 
              ans = 0
              ans += i for i in @stack
              @flush ans

          .pipe r (c) -> 
            spy c

        async = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 1
            s0.write data

        async(-1).then ->
          return async 1
        .then ->
          return async 3
        .then ->
          expect(spy).to.be.calledWith 9

      it "should clean the reduce's context once flush is called", ->
        r = @reduce.factory {objectMode: yes}

        spy = sinon.spy()
        s0 = r()
        s0.pipe r (c) -> @flush ++c
          .pipe r (c) -> 
            ++c
            @stack ?= []
            @stack.push c 
            if c > 3 
              ans = 0
              ans += i for i in @stack
              @flush ans

          .pipe r (c) -> spy c

        asyncA = (data) ->
          return new Promise (resolve, reject) ->
            setTimeout resolve, 1
            s0.write data

        asyncB = ->
          return asyncA(-1).then ->
              return asyncA 1
            .then ->
              return asyncA 3
            .then ->
              expect(spy).to.be.calledWith 9
              expect(spy).to.not.be.calledWith 18


        asyncB().then -> asyncB()


