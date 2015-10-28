var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var browserify = require('browserify');
var rename = require('gulp-rename');
var source = require('vinyl-source-stream');

var paths = {
  scripts: ['./public/js/**/*.coffee', './public/js/**/**/*.hbs'],
  app: ['./public/js/app.coffee'],
  app_bundle_name: 'bundle.min.js',
  app_bundle_dir: './public/dist/js/'
};

gulp.task('scripts', function() {
  browserify({
    entries: paths.app,
    extensions: ['.coffee', '.js', '.hbs']
  })
  .transform('coffeeify')
  .transform('hbsfy')
  // .transform('uglifyify')
  .bundle()
  .pipe(source(paths.app_bundle_name))
  .pipe(gulp.dest(paths.app_bundle_dir))
});

gulp.task('watch', function() {
  gulp.watch(paths.scripts, ['scripts']);
});

gulp.task('default', ['scripts', 'watch']);
