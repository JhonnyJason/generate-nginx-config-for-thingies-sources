prepareprocessmodule = {name: "prepareprocessmodule"}

#region node_modules
fs = require "fs"
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["prepareprocessmodule"]?  then console.log "[prepareprocessmodule]: " + arg
    return

#region internal variables
cfg = null
github = null
deploymentHandler = null
pathHandler = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
prepareprocessmodule.initialize = () ->
    log "prepareprocessmodule.initialize"
    cfg = allModules.configmodule
    github = allModules.githubhandlermodule
    deploymentHandler = allModules.deploymenthandlermodule
    pathHandler = allModules.pathhandlermodule

#region internal functions
digestConfigFile = () ->
    log "digestRepoListFile"
    requirePath = pathHandler.getConfigRequirePath() 
    config = require(requirePath)

    cfg.ipAddress = config.ipAddress
    cfg.name = config.name
    cfg.webhookSecret = config.webhookSecret
    cfg.webhookPort = config.webhookPort
    cfg.generateURL()
    
    for thingy in config.thingies
        deploymentHandler.addDeploymentFor(thingy.repository)

#endregion

#region exposed functions
prepareprocessmodule.execute = (keysDirectory, configPath, mode) ->
    log "prepareprocessmodule.execute"
    await pathHandler.setKeysDirectory(keysDirectory)
    await pathHandler.setConfigFilePath(configPath)
    await digestConfigFile()
    await github.buildConnection()

    switch mode
        when "prepare" then await deploymentHandler.prepareMissingDeployments()
        when "refresh" then await deploymentHandler.refreshDeployments()
        when "remove" then await deploymentHandler.removeDeployments()
    
    #    
    # thingy.digestConfig(cfg.public.thingies)
    # useArguments(arg1, arg2)
    # await pathHandler.tryUse(path)
    # await github.buildConnection()
    # await thingy.doUserInquiry()
    # thingy.createRepositoryTree()
    # await repositoryTree.initializeRepositories()
    # await thingy.prepare()
    return true
#endregion

module.exports = prepareprocessmodule
