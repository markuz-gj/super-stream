domain = require "domain"

{Transform, Readable, Duplex} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

junction = require "super-stream/junction"
isStream = require "../src/isStream"

{isJunction, isDuplex} = isStream
# created fake npm package
each = require "super-stream/each"

describe "exported value:", ->

  it 'should be a function', -> 
    expect(isStream).to.be.an.instanceof Function

  it 'should have property isJunction', ->
    expect(isStream).to.have.property 'isJunction'

describe "isStream's behaviour", ->

  it "should detect a junction", ->
    expect(isJunction junction()).to.be.true

# beforeEachHook = Object.create null

# beforeEachHook["describing returned function from map.factory():\n"] =  ->
#   @map = map.factory()
#   @objMode = no
#   @data = new Buffer "data"
#   @data2 = new Buffer "data2"
#   @data3 = new Buffer "data3"

# beforeEachHook["describing returned function from map.factory({objectMode: true}):\n"] =  ->
#   @map = map.factory {objectMode: true}
#   @objMode = yes
#   @data = "data"
#   @data2 = "data2"
#   @data3 = "data3"

# for desc, runFunction of beforeEachHook

#   describe desc, ->

#     beforeEach runFunction
    
#     afterEach -> @map = @objMode = @data = @data2 = undefined






