path = require "path"
domain = require "domain"

gulp = require "gulp"
{log, colors, replaceExtension} = require "gulp-util"
{red, bold} = colors
coffee = require "gulp-coffee"
mocha = require "gulp-mocha"
watch = require "gulp-watch"
through = require("through2").obj
shell = require "gulp-shell"
match = require "minimatch"
# es = require "event-stream"
# grep = require "gulp-grep-stream"
# filter = require "gulp-filter"

{Transform} = require "stream"
Duplexer = require "plexer"
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

s = shell 'node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register spec/*.coffee' 

c = shell './node_modules/istanbul/lib/cli.js cover --report html ./node_modules/mocha/bin/_mocha -- --compilers coffee:coffee-script/register spec/*.coffee -R nyan -t 5000'

# c.write('PP')
# s.write("PPP").pipe through (f) ->
#   console.log f

rand = (n = 6) -> ~~(Math.random()*(10**n))

ps = (str="-- #{rand 3} --") ->
  st = new Transform {objectMode: on}
  st._transform = (f,e,n) ->
    console.log "#{str} #{f.path}"
    @push f
    n()

  return st

d = domain.create()
d.on "error", (e) ->
  console.log e.stack
  console.log "EE:mocha", ~~(Math.random()*(10**4))

watchStream = ->
  return watch {emit: 'all'}, (files) -> 

    mochaStream = mocha {reporters:'Nyan'}
    for i, fn of mochaStream
      if fn instanceof Function
        mochaStream[i] = d.bind fn

    # mochaStream.pipe ps("@@")

    return files
      # .pipe ps('-----')
      # .pipe istanbul()
      # .pipe filter("!src/*")
      # .pipe mochaStream
      .pipe through (f,e,n) ->
        f.base = path.dirname f.base
        @push f
        n()
      .pipe coffee {bare: on}
      .pipe gulp.dest "./#{DIST}/"
      .pipe through (f,e,n) ->
        if match(f.path, "**/spec/**")
          cmd ="./node_modules/istanbul/lib/cli.js cover --report html ./node_modules/mocha/bin/_mocha -- #{f.path} -R nyan -t 5000"
          st = shell cmd
          self = @
          st.on "error", (e) ->
            console.log e.stack
            # self.push f
            # n()
          st.write('A')
        @push f
        n()        
      # .pipe ps("01:#{rand()}")

      # .pipe istanbul.writeReports()

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


  # returning task
  return gulp.src GLOBS.mocha.src
    .pipe watchStream()
    # .pipe ps("00:#{rand(3)}")

    # .pipe through (f,e,n) ->
    #   shell = require "gulp-shell"
    #   cmd = "node_modules/mocha/bin/mocha dist/*.js -R nyan"
    #   # cmd = "node_modules/mocha/bin/mocha "
    #   console.log cmd
    #   st = shell cmd
    #   st.write("pp")
    #   # st = shell "node_modules/mocha/bin/mocha -R nyan #{f.path}"
    #   # st.write()
    #   # c.write('pp')
    #   @push f 
    #   n()

    # .pipe istanbul()

    # .pipe through (f,e,n) ->
    #   f.path = replaceExtension f.path, ".coffee"
    #   @push f
    #   n()
    # # .pipe mocha()
    # .pipe instanbul
    # .pipe through (f,e,n) ->
    #   # console.log f.contents.toString()


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
