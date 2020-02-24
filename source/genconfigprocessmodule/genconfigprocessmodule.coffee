genconfigprocessmodule = {name: "genconfigprocessmodule"}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["genconfigprocessmodule"]?  then console.log "[genconfigprocessmodule]: " + arg
    return

############################################################
fs = require "fs"

############################################################
pathHandler = null
nginxConf = null

############################################################
genconfigprocessmodule.initialize = () ->
    log "genconfigprocessmodule.initialize"
    pathHandler = allModules.pathhandlermodule
    nginxConf = allModules.nginxconfigmodule


############################################################
processAllThingies = () ->
    log "processAllThingies"
    requirePath = pathHandler.getConfigRequirePath() 
    config = require(requirePath)
    
    promises = (nginxConf.generateForThingy(thingy) for thingy in config.thingies)
    await Promise.all(promises)    

############################################################
genconfigprocessmodule.execute = (configPath, outputDirectory) ->
    log "genconfigprocessmodule.execute"
    await pathHandler.setConfigFilePath(configPath)
    await pathHandler.setOutputDirectory(outputDirectory)
    await processAllThingies()
    return true

module.exports = genconfigprocessmodule
