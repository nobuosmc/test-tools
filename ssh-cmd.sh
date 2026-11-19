#!/bin/bash


nodeList="172.27.47.8 172.27.47.8 172.27.47.8 172.27.47.8 172.27.47.8 172.27.47.8"

function cx8_ibConfig () {
    local node="$1"
    local username="$2"
    local passwd="$3"

    echo "Connecting to $node ... $username $passwd"
    sshpass -p "$passwd" ssh -o StrictHostKeyChecking=no "$username@$node" "
      echo 'Running ls -l on $(hostname)'
      ls -l
      df -k
      du -h
    "
    echo "---------------------------------"
}

username="test"
passwd="Super123"

for node in $nodeList; do
  echo "ssh into $node to config CX8"
  cx8_ibConfig $node $username $passwd
  sleep 1
done

