genconfigprocessmodule = {name: "genconfigprocessmodule"}

#region node_modules
fs = require "fs"
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["genconfigprocessmodule"]?  then console.log "[genconfigprocessmodule]: " + arg
    return

#region internal variables
pathHandler = null
nginxConf = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
genconfigprocessmodule.initialize = () ->
    log "genconfigprocessmodule.initialize"
    pathHandler = allModules.pathhandlermodule
    nginxConf = allModules.nginxconfigmodule


#region internal functions
processAllThingies = () ->
    log "processAllThingies"
    requirePath = pathHandler.getConfigRequirePath() 
    config = require(requirePath)
    
    promises = (nginxConf.generateForThingy(thingy) for thingy in config.thingies)
    await Promise.all(promises)    

#endregion

#region exposed functions
genconfigprocessmodule.execute = (configPath, outputDirectory) ->
    log "genconfigprocessmodule.execute"
    await pathHandler.setConfigFilePath(configPath)
    await pathHandler.setOutputDirectory(outputDirectory)
    await processAllThingies()
    return true
#endregion

module.exports = genconfigprocessmodule
