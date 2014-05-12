var Deferred, Promise, bufferMode, extendCtx, objectMode, sinon, spy, through;

through = require("super-stream.through");

sinon = require("sinon");

Promise = require("es6-promise").Promise;


/* istanbul ignore next */

spy = function(stream) {
  var agent, fn;
  if (spy.free.length === 0) {
    agent = sinon.spy();
  } else {
    agent = spy.free.pop();
    agent.reset();
  }
  spy.used.push(agent);
  fn = stream._transform;
  stream.spy = agent;
  stream._transform = function(c) {
    agent(c);
    return fn.apply(this, arguments);
  };
  return agent;
};

spy.free = [];

spy.used = [];


/* istanbul ignore next */

extendCtx = function(fn) {
  this.thr = fn.factory(this.optA);
  this.thrX = fn.factory(this.optB);
  this.noop = this.thr();
  this.stA = this.thr();
  this.stB = this.thr(this.optA);
  spy(this.stA);
  spy(this.stB);
  this.streamsArray = [this.stA, this.stB, this.stX, this.stY, this.stZ];
  return this.dataArray = [this.data1, this.data2];
};

bufferMode = {
  desc: 'streams in buffer mode:',

  /* istanbul ignore next */
  before: function(fn) {
    return function() {
      var ctor;
      this.optA = {};
      this.optB = {
        objectMode: true
      };
      this.data1 = new Buffer("data1");
      this.data2 = new Buffer("data2");
      this.stX = fn.buf();
      spy(this.stX);
      this.stY = fn.buf(function(c, e, n) {
        return n(null, c);
      });
      spy(this.stY);
      ctor = fn.ctor(this.optA, function(c, e, n) {
        return n(null, c);
      });
      this.stZ = ctor();
      spy(this.stZ);
      extendCtx.call(this, fn);
      return this;
    };
  },

  /* istanbul ignore next */
  after: function() {
    var agent, _i, _len, _ref, _results;
    _ref = spy.used;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      agent = _ref[_i];
      _results.push(spy.free.push(spy.used.pop()));
    }
    return _results;
  }
};

objectMode = {
  desc: 'streams in object mode:',

  /* istanbul ignore next */
  before: function(fn) {
    return function() {
      var ctor;
      this.optA = {
        objectMode: true
      };
      this.optB = {};
      this.data1 = "data1";
      this.data2 = "data2";
      this.stX = fn.obj();
      spy(this.stX);
      this.stY = fn.obj(function(c, e, n) {
        return n(null, c);
      });
      spy(this.stY);
      ctor = fn.ctor(this.optA, function(c, e, n) {
        return n(null, c);
      });
      this.stZ = ctor();
      spy(this.stZ);
      extendCtx.call(this, fn);
      return this;
    };
  },

  /* istanbul ignore next */
  after: function() {
    var agent, _i, _len, _ref, _results;
    _ref = spy.used;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      agent = _ref[_i];
      _results.push(spy.free.push(spy.used.pop()));
    }
    return _results;
  }
};


/* istanbul ignore next */

Deferred = function() {
  this.promise = new Promise((function(_this) {
    return function(resolve, reject) {
      _this.resolve_ = resolve;
      return _this.reject_ = reject;
    };
  })(this));
  return this;
};


/* istanbul ignore next */

Deferred.prototype.resolve = function() {
  return this.resolve_.apply(this.promise, arguments);
};


/* istanbul ignore next */

Deferred.prototype.reject = function() {
  return this.reject_.apply(this.promise, arguments);
};


/* istanbul ignore next */

Deferred.prototype.then = function() {
  return this.promise.then.apply(this.promise, arguments);
};


/* istanbul ignore next */

Deferred.prototype["catch"] = function() {
  return this.promise["catch"].apply(this.promise, arguments);
};

module.exports = {
  bufferMode: bufferMode,
  objectMode: objectMode,
  Deferred: Deferred
};
