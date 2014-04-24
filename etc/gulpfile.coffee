path = require "path"
domain = require "domain"
{exec} = require "child_process"
{puts} = require "util"

gulp = require "gulp"
gutil = require "gulp-util"
{log, colors, replaceExtension} = require "gulp-util"
{red, bold} = colors

coffee = require "gulp-coffee"
mocha = require "gulp-mocha"
watch = require "gulp-watch"
through = require("through2").obj
match = require "minimatch"

{Transform} = require "stream"
Duplexer = require "plexer"
istanbul = require "gulp-istanbul"

flatten = require "lodash-node/modern/arrays/flatten"

SRC   = "src"
DIST  = "dist"
SPEC  = "spec"
ETC   = "etc"

GLOBS =
	coffee:
    src: ["#{SRC}/*.coffee", "!node_modules/**/*"]
    dest: "#{DIST}/"
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
    puts "#{str} #{f.path}"
    @push f
    n()

  return st

d = domain.create()
d.on "error", (e) ->
  puts e.stack
  puts "EE:mocha", ~~(Math.random()*(10**4))

gulp.task "watch:spec", ->
  cache = {}
  return gulp.src GLOBS.mocha.src
    .pipe watch()
    .pipe coffee {bare: yes}

    .pipe through (f,e,n) ->
      f._file = new gutil.File f
      f.base = path.dirname f.base
      @push f
      n()

    .pipe gulp.dest "./#{DIST}/"
    .pipe through (f,e,n) ->
      @push f; n()
      firstTime = !cache[f.path]

      if firstTime
        if match(f.path, "**/src/**")
          # making pointing to the right spec
          dir = path.dirname(f.path).replace(/src$/, 'spec')
          cache[f.path] = path.join dir, path.basename(f.path)
          return
        else
          cache[f.path] = f.path

      cmd = "echo"
      # cmd = "export NODE_PATH=$NODE_PATH:#{process.cwd()}/dist/src"
      cmd = "#{cmd};./node_modules/istanbul/lib/cli.js cover --report html ./node_modules/mocha/bin/_mocha -- #{cache[f.path]} -R spec -t 5000"
      # cmd ="#{cmd};./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register #{cache[f.path]} -R spec -t 1000"
      st = exec cmd

      cache.stdout ?= []
      cache.stderr ?= []

      st.stdout.pipe through (f, e, n) -> cache.stdout.push f; @push f; n()

      st.stderr.pipe through (f, e, n) -> cache.stderr.push f; @push f; n()

      st.on "close", (exitCode) ->

        str = bold "#{rand 4}: #{cache[f.path]}\n"

        if cache?.stdout? then str = "#{str}#{cache.stdout.join ""}"
        if cache?.stderr? then str = "#{str}#{cache.stderr.join ""}"

        puts str
        cache.stdout = []
        cache.stderr = []
    
    .pipe through (f,e,n) ->

      if match(f.path, "**/src/**")
        @push f._file
      
      n()

    .pipe gulp.dest "#{process.cwd()}/node_modules/super-stream"
    # .pipe through (f,e,n)->
    #   console.log "AAAAA", f.path
    #   @push f
    #   n()


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

gulp.task "default", ["watch:spec", "watch:gulpfiles"]

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
