#!/bin/bash

# List of switch IPs
SWITCHES=(
"10.10.6.85"
"10.10.122.247"
"10.10.122.34"
"10.10.17.189"
"10.10.6.131"
"10.10.51.24"
"10.10.65.223"
"10.10.122.50"
"10.10.121.155"
)

# SSH credentials
USER="admin"
PASS="Super_123"

# Command to run on each switch
CMD="nv show cluster apps running"
# CMD="nv action reset system factory default"

echo "Starting command execution on switches..."
echo "-------------------------------------------"

for IP in "${SWITCHES[@]}"; do
  echo ">>> Connecting to $IP"
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "$CMD"
  # sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "nv set cluster state disable"
  # sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "nv config apply"
  # sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "nv config save"
  if [ $? -ne 0 ]; then
    echo "⚠️  Failed to connect or run command on $IP"
  fi
  echo "-------------------------------------------"
done

echo "All done!"

