const gulp = require('gulp');
const genModes = require("./gen_modes");
const genStyles = require("./gen_styles");
const alk = require('./alakon');

gulp.task('generate', async function() {
  genModes.exec();
//  genStyles.exec();
});