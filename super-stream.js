
/**
 * @module super-stream
 * @author Marcos GJ 
 * @license MIT
 */

/**
 * @global
 * @type Object
 * @default {}
 * @desc default options passed to through2 if none is provided
 */
var OPTIONS, factory;

OPTIONS = {};


/**
 * @typedef {Object} SuperStream
 * @property {Function} through
 */


/** 
 * @desc A factory function
 * @type Function
 * @param {Object=} options - Set through default options.
 * @returns {SuperStream}
 */

factory = function(options) {
  if (options == null) {
    options = {};
  }
  OPTIONS = options;
  return {
    through: require("super-stream-through").factory(OPTIONS),
    factory: factory
  };
};

module.exports = factory();
