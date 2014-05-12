var Transform, chai, expect, sinon, ss;

chai = require("chai");

sinon = require("sinon");

chai.use(require("sinon-chai"));

Transform = require("readable-stream").Transform;

expect = chai.expect;

chai.config.showDiff = false;

ss = require("./index");

describe("exported value:", function() {
  it('must be a Object', function() {
    return expect(ss).to.be.an["instanceof"](Object);
  });
  return it('must have through method', function() {
    expect(ss).to.have.property("through");
    return expect(ss.through).to.be.an["instanceof"](Function);
  });
});

describe("through method", function() {
  return it('must return a Transform stream', function() {
    return expect(ss.through()).to.be.an["instanceof"](Transform);
  });
});
