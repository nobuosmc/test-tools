#!/usr/bin/env python3
import paramiko

# Inline list of nodes
nodes = ["1.1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4", "5.5.5.5"]

# SSH credentials
username = input("Enter SSH username: ")
password = input("Enter SSH password: ")

# Function to run commands on a single node
def test(node, username, password):
    print(f"Connecting to {node} as {username} ...")
    try:
        # Create SSH client
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(node, username=username, password=password)

        # Commands to run
        commands = [
            "echo 'Running commands on $(hostname)...'",
            "pwd",
            "ls -l",
            "df -k",
            "du -h --max-depth=1 2>/dev/null"
        ]

        for cmd in commands:
            stdin, stdout, stderr = ssh.exec_command(cmd)
            output = stdout.read().decode()
            error = stderr.read().decode()
            if output:
                print(output)
            if error:
                print(error)

        print("-" * 40)
        ssh.close()
    except Exception as e:
        print(f"Failed to connect to {node}: {e}")
        print("-" * 40)

# Loop through nodes and run test
for node in nodes:
    test(node, username, password)