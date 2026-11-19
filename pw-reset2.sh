


#!/bin/bash

# List of switch IPs
SWITCHES=(
"10.10.103.113"
"10.10.75.124"
"10.10.107.90"
"10.10.102.203"
"10.10.75.36"
"10.10.74.31"
"10.10.110.180"
"10.10.85.4"
"10.10.125.194"
)

# SSH credentials
USER="admin"
PASS="Super_123"

# Command to run on each switch
CMD="nv show cluster apps running"

echo "Starting command execution on switches..."
echo "-------------------------------------------"

for IP in "${SWITCHES[@]}"; do
  echo ">>> Connecting to $IP"
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "$CMD"
  if [ $? -ne 0 ]; then
    echo "⚠️  Failed to connect or run command on $IP"
  fi
  echo "-------------------------------------------"
done

echo "All done!"





#!/bin/bash

# List of switch IPs
SWITCHES=(
"10.10.103.113"
"10.10.75.124"
"10.10.107.90"
"10.10.102.203"
"10.10.75.36"
"10.10.74.31"
"10.10.110.180"
"10.10.85.4"
"10.10.125.194"
)

# SSH credentials
USER="admin"
PASS="Super_123"

# Command to run on each switch
CMD="nv show cluster apps running"

echo "Starting command execution on switches..."
echo "-------------------------------------------"

for IP in "${SWITCHES[@]}"; do
  echo ">>> Connecting to $IP"
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "nv set cluster state disable"
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "nv config apply"
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "$USER@$IP" "nv config save" 
  if [ $? -ne 0 ]; then
    echo "⚠️  Failed to connect or run command on $IP"
  fi
  echo "-------------------------------------------"
done

echo "All done!"
 
nv show cluster apps running
nv set cluster state disable
nv config apply
nv config save


nv set cluster state enabled
nv config apply
nv config save
nv action generate sdn config app nmx-controller type fm_config
nv show sdn config app nmx-controller type fm_config files

sudo vi /host/cluster_infra/app_config/nmx-controller/fm_config/nmx-controller_fm_config

MNNVL_TOPOLOGY=gb200_nvl72r1_c2g4_topology

nv action install sdn config app nmx-controller type fm_config files nmx-controller_fm_config_<autocomplete>
nv action stop cluster app nmx-controller
nv action start cluster app nmx-controller
nv show cluster apps running
