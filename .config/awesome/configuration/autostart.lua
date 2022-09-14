local helpers = require("helpers")

------------------------------------------------

helpers.run.run_once("picom -b")
helpers.run.run_once("playerctld daemon")

helpers.run.run_once("spotify")
helpers.run.run_once("evolution")
