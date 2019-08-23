pathhandlermodule = {name: "pathhandlermodule"}

#region node_modules
c           = require('chalk');
fs          = require("fs-extra")
pathModule  = require("path")
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pathhandlermodule"]?  then console.log "[pathhandlermodule]: " + arg
    return

#region exposed variables
pathhandlermodule.configPath = ""
pathhandlermodule.outputDir = ""
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
pathhandlermodule.initialize = () ->
    log "pathhandlermodule.initialize"
    utl = allModules.utilmodule

#region internal functions
checkDirectoryExists = (path) ->
    try
        stats = await fs.lstat(path)
        return stats.isDirectory()
    catch err
        # console.log(c.red(err.message))
        return false
#endregion

#region exposed functions
pathhandlermodule.setOutputDirectory = (outputDir) ->
    if outputDir
        if pathModule.isAbsolute(outputDir)
            pathhandlermodule.outputDir = outputDir
        else
            pathhandlermodule.outputDir = pathModule.resolve(process.cwd(), outputDir)
    else
        throw "Trying to set undefined or empty directory for the configuration output."

    exists = await checkDirectoryExists(pathhandlermodule.outputDir)
    if !exists
        throw new Error("Provided directory " + outputDir + " does not exist!")

pathhandlermodule.setConfigFilePath = (configPath) ->
    if configPath
        if pathModule.isAbsolute(configPath)
            pathhandlermodule.configPath = configPath
        else
            pathhandlermodule.configPath = pathModule.resolve(process.cwd(), configPath)
    else
        throw "Trying to set undefined or empty config path."

pathhandlermodule.getConfigRequirePath = -> pathhandlermodule.configPath

pathhandlermodule.getConfigOutputPath = (name) ->
    log "pathhandlermodule.getConfigOutputPath"
    return pathModule.resolve(pathhandlermodule.outputDir, name)
#endregion

module.exports = pathhandlermodule