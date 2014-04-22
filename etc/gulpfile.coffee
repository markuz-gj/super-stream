path = require "path"
domain = require "domain"

gulp = require "gulp"
{log, colors} = require "gulp-util"
{red, bold} = colors
coffee = require "gulp-coffee"
mocha = require "gulp-mocha"
watch = require "gulp-watch"
# grep = require "gulp-grep-stream"
# filter = require "gulp-filter"

{Transform} = require "stream"
istanbul = require "gulp-istanbul"

flatten = require "lodash-node/modern/arrays/flatten"

SRC   = "src"
DIST  = "dist"
SPEC  = "spec"
ETC   = "etc"

GLOBS =
  # src: "./#{SRC}/"
  # dist: "./#{DIST}/"
  # spec: "./#{SPEC}/"
  # etc: "./#{ETC}/"

	coffee:
    src: ["#{SRC}/*.coffee", "!node_modules/**/*"]
    dest: "#{DIST}"
    dist: "#{DIST}/**/*.js"
    ext: ".js"

  gulpfiles:
    src: ["#{ETC}/**/*.coffee"]

  mocha:
    src: ["#{SPEC}/*.coffee"]

#
## NOTE: extending GLOBS namespace now
#
GLOBS.mocha.src = flatten [GLOBS.mocha.src, GLOBS.coffee.src]

rand = (n = 6) -> ~~(Math.random()*(10**n))

ps = (str="-- #{rand 3} --") ->
  st = new Transform {objectMode: on}
  st._transform = (f,e,n) ->
    console.log "#{str} #{f.path}"
    @push f
    n()

  return st

gulp.task "watch:gulpfiles", ->
  cache = {}
  job = new Transform {objectMode: yes}
  job._transform = (f, e, n) ->
    if cache[f.path] 
      log bold red "::: Existing gulp task now :::"
      process.exit 13

    cache[f.path] = on
    @push f
    n()

  return gulp.src GLOBS.gulpfiles.src
    .pipe watch {emitOnGlob: no}
    .pipe job 

gulp.task "watch:spec", ->

  d = domain.create()
  d.on "error", (e) ->
    console.log e.stack
    console.log "EE:mocha", ~~(Math.random()*(10**4))

  watchStream = ->
    return watch {emit: 'all'}, (files) -> 

      mochaStream = mocha()
      for i, fn of mochaStream
        if fn instanceof Function
          mochaStream[i] = d.bind fn

      # mochaStream.pipe ps("@@")

      return files
        # .pipe filter("!src/*")
        .pipe mochaStream
        .pipe ps("01:#{rand()}")
  # returning task
  return gulp.src GLOBS.mocha.src, {read: off}
    .pipe watchStream()
    .pipe ps("00:#{rand(3)}")

gulp.task "default", ["watch:spec", "watch:gulpfiles"]

# gulp.task "assets", ["coffee"]

# gulp.task "coffee", ->
#   job = new Transform {objectMode: yes}
#   job._transform = (f, e, n) ->
#     console.log f.path
#     @push f
#     do n

#   return gulp.src GLOBS.coffee.src 
#     .pipe watch {emitOnGlob: no}
#     .pipe coffee {bare: yes}
#     .pipe job
