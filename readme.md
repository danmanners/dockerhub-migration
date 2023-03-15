# Migrate Away from Docker Hub

On Tuesday, March 14 2023, Docker Hub notified teams that do not pay that their services would be shut down in 30 days, and artifacts deleted in 60+ days, if they do not switch to paying accounts. Regardless of your feelings on the matter (See [The GitHub thread for an idea](https://github.com/docker/hub-feedback/issues/2314)), here's a quick script that'll help you migrate from Docker Hub to any other container registry using [Skopeo](https://github.com/containers/skopeo).

## Examples and Usage

It's easy enough to use this as is, though you're more than welcome to improve upon it.

1. Argument 1 - New Target Registry
2. Argument 2 - Rewrite the namespace of an image tag
    - Example: `library/ubuntu:22.04` to `newValue/ubuntu:22.04`; necessary for plenty of container registires unless you want to keep the same namespace
    - set to `''` if you want to leave it the same
3. Argument 3+ - Full list of images you want to move
    - Can use brace expansion, as shown in the example below

> My script isn't handling authentication. If you don't want to hit the Docker Rate Limit, or to authenticate to your new container registry, make sure to authenticate.
> ```bash
> # Pass in your Docker Hub password secretly 
> read -s dockerHubPass
> echo "${dockerHubPass}" | \
> skopeo login docker.io \
> --username YourUsername \
> --password-stdin && unset dockerHubPass
> 
> # Pass in your new registry password/token secretly 
> read -s newRegistryPass
> echo "${newRegistryPass}" | \
> skopeo login target.registry.com \
> --username YourUsername \
> --password-stdin && unset newRegistryPass
> 
> # repeat for each new container registry you need to push to.
> ```

Once you've authenticated to whichever registries you need, run the script!

```bash
➜  ~ ./bulkTransfer.sh target.registry.com \
    newValue \
    library/{ubuntu:18.04,ubuntu:20.04,ubuntu:22.04,mongo:6.0.5{,-jammy}}
========================
Source:  docker.io/library/ubuntu:18.04
Dest:  target.registry.com/newValue/ubuntu:18.04
...
========================
Source:  docker.io/library/ubuntu:20.04
Dest:  target.registry.com/newValue/ubuntu:20.04
...
========================
Source:  docker.io/library/ubuntu:22.04
Dest:  target.registry.com/newValue/ubuntu:22.04
...
========================
Source:  docker.io/library/mongo:6.0.5
Dest:  target.registry.com/newValue/mongo:6.0.5
...
========================
Source:  docker.io/library/mongo:6.0.5-jammy
Dest:  target.registry.com/newValue/mongo:6.0.5-jammy
...
```

## Runtime Notes

- If you're copying Official Docker Hub images, prefix it with `library/`. I haven't written logic to handle it.
- If you don't want to rewrite the namespace of the image tag, make sure to set the second argument to `''` or similar. I haven't written the logic to handle an empty second argument past an empty string.

## What else?

Feel free to submit PRs, issues, fork it, whatever you want. I'm personally mad at Docker and simply want to offer people an easy and bulk way to migrate container images off of Docker Hub.
