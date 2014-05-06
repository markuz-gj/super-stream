var SuperStream, chai, expect, sinon;

chai = require("chai");

sinon = require("sinon");

chai.use(require("sinon-chai"));

expect = chai.expect;

chai.config.showDiff = false;

SuperStream = require("./super-stream");

describe("exported value:", function() {
  return it('must be a Object', function() {
    return expect(SuperStream).to.be.an["instanceof"](Object);
  });
});
