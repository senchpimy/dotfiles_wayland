-- Environment Variables Dynamic Configuration
local HOME = os.getenv("HOME")
local scrPath = HOME .. "/.local/share/bin"

-- System & Tool Paths
hl.env("SCRIPTS", scrPath)
hl.env("PATH", os.getenv("PATH") .. ":" .. scrPath)

-- Global XDG environment variables (Standardizing paths)
hl.env("XDG_STATE_HOME",  HOME .. "/.local/state")
hl.env("XDG_DATA_HOME",   HOME .. "/.local/share")
hl.env("XDG_CONFIG_HOME", HOME .. "/.config")
hl.env("XDG_CACHE_HOME",  HOME .. "/.cache")

-- User Directories
hl.env("XDG_DESKTOP_DIR",   HOME .. "/Desktop")
hl.env("XDG_DOWNLOAD_DIR",  HOME .. "/Downloads")
hl.env("XDG_DOCUMENTS_DIR", HOME .. "/Documents")
hl.env("XDG_PICTURES_DIR",  HOME .. "/Pictures")
hl.env("XDG_VIDEOS_DIR",    HOME .. "/Videos")
hl.env("XDG_MUSIC_DIR",     HOME .. "/Music")

-- Apps & Scaling
hl.env("FREETYPE_PROPERTIES", "truetype:interpreter-version=40")
hl.env("GDK_DPI_SCALE", "1")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- App Specifics
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("OBSIDIAN_USE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- Input Method
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("GTK_IM_MODULE", "wayland")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")

-- GPU
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")

-- Cache paths
hl.env("CUDA_CACHE_PATH", HOME .. "/.cache/cuda")
hl.env("__GL_SHADER_DISK_CACHE_PATH", HOME .. "/.cache/nv")
