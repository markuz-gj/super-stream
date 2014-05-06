var chai, expect, sinon, through;

chai = require("chai");

sinon = require("sinon");

chai.use(require("sinon-chai"));

expect = chai.expect;

chai.config.showDiff = false;

through = require("./through");

describe("exported value:", function() {
  return it('must be a function', function() {
    return expect(through).to.be.an["instanceof"](Function);
  });
});
