domain = require "domain"

{Transform, Readable} = require "readable-stream"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
should = chai.should()

Each = require "../src/each"


describe "exported value", ->
  console.log "#each:"
  it 'should be a function', ->
    Each.should.be.an.instanceof Function


