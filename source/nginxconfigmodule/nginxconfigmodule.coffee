nginxconfigmodule = {name: "nginxconfigmodule"}
############################################################
#region logPrintFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["nginxconfigmodule"]?  then console.log "[nginxconfigmodule]: " + arg
    return
errLog = (arg) -> console.log(c.red(arg))
successLog = (arg) -> console.log(c.green(arg))
#endregion

############################################################
fs = require("fs").promises
c = require("chalk")

############################################################
pathHandler = null

############################################################
nginxconfigmodule.initialize = () ->
    log "nginxconfigmodule.initialize"
    pathHandler = allModules.pathhandlermodule
    return


############################################################
#region generateServerSectionLines
listenLine = (thingy) ->
    log "listenLine"
    result = ""
    if thingy.outsidePort and thingy.plainHTTP
        result += "    listen " + thingy.outsidePort + ";\n"
        result += "    listen [::]:" + thingy.outsidePort + ";\n"
    else if thingy.outsidePort
        result += "    listen " + (thingy.outsidePort - 1) + ";\n"
        result += "    listen [::]:" + (thingy.outsidePort - 1) + ";\n"
    else
        result += "    listen 80;\n"
        result += "    listen [::]:80;\n"
    result += "\n"
    return result

serverNameLine = (thingy) ->
    log "serverNameLine"
    result = ""
    if thingy.dnsNames? && thingy.dnsNames.length > 0
        result += "    server_name"
        result += " " + name for name in thingy.dnsNames
        result += ";\n"
    return result

locationSection = (thingy) ->
    log "locationSection"
    
    if thingy.type == "website"
        return websiteLocationSection(thingy)

    if thingy.type == "service" and thingy.socket
        return socketServiceLocationSection(thingy)
        
    if thingy.type == "service" and thingy.port
        return portServiceLocationSection(thingy)

    if thingy.type == "service" 
        throw new Error("Service has neither port nor socket defined!")

    return ""

#endregion

############################################################
#region locationSections
websiteLocationSection = (thingy) ->
    log "websiteLocationSection"
    if !thingy.homeUser then throw new Error("No homeUser was defined!")

    result = "\n###### Handling of all regular requests - Website\n"

    # ## location for large media files to be introduced later
    # result = "    location ~* / {\n"
    # result += limitExceptSection(thingy.type)
    # result += "\n        expires 30d;\n" ## move into server block
    # result += "\n    }\n\n"
    ## location for rest of the files
    result += "    location / {\n"
    result += limitExceptSection(thingy.type)
    result += "        gzip_static on;\n"
    result += "        try_files $uri $uri.html $uri/ =404;\n"
    result += "    }\n\n"
        
    return result

portServiceLocationSection = (thingy) ->
    log "portServiceLocationSection"
    if !thingy.port then throw new Error("No port was defined!")

    result = "\n###### Handling of all regular requests - PortService\n"
    result += "    location / {\n"
    result += limitExceptSection(thingy.type)
    result += websocketSection(thingy.upgradeWebsocket)
    result += proxyPassPortSection(thingy.port)
    result += "\n    }\n\n"
    return result

socketServiceLocationSection = (thingy) ->
    log "socketServiceLocationSection"
    if !thingy.homeUser then throw new Error("No homeUser was defined!")

    result = "\n###### Handling of all regular requests - SocketService\n"
    result += "    location / {\n"
    result += limitExceptSection(thingy.type)
    result += websocketSection(thingy.upgradeWebsocket)
    result += proxyPassSocketSocket(thingy.homeUser)
    result += "\n    }\n\n"
    return result

############################################################
#region individualSections
htmlForwardSection = (type) ->
    return "" unless type == "website"
    return """

    ###### Removing .html extension
        if ($request_uri ~ ^/(.*)\\.html$) { return 301 /$1; }
    
    """

limitExceptSection = (type) ->
    if type == "website"
        return "        limit_except GET { deny all; }\n"
    if type == "service"
        return "        limit_except POST { deny all; }\n"
    return ""

rootSection = (thingy) ->
    return "" unless thingy.type == "website"
    return """
    
    ###### Our document-root
        root /srv/http/#{thingy.homeUser};
    
    """ 

noIndexSection = (searchIndexing) -> 
    if searchIndexing then return ""
    return """
    
    ###### Tell the Robots: No Indexing!
        add_header  X-Robots-Tag "noindex, nofollow, nosnippet, noarchive";
    
    """ 

CORSSection = (thingy) ->
    return "" unless thingy.type == "service"
    return "" unless thingy.broadCORS
    return """

    ###### Allow all CORS requests
        add_header 'Access-Control-Allow-Origin' "$http_origin" always;
        add_header 'Access-Control-Allow-Credentials' 'true' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header Access-Control-Allow-Headers 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With,X-Token-Auth,X-Mx-ReqToken,X-Requested-With';
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';

        if ($request_method = 'OPTIONS') { rewrite ^ /.options last; }

    ###### handle options requests here
        location /.options {
            limit_except OPTIONS { deny all; }
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    
    """

proxyPassPortSection = (port) ->
    return """

    ########## ProxyPass to service at port
            proxy_pass http://localhost:#{port};
    
    """

proxyPassSocketSocket = (homeUser) ->
    return """

    ########## ProxyPass to service at unix Socket
            proxy_pass http://unix:/run/#{homeUser}.sk;
    
    """

websocketSection = (upgradeWebsocket) ->
    return "" unless upgradeWebsocket
    return """
    
    ########## Upgrade connection for websockets
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_read_timeout 2h;
            proxy_send_timeout 2h;
    
    """

#endregion

#endregion

############################################################
nginxconfigmodule.generateForThingy = (thingy) ->
    log "nginxconfigmodule.generateForThingy"
    # log "\n" + JSON.stringify(thingy, null, 2)
    return if thingy.type != "service" and thingy.type != "website"
    try
        configString = "server {\n"
        configString += listenLine(thingy)
        configString += serverNameLine(thingy)
        configString += rootSection(thingy)
        configString += noIndexSection(thingy.searchIndexing)
        configString += CORSSection(thingy)
        configString += htmlForwardSection(thingy.type)
        configString += locationSection(thingy)
        configString += "}\n"
        configPath = pathHandler.getConfigOutputPath(thingy.homeUser)
        log "write to: " + configPath
        await fs.writeFile(configPath, configString)
        successLog thingy.homeUser  + " - nginx-config generated"
    catch err
        errorMessage = thingy.homeUser + " - could not generate nginx-config"
        errorMessage += "\nReason: " + err 
        errLog errorMessage

module.exports = nginxconfigmodule