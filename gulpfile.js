const resolve = require('resolve');
const path = require('path');

// This class is adapted from:
// https://github.com/danderu/node-sass-custom-importer/blob/aef972efe419176ee5601753239d3c3917bbb434/src/index.js
const FakeNgWebpackImporter = (url, prev, done) => {
    if (!url.startsWith('~')) {
        return null;
    }

    const route = url.split(path.sep);
    let fileImport = route.pop();
    if (!fileImport.endsWith('.css')) {
        // normalize names to '_{file name}.scss'
        // e.g. 'variables' => '_variables.scss'
        fileImport = fileImport.startsWith('_') ? fileImport : '_' + fileImport;
        fileImport = fileImport.endsWith('.scss') ? fileImport : fileImport + '.scss';
    }

    const newUrl = route.concat([fileImport]).join(path.sep);
    done({
        file: resolve.sync(newUrl.slice(1), {
            basedir: __dirname + '/node_modules'
        })
    });
};

////////////////////////////////////////////////////////////////////////////////

const gulp = require('gulp');
const sass = require('gulp-sass');

const sassPaths = './src/**/*.scss',
    sassOutPath = './src/';

const sassIncludePaths = ['src/assets/styles'];
const sassOptions = {
    includePaths: sassIncludePaths,
    importer: FakeNgWebpackImporter
};

gulp.task('compile-sass', function() {
    gulp.src(sassPaths)
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(gulp.dest(sassOutPath));
});
