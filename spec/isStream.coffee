domain = require "domain"

{Transform, Duplex, Readable, Writable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

{Junction} = require "super-stream/junction"
isStream = require "../src/isStream"

{isJunction, isTransform, isDuplex, isReadable, isWritable} = isStream
{isReadableOnly, isDuplexOnly, isWritableOnly} = isStream
# created fake npm package
each = require "super-stream/each"

describe "exported value:", ->

  it 'should be a function', -> 
    expect(isStream).to.be.an.instanceof Object

  for prop in ['isJunction', 'isTransform', 'isDuplex', 'isReadable', 'isWritable', 'isReadableOnly', 'isWritableOnly', 'isDuplex']
    it "should have property #{prop}", ->
      expect(isStream).to.have.property prop

describe "isStream's behaviour", ->

  it "should detect a junction", ->
    expect(isJunction new Junction()).to.be.true
    expect(isJunction new Junction({objectMode: yes})).to.be.true

  it "should detect a Transform", ->
    expect(isTransform new Junction()).to.be.false
    expect(isTransform new Transform()).to.be.true
    expect(isTransform new Duplex()).to.be.false
    expect(isTransform new Writable()).to.be.false
    expect(isTransform new Readable()).to.be.false

  it "should detect a Duplex", ->
    expect(isDuplex new Junction()).to.be.true
    expect(isDuplex new Transform()).to.be.true
    expect(isDuplex new Duplex()).to.be.true
    expect(isDuplex new Writable()).to.be.false
    expect(isDuplex new Readable()).to.be.false

  it "should detect a Duplex only", ->
    expect(isDuplexOnly new Junction()).to.be.false
    expect(isDuplexOnly new Transform()).to.be.false
    expect(isDuplexOnly new Duplex()).to.be.true
    expect(isDuplexOnly new Writable()).to.be.false
    expect(isDuplexOnly new Readable()).to.be.false

  it "should detect a Readable", ->
    expect(isReadable new Junction()).to.be.true
    expect(isReadable new Transform()).to.be.true
    expect(isReadable new Duplex()).to.be.true
    expect(isReadable new Readable()).to.be.true
    expect(isReadable new Writable()).to.be.false

  it "should detect a Readable only", ->
    expect(isReadableOnly new Junction()).to.be.false
    expect(isReadableOnly new Transform()).to.be.false
    expect(isReadableOnly new Duplex()).to.be.false
    expect(isReadableOnly new Readable()).to.be.true
    expect(isReadableOnly new Writable()).to.be.false

  it "should detect a Writable", ->
    expect(isWritable new Junction()).to.be.true
    expect(isWritable new Transform()).to.be.true
    expect(isWritable new Duplex()).to.be.true
    expect(isWritable new Readable()).to.be.false
    expect(isWritable new Writable()).to.be.true

  it "should detect a Writable only", ->
    expect(isWritableOnly new Junction()).to.be.false
    expect(isWritableOnly new Transform()).to.be.false
    expect(isWritableOnly new Duplex()).to.be.false
    expect(isWritableOnly new Readable()).to.be.false
    expect(isWritableOnly new Writable()).to.be.true
