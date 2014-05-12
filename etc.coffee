###*
 * @module super-stream/etc
 * @author Marcos GJ 
 * @license MIT
 * @desc some helper functions
 ###

path = require "path"
{readFile, writeFile} = require "fs"
{exec} = require "child_process"
{Promise} = require "es6-promise"

gulp = require "gulp"
{colors, log, replaceExtension} = require "gulp-util"
{bold, red, magenta} = colors

coffee = require "gulp-coffee"
jsdoc = require "gulp-jsdoc"

express = require "express"
livereload = require "gulp-livereload"
tinylr = require "tiny-lr"
conn = require "connect"
conn.livereload = require 'connect-livereload'
conn.markdown = require "markdown-middleware"

through = require "super-stream.through"
thr = through.obj

###*
  * @param {Object} evt - event object from gulp.watch
  * @param {String} code - code value to be passed to process.exit
  ###
exit = (evt, code = 0) ->
  if evt.type is 'changed'
    log bold red "::: Existing gulp task now :::"
    process.exit code

###*
  * @param {String} cmd - a shell command to be passed to child_process.exec
  * @returns {Promise} - A promise which resolve whenever child_process closes or reject on error event only.
  ###
shell = (cmd) ->
  return new Promise (resolve, reject) ->
    cache =
      stdout: []
      stderr: []

    stream = exec cmd
    stream.on "error", reject

    stream.stdout.pipe thr (f,e,n) -> cache.stdout.push f; n()
    stream.stderr.pipe thr (f,e,n) -> cache.stderr.push f; n()

    stream.on "close", (code) ->
      str = cache.stdout.join ''
      str = "#{str}\n#{cache.stderr.join ''}"
      resolve(str)

###*
  * @param {String} spec - filename of the test file to be run
  * @returns {Function} - A gulp task
  ###
mocha =  (spec) ->
  ->
    cmd = "./node_modules/mocha/bin/mocha  --compilers coffee:coffee-script/register #{spec} -R spec -t 1000 "
    shell cmd
      .catch (err) ->
        throw new Error err
      .then (str) ->
        console.log str

###*
  * @param {String} spec - filename of the test to be run
  * @returns {Function} - A gulp task
  ###
istanbul = (spec) ->
  spec = replaceExtension spec, ".js"
  ->
    cmd = "./node_modules/istanbul/lib/cli.js cover --report html ./node_modules/mocha/bin/_mocha -- #{spec} -R dot -t 1000"
    
    shell cmd
      .catch (err) ->
        throw new Error err
      .then (str) ->
        console.log "\nIstanbul coverage summary:"
        console.log "==========================\n"
        console.log str.split('\n')[7..10].join('\n')
        fpath = "#{str.split('\n')[-3..-3].join('').split(' ')[4].split('')[1..-2].join('')}/index.html"
        console.log "\nopen:", "./#{path.relative process.cwd(), fpath}"

###*
  * @param {String} glob - glob pattern to watch. NOTE: doesn't support an array.
  * @returns {Function} - A gulp task
  * @desc 
  * It creates a express/livereload servers and server the `./coverage/index.html`, `./jsdoc/index.html` and `./*.md` diles
  ###
server = (glob) ->
  globs = [glob, "./coverage/index.html", './jsdoc/index.html']
  app = express()

  app.use conn.errorHandler {dumpExceptions: true, showStack: true }
  app.use conn.livereload()
  app.use conn.markdown {directory: __dirname}

  app.use '/coverage', express.static path.resolve './coverage'
  app.use '/jsdoc', express.static path.resolve './jsdoc'

  app.listen 3001, ->
    log bold "express server running on port: #{magenta 3001}"

  serverLR = tinylr {
    liveCSS: off
    liveJs: off
    LiveImg: off
  }

  lrUp = new Promise (resolve, reject) ->
    serverLR.listen 35729, (err) ->
     return reject err if err
     resolve()

  ->
    gulp.watch globs, (evt) ->
      lrUp.then ->
        log 'LR: reloading....'
        gulp.src evt.path
          .pipe livereload serverLR

###*
  * @private
  * @returns {Transform} - A `Transform` Stream which extract all jsdoc @desc tags, concat them and write a `README.md`
  ###
writeReadme = ->

  fixLine = (line) ->
    line.replace /^[ ]*\* @description/, ''
      .replace /^[ ]*\* @desc/, ''
      .replace /^[ ]*\*/, ''
      .replace /^[ ]/, ''

  thr (f, e, n) ->
    cache = {}
    cache.str = []
    cache.bool = no
    cache.buf = []

    file = f.contents.toString()
    file.split('\n').map (line) ->

      if cache.bool and line.match /\* @/
        cache.bool = no

      if line.match /\*\//
        cache.bool = no
        if cache.buf.length
          cache.str.push cache.buf.join '\n'
        cache.buf = []

      if line.match /\* @desc/
        cache.bool = yes

      if cache.bool
        cache.buf.push fixLine line

    writeFile './README.md', cache.str.join('\n'), (err) ->
      n err if err
      n null, f

###*
  * @private
  * @returns {Transform} - A `Transform` Stream which un-escape ##\# 
  * @desc Coffeescript triple # comment style conflics with markdown triple #. 
  * So the markdown triple # are "escaped" and this stream un-escapes it. :) cool hack hum?.
  ###
fixMarkdown = ->
  thr (f,e,n) ->
    f.contents = new Buffer f.contents.toString().replace(/\\#/g,'#').replace('\*#', '##')
    n null, f

###*
 * @param {String} src - glob pattern to watch. NOTE: doesn't support an array
 * @returns {Function} - A gulp task
 ###
compileDoc = (src) ->
  # # sample template config
  # template = {
  #   path: 'ink-docstrap'
  #   systemName: 'super-stream'
  #   footer: 'lol - my footer'
  #   copyright: "my copyright"
  #   navType: "vertical"
  #   theme: "spacelab"
  #   linenums: yes
  #   collapseSymbols: no
  #   inverseNav: no
  # }

  config =
    plugins: ['plugins/markdown']
    markdown: 
      parser: 'gfm'
      hardwrap: yes

  -> 

    gulp.src replaceExtension(src, '.js')
      .pipe fixMarkdown()
      .pipe writeReadme()
      .pipe jsdoc.parser config
      .pipe jsdoc.generator 'jsdoc'
      # .pipe jsdoc.generator 'jsdoc', template

###*
 * @param {String|Array} globs - glob pattern to watch
 * @returns {Function} - A gulp task
 ###
compileCoffee = (globs) ->
  -> 
    gulp.src globs
      .pipe coffee {bare: yes}
      .pipe gulp.dest('.')

module.exports =
  exit: exit
  shell: shell
  mocha: mocha
  istanbul: istanbul
  server: server
  jsdoc: compileDoc
  coffee: compileCoffee

