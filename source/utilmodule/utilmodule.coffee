utilmodule = {name: "utilmodule"}

#region noode_modules
execFile  = require('child_process').execFile
exec = require("child_process").exec
keygen = require("ssh-keygen")
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["utilmodule"]?  then console.log "[utilmodule]: " + arg
    return

#region internal variables
#endregion

#region exposed variables
#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
utilmodule.initialize = () ->
    log "utilmodule.initialize"

#region internal functions
#endregion

#region exposed functions
utilmodule.isFullURL = (url) ->
    if url.length < 20 then return false
    checker = url.substr(0,8)
    
    if checker == "https://" then return true
    if checker == "git@gith" then return true
    return false

utilmodule.capitaliseFirstLetter = (string)  ->
    return string.charAt(0).toUpperCase() + string.slice(1)

utilmodule.execScriptPromise = (script, options) ->    
    return new Promise (resolve, reject) ->
        callback = (error, stdout, stderr) ->
            if error then reject(error)
            if stderr then reject(new Error(stderr))
            resolve(stdout)
        execFile(script, options, callback)

utilmodule.execGitCheckPromise = (path) ->
    options = 
        cwd: path
    
    return new Promise (resolve, reject) ->
        callback = (error, stdout, stderr) ->
            if error then reject(error)
            if stderr then reject(new Error(stderr))
            resolve(stdout)
        exec("git rev-parse --is-inside-work-tree", options, callback)

utilmodule.sshKeygen = (location) ->
    options = 
        location: location

    return new Promise (resolve, reject) ->
        callback = (error, out) ->
            if error then reject(error)
            result = 
                privateKey: out.key
                publicKey: out.pubKey
            resolve(result)
        keygen(options, callback)
#endregion

module.exports = utilmodule
