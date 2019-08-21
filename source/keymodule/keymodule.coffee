keymodule = {name: "keymodule"}

#region node_modules
fs = require "fs"
crypto = require "crypto"
ssh = require "ssh-keygen"
#endregion

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["keymodule"]?  then console.log "[keymodule]: " + arg
    return

#region internal variables
pathHandler = null
utl = null
rsaOptions = 
    modulusLength: 2048
    publicKeyEncoding:
        type: "spki"
        format:"pem"
    privateKeyEncoding:
        type: "pkcs8"
        format: "pem"
#endregion

#region exposed variables
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
keymodule.initialize = () ->
    log "keymodule.initialize"
    pathHandler = allModules.pathhandlermodule
    utl = allModules.utilmodule
#region internal functions
createKeyPair = (privPath) ->
    log "createKeyPair"
    # crypto.generateKeyPairSync("rsa", rsaOptions)
    # pub = makeGithubCompatibleString(result.publicKey)
    # priv = result.privateKey
    result  = await utl.sshKeygen(privPath)
    # log "\n" + JSON.stringify(result)
    pub = result.publicKey
    priv = result.privateKey
    return {pub, priv}
makeGithubCompatibleString = (pubKey) -> 
    log "makeGithubCompatibleString"
    pubKey = pubKey.replace("\n", "")
    if rsaOptions.publicKeyEncoding.type == "pkcs1"
        pubKey = pubKey.replace("-----END RSA PUBLIC KEY-----", "")
        pubKey = pubKey.replace("-----BEGIN RSA PUBLIC KEY-----", "")
    else if rsaOptions.publicKeyEncoding.type == "spki"
        pubKey = pubKey.replace("-----END PUBLIC KEY-----", "")
        pubKey = pubKey.replace("-----BEGIN PUBLIC KEY-----", "")
    return "ssh-rsa " + pubKey
#endregion

#region exposed functions
keymodule.getKeyPairForRepo = (repo) ->
    log "keymodule.getKeyPairForRepo"
    pubPath = pathHandler.getPubKeyPath(repo)
    privPath = pathHandler.getPrivKeyPath(repo)
    try
        pub  = fs.readFileSync(pubPath, "utf8")
        priv = fs.readFileSync(pubPath, "utf8")
    catch err
        log "error reading keys - createing new one."
        {pub, priv} = await createKeyPair(privPath)
        # log "\n" + pub
        fs.writeFileSync(pubPath, pub)
        fs.writeFileSync(privPath, priv)
    return {pub, priv}

keymodule.removeKeyPairForRepo = (repo) ->
    log "keymodule.removeKeyPairForRepo"
    pubPath = pathHandler.getPubKeyPath(repo)
    privPath = pathHandler.getPrivKeyPath(repo)
    try
        fs.unlinkSync(pubPath)
        fs.unlinkSync(privPath)
    catch err
        log "error removing keys - maybe did not exist anyways."    
    return
#endregion exposed functions

module.exports = keymodule

