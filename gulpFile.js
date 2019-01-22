const gulp = require('gulp4');

/**
 * Clean:
 * Delete the "dist" directory for a clean build.
 */
gulp.task('clean', () => require('del')(['./dist/']));

/**
 * Copy:
 * Copy the ABL compiled files to the "dist" directory.
 */
gulp.task('copy', () =>
  gulp
    .src(['package*.json', './src/**/*.r', './src/**/*.exe'])
    .pipe(gulp.dest('./dist')));

/**
 * Compile:
 * Compile TypeScript sources and move compiled files in the "dist" directory.
 */
gulp.task('compile', gulp.series('clean', () => {
  const ts = require('gulp-typescript');
  const tsProject = ts.createProject('./tsconfig.json');

  return tsProject
    .src()
    .pipe(tsProject())
    .pipe(gulp.dest('./dist'));
}));

/**
 * Build:
 * Compile TypeScript sources and copy the resource files. Both compiled and
 * resource files are copied to "dist" directory.
 */
gulp.task('build', gulp.series('compile', 'copy', () => {
  const uglify = require('gulp-uglify-es').default;
  return gulp.src('./dist/**/**.js')
    .pipe(uglify())
    .pipe(gulp.dest((file) => file.base));
}));
