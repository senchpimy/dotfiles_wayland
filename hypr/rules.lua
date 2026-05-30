-- Window and Layer Rules

-- Layer Rules
local blur_layers = { "rofi", "notifications", "swaync-notification-window", "swaync-control-center", "logout_dialog", "bar", "cornertl", "cornertr", "cornerbl", "cornerbr" }
for _, layer in ipairs(blur_layers) do
    hl.layer_rule({ match = { namespace = layer }, blur = true, ignore_alpha = 0 })
end

hl.layer_rule({ match = { namespace = "sideleft.*" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "sideright.*" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "bar" }, no_anim = true, ignore_alpha = 0.64 })
hl.layer_rule({ match = { namespace = "corner.*" }, ignore_alpha = 0.64 })

-- Window Rules
-- Opacity Rules
local opacity_080 = { "Steam", "steam", "steamwebhelper", "code-oss", "Code", "code-url-handler", "code-insiders-url-handler", "org.kde.dolphin", "org.kde.ark", "nwg-look", "qt5ct", "qt6ct", "kvantummanager", "com.github.tchx84.Flatseal", "hu.kramo.Cartridges", "gnome-boxes", "discord", "WebCord", "ArmCord", "app.drey.Warp", "net.davidotek.pupgui2", "yad", "Signal", "io.github.alainm23.planify", "io.gitlab.theevilskeleton.Upscaler", "com.github.unrud.VideoDownloader", "org.freedesktop.impl.portal.desktop.gtk", "org.freedesktop.impl.portal.desktop.hyprland" }
for _, class in ipairs(opacity_080) do
    hl.window_rule({ opacity = "0.80 0.80", match = { class = "^(" .. class .. ")$" }})
end

local opacity_090 = { "Brave-browser", "kitty" }
for _, class in ipairs(opacity_090) do
    hl.window_rule({ opacity = "0.90 0.90", match = { class = "^(" .. class .. ")$" }})
end

hl.window_rule({ opacity = "0.95 0.95", match = { class = "^(Spotify|spotify)$" }})
hl.window_rule({ opacity = "0.80 0.70", match = { class = "^(pavucontrol|blueman-manager|nm-applet|nm-connection-editor|org.kde.polkit-kde-authentication-agent-1)$" }})

-- Float Rules
hl.window_rule({ float = true, match = { class = "com-group_finity-mascot-Main" }, no_blur = true, no_focus = true, no_shadow = true, border_size = 0 })
hl.window_rule({ float = true, match = { class = "org.kde.dolphin", title = "Progress Dialog — Dolphin" }})
hl.window_rule({ float = true, match = { class = "org.kde.dolphin", title = "Copying — Dolphin" }})
hl.window_rule({ float = true, match = { title = "Picture-in-Picture" }})
hl.window_rule({ float = true, match = { class = "firefox", title = "Library" }})
hl.window_rule({ float = true, match = { class = "vlc|kvantummanager|qt5ct|qt6ct|nwg-look|org.kde.ark|Signal|com.github.rafostar.Clapper|app.drey.Warp|net.davidotek.pupgui2|yad|eog|io.github.alainm23.planify|io.gitlab.theevilskeleton.Upscaler|com.github.unrud.VideoDownloader|pavucontrol|blueman-manager|nm-applet|nm-connection-editor|flameshot" }})

-- Special Rules
hl.window_rule({ no_anim = true, match = { class = "flameshot" }})
hl.window_rule({ float = true, no_anim = true, match = { title = "tablet_utils" }})
hl.window_rule({ float = true, no_anim = true, match = { title = "woomer" }})
hl.window_rule({ opacity = 1.0, match = { class = "firefox" }})

hl.window_rule({ float = true, fullscreen = true, border_size = 0, match = { class = "neo-matrix" }})
hl.window_rule({ border_size = 0, rounding = 0, no_shadow = true, match = { title = "StreamCam" }})
