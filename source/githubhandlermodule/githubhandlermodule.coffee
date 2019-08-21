githubhandlermodule = {name: "githubhandlermodule"}

githubAPI = require("github-api")
inquirer = require("inquirer")
c = require "chalk"
CLI         = require('clui')
Spinner     = CLI.Spinner

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["githubhandlermodule"]?  then console.log "[githubhandlermodule]: " + arg
    return

#region internal variables
api = null

authQuestions = [ 
    {
        name: "username"
        type: "input"
        message: "Github username:"
        validate: (value) ->
            if value.length then return true;
            else return 'Please!'   
    },
    {
        name: "password"
        type: "password"
        message: "Github password:"
        validate: (value) ->
            if value.length then return true;
            else return 'Please!'   
    }    
]

#endregion

#region exposed variables
githubhandlermodule.user = ""
githubhandlermodule.password = ""
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
githubhandlermodule.initialize = () ->
    log "githubhandlermodule.initialize"
    
#region internal functions
connectAPI = ->
    authenticated = false
    
    while !authenticated
        answers = await inquirer.prompt(authQuestions)
        status = new Spinner('Checking credentials...');
        
        options =
            username: answers.username
            password: answers.password

        try
            status.start();
            api = new githubAPI(options)
            user = api.getUser()
            profile = await user.getProfile()
            # console.log "\n" + JSON.stringify profile.data
            console.log(c.green("Credentials Check succeeded!"))
            githubhandlermodule.user = answers.username
            githubhandlermodule.password = answers.password
            authenticated = true
        catch err
            console.log(c.red("Credentials Check failed!"))
        finally
            status.stop()
#endregion

#region exposed fun
githubhandlermodule.buildConnection = ->
    if api == null
        await connectAPI()

githubhandlermodule.addWebhook = (repo, url, secret) ->
    log "githubhandlermodule.addWebhook"
    repoHandle = api.getRepo(githubhandlermodule.user, repo)
    
    config =
        url: url
        content_type: "json"
        secret: secret
    
    webhookDescription =
        name: "web"      
        active: true
        events: ["push"]
        config: config  
    
    await repoHandle.createHook(webhookDescription)
    
githubhandlermodule.removeWebhook = (repo, url) ->
    log "githubhandlermodule.getWebhook"
    repoHandle = api.getRepo(githubhandlermodule.user, repo)
    
    result = await repoHandle.listHooks()
    allHooks = result.data
    idsToDelete = []
    idsToDelete.push(hook.id) for hook in allHooks when hook.config.url is url

    promises = (repoHandle.deleteHook(id) for id in idsToDelete)
    await Promise.all(promises) 
    return

githubhandlermodule.addDeployKey = (repo, key, title) ->
    log "githubhandlermodule.addDeployKey"
    repoHandle = api.getRepo(githubhandlermodule.user, repo)
    
    keyDescription = 
        title: title
        key: key
        read_only: true

    await repoHandle.createKey(keyDescription)
    
githubhandlermodule.removeDeployKey = (repo, title) ->
    log "githubhandlermodule.removeDeployKey"
    repoHandle = api.getRepo(githubhandlermodule.user, repo)

    result = await repoHandle.listKeys()
    allKeys = result.data
    idsToDelete = []
    idsToDelete.push(key.id) for key in allKeys when key.title is title
    
    promises = (repoHandle.deleteKey(id) for id in idsToDelete)
    await Promise.all(promises) 
    return

    


#endregion

module.exports = githubhandlermodule