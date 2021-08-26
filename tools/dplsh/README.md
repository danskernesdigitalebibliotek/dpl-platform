# DPL Platform Operations Shell #

A small docker-based shell that eases the use of terraform and other ops tools.

`dplsh` clones `${HOME}/.azure` into the shell which makes your local azure CLI state available from the shell. It also source `.dplsh.profile` if the file exists in the directory which allows you to implement project-specific tweaks.

## Prerequisites
* Docker
* [jq](https://stedolan.github.io/jq/download/)
* Bash 4 or newer

## Build and release
The shell is based on a docker image. To produce a build and release it you
simply build the docker image, and push it to the correct registry.

This is done by the `dplsh-build-release.yaml` GitHub Action, but can
also be done manually for testing purposes or in an emergency:

```shell
$ task build IMAGE_TAG=<some tag>
$ task push
```

## Launching the shell
The shell is launched via the `dplsh.sh` shell-script found in the same
directory as this document. It is advicable to place a symlink to this file
 on your path to make launching the shell easier
```shell
ln -s /path/to/checkout/tools/dplsh/dplsh.sh /usr/local/bin/dplsh
```

Should you need to launch the shell without having access to the shell-script
it can be done by streaming it from the image like this:
```shell
# You need to do a one-time pull of the image:
docker run docker.pkg.github.com/danskernesdigitalebibliotek/dpl-platform/dplsh:lates

# Then launch the shell
bash -c "$(docker run docker.pkg.github.com/danskernesdigitalebibliotek/dpl-platform/dplsh:latest bootstrap)"
```

## Shell profiles
The following demonstrates a number of ways to use the profile feature of the
shell. The shell will set its file-system root after the first profile it
findes by traversing up towards the root of the host file-system. It then
sources the file before starting the actual shell.

### Example 1
```shell
$ touch /project/.dplsh.profile.my-profile
$ cd /project/some/subpath
$ dplsh -p my-profile
```
 dplsh will launch a container and do the following inside it
   * mount /project as /home/dplsh/host_mount
   * mount /project/.dplsh.profile.my-profile as  /home/dplsh/.dplsh.profile
   * cd to /home/dplsh/host_mount/some/subpath
   * source /home/dplsh/.dplsh.profile
Notice, CWD while sourcing is the subdirectory the shell was launched for in.

### Example 2
```shell
$ touch /project/.dplsh.profile
$ cd /project/some/random
$ dplsh
```
Same as example 1, but the shell will now default to .dplsh.profile

### Example 3:
```shell
$ touch /project/subdir/.dplsh.profile
$ cd /project/subdir
$ dplsh
```
Same as example 1, but the shell will now mount /project/subdir as /home/dplsh/host_mount thus "jailing" the shell inside the directory it was launched from.

# Troubleshooting

## Unable to connect to docker due to "Permission denied"

dplsh will attempt to mount the `/var/run/docker.sock` into its container in order to make Docker available. On the initial mount the socket will not be writable by the dplsh user, and you may see an error like `Got permission denied while trying to connect to the Docker daemon socket`.

This can be fixed by starting dplsh as root, and changing the permissions of the socket from inside the container. On Docker for Mac, this change will persist until the next reboot of the host, and will only be persisted inside containers.
On Linux, however, this change persists on the host, and means that docker.sock is no longer owned by root.

dplsh can perform the update automatically by being launched with
```shell
dplsh --fix-docker
````
