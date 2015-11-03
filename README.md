# docker-machine-sshfs

This script can be used to create or update a docker-machine changing the mount point /Users from **vboxsf** to **sshfs.fuse**. 
The performance are near to local machine development.

## Pre-Requires
- docker-toolbox or docker-machine already installed
- docker-machine version > **0.4.1**

## Issues and Workaround
Sometimes can append that with many virtualmachines Virtualbox lost arp  with hostonly network adapter.
This can generate some issues with sshfs connection.
You can fix it with this workaround
In your shell create a new vbox adapter
```
$ vboxmanage hostonlyif create
```
Go to virtualbox , select your machine , go to settings , network and change hostonly adapter to the new one
Log into docker-machine and change connection parameters into bootlocal.sh
```
$ docker-machine ssh *machinename*
$ vim /var/lib/boot2docker/bootlocal.sh 
```
change the VBOXHOSTIP to the new adapter ip
```
su - docker -c 'sh -c "sshfs -o UserKnownHostsFile=/dev/null -o loglevel=debug -o StrictHostKeyChecking=no -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 -o Ciphers=arcfour,auto_cache,reconnect,big_writes,allow_other,default_permissions -o uid=1000 -o gid=50 YOURUSERNAME@VBOXHOSTIP:/Users/ /Users/ " &'
```
Restart your vm 



## Install
Download repository and change permission on script
```bash
git clone git@github.com:Atamos/docker-machine-sshfs.git 
cd docker-machine-sshfs && chmod +x ./scr/docker-machine-sshfs
```

## Usage
```bash
Usage: docker-machine-sshfs [COMMAND] [OPTIONS]

Commands:
  install	Install docker-machine-sshfs and all of its dependencies.

Options:
  -m, --machine-name name		When suplied syncs with the given docker machine host
  -l, --log-level LOG_LEVEL		Specify the logging level. One of: DEBUG INFO   . Default: INFO
  -h, --help				Print this help text and exit.
```

##Example
```bash
$ docker-machine-sshfs install -l DEBUG -m devmachine
 [INFO] Starting install of docker-machine-sshfs 
 [INFO] Initializing docker machine devmachine
 [INFO] check if docker_machine exists
 ...
```
At the end of execution you can find a new docker-machine ready for use with /Users mounted as sshfs.fuse filesystem.


