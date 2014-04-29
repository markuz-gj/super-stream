domain = require "domain"

{Transform, Readable, Duplex} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

junction = require "../src/junction"
each = require "super-stream/each"

describe "exported value:", ->

  it 'must be a function', -> 
    expect(junction).to.be.an.instanceof Function

  it "must have #factory be an instanceof Function", ->
    expect(junction).to.have.property "factory"
    expect(junction.factory).to.be.an.instanceof Function

  it "must have #Junction be an instanceof Function", ->
    expect(junction).to.have.property "Junction"
    expect(junction.Junction).to.be.an.instanceof Function

beforeEachHook = Object.create null

beforeEachHook["describing returned function from junction.factory():\n"] =  ->
  @jnt = junction.factory()
  @ea = each.factory()
  @objMode = no
  @data = new Buffer "data"
  @data2 = new Buffer "data2"
  @data3 = new Buffer "data3"

beforeEachHook["describing returned function from junction.factory({objectMode: true}):\n"] =  ->
  @jnt = junction.factory {objectMode: yes}
  @ea = each.factory {objectMode: yes}
  @objMode = yes
  @data = "data"
  @data2 = "data2"
  @data3 = "data3"

for desc, runFunction of beforeEachHook

  describe desc, ->

    beforeEach runFunction
    
    afterEach -> @jnt = @objMode = @data = @data2 = undefined

    describe "describing junction from junction():", ->

      it "must be an instanceof Junction", ->
        expect(@jnt()).to.be.an.instanceof @jnt.Junction

      it "must be an instanceof Duplex Stream only", ->
        expect(@jnt()).to.be.an.instanceof Duplex
        expect(@jnt()).to.not.be.an.instanceof Transform

      it "must have #_entry be an instanceof Function", ->
        expect(@jnt()).to.have.property "_entry"
        expect(@jnt()._entry).to.be.an.instanceof Function

      it "must have #entry be an instanceof Transform", ->
        expect(@jnt()).to.have.property "entry"
        expect(@jnt().entry).to.be.an.instanceof Transform

      it "must have #_exit be an instanceof Function", ->
        expect(@jnt()).to.have.property "_exit"
        expect(@jnt()._exit).to.be.an.instanceof Function

      it "must have #exit be an instanceof Transform", ->
        expect(@jnt()).to.have.property "exit"
        expect(@jnt().exit).to.be.an.instanceof Transform

      describe "junction behaviour:", ->

        it "must let data pass only through the entry stream", ->
          ctx = @

          spyA = sinon.spy()
          spyB = sinon.spy()

          stX = @ea (c) ->
            @next null, c

          stA = @ea (c) ->
            spyA c
            @next null, c

          stB = @ea (c) ->
            spyB c
            @next null, c

          jnt = @jnt()

          jnt.entry.pipe stA
          jnt.exit.pipe stB

          stX.pipe jnt

          async = (data) ->
            return new Promise (resolve, reject) ->
              setTimeout resolve, 1
              stX.write data

          async(@data).then ->
            expect(spyA).to.have.been.calledOnce
            expect(spyA).to.have.been.calledWith ctx.data
            expect(spyB).to.not.have.been.called

        it "must let data pass only through the exit stream", ->
          ctx = @

          spyA = sinon.spy()
          spyB = sinon.spy()

          stX = @ea (c) ->
            @next null, c

          stA = @ea (c) ->
            spyA c
            @next null, c

          stB = @ea (c) ->
            spyB c
            @next null, c


          jnt = @jnt()

          jnt.entry.pipe stA
          jnt.exit.pipe stB

          stX.pipe jnt.exit

          async = (data) ->
            return new Promise (resolve, reject) ->
              setTimeout resolve, 1
              stX.write data

          async(@data).then ->
            expect(spyA).to.not.have.been.called
            expect(spyB).to.have.been.calledWith ctx.data
            expect(spyB).to.have.been.calledOnce

        it "must let data pass only through the entry and exit stream", ->
          ctx = @

          spyA = sinon.spy()
          spyB = sinon.spy()

          stX = @ea (c) ->
            @next null, c

          stA = @ea (c) ->
            spyA c
            @next null, c

          stB = @ea (c) ->
            spyB c
            @next null, c

          jnt = @jnt()

          # creating a pipeline
          stX.pipe jnt
          jnt.entry.pipe stA
          stA.pipe stB
          jnt.exit.pipe stB

          async = (data) ->
            return new Promise (resolve, reject) ->
              setTimeout resolve, 1
              stX.write data

          async(@data).then ->
            expect(spyA).to.have.been.calledOnce
            expect(spyA).to.have.been.calledWith ctx.data

            expect(spyB).to.have.been.calledOnce
            expect(spyB).to.have.been.calledWith ctx.data


    describe "describing junction from junction({})", ->

      it "must work", ->

    describe "describing junction from junction({}, Readable)", ->

      it "must work", ->

    describe "describing junction from junction({}, Writable)", ->

      it "must work", ->

    describe "describing junction from junction({}, Readable, Writable)", ->

      it "must work", ->
















