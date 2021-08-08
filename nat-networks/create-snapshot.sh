#!/bin/bash

thedomain="microk8s-1-192.168.122.210"
thedisk="microk8s-1"
snapshotname="initial"
targetdisk="vda"

# look at '<disk>' types, can have type other than file
virsh dumpxml $thedomain | grep '<disk' -A5

# show block level devices
virsh domblklist $thedomain

# pull default pool path from xml
pooldir=$(virsh pool-dumpxml default | grep -Po "(?<=path\>)[^<]+")
echo "default pool dir: $pooldir"

# create snapshot in default pool location
set -ex
virsh snapshot-create-as $thedomain --name $snapshotname --disk-only --diskspec vda,file=$pooldir/$thedisk.$snapshotname --diskspec hdd,snapshot=no

# list snapshot
virsh snapshot-list $thedomain

