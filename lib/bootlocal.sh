#!/bin/bash
cp /var/lib/boot2docker/ssh/id_rsa /var/lib/boot2docker/ssh/id_rsa.pub /home/docker/.ssh/
chown  docker:staff /home/docker/.ssh/id_rsa.pub /home/docker/.ssh/id_rsa
umount /Users
mkdir /Users
chown docker:staff /Users
su - docker -c  'tce-load -i /var/lib/boot2docker/sshfs-fuse-2.5.x86_64.tcz'
sudo sh -c "echo 'user_allow_other' > /etc/fuse.conf"
su - docker -c 'sh -c "sshfs {SSHFS_OPTIONS} -o uid={SSHFS_UID} -o gid={SSHFS_GUID} {USER}@{VBOXIP}:/Users/ /Users/"'
sysctl -w vm.max_map_count=262144
echo 'ready'

