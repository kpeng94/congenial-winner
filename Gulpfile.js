'use strict';

var gulp       = require('gulp');
var bower      = require('gulp-bower');
var coffeelint = require('gulp-coffeelint');
var rename     = require('gulp-rename');
var stylus     = require('gulp-stylus');
var uglify     = require('gulp-uglify');

var browserify = require('browserify');
var coffeeify  = require('coffeeify');
var del        = require('del');
var es         = require('event-stream');
var glob       = require('glob');
var buffer     = require('vinyl-buffer');
var vinyl      = require('vinyl-source-stream');

var paths = {
    // Source paths
    assets: [
        './app/assets/**/*.*',
        './app/assets/pack.json',
        './app/controller.html',
        './app/index.html'
    ],
    app: './app',
    css: './app/css/*.styl',
    coffee: ['./app/coffee/bigscreen/bigscreen.coffee',
             './app/coffee/controller/controller.coffee'],
    lint: ['./app/coffee/**/*.coffee',
           './server/*.coffee',
           './util/*.coffee'],
    // Distribution paths
    dist: './dist',
    bower: './dist/js/vendors'
};

gulp.task('lint', function() {
    return gulp.src(paths.lint)
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
        .pipe(coffeelint.reporter('failOnWarning'));
});

gulp.task('clean', function(cb) {
    del(paths.dist, cb);
});

// Development tasks
gulp.task('bower', function() {
    return bower({directory : paths.bower});
});

gulp.task('copy-assets', function() {
    return gulp.src(paths.assets, {base: paths.app})
        .pipe(gulp.dest(paths.dist));
});

gulp.task('compile-css', function() {
    return gulp.src(paths.css)
        .pipe(stylus({
            compress: false
        }))
        .pipe(rename(function (path) {
            path.dirname = 'css';
            path.extname = '.css';
        }))
        .pipe(gulp.dest(paths.dist));
});

gulp.task('compile-js', function(done) {
    var tasks = paths.coffee.map(function(entry) {
        return browserify({ entries: [entry] }).transform(coffeeify)
            .bundle()
            .pipe(vinyl(entry))
            .pipe(rename(function (path) {
                path.dirname = 'js';
                path.extname = '.js';
            }))
            .pipe(gulp.dest(paths.dist));
    });
    return es.merge.apply(null, tasks);
});

// Production tasks
gulp.task('compile-css-release', function() {
    return gulp.src(paths.css)
        .pipe(stylus({
            compress: true
        }))
        .pipe(rename(function (path) {
            path.dirname = 'css';
            path.extname = '.css';
        }))
        .pipe(gulp.dest(paths.dist));
});

gulp.task('compile-js-release', function() {
    var tasks = paths.coffee.map(function(entry) {
        return browserify({ entries: [entry] }).transform(coffeeify)
            .bundle()
            .pipe(vinyl(entry))
            .pipe(uglify())
            .pipe(rename(function (path) {
                path.dirname = 'js';
                path.extname = '.js';
            }))
            .pipe(gulp.dest(paths.dist));
    });
    return es.merge.apply(null, tasks);
});

gulp.task('builddeploy', function() {
    gulp.start('bower', 'copy-assets', 'compile-css-release', 'compile-js-release');
});

gulp.task('default', function() {
    gulp.start('bower', 'copy-assets', 'compile-css', 'compile-js');
});
