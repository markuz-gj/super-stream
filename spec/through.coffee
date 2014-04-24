domain = require "domain"

{Transform, Readable} = require "readable-stream"
isObject = require "lodash-node/modern/objects/isObject"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

through = require "../src/through"

describe "exported value", ->
  C = {}

  it 'should be a function', ->
    expect(through).to.be.an.instanceof Function

  it "should have `obj` property", ->
    expect(through).to.have.property "obj"

  it "should have `ctor` property", ->
    expect(through).to.have.property "ctor"

  it "should have `factory` property and have it equal to `ctor` property", ->
    expect(through.factory).to.be.equal through.ctor
    expect(through).to.have.property "factory"

describe "#through", ->


  it "should return an instance of Transform", ->
    expect(through()).to.be.an.instanceof Transform

  it "should return a noop Transform if called without arguments", ->
    stA = through()
    stB = through()

    chunk = new Buffer "data"

    stA.pipe through (f,e,n) ->
      @push f;n()
      expect(f).to.equal chunk
      # console.log f.toString()
    .pipe stB
    .pipe through (f,e,n) ->
      @push f;n()

      # should.be.equal chunk
      # should(f).be.equal chunk
      # should.be.equal f, chunk
      expect(f).to.equal chunk
      # should.be.equal f, chunk
      # console.log f.toString()

    stA.write chunk





