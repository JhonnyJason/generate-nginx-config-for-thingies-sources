nginxconfigmodule = {name: "nginxconfigmodule"}

#region node_modules
fs = require("fs").promises
c = require("chalk")
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["nginxconfigmodule"]?  then console.log "[nginxconfigmodule]: " + arg
    return


#region internal variables
errLog = (arg) -> console.log(c.red(arg))
successLog = (arg) -> console.log(c.green(arg))
pathHandler = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
nginxconfigmodule.initialize = () ->
    log "nginxconfigmodule.initialize"
    pathHandler = allModules.pathhandlermodule

#region internal functions
generateListenLine = (thingy) ->
    log "generateListenLine"
    result = ""
    if thingy.outsidePort
        result += "    listen " + thingy.outsidePort + ";\n"
    else
        result += "    listen 80;\n"
        result += "    listen [::]:80;\n"
    result += "\n"
    return result

generateServerNameLine = (thingy) ->
    log "generateServerNameLine"
    result = ""
    if thingy.dnsNames? && thingy.dnsNames.length > 0
        result += "    server_name"
        result += " " + name for name in thingy.dnsNames
        result += ";\n\n"
    return result

generateLocationLine = (thingy) ->
    log "generateLocationLine"
    result = ""
    if thingy.type == "website"
        result += generateWebsiteLocationLine(thingy)
    else if thingy.type == "service"
        if thingy.socket
            result += generateSocketServiceLocationLine(thingy)
        else if thingy.port
            result += generatePortServiceLocationLine(thingy)
        else throw new Error("Service has neither port nor socket defined!")
    return result

generateWebsiteLocationLine = (thingy) ->
    log "generateWebsiteLocationLine"
    if !thingy.homeUser then throw new Error("No homeUser was defined!")
    result = ""
    result += "    location / {\n"
    result += "        root /srv/http/" + thingy.homeUser + ";\n"
    result += "        index index.html;\n"
    result += "    }\n\n"
    return result

generatePortServiceLocationLine = (thingy) ->
    log "generatePortServiceLocationLine"
    if !thingy.port then throw new Error("No port was defined!")
    result = ""
    result += "    location / {\n"
    result += "        proxy_pass http://localhost:" + thingy.port + ";\n"
    result += "    }\n\n"
    return result

generateSocketServiceLocationLine = (thingy) ->
    log "generateSocketServiceLocationLine"
    if !thingy.homeUser then throw new Error("No homeUser was defined!")
    result = ""
    result += "    location / {\n"
    result += "        proxy_pass http://unix:/run/" + thingy.homeUser + ".sk;\n"
    result += "    }\n\n"
    return result
#endregion

#region exposed functions
nginxconfigmodule.generateForThingy = (thingy) ->
    log "nginxconfigmodule.generateForThingy"
    # log "\n" + JSON.stringify(thingy, null, 2)
    return if thingy.type != "service" and thingy.type != "website"
    try
        configString = "server {\n"
        configString += generateListenLine(thingy)
        configString += generateServerNameLine(thingy)
        configString += generateLocationLine(thingy)
        configString += "}\n"
        configPath = pathHandler.getConfigOutputPath(thingy.homeUser)
        log "write to: " + configPath
        await fs.writeFile(configPath, configString)
        successLog thingy.homeUser  + " - nginx-config generated"
    catch err
        errorMessage = thingy.homeUser + " - could not generate nginx-config"
        errorMessage += "\nReason: " + err 
        errLog errorMessage
#endregion

module.exports = nginxconfigmodule