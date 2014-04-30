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

describe "exported value:", ->

  it 'must be a function', -> 
    expect(pipeline).to.be.an.instanceof Function

  it "must have #factory be an instanceof Function", ->
    expect(pipeline).to.have.property "factory"
    expect(pipeline.factory).to.be.an.instanceof Function

  it "must have #Pipeline be an instanceof Function", ->
    expect(pipeline).to.have.property "Pipeline"
    expect(pipeline.Pipeline).to.be.an.instanceof Function

beforeEachHook = Object.create null

beforeEachHook["describing returned function from pipeline.factory():\n"] =  ->
  @pln = pipeline.factory()
  @ea = each.factory()
  @objMode = no
  @data = new Buffer "data"
  @data2 = new Buffer "data2"
  @data3 = new Buffer "data3"

beforeEachHook["describing returned function from pipeline.factory({objectMode: true}):\n"] =  ->
  @pln = pipeline.factory {objectMode: yes}
  @ea = each.factory {objectMode: yes}
  @objMode = yes
  @data = "data"
  @data2 = "data2"
  @data3 = "data3"

for desc, runFunction of beforeEachHook

  describe desc, ->

    beforeEach runFunction
    
    afterEach -> @pln = @objMode = @data = @data2 = undefined

    describe "describing pipeline from pipeline():", ->
      it "must be an instanceof Pipeline", ->



        pl = pipeline()

        stA = each (c) -> 
          console.log 'a', c.toString()
          @push c

        stB = each (c) ->
          console.log 'b', c.toString()
          @push c

        # stA.pipe pl
        #   .pipe stB

        # stA.write "A"

        pl2 = pipeline [stA, pl, stB]

        stC = each (c) ->
          console.log 'c', c.toString()
          @push c

        stD = each (c) ->
          console.log "d", c.toString()
          @push c


        stE = each (c) ->
          console.log "e", c.toString()
          @push c

        stF = each (c) ->
          console.log "f", c.toString()
          @push c

        pl3 = pipeline [stC, pl2, stD]


        stE.pipe pl3
          .pipe stF

        stE.write "p"
        # stC.pipe pl2
        #   .pipe stD

        # stC.write 'p'





        # for k,i of pl
        #   console.log k
        # @pln()
      #   expect(@pln()).to.be.an.instanceof @pln.Pipeline




