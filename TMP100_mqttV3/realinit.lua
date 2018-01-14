-- file : init.lua

app = require "application"
package.loaded.app = nil
app = require "application"
config = require "config"
package.loaded.config = nil
config = require "config"
setup = require "setup"
package.loaded.setup = nil
setup = require "setup"




setup.start()
