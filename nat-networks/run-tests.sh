#!/bin/bash

# add ssh fingerprint to known_hosts so we don't have to be asked later
ssh-keyscan -H 192.168.130.10 >> ~/.ssh/known_hosts
ssh-keyscan -H 192.168.131.10 >> ~/.ssh/known_hosts

# fail if any of these commands fail

echo ========================================
set -ex

echo run tests from 192.168.130.10
ssh -i id_rsa ubuntu@192.168.130.10 "hostname; ping -c1 192.168.130.1; dig nat1.home.lab +short; dig -x 192.168.130.10 +short"
ssh -i id_rsa ubuntu@192.168.130.10 "ping -c1 192.168.131.1"

set +e
echo "should not be able to reach to vm on different NAT network"
ssh -i id_rsa ubuntu@192.168.130.10 "nc -vz 192.168.131.10 22"
retVal=$?
echo "retVal = $retVal"
if [ $retVal -eq 0 ]; then
  echo "ERROR you should not be able to reach a vm on another NAT"
  exit 3
else
  echo "OK netcat to a VM on another NAT failed, which is expected"
fi

echo ========================================
set -ex

echo run tests from 192.168.131.10
ssh -i id_rsa ubuntu@192.168.131.10 "hostname; ping -c1 192.168.131.1; dig nat2.home.lab +short; dig -x 192.168.131.10 +short"
ssh -i id_rsa ubuntu@192.168.131.10 "ping -c1 192.168.130.1"

set +e
echo "should not be able to reach to vm on different NAT network"
ssh -i id_rsa ubuntu@192.168.131.10 "nc -vz 192.168.130.10 22"
if [ $? -eq 0 ]; then
  echo "ERROR you should not be able to reach a vm on another NAT"
  exit 3
else
  echo "OK netcat to a VM on another NAT failed, which is expected"
fi

set +ex

echo ""
echo ""
echo "DONE. All tests ran successfully"
