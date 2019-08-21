# prepare-machine-thingy-deployment - Small cli to prepare deployments on a server machine. Webhooks and deployment keys for github.

# Why?
The toolset for the machine thingy requires such a tool.

# What?
prepare-machine-thingy-deployment - specificly for a machine config thingy, it consists of a set of thingies which are to be deployed on the certain machine. For the deployment to be ready to go we need to set up the webhooks and deployment keys for each of the those thingies for which the machine thingy is configured for.

# How?
Requirements
------------
* [GitHub account](https://github.com/)
* [openssh installed](https://www.openssh.com/)
* [Node.js installed](https://nodejs.org/)

Installation
------------

Current git version
``` sh
$ npm install git+https://github.com/JhonnyJason/prepare-machine-thingy-deployment-output.git
```
Npm Registry
``` sh
$ npm install prepare-machine-thingy-deployment
```


Usage
-----

Small cli to prepare deployments on a server machine. Webhooks and deployment keys for github.

```
$ prepare-machine-thingy-deployment --help

  Usage
      $ prepare-machine-thingy-deployment <arg1> <arg2> <arg3>
    
  Options
      required:
      arg1, --keys-directory <path/to/keys>, -k <path/to/keys>
          path of directory where old keys are kept and the new ones will be stored
      arg2, --machine-config <machine-config>, -c <machine-config>
          path to file which if the machine-config
    
      optional:
      arg3, --mode <mode>, -m <mode>  
          "prepare" (default) - we keep old keys and add the missing ones - same holds for the webhooks
          "refresh" - we remove all old keys and webhooks and add new ones
          "remove" - well... aaaand it's gone, it's all gone!
  TO NOTE:
      The flags will overwrite the flagless argument.

  Examples
      $ prepare-machine-thingy-deployment keys allRepos refresh
      ...

```

machine-config
-----

To be interpreted correctly the machine-config file must meet following requirements.

It must export an object as follows:
```javascript
module.exports = {
    ipAddress = "7.4.7.6",
    name = "exampleMachineName",
    webhookSecret = "supersecretsecret",
    webhookPort = 4567,
    thingies = [...]
}
```
Furtherly For each thingy to deploy we have an object in the array.
While the detailed specification what you need in your machine-config might vary strongly it is required to contain the repository name of the deployable thingy part. Plus for now - it has to be owned by your user on github.
```javascript
{
    repository: "example-machine-1-output",
    ...
}
```

Result
-----
This will produce an active webhook of type `application/json` to `http://7.4.7.6:4567/webhook` which is triggered on `push` events.

Also it will create new ssh-keys in OpenSSH format [RFC 4253](https://tools.ietf.org/html/rfc4253#section-6.6) (actually uses openssh over the node-keygen package). The key pairs will be stored in the given `keysDirectory` and the public key will be added as `read_only` deploy key. The title of the deploy key is the used `name` property of the machine-config object.

Notice: It is thought to have 1 deployment for one repository on a certain machine. Thus the deploy keys are identifiable by their titles. Donot use a machine name multiple times!

# Further steps
This tool will be furtherly extended, mainly to fit my own needs.
Ideas of what could come next:

- add meaningful diagnosis on errors (404 etc.)
- add support for not-github systems

All sorts of inputs are welcome, thanks!

---

# License

## The Unlicense JhonnyJason style

- Information has no ownership.
- Information only has memory to reside in and relations to be meaningful.
- Information cannot be stolen. Only shared or destroyed.

And you whish it has been shared before it is destroyed.

The one claiming copyright or intellectual property either is really evil or probably has some insecurity issues which makes him blind to the fact that he also just connected information which was free available to him.

The value is not in him who "created" the information the value is what is being done with the information.
So the restriction and friction of the informations' usage is exclusively reducing value overall.

The only preceived "value" gained due to restriction is actually very similar to the concept of blackmail (power gradient, control and dependency).

The real problems to solve are all in the "reward/credit" system and not the information distribution. Too much value is wasted because of not solving the right problem.

I can only contribute in that way - none of the information is "mine" everything I "learned" I actually also copied.
I only connect things to have something I feel is missing and share what I consider useful. So please use it without any second thought and please also share whatever could be useful for others. 

I also could give credits to all my sources - instead I use the freedom and moment of creativity which lives therein to declare my opinion on the situation. 

*Unity through Intelligence.*

We cannot subordinate us to the suboptimal dynamic we are spawned in, just because power is actually driving all things around us.
In the end a distributed network of intelligence where all information is transparently shared in the way that everyone has direct access to what he needs right now is more powerful than any brute power lever.

The same for our programs as for us.

It also is peaceful, helpful, friendly - decent. How it should be, because it's the most optimal solution for us human beings to learn, to connect to develop and evolve - not being excluded, let hanging and destroy.

If we really manage to build an real AI which is far superior to us it will unify with this network of intelligence.
We never have to fear superior intelligence, because it's just the better engine connecting information to be most understandable/usable for the other part of the intelligence network.

The only thing to fear is a disconnected unit without a sufficient network of intelligence on its own, filled with fear, hate or hunger while being very powerful. That unit needs to learn and connect to develop and evolve then.

We can always just give information and hints :-) The unit needs to learn by and connect itself.

Have a nice day! :D