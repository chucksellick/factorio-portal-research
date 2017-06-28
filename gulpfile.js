var process = require("process");
var fs = require("fs");
var path = require("path");

var gulp = require('gulp');

var infoPath = "./src/info.json";
var srcPaths = ["src/**/*.lua", "src/**/*.png", "src/**/*.cfg", "src/**/*.md"];

var homePath = process.env[(process.platform === 'win32') ? 'USERPROFILE' : 'HOME'];
var appPath = (process.platform === 'win32') ? "AppData\\Roaming\\Factorio" : "Library/Application Support/factorio";

var factorioPath = path.join(homePath, appPath);

if (!fs.existsSync(factorioPath)) {
  throw new Error("Factorio not found at: " + factorioPath + "\nPlease configure correct Factorio base path in config.js");
}

var modPath = path.join(factorioPath, "mods");
var buildPath = null;

gulp.task('devPath', function() {
  var infoJson = JSON.parse(fs.readFileSync(infoPath));
  buildPath = path.join(modPath, infoJson.name + "_" + infoJson.version);
  // TODO: Remove old folder if path changed
  return gulp.src(infoPath)
    .pipe(gulp.dest(buildPath));
});

gulp.task('devBuild', function() {
  return gulp.src(srcPaths)
    .pipe(gulp.dest(buildPath));
});

gulp.task("devWatch", function() {
  gulp.watch(infoPath, ["devPath"]);
  gulp.watch(srcPaths, ["devBuild"]);
});

gulp.task('default', ["devPath", "devBuild", "devWatch"]);
