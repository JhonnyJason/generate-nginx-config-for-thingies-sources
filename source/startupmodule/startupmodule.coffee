startupmodule = {name: "startupmodule"}

#region node_modules
c = require "chalk"
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return

#region internal variables
errLog = (arg) -> console.log(c.red(arg))
successLog = (arg) -> console.log(c.green(arg))
genconfigProcess = null
cliArguments = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    genconfigProcess = allModules.genconfigprocessmodule
    cliArguments = allModules.cliargumentsmodule

#region internal functions

#endregion

#region exposed functions
startupmodule.cliStartup = ->
    log "startupmodule.cliStartup"
    try
        e = cliArguments.extractArguments()
        # console.log(chalk.yellow("caught arguments are: " + args._))
        done = await genconfigProcess.execute(e.machineConfig, e.outputDirectory)
        if done then successLog 'All done!'
    catch err
        errLog "Error!"
        console.log(err)
        console.log("\n")

#endregion exposed functions

module.exports = startupmodule

