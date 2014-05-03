path = require "path"
domain = require "domain"
{exec} = require "child_process"
{puts} = require "util"

gulp = require "gulp"
gutil = require "gulp-util"
{log, colors, replaceExtension} = require "gulp-util"
{red, magenta, bold} = colors

coffee = require "gulp-coffee"
mocha = require "gulp-mocha"
# watch = require "gulp-watch"
# ea = require("through2").obj
match = require "minimatch"
prettyHrtime = require "pretty-hrtime"

{Transform} = require "stream"
Duplexer = require "plexer"
istanbul = require "gulp-istanbul"

flatten = require "lodash-node/modern/arrays/flatten"

eachBuf = require "../src/each"
pipeline = require "../src/pipeline"

each = eachBuf.factory {objectMode: yes}
pln = pipeline.factory {objectMode: yes}

SRC  = "src"
DIST = "dist"
SPEC = "spec"
ETC  = "etc"
TMP  = "tmp"

GLOBS =
	coffee:
    src: ["#{SRC}/*.coffee"]
    dest: "./#{DIST}/"
    tmp: "./#{TMP}/"
    dist: "./#{DIST}/**/*.js"
    ext: ".js"

  etc:
    src: ["#{ETC}/**/*.coffee"]

  spec:
    src: ["{#{SRC},#{ETC}}/*.coffee"]
    dest: "./#{DIST}/"
    tmp: "./#{TMP}/"
    dist: "./#{DIST}/**/*.js"
    ext: ".js"
#   mocha:
#     src: ["#{SPEC}/*.coffee"]

# #
# ## NOTE: extending GLOBS namespace now
# #
# GLOBS.mocha.src = flatten [GLOBS.mocha.src, GLOBS.coffee.src]

rand = (n = 6) -> ~~(Math.random()*(10**n))

ps = (str="-- #{rand 3} --") ->
  st = new Transform {objectMode: on}
  st._transform = (f,e,n) ->
    puts "#{str} #{f.path}"
    @push f
    n()

  return st

d = domain.create()
d.on "error", (e) ->
  puts e.stack
  puts "EE:mocha", ~~(Math.random()*(10**4))

# gulp.task "watch:spec", ->
#   cache = {}
#   return gulp.src GLOBS.mocha.src
#     .pipe watch()

#     # .pipe coffee {bare: yes}

#     .pipe ea (f) ->
#       f._file = new gutil.File f
#       f.base = path.dirname f.base
#       @push f

#     # .pipe gulp.dest "./#{DIST}/"

#     .pipe ea (f) ->
#       @push f
#       firstTime = !cache[f.path]

#       if firstTime
#         if match(f.path, "**/src/**")
#           # making pointing to the right spec
#           dir = path.dirname(f.path).replace(/src$/, 'spec')
#           cache[f.path] = path.join dir, path.basename(f.path)
#           return
#         else
#           cache[f.path] = f.path

#       cmd = "echo"
#       # cmd = "export NODE_PATH=$NODE_PATH:#{process.cwd()}/dist/src"
#       # cmd = "#{cmd};./node_modules/istanbul/lib/cli.js cover --report html ./node_modules/mocha/bin/_mocha -- #{cache[f.path]} -R spec -t 1000"
#       cmd ="#{cmd};./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register #{cache[f.path]} -R spec -t 1000"
#       st = exec cmd

#       cache.stdout ?= []
#       cache.stderr ?= []

#       st.stdout.pipe ea (f) -> cache.stdout.push f; @push f
#       st.stderr.pipe ea (f) -> cache.stderr.push f; @push f

#       st.on "close", (exitCode) ->
#         str = bold "#{rand 4}: #{cache[f.path]}\n"

#         if cache?.stdout? then str = "#{str}#{cache.stdout.join ""}"
#         if cache?.stderr? then str = "#{str}#{cache.stderr.join ""}"

#         puts str
#         cache.stdout = []
#         cache.stderr = []
    
#     .pipe ea (f) ->
#       if match(f.path, "**/src/**")
#         @push f._file

#     .pipe gulp.dest "#{process.cwd()}/node_modules/super-stream"
#     # .pipe ea (f,e,n)->
#     #   @push f; n()

# gulp.task "watch:spec", ->
#   gulp.watch GLOBS.coffee.src, ->
#     console.log arguments

# gulp.task "watch:gulpfiles", ->
#   cache = {}
#   gulp.src GLOBS.gulpfiles.src
#     .pipe watch {emitOnGlob: no}
#     .pipe ea (f) ->
#       if cache[f.path] 
#         log bold red "::: Existing gulp task now :::"
#         process.exit 13

#       cache[f.path] = on
#       @push f

# gulp.task "gulpfiles", 

logFile = (evt) ->
  if evt._startTime
    timedif = prettyHrtime process.hrtime(evt._startTime)
  
  file = "./#{path.relative process.cwd(), evt.path}"
  msg = "file #{magenta file} was #{evt.type || "created in #{magenta timedif}"}"
  log msg
  return file

logStream = each (f) ->
  logFile f
  @push f

watcher = (name, glob, handler) ->
  gulp.task name, ->
    gulp.watch glob, (evt) ->
      logFile evt
      evt._eventStart = process.hrtime()
      task = handler.call @, evt
      task.pipe each (f) ->
        console.log 'pppppp'
#       f._startTime = process.hrtime()
#       st = each()
#       st.pipe pl.coffee
#       st.write f

JNT = pln()




pln JNT, [
    coffee {bare: yes}
    gulp.dest GLOBS.coffee.tmp
    logStream
  ]

pln JNT, [
    each (f) ->
      console.log 'llll'
  ]

watcher "watch:src", GLOBS.coffee.src, (evt) -> 
  gulp.src evt.path
    .pipe JNT


watcher "watch:etc", GLOBS.etc.src, (evt) ->
    if match evt.path, '**/*gulp*.coffee'
      log bold red "::: Existing gulp task now :::"
      process.exit 13
      return

    gulp.src evt.path
      .pipe JNT

gulp.task "watch", ["watch:etc", "watch:src"]

gulp.task "default", ["watch"]
# gulp.task "assets", ["coffee"]

# gulp.task "coffee", ->
#   job = new Transform {objectMode: yes}
#   job._transform = (f, e, n) ->
#     puts f.path
#     @push f
#     do n

#   return gulp.src GLOBS.coffee.src 
#     .pipe watch {emitOnGlob: no}
#     .pipe coffee {bare: yes}
#     .pipe job


# job = 
#   spec: ->
#     each (f) ->
#       f._startTime = process.hrtime()
#       st = each()
#       st.pipe pl.spec
#       st.write f

#   etc: ->
#     each (f) ->
#       f._startTime = process.hrtime()
#       st = each()
#       st.pipe pl.coffee
#       st.write f

#   coffee: -> 
#     each (f, cfg = opts) ->
#       f._startTime = process.hrtime()
#       st = each()
#       st.pipe pl.coffee
#       st.write f

# watcher "watch:spec", GLOBS.coffee.src, (evt) -> 
#   gulp.src evt.path
#     .pipe job.spec()


