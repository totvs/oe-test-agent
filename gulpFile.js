const gulp = require('gulp4');

/**
 * clean:
 * Delete the "dist" directory for a clean build.
 */
gulp.task('clean', () => require('del')(['./dist/', './test/**/*.js']));

/**
 * copy:
 * Copy the ABL and Robot compiled files to the "dist" directory.
 */
gulp.task('copy', () =>
  gulp
    .src(['package*.json', 'README.md', './src/**/*.r', './src/**/*.exe'])
    .pipe(gulp.dest('./dist')));

/**
 * compile:
 * Compile TypeScript sources and move the compiled files to the "dist"
 * directory.
 */
gulp.task('compile', gulp.series('clean', () => {
  const ts = require('gulp-typescript');
  const tsProject = ts.createProject('./tsconfig.json');

  return gulp.src(['./src/**/*.ts'])
    .pipe(tsProject())
    .pipe(gulp.dest('./dist'));
}));

/**
 * build:
 * Compile TypeScript sources and copy all resources files. Both compiled and
 * resource files are copied to "dist" directory.
 */
gulp.task('build', gulp.series('compile', 'copy', () => {
  const uglify = require('gulp-uglify-es').default;
  return gulp.src('./dist/**/*.js')
    .pipe(uglify())
    .pipe(gulp.dest((file) => file.base));
}));

/**
 * compile-test:
 * Compile TypeScript test sources.
 */
gulp.task('compile-test', () => {
  const ts = require('gulp-typescript');
  const tsProject = ts.createProject('./tsconfig.json');

  return gulp.src(['./test/**/*.ts'])
    .pipe(tsProject())
    .pipe(gulp.dest('./test'));
});

/**
 * test:
 * Build all necessary test sources and execute the test file.
 */
gulp.task('test', gulp.series('build', 'compile-test', () => {
  const protractor = require('gulp-protractor').protractor;
  return gulp.src('./test/*.spec.js').pipe(protractor({ configFile: './test/conf.js' }));
}));
