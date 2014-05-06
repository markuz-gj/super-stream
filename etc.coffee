###*
 * @module super-stream/etc
 * @author Marcos GJ 
 * @license MIT
 * @desc some helper functions
 ###

{exec} = require "child_process"
{Promise} = require "es6-promise"

gulp = require "gulp"
{colors, log, replaceExtension} = require "gulp-util"
{bold, red} = colors

through = require './through'
th = through.obj

###*
 * @type Function
 * @param {String} cmd - a shell command to be passed to child_process.exec
 * @returns {Promise}
 ###
shell = (cmd) ->
  promise = new Promise (resolve, reject) ->
    cache =
      stdout: []
      stderr: []

    stream = exec cmd
    stream.on "error", reject

    stream.stdout.pipe th (f,e,n) -> cache.stdout.push f; n()
    stream.stderr.pipe th (f,e,n) -> cache.stderr.push f; n()

    stream.on "close", (code) ->
      str = cache.stdout.join ''
      str = "#{str}\n#{cache.stderr.join ''}"
      resolve(str)

###*
 * @type Function
 * @param {String} spec - filename of the test to be run
 * @returns {Function}
 ###
mocha =  (spec) ->
  ->
    cmd = "./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register #{spec} -R spec -t 1000"
    shell cmd
      .catch (err) ->
        throw new Error err
      .then (str) ->
        console.log str

###*
 * @type Function
 * @param {String} spec - filename of the test to be run
 * @returns {Function}
 ###
istanbul = (spec) ->
  spec = replaceExtension spec, ".js"
  ->
    cmd = "./node_modules/istanbul/lib/cli.js cover --report html ./node_modules/mocha/bin/_mocha -- #{spec} -R dot -t 1000"
    shell cmd
      .catch (err) ->
        throw new Error err
      .then (str) ->
        console.log "Istanbul coverage summary:"
        console.log "==========================\n"
        console.log str.split('\n')[7..10].join('\n')
        console.log "\n#{str.split('\n')[15].split(' ')[4].split('')[1..-2].join('')}/index.html"

###*
 * @type Function
 * @param {String} code - code value to be passed to process.exit
 ###
reboot = (code = 0) ->
  log bold red "::: Existing gulp task now :::"
  process.exit code

module.exports =
  shell: shell
  mocha: mocha
  istanbul: istanbul
  reboot: reboot

