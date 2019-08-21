pathhandlermodule = {name: "pathhandlermodule"}

#region node_modules
inquirer    = require("inquirer")
c           = require('chalk');
CLI         = require('clui');
Spinner     = CLI.Spinner;
fs          = require("fs-extra")
pathModule  = require("path")
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pathhandlermodule"]?  then console.log "[pathhandlermodule]: " + arg
    return

#region internal variables
utl = null
#endregion

#region exposed variables
pathhandlermodule.keysDirectory = ""
pathhandlermodule.configPath = ""
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
pathhandlermodule.setKeysDirectory = (keysDir) ->
    if keysDir
        if pathModule.isAbsolute(keysDir)
            pathhandlermodule.keysDirectory = keysDir
        else
            pathhandlermodule.keysDirectory = pathModule.resolve(process.cwd(), keysDir)
    else
        throw "Trying to set undefined or empty directory for the keys."

    exists = await checkDirectoryExists(pathhandlermodule.keysDirectory)
    if !exists
        throw new Error("Provided directory " + keysDir + " does not exist!")

pathhandlermodule.setConfigFilePath = (configPath) ->
    if configPath
        if pathModule.isAbsolute(configPath)
            pathhandlermodule.configPath = configPath
        else
            pathhandlermodule.configPath = pathModule.resolve(process.cwd(), configPath)
    else
        throw "Trying to set undefined or empty directory for the keys."

pathhandlermodule.getConfigRequirePath = -> pathhandlermodule.configPath

pathhandlermodule.getPrivKeyPath = (repo) ->
    return pathModule.resolve(pathhandlermodule.keysDirectory, repo)

pathhandlermodule.getPubKeyPath = (repo) ->
    return pathModule.resolve(pathhandlermodule.keysDirectory, repo + ".pub")

#endregion

module.exports = pathhandlermodule