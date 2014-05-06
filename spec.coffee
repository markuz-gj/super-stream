
chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

expect = chai.expect
chai.config.showDiff = no

SuperStream = require "./super-stream"


describe "exported value:", ->
  it 'must be a Object', ->
    expect(SuperStream).to.be.an.instanceof Object
