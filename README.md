# docker-machine-sshfs

This script can be used to create or update a docker-machine changing the mount point /Users from **vboxsf** to **sshfs.fuse**. 
The performance are near to local machine development.

## Pre-Requires
- docker-toolbox or docker-machine already installed
- docker-machine version > **0.4.1**

##sshfs for tinycore 64bit 
The sshfs package for 64bit tinycore linux is custom compiled , becouse I'm unable to find a right package in tinycore 64 bit repository. 
If this version doesn't work on your docker-machine you can recompile it, following this instructions

* Download the sshfs-fuse from the original website http://fuse.sourceforge.net/sshfs.html
* Copy it in the docker-machine for build
```
 $ docker-machine scp sshfs.tgz machinename:/root/
```
* install the dipendencies 
``` 
$ docker-machine ssh machinename 
$ tce load gcc-dev # or some library package that configure may require
$ tce-load -iw compiletc.tcz
$ tce-load -wi linux-headers-3.0.21-tinycore.tcz
$ tce-load -iw squashfs-tools-4.x.tcz
$ tce-load -iw glibc_apps.tcz
```
* Extract the archive
```
$ tar zxvf sshfs.tgz
$ cd sshfs
```
* Compile it
``` 
$ ./configure --prefix=/usr/local \
 RPCGEN="$(readlink -f $(which rpcgen)) -Y "$(dirname $(which cpp))
$ make
```
* Create package
```
$ touch /tmp/sshfs
$ make DESTDIR=/tmp/sshfs install-strip
cd /tmp
mksquashfs sshfs sshfs.tcz
```
Now you can install the package with  
```
tce -i sshfs.tcz
```

## Issues and Workaround
Sometimes can happen that with many virtualmachines Virtualbox lose arp  with hostonly network adapter.
This can generate some issues with sshfs connection like missing mountpoint or timout. See https://forums.virtualbox.org/viewtopic.php?f=8&t=63998

You can fix it with this workaround
In your shell create a new vbox adapter
```
$ vboxmanage hostonlyif create
```
Go on virtualbox , select your machine , go to settings , network, and change hostonly adapter to the new one
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

NOTE: you can find hostadapter ip with ifconfig on your shell


## Install
Download repository and change permission on script
```bash
git clone git@github.com:Atamos/docker-machine-sshfs.git 
cd docker-machine-sshfs && chmod +x ./scr/docker-machine-sshfs
cd ./scr && ./docker-machine-sshfs [COMMAND] [OPTIONS] 
```
**NOTE: Please, launch the command into src directory for now.**

**NOTE2: The -m options is mandatory . This issue should be fixed soon.** 

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

Check that sshfs is mounted 
```
$ docker-machine ssh _machinename_ mount  | grep sshfs.fuse | wc -l | xargs
```
The output should be  **1**

###If you can't find sshf.fuse mount point or it disappears after short timout
* First try to reboot your vm 
```
$ docker-machine stop _machinename_ 
$ docker-machine start _machinename_
```
* Try to change the Virtualbox hostonlynetwork (see the issues on top of this readme)
*You should consider to create a hostonlynetork for each docker-machine*


