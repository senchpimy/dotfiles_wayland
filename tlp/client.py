#!/usr/bin/env python3
import argparse
import socket
import subprocess

#Ejecutar notify-send "TLP Manager" "Profile switched to $PROFILE"
subprocess.run(["notify-send", "TLP Manager", "Profile switched"])

parser = argparse.ArgumentParser(
    description="Client for TLP Manager"
)
parser.add_argument(
    "-s",
    "--switch",
    action="store_true",
    help="Switch between power profiles",
)
args = parser.parse_args()

try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect("/tmp/tlp_manager.sock")
except socket.error as msg:
    print(f"Socket error: {msg}")
    exit(1)

if args.switch:
    s.sendall(b"switch")
    print(s.recv(1024).decode(), end="")
    s.close()
else:
    s.sendall(b"status")
    print(s.recv(1024).decode(), end="")
    s.close()
