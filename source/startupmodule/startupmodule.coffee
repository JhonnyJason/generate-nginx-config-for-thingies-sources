startupmodule = {name: "startupmodule"}

#region node_modules
c = require "chalk"
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["startupmodule"]?  then console.log "[startupmodule]: " + arg
    return

#region internal variables
prepareProcess = null
cliArguments = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
startupmodule.initialize = () ->
    log "startupmodule.initialize"
    prepareProcess = allModules.prepareprocessmodule
    cliArguments = allModules.cliargumentsmodule

#region internal functions

#endregion

#region exposed functions
startupmodule.cliStartup = ->
    log "startupmodule.cliStartup"
    try
        e = cliArguments.extractArguments()
        # console.log(chalk.yellow("caught arguments are: " + args._))
        done = await prepareProcess.execute(e.keysDirectory, e.machineConfig, e.mode)
        if done then console.log(c.green('All done!\n'));
    catch err
        console.log(c.red('Error!'));
        console.log(err)
        console.log("\n")

#endregion exposed functions

module.exports = startupmodule

