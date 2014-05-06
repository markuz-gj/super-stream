
chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

expect = chai.expect
chai.config.showDiff = no

through = require "./through"


describe "exported value:", ->
  it 'must be a function', ->
    expect(through).to.be.an.instanceof Function
