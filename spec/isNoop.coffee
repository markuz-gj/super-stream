domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

isNoop = require "../src/isNoop"

# created fake npm package
each = require "super-stream/each"

describe "exported value:", ->

  it 'should be a function', ->
    expect(isNoop).to.be.an.instanceof Function



