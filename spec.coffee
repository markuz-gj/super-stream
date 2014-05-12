
chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

{Transform} = require "readable-stream"

expect = chai.expect
chai.config.showDiff = no

ss = require "./index"


describe "exported value:", ->
  it 'must be a Object', ->
    expect(ss).to.be.an.instanceof Object

  it 'must have through method', ->
    expect(ss).to.have.property "through"
    expect(ss.through).to.be.an.instanceof Function

describe "through method", ->
  it 'must return a Transform stream', ->
    expect(ss.through()).to.be.an.instanceof Transform
    # console.log ss.through()
