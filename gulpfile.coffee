'use strict'

gulp = require 'gulp'
source = require 'vinyl-source-stream'
sass = require 'gulp-sass'
pleeease = require 'gulp-pleeease'
browserify = require 'browserify'
babelify = require 'babelify'
debowerify = require 'debowerify'
jade = require 'gulp-jade'
rename = require 'gulp-rename'
browserSync = require 'browser-sync'

SRC = './src'
DEST = './public'

# html
gulp.task 'jade', () ->
  locals = require("#{SRC}/config/meta.json");

  return gulp.src(["#{SRC}/jade/**/*.jade", "!#{SRC}/jade/layout/*.jade", "!#{SRC}/jade/include/*.jade", "!#{SRC}/jade/mixin/*.jade"])
    .pipe jade
      locals: locals,
      basedir: "#{SRC}/jade",
      pretty: true,
    .pipe gulp.dest "#{DEST}"

gulp.task 'html', gulp.series('jade')

gulp.task 'sass', () ->
  gulp.src "#{SRC}/scss/style.scss"
    .pipe do sass
    .pipe pleeease {
      autoprefixer: {
        browsers: [
          "ie >= 10",
          "ie_mob >= 10",
          "ff >= 30",
          "chrome >= 34",
          "safari >= 7",
          "opera >= 23",
          "ios >= 7",
          "android >= 4.4",
          "bb >= 10"
        ]
      },
      "minifier": false
    }
    .pipe gulp.dest "#{DEST}/css"

gulp.task 'css', gulp.series('sass')

gulp.task 'browserify', () ->
  return browserify("#{SRC}/js/main.js")
    .transform(babelify)
    .transform(debowerify)
    .bundle()
    .pipe(source('main.js'))
    .pipe(gulp.dest("#{DEST}/js"))

gulp.task 'js', gulp.parallel('browserify')
# gulp.task 'js', gulp.series('browserify', gulp.parallel('minify', 'deco'))

gulp.task 'browser-sync' , () ->
  browserSync
    server: {
      baseDir: DEST
    }

  gulp.watch(["#{SRC}/scss/**/*.scss"], gulp.series('sass', browserSync.reload));
  gulp.watch(["#{SRC}/js/**/*.js"], gulp.series('browserify', browserSync.reload));
  gulp.watch(["#{SRC}/jade/**/*.jade"], gulp.series('jade', browserSync.reload));

gulp.task('serve', gulp.series('browser-sync'));

gulp.task('build', gulp.parallel('css', 'js', 'html'));
gulp.task 'default', gulp.series('build', 'serve');
