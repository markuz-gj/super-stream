###
  * README.md intro
  * @desc 
  * ##\# warning: this is not ready for consuption yet
  ###

###*
 * @module super-stream
 * @author Markuz GJ 
 * @license MIT
 ###


###*
 * @typedef {Object} SuperStream
 * @property {Function} through
 ###

###* 
 * @type Function
 * @param {Object=} options - Set through default options.
 * @returns {SuperStream}
 ###
 #

factory = (options = {}) ->
  OPTIONS = options

  return {
    through: require("super-stream.through").factory OPTIONS
    factory: factory
  }

module.exports = factory()
