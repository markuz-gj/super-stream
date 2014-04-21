path = require "path"

gulp = require "gulp"
gutil = require "gulp-util"

coffee = require "gulp-coffee"
mocha = require "gulp-mocha"
watch = require "gulp-watch"

{Transform} = require "stream"

SRC = "."
DIST = "dist"

globs =
	coffee:
    src: ["#{SRC}/*.coffee", "!node_modules/**/*"]
    dest: "#{DIST}"
    dist: "#{DIST}/**/*.js"
    ext: ".js"


t00 = new Transform {objectMode: yes}
t00._transform = (f, e, n) ->
  console.log f.contents
  @push f
  do n

gulp.task "coffee", ->
  gulp.src globs.coffee.src 
    .pipe watch()
    .pipe coffee {bare: yes}
    .pipe t00



gulp.task "assets", ["coffee"]

gulp.task "default", ["assets"]





