domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

filter = require "../src/filter"
each = require "../src/each"

describe "exported value", ->
  it 'should be a function', ->
    expect(filter).to.be.an.instanceof Function

describe "stream returned by #filter", ->

  beforeEach ->
    @noop = filter()
    @stA = filter (f) ->
      return yes

    @stB = filter (f) ->
      return no

  it "should be an instanceof `Transform`", ->
    expect(@noop).to.be.an.instanceof Transform

  describe "#filter() called without arguments", ->

    it "should return a noop Transform", ->

    it "should have a `#_filter` property", ->
      expect(@noop).to.have.property "_filter"

    it "should not have a `#_filter.next` property", ->
      expect(@noop._filter).to.not.have.property "next"



  # NOTE: use some promise to test this next two specs

  describe "#filter() called with function arguments", ->

    it "should let chunk pass", ->
      @stA.pipe each (f) ->
        # console.log f.toString()

      @stA.write "data"

    it "should not let chunk pass", ->
      @stB.pipe each (f) ->
        console.log f.toString()

      @stA.write "data"




