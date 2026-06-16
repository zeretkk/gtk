var gulp = require('gulp');
var childProcess = require('child_process');

function compileSass(sources) {
    sources.forEach(function(source) {
        var target = source.replace(/\.scss$/, '.css');
        childProcess.execFileSync('sassc', [source, target], { stdio: 'inherit' });
    });
}

gulp.task('styles', function(done) {
    compileSass([
        'gtk-3.20/gtk.scss',
        'gtk-3.20/gtk-dark.scss'
    ]);
    done();
});

gulp.task('styles-gtk4', function(done) {
    compileSass([
        'gtk-4.0/gtk.scss',
        'gtk-4.0/gtk-dark.scss'
    ]);
    done();
});

gulp.task('gtk', gulp.series('styles', 'styles-gtk4'));

gulp.task('shell-style', function(done) {
    compileSass([
        'gnome-shell/gnome-shell.scss',
        'gnome-shell/legacy/gnome-shell.scss'
    ]);
    done();
});

gulp.task('cinnamon-style', function(done) {
    compileSass([
        'cinnamon/cinnamon.scss',
        'cinnamon/cinnamon-dark.scss'
    ]);
    done();
});

//Watch task
gulp.task('default',function() {
    gulp.watch(['gtk-3.20/**/*.scss', 'gtk-4.0/**/*.scss'], gulp.series('gtk'));
});

gulp.task('shell',function() {
    gulp.watch('gnome-shell/**/*.scss', gulp.series('shell-style'));
});

gulp.task('cinnamon',function() {
    gulp.watch('cinnamon/**/*.scss', gulp.series('cinnamon-style'));
});
