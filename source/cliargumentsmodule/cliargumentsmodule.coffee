cliargumentsmodule = {name: "cliargumentsmodule"}

#region node_modules
meow       = require('meow')
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["cliargumentsmodule"]?  then console.log "[cliargumentsmodule]: " + arg
    return

#region internal variables

#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
cliargumentsmodule.initialize = () ->
    log "cliargumentsmodule.initialize"

#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ generate-nginx-config-for-thingies <arg1> <arg2>
    
        Options
            required:
            arg1, --machine-config <machine-config>, -c <machine-config>
                path to file which if the machine-config
            arg2, --output-directory <path/to/dir>, -o <path/to/dir>
                path of directory where the generated config files should be stored
            
        TO NOTE:
            The flags will overwrite the flagless argument.

        Examples
            $ generate-nginx-config-for-thingies  machine-config.js ../sites-enabled
            ...
    """
getOptions = ->
    log "getOptions"
    return {
        flags:
            machineConfig:
                type: "string"
                alias: "c"
            outputDirectory:
                type: "string"
                alias: "o"
    }

extractMeowed = (meowed) ->
    log "extractMeowed"
    machineConfig = ""
    outputDirectory = ""

    if meowed.input[0]
        machineConfig = meowed.input[0]
    if meowed.input[1]
        outputDirectory = meowed.input[1]

    if meowed.flags.machineConfig
        machineConfig = meowed.flags.machineConfig
    if meowed.flags.outputDirectory
        outputDirectory = meowed.flags.outputDirectory

    return {machineConfig, outputDirectory}

throwErrorOnUsageFail = (extract) ->
    log "throwErrorOnUsageFail"
    if !extract.machineConfig
        throw "Usage error: obligatory option machineConfig was not provided!"
    if !extract.outputDirectory
        throw "Usage error: obligatory option keysDirectory was not provided!"
    
    if !(typeof extract.machineConfig == "string")
        throw "Usage error: option machineConfig was provided in an unexpected way!"
    if !(typeof extract.outputDirectory == "string")
        throw "Usage error: option keysDirectory was provided in an unexpected way!"
    
#endregion

#region exposed functions
cliargumentsmodule.extractArguments = ->
    log "cliargumentsmodule.extractArguments"
    options = getOptions()
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    throwErrorOnUsageFail(extract)
    return extract

#endregion exposed functions

module.exports = cliargumentsmodule

