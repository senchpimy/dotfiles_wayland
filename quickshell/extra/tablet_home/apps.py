import iconos
import os

dirs = ['/usr/share/applications/', "/home/plof/.local/share/applications/"]
theme = iconos.get_icon_theme()

# Cargar los datos de ~/.cache/rofi3.druncache
cache_path = os.path.expanduser("~/.cache/rofi3.druncache")
usage_order = {}
if os.path.exists(cache_path):
    with open(cache_path, "r") as f:
        for line in f:
            parts = line.strip().split(" ", 1)
            if len(parts) == 2:
                usage_order[parts[1]] = int(parts[0])

found_apps = []
other_apps = []

for dir in dirs:
    for i in os.listdir(dir):
        file_path = os.path.join(dir, i)
        with open(file_path, 'r', errors='ignore') as f:
            t = f.read()
            
            if "Type=Application" not in t:
                continue
            
            if "NoDisplay=true" in t:
                continue
            
            name_ind = t.find('Name=') + 5
            stop = t[name_ind:].find('\n')
            nombre = t[name_ind:name_ind + stop]
            
            name_ind = t.find('Icon=') + 5
            stop = t[name_ind:].find('\n')
            icon = t[name_ind:name_ind + stop]
            
            exists, full = iconos.find_icon_theme_path(theme, icon)
            if not exists:continue
            app_data = (nombre, full, i)
            
            if i in usage_order:
                found_apps.append((usage_order[i], app_data))
            else:
                other_apps.append(app_data)

found_apps.sort(reverse=True, key=lambda x: x[0])
for _, app in found_apps:
    print("@".join(app))

for app in other_apps:
    print("@".join(app))
