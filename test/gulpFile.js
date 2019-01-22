/**
 * Test:
 * Build all necessary sources and execute the test file.
 */
gulp.task('test', gulp.series('build', () => {
  const protractor = require('gulp-protractor').protractor;
  return gulp.src('./dist/test/**/**.spec.js').pipe(protractor({ configFile: './dist/test/conf.js' }));
}));