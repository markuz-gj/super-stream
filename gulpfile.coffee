###*
 * @author Marcos GJ
 * @license MIT
 * @desc gulpfile for through
 ###

gulp = require "gulp"
{colors, log, replaceExtension} = require "gulp-util"
{bold, red} = colors

{mocha, istanbul, exit, server, jsdoc, coffee} = require "./etc"

SRC = "./index.coffee"
SPEC = "./spec.coffee"
FIXTURE = "./fixture.coffee"
ETC = "./etc.coffee"

gulp.task "compile:coffee", coffee [SRC, SPEC, FIXTURE]
gulp.task "compile:doc", ["compile:coffee"], jsdoc SRC

gulp.task "test:mocha", mocha SPEC
gulp.task "test:istanbul", ["compile:coffee"], istanbul SPEC

gulp.task "server", ["test:mocha", "test:istanbul", "compile:doc"], server SPEC

compile = -> gulp.start "compile:doc"
test = -> gulp.start "test:mocha", "test:istanbul" 

gulp.task "test", test
gulp.task "compile", compile

gulp.task "watch", ["compile", "server"], ->
  gulp.watch ["./gulpfile.coffee", ETC], exit
  gulp.watch [SRC, SPEC, FIXTURE], (evt) -> compile(); test()

gulp.task "default", ["compile", "test"]
