domain = require "domain"

{Transform, Readable} = require "readable-stream"
{Promise} = require "es6-promise"

chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"
expect = chai.expect
chai.config.showDiff = false

each = require "../src/each"


describe "exported value", ->
  it 'should be a function', ->
    expect(each).to.be.an.instanceof Function

  it "should return a noop Transform if called without arguments", ->
    stA = each()
    stB = each()

    chunk = new Buffer "data"

    stA.pipe each (f,e,n) ->
      @push f;n()
      expect(f).to.equal chunk
      return null
    .pipe stB
    .pipe each (f,e,n) ->
      @push f;n()
      expect(f).to.equal chunk
      return null


    stA.write chunk

describe "stream returned by #each", ->

  beforeEach ->
    @noop = each()

    @chunk0 = new Buffer "data 0"
    @chunk1 = new Buffer "data 2"
    @chunk2 = new Buffer "data 1"

    @stA = each (f,e,n) -> 
      @push f
      n(); n(); n()
      # console.log "stA", f.toString()

    @stB = each {objectMode: yes}, (f,e,n) -> 
      @push f
      # console.log "stB", f.toString()

    @stC = each (f,e,n) -> 
      @push f
      # console.log "stC", f.toString()

  it "should be an instanceof `Transform`", ->
    expect(@noop).to.be.an.instanceof Transform

  it "should have a `#_each` property", ->
    expect(@noop).to.have.property "_each"

  it "should not have a `#_each.next` property", ->
    expect(@noop._each).to.not.have.property "next"

  it "should call `#next()` only once even if called multiple times", ->
    ctx = @
    @stA.pipe each (f) -> expect(f).to.equal ctx.chunk0
    @stA.write @chunk0

  it "should call `#next()` automatically and work on multiple `stream#write(chunk)`", ->
    ctx = @
    spy = sinon.spy()

    async = new Promise (resolve, reject) ->
      ctx.stA.pipe ctx.stB
        .pipe ctx.stC
        .pipe each (f) -> 
          spy()
          resolve(spy)

      ctx.stA.write ctx.chunk0

    async.then (spy) -> 
        ctx.stA.write ctx.chunk1
        return spy 
      .then (spy) -> 
        ctx.stA.write ctx.chunk2
        return spy 
      .then (spy) ->
        expect(spy).to.have.been.calledThrice
        return spy

  # it 






























