domain = require "domain"

{Transform, Readable} = require "readable-stream"
isObject = require "lodash-node/modern/objects/isObject"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
should = chai.should()

through = require "../src/through"

describe "exported value", ->
  
  C = {}


  it 'should be a function', ->
    through.should.be.an.instanceof Function

  it "should have factory property", ->
    through.should.have.property "factory"

  it "should have noop property", ->
    through.should.have.property "noop"

# describe "method #through", ->
#   it "should return a Transform stream"


describe "noop property", ->
  C = {}

  beforeEach ->
    C.opts = null

  it 'should be a function', ->
    through.noop.should.be.an.instanceof Function

  it "should return an instanceof Transform", ->
    through.noop().should.be.an.instanceof Transform

  it "should stream data through without modifying", ->
    chunk = new Buffer 'some data'
    noop1 = through.noop(C.opts)
    noop2 = through.noop(C.opts)

    # console.log through


    stream = through C.opts, (f,e,n) -> 
      should.equal f, chunk


    noop1.pipe(noop2).pipe(stream)
    noop1.write(chunk)


describe "factory property", ->
  C = {}

  beforeEach ->
    C.opts = {}

  it 'should be a function', ->
    through.factory.should.be.an.instanceof Function

  it "should return an instanceof Function", ->
    (through.factory()).should.be.an.instanceof Function


  # it ""
  # it "should return an instanceof"
  # it "should behave as a constructor is called without the new operator", ->
  #   through.Ctor().should.be.an.instanceof through.Ctor


  # it "should return a #newThrough with different options as default", ->
  #   cfg = {objectMode: on}
  #   ss = through.factory cfg

  #   noop = through.noop cfg
  #   noop.pipe ss (f,e,n) ->
  #     console.log f,e,n
  #     @push f
  #     n()

  #   noop.write "LLL"













