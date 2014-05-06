###*
 * @module through
 * @author Marcos GJ 
 * @license MIT
 ###

###*
 * @external Transform
 * @requires module:through2
 * @requires module:lodash.isfunction
 * @requires module:lodash.defaults
 ###

through2 = require "through2"
isFunction = require "lodash.isfunction"
defaults = require "lodash.defaults"

###*
 * @global
 * @type Object
 * @default {}
 * @desc default options passed to through2 if none is provided
 ###
OPTIONS = {}

###*
 * @desc A wrapper function around through2 
 * @type Function
 * @param {Object=|Function=} options - Options passed through2 or a transform function (optional)
 * @param {Function=} transform - Transform function (optional)
 * @param {Function=} flush - Flush function (optional)
 * @returns {Transform} - A transform stream
 ###
through = (options, transform, flush) ->
  if isFunction options
    flush = transform
    transform = options
    options = OPTIONS
  else
    options = defaults options, OPTIONS

  if arguments.length is 0
    options = OPTIONS

  return through2 options, transform, flush

###*
 * @typedef {Function} Through
 * @property {Function} factory 
 * @property {Function} ctor
 * @property {Function} obj
 ###

###* 
 * @desc A factory function
 * @type Function
 * @param {Object=} options - Set through default options.
 * @returns {Through}
 ###
factory = (options = {}) ->
  OPTIONS = options

  through.factory = factory
  through.ctor = through2.ctor
  through.obj = through2.obj

  return through

module.exports = factory()
