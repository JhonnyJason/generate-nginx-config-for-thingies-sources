Modules = require "./allmodules.js"

global.allModules = Modules

for name, module of Modules
    module.initialize() 
        
Modules.startupmodule.cliStartup()