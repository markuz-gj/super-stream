domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

pipeline = require "../src/pipeline"

pl = pipeline.pipeline
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
        @pln()
      #   expect(@pln()).to.be.an.instanceof @pln.Pipeline




