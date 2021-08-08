#!/bin/bash

for octet in $(seq 130 131); do
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.$octet.10
done
