#!/bin/bash

# add ssh fingerprint to known_hosts so we don't have to be asked later
ssh-keyscan -H 192.168.140.10 >> ~/.ssh/known_hosts
ssh-keyscan -H 192.168.141.10 >> ~/.ssh/known_hosts

# fail if any of these commands fail
set -ex

echo ========================================

echo run tests from 192.168.140.10
ssh -i id_rsa ubuntu@192.168.140.10 "hostname; ping -c1 192.168.140.1; dig routed1.home.lab +short; dig -x 192.168.140.10 +short"
ssh -i id_rsa ubuntu@192.168.140.10 "ping -c1 192.168.141.1; nc -vz 192.168.141.10 22"


echo ========================================


echo run tests from 192.168.141.10
ssh -i id_rsa ubuntu@192.168.141.10 "hostname; ping -c1 192.168.141.1; dig routed2.home.lab +short; dig -x 192.168.141.10 +short"
ssh -i id_rsa ubuntu@192.168.141.10 "ping -c1 192.168.140.1; nc -vz 192.168.140.10 22"


set +ex

echo ""
echo ""
echo "DONE. All tests ran successfully"

