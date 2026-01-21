#!/usr/bin/env python3
import subprocess
import re
import json
import sys

import subprocess
import re
import json
import sys
import os


def get_cmdline(pid):
    try:
        with open(f"/proc/{pid}/cmdline", "r") as f:
            cmdline = f.read().split('\0')
            args = [arg for arg in cmdline if arg]
            if not args:
                return None

            prog = os.path.basename(args[0])
            if len(args) > 1:
                return f"{prog} {' '.join(args[1:])}"
            return prog
    except:
        return None


def get_ports():
    try:
        result = subprocess.run(
            ['ss', '-tunlp'], capture_output=True, text=True)
        output = result.stdout

        ports = []

        # Skip header
        lines = output.strip().split('\n')[1:]

        # Define development indicators
        DEV_PROCESSES = {
            'node', 'npm', 'yarn', 'pnpm', 'python', 'python3', 'ruby', 'go', 'rustc', 'java',
            'php', 'vite', 'webpack', 'next', 'nuxt', 'flask', 'django', 'uvicorn',
            'gunicorn', 'rails', 'postgres', 'mysqld', 'redis-server', 'mongod',
            'docker', 'docker-proxy', 'containerd', 'bun', 'deno', 'air', 'cargo',
            'surreal', 'pocketbase', 'strapi', 'supabase', 'vercel', 'wrangler',
            'ollama', 'llama', 'local-ai', 'minio', 'nginx', 'apache2', 'httpd'
        }

        # Known system processes to explicitly exclude
        SYSTEM_PROCESSES = {
            'sshd', 'systemd-resolve', 'cupsd', 'avahi-daemon', 'rpcbind', 'master',
            'chronyd', 'smbd', 'nmbd', 'bluetoothd', 'iwd', 'wpa_supplicant',
            'dnsmasq', 'rpc.statd', 'rpc.mountd', 'nfsd'
        }

        def is_development(port, process, cmdline=None):
            process_lower = process.lower()
            cmdline_lower = cmdline.lower() if cmdline else ""

            if any(sys_proc in process_lower for sys_proc in SYSTEM_PROCESSES):
                return False

            if 3000 <= port <= 100000:
                return True

            if port in [1337, 27017, 28017, 5432, 3306, 6379, 11434]:
                return True

            if any(tool in process_lower for tool in DEV_PROCESSES) or \
               any(tool in cmdline_lower for tool in DEV_PROCESSES):
                return True

            return False

        for line in lines:
            parts = re.split(r'\s+', line)

            if len(parts) < 6:
                continue

            protocol = parts[0]
            if protocol != 'tcp':
                continue

            state = parts[1]
            local_addr = parts[4]
            process_info = " ".join(parts[6:]) if len(parts) > 6 else ""

            if protocol == 'tcp' and state != 'LISTEN':
                continue

            if ':' in local_addr:
                port_str = local_addr.split(':')[-1]
                try:
                    port = int(port_str)
                except ValueError:
                    continue
            else:
                continue

            matches = re.findall(r'"([^"]+)",pid=(\d+)', process_info)

            if not matches:
                if is_development(port, "Unknown"):
                    ports.append({
                        "protocol": protocol,
                        "port": port,
                        "process": "Unknown",
                        "pid": -1
                    })
            else:
                for name, pid in matches:
                    pid_int = int(pid)
                    cmdline = get_cmdline(pid_int)
                    if is_development(port, name, cmdline):
                        ports.append({
                            "protocol": protocol,
                            "port": port,
                            "process": cmdline if cmdline else name,
                            "pid": pid_int
                        })

        # Deduplicate based on port and pid
        unique_ports = []
        seen = set()
        for p in ports:
            key = (p['protocol'], p['port'], p['pid'])
            if key not in seen:
                seen.add(key)
                unique_ports.append(p)

        unique_ports.sort(key=lambda x: x['port'])

        print(json.dumps(unique_ports))

    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

        unique_ports = []
        seen = set()
        for p in ports:
            key = (p['protocol'], p['port'], p['pid'])
            if key not in seen:
                seen.add(key)
                unique_ports.append(p)

        unique_ports.sort(key=lambda x: x['port'])

        print(json.dumps(unique_ports))

    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)


if __name__ == "__main__":
    get_ports()
