configmodule = {name: "configmodule"}

#region node_modules
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

#region internal variables
#endregion

#region exposed variables
configmodule.ipAddress = "0.0.0.0"
configmodule.name = "defaultName"
configmodule.webhookSecret = "defaultSecret"
configmodule.webhookPort = "3000"
configmodule.webhookURL = ""
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
configmodule.initialize = () ->
    log "configmodule.initialize"

#region internal functions

#endregion

#region exposed functions
configmodule.generateURL = () ->
    log "configmodule.genURL"
    configmodule.webhookURL = "http://" 
    configmodule.webhookURL += configmodule.ipAddress
    configmodule.webhookURL += ":"
    configmodule.webhookURL += configmodule.webhookPort
    configmodule.webhookURL += "/webhook"
    
    
#endregion exposed functions

module.exports = configmodule

