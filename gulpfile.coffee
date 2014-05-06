###*
 * @author Marcos GJ
 * @license MIT
 * @desc gulpfile for through
 ###

coffee = require "gulp-coffee"
gulp = require "gulp"
{colors, log} = require "gulp-util"
{bold, red} = colors

through = require './through'
{mocha, istanbul, reboot} = require "./etc"

SRC = "./through.coffee"
SPEC = "./spec.coffee"

gulp.task "compile:coffee", -> 
  gulp.src [SRC, SPEC]
    .pipe coffee {bare: yes}
    .pipe gulp.dest('.')

gulp.task "compile:doc", -> log 'compiling docs'

gulp.task "test:mocha", mocha SPEC
gulp.task "test:istanbul", ["compile:coffee"], istanbul SPEC

compile = -> gulp.start "compile:coffee", "compile:doc"
test = -> gulp.start "test:mocha", "test:istanbul" 

gulp.task "test", test
gulp.task "compile", compile

gulp.task "watch", ["compile", "test"], ->
  gulp.watch [__filename, "./etc.coffee"], reboot
  gulp.watch [SRC, SPEC], (evt) -> compile(); test()

gulp.task "default", ["compile", "test"]
