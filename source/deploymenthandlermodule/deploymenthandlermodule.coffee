deploymenthandlermodule = {name: "deploymenthandlermodule"}

#region node_modules
CLI         = require('clui')
Spinner     = CLI.Spinner
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["deploymenthandlermodule"]?  then console.log "[deploymenthandlermodule]: " + arg
    return

#region internal variables
pathHander = null
keyModule = null
github = null
cfg = null

allDeployments = []
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
deploymenthandlermodule.initialize = () ->
    log "deploymenthandlermodule.initialize"
    pathHander = allModules.pathhandlermodule
    keyModule = allModules.keymodule
    github = allModules.githubhandlermodule
    cfg = allModules.configmodule

#region classes
class deploymentEntry
    constructor: (@repo) ->
        return
    
    establishKeyPairs: ->
        pair = await keyModule.getKeyPairForRepo(@repo)
        @pub = pair.pub
        @priv = pair.priv

    addKey: ->
        log "addKey on " + @repo
        if !@pub or !@priv then await @establishKeyPairs()
        try await github.addDeployKey(@repo, @pub, cfg.name)
        catch err
            log "error on github creating deploy key! " + @repo
            ##TODO figure out when the error was 404
        return

    removeKey: ->
        log "removeKey on " + @repo
        keyModule.removeKeyPairForRepo(@repo)
        try await github.removeDeployKey(@repo, cfg.name)
        catch err 
            log "error on github removing deploy key! " + @repo
            ##TODO figure out when the error was 404
        return

    addWebhook: ->
        log "addWebhook on " + @repo
        try await github.addWebhook(@repo, cfg.webhookURL, cfg.webhookSecret)
        catch err 
            log "error on github creating webhook! " + @repo
            ##TODO figure out when the error was 404
        return

    removeWebhook: ->
        log "removeWebhook on " + @repo
        try await github.removeWebhook(@repo, cfg.webhookURL)
        catch err 
            log "error on github removing webhook! " + @repo
            ##TODO figure out when the error was 404
        return

#endregion

#region internal functions
#endregion

#region exposed functions
deploymenthandlermodule.addDeploymentFor = (repo) ->
    # log "deploymenthandlermodule.addDeploymentFor"
    deployment = new deploymentEntry(repo)
    allDeployments.push(deployment)

deploymenthandlermodule.refreshDeployments = ->
    log "deploymenthandlermodule.refreshDeployments"
    await deploymenthandlermodule.removeDeployments()
    await deploymenthandlermodule.prepareMissingDeployments()

deploymenthandlermodule.prepareMissingDeployments = ->
    log "deploymenthandlermodule.prepareMissingDeployments"
    promises = []
    for deployment in allDeployments
        promises.push deployment.addKey()
        promises.push deployment.addWebhook()
    status = new Spinner('Adding missing webhooks and keys...');
    try 
        status.start()
        await Promise.all(promises)
    finally status.stop()

deploymenthandlermodule.removeDeployments = ->
    log "deploymenthandlermodule.removeDeployments"
    promises = []
    for deployment in allDeployments
        promises.push deployment.removeKey()
        promises.push deployment.removeWebhook()
    status = new Spinner('Removing webhooks and keys...');
    try 
        status.start()
        await Promise.all(promises)
    finally status.stop()
#endregion exposed functions

module.exports = deploymenthandlermodule

