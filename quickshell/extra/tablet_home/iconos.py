
import subprocess
import os

def get_icon_theme():
    try:
        theme = subprocess.check_output([
            "gsettings", "get", "org.gnome.desktop.interface", "icon-theme"
        ]).decode("utf-8").strip().strip("'")  # Elimina comillas
        return theme
    except subprocess.CalledProcessError:
        return None

def find_icon_theme_path(og_theme,icon):
    icon_dirs = ["/usr/share/icons/", "~/.icons/", "~/.local/share/icons/"]
    def_theme="hicolor"
    for base_dir in icon_dirs:
        for theme in [og_theme,def_theme]:
            for i in ['/apps/scalable/','/scalable/apps/',"/256x256/apps/","/128x128/apps/"]:
                for end in [".svg", ".png"]:
                    theme_path = os.path.expanduser(base_dir+theme+i+icon+end)
                    if os.path.exists(theme_path):
                        return True,theme_path
    return False,None
